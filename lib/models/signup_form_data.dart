class SignupFormData {
  String firstName;
  String lastName;
  String? avatarId;
  Set<String> selectedSports;

  SignupFormData({
    this.firstName = '',
    this.lastName = '',
    this.avatarId,
    Set<String>? selectedSports,
  }) : selectedSports = selectedSports ?? <String>{};

  bool get hasName => firstName.trim().isNotEmpty;
}
