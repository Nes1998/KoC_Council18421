import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koc_council_website/firebase/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(const LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text('Please login your credentials below'),
      ),
      body: const Center(
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String emailVal = '';
  String passwordVal = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void setEmailVal(String value) {
    setState(() {
      emailVal = value;
    });
  }

  void setPasswordVal(String value) {
    setState(() {
      passwordVal = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: () => {Navigator.pushNamed(context, '/')},
              child: const Text('Go back to the home page')),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => setEmailVal(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (value) => setPasswordVal(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Process login
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: emailVal,
                  password: passwordVal,
                )
                    .then((value) {
                  // Handle successful login
                }).catchError((error) {
                  // Handle login error
                });
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
