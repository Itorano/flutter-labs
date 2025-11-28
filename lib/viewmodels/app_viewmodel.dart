import 'package:flutter/material.dart';
import 'package:aethel/services/download_queue_service.dart';
import 'package:aethel/theme/app_theme.dart';

class AppViewModel extends ChangeNotifier {
  void refreshTheme() {
    notifyListeners();
  }

  void setupNotifications(
      BuildContext context,
      DownloadQueueManager queueManager,
      ) {
    if (queueManager.onShowNotification == null) {
      queueManager.onShowNotification = (message) {
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(
                bottom: 16,
                left: 16,
                right: 16,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      };

      queueManager.onDownloadCompleted = (trackName) {
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('$trackName добавлен в библиотеку'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(
                bottom: 16,
                left: 16,
                right: 16,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      };
    }
  }
}
