import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:myresolve/Utils/pact_provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ScanInviteScreen extends StatefulWidget {
  const ScanInviteScreen({Key? key}) : super(key: key);

  @override
  State<ScanInviteScreen> createState() => _ScanInviteScreenState();
}

class _ScanInviteScreenState extends State<ScanInviteScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool joining = false;
  bool hasScanned = false;

  // Extract joinCode from scanned string
  String? _extractJoinCode(String raw) {
    try {
      final uri = Uri.tryParse(raw);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        // if url like .../api/pacts/join/<joinCode>
        final last = uri.pathSegments.last;
        if (last.isNotEmpty && last != 'join') return last;
      }
      // fallback: look for token= or code= param
      final tokenParam = uri?.queryParameters['token'] ?? uri?.queryParameters['code'];
      if (tokenParam != null && tokenParam.isNotEmpty) return tokenParam;
    } catch (_) {}
    // if raw is plain code (no url structure)
    if (raw.trim().isNotEmpty && !raw.contains('http')) return raw.trim();
    return null;
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (hasScanned || joining) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final raw = barcodes.first.rawValue;
    if (raw == null) return;
    
    hasScanned = true;
    controller.stop();
    
    final joinCode = _extractJoinCode(raw);
    if (joinCode == null) {
      _showError('Invalid invite code or QR');
      hasScanned = false;
      controller.start();
      return;
    }
    
    await _joinPact(joinCode);
  }

  Future<void> _joinPact(String joinCode) async {
    setState(() => joining = true);
    
    final provider = Provider.of<PactProvider>(context, listen: false);
    try {
      final success = await provider.joinPact(joinCode);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'You have successfully joined the pact',
                contentType: ContentType.success,
              ),
            ),
          );
          // Wait a bit before popping to show the success message
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
          return;
        } else {
          final err = provider.error ?? 'Failed to join pact';
          _showError(err);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          joining = false;
          hasScanned = false;
        });
        controller.start();
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: message,
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Scan Invite QR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // QR Scanner View
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          
          // Custom overlay with scanning area
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF1D61E7),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          // Dark overlay outside scanning area
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Instructions overlay at top
          Positioned(
            top: 12.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Position QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (joining)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D61E7)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Joining pact...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Manual entry button at bottom
          Positioned(
            bottom: 4.h,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Enter Code Manually'),
                onPressed: () {
                  controller.stop();
                  _showManualEntryDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D61E7),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Invite Code'),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            hintText: 'Paste or enter code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.vpn_key),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.start();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              Navigator.pop(context);
              if (code.isNotEmpty) {
                final joinCode = _extractJoinCode(code);
                if (joinCode != null) {
                  _joinPact(joinCode);
                } else {
                  _showError('Invalid invite code');
                  controller.start();
                }
              } else {
                controller.start();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D61E7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
