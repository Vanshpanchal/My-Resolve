import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CreatePactScreen extends StatelessWidget {
  const CreatePactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Lets body extend behind app bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            // backgroundColor:,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Create Pact",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF2F6F9),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // Blue Card with illustration and text
                      Center(
                        child: Container(
                          width: 90.w,
                          padding: EdgeInsets.symmetric(
                            vertical: 2.5.h,
                            horizontal: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF3086FF),
                            borderRadius: BorderRadius.circular(5.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.w,
                                offset: Offset(0, 1.h),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 2.w),
                              SizedBox(
                                height: 15.h,
                                width: 35.w,
                                child: Image.asset(
                                  'assets/images/Create.png',
                                  // Replace with your asset
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  "Dream it.\nDefine it.\nDo it.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),
                      // Title field
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LabelText(label: "Title"),
                            SizedBox(height: 1.h),
                            _StyledTextField(
                              hint: "PactName.",
                              initialValue: "",
                            ),
                            SizedBox(height: 2.5.h),
                            _LabelText(label: "Description"),
                            SizedBox(height: 1.h),
                            _StyledTextField(
                              hint: "This is Pact.",
                              initialValue: "",
                              maxLines: 2,
                            ),
                            SizedBox(height: 4.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 2.0.h,
                                  ),
                                  backgroundColor: const Color(0xFF3086FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => PactReadyDialog(code: 'ABX123'),
                                  );
                                  // Action for create pact
                                },
                                child: Text(
                                  "Create Pact",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

class _LabelText extends StatelessWidget {
  final String label;

  const _LabelText({required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFEA3D3D),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String hint;
  final String initialValue;
  final int maxLines;

  const _StyledTextField({
    required this.hint,
    required this.initialValue,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: TextStyle(fontSize: 16.sp, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: Color(0xFF3086FF), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: Color(0xFF3086FF), width: 2),
        ),
      ),
    );
  }
}

class PactReadyDialog extends StatelessWidget {
  final String code;
  const PactReadyDialog({super.key, required this.code});

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
                // Close Button
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
                SizedBox(height: size.height * 0.01),
                // Image
                SizedBox(
                  height: size.height * 0.14,
                  child: Image.asset(
                    'assets/images/Join.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Title
                Text(
                  "Your Pact is Ready!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.051,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.012),
                // Subtext
                Text(
                  "No pact is complete without teammates.\nInvite them with this code!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: size.width * 0.04,
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                // Code Field (read-only)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.018,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF3086FF), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Copy Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.copy_rounded, color: Colors.white, size: size.width * 0.053),
                    label: Text(
                      "Copy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.043,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3086FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      // Copy code to clipboard
                      await Clipboard.setData(ClipboardData(text: code));

                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Copied!',
                          message: 'Invite code "$code" copied to clipboard',
                          contentType: ContentType.success,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      // Close dialog after copying
                      Navigator.of(context).pop();
                    },
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