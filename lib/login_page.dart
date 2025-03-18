                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.email,
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
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: localizations.password,
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
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text(localizations.login),
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