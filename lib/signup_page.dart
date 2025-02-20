import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

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
      UserCredential userCredential;

      if (kIsWeb) {
        // Web-specific sign in
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        // Mobile/Desktop sign in
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          _showSnackBar("Google sign in canceled");
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        // Show loading indicator
        _showLoadingDialog();

        try {
          // Check if user profile exists
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // Hide loading indicator before showing dialog
            Navigator.pop(context);
            // Collect additional info if profile doesn't exist
            await _collectAdditionalInfo(user);
          } else {
            // Hide loading indicator
            Navigator.pop(context);
            _showSnackBar("Signup successful! Please log in.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } catch (e) {
          // Hide loading indicator if error occurs
          Navigator.pop(context);
          throw e;
        }
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _collectAdditionalInfo(User user) async {
    bool? completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Complete Your Profile"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Navigator.pop(context, false);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
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
                Navigator.pop(context, true);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    if (completed == true) {
      await _saveUserData(user.uid);
      _showSnackBar("Signup successful! Please log in.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Sign Up"),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: signupWithGoogle,
              icon: Icon(Icons.login),
              label: Text("Sign up with Google"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
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
