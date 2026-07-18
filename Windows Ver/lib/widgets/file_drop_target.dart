import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:io';

/// Widget che avvolge un child e permette il drag & drop di file
class FileDropTarget extends StatefulWidget {
  final Widget child;
  final Function(List<String> filePaths) onFilesDropped;
  final bool enabled;

  const FileDropTarget({
    super.key,
    required this.child,
    required this.onFilesDropped,
    this.enabled = true,
  });

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState extends State<FileDropTarget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Su desktop, usa DropTarget se disponibile
    if (kIsWeb || (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS)) {
      // Su web o mobile, non supportato
      return widget.child;
    }

    // Su desktop Linux/Windows/macOS, usa DropTarget
    return DropTarget(
      onDragDone: widget.enabled
          ? (details) {
              setState(() {
                _isDragging = false;
              });
              _handleDrop(details);
            }
          : null,
      onDragEntered: widget.enabled
          ? (details) {
              setState(() {
                _isDragging = true;
              });
            }
          : null,
      onDragExited: widget.enabled
          ? (details) {
              setState(() {
                _isDragging = false;
              });
            }
          : null,
      enable: widget.enabled,
      child: Stack(
        children: [
          widget.child,
          if (_isDragging && widget.enabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rilascia i file qui',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleDrop(DropDoneDetails details) {
    final filePaths = <String>[];
    
    for (final item in details.files) {
      _collectFilePaths(item, filePaths);
    }

    if (filePaths.isNotEmpty) {
      widget.onFilesDropped(filePaths);
    }
  }

  /// Raccoglie tutti i percorsi file, espandendo directory e supportando file multipli
  void _collectFilePaths(dynamic item, List<String> filePaths) {
    final path = item.path;
    if (path == null || path.isEmpty) return;

    if (item is DropItemDirectory) {
      // Espandi directory: raccogli tutti i file dai figli (ricorsivo)
      for (final child in item.children) {
        _collectFilePaths(child, filePaths);
      }
      // Se children è vuoto (es. macOS), elenca i file nella directory
      if (item.children.isEmpty) {
        try {
          final dir = Directory(path);
          if (dir.existsSync()) {
            for (final entity in dir.listSync(recursive: true)) {
              if (entity is File && entity.existsSync()) {
                final p = entity.path;
                if (!filePaths.contains(p)) filePaths.add(p);
              }
            }
          }
        } catch (_) {}
      }
    } else {
      // File singolo
      final fileObj = File(path);
      if (fileObj.existsSync()) {
        filePaths.add(path);
      }
    }
  }
}

