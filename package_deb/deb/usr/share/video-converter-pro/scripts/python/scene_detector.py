#!/usr/bin/env python3
"""
PySceneDetect Integration Service
Detects scene changes in videos and provides scene list for optimization
Based on: https://www.scenedetect.com/
"""

import sys
import json
import argparse
from pathlib import Path

try:
    from scenedetect import VideoManager, SceneManager
    from scenedetect.detectors import ContentDetector, ThresholdDetector, AdaptiveDetector
    from scenedetect.frame_timecode import FrameTimecode
except ImportError as e:
    print(json.dumps({
        'success': False,
        'error': f'Missing dependencies: {e}. Install with: pip install scenedetect[opencv]'
    }))
    sys.exit(1)


class SceneDetectorService:
    """Service for detecting scenes in videos using PySceneDetect"""
    
    def __init__(self, method='adaptive', threshold=30.0):
        """
        Initialize scene detector
        
        Args:
            method: Detection method ('adaptive', 'content', 'threshold')
            threshold: Threshold value for detection (method-dependent)
        """
        self.method = method
        self.threshold = threshold
    
    def detect_scenes(self, video_path, output_json=None, split_video=False, output_dir=None):
        """
        Detect scenes in a video
        
        Args:
            video_path: Path to input video
            output_json: Optional path to save scene list as JSON
            split_video: Whether to split video into separate files
            output_dir: Directory for split video files (if split_video=True)
        
        Returns:
            Dictionary with scene detection results
        """
        try:
            # Create video manager
            video_manager = VideoManager([video_path])
            scene_manager = SceneManager()
            
            # Choose detector based on method
            if self.method == 'adaptive':
                detector = AdaptiveDetector()
            elif self.method == 'content':
                detector = ContentDetector(threshold=self.threshold)
            elif self.method == 'threshold':
                detector = ThresholdDetector(threshold=self.threshold)
            else:
                return {
                    'success': False,
                    'error': f'Unknown detection method: {self.method}'
                }
            
            scene_manager.add_detector(detector)
            
            # Start detection
            video_manager.set_duration()
            video_manager.start()
            
            # Detect scenes
            scene_manager.detect_scenes(frame_source=video_manager)
            
            # Get scene list
            scene_list = scene_manager.get_scene_list()
            
            # Convert to JSON-serializable format
            scenes = []
            for i, (start_time, end_time) in enumerate(scene_list):
                scenes.append({
                    'scene_number': i + 1,
                    'start_time': str(start_time),
                    'start_seconds': start_time.get_seconds(),
                    'end_time': str(end_time),
                    'end_seconds': end_time.get_seconds(),
                    'duration': (end_time - start_time).get_seconds()
                })
            
            result = {
                'success': True,
                'video_path': video_path,
                'total_scenes': len(scenes),
                'scenes': scenes,
                'method': self.method,
                'threshold': self.threshold
            }
            
            # Save JSON if requested
            if output_json:
                with open(output_json, 'w') as f:
                    json.dump(result, f, indent=2)
                result['json_path'] = output_json
            
            # Split video if requested
            if split_video and output_dir:
                split_result = self._split_video(video_path, scene_list, output_dir)
                result['split_result'] = split_result
            
            return result
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
        finally:
            if 'video_manager' in locals():
                video_manager.release()
    
    def _split_video(self, video_path, scene_list, output_dir):
        """Split video into separate scene files"""
        try:
            from scenedetect.video_splitter import split_video_ffmpeg
            
            output_dir = Path(output_dir)
            output_dir.mkdir(parents=True, exist_ok=True)
            
            split_files = []
            for i, (start_time, end_time) in enumerate(scene_list):
                output_path = output_dir / f'scene_{i+1:03d}.mp4'
                split_video_ffmpeg(
                    [video_path],
                    scene_list,
                    str(output_path),
                    video_manager=None,
                    arg_override='-c:v libx264 -preset fast -crf 22'
                )
                split_files.append(str(output_path))
            
            return {
                'success': True,
                'output_dir': str(output_dir),
                'split_files': split_files,
                'total_files': len(split_files)
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def get_optimal_quality_settings(self, scene_list):
        """
        Analyze scenes to recommend optimal quality settings
        
        Args:
            scene_list: List of detected scenes
        
        Returns:
            Dictionary with quality recommendations
        """
        if not scene_list:
            return {
                'success': False,
                'error': 'No scenes detected'
            }
        
        # Analyze scene durations
        durations = [scene['duration'] for scene in scene_list]
        avg_duration = sum(durations) / len(durations)
        min_duration = min(durations)
        max_duration = max(durations)
        
        # Analyze scene count
        total_scenes = len(scene_list)
        
        # Recommendations based on scene characteristics
        recommendations = {
            'scene_count': total_scenes,
            'avg_scene_duration': avg_duration,
            'min_scene_duration': min_duration,
            'max_scene_duration': max_duration,
            'has_rapid_cuts': min_duration < 2.0 and total_scenes > 20,
            'has_long_scenes': max_duration > 30.0,
            'suggested_bitrate_mode': 'crf' if avg_duration > 5.0 else 'bitrate',
            'suggested_crf': 18 if min_duration > 3.0 else 23,
            'suggested_bitrate': 8000 if avg_duration > 5.0 else 5000
        }
        
        return {
            'success': True,
            'recommendations': recommendations
        }


def main():
    parser = argparse.ArgumentParser(description='PySceneDetect Scene Detection Service')
    parser.add_argument('--input', required=True, help='Input video path')
    parser.add_argument('--method', default='adaptive', 
                       choices=['adaptive', 'content', 'threshold'],
                       help='Scene detection method')
    parser.add_argument('--threshold', type=float, default=30.0,
                       help='Detection threshold (for content/threshold methods)')
    parser.add_argument('--output-json', help='Output JSON file for scene list')
    parser.add_argument('--split', action='store_true',
                       help='Split video into separate scene files')
    parser.add_argument('--output-dir', help='Output directory for split files')
    parser.add_argument('--analyze-quality', action='store_true',
                       help='Analyze scenes and provide quality recommendations')
    
    args = parser.parse_args()
    
    # Initialize detector
    detector = SceneDetectorService(method=args.method, threshold=args.threshold)
    
    # Detect scenes
    result = detector.detect_scenes(
        video_path=args.input,
        output_json=args.output_json,
        split_video=args.split,
        output_dir=args.output_dir
    )
    
    # Add quality analysis if requested
    if args.analyze_quality and result['success']:
        quality_analysis = detector.get_optimal_quality_settings(result['scenes'])
        result['quality_analysis'] = quality_analysis
    
    # Output JSON result
    print(json.dumps(result, indent=2))
    
    sys.exit(0 if result['success'] else 1)


if __name__ == '__main__':
    main()

