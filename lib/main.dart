import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:womensafety/laws_page.dart';
import 'package:womensafety/map.dart';
import 'package:womensafety/news_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'otherservices.dart';
import 'notification_page.dart';
import 'contacts_page.dart';
import 'self_defense_videos.dart';
import 'settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'sos_settings_provider.dart';
import 'font_size_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    final prefs = await SharedPreferences.getInstance();
    print('SharedPreferences initialized');
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => SOSSettingsProvider()),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          Provider<AuthService>(create: (_) => AuthService(prefs)),
        ],
        child: MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error initializing app. Please try again later.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Error details: $e',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer4<ThemeProvider, LanguageProvider, FontSizeProvider, AuthService>(
      builder: (context, themeProvider, languageProvider, fontSizeProvider, authService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Women Safety App',
          locale: languageProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'), // English
            Locale('hi'), // Hindi
            Locale('es'), // Spanish
            Locale('fr'), // French
            Locale('ar'), // Arabic
            Locale('ta'), // Tamil
          ],
          theme: ThemeData(
            primarySwatch: Colors.pink,
            textTheme: GoogleFonts.poppinsTextTheme().copyWith(
              bodyLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
              bodyMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
              bodySmall: TextStyle(fontSize: fontSizeProvider.fontSize),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.pinkAccent),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.pink,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
              bodyLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
              bodyMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
              bodySmall: TextStyle(fontSize: fontSizeProvider.fontSize),
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.pink,
              brightness: Brightness.dark,
            ).copyWith(secondary: Colors.pinkAccent),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Color(0xFF121212),
            cardColor: Color(0xFF1E1E1E),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Colors.pinkAccent,
              unselectedItemColor: Colors.grey,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.pinkAccent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pinkAccent),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.pinkAccent,
              contentTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 20),
                  Text(
                    'Error loading app. Please try again.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return BottomNavBar();
        }

        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
    usernameController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          focusNode: labelText == 'Password' ? _passwordFocusNode : null,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            filled: true,
            fillColor: isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pinkAccent),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return labelText == 'Email' ? l10n.pleaseEnterEmail : l10n.pleaseEnterPassword;
            }
            if (labelText == 'Email' && !value.contains('@')) {
              return l10n.invalidEmailFormat;
            }
            return null;
          },
          onFieldSubmitted: (value) {
            if (labelText == 'Email') {
              FocusScope.of(context).nextFocus();
              _passwordFocusNode.requestFocus();
            } else if (labelText == 'Password') {
              login();
            }
          },
        );
      },
    );
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save login credentials for auto-login
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.saveLoginCredentials(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );

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
      } on FirebaseAuthException catch (e) {
        final l10n = AppLocalizations.of(context)!;
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = l10n.userNotFound;
            break;
          case 'wrong-password':
            message = l10n.wrongPassword;
            break;
          case 'invalid-email':
            message = l10n.invalidEmail;
            break;
          case 'user-disabled':
            message = 'This account has been disabled';
            break;
          default:
            message = l10n.errorLoading;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.tryAgain,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ),
        );
      } catch (e) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoading),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n.tryAgain,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.pinkAccent.withOpacity(0.4), Colors.deepPurple.shade900]
                        : [Colors.pinkAccent.withOpacity(0.7), Colors.deepPurple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          Center(
            child: FadeInUp(
              duration: Duration(seconds: 1),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/WSA_logo.png',
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Text(
                        l10n.welcomeMessage,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        l10n.safetyMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.white70,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildTextField(usernameController, l10n.email),
                      SizedBox(height: 15),
                      _buildTextField(passwordController, l10n.password, obscureText: true),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.white70),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        onPressed: _isLoading ? null : login,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(l10n.login, style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text(
                          l10n.signUp,
                          style: TextStyle(color: isDark ? Colors.white : Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LandingPage(),
    ContactsPage(),
    OtherServicesWidget(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: l10n.contacts),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: l10n.services),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: l10n.settings),
        ],
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  Future<void> _handleSOS(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final sosSettings = Provider.of<SOSSettingsProvider>(context, listen: false);
    
    // Show confirmation dialog with a timeout
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto-proceed after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        });
        
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AlertDialog(
            title: Text(
              '🚨 EMERGENCY SOS',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Sending emergency alerts to your contacts and emergency services...',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Proceed', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );

    if (shouldProceed == true) {
      try {
        // Start all emergency actions simultaneously
        List<Future<void>> emergencyActions = [];

        // Share location with emergency contacts
        emergencyActions.add(ContactsPage.sendLocation(context));

        // Call police if enabled
        if (sosSettings.policeCallEnabled) {
          emergencyActions.add(
            launchUrl(
              Uri.parse('tel:100'),
              mode: LaunchMode.externalApplication,
            ),
          );
        }

        // Wait for all actions to complete with a timeout
        await Future.wait(
          emergencyActions,
          eagerError: false,
        ).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            // Even if some actions fail, we don't want to block the SOS process
            return <void>[];
          },
        );

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Emergency alerts sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // In emergency situations, we don't want to show errors to the user
        // Just continue with the SOS process
        print('Error in _handleSOS: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark 
                  ? [Colors.pinkAccent.withOpacity(0.2), Colors.deepPurple.withOpacity(0.4)]
                  : [Colors.pinkAccent.withOpacity(0.3), Colors.deepPurple.withOpacity(0.8)],
              center: Alignment.center,
              radius: 1.2,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // First Row of Buttons
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _buildGridButton(Icons.map, l10n.mapAndReviews, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
                        }),
                        _buildGridButton(Icons.shield, l10n.selfDefense, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SelfDefenseVideos()));
                        }),
                      ],
                    ),

                    // SOS Emergency Button
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: FloatingActionButton.extended(
                        onPressed: () => _handleSOS(context),
                        icon: Icon(Icons.warning, color: Colors.white),
                        label: Text(l10n.sosEmergency, style: TextStyle(fontSize: 18, color: Colors.white)),
                        backgroundColor: Colors.red,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Second Row of Buttons
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _buildGridButton(Icons.article, l10n.newsAndArticles, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
                        }),
                        _buildGridButton(Icons.gavel, l10n.welfareLaws, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LawsPage()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build grid buttons
  Widget _buildGridButton(IconData icon, String text, VoidCallback onPressed) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Container(
              width: 150,
              height: 150,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: isDark 
                            ? [Colors.pinkAccent.withOpacity(0.8), Colors.deepPurpleAccent.withOpacity(0.8)]
                            : [Colors.pinkAccent, Colors.deepPurpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(
                      icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

