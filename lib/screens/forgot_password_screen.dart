import 'package:flutter/material.dart';
import 'package:mamaapp/screens/login_screen.dart';
import 'package:mamaapp/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _generalError;
  String? _successMessage;
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _otpBoxControllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    for (final ctrl in _otpBoxControllers) {
      ctrl.dispose();
    }
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _generalError = null;
      _successMessage = null;
    });
    try {
      await _apiService.requestPasswordReset(_emailController.text.trim());
      setState(() {
        _otpSent = true;
        _successMessage = 'OTP sent to your email.';
      });
    } catch (e) {
      setState(() {
        _emailError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtpAndReset() async {
    setState(() {
      _isLoading = true;
      _otpError = null;
      _passwordError = null;
      _generalError = null;
      _successMessage = null;
    });
    final otp = _otpBoxControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() {
        _otpError = 'Please enter the 6-digit OTP.';
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        _passwordError = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }
    try {
      await _apiService.verifyOtpReset(
        email: _emailController.text.trim(),
        otp: otp,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      );
      setState(() {
        _successMessage = 'Password reset successful. Please log in.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFCB4172)),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Color(0xFFCB4172),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_generalError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!_otpSent) ...[
                    const Text(
                      'Enter your email to receive an OTP for password reset.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCB4172),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ] else ...[
                    const Text(
                      'Enter the OTP sent to your email and set your new password.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: List.generate(6, (i) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                            child: TextField(
                              controller: _otpBoxControllers[i],
                              focusNode: _otpFocusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                counterText: '',
                                errorText: i == 0 ? _otpError : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (val) {
                                if (val.length == 1 && i < 5) {
                                  _otpFocusNodes[i + 1].requestFocus();
                                } else if (val.isEmpty && i > 0) {
                                  _otpFocusNodes[i - 1].requestFocus();
                                }
                              },
                              onSubmitted: (val) {
                                if (i == 5) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        errorText: _passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordConfirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtpAndReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCB4172),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 