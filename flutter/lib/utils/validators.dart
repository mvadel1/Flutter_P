class Validators {

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 8) {
      return 'Invalid phone number';
    }
    return null; 
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field required';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
