import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FE Media Converter 🎬🎵🖼️'**
  String get appTitle;

  /// No description provided for @conversion.
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get conversion;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @removeCompletedFiles.
  ///
  /// In en, this message translates to:
  /// **'Remove completed files from queue?'**
  String get removeCompletedFiles;

  /// No description provided for @waitingForConversion.
  ///
  /// In en, this message translates to:
  /// **'Waiting for conversion'**
  String get waitingForConversion;

  /// No description provided for @emptyEntireQueue.
  ///
  /// In en, this message translates to:
  /// **'Empty entire queue?'**
  String get emptyEntireQueue;

  /// No description provided for @conversionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Conversion completed'**
  String get conversionCompleted;

  /// No description provided for @conversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get conversionFailed;

  /// No description provided for @conversionPausedStatus.
  ///
  /// In en, this message translates to:
  /// **'Conversion paused'**
  String get conversionPausedStatus;

  /// No description provided for @removeFromQueueQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue?'**
  String get removeFromQueueQuestion;

  /// No description provided for @areYouSureRemove.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {fileName}?'**
  String areYouSureRemove(Object fileName);

  /// No description provided for @areYouSureStop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop {fileName}?'**
  String areYouSureStop(Object fileName);

  /// No description provided for @pauseConversionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Pause conversion?'**
  String get pauseConversionQuestion;

  /// No description provided for @areYouSurePause.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pause {fileName}?'**
  String areYouSurePause(Object fileName);

  /// No description provided for @stopConversionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Stop conversion?'**
  String get stopConversionQuestion;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get addToQueue;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @videoCodec.
  ///
  /// In en, this message translates to:
  /// **'Video Codec'**
  String get videoCodec;

  /// No description provided for @videoBitrate.
  ///
  /// In en, this message translates to:
  /// **'Video Bitrate'**
  String get videoBitrate;

  /// No description provided for @qualityMode.
  ///
  /// In en, this message translates to:
  /// **'Quality Mode'**
  String get qualityMode;

  /// No description provided for @constantQuality.
  ///
  /// In en, this message translates to:
  /// **'Constant Quality'**
  String get constantQuality;

  /// No description provided for @constantBitrate.
  ///
  /// In en, this message translates to:
  /// **'Constant Bitrate'**
  String get constantBitrate;

  /// No description provided for @crfDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintains constant quality, variable file size'**
  String get crfDescription;

  /// No description provided for @bitrateDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintains constant file size, variable quality'**
  String get bitrateDescription;

  /// No description provided for @videoSettings.
  ///
  /// In en, this message translates to:
  /// **'Video Settings'**
  String get videoSettings;

  /// No description provided for @advancedVideoSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Video Settings'**
  String get advancedVideoSettings;

  /// No description provided for @codecDescription.
  ///
  /// In en, this message translates to:
  /// **'Select video compression format'**
  String get codecDescription;

  /// No description provided for @bitrateMode.
  ///
  /// In en, this message translates to:
  /// **'Bitrate Mode'**
  String get bitrateMode;

  /// No description provided for @mediaType.
  ///
  /// In en, this message translates to:
  /// **'Media Type'**
  String get mediaType;

  /// No description provided for @selectMedia.
  ///
  /// In en, this message translates to:
  /// **'Select {mediaType}'**
  String selectMedia(Object mediaType);

  /// No description provided for @noFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No files selected'**
  String get noFilesSelected;

  /// No description provided for @clickToBrowse.
  ///
  /// In en, this message translates to:
  /// **'Click on \"Browse {mediaType}\" to select files'**
  String clickToBrowse(Object mediaType);

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} files selected'**
  String filesSelected(Object count);

  /// No description provided for @selectionCleared.
  ///
  /// In en, this message translates to:
  /// **'Selection cleared'**
  String get selectionCleared;

  /// No description provided for @filesAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'{count} files added to queue'**
  String filesAddedToQueue(Object count);

  /// No description provided for @dropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here to add them'**
  String get dropFilesHere;

  /// No description provided for @dragAndDropSupported.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop files here'**
  String get dragAndDropSupported;

  /// No description provided for @outputFormat.
  ///
  /// In en, this message translates to:
  /// **'Output Format - {mediaType}'**
  String outputFormat(Object mediaType);

  /// No description provided for @qualitySettings.
  ///
  /// In en, this message translates to:
  /// **'Quality Settings'**
  String get qualitySettings;

  /// No description provided for @videoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video Quality:'**
  String get videoQuality;

  /// No description provided for @audioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality:'**
  String get audioQuality;

  /// No description provided for @videoFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Video Filters'**
  String get videoFilters;

  /// No description provided for @audioFilters.
  ///
  /// In en, this message translates to:
  /// **'Professional Audio Filters'**
  String get audioFilters;

  /// No description provided for @conversionQueue.
  ///
  /// In en, this message translates to:
  /// **'Conversion Queue'**
  String get conversionQueue;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String completedCount(Object completed, Object total);

  /// No description provided for @converting.
  ///
  /// In en, this message translates to:
  /// **'Converting...'**
  String get converting;

  /// No description provided for @noFilesInQueue.
  ///
  /// In en, this message translates to:
  /// **'No files in queue'**
  String get noFilesInQueue;

  /// No description provided for @addFilesFromConversion.
  ///
  /// In en, this message translates to:
  /// **'Add files from the Conversion page\nto start converting'**
  String get addFilesFromConversion;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @pauseConversion.
  ///
  /// In en, this message translates to:
  /// **'Pause conversion'**
  String get pauseConversion;

  /// No description provided for @stopConversion.
  ///
  /// In en, this message translates to:
  /// **'Stop conversion'**
  String get stopConversion;

  /// No description provided for @fileRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" removed from queue'**
  String fileRemoved(Object fileName);

  /// No description provided for @filePaused.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" paused'**
  String filePaused(Object fileName);

  /// No description provided for @fileStopped.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" stopped'**
  String fileStopped(Object fileName);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @conversionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Conversion in progress'**
  String get conversionInProgress;

  /// No description provided for @pausedAt.
  ///
  /// In en, this message translates to:
  /// **'Paused at {time}'**
  String pausedAt(Object time);

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed {time}'**
  String completedAt(Object time);

  /// No description provided for @failedAt.
  ///
  /// In en, this message translates to:
  /// **'Failed {time}'**
  String failedAt(Object time);

  /// No description provided for @pausedAtTime.
  ///
  /// In en, this message translates to:
  /// **'Paused at {time}'**
  String pausedAtTime(Object time);

  /// No description provided for @completedAtTime.
  ///
  /// In en, this message translates to:
  /// **'Completed at {time}'**
  String completedAtTime(Object time);

  /// No description provided for @failedAtTime.
  ///
  /// In en, this message translates to:
  /// **'Failed at {time}'**
  String failedAtTime(Object time);

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @outputFolder.
  ///
  /// In en, this message translates to:
  /// **'Output Folder'**
  String get outputFolder;

  /// No description provided for @sameAsInput.
  ///
  /// In en, this message translates to:
  /// **'Same as input folder'**
  String get sameAsInput;

  /// No description provided for @cpuThreads.
  ///
  /// In en, this message translates to:
  /// **'CPU Threads'**
  String get cpuThreads;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get autoDetect;

  /// No description provided for @concurrentConversions.
  ///
  /// In en, this message translates to:
  /// **'Concurrent Conversions'**
  String get concurrentConversions;

  /// No description provided for @concurrentConversionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Number of files to convert concurrently'**
  String get concurrentConversionsDesc;

  /// No description provided for @gpuAcceleration.
  ///
  /// In en, this message translates to:
  /// **'GPU Acceleration'**
  String get gpuAcceleration;

  /// No description provided for @useGpu.
  ///
  /// In en, this message translates to:
  /// **'Use GPU for conversion'**
  String get useGpu;

  /// No description provided for @gpuCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Better performance but limited compatibility'**
  String get gpuCompatibility;

  /// No description provided for @requiresCompatibleHardware.
  ///
  /// In en, this message translates to:
  /// **'Requires compatible hardware and drivers'**
  String get requiresCompatibleHardware;

  /// No description provided for @gpuType.
  ///
  /// In en, this message translates to:
  /// **'GPU Type'**
  String get gpuType;

  /// No description provided for @autoDetection.
  ///
  /// In en, this message translates to:
  /// **'Auto-detection'**
  String get autoDetection;

  /// No description provided for @selectGpuType.
  ///
  /// In en, this message translates to:
  /// **'Select the type of graphics card installed'**
  String get selectGpuType;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @professionalMediaConversion.
  ///
  /// In en, this message translates to:
  /// **'Professional media conversion application'**
  String get professionalMediaConversion;

  /// No description provided for @usesFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Uses FFmpeg for conversions. Make sure FFmpeg is installed on your system.'**
  String get usesFfmpeg;

  /// No description provided for @extractAudioOnly.
  ///
  /// In en, this message translates to:
  /// **'Extract Audio Only'**
  String get extractAudioOnly;

  /// No description provided for @extractAudioFromVideo.
  ///
  /// In en, this message translates to:
  /// **'Extract audio from video files (e.g., MP4 to MP3, MOV to WAV)'**
  String get extractAudioFromVideo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @audios.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audios;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @formats.
  ///
  /// In en, this message translates to:
  /// **'formats'**
  String get formats;

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'Active filters'**
  String get filtersActive;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @noiseReduction.
  ///
  /// In en, this message translates to:
  /// **'Noise Reduction'**
  String get noiseReduction;

  /// No description provided for @noiseReductionStrength.
  ///
  /// In en, this message translates to:
  /// **'Noise Reduction Strength'**
  String get noiseReductionStrength;

  /// No description provided for @reducesDigitalNoise.
  ///
  /// In en, this message translates to:
  /// **'Reduces digital noise and grain. High values may soften the image.'**
  String get reducesDigitalNoise;

  /// No description provided for @qualityEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Quality Enhancement'**
  String get qualityEnhancement;

  /// No description provided for @sharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get sharpness;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @gamma.
  ///
  /// In en, this message translates to:
  /// **'Gamma'**
  String get gamma;

  /// No description provided for @advancedCorrections.
  ///
  /// In en, this message translates to:
  /// **'Advanced Corrections'**
  String get advancedCorrections;

  /// No description provided for @videoStabilization.
  ///
  /// In en, this message translates to:
  /// **'Video Stabilization'**
  String get videoStabilization;

  /// No description provided for @reducesCameraShake.
  ///
  /// In en, this message translates to:
  /// **'Reduces camera shake'**
  String get reducesCameraShake;

  /// No description provided for @deinterlacing.
  ///
  /// In en, this message translates to:
  /// **'Deinterlacing'**
  String get deinterlacing;

  /// No description provided for @removesInterlacedLines.
  ///
  /// In en, this message translates to:
  /// **'Removes lines from interlaced videos'**
  String get removesInterlacedLines;

  /// No description provided for @colorProfiles.
  ///
  /// In en, this message translates to:
  /// **'Color Profiles'**
  String get colorProfiles;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @vivid.
  ///
  /// In en, this message translates to:
  /// **'Vivid'**
  String get vivid;

  /// No description provided for @cinematic.
  ///
  /// In en, this message translates to:
  /// **'Cinematic'**
  String get cinematic;

  /// No description provided for @blackWhite.
  ///
  /// In en, this message translates to:
  /// **'Black & White'**
  String get blackWhite;

  /// No description provided for @sepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get sepia;

  /// No description provided for @activeEffectsPreview.
  ///
  /// In en, this message translates to:
  /// **'Active Effects Preview:'**
  String get activeEffectsPreview;

  /// No description provided for @noActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'No active filters'**
  String get noActiveFilters;

  /// No description provided for @volumeDynamics.
  ///
  /// In en, this message translates to:
  /// **'Volume and Dynamics'**
  String get volumeDynamics;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @compression.
  ///
  /// In en, this message translates to:
  /// **'Compression'**
  String get compression;

  /// No description provided for @normalization.
  ///
  /// In en, this message translates to:
  /// **'Normalization'**
  String get normalization;

  /// No description provided for @levelsVolumeAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Levels volume automatically'**
  String get levelsVolumeAutomatically;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @bass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get bass;

  /// No description provided for @treble.
  ///
  /// In en, this message translates to:
  /// **'Treble'**
  String get treble;

  /// No description provided for @equalizerPreset.
  ///
  /// In en, this message translates to:
  /// **'Equalizer Preset:'**
  String get equalizerPreset;

  /// No description provided for @bassBoost.
  ///
  /// In en, this message translates to:
  /// **'Bass Boost'**
  String get bassBoost;

  /// No description provided for @trebleBoost.
  ///
  /// In en, this message translates to:
  /// **'Treble Boost'**
  String get trebleBoost;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @audioCleaning.
  ///
  /// In en, this message translates to:
  /// **'Audio Cleaning'**
  String get audioCleaning;

  /// No description provided for @removeNoise.
  ///
  /// In en, this message translates to:
  /// **'Remove Noise'**
  String get removeNoise;

  /// No description provided for @reducesBackgroundHiss.
  ///
  /// In en, this message translates to:
  /// **'Reduces background hiss'**
  String get reducesBackgroundHiss;

  /// No description provided for @noiseThreshold.
  ///
  /// In en, this message translates to:
  /// **'Noise Threshold'**
  String get noiseThreshold;

  /// No description provided for @reverb.
  ///
  /// In en, this message translates to:
  /// **'Reverb'**
  String get reverb;

  /// No description provided for @activeAudioEffects.
  ///
  /// In en, this message translates to:
  /// **'Active Audio Effects:'**
  String get activeAudioEffects;

  /// No description provided for @noActiveAudioFilters.
  ///
  /// In en, this message translates to:
  /// **'No active audio filters'**
  String get noActiveAudioFilters;

  /// No description provided for @excellentQuality.
  ///
  /// In en, this message translates to:
  /// **'Excellent (CRF: {crf})'**
  String excellentQuality(Object crf);

  /// No description provided for @greatQuality.
  ///
  /// In en, this message translates to:
  /// **'Great (CRF: {crf})'**
  String greatQuality(Object crf);

  /// No description provided for @goodQuality.
  ///
  /// In en, this message translates to:
  /// **'Good (CRF: {crf})'**
  String goodQuality(Object crf);

  /// No description provided for @averageQuality.
  ///
  /// In en, this message translates to:
  /// **'Average (CRF: {crf})'**
  String averageQuality(Object crf);

  /// No description provided for @lowQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Low (CRF: {crf})'**
  String lowQualityLabel(Object crf);

  /// No description provided for @crfScale.
  ///
  /// In en, this message translates to:
  /// **'CRF: 0 (Best) - 51 (Worst)'**
  String get crfScale;

  /// No description provided for @bitrateScale.
  ///
  /// In en, this message translates to:
  /// **'Bitrate: 64 kbps - 320 kbps'**
  String get bitrateScale;

  /// No description provided for @audioCodec.
  ///
  /// In en, this message translates to:
  /// **'Audio Codec'**
  String get audioCodec;

  /// No description provided for @audioCodecDesc.
  ///
  /// In en, this message translates to:
  /// **'Select audio codec for the output file'**
  String get audioCodecDesc;

  /// No description provided for @aacDescription.
  ///
  /// In en, this message translates to:
  /// **'AAC - High compatibility, good quality'**
  String get aacDescription;

  /// No description provided for @mp3Description.
  ///
  /// In en, this message translates to:
  /// **'MP3 - Maximum compatibility'**
  String get mp3Description;

  /// No description provided for @flacDescription.
  ///
  /// In en, this message translates to:
  /// **'FLAC - Lossless, maximum quality'**
  String get flacDescription;

  /// No description provided for @opusDescription.
  ///
  /// In en, this message translates to:
  /// **'Opus - Excellent efficiency'**
  String get opusDescription;

  /// No description provided for @vorbisDescription.
  ///
  /// In en, this message translates to:
  /// **'Vorbis - Open source, good quality'**
  String get vorbisDescription;

  /// No description provided for @pcmDescription.
  ///
  /// In en, this message translates to:
  /// **'PCM - Uncompressed audio'**
  String get pcmDescription;

  /// No description provided for @audioCodecDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Selected audio codec: {codec}'**
  String audioCodecDefaultDescription(Object codec);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get files;

  /// No description provided for @customResolution.
  ///
  /// In en, this message translates to:
  /// **'Custom Resolution'**
  String get customResolution;

  /// No description provided for @customWidth.
  ///
  /// In en, this message translates to:
  /// **'Width (px)'**
  String get customWidth;

  /// No description provided for @customHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (px)'**
  String get customHeight;

  /// No description provided for @originalResolution.
  ///
  /// In en, this message translates to:
  /// **'Image Resolution'**
  String get originalResolution;

  /// No description provided for @previewOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original Preview'**
  String get previewOriginal;

  /// No description provided for @previewModified.
  ///
  /// In en, this message translates to:
  /// **'Modified Preview'**
  String get previewModified;

  /// No description provided for @useCustomResolution.
  ///
  /// In en, this message translates to:
  /// **'Use Custom Resolution'**
  String get useCustomResolution;

  /// No description provided for @customResolutionDesc.
  ///
  /// In en, this message translates to:
  /// **'Set specific width and height (e.g. 1920x1080)'**
  String get customResolutionDesc;

  /// No description provided for @loadingResolution.
  ///
  /// In en, this message translates to:
  /// **'Loading resolution...'**
  String get loadingResolution;

  /// No description provided for @resolutionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Resolution not available'**
  String get resolutionNotAvailable;

  /// No description provided for @selectImageForResolution.
  ///
  /// In en, this message translates to:
  /// **'Select an image to see the resolution'**
  String get selectImageForResolution;

  /// No description provided for @resolutionDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a specific resolution. If you set only width or height, the aspect ratio is maintained.'**
  String get resolutionDescription;

  /// No description provided for @previewDescription.
  ///
  /// In en, this message translates to:
  /// **'View the original image or with filters applied'**
  String get previewDescription;

  /// No description provided for @advancedUpscalingAlgorithms.
  ///
  /// In en, this message translates to:
  /// **'Double or quadruple the image resolution. Uses advanced upscaling algorithms.'**
  String get advancedUpscalingAlgorithms;

  /// No description provided for @audioCodecSection.
  ///
  /// In en, this message translates to:
  /// **'Audio Codec - {mediaType}'**
  String audioCodecSection(Object mediaType);

  /// No description provided for @ffmpegVersionCheck.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg Version Check'**
  String get ffmpegVersionCheck;

  /// No description provided for @ffmpegNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg is not installed or version is outdated'**
  String get ffmpegNotInstalled;

  /// No description provided for @ffmpegVersionRequired.
  ///
  /// In en, this message translates to:
  /// **'Required version: 8.0.1'**
  String get ffmpegVersionRequired;

  /// No description provided for @ffmpegCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String ffmpegCurrentVersion(Object version);

  /// No description provided for @ffmpegNeedsUpdate.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg needs to be updated to version 8.0.1'**
  String get ffmpegNeedsUpdate;

  /// No description provided for @installFFmpeg.
  ///
  /// In en, this message translates to:
  /// **'Install FFmpeg 8.0.1'**
  String get installFFmpeg;

  /// No description provided for @installFFmpegDesc.
  ///
  /// In en, this message translates to:
  /// **'This will install FFmpeg 8.0.1 using administrator privileges. The password will be stored securely for future use.'**
  String get installFFmpegDesc;

  /// No description provided for @enterSudoPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter administrator password'**
  String get enterSudoPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @installingFFmpeg.
  ///
  /// In en, this message translates to:
  /// **'Installing FFmpeg...'**
  String get installingFFmpeg;

  /// No description provided for @ffmpegInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg 8.0.1 installed successfully!'**
  String get ffmpegInstallSuccess;

  /// No description provided for @ffmpegInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg installation failed: {error}'**
  String ffmpegInstallFailed(Object error);

  /// No description provided for @detectedDistribution.
  ///
  /// In en, this message translates to:
  /// **'Detected distribution: {distro}'**
  String detectedDistribution(Object distro);

  /// No description provided for @addingRepository.
  ///
  /// In en, this message translates to:
  /// **'Adding repository...'**
  String get addingRepository;

  /// No description provided for @updatingPackages.
  ///
  /// In en, this message translates to:
  /// **'Updating package list...'**
  String get updatingPackages;

  /// No description provided for @installingPackage.
  ///
  /// In en, this message translates to:
  /// **'Installing FFmpeg...'**
  String get installingPackage;

  /// No description provided for @passwordStored.
  ///
  /// In en, this message translates to:
  /// **'Password stored securely for future installations'**
  String get passwordStored;

  /// No description provided for @skipInstallation.
  ///
  /// In en, this message translates to:
  /// **'Skip Installation'**
  String get skipInstallation;

  /// No description provided for @manualInstall.
  ///
  /// In en, this message translates to:
  /// **'Manual Installation'**
  String get manualInstall;

  /// No description provided for @manualInstallDesc.
  ///
  /// In en, this message translates to:
  /// **'You can install FFmpeg manually using the commands below'**
  String get manualInstallDesc;

  /// No description provided for @howToInstallFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'How to install FFmpeg'**
  String get howToInstallFfmpeg;

  /// No description provided for @onFedora.
  ///
  /// In en, this message translates to:
  /// **'On Fedora'**
  String get onFedora;

  /// No description provided for @onUbuntuDebian.
  ///
  /// In en, this message translates to:
  /// **'On Ubuntu/Debian'**
  String get onUbuntuDebian;

  /// No description provided for @onWindows.
  ///
  /// In en, this message translates to:
  /// **'On Windows'**
  String get onWindows;

  /// No description provided for @onMacOS.
  ///
  /// In en, this message translates to:
  /// **'On macOS'**
  String get onMacOS;

  /// No description provided for @openTerminalAndRun.
  ///
  /// In en, this message translates to:
  /// **'Open terminal and run'**
  String get openTerminalAndRun;

  /// No description provided for @downloadFromFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Download from FFmpeg website'**
  String get downloadFromFfmpeg;

  /// No description provided for @useHomebrew.
  ///
  /// In en, this message translates to:
  /// **'Use Homebrew'**
  String get useHomebrew;

  /// No description provided for @afterInstallingRestart.
  ///
  /// In en, this message translates to:
  /// **'After installing, restart the application'**
  String get afterInstallingRestart;

  /// No description provided for @clickToOpenGuide.
  ///
  /// In en, this message translates to:
  /// **'Click to open installation guide'**
  String get clickToOpenGuide;

  /// No description provided for @audioPreview.
  ///
  /// In en, this message translates to:
  /// **'Audio Preview'**
  String get audioPreview;

  /// No description provided for @audioPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Listen to the original audio or with filters applied'**
  String get audioPreviewDescription;

  /// No description provided for @openWithSystemPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open with system player'**
  String get openWithSystemPlayer;

  /// No description provided for @audioFileReady.
  ///
  /// In en, this message translates to:
  /// **'Audio file ready for playback'**
  String get audioFileReady;

  /// No description provided for @modifiedAudioGenerated.
  ///
  /// In en, this message translates to:
  /// **'Modified audio generated (first 10 seconds)'**
  String get modifiedAudioGenerated;

  /// No description provided for @fileWillOpenWithDefaultPlayer.
  ///
  /// In en, this message translates to:
  /// **'The file will open with the system\'s default audio player'**
  String get fileWillOpenWithDefaultPlayer;

  /// No description provided for @videoQualityMode.
  ///
  /// In en, this message translates to:
  /// **'Video Quality Mode'**
  String get videoQualityMode;

  /// No description provided for @constantQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'CRF (Constant Quality)'**
  String get constantQualityLabel;

  /// No description provided for @constantBitrateLabel.
  ///
  /// In en, this message translates to:
  /// **'Bitrate (File Size)'**
  String get constantBitrateLabel;

  /// No description provided for @videoBitrateLabel.
  ///
  /// In en, this message translates to:
  /// **'Video Bitrate'**
  String get videoBitrateLabel;

  /// No description provided for @crfQualityRange.
  ///
  /// In en, this message translates to:
  /// **'CRF: 0 (Best Quality) - 51 (Worst Quality)'**
  String get crfQualityRange;

  /// No description provided for @bitrateQualityRange.
  ///
  /// In en, this message translates to:
  /// **'Bitrate: 500 kbps (Low Quality) - 20,000 kbps (Very High Quality)'**
  String get bitrateQualityRange;

  /// No description provided for @qualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality:'**
  String get qualityLabel;

  /// No description provided for @videoCodecDescriptionLibx264.
  ///
  /// In en, this message translates to:
  /// **'Excellent compatibility, good compression'**
  String get videoCodecDescriptionLibx264;

  /// No description provided for @videoCodecDescriptionLibx265.
  ///
  /// In en, this message translates to:
  /// **'Better compression, limited compatibility'**
  String get videoCodecDescriptionLibx265;

  /// No description provided for @videoCodecDescriptionLibvpx.
  ///
  /// In en, this message translates to:
  /// **'Open source codec for Web'**
  String get videoCodecDescriptionLibvpx;

  /// No description provided for @videoCodecDescriptionLibvpxVp9.
  ///
  /// In en, this message translates to:
  /// **'Modern codec for high quality'**
  String get videoCodecDescriptionLibvpxVp9;

  /// No description provided for @videoCodecDescriptionMpeg4.
  ///
  /// In en, this message translates to:
  /// **'Universal compatibility'**
  String get videoCodecDescriptionMpeg4;

  /// No description provided for @videoCodecDescriptionLibaomAv1.
  ///
  /// In en, this message translates to:
  /// **'Next-gen codec, advanced compression'**
  String get videoCodecDescriptionLibaomAv1;

  /// No description provided for @videoCodecDescriptionDefault.
  ///
  /// In en, this message translates to:
  /// **'Video codec'**
  String get videoCodecDescriptionDefault;

  /// No description provided for @audioQualityHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest Quality (Lossless-like)'**
  String get audioQualityHighest;

  /// No description provided for @audioQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High Quality (Transparency)'**
  String get audioQualityHigh;

  /// No description provided for @audioQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Quality (Good balance)'**
  String get audioQualityMedium;

  /// No description provided for @audioQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low Quality (Compatibility)'**
  String get audioQualityLow;

  /// No description provided for @selectVideoForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Select a video for automatic analysis'**
  String get selectVideoForAnalysis;

  /// No description provided for @analyzeVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Analyze Video Quality'**
  String get analyzeVideoQuality;

  /// No description provided for @analyzingVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Analyzing video quality...'**
  String get analyzingVideoQuality;

  /// No description provided for @videoAnalyzedNoIssues.
  ///
  /// In en, this message translates to:
  /// **'Video analyzed - No critical issues'**
  String get videoAnalyzedNoIssues;

  /// No description provided for @problemsDetectedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'{problems} problems detected - {recommendations} recommendations'**
  String problemsDetectedRecommendations(Object problems, Object recommendations);

  /// No description provided for @intelligentVideoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Intelligent Video Analysis'**
  String get intelligentVideoAnalysis;

  /// No description provided for @automaticOptimizations.
  ///
  /// In en, this message translates to:
  /// **'Automatic Optimizations'**
  String get automaticOptimizations;

  /// No description provided for @autoOptimization.
  ///
  /// In en, this message translates to:
  /// **'Auto Optimization'**
  String get autoOptimization;

  /// No description provided for @autoOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply best settings based on analysis'**
  String get autoOptimizationDesc;

  /// No description provided for @lowQuality.
  ///
  /// In en, this message translates to:
  /// **'Low Quality ⭐'**
  String get lowQuality;

  /// No description provided for @lowQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'MAXIMUM OPTIMIZATION for low quality videos with heavy noise'**
  String get lowQualityDesc;

  /// No description provided for @ultraQuality.
  ///
  /// In en, this message translates to:
  /// **'Ultra Quality'**
  String get ultraQuality;

  /// No description provided for @ultraQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional enhancement with all advanced filters'**
  String get ultraQualityDesc;

  /// No description provided for @lowLight.
  ///
  /// In en, this message translates to:
  /// **'Low Light'**
  String get lowLight;

  /// No description provided for @lowLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve videos in low light conditions'**
  String get lowLightDesc;

  /// No description provided for @detailRecovery.
  ///
  /// In en, this message translates to:
  /// **'Restore Details'**
  String get detailRecovery;

  /// No description provided for @detailRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Recover lost details and textures'**
  String get detailRecoveryDesc;

  /// No description provided for @compressionFix.
  ///
  /// In en, this message translates to:
  /// **'Fix Compression'**
  String get compressionFix;

  /// No description provided for @compressionFixDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove artifacts from heavy compression'**
  String get compressionFixDesc;

  /// No description provided for @filmRestoration.
  ///
  /// In en, this message translates to:
  /// **'Film Restoration'**
  String get filmRestoration;

  /// No description provided for @filmRestorationDesc.
  ///
  /// In en, this message translates to:
  /// **'Optimized for old videos and films'**
  String get filmRestorationDesc;

  /// No description provided for @fundamentalFilters.
  ///
  /// In en, this message translates to:
  /// **'Fundamental Filters'**
  String get fundamentalFilters;

  /// No description provided for @qualityAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Quality and Details'**
  String get qualityAndDetails;

  /// No description provided for @noiseReductionLabel.
  ///
  /// In en, this message translates to:
  /// **'Noise Reduction'**
  String get noiseReductionLabel;

  /// No description provided for @colorAndLight.
  ///
  /// In en, this message translates to:
  /// **'Color and Light'**
  String get colorAndLight;

  /// No description provided for @redBalance.
  ///
  /// In en, this message translates to:
  /// **'Red Balance'**
  String get redBalance;

  /// No description provided for @greenBalance.
  ///
  /// In en, this message translates to:
  /// **'Green Balance'**
  String get greenBalance;

  /// No description provided for @blueBalance.
  ///
  /// In en, this message translates to:
  /// **'Blue Balance'**
  String get blueBalance;

  /// No description provided for @deinterlacingLabel.
  ///
  /// In en, this message translates to:
  /// **'Deinterlacing'**
  String get deinterlacingLabel;

  /// No description provided for @deinterlacingDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove interlaced lines from older videos'**
  String get deinterlacingDesc;

  /// No description provided for @stabilizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get stabilizationLabel;

  /// No description provided for @stabilizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce camera shake'**
  String get stabilizationDesc;

  /// No description provided for @detailEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Detail Enhancement'**
  String get detailEnhancement;

  /// No description provided for @detailEnhancementDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve detail definition'**
  String get detailEnhancementDesc;

  /// No description provided for @gpuAccelerationLabel.
  ///
  /// In en, this message translates to:
  /// **'GPU Acceleration'**
  String get gpuAccelerationLabel;

  /// No description provided for @useGpuForConversion.
  ///
  /// In en, this message translates to:
  /// **'Use GPU for conversion'**
  String get useGpuForConversion;

  /// No description provided for @useGpuForConversionDesc.
  ///
  /// In en, this message translates to:
  /// **'Move video encoding to graphics card (if available)'**
  String get useGpuForConversionDesc;

  /// No description provided for @gpuPreset.
  ///
  /// In en, this message translates to:
  /// **'GPU Preset (speed vs quality)'**
  String get gpuPreset;

  /// No description provided for @gpuPresetFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get gpuPresetFast;

  /// No description provided for @gpuPresetFastDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum speed, slightly lower quality'**
  String get gpuPresetFastDesc;

  /// No description provided for @gpuPresetMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gpuPresetMedium;

  /// No description provided for @gpuPresetMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced between speed and quality (recommended)'**
  String get gpuPresetMediumDesc;

  /// No description provided for @gpuPresetHighQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality'**
  String get gpuPresetHighQuality;

  /// No description provided for @gpuPresetHighQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Best possible quality, slower conversion'**
  String get gpuPresetHighQualityDesc;

  /// No description provided for @drunetDenoisingTitle.
  ///
  /// In en, this message translates to:
  /// **'DRUNet (AI denoising)'**
  String get drunetDenoisingTitle;

  /// No description provided for @drunetDenoisingDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep learning denoising when drunet_model.pth is in models/drunet/. On by default.'**
  String get drunetDenoisingDesc;

  /// No description provided for @sceneDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Scene detection (PySceneDetect)'**
  String get sceneDetectionTitle;

  /// No description provided for @sceneDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Scene analysis for smarter encoding hints. On by default.'**
  String get sceneDetectionDesc;

  /// No description provided for @useSceneOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Scene-based optimization'**
  String get useSceneOptimizationTitle;

  /// No description provided for @useSceneOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply bitrate/quality recommendations from scene analysis.'**
  String get useSceneOptimizationDesc;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @vividLabel.
  ///
  /// In en, this message translates to:
  /// **'Vivid'**
  String get vividLabel;

  /// No description provided for @cinematicLabel.
  ///
  /// In en, this message translates to:
  /// **'Cinematic'**
  String get cinematicLabel;

  /// No description provided for @blackWhiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Black & White'**
  String get blackWhiteLabel;

  /// No description provided for @sepiaLabel.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get sepiaLabel;

  /// No description provided for @imageFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Filters'**
  String get imageFiltersTitle;

  /// No description provided for @qualityEnhancementLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality Enhancement'**
  String get qualityEnhancementLabel;

  /// No description provided for @imageUpscaling.
  ///
  /// In en, this message translates to:
  /// **'Image Upscaling'**
  String get imageUpscaling;

  /// No description provided for @enableImageUpscaling.
  ///
  /// In en, this message translates to:
  /// **'Enable Upscaling'**
  String get enableImageUpscaling;

  /// No description provided for @enableImageUpscalingDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase image resolution'**
  String get enableImageUpscalingDesc;

  /// No description provided for @upscalingFactor.
  ///
  /// In en, this message translates to:
  /// **'Upscaling Factor'**
  String get upscalingFactor;

  /// No description provided for @upscalingDisabledWithCustom.
  ///
  /// In en, this message translates to:
  /// **'Upscaling is disabled when using custom resolution.'**
  String get upscalingDisabledWithCustom;

  /// No description provided for @imageColorProfiles.
  ///
  /// In en, this message translates to:
  /// **'Color Profiles'**
  String get imageColorProfiles;

  /// No description provided for @userGuideMenu.
  ///
  /// In en, this message translates to:
  /// **'User guide'**
  String get userGuideMenu;

  /// No description provided for @userGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'User guide'**
  String get userGuideTitle;

  /// No description provided for @userGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'This guide summarizes how FE Media Converter works: pick a media type, add files, choose format and quality, optionally tune filters, then use the queue to run jobs. Settings persist between sessions.'**
  String get userGuideIntro;

  /// No description provided for @guideSectionQuickStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get guideSectionQuickStartTitle;

  /// No description provided for @guideSectionQuickStartBody.
  ///
  /// In en, this message translates to:
  /// **'1) Choose Video, Audio, or Image on the left.\n2) Tap Browse or drop files onto the window.\n3) Pick output format and codecs.\n4) Adjust quality (CRF or bitrate) if needed.\n5) Tap Add to queue, open the Queue tab, and start conversion.\n6) Use Settings for output folder, theme, language, threads, and GPU options.'**
  String get guideSectionQuickStartBody;

  /// No description provided for @guideSectionFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Formats and codecs'**
  String get guideSectionFormatsTitle;

  /// No description provided for @guideSectionFormatsBody.
  ///
  /// In en, this message translates to:
  /// **'Each media mode has its own presets. Video supports common codecs (for example H.264, HEVC, VP9, AV1). Audio includes AAC, MP3, Opus, FLAC, and more. Images support PNG, JPEG, WebP, and others. You can extract audio only from video files when that option is enabled in Settings.'**
  String get guideSectionFormatsBody;

  /// No description provided for @guideSectionVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video: filters and AI'**
  String get guideSectionVideoTitle;

  /// No description provided for @guideSectionVideoBody.
  ///
  /// In en, this message translates to:
  /// **'Advanced video filters cover noise reduction, sharpness, color (brightness, contrast, saturation, gamma, RGB balance), stabilization, deinterlacing, and creative color profiles. Intelligent analysis can suggest optimizations for low light, heavy compression, or old film look.\nOptional DRUNet denoising uses a downloaded neural model. Scene detection (PySceneDetect) can analyze cuts to tune encoding; enable scene-based optimization to apply its hints.\nGPU acceleration (when supported) moves encoding to the graphics card—pick a GPU preset that balances speed and quality.'**
  String get guideSectionVideoBody;

  /// No description provided for @guideSectionAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio filters'**
  String get guideSectionAudioTitle;

  /// No description provided for @guideSectionAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust volume, compression, and normalization. Use the equalizer with bass/treble controls and presets (for example bass boost or voice). Cleaning tools reduce background hiss; reverb adds space. Preview helps compare original and processed audio where available.'**
  String get guideSectionAudioBody;

  /// No description provided for @guideSectionImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Images: resolution and upscaling'**
  String get guideSectionImageTitle;

  /// No description provided for @guideSectionImageBody.
  ///
  /// In en, this message translates to:
  /// **'Apply quality and color adjustments similar to video. Set a custom width/height or keep aspect ratio by filling only one dimension. Super-resolution / upscaling increases resolution; it is disabled when a fixed custom resolution conflicts with scaling. Color profiles give quick stylistic looks.'**
  String get guideSectionImageBody;

  /// No description provided for @guideSectionQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue and concurrency'**
  String get guideSectionQueueTitle;

  /// No description provided for @guideSectionQueueBody.
  ///
  /// In en, this message translates to:
  /// **'The queue lists pending, active, paused, completed, and failed jobs. You can pause, resume, stop, or remove tasks. Concurrent conversions in Settings controls how many files run at once—raise it on powerful CPUs, lower it to reduce load.'**
  String get guideSectionQueueBody;

  /// No description provided for @guideSectionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get guideSectionSettingsTitle;

  /// No description provided for @guideSectionSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Output folder: leave empty to write next to each source file. CPU threads limits FFmpeg thread usage (0 = auto). Theme and UI language apply immediately after confirmation. Default formats and codecs are remembered per media type.'**
  String get guideSectionSettingsBody;

  /// No description provided for @guideSectionModelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Models and Python tools'**
  String get guideSectionModelsTitle;

  /// No description provided for @guideSectionModelsBody.
  ///
  /// In en, this message translates to:
  /// **'DRUNet and scene scripts live under the app’s Python environment. On first launch you may be prompted to download the DRUNet weights (~125 MB). You can change the models directory in Settings; the app also uses a default folder under your home for caches.'**
  String get guideSectionModelsBody;

  /// No description provided for @guideSectionDepsTitle.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg and startup check'**
  String get guideSectionDepsTitle;

  /// No description provided for @guideSectionDepsBody.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg must be installed and reasonably up to date. If the dependency screen appears, follow the guided install or manual instructions, then retry. The app also benefits from Python 3 and pip/venv for optional features.'**
  String get guideSectionDepsBody;

  /// No description provided for @pythonSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional Python components'**
  String get pythonSetupTitle;

  /// No description provided for @pythonSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'DRUNet AI denoising and scene detection use a local Python virtual environment with PyTorch and other libraries. This download can be large and is prepared on first launch (not during package install).\n\nInstall now, or skip and use the rest of the app without these features.'**
  String get pythonSetupIntro;

  /// No description provided for @pythonSetupInstall.
  ///
  /// In en, this message translates to:
  /// **'Download and install'**
  String get pythonSetupInstall;

  /// No description provided for @pythonSetupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get pythonSetupSkip;

  /// No description provided for @pythonSetupRunning.
  ///
  /// In en, this message translates to:
  /// **'Installing packages (this may take several minutes)…'**
  String get pythonSetupRunning;

  /// No description provided for @pythonSetupPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pythonSetupPleaseWait;

  /// No description provided for @pythonSetupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Python environment is ready. You can use DRUNet and scene tools.'**
  String get pythonSetupSuccess;

  /// No description provided for @pythonSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup failed (exit code: {code}). You can retry or run scripts/python/setup_python_env.sh manually.'**
  String pythonSetupFailed(int code);

  /// No description provided for @pythonSetupRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pythonSetupRetry;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
