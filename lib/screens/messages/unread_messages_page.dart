import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/chat_thread.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player_details/messages/messages_widgets.dart';
import '../../widgets/user_avatar.dart';
import '../player_details/message_page.dart';
import 'group_messages_page.dart';

/// Unread Messages tab. Streams the same thread collection as the main
/// Messages tab and filters to threads where the current user hasn't
/// seen the latest message yet (see [ChatThread.isUnreadFor]).
///
/// Intentionally simple — no per-thread unread counts (we don't track
/// per-message read state), no group threads, no read receipts UI.
class UnreadMessagesPage extends StatefulWidget {
  const UnreadMessagesPage({super.key});

  @override
  State<UnreadMessagesPage> createState() => _UnreadMessagesPageState();
}

class _UnreadMessagesPageState extends State<UnreadMessagesPage> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  // Lookup cache for the other participant. Identical pattern to the
  // main Messages tab so resolved users survive snapshot churn.
  final Map<String, AppUser?> _userCache = {};

  Future<AppUser?> _resolveOther(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid];
    final user = await _userService.getUser(uid);
    _userCache[uid] = user;
    return user;
  }

  void _openThread(AppUser other) {
    Navigator.push(
      context,
      _fadeRoute<void>(MessagePage(otherUser: other)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const MessagesHeader(
              title: 'Unread Messages',
              showBackButton: true,
            ),
            Expanded(
              child: me == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Sign in to view your unread messages.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : StreamBuilder<List<ChatThread>>(
                      stream: _chatService.streamThreadsForUser(me.uid),
                      builder: (context, snapshot) {
                        final waitingFirst =
                            snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData;
                        final allThreads =
                            snapshot.data ?? const <ChatThread>[];
                        // Filter to threads the current user hasn't seen
                        // the latest message of. `isUnreadFor` already
                        // excludes threads whose latest message was sent
                        // by the current user.
                        final unread = allThreads
                            .where((t) => t.isUnreadFor(me.uid))
                            .toList();

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pageHorizontal,
                            AppSpacing.xxl,
                          ),
                          children: [
                            const MessageSearchBar(),
                            const SizedBox(height: AppSpacing.md),
                            MessageFilterTabs(
                              selectedFilter: 'Unread',
                              onAllTap: () => Navigator.maybePop(context),
                              onUnreadTap: () {},
                              onGroupsTap: () {
                                Navigator.of(context).pushReplacement(
                                  _fadeRoute<void>(
                                    const GroupMessagesPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (waitingFirst)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.xxl,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (unread.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xxl,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.mark_email_read_outlined,
                                        size: 56,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.md),
                                      Text(
                                        'No unread messages yet',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.xs),
                                      Text(
                                        "When you receive new messages, "
                                        "they'll show up here.",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              Text(
                                'Unread conversations',
                                style: AppTextStyles.sectionTitle
                                    .copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              for (final thread in unread)
                                _UnreadThreadTile(
                                  key: ValueKey(thread.id),
                                  thread: thread,
                                  myUid: me.uid,
                                  resolveOther: _resolveOther,
                                  onTap: _openThread,
                                ),
                            ],
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
  );
}

/// Per-row widget for the unread list. Mirrors the visual treatment of
/// the unread variant in the main Messages tab (bolded name + last
/// message, primary-tinted border, green dot) so the two views feel
/// like the same conversation, just filtered.
class _UnreadThreadTile extends StatefulWidget {
  final ChatThread thread;
  final String myUid;
  final Future<AppUser?> Function(String uid) resolveOther;
  final void Function(AppUser other) onTap;

  const _UnreadThreadTile({
    super.key,
    required this.thread,
    required this.myUid,
    required this.resolveOther,
    required this.onTap,
  });

  @override
  State<_UnreadThreadTile> createState() => _UnreadThreadTileState();
}

class _UnreadThreadTileState extends State<_UnreadThreadTile> {
  AppUser? _other;
  bool _loading = true;
  String? _resolvedUid;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _UnreadThreadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final otherUid = widget.thread.otherParticipant(widget.myUid);
    if (otherUid != _resolvedUid) _resolve();
  }

  Future<void> _resolve() async {
    final otherUid = widget.thread.otherParticipant(widget.myUid);
    _resolvedUid = otherUid;
    if (otherUid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final user = await widget.resolveOther(otherUid);
    if (!mounted) return;
    setState(() {
      _other = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _other == null ? null : () => widget.onTap(_other!),
          borderRadius: borderRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: borderRadius,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_loading)
                  const SizedBox(
                    width: 54,
                    height: 54,
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  UserAvatar(
                    size: 54,
                    initials: _other?.initials ?? '?',
                    photoUrl: _other?.photoUrl,
                    avatarId: _other?.avatarId,
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _other?.displayName ??
                                  (_loading ? 'Loading…' : 'Unknown user'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _formatThreadTime(widget.thread.lastMessageAt),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.thread.lastMessage?.isNotEmpty == true
                                  ? widget.thread.lastMessage!
                                  : 'New conversation',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.brightGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact thread-time label: clock time today, "Yesterday", short
/// weekday this week, MM/DD otherwise. Same shape as the helper in
/// `messages_page.dart` — duplicated rather than refactored into a
/// shared utility to avoid touching the main Messages tab in this fix.
String _formatThreadTime(DateTime? t) {
  if (t == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(t.year, t.month, t.day);
  final diff = today.difference(that).inDays;

  if (diff == 0) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final hour12 = ((h + 11) % 12) + 1;
    final period = h < 12 ? 'AM' : 'PM';
    return '$hour12:$m $period';
  }
  if (diff == 1) return 'Yesterday';
  if (diff < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[t.weekday - 1];
  }
  final mm = t.month.toString().padLeft(2, '0');
  final dd = t.day.toString().padLeft(2, '0');
  return '$mm/$dd';
}
