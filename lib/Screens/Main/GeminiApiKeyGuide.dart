import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class GeminiApiKeyGuide extends StatelessWidget {
  const GeminiApiKeyGuide({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F8FB),
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
        title: Text(
          'Get Gemini API Key',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction Card
                  _buildInfoCard(
                    title: 'What is Gemini API?',
                    description:
                        'Gemini API is Google\'s AI service that powers intelligent features in MyResolve, including automatic check-in verification using image analysis.',
                    icon: Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 2.h),

                  // Steps Header
                  Text(
                    'How to Get Your API Key',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Step 1
                  _buildStepCard(
                    stepNumber: '1',
                    title: 'Visit Google AI Studio',
                    description:
                        'Open your browser and go to Google AI Studio to create your API key.',
                    actionText: 'Open AI Studio',
                    onActionTap: () => _launchURL('https://aistudio.google.com/app/apikey'),
                    icon: Icons.launch,
                  ),
                  SizedBox(height: 2.h),

                  // Step 2
                  _buildStepCard(
                    stepNumber: '2',
                    title: 'Sign in with Google',
                    description:
                        'Log in using your Google account. If you don\'t have one, create a new Google account.',
                    icon: Icons.account_circle_outlined,
                  ),
                  SizedBox(height: 2.h),

                  // Step 3
                  _buildStepCard(
                    stepNumber: '3',
                    title: 'Create API Key',
                    description:
                        'Click on "Get API Key" or "Create API Key" button. You may need to accept the terms of service.',
                    icon: Icons.key_outlined,
                  ),
                  SizedBox(height: 2.h),

                  // Step 4
                  _buildStepCard(
                    stepNumber: '4',
                    title: 'Copy Your API Key',
                    description:
                        'Once generated, copy the API key. Keep it secure and don\'t share it publicly.',
                    icon: Icons.content_copy_outlined,
                  ),
                  SizedBox(height: 2.h),

                  // Step 5
                  _buildStepCard(
                    stepNumber: '5',
                    title: 'Paste in MyResolve',
                    description:
                        'Go back to Settings > Setup Gemini API Key and paste your key in the input field.',
                    icon: Icons.paste_outlined,
                  ),
                  SizedBox(height: 3.h),

                  // Important Notes Card
                  _buildInfoCard(
                    title: 'Important Notes',
                    description:
                        '• Keep your API key private and secure\n'
                        '• Free tier has usage limits\n'
                        '• You can regenerate keys anytime\n'
                        '• API key is stored securely on your device',
                    icon: Icons.security_outlined,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 2.h),

                  // Help Card
                  _buildInfoCard(
                    title: 'Need More Help?',
                    description:
                        'Visit Google AI Studio documentation for detailed instructions and troubleshooting.',
                    icon: Icons.help_outline,
                    color: Colors.green,
                    actionText: 'View Documentation',
                    onActionTap: () => _launchURL('https://ai.google.dev/gemini-api/docs'),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Circle
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D61E7), Color(0xFF4A90E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D61E7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF1D61E7),
                      size: 20.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                if (actionText != null && onActionTap != null) ...[
                  SizedBox(height: 1.5.h),
                  ElevatedButton.icon(
                    onPressed: onActionTap,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(actionText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D61E7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (actionText != null && onActionTap != null) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(actionText),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
