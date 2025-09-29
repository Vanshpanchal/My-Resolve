import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:myresolve/Utils/firebase_notification_service.dart';
import 'package:myresolve/Utils/user_profile_provider.dart';
import 'package:myresolve/Utils/auth_provider.dart';
import 'package:myresolve/Utils/user_model.dart';
import 'package:myresolve/Utils/awesome_snackbar_helper.dart';
import 'package:myresolve/Screens/Authentication/SetNewPasswordScreen.dart';
import 'package:myresolve/Screens/Authentication/Login.dart';
import 'package:myresolve/Utils/pact_provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _currentReminder;

  @override
  void initState() {
    super.initState();
    _loadCurrentReminder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProfileProvider>(context, listen: false).fetchUserProfile();
    });
  }


  Future<void> _loadCurrentReminder() async {
    final reminder = await FirebaseNotificationService.getCurrentReminder();
    if (mounted) {
      setState(() {
        _currentReminder = reminder;
      });
    }
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1D61E7), // App blue
              onPrimary: Colors.white, // Text on blue
              onSurface: Colors.black, // Text on white
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: WidgetStateColor.resolveWith((states) => Color(0xFF1D61E7)),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) => Colors.white),
              dayPeriodColor: WidgetStateColor.resolveWith((states) => Color(0xFF1D61E7)),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) => Colors.white),
              dialHandColor: Color(0xFF1D61E7),
              dialBackgroundColor: Color(0xFFE7EFFA),
              entryModeIconColor: Color(0xFF1D61E7),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final box = await Hive.openBox('reminderBox');
      await box.put('reminder', {'hour': picked.hour, 'minute': picked.minute});
      // Schedule Firebase notification
      await FirebaseNotificationService.scheduleDailyReminder(picked.hour, picked.minute, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily reminder set for ${picked.format(context)}')),
      );
    }
  }

  Future<void> _cancelReminder(BuildContext context) async {
    await FirebaseNotificationService.cancelDailyReminder(context: context);
    await _loadCurrentReminder();
  }

  String _getReminderStatusText() {
    if (_currentReminder == null || _currentReminder!['enabled'] != true) {
      return 'No daily reminder set';
    }
    
    final hour = _currentReminder!['hour'] ?? 0;
    final minute = _currentReminder!['minute'] ?? 0;
    final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    
    return 'Daily reminder: $timeString';
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D61E7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (shouldLogout != true) return;

      // Clear user data from Hive
      final userBox = Hive.box<UserModel>('userBox');
      await userBox.clear();
      
      // Call auth provider logout
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        
        AwesomeSnackbarHelper.showSuccess(
          context,
          'Logged Out',
          'You have been successfully logged out.',
        );
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackbarHelper.showError(
          context,
          'Logout Failed',
          'Failed to logout. Please try again.',
        );
      }
    }
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
          extendBodyBehindAppBar: true, // Lets body extend behind app bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Settings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5F8FB),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 5.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      child: Column(
                        children: [
                          Consumer<UserProfileProvider>(
                            builder: (context, userProfileProvider, _) {
                              String? profilePicture = userProfileProvider.userProfile?['profilePicture'];
                              
                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 6.5.h,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 6.h,
                                      backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                                          ? NetworkImage(profilePicture)
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      onBackgroundImageError: profilePicture != null && profilePicture.isNotEmpty
                                          ? (exception, stackTrace) {
                                              debugPrint('Profile image error: $exception');
                                            }
                                          : null,
                                      child: profilePicture == null || profilePicture.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 4.h,
                                              color: Colors.grey[600],
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final success = await userProfileProvider.selectAndUploadProfilePicture();
                                        if (success && mounted) {
                                          AwesomeSnackbarHelper.showSuccess(
                                            context,
                                            'Success!',
                                            'Profile picture updated successfully!',
                                          );
                                        } else if (!success && mounted) {
                                          AwesomeSnackbarHelper.showError(
                                            context,
                                            'Upload Failed',
                                            userProfileProvider.error ?? 'Failed to update profile picture',
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(1.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1D61E7),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: userProfileProvider.uploading
                                            ? SizedBox(
                                                width: 2.h,
                                                height: 2.h,
                                                child: const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 2.h,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 4.h),
                          // _SettingsButton(
                          //   icon: Icons.person_outline_rounded,
                          //   label: 'Edit Profile',
                          //   onTap: () {
                          //     // TODO: Implement edit profile logic
                          //   },
                          // ),
                          // SizedBox(height: 2.h),
                          Consumer<UserProfileProvider>(
                            builder: (context, userProfileProvider, _) {
                              return _SettingsButton(
                                icon: Icons.photo_camera_outlined,
                                label: 'Update Profile Picture',
                                onTap: () async {
                                  final success = await userProfileProvider.selectAndUploadProfilePicture();
                                  if (success && mounted) {
                                    AwesomeSnackbarHelper.showSuccess(
                                      context,
                                      'Success!',
                                      'Profile picture updated successfully!',
                                    );
                                  } else if (!success && mounted) {
                                    AwesomeSnackbarHelper.showError(
                                      context,
                                      'Upload Failed',
                                      userProfileProvider.error ?? 'Failed to update profile picture',
                                    );
                                  }
                                },
                                loading: userProfileProvider.uploading,
                              );
                            },
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetNewPasswordScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.alarm_outlined,
                            label: 'Daily Reminder',
                            onTap: () => _pickReminderTime(context),
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.psychology_outlined,
                            label: 'Setup Gemini API Key',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => GeminiApiKeyDialog(),
                              );
                            },
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.logout_outlined,
                            label: 'Logout',
                            onTap: _logout,
                          ),
                          SizedBox(height: 2.h),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: top + 1.2.h,
        left: 4.w,
        right: 4.w,
        bottom: 2.2.h,
      ),
      width: double.infinity,
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [Color(0xFFBFD6FF), Color(0xFFE7EFFA)],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.only(
      //     bottomLeft: Radius.circular(26),
      //     bottomRight: Radius.circular(26),
      //   ),
      // ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(1.2.h),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 2.2.h,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w), // spacer to balance back button
        ],
      ),
    );
  }
}

