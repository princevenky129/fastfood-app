import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';

class ShopQrDialog extends StatefulWidget {
  const ShopQrDialog({super.key});

  @override
  State<ShopQrDialog> createState() => _ShopQrDialogState();
}

class _ShopQrDialogState extends State<ShopQrDialog> {
  int _qrModeIndex = 0; // 0 = Customer Menu Web QR, 1 = UPI Payment QR

  static const String upiId = '8904629757@ptyes';
  static const String shopName = 'FastFood Counter #1';

  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: 'https://web-nu-umber-54.vercel.app');
    _urlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String get _currentQrPayload {
    if (_qrModeIndex == 0) {
      final text = _urlController.text.trim();
      return text.isEmpty ? 'https://fastfood-menu.vercel.app' : text;
    }
    return 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(shopName)}&cu=INR';
  }

  @override
  Widget build(BuildContext context) {
    final isMenuQr = _qrModeIndex == 0;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandRed, AppColors.brandOrange],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop QR Code',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        isMenuQr
                            ? 'Scannable Website QR Code'
                            : 'UPI Payment Transfer QR',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceWarm,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mode Selector Pill Tabs (Web QR vs UPI Pay QR)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _qrModeIndex = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isMenuQr ? AppColors.brandRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '📱 Menu Website QR',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isMenuQr ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _qrModeIndex = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isMenuQr ? AppColors.brandOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '💳 UPI Pay QR',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: !isMenuQr ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scannable QR Code Card Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isMenuQr ? AppColors.brandRed : AppColors.brandOrange,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMenuQr ? AppColors.brandRed : AppColors.brandOrange)
                        .withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // QR Image Generator
                  QrImageView(
                    key: ValueKey(_currentQrPayload),
                    data: _currentQrPayload,
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: isMenuQr ? AppColors.brandRed : AppColors.brandOrange,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    shopName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Data Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMenuQr
                              ? Icons.language_rounded
                              : Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: isMenuQr ? AppColors.brandRed : AppColors.brandOrange,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isMenuQr ? _currentQrPayload : upiId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isMenuQr ? AppColors.brandRed : AppColors.brandOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Edit Web Link Section
            if (isMenuQr) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Your Deployed Vercel / Render Website URL',
                  labelStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.brandRed),
                  hintText: 'https://your-app.vercel.app',
                  hintStyle: GoogleFonts.inter(color: AppColors.textFaint, fontSize: 12),
                  fillColor: AppColors.surfaceWarm,
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.brandRed, size: 18),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Instruction Label
            Text(
              isMenuQr
                  ? 'Scan with Google Lens or Phone Camera to open your deployed shop website menu.'
                  : 'Scan with PhonePe, GPay, or Paytm to pay directly via UPI ID $upiId.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
