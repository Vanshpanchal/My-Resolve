import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:myresolve/Screens/Authentication/Login.dart';
import 'package:myresolve/Utils/Colors.dart';

import 'package:provider/provider.dart';
import 'package:myresolve/Utils/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:sizer/sizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedCountryCode = '+91';
  bool _obscureText = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF2974F0), // Blue
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FB),
        body: Stack(
        children: [
          SizedBox(
            height: 20.h,
            width: 100.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/Blur.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SvgPicture.asset(
                            'assets/icons/backarrow.svg',
                            width: 5.w,
                            height: 3.5.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create an account to continue!",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // First Name
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 4.w),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your first name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    // Last Name
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 4.w),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your last name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 4.w),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    // Date of Birth
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _pickDate(context),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 4.w),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "DD/MM/YYYY",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey, size: 18.sp),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    PhoneInputWithDropdown(
                      controller: _phoneController,
                      onCountryCodeChanged: (code) {
                        setState(() {
                          _selectedCountryCode = code;
                        });
                      },
                    ),
                    SizedBox(height: 2.h),
                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 4.w),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 3.h),
                    // Register Button (reuse your gradientButton if you want)
                    SizedBox(
                      width: double.infinity,
                      height: 6.5.h,
                      child: gradientButton(
                        context,
                        onPressed: () async {
                          final name = (_firstNameController.text.trim() + ' ' + _lastNameController.text.trim()).trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final dobText = _dobController.text.trim();
                          final phone = _phoneController.text.trim();
                          if (name.isEmpty || email.isEmpty || password.isEmpty || dobText.isEmpty || phone.isEmpty) {
                            EasyLoading.dismiss();
                            final snackBar = SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Error',
                                message: 'Please fill all fields',
                                contentType: ContentType.failure,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return;
                          }
                          // Convert dob to yyyy-MM-dd
                          String dobFormatted = '';
                          try {
                            final parts = dobText.split('/');
                            if (parts.length == 3) {
                              dobFormatted = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
                            }
                          } catch (_) {}
                          if (dobFormatted.isEmpty) {
                            EasyLoading.dismiss();
                            final snackBar = SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Error',
                                message: 'Invalid date of birth',
                                contentType: ContentType.failure,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return;
                          }
                          // Use selected country code from dropdown
                          final countryCode = _selectedCountryCode;
                          final mobileNumber = phone;
                          EasyLoading.show(status: 'Registering...');
                      final result = await authProvider.register(
                            name: name,
                            email: email,
                            password: password,
                            dob: dobFormatted,
                            countryCode: countryCode,
                            mobileNumber: mobileNumber,
                          );
                          EasyLoading.dismiss();
                          print(result['success']);
                      if (result['success'] == true) {
                            final snackBar = SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Success',
                                message: 'Registration successful!',
                                contentType: ContentType.success,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            await Future.delayed(const Duration(milliseconds: 800));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          } else {
                            print(result['message']+"in else");
                            final snackBar = SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Error',
                            message: result['message'] ?? 'Registration failed',
                                contentType: ContentType.failure,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        text: "Register",
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Log in",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: const Color(0xFF2974F0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// You can reuse your BlueWaveClipper and gradientButton from your login screen files.
class BlueWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.cubicTo(
      size.width * 0.25, size.height,
      size.width * 0.75, size.height - 80,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// You can also reuse your gradientButton as before.
Widget gradientButton(BuildContext context, {required VoidCallback onPressed, required String text}) {
  return SizedBox(
    width: double.infinity,
    height: 6.5.h,
    child: Stack(
      children: [
        // Blue background
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2974F0),
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
        // White linear gradient overlay at 12% opacity
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // ElevatedButton with transparent background
        Positioned.fill(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              minimumSize: Size(0, 0),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

final List<Map<String, String>> _countries = [
  {"flag": "🇮🇳", "code": "+91"},
  {"flag": "🇺🇸", "code": "+1"},
  {"flag": "🇬🇧", "code": "+44"},
  {"flag": "🇨🇭", "code": "+41"},
];


class PhoneInputWithDropdown extends StatefulWidget {
  const PhoneInputWithDropdown({Key? key, required this.controller, required this.onCountryCodeChanged}) : super(key: key);

  final TextEditingController controller;
  final void Function(String) onCountryCodeChanged;

  @override
  State<PhoneInputWithDropdown> createState() => _PhoneInputWithDropdownState();
}

class _PhoneInputWithDropdownState extends State<PhoneInputWithDropdown> {
  // Map country code to max length
  final Map<String, int> _countryPhoneLengths = {
    '+91': 10, // India
    '+1': 10,  // USA
    '+44': 10, // UK (varies, but 10 for mobiles)
    '+41': 9,  // Switzerland (varies, 9 for mobiles)
  };

  Map<String, String> selectedCountry = _countries[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCountryCodeChanged(selectedCountry['code']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    int maxLength = _countryPhoneLengths[selectedCountry['code']] ?? 10;
    return Row(
      children: [
        Container(
          height: 6.5.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3.w),
              bottomLeft: Radius.circular(3.w),
            ),
          ),
          padding: EdgeInsets.only(left: 4.w, right: 1.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, String>>(
              value: selectedCountry,
              dropdownColor: AppColors.background,
              borderRadius: BorderRadius.circular(3.w),
              items: _countries.map((country) {
                return DropdownMenuItem<Map<String, String>>(
                  value: country,
                  child: Row(
                    children: [
                      Text(country['flag']!, style: TextStyle(fontSize: 18.sp)),
                      SizedBox(width: 1.w),
                      Text(country['code']!, style: TextStyle(fontSize: 16.sp)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCountry = value;
                  });
                  widget.onCountryCodeChanged(selectedCountry['code']!);
                }
              },
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: Colors.grey),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            maxLength: maxLength,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 3.w),
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your phone number",
              prefixText: "", // Add some spacing between dropdown and text
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3.w),
                  bottomRight: Radius.circular(3.w),
                ),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}