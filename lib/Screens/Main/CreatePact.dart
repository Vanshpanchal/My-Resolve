import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Utils/pact_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CreatePactScreen extends StatefulWidget {
  const CreatePactScreen({super.key});

  @override
  State<CreatePactScreen> createState() => _CreatePactScreenState();
}

class _CreatePactScreenState extends State<CreatePactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3.h),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabelText(label: "Title"),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _titleController,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Title required' : null,
                                decoration: InputDecoration(
                                  hintText: "PactName.",
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
                              ),
                              SizedBox(height: 2.5.h),
                              _LabelText(label: "Description"),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _descController,
                                maxLines: 2,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Description required' : null,
                                decoration: InputDecoration(
                                  hintText: "This is Pact.",
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
                              ),
                              SizedBox(height: 2.5.h),
                              _LabelText(label: "Total Days"),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _daysController,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Total days required';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1) return 'Enter a valid number';
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "45",
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
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          setState(() => _loading = true);
                                          final pactProvider = Provider.of<PactProvider>(context, listen: false);
                                          final res = await pactProvider.createPact(
                                            name: _titleController.text.trim(),
                                            description: _descController.text.trim(),
                                            totalDays: int.parse(_daysController.text.trim()),
                                          );
                                          setState(() => _loading = false);
                                          if (res['success'] == true) {
                                            final code = res['data']['groupCode'] ?? '';
                                            showDialog(
                                              context: context,
                                              builder: (context) => PactReadyDialog(code: code),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                elevation: 0,
                                                backgroundColor: Colors.transparent,
                                                content: AwesomeSnackbarContent(
                                                  title: 'Error',
                                                  message: res['error'] ?? 'Failed to create pact',
                                                  contentType: ContentType.failure,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  child: _loading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
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
              ),
            ],
          ),
        );
      },
    ));
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
                SizedBox(
                  height: size.height * 0.14,
                  child: Image.asset(
                    'assets/images/Join.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  "Your Pact is Ready!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.051,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.012),
                Text(
                  "No pact is complete without teammates.\nInvite them with this code!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: size.width * 0.04,
                  ),
                ),
                SizedBox(height: size.height * 0.025),
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
                      code.toUpperCase(),
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
                      // Copy code to clipboard (uppercase)
                      await Clipboard.setData(ClipboardData(text: code.toUpperCase()));

                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Copied!',
                          message: 'Invite code "${code.toUpperCase()}" copied to clipboard',
                          contentType: ContentType.success,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      // Pop dialogs/screens until back to DashboardScreen
                      int popCount = 0;
                      while (Navigator.of(context).canPop() && popCount < 3) {
                        Navigator.of(context).pop();
                        popCount++;
                        // Optionally, check if context is DashboardScreen
                        // but in most flows, 2 pops (dialog + create pact) is enough
                      }
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