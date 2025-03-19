import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/app_signature.dart';
import 'package:animate_do/animate_do.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import 'main.dart';
import 'font_size_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _passwordFocusNode = FocusNode();

  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showFirebaseSetupInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Firebase Setup Instructions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To enable Google Sign-In, you need to add your SHA-1 certificate fingerprint to your Firebase project:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('1. Go to Firebase Console'),
              Text('2. Select your project'),
              Text('3. Go to Project Settings > Your apps'),
              Text('4. Add the SHA-1 certificate fingerprint'),
              SizedBox(height: 16),
              Text(
                'To get your SHA-1 certificate on Windows:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Option 1: Using Android Studio (Recommended):'),
              Text('1. Open this project in Android Studio'),
              Text('2. Click on "Gradle" in the right sidebar'),
              Text('3. Navigate to Tasks > android > signingReport'),
              Text('4. Double-click on signingReport'),
              Text('5. Look for SHA1 in the output window'),
              SizedBox(height: 12),
              Text('Option 2: Using Command Prompt:'),
              Text('First navigate to your .android folder:'),
              SelectableText('cd %USERPROFILE%\\.android'),
              Text('Then run this command (copy and paste it):'),
              SelectableText('"C:\\Program Files\\Android\\Android Studio\\jbr\\bin\\keytool" -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android'),
              SizedBox(height: 16),
              Text(
                'Example SHA-1 fingerprint format:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText('5E:8F:16:06:2E:A3:CD:2C:4A:0D:54:78:76:BA:A6:F3:8C:AB:F6:25'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => BottomNavBar(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      
      if (e is FirebaseAuthException && e.code == 'ERROR_ABORTED_BY_USER') {
        // User canceled the sign-in, don't show an error
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Google. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final baseFontSize = fontSizeProvider.fontSize;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.pink.shade900,
                              Colors.deepPurple.shade900,
                            ]
                          : [
                              Colors.pink.shade100,
                              Colors.deepPurple.shade100,
                            ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/icons/WSA_logo.png',
                          height: 100,
                          width: 100,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Welcome text
                      Text(
                        l10n.welcomeToWSA,
                        style: TextStyle(
                          fontSize: baseFontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        l10n.welcomeMessage,
                        style: TextStyle(
                          fontSize: baseFontSize * 1.1,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      // Email input
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          prefixIcon: const Icon(Icons.email),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.alternate_email),
                            onPressed: () {
                              if (!_emailController.text.contains('@')) {
                                _emailController.text = '${_emailController.text}@gmail.com';
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onEditingComplete: () {
                          if (!_emailController.text.contains('@')) {
                            _emailController.text = '${_emailController.text}@gmail.com';
                          }
                        },
                        onSubmitted: (_) {
                          if (!_emailController.text.contains('@')) {
                            _emailController.text = '${_emailController.text}@gmail.com';
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password input
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        onTap: () {
                          if (!_emailController.text.contains('@')) {
                            _emailController.text = '${_emailController.text}@gmail.com';
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: Text(l10n.login),
                      ),
                      SizedBox(height: 12),
                      // Forgot password
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                            fontSize: baseFontSize * 0.9,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: TextStyle(
                              fontSize: baseFontSize * 0.9,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              l10n.signUp,
                              style: TextStyle(
                                fontSize: baseFontSize * 0.9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Google sign in button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Image.asset(
                          'assets/icons/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          l10n.signInWithGoogle,
                          style: TextStyle(
                            fontSize: baseFontSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
    );
  }

  Future<void> _handleLogin() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (userCredential.user != null) {
        // Return success value to previous page
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 