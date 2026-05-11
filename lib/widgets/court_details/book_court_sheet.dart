import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rallyup/screens/confirm_booking_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'players_setup_sheet.dart';

class BookCourtSheet extends StatefulWidget {
  final String courtName;
  final String sportEmoji;
  final String imagePath;
  final String priceText;
  final String selectedAvailableFor;
  final String selectedSport;

  const BookCourtSheet({
    super.key,
    required this.courtName,
    required this.sportEmoji,
    required this.imagePath,
    required this.priceText,
    required this.selectedAvailableFor,
    required this.selectedSport,
  });

  @override
  State<BookCourtSheet> createState() => _BookCourtSheetState();
}

class _BookCourtSheetState extends State<BookCourtSheet> {
  String _selectedDateText = 'Mon, Aug 17';
  String _selectedTimeText = '6:00 PM - 7:00 PM';
  String _selectedMatchType = 'Open Match';

  final List<String> _timeOptions = const [
    '6:00 PM - 7:00 PM',
    '7:00 PM - 8:00 PM',
    '8:00 PM - 9:00 PM',
    '9:00 PM - 10:00 PM',
  ];

  Future<void> _openDatePickerOverlay() async {
    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return _DatePickerOverlay(
          initialDate: DateTime(2025, 8, 17),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateText = DateFormat('EEE, MMM d').format(picked);
      });
    }
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTimeText == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeText = time;
        });
      },
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          time,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMatchType == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMatchType = title;
        });
      },
      child: Container(
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 34, color: AppColors.textPrimary),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConfirmBookingDirect() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ConfirmBookingPage(
          courtName: widget.courtName,
          sport: widget.selectedSport,
          sportEmoji: widget.sportEmoji,
          imagePath: widget.imagePath,
          dateText: _selectedDateText,
          timeText: _selectedTimeText,
          priceText: widget.priceText,
          matchType: _selectedMatchType,
          totalPlayers: 4,
          confirmedPlayers: 1,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _openPlayersSetup() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PlayersSetupSheet(
          courtName: widget.courtName,
          sport: widget.selectedSport,
          sportEmoji: widget.sportEmoji,
          imagePath: widget.imagePath,
          dateText: _selectedDateText,
          timeText: _selectedTimeText,
          priceText: widget.priceText,
          matchType: _selectedMatchType,
          initialPlayersRequired: 4,
          initialPlayersConfirmed: 1,
        );
      },
    );
  }

  void _continue() {
    if (_selectedMatchType == 'Private Match') {
      _openConfirmBookingDirect();
    } else {
      _openPlayersSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Court',
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Select date',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openDatePickerOverlay,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedDateText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 28,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Select time',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: _timeOptions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 48,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return _buildTimeChip(_timeOptions[index]);
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Match type',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMatchTypeCard(
                    title: 'Private Match',
                    subtitle: 'Only invited players\ncan join',
                    icon: Icons.lock_outline_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMatchTypeCard(
                    title: 'Open Match',
                    subtitle: 'Anyone can join\nthis match',
                    icon: Icons.groups_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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

class _DatePickerOverlay extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerOverlay({
    required this.initialDate,
  });

  @override
  State<_DatePickerOverlay> createState() => _DatePickerOverlayState();
}

class _DatePickerOverlayState extends State<_DatePickerOverlay> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  final DateTime _secondaryHighlightedDate = DateTime(2025, 8, 5);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  Future<void> _openMonthYearPicker() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final years = List.generate(7, (index) => 2023 + index);

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SizedBox(
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select month & year',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: years.expand((year) {
                        return List.generate(12, (monthIndex) {
                          final date = DateTime(year, monthIndex + 1);
                          final isSelected = date.year == _visibleMonth.year &&
                              date.month == _visibleMonth.month;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              DateFormat('MMMM yyyy').format(date),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, date),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _visibleMonth = DateTime(picked.year, picked.month);
        final daysInNewMonth =
            DateTime(picked.year, picked.month + 1, 0).day;
        final newDay =
            _selectedDate.day > daysInNewMonth ? daysInNewMonth : _selectedDate.day;
        _selectedDate = DateTime(picked.year, picked.month, newDay);
      });
    }
  }

  List<Widget> _buildCalendarCells() {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);

    final leadingEmptyCount = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    final List<Widget> cells = [];

    for (int i = 0; i < leadingEmptyCount; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= totalDays; day++) {
      final currentDate = DateTime(_visibleMonth.year, _visibleMonth.month, day);

      final isSelected =
          currentDate.year == _selectedDate.year &&
          currentDate.month == _selectedDate.month &&
          currentDate.day == _selectedDate.day;

      final isSecondaryHighlighted =
          currentDate.year == _secondaryHighlightedDate.year &&
          currentDate.month == _secondaryHighlightedDate.month &&
          currentDate.day == _secondaryHighlightedDate.day &&
          !isSelected;

      cells.add(
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = currentDate;
              });
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isSecondaryHighlighted
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    while (cells.length < 42) {
      cells.add(const SizedBox.shrink());
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 680,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F1E7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select date',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(_selectedDate),
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit_rounded, size: 24),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.primary, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                GestureDetector(
                  onTap: _openMonthYearPicker,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_visibleMonth),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _goToPreviousMonth,
                  child: const Icon(Icons.chevron_left_rounded, size: 30),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _goToNextMonth,
                  child: const Icon(Icons.chevron_right_rounded, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('S'),
                Text('M'),
                Text('T'),
                Text('W'),
                Text('T'),
                Text('F'),
                Text('S'),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
                children: _buildCalendarCells(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = widget.initialDate;
                      _visibleMonth = DateTime(
                        widget.initialDate.year,
                        widget.initialDate.month,
                      );
                    });
                  },
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  child: Text(
                    'OK',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}