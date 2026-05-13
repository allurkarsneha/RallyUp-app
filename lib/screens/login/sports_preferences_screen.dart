import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart';

class SportsPreferencesScreen extends StatefulWidget {
  const SportsPreferencesScreen({super.key});

  @override
  State<SportsPreferencesScreen> createState() =>
      _SportsPreferencesScreenState();
}

class _SportsPreferencesScreenState extends State<SportsPreferencesScreen> {
  final Set<String> selectedSports = {};

  final List<Map<String, String>> sports = const [
    {'name': 'Tennis', 'image': 'assets/images/login/tennis.png'},
    {'name': 'Swimming', 'image': 'assets/images/login/swimming.png'},
    {'name': 'Badminton', 'image': 'assets/images/login/badminton.png'},
    {'name': 'Soccer', 'image': 'assets/images/login/soccer.png'},
    {'name': 'Table Tennis', 'image': 'assets/images/login/tabletennis.png'},
    {'name': 'Basketball', 'image': 'assets/images/login/basketball.png'},
    {'name': 'Volleyball', 'image': 'assets/images/login/volleyball.png'},
    {'name': 'Pickleball', 'image': 'assets/images/login/pickleball.png'},
    {'name': 'Cricket', 'image': 'assets/images/login/cricket.png'},
    {'name': 'Football', 'image': 'assets/images/login/football.png'},
  ];

  void finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainShell(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
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

              const SizedBox(height: 18),

              const Text(
                'Pick your favorites!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: "Type 'Cycling'",
                  hintStyle: const TextStyle(color: AppColors.grayText),
                  filled: true,
                  fillColor: AppColors.lightGray,
                  suffixIcon: const Icon(
                    Icons.search,
                    color: AppColors.grayText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: sports.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 22,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final sport = sports[index];
                    final name = sport['name']!;
                    final image = sport['image']!;
                    final isSelected = selectedSports.contains(name);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSports.remove(name);
                          } else {
                            selectedSports.add(name);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.darkGreen
                                : Colors.transparent,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: .25),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: PrimaryButton(
        text: 'Done',
        width: 180,
        height: 50,
        backgroundColor: AppColors.darkGreen,
        onPressed: finishOnboarding,
      ),
    );
  }
}
