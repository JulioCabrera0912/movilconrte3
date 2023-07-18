import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_auth/features/user/domain/usecases/sign_in_usecase.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_auth/features/user/domain/usecases/sign_in_usecase.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            const Text(
              'Inicia sesión',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 30),
            Image.asset(
              'assets/img/perfil.jpeg',
              width: 250,
              height: 250,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final signInUseCase = Provider.of<SignInWithGoogleUseCase>(
                    context,
                    listen: false);
                try {
                  final user = await signInUseCase.call();
                  if (user != null) {
                    Navigator.of(context).pushNamed('/chat');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Falló la autenticación con Google')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Ocurrió un error durante la autenticación: $e'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Iniciar sesión con Google',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
