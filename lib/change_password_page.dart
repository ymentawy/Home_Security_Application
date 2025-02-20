import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    User? user = _auth.currentUser;

    if (user == null) {
      _showSnackBar("No user logged in.");
      return;
    }

    // Check if user signed in with Google
    for (var provider in user.providerData) {
      if (provider.providerId == "google.com") {
        _showSnackBar(
            "Password change is not allowed for Google sign-in users.");
        return;
      }
    }

    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar("All fields are required.");
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar("New password must be at least 6 characters long.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("New passwords do not match.");
      return;
    }

    try {
      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      _showSnackBar("Password changed successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _passwordField(
              label: "Current Password",
              controller: currentPasswordController,
              isPasswordVisible: isCurrentPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  isCurrentPasswordVisible = !isCurrentPasswordVisible;
                });
              },
            ),
            _passwordField(
              label: "New Password",
              controller: newPasswordController,
              isPasswordVisible: isNewPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  isNewPasswordVisible = !isNewPasswordVisible;
                });
              },
            ),
            _passwordField(
              label: "Confirm New Password",
              controller: confirmPasswordController,
              isPasswordVisible: isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text("Save Password"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
