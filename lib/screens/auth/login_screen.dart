import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import '../normal_user/home_screen.dart';
import '../blind_user/blind_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _normalUserController = TextEditingController();
  final _normalPasswordController = TextEditingController();
  final _blindUserController = TextEditingController();
  final _blindPasswordController = TextEditingController();

  Future<void> _login(String type) async {
    final prefs = await SharedPreferences.getInstance();

    if (type == "normal") {
      if (_normalUserController.text.trim() == "normaluser" &&
          _normalPasswordController.text.trim() == "1234") {
        await prefs.setString('userType', 'normal');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NormalUserHome()),
        );
      } else {
        _showError();
      }
    } else {
      if (_blindUserController.text.trim() == "blinduser" &&
          _blindPasswordController.text.trim() == "5678") {
        await prefs.setString('userType', 'blind');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BlindUserHome()),
        );
      } else {
        _showError();
      }
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid username or password")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cursive',
                ),
              ),
              const SizedBox(height: 30),

              /// Cards layout (Row for wide screens, Column for phones)
              Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLoginCard(
                    title: "Normal User Login",
                    usernameController: _normalUserController,
                    passwordController: _normalPasswordController,
                    onLogin: () => _login("normal"),
                  ),
                  if (isWide) const SizedBox(width: 20),
                  if (!isWide) const SizedBox(height: 20),
                  _buildLoginCard(
                    title: "Blind User Login",
                    usernameController: _blindUserController,
                    passwordController: _blindPasswordController,
                    onLogin: () => _login("blind"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// Sign Up text
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: const Text(
                  "Don't have an account? Sign up here",
                  style: TextStyle(fontSize: 16, color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard({
    required String title,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required VoidCallback onLogin,
  }) {
    return SizedBox(
      width: 320,
      child: Card(
        color: const Color(0xFFF6F2FA),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cursive',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
