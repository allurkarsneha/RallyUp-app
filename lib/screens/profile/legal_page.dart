import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  Widget _legalRow(String title) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD8F3DC), width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(fontSize: 16),
            ),
          ),

          Text(
            'View',
            style: AppTextStyles.action.copyWith(
              color: AppColors.brightGreen,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.open_in_new_rounded,
            color: AppColors.brightGreen,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFC8F3CE),

        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).padding.top + 96,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                color: AppColors.white,

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 24,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),

                    Text('Legal', style: AppTextStyles.pageTitle),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              _legalRow('Privacy Policy'),
              _legalRow('Terms of Service'),

              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