class GeminiApiKeyDialog extends StatefulWidget {
  @override
  State<GeminiApiKeyDialog> createState() => _GeminiApiKeyDialogState();
}

class _GeminiApiKeyDialogState extends State<GeminiApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.07,
        vertical: size.height * 0.05,
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: size.height * 0.8,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: size.width * 0.06,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: size.height * 0.02),
                        Icon(
                          Icons.psychology,
                          size: size.width * 0.15,
                          color: Color(0xFF3B73FF),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          "Setup Gemini API Key",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.055,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "Enter your Gemini API key to enable\nAI-powered check-in verification.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Enter your Gemini API Key",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: size.width * 0.04,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.018,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Color(0xFF3B73FF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Color(0xFF3B73FF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color(0xFF3B73FF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B73FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              elevation: 2,
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                                    setState(() {
                                      _loading = true;
                                      _error = null;
                                    });
                                    String apiKey = _controller.text.trim();
                                    if (apiKey.isEmpty) {
                                      setState(() {
                                        _error = 'Please enter your Gemini API key.';
                                        _loading = false;
                                      });
                                      return;
                                    }
                                    final pactProvider = Provider.of<PactProvider>(context, listen: false);
                                    final result = await pactProvider.setGeminiApiKey(geminiApiKey: apiKey);
                                    if (result['success']) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            content: AwesomeSnackbarContent(
                                              title: 'Success!',
                                              message: 'Gemini API key has been set successfully!',
                                              contentType: ContentType.success,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        _error = result['error'] ?? 'Failed to set API key.';
                                        _loading = false;
                                      });
                                    }
                                  },
                            child: _loading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Set API Key',
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      // color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1D61E7),
                Color(0xBD1D61E7), // Blue
                // Color(0x1FFFFFFF), // Light Blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          height: 7.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 5.8.h,
                height: 5.8.h,

                child: Icon(icon, color: Colors.white, size: 2.6.h),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              loading
                  ? SizedBox(
                      width: 3.2.h,
                      height: 3.2.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 3.2.h,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
