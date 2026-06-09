import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'analytics_service.dart';
import 'product_model.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  final String? nextRoute;
  final Product? product;

  const LoginScreen({super.key, this.nextRoute, this.product});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── SHA-256 helper ──────────────────────────────────
  String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await AnalyticsService.logLogin();
      if (cred.user != null) {
        await AnalyticsService.setUserId(_sha256(cred.user!.uid));
      }
      if (!mounted) return;
      _navigateAfterAuth();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await AnalyticsService.logSignUp();
      if (cred.user != null) {
        await AnalyticsService.setUserId(_sha256(cred.user!.uid));
      }
      if (!mounted) return;
      _navigateAfterAuth();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateAfterAuth() {
    if (widget.nextRoute != null) {
      if (widget.nextRoute == '/checkout' && widget.product != null) {
        Navigator.pushReplacementNamed(context, '/checkout',
            arguments: widget.product);
      } else {
        Navigator.pushReplacementNamed(context, widget.nextRoute!);
      }
    } else {
      Navigator.pop(context);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Logo ─────────────────────────────────
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: HolaflyTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('H',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tab bar ──────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: HolaflyTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: HolaflyTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: HolaflyTheme.textSecondary,
                    labelStyle: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Register'),
                    ],
                    onTap: (_) => setState(() => _errorMessage = null),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Email field ──────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),

                // ── Password field ───────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),

                // ── Confirm password (register only) ─────
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _tabController.index == 1
                      ? Column(
                          children: [
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Error message ─────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HolaflyTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: HolaflyTheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: HolaflyTheme.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: HolaflyTheme.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── CTA button ────────────────────────────
                ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) {
                    final isLogin = _tabController.index == 0;
                    return ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (isLogin ? _login : _register),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(isLogin ? 'Login' : 'Create account'),
                    );
                  },
                ),

                if (_tabController.index == 0) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?',
                          style: TextStyle(color: HolaflyTheme.textSecondary)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}