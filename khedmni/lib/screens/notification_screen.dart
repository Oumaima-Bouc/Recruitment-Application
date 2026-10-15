import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/notification_cubit.dart';
import '../logic/cubits/notification_state.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widgets;
import 'package:khedmni/l10n/app_localizations.dart';
import '../core/constants/colors.dart'; // Add import


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetchNotifications();
  }

  String _formatTime(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'mark_read') {
                context.read<NotificationCubit>().markAllAsRead();
              } else if (value == 'delete_all') {
                context.read<NotificationCubit>().deleteAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.markAllAsRead),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.deleteAll),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return LoadingWidget(
              message: AppLocalizations.of(context)!.loadingNotifications,
            );
          }

          if (state is NotificationError) {
            return error_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<NotificationCubit>().fetchNotifications(),
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noNotifications,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final bool isRead = notif.isRead;

                return GestureDetector(
                  onTap: () {
                    context.read<NotificationCubit>().markAsRead(notif.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: isRead
                          ? (isDark ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : const Color(0xFFF9FBFD))
                          : (isDark ? colorScheme.surfaceContainerHigh : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.darkBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          if (!isRead)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead 
                              ? (isDark ? Colors.grey.shade400 : Colors.grey.shade800)
                              : (isDark ? Colors.white : AppColors.darkBlue),
                        ),
                      ),
                      subtitle: Text(
                        notif.message,
                        style: TextStyle(
                          color: isRead 
                              ? (isDark ? Colors.grey.shade500 : Colors.grey.shade700)
                              : (isDark ? Colors.grey.shade300 : Colors.black87),
                        ),
                      ),
                      trailing: Text(
                        _formatTime(context, notif.timestamp),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
