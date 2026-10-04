import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_image_widget.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // HOMO brand colors
  static const Color _homoPurple = Color(0xFF6B21A8);
  static const Color _textPrimary = Color(0xFF0A0A0A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderDefault = Color(0xFFE5E7EB);
  static const Color _errorColor = Color(0xFFDC2626);

  // Demo OTP — development only, not shown in UI
  static const String _demoOtp = '123456';

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _errorMessage;
  bool _isLoading = false;
  int _resendCountdown = 30;
  bool _resendEnabled = false;
  String? _resendConfirmation;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 30;
    _resendEnabled = false;
    _resendConfirmation = null;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  void _onResend() {
    if (!_resendEnabled) return;
    setState(() {
      _resendConfirmation = 'A new code has been requested.';
      _errorMessage = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _startCountdown();
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _enteredOtp.length == 6;

  String _maskedPhone() {
    final raw = widget.phone.replaceAll(RegExp(r'\D'), '');
    if (raw.length == 10) {
      return '+91 ${raw.substring(0, 2)}••••${raw.substring(6)}';
    }
    return '+91 ••••• ••••';
  }

  void _onDigitChanged(int index, String value) {
    // Clear error on any change
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
    if (_resendConfirmation != null) {
      setState(() => _resendConfirmation = null);
    }

    if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
      setState(() {});
    } else if (value.isEmpty) {
      setState(() {});
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        setState(() {});
      }
    }
  }

  Future<void> _onPaste(String pasted) async {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[5].unfocus();
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _verify() async {
    if (!_isComplete || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate brief verification delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (_enteredOtp == _demoOtp) {
      context.go('/basic-details');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF0A0A0A),
                    ),
                    tooltip: 'Back to login',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // HOMO Logo
                      Center(
                        child: CustomImageWidget(
                          imageUrl: 'assets/images/img_app_logo.svg',
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Heading
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Verify your number',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter the 6-digit code sent to your mobile number.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Masked phone number
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _maskedPhone(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // OTP Input cells
                      _buildOtpInput(),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _errorColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Verify & Continue button
                      _buildVerifyButton(),

                      const SizedBox(height: 28),

                      // Resend section
                      _buildResendSection(),

                      const SizedBox(height: 40),
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

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return _OtpCell(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (val) => _onDigitChanged(index, val),
          onKeyEvent: (event) => _onKeyEvent(index, event),
          onPaste: _onPaste,
          hasError: _errorMessage != null,
          homoPurple: _homoPurple,
          borderDefault: _borderDefault,
          errorColor: _errorColor,
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final bool active = _isComplete && !_isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: active ? _verify : null,
        style: TextButton.styleFrom(
          backgroundColor: active
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF3F4F6),
          foregroundColor: active ? Colors.white : const Color(0xFFD1D5DB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: 0,
          splashFactory: NoSplash.splashFactory,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withAlpha(204),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Verifying...',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              )
            : Text(
                'Verify & Continue',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFFD1D5DB),
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (_resendConfirmation != null)
          Text(
            _resendConfirmation!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF059669),
            ),
          )
        else if (_resendEnabled)
          GestureDetector(
            onTap: _onResend,
            child: Text(
              'Resend code',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
                decoration: TextDecoration.underline,
                decorationColor: _textPrimary,
              ),
            ),
          )
        else
          Text(
            'Resend code in ${_resendCountdown}s',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
          ),
      ],
    );
  }
}

// Individual OTP cell widget
class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final Future<void> Function(String) onPaste;
  final bool hasError;
  final Color homoPurple;
  final Color borderDefault;
  final Color errorColor;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.onPaste,
    required this.hasError,
    required this.homoPurple,
    required this.borderDefault,
    required this.errorColor,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = widget.focusNode.hasFocus);
      }
    });
  }

  Color get _borderColor {
    if (widget.hasError) return widget.errorColor;
    if (_isFocused) return const Color(0xFF0A0A0A);
    if (widget.controller.text.isNotEmpty) return const Color(0xFFD1D5DB);
    return widget.borderDefault;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKeyEvent,
      child: SizedBox(
        width: 46,
        height: 52,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A0A0A),
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _isFocused ? const Color(0xFF0A0A0A) : _borderColor,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (val) {
            // Handle paste of full OTP
            if (val.length > 1) {
              widget.onPaste(val);
              return;
            }
            widget.onChanged(val);
          },
          onTap: () {
            // Select all text on tap so digit can be replaced
            widget.controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.controller.text.length,
            );
          },
        ),
      ),
    );
  }
}