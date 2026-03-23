import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_converter_pro/providers/conversion_provider.dart';
import 'package:video_converter_pro/models/conversion_task.dart';
import 'package:video_converter_pro/models/conversion_status.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';

class ConversionQueue extends StatelessWidget {
  const ConversionQueue({super.key});

  @override
  Widget build(BuildContext context) {
    final conversionProvider = context.watch<ConversionProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildQueueHeader(context, conversionProvider, l10n),
        const SizedBox(height: 16),
        Expanded(
          child: conversionProvider.conversionQueue.isEmpty
              ? _buildEmptyState(context, l10n)
              : _buildQueueList(context, conversionProvider, l10n),
        ),
      ],
    );
  }

  Widget _buildQueueHeader(BuildContext context, ConversionProvider provider, AppLocalizations l10n) {
    final completedCount = provider.completedCount;
    final totalCount = provider.queueLength;
    final isConverting = provider.isConverting;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icona e titolo
            const Icon(Icons.playlist_play, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.conversionQueue,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.completedCount(completedCount, totalCount),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (isConverting) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.converting,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Pulsanti di azione
            if (provider.queueLength > 0) ...[
              if (provider.completedCount > 0)
                Tooltip(
                  message: l10n.removeCompletedFiles,
                  child: TextButton.icon(
                    onPressed: provider.clearCompleted,
                    icon: const Icon(Icons.cleaning_services, size: 18),
                    label: Text(l10n.clear),
                  ),
                ),
              const SizedBox(width: 8),
              Tooltip(
                message: l10n.emptyEntireQueue,
                child: IconButton(
                  icon: Icon(
                    Icons.clear_all,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: provider.clearQueue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueList(BuildContext context, ConversionProvider provider, AppLocalizations l10n) {

    return Card(
      child: ListView.builder(
        itemCount: provider.conversionQueue.length,
        itemBuilder: (context, index) {
          final task = provider.conversionQueue[index];
          return _buildQueueItem(context, task, provider, index, l10n);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFilesInQueue,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFilesFromConversion,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueItem(BuildContext context, ConversionTask task, ConversionProvider provider, int index, AppLocalizations l10n) {
    return Card(
      key: Key('${task.id}-$index'),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: _getTaskColor(context, task.status),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: _buildTaskLeading(task, l10n),
          title: _buildTaskTitle(task, l10n),
          subtitle: _buildTaskSubtitle(context, task, l10n),
          trailing: _buildTaskTrailing(context, task, provider, l10n),
        ),
      ),
    );
  }

  Widget _buildTaskLeading(ConversionTask task, AppLocalizations l10n) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Icona principale
        _getStatusIcon(task.status, l10n),
        
        // Indicatore di progresso per i task in elaborazione
        if (task.status == ConversionStatus.processing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${(task.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskTitle(ConversionTask task, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.fileName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              task.mediaTypeIcon,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              task.format.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (task.status == ConversionStatus.completed) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 12,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.outputFileName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTaskSubtitle(BuildContext context, ConversionTask task, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra di progresso per i task in elaborazione
        if (task.status == ConversionStatus.processing || task.status == ConversionStatus.paused) ...[
          LinearProgressIndicator(
            value: task.progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: _getProgressColor(context, task.progress, task.status),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(task.progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                task.timeRemaining,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
        
        // Messaggio di errore per i task falliti
        if (task.status == ConversionStatus.failed && task.error != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${l10n.error}: ${task.error!}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        
        // Informazioni aggiuntive per tutti i task
        const SizedBox(height: 2),
        Text(
          _getStatusDescription(task, l10n),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTrailing(BuildContext context, ConversionTask task, ConversionProvider provider, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsante per aprire la cartella di output (solo per task completati)
        if (task.status == ConversionStatus.completed)
          Tooltip(
            message: 'Apri cartella file',
            child: IconButton(
                  icon: Icon(
                Icons.folder_open,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () => _openOutputFolder(context, task),
            ),
          ),
        
        // Icona di stato
        if (task.status == ConversionStatus.completed)
          Tooltip(
            message: l10n.conversionCompleted,
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        
        if (task.status == ConversionStatus.failed)
          Tooltip(
            message: l10n.conversionFailed,
            child: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
        
        if (task.status == ConversionStatus.paused)
          Tooltip(
            message: l10n.conversionPausedStatus,
            child: Icon(
              Icons.pause_circle,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
          ),
        
        const SizedBox(width: 8),
        
        // Pulsanti di controllo per task attivi
        if (task.canPause)
          Tooltip(
            message: l10n.pauseConversion,
            child: IconButton(
              icon: Icon(
                Icons.pause,
                color: Colors.orange.shade600,
                size: 20,
              ),
              onPressed: () => _showPauseConfirmation(context, task, provider, l10n),
            ),
          ),
        
        if (task.canResume)
          Tooltip(
            message: l10n.resume,
            child: IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: Colors.green.shade600,
                size: 20,
              ),
              onPressed: () => provider.resumeTask(task.id),
            ),
          ),
        
        if (task.canStop)
          Tooltip(
            message: l10n.stopConversion,
            child: IconButton(
              icon: Icon(
                Icons.stop,
                color: Colors.red.shade600,
                size: 20,
              ),
              onPressed: () => _showStopConfirmation(context, task, provider, l10n),
            ),
          ),
        
        // Pulsante di rimozione (non disponibile per i task in elaborazione)
        if (task.status != ConversionStatus.processing && task.status != ConversionStatus.paused)
          Tooltip(
            message: l10n.removeFromQueue,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
                size: 20,
              ),
              onPressed: () => _showDeleteConfirmation(context, task, provider, l10n),
            ),
          ),
      ],
    );
  }

  void _openOutputFolder(BuildContext context, ConversionTask task) async {
    try {
      final outputFile = File(task.outputPath);
      if (await outputFile.exists()) {
        final outputDir = outputFile.parent;
        // Apri la cartella usando xdg-open su Linux
        await Process.run('xdg-open', [outputDir.path]);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File di output non trovato')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aprire la cartella: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, ConversionTask task, ConversionProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFromQueueQuestion),
        content: Text(l10n.areYouSureRemove(task.fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.removeFromQueue(task.id);
              final navigatorContext = context;
              Navigator.of(navigatorContext).pop();
              
              if (navigatorContext.mounted) {
                ScaffoldMessenger.of(navigatorContext).showSnackBar(
                  SnackBar(
                    content: Text(l10n.fileRemoved(task.fileName)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  void _showPauseConfirmation(BuildContext context, ConversionTask task, ConversionProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pauseConversionQuestion),
        content: Text(l10n.areYouSurePause(task.fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.pauseTask(task.id);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.filePaused(task.fileName)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: Text(l10n.pause),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation(BuildContext context, ConversionTask task, ConversionProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.stopConversionQuestion),
        content: Text(l10n.areYouSureStop(task.fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.stopTask(task.id);
              Navigator.of(context).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.fileStopped(task.fileName)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.stop),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(BuildContext context, ConversionStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case ConversionStatus.pending:
        return isDark ? Colors.grey[800]! : Colors.grey.shade100;
      case ConversionStatus.processing:
        return isDark ? Colors.blue[900]! : Colors.blue.shade50;
      case ConversionStatus.paused:
        return isDark ? Colors.orange[900]! : Colors.orange.shade50;
      case ConversionStatus.completed:
        return isDark ? Colors.green[900]! : Colors.green.shade50;
      case ConversionStatus.failed:
        return isDark ? Colors.red[900]! : Colors.red.shade50;
    }
  }

  Widget _getStatusIcon(ConversionStatus status, AppLocalizations l10n) {
    const iconSize = 28.0;
    
    switch (status) {
      case ConversionStatus.pending:
        return Icon(
          Icons.access_time,
          color: Colors.orange.shade600,
          size: iconSize,
        );
      case ConversionStatus.processing:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.sync,
              color: Colors.blue.shade600,
              size: iconSize,
            ),
            // Animazione di rotazione
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                value: null, // Indicatore indeterminato
                strokeWidth: 2,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        );
      case ConversionStatus.paused:
        return Icon(
          Icons.pause_circle,
          color: Colors.orange.shade600,
          size: iconSize,
        );
      case ConversionStatus.completed:
        return Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: iconSize,
        );
      case ConversionStatus.failed:
        return Icon(
          Icons.error,
          color: Colors.red.shade600,
          size: iconSize,
        );
    }
  }

  Color _getProgressColor(BuildContext context, double progress, ConversionStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (status == ConversionStatus.paused) {
      return isDark ? Colors.orange[400]! : Colors.orange;
    }
    if (progress < 0.3) {
      return isDark ? Colors.red[400]! : Colors.red;
    }
    if (progress < 0.7) {
      return isDark ? Colors.orange[400]! : Colors.orange;
    }
    return isDark ? Colors.green[400]! : Colors.green;
  }

  String _getStatusDescription(ConversionTask task, AppLocalizations l10n) {
    switch (task.status) {
      case ConversionStatus.pending:
        return l10n.waitingForConversion;
      case ConversionStatus.processing:
        return l10n.conversionInProgress;
      case ConversionStatus.paused:
        return l10n.pausedAtTime(_formatTime(task.createdAt, l10n));
      case ConversionStatus.completed:
        return l10n.completedAtTime(_formatTime(task.createdAt, l10n));
      case ConversionStatus.failed:
        return l10n.failedAtTime(_formatTime(task.createdAt, l10n));
    }
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }
}