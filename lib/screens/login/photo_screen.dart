import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'sports_preferences_screen.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key});

  void goToSports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SportsPreferencesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 54),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.darkGreen,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Set Your Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE1E3E6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              Center(
                child: SizedBox(
                  width: 170,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA7E1B1),
                      foregroundColor: AppColors.darkGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text('Upload Photo'),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.lightGray)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('or'),
                  ),
                  Expanded(child: Divider(color: AppColors.lightGray)),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => goToSports(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: PrimaryButton(
                  text: 'Continue',
                  width: 180,
                  height: 48,
                  backgroundColor: AppColors.darkGreen.withOpacity(0.75),
                  onPressed: () => goToSports(context),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}
