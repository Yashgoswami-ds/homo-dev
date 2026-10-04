import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  String? _errorMessage;
  bool _isFocused = false;
  bool _isLoading = false;

  // HOMO brand colors — restrained palette
  static const Color _homoPurple = Color(0xFF6B21A8);
  static const Color _textPrimary = Color(0xFF0A0A0A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderDefault = Color(0xFFE5E7EB);
  static const Color _errorColor = Color(0xFFDC2626);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _normalizePhone(String input) {
    String normalized = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.startsWith('+91')) {
      normalized = normalized.substring(3);
    } else if (normalized.startsWith('91') && normalized.length == 12) {
      normalized = normalized.substring(2);
    }
    return normalized;
  }

  bool _isValidIndianMobile(String normalized) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(normalized);
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _errorMessage = null;
    });
  }

  bool get _canContinue {
    final normalized = _normalizePhone(_phoneController.text.trim());
    return _isValidIndianMobile(normalized);
  }

  void _onContinue() async {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorMessage = 'Please enter your mobile number');
      return;
    }
    final normalized = _normalizePhone(raw);
    if (!_isValidIndianMobile(normalized)) {
      setState(
        () => _errorMessage = 'Please enter a valid 10-digit mobile number',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.push('/otp', extra: {'phone': normalized});
  }

  void _onGoogleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Google sign-in will be available soon.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onAppleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Apple sign-in will be available soon.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48),
                        _buildLogo(),
                        const SizedBox(height: 40),
                        _buildHeadline(),
                        const SizedBox(height: 28),
                        _buildPhoneField(),
                        const SizedBox(height: 14),
                        _buildContinueButton(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildSocialButtons(),
                        const Spacer(),
                        const SizedBox(height: 24),
                        _buildTerms(),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/file_00000000e5948211bc47ef13abd7a14f-1791057025212.jpg',
        height: 52,
        fit: BoxFit.contain,
        semanticLabel: 'HOMO official logo',
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to HOMO',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your trusted platform for human services.',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final bool hasError = _errorMessage != null && _errorMessage!.isNotEmpty;

    Color borderColor;
    if (hasError) {
      borderColor = _errorColor;
    } else if (_isFocused) {
      borderColor = _homoPurple;
    } else {
      borderColor = _borderDefault;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              // Country code prefix
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇮🇳', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '+91',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical divider
              Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: _onPhoneChanged,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Mobile number',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFFBBBBBB),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error message — only shown when error exists
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 13, color: _errorColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _errorColor,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    final bool enabled = _canContinue && !_isLoading;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFE5E7EB),
          foregroundColor: enabled ? Colors.white : const Color(0xFFAAAAAA),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: enabled ? Colors.white : const Color(0xFFAAAAAA),
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFE8E8E8), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAAAAA),
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFE8E8E8), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _SocialButton(
          onTap: _onGoogleTap,
          icon: const _GoogleIcon(),
          label: 'Continue with Google',
        ),
        const SizedBox(height: 12),
        _SocialButton(
          onTap: _onAppleTap,
          icon: const Icon(Icons.apple, size: 18, color: Color(0xFF0A0A0A)),
          label: 'Continue with Apple',
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
            height: 1.6,
          ),
          children: [
            const TextSpan(text: "By continuing, you agree to HOMO's "),
            TextSpan(
              text: 'Terms of Service',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _homoPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _homoPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

// Social button widget
class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A0A0A),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 18, height: 18, child: icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google "G" icon drawn with canvas
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleIconPainter());
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78);

    canvas.drawArc(rect, -0.3, 1.6, false, paintBlue);
    canvas.drawArc(rect, 1.3, 1.2, false, paintYellow);
    canvas.drawArc(rect, 2.5, 1.0, false, paintGreen);
    canvas.drawArc(rect, 3.5, 1.1, false, paintRed);

    final paintBar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.72, cy), paintBar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
