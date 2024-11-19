import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  bool isPasswordVisible = false;

  Future<void> signupWithEmailPassword() async {
    if (_areFieldsIncomplete()) {
      _showSnackBar("All fields are required.");
      return;
    }

    try {
      // Create a new user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save additional user data to Firestore
      await _saveUserData(userCredential.user!.uid);

      _showSnackBar("Signup successful! Please log in.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> signupWithGoogle() async {
    try {
      final GoogleAuthProvider authProvider = GoogleAuthProvider();

      // Use signInWithPopup for web to authenticate
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(authProvider);

      final user = userCredential.user;

      if (user != null) {
        // Prompt user to complete profile data
        await _collectAdditionalInfo(user);

        _showSnackBar("Signup successful! Please log in.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> _collectAdditionalInfo(User user) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Complete Your Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: firstNameController,
                  label: "First Name",
                  isMandatory: true,
                ),
                _buildTextField(
                  controller: lastNameController,
                  label: "Last Name",
                  isMandatory: true,
                ),
                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  isMandatory: true,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: addressController,
                  label: "Address",
                  isMandatory: true,
                ),
                _buildTextField(
                  controller: zipCodeController,
                  label: "Zip Code",
                  isMandatory: true,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Data incomplete
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Debug: Log field values
                print("First Name: ${firstNameController.text}");
                print("Last Name: ${lastNameController.text}");
                print("Phone: ${phoneController.text}");
                print("Address: ${addressController.text}");
                print("Zip Code: ${zipCodeController.text}");

                if (firstNameController.text.trim().isEmpty ||
                    lastNameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    addressController.text.trim().isEmpty ||
                    zipCodeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("All fields are required.")),
                  );
                  return;
                }

                Navigator.pop(context, true); // Data complete
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    if (firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        zipCodeController.text.trim().isNotEmpty) {
      // Save user data in Firestore
      await _saveUserData(user.uid);
    } else {
      await FirebaseAuth.instance.signOut();
      _showSnackBar("Signup canceled due to incomplete information.");
    }
  }

  Future<void> _saveUserData(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'zip_code': zipCodeController.text.trim(),
      'created_at': Timestamp.now(),
    });
  }

  bool _areFieldsIncomplete() {
    return firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        zipCodeController.text.isEmpty;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup Page')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: firstNameController,
              label: "First Name",
              isMandatory: true,
            ),
            _buildTextField(
              controller: lastNameController,
              label: "Last Name",
              isMandatory: true,
            ),
            _buildTextField(
              controller: emailController,
              label: "Email",
              isMandatory: true,
            ),
            _buildTextField(
              controller: passwordController,
              label: "Password",
              isMandatory: true,
              obscureText: !isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
            _buildTextField(
              controller: phoneController,
              label: "Phone Number",
              isMandatory: true,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: addressController,
              label: "Address",
              isMandatory: true,
            ),
            _buildTextField(
              controller: zipCodeController,
              label: "Zip Code",
              isMandatory: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signupWithEmailPassword,
              child: Text("Sign Up"),
            ),
            ElevatedButton.icon(
              onPressed: signupWithGoogle,
              icon: Icon(Icons.login),
              label: Text("Sign up with Google"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isMandatory = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (isMandatory ? " *" : ""),
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
