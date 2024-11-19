import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _passwordField("Current Password", currentPasswordController),
            _passwordField("New Password", newPasswordController),
            _passwordField("Confirm New Password", confirmPasswordController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password changed successfully!")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwords do not match!")),
                  );
                }
              },
              child: Text("Save Password"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        controller: controller,
      ),
    );
  }

  // Remove this redundant build method
}
