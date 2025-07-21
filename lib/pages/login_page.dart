import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final isValid = password.length >= 6;
    if (_isPasswordValid != isValid) {
      setState(() {
        _isPasswordValid = isValid;
      });
    }
  }

  bool get _isFormValid => _isEmailValid && _isPasswordValid;

  // Future<void> _signInWithEmail() async {
  //   if (!_isFormValid) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     await _authService.signInWithEmailAndPassword(
  //       _emailController.text.trim(),
  //       _passwordController.text,
  //     );
  //     // Handle successful login (navigate to main app)
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Login successful!')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Login failed: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  Future<void> _signInWithEmail() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    // Simulasi loading untuk melihat tampilan
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo mode - Login disabled')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    // Simulasi loading untuk melihat tampilan
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo mode - Google login disabled')),
      );
      setState(() => _isLoading = false);
    }
  }

  // Future<void> _signInWithGoogle() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     await _authService.signInWithGoogle();
  //     // Handle successful login (navigate to main app)
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Google login successful!')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Google login failed: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Large Logo
              Image.asset(
                'assets/images/tsn.jpg',
                width: 120,
                height: 73,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 60),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter Username',
                      keyboardType: TextInputType.emailAddress,
                      isValid: _isEmailValid,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Enter Key Password',
                      isPassword: true,
                      isValid: _isPasswordValid,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 52,
                    //   child: ElevatedButton(
                    //     onPressed: _isFormValid && !_isLoading
                    //         ? _signInWithEmail
                    //         : null,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: _isFormValid
                    //           ? const Color(0xFF860092)
                    //           : Colors.grey.shade300,
                    //       foregroundColor: _isFormValid
                    //           ? Colors.white
                    //           : Colors.grey.shade600,
                    //       elevation: 0,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(26),
                    //       ),
                    //     ),
                    //     child: _isLoading
                    //         ? const SizedBox(
                    //             height: 20,
                    //             width: 20,
                    //             child: CircularProgressIndicator(
                    //               strokeWidth: 2,
                    //               valueColor: AlwaysStoppedAnimation<Color>(
                    //                 Colors.white,
                    //               ),
                    //             ),
                    //           )
                    //         : Text(
                    //             'Sign In',
                    //             style: GoogleFonts.inter(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //   ),
                    // ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        // Always enabled for demo
                        onPressed: !_isLoading
                            ? () => context.go('/home')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF860092),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Google Sign In Button
              GoogleSignInButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                isLoading: _isLoading,
              ),

              const Spacer(),

              // Bottom indicator
              Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
