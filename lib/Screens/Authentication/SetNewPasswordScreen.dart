import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myresolve/Utils/api_endpoints.dart';
import 'package:myresolve/Utils/awesome_snackbar_helper.dart';
import 'package:myresolve/Utils/user_model.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  static const _storage = FlutterSecureStorage();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Get email from stored user data
    final userBox = Hive.box<UserModel>('userBox');
    if (userBox.isEmpty) {
      if (mounted) {
        AwesomeSnackbarHelper.showError(
          context,
          'Error',
          'User session not found. Please login again.',
        );
      }
      return;
    }
    
    final user = userBox.getAt(0);
    if (user == null || user.email.isEmpty) {
      if (mounted) {
        AwesomeSnackbarHelper.showError(
          context,
          'Error',
          'User email not found. Please login again.',
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/auth/reset-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': user.email,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          AwesomeSnackbarHelper.showSuccess(
            context,
            'Success!',
            'Password updated successfully! You can now login with your new password.',
          );
          Navigator.pop(context);
        } else {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Failed to update password';
          AwesomeSnackbarHelper.showError(
            context,
            'Reset Failed',
            errorMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackbarHelper.showError(
          context,
          'Network Error',
          'Please check your internet connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Sizer(
        builder: (ctx, orientation, deviceType) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            backgroundColor: const Color(0xFFF5F8FB),
            body: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/Blur.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        // Title
                        Text(
                          'Set a new password',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        // Subtitle
                        Text(
                          'Create a new password. Ensure it differs from previous ones for security',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Form
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // New Password Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    validator: _validatePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your new password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.h,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword = !_obscureNewPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                // Confirm Password Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    validator: _validateConfirmPassword,
                                    decoration: InputDecoration(
                                      hintText: 'Re-enter password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.h,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                // Update Password Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updatePassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1D61E7),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 2.5.h,
                                            width: 2.5.h,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Update Password',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}