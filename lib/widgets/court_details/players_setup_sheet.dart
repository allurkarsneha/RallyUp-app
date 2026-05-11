import 'package:flutter/material.dart';
import 'package:rallyup/screens/confirm_booking_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'number_picker_sheet.dart';

class PlayersSetupSheet extends StatefulWidget {
  final String courtName;
  final String sport;
  final String sportEmoji;
  final String imagePath;
  final String dateText;
  final String timeText;
  final String priceText;
  final String matchType;
  final int initialPlayersRequired;
  final int initialPlayersConfirmed;

  const PlayersSetupSheet({
    super.key,
    required this.courtName,
    required this.sport,
    required this.sportEmoji,
    required this.imagePath,
    required this.dateText,
    required this.timeText,
    required this.priceText,
    required this.matchType,
    required this.initialPlayersRequired,
    required this.initialPlayersConfirmed,
  });

  @override
  State<PlayersSetupSheet> createState() => _PlayersSetupSheetState();
}

class _PlayersSetupSheetState extends State<PlayersSetupSheet> {
  late int _playersRequired;
  late int _playersConfirmed;

  @override
  void initState() {
    super.initState();
    _playersRequired = widget.initialPlayersRequired;
    _playersConfirmed = widget.initialPlayersConfirmed;
  }

  int get _playersStillRequired {
    final value = _playersRequired - _playersConfirmed;
    return value < 0 ? 0 : value;
  }

  Future<void> _pickRequiredPlayers() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NumberPickerSheet(
          title: 'No. of players required',
          initialValue: _playersRequired,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _playersRequired = picked;
        if (_playersConfirmed > _playersRequired) {
          _playersConfirmed = _playersRequired;
        }
      });
    }
  }

  Future<void> _pickConfirmedPlayers() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NumberPickerSheet(
          title: 'Players already confirmed',
          initialValue: _playersConfirmed,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _playersConfirmed = picked > _playersRequired ? _playersRequired : picked;
      });
    }
  }

  void _continue() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ConfirmBookingPage(
          courtName: widget.courtName,
          sport: widget.sport,
          sportEmoji: widget.sportEmoji,
          imagePath: widget.imagePath,
          dateText: widget.dateText,
          timeText: widget.timeText,
          priceText: widget.priceText,
          matchType: widget.matchType,
          totalPlayers: _playersRequired,
          confirmedPlayers: _playersConfirmed,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  'Players Setup',
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This match will be visible in\nOpen Matches for others to join',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _PlayersRow(
              title: 'No. of players required',
              subtitle: '(including you)',
              value: _playersRequired,
              onTap: _pickRequiredPlayers,
            ),
            const SizedBox(height: 18),
            _PlayersRow(
              title: 'Players already confirmed',
              subtitle: '(including you)',
              value: _playersConfirmed,
              onTap: _pickConfirmedPlayers,
            ),
            const SizedBox(height: 22),
            Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFD6DEE8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    'Players Still Required',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_playersStillRequired',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Players',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayersRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final VoidCallback onTap;

  const _PlayersRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    '$value',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}