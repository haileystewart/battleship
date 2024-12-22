// ignore_for_file: use_build_context_synchronously
import 'package:battleships/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/api/game_provider.dart';
import 'package:battleships/api/game_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const route = '/loginpage';

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    final username = _username.text;
    final password = _password.text;

    String errorMessage = '';

    if (username.length < 3) {
      errorMessage = 'Username has to be at least 3 characters long';
    }

    else if (username.contains(' ')) {
      errorMessage = 'Username cannot have spaces';
    } 

    else if (password.length < 3) {
      errorMessage = 'Password has to be at least 3 characters long';
    }

    else if (password.contains(' ')) {
      errorMessage = 'Password cannot have spaces';
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    setState(() { isLoading = true; });

    try {
      final gameAPI = GameAPI();
      final response = await gameAPI.login(username, password, false);
      final prefs = await SharedPreferences.getInstance();

      prefs.setString('user_name', username);
      prefs.setString('access_token', response.accessToken);

      // DEBUG helper
      // ignore: avoid_print
      print(response.accessToken);

      Provider.of<GameProvider>(context, listen: false).setUserName(username);
      Provider.of<GameProvider>(context, listen: false).setUserAccessToken(response.accessToken);
      Provider.of<GameProvider>(context, listen: false).setShowCompletedGamesList(true);

      setState(() { isLoading = false; });

      Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);
    }

    catch (e) {
      setState(() { isLoading = false; });

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception:')) {
        errorMessage = errorMessage.substring('Exception:'.length).trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> register(BuildContext context) async {
    final username = _username.text;
    final password = _password.text;

    String errorMessage = '';

    if (username.length < 3) {
      errorMessage = 'Username has to be at least 3 characters long';
    }

    else if (username.contains(' ')) {
      errorMessage = 'Username cannot have spaces';
    } 

    else if (password.length < 3) {
      errorMessage = 'Password has to be at least 3 characters long';
    }

    else if (password.contains(' ')) {
      errorMessage = 'Password cannot have spaces';
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    setState(() { isLoading = true; });

    try {
      final gameAPI = GameAPI();
      final response = await gameAPI.login(username, password, true);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', response.accessToken);

      Provider.of<GameProvider>(context, listen: false).setUserAccessToken(response.accessToken);

      setState(() { isLoading = false; });

      Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);

    } 

    catch (e) {
      setState(() { isLoading = false; });

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception:')) {
        errorMessage = errorMessage.substring('Exception:'.length).trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.sizeOf(context).width * 0.5,
          backgroundColor: Colors.grey[100],
          behavior: SnackBarBehavior.floating,

          content: Container(
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Please press again to exit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

      return Future.value(false);
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(title: const Center(child: Text('Login'))),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())

            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    TextField(
                      controller: _username,
                      decoration: const InputDecoration(
                        labelText: 'UserName',
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),

                    const SizedBox(height: 28.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: () => login(context), child: const Text('Login')),
                        TextButton(onPressed: () => register(context), child: const Text('Register')),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
