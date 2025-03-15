import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:midterm_practice/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final (success, message) = await AuthService().login(
            email: _emailController.text, password: _passwordController.text);
        // Navigate to home screen after successful login
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (success, message, userCredential) =
          await AuthService().signInWithGoogle();
      final User? user = userCredential!.user;

      if (!mounted) return;

      if (success && user != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final additionalInfo = userCredential.additionalUserInfo;
          final bool isNewUser = additionalInfo?.isNewUser ?? false;

          // Show loading message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checking account details...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
          if (isNewUser) {
            // Redirect to Set Password screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/set-details',
                  arguments: user);
            }
          } else {
            // Existing user, go to Home Screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }
      } else if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (success, message, userCredential) =
          await AuthService().signInWithFacebook();
      final User? user = userCredential!.user;

      if (!mounted) return;

      if (success && user != null) {
        final additionalInfo = userCredential.additionalUserInfo;
        final bool isNewUser = additionalInfo?.isNewUser ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking account details...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );

        if (isNewUser) {
          Navigator.pushReplacementNamed(context, '/set-details',
              arguments: user);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGitHub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (success, message, userCredential) =
          await AuthService().signInWithGithub();
      final User? user = userCredential!.user;

      if (!mounted) return;

      if (success && user != null) {
        final additionalInfo = userCredential.additionalUserInfo;
        final bool isNewUser = additionalInfo?.isNewUser ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking account details...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );

        if (isNewUser) {
          Navigator.pushReplacementNamed(context, '/set-details',
              arguments: user);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Basic email validation
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: null,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Social Login Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Or sign in with:'),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 32,
                          color: Colors.green,
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.facebook,
                          size: 32,
                          color: Colors.blue,
                        ),
                        onPressed: _signInWithFacebook,
                      ),
                      IconButton(
                        icon: const Icon(
                          FontAwesome.github,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: _signInWithGitHub,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
