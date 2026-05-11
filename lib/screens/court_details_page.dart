import 'package:flutter/material.dart';
import 'package:rallyup/main.dart';
import 'package:rallyup/screens/notifications_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/court_details/book_court_sheet.dart';

class CourtDetailsPage extends StatefulWidget {
  final String courtName;
  final String sport;
  final String sportEmoji;
  final String imagePath;
  final String distanceText;
  final String ratingText;
  final String priceText;
  final String locationText;

  const CourtDetailsPage({
    super.key,
    required this.courtName,
    required this.sport,
    required this.sportEmoji,
    required this.imagePath,
    required this.distanceText,
    required this.ratingText,
    required this.priceText,
    required this.locationText,
  });

  @override
  State<CourtDetailsPage> createState() => _CourtDetailsPageState();
}

class _CourtDetailsPageState extends State<CourtDetailsPage> {
  String _selectedAvailableFor = 'Doubles';
  String _selectedSport = 'Tennis';

  void _openNotificationsPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const NotificationsPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openBookCourtSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BookCourtSheet(
          courtName: widget.courtName,
          sportEmoji: widget.sportEmoji,
          imagePath: widget.imagePath,
          priceText: widget.priceText,
          selectedAvailableFor: _selectedAvailableFor,
          selectedSport: _selectedSport,
        );
      },
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MainShell(initialIndex: index),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sportsOptions = ['Tennis', 'Pickleball', 'Badminton'];
    final availableForOptions = ['Singles', 'Doubles', 'Practice', 'Coaching'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                18,
                AppSpacing.pageHorizontal,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Court Details',
                    style: AppTextStyles.pageTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openNotificationsPage(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Image.asset(
                    widget.imagePath,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      18,
                      AppSpacing.pageHorizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.courtName,
                          style: AppTextStyles.pageTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${widget.sportEmoji}  ${widget.sport}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF4B400),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.ratingText} (128 reviews)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.distanceText,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '•',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.locationText,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.priceText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'About this venue',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Well-maintained outdoor tennis court with night lighting.\nPerfect for casual games and practice.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Amenities',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 18,
                          runSpacing: 10,
                          children: [
                            _buildAmenityItem(Icons.light_mode_outlined, 'Lighting'),
                            _buildAmenityItem(Icons.local_parking_outlined, 'Parking'),
                            _buildAmenityItem(Icons.wc_outlined, 'Restrooms'),
                            _buildAmenityItem(Icons.water_drop_outlined, 'Water'),
                            _buildAmenityItem(Icons.event_seat_outlined, 'Seating'),
                            _buildAmenityItem(Icons.sports_tennis_outlined, 'Rental Equipment'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 14),
                        Text(
                          'Available for',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableForOptions.map((option) {
                            return _buildSelectableChip(
                              label: option,
                              isSelected: _selectedAvailableFor == option,
                              onTap: () {
                                setState(() {
                                  _selectedAvailableFor = option;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Sports',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sportsOptions.map((option) {
                            return _buildSelectableChip(
                              label: option,
                              isSelected: _selectedSport == option,
                              onTap: () {
                                setState(() {
                                  _selectedSport = option;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _openBookCourtSheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Book Now',
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
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: null,
        onTap: (index) => _onBottomNavTap(context, index),
      ),
    );
  }
}