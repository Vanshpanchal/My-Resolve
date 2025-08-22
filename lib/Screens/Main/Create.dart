import 'package:flutter/material.dart';
import 'package:myresolve/Screens/Main/CreatePact.dart';
import 'package:sizer/sizer.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Create or Join Pact",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 5.h),
                _ActionCard(
                  image: 'assets/images/Create.png',
                  buttonText: 'CREATE',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePactScreen()));
                  },
                ),
                SizedBox(height: 3.h),
                _ActionCard(
                  image: 'assets/images/Join.png',
                  buttonText: 'JOIN',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => JoinPactDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String image;
  final String buttonText;
  final VoidCallback onTap;

  const _ActionCard({
    required this.image,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90.w,
        height: 22.h,
        decoration: BoxDecoration(
          color: const Color(0xFF3B73FF),
          borderRadius: BorderRadius.circular(5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.w,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 15.h,
                width: 40.w,
                child: Image.asset(image, fit: BoxFit.contain),
              ),
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF6F98FF),
                    border: Border.all(color: Colors.white, width: 1.8),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.5.sp,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinPactDialog extends StatefulWidget {
  @override
  State<JoinPactDialog> createState() => _JoinPactDialogState();
}

class _JoinPactDialogState extends State<JoinPactDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
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
            maxHeight: size.height * 0.8, // never larger than 80% screen
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
              mainAxisSize: MainAxisSize.min, // shrink to content
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

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // keep tight
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image
                        SizedBox(
                          height: size.height * 0.18,
                          child: Image.asset(
                            'assets/images/Join.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // Title
                        Text(
                          "Join Pact",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.055,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.01),

                        // Subtext
                        Text(
                          "Stronger together.\nJoin a pact and grow with your team.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // TextField
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Paste Your Code",
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

                        // Button
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "JOIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.042,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
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
