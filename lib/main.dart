import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone/state/auth/providers/is_logged_in_provider.dart';
import 'package:instagram_clone/views/components/constants/strings.dart';
import 'firebase_options.dart';

import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Consumer(
        builder: (context, ref, child) {
          final isLoggedIn = ref.watch(isLoggedInProvider);
          return isLoggedIn ? const MainView() : const LoginView();
        },
      ),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main View'),
        centerTitle: true,
      ),
      body: ProgressHUD(
        backgroundColor: Colors.white,
        indicatorColor: Colors.blueGrey,
        textStyle: const TextStyle(color: Colors.blueGrey, fontSize: 15),
        borderColor: Colors.black,
        child: Consumer(
          builder: (context, ref, child) {
            return TextButton(
              onPressed: () async {
                final progress = ProgressHUD.of(context)!;
                progress.showWithText(Strings.loading);
                await ref.read(authStateProvider.notifier).logOut();
                progress.dismiss();
              },
              child: const Text('Log Out!'),
            );
          },
        ),
      ),
    );
  }
}

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login View'),
        centerTitle: true,
      ),
      body: ProgressHUD(
        backgroundColor: Colors.white,
        indicatorColor: Colors.blueGrey,
        textStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Builder(builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  final progress = ProgressHUD.of(context);
                  progress?.showWithText(Strings.loading);
                  await ref.read(authStateProvider.notifier).loginWithGoogle();
                  progress?.dismiss();
                },
                child: const Text('Sign In with Google'),
              ),
              TextButton(
                onPressed: () async {
                  final progress = ProgressHUD.of(context);
                  progress?.showWithText(Strings.loading);
                  await ref
                      .read(authStateProvider.notifier)
                      .loginWithFacebook();
                  progress?.dismiss();
                },
                child: const Text('Sign In with Facebook'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
