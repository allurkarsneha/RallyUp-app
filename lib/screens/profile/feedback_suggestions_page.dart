import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class FeedbackSuggestionsPage extends StatefulWidget {
  const FeedbackSuggestionsPage({super.key});

  @override
  State<FeedbackSuggestionsPage> createState() =>
      _FeedbackSuggestionsPageState();
}

class _FeedbackSuggestionsPageState extends State<FeedbackSuggestionsPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    categoryController.text = 'Technical issue, bug, feedback...';
  }

  @override
  void dispose() {
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                'Feedback & Suggestions',
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: AppTextStyles.body.copyWith(fontSize: 20));
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontSize: 18,
      ),
      filled: true,
      fillColor: const Color(0xFFEDEDED),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  void reportIssue() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback submitted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),

              const SizedBox(height: 42),

              _label('Category'),

              const SizedBox(height: 8),

              TextField(
                controller: categoryController,
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 26),

              _label('Description'),

              const SizedBox(height: 8),

              TextField(
                controller: descriptionController,
                maxLines: 9,
                decoration: _inputDecoration(
                  hint: 'Please give a detailed explanation of\nthe problem',
                ),
              ),

              const SizedBox(height: 76),

              Center(
                child: PrimaryButton(
                  text: 'Report',
                  width: 300,
                  height: 58,
                  backgroundColor: AppColors.primary,
                  onPressed: reportIssue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
