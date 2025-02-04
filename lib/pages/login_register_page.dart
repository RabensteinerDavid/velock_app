import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velock_app/main.dart';
import 'package:velock_app/pages/home_page.dart';
import 'package:velock_app/util/auth.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String _errorMessage = '';
  bool _isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signIn() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Unknown error occurred.';
      });
      _showSnackBar(_errorMessage);
    }
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      _showSnackBar(_errorMessage);
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Unknown error occurred.';
      });
      _showSnackBar(_errorMessage);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email to reset the password.';
      });
      _showSnackBar(_errorMessage);
      return;
    }

    try {
      await Auth().resetPassword(email: _emailController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Unknown error occurred.';
      });
      _showSnackBar(_errorMessage);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isPassword,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: MyApp.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyApp.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _isLoginMode ? _signIn : _register,
      child: Text(
        _isLoginMode ? 'Login' : 'Register',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildToggleLoginRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginMode ? "Don't have an account?" : "Already a member?",
          style: const TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginMode = !_isLoginMode;
              _errorMessage = '';
            });
          },
          child: Text(
            _isLoginMode ? 'Sign Up' : 'Login',
            style: const TextStyle(color: MyApp.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _resetPassword,
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: MyApp.accentColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.accentColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/lottie/authentication.json",
                      fit: BoxFit.cover,
                      width: 100,
                    ),
                    Text(
                      _isLoginMode ? 'Welcome Back!' : 'Sign Up',
                      style: const TextStyle(
                        fontSize: 30,
                        color: MyApp.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        isPassword: false),
                    _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true),
                    if (!_isLoginMode)
                      _buildTextField(
                          label: 'Repeat Password',
                          controller: _confirmPasswordController,
                          isPassword: true),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _buildSubmitButton(),
                    ),
                    _buildToggleLoginRegister(),
                    _buildForgotPasswordButton(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 16,
              child: Image.asset("assets/images/velock.png", width: 100),
            ),
          ],
        ),
      ),
    );
  }
}
