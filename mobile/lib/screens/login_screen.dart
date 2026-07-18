// ============================================================
//  lib/screens/login_screen.dart
//  Aura Diet Planner — Login / Sign-Up
//  Volcanic Cyberpunk Auth Gate
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  // Email form state and controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();

    // Listen for auth errors
    AuthService.instance.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    final err = AuthService.instance.error;
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AuraColors.error.withAlpha(220),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    AuthService.instance.removeListener(_onAuthChange);
    super.dispose();
  }

  bool get _loading =>
      AuthService.instance.state == AuthState.loading;

  void _submitEmailForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      if (_isSignUp) {
        await AuthService.instance.signUpWithEmail(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await AuthService.instance.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
    }
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignUp) ...[
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AuraColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'DISPLAY NAME',
                hintText: 'e.g. John Doe',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AuraColors.textSecondary),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: AuraColors.textPrimary),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'EMAIL ADDRESS',
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.email_outlined, color: AuraColors.textSecondary),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(val.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: AuraColors.textPrimary),
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PASSWORD',
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AuraColors.textSecondary),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter your password';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          GestureDetector(
            onTap: _loading ? null : _submitEmailForm,
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: voltButton(radius: 12),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Toggle Mode
          TextButton(
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
                _formKey.currentState?.reset();
              });
            },
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : 'New to Aura? Create an account',
              style: const TextStyle(
                color: AuraColors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (_, __) => Scaffold(
        backgroundColor: AuraColors.bg,
        body: Stack(
          children: [
            // Background glow
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AuraColors.orange.withAlpha(35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AuraColors.amber.withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 52),

                          // Brand mark with back button
                          Row(
                            children: [
                              if (_showEmailForm) ...[
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                      color: AuraColors.orange, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _showEmailForm = false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                              ],
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AuraGradients.brand,
                                  borderRadius: BorderRadius.circular(13),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AuraColors.orange.withAlpha(120),
                                      blurRadius: 18,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.black,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AURA',
                                    style: AuraText.display(
                                            size: 20, weight: FontWeight.w900)
                                        .copyWith(letterSpacing: 3),
                                  ),
                                  Text(
                                    'Diet Planner',
                                    style: AuraText.body(
                                        size: 11,
                                        color: AuraColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 52),

                          // Headline
                          if (!_showEmailForm) ...[
                            Text(
                              'Fuel your\npotential.',
                              style: AuraText.display(
                                  size: 38, weight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Precision nutrition plans engineered\nfor elite performance.',
                              style: AuraText.body(size: 14),
                            ),
                          ] else ...[
                            Text(
                              _isSignUp ? 'Create\nAccount.' : 'Welcome\nBack.',
                              style: AuraText.display(
                                  size: 38, weight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isSignUp
                                  ? 'Register below to engine your nutrition.'
                                  : 'Access your elite performance profiles.',
                              style: AuraText.body(size: 14),
                            ),
                          ],

                          const SizedBox(height: 48),

                          // Auth buttons / form
                          if (!_showEmailForm) ...[
                            Column(
                              children: [
                                // Google
                                _AuthButton(
                                  loading: _loading,
                                  icon: _GoogleIcon(),
                                  label: 'Continue with Google',
                                  bgColor: Colors.white,
                                  fgColor: const Color(0xFF1F1F1F),
                                  onTap: _loading
                                      ? null
                                      : () async => AuthService.instance
                                          .signInWithGoogle(),
                                ),
                                const SizedBox(height: 12),

                                // Apple
                                _AuthButton(
                                  loading: _loading,
                                  icon: const Icon(Icons.apple_rounded,
                                      color: Colors.white, size: 22),
                                  label: 'Continue with Apple',
                                  bgColor: const Color(0xFF1C1C1E),
                                  fgColor: Colors.white,
                                  border: true,
                                  onTap: _loading
                                      ? null
                                      : () async => AuthService.instance
                                          .signInWithApple(),
                                ),
                                const SizedBox(height: 12),

                                // Email
                                _AuthButton(
                                  loading: _loading,
                                  icon: const Icon(Icons.email_rounded,
                                      color: AuraColors.textPrimary, size: 20),
                                  label: 'Continue with Email',
                                  bgColor: AuraColors.bgCard,
                                  fgColor: AuraColors.textPrimary,
                                  border: true,
                                  onTap: _loading
                                      ? null
                                      : () => setState(() {
                                            _showEmailForm = true;
                                            _isSignUp = false;
                                          }),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildEmailForm(),
                          ],

                          const SizedBox(height: 32),

                          // Terms
                          Center(
                            child: Text(
                              'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: AuraText.body(
                                  size: 11, color: AuraColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Full-screen loading overlay
            if (_loading)
              Container(
                color: AuraColors.bg.withAlpha(160),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: AuraColors.orange, strokeWidth: 2.5),
                      SizedBox(height: 16),
                      Text('Signing in...',
                          style: TextStyle(
                              color: AuraColors.textSecondary,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Auth button ────────────────────────────────────────────────────
class _AuthButton extends StatefulWidget {
  final bool loading;
  final Widget icon;
  final String label;
  final Color bgColor;
  final Color fgColor;
  final bool border;
  final VoidCallback? onTap;

  const _AuthButton({
    required this.loading,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
    this.border = false,
    this.onTap,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.bgColor
                .withAlpha(_pressed ? 220 : 255),
            borderRadius: BorderRadius.circular(12),
            border: widget.border
                ? Border.all(color: AuraColors.border, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 22, height: 22, child: widget.icon),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.fgColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Google 'G' icon ───────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r      = size.width / 2;

    // Red arc (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      _deg(-225), _deg(100),
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );

    // Blue arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      _deg(-125), _deg(100),
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );

    // Yellow arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      _deg(-25), _deg(110),
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );

    // Green arm
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width, center.dy),
      Paint()
        ..color = const Color(0xFF34A853)
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );
  }

  double _deg(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(_) => false;
}
