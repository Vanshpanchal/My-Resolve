import 'dart:async';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:myresolve/Utils/pact_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:myresolve/Utils/awesome_snackbar_helper.dart';
import 'package:myresolve/Screens/Main/FullScreenImageViewer.dart';
import 'package:myresolve/Screens/Main/InviteQrScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Utils/reminder_helper.dart';
import 'package:sizer/sizer.dart';

class PactDetailScreen extends StatefulWidget {
  const PactDetailScreen({Key? key}) : super(key: key);

  @override
  State<PactDetailScreen> createState() => _PactDetailScreenState();
}

class _PactDetailScreenState extends State<PactDetailScreen> {
  File? _selectedImage;
  final TextEditingController _commentController = TextEditingController();
  bool _uploading = false;
  final ValueNotifier<String> _reminderTimeStrNotifier = ValueNotifier('00:00:00');
  Timer? _reminderTimer;
  String? _pactId;
  bool _initialLoadDone = false;
  
  // Loading states for verification buttons
  bool _acceptLoading = false;
  bool _declineLoading = false;
  bool _geminiLoading = false;

  @override
  void initState() {
    super.initState();
    _updateReminderCountdown();
    _reminderTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateReminderCountdown());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : '';
      _pactId = pactId;
      if (pactId.isNotEmpty && !_initialLoadDone) {
        _initialLoadDone = true;
        // Always fetch fresh data when pact detail is viewed
        Provider.of<PactProvider>(context, listen: false).fetchTodayCheckins(pactId);
      }
    });
  }

  // Centralized refresh method for pull-to-refresh and initial load
  Future<void> _refreshData() async {
    if (_pactId != null && _pactId!.isNotEmpty) {
      final pactProvider = Provider.of<PactProvider>(context, listen: false);
      try {
        await pactProvider.fetchTodayCheckins(_pactId!); // Always fetch fresh data
      } catch (e) {
        if (mounted) {
          AwesomeSnackbarHelper.showError(
            context,
            'Error',
            'Failed to refresh data',
          );
        }
      }
    }
  }

  void _updateReminderCountdown() async {
    final duration = await ReminderHelper.getTimeUntilNextReminder();
    _reminderTimeStrNotifier.value = ReminderHelper.formatDuration(duration);
  }

  @override
  @override
  void dispose() {
    _reminderTimer?.cancel();
    _reminderTimeStrNotifier.dispose();
    super.dispose();
  }
  // Countdown card widget (copied from Dashboard/Profile for consistency)
  Widget _countdownCard(String timeStr, String pactId) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3B73FF),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: SizedBox(
        height: 16.h,
        child: Row(
          children: [
            Expanded(
              flex: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Check-in Due',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(.85),
                      fontWeight: FontWeight.w500,
                      letterSpacing: .2,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  FittedBox(
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(3.w),
                      onTap: _uploading ? null : () {
                        if (pactId.isNotEmpty) {
                          _submitCheckIn(context, pactId);
                        } else {
                          AwesomeSnackbarHelper.showError(context, 'Error', 'Pact ID missing.');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: _uploading ? const Color(0xFF6F98FF).withOpacity(0.7) : const Color(0xFF6F98FF),
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: Center(
                          child: _uploading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : FittedBox(
                                  child: Text(
                                    'Check-In',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: .5,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              flex: 60,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/check_pic.png',
                  fit: BoxFit.contain,
                  height: 20.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(ctx, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(ctx, file);
              },
            ),
          ],
        ),
      ),
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitCheckIn(BuildContext context, String pactId) async {
    // Remove focus from text field
    FocusScope.of(context).unfocus();
    
    if (_selectedImage == null) {
      AwesomeSnackbarHelper.showWarning(
        context,
        'Image Required',
        'Please select an image.',
      );
      return;
    }
    setState(() => _uploading = true);
    final provider = Provider.of<PactProvider>(context, listen: false);
    final result = await provider.checkInWithImage(
      pactId: pactId,
      imagePath: _selectedImage!.path,
      comment: _commentController.text,
    );
    setState(() => _uploading = false);
    if (result['success'] == true) {
      AwesomeSnackbarHelper.showSuccess(
        context,
        'Success',
        'Check-in uploaded successfully!',
      );
      setState(() {
        _selectedImage = null;
        _commentController.clear();
      });
      
      // Refresh today's check-ins list after successful check-in
      try {
        await provider.fetchTodayCheckins(pactId); // Refresh after check-in
      } catch (e) {
        // Log error but don't show it to user since check-in was successful
        print('Error refreshing check-ins: $e');
      }
    } else {
      AwesomeSnackbarHelper.showError(
        context,
        'Failed',
        result['error'] ?? 'Check-in failed.',
      );
    }
  }

  Widget _buildCheckInCard(BuildContext context, String pactId) {
    // Match countdownCard padding, margin, and radius
  return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      margin: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF377CFD),
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.10),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: InkWell(
              onTap: () => _pickImage(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, color: Color(0xFF377CFD)),
                  SizedBox(width: 2.w),
                  Text(
                    _selectedImage == null ? "Upload Here" : "Image Selected",
                    style: TextStyle(
                      color: Color(0xFF377CFD),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedImage != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preview Image:',
                  style: TextStyle(
                    color: Color(0xFF377CFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Image.file(_selectedImage!, height: 120),
            ),
          ],
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Add Comment (optional)",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          InkWell(
            borderRadius: BorderRadius.circular(4.w),
            onTap: _uploading
                ? null
                : () {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : '';
                    if (pactId.isNotEmpty) {
                      _submitCheckIn(context, pactId);
                    } else {
                      AwesomeSnackbarHelper.showError(context, 'Error', 'Pact ID missing.');
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6F98FF),
                border: Border.all(color: Colors.white, width: 1.8),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Center(
                child: _uploading
                    ? Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Text(
                        'Check-In',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: .5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 1.h),
      child: Container(
        width: double.infinity,
        height: 3.h,
        decoration: BoxDecoration(
          color: Color(0xFF377CFD),
          borderRadius: BorderRadius.circular(2.w), // Added border radius
        ),
        alignment: Alignment.center,
        child: Text(
          "Members",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required String status,
    required String statusType, // active, failed
    required String action,
    required Color statusColor,
    required Color actionColor,
    required String profileImage,
    String comment = '',
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.0.h, horizontal: 0.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.0.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 6.5.w,
                backgroundImage: AssetImage(profileImage),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.2.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        border: Border.all(
                          color: Color(0xFF377CFD),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        status[0].toUpperCase() + status.substring(1), // Capitalize first letter
                        style: TextStyle(
                          color: statusType == "approved"
                              ? Color(0xFF2E8701)
                              : statusType == "rejected"
                                  ? Color(0xFFC84E4F)
                              : Color(0xFFFFFFFF),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (comment.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        comment,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 0.w),
              InkWell(
                onTap: () {},

                child: Container(
                  width: 35.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures content fits tightly
                    children: [
                      Text(
                        action,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
        );
  }

  // Update _showMemberDetailSheet to accept all member data
  void _showMemberDetailSheet(BuildContext context, {
    required String name,
    required String profileImage,
    required String status,
    required String comment,
    required String mediaUrl,
    required bool verified,
    required String checkinId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GestureDetector(
                      onTap: () {
                        // Only open full screen if there's a media URL (check-in image)
                        if (mediaUrl.isNotEmpty) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                FullScreenImageViewer(
                                  imageUrl: mediaUrl,
                                  heroTag: 'checkin_image_$checkinId',
                                  isNetworkImage: true,
                                ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                              reverseTransitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        }
                      },
                      child: Hero(
                        tag: 'checkin_image_$checkinId',
                        child: mediaUrl.isNotEmpty
                            ? Stack(
                                children: [
                                  Image.network(
                                    mediaUrl,
                                    fit: BoxFit.cover,
                                    height: 340,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 340,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 340,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  // Overlay to indicate the image is clickable
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Image.asset(
                                profileImage,
                                fit: BoxFit.cover,
                                height: 340,
                                width: double.infinity,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (comment.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      comment,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 8),
                Text(
                  'Status: ${verified ? 'Verified' : status}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: verified ? Colors.green : Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _acceptLoading ? null : () async {
                            setState(() => _acceptLoading = true);
                            final provider = Provider.of<PactProvider>(context, listen: false);
                            final result = await provider.verifyCheckin(checkinId: checkinId, action: 'approve');
                            setState(() => _acceptLoading = false);
                            Navigator.of(context).pop();
                            if (result['success'] == true) {
                              AwesomeSnackbarHelper.showSuccess(
                                context,
                                'Approved',
                                'Check-in approved.',
                              );
                            } else {
                              AwesomeSnackbarHelper.showError(
                                context,
                                'Failed',
                                result['error'] ?? 'Failed to approve.',
                              );
                            }
                            // Refresh check-ins
                            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                            final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : '';
                            if (pactId.isNotEmpty) {
                              provider.fetchTodayCheckins(pactId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.green, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _acceptLoading 
                            ? Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                ),
                              )
                            : Text('ACCEPT', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _declineLoading ? null : () async {
                            setState(() => _declineLoading = true);
                            final provider = Provider.of<PactProvider>(context, listen: false);
                            final result = await provider.verifyCheckin(checkinId: checkinId, action: 'reject');
                            setState(() => _declineLoading = false);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: result['success'] == true ? 'Rejected' : 'Failed',
                                  message: result['success'] == true ? 'Check-in rejected.' : (result['error'] ?? 'Failed to reject.'),
                                  contentType: result['success'] == true ? ContentType.success : ContentType.failure,
                                ),
                              ),
                            );
                            // Refresh check-ins
                            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                            final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : '';
                            if (pactId.isNotEmpty) {
                              provider.fetchTodayCheckins(pactId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _declineLoading 
                            ? Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                ),
                              )
                            : Text('DECLINE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _geminiLoading ? null : () async {
                            setState(() => _geminiLoading = true);
                            final provider = Provider.of<PactProvider>(context, listen: false);
                            final result = await provider.autoVerifyCheckin(checkinId: checkinId);
                            setState(() => _geminiLoading = false);
                            
                            if (result['success']) {
                              Navigator.of(context).pop();

                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Success!',
                                  message: 'Check-in auto-verified successfully with Gemini AI',
                                  contentType: ContentType.success,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            } else {
                              // Handle specific Gemini API key error
                              String errorMessage = result['error'] ?? 'Failed to auto-verify check-in';
                              String title = 'Error!';
                              Navigator.of(context).pop();
                              if (errorMessage.contains('Gemini API key is not set') || 
                                  errorMessage.contains('API key') ||
                                  errorMessage.contains('not set')) {
                                title = 'Configuration Error';
                                errorMessage = 'Your Gemini API key is not set. Please set it in Settings to use auto-verify.';
                              }
                              
                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: title,
                                  message: errorMessage,
                                  contentType: ContentType.failure,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                            
                            // Refresh check-ins
                            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                            final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : '';
                            if (pactId.isNotEmpty) {
                              provider.fetchTodayCheckins(pactId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2563FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _geminiLoading 
                            ? Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            : Text('Process with Gemini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pactTitle = args != null && args['title'] != null ? args['title'] as String : 'Pact';
    final pactId = args != null && args['pactId'] != null ? args['pactId'] as String : (_pactId ?? '');
    final groupCode = args != null && args['groupCode'] != null ? args['groupCode'] as String : '';
    
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFFF5F8FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pactTitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (groupCode.isNotEmpty) ...[
                  SizedBox(width: 2.w),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: groupCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Copied!',
                            message: 'Group code copied to clipboard',
                            contentType: ContentType.success,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.black54,
                      size: 20.sp,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (groupCode.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteQrScreen(
                          joinCode: groupCode,
                          pactTitle: pactTitle,
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.share,
                  color: Colors.black,
                  size: 22.sp,
                ),
                tooltip: 'Invite members',
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              RefreshIndicator(
                onRefresh: _refreshData,
                color: const Color(0xFF1D61E7),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      // Next Check-in Due widget with reminder countdown
                      ValueListenableBuilder(
                        valueListenable: _reminderTimeStrNotifier,
                        builder: (context, String timeStr, _) {
                          return _countdownCard(timeStr, pactId);
                        },
                      ),
                      SizedBox(height: 2.0.h),
                      _buildCheckInCard(context, pactId),
                      SizedBox(height: 2.4.h),
                      _buildMembersHeader(),
                      Consumer<PactProvider>(
                        builder: (context, pactProvider, _) {
                          if (pactProvider.todayCheckinsLoading) {
                            // Shimmer for loading state
                            return Column(
                              children: List.generate(3, (i) => _buildMemberShimmer()),
                            );
                          }
                          final checkins = pactProvider.todayCheckins;
                          if (checkins == null || checkins.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Text('No check-ins found for today.', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                            );
                          }
                          return Column(
                            children: checkins.map<Widget>((checkin) {
                              final user = checkin['userId'];
                              final name = user is Map && user['name'] != null ? user['name'] : 'User';
                              final status = checkin['status'] ?? '';
                              final comment = checkin['comment'] ?? '';
                              final mediaUrl = checkin['mediaUrl'] ?? '';
                              final verified = (checkin['verifiedBy'] as List?)?.isNotEmpty == true;
                              // Use default profile image - no profile pictures in pact detail
                              final profileImage = 'assets/images/default_profile.jpg';
                              final isNetworkImage = false;
                              Color statusColor;
                              Color actionColor;
                              String actionText;
                              if (status == 'pending') {
                                statusColor = Color(0xFF6CA8FF);
                                actionColor = Color(0xFF6CA8FF);
                                actionText = verified ? 'Verified' : 'Pending';
                              } else if (status == 'reject') {
                                statusColor = Color(0xFFFFA2A3);
                                actionColor = Color(0xFFF47272);
                                actionText = 'Failed';
                              } else {
                                statusColor = Color(0xFF4AFFB3);
                                actionColor = Color(0xFF2ECC89);
                                actionText = 'Verified';
                              }
                              return _buildMemberTile(
                                name: name,
                                status: status,
                                statusType: status,
                                action: actionText,
                                statusColor: statusColor,
                                actionColor: actionColor,
                                profileImage: profileImage,
                                comment: comment,
                                onTap: () => _showMemberDetailSheet(
                                  context,
                                  name: name,
                                  profileImage: profileImage,
                                  status: status,
                                  comment: comment,
                                  mediaUrl: mediaUrl,
                                  verified: verified,
                                  checkinId: checkin['_id'] ?? '',
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              ),
              )],
          ),
        );
      },
    );
  }

  // Shimmer for member tile
  Widget _buildMemberShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 18,
                        color: Colors.grey[300],
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 50,
                        height: 18,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}