// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone/utils/loading_dialog.dart';
import 'package:instagram_clone/views/components/constants/strings.dart' as str;
import 'package:instagram_clone/views/constants/app_colors.dart';
import 'package:instagram_clone/views/constants/strings.dart';
import 'package:instagram_clone/views/login/divider_with_margins.dart';
import 'package:instagram_clone/views/login/facebook_button.dart';
import 'package:instagram_clone/views/login/google_button.dart';
import 'package:instagram_clone/views/login/login_view_signup_links.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    Strings.welcomeToAppName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const DividerWithMargins(),
                  Text(
                    Strings.logIntoYourAccount,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(height: 1.5),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.loginButtonColor,
                      foregroundColor: AppColors.loginButtonTextColor,
                    ),
                    onPressed: () async {
                      loadingScrean(context, str.Strings.loading);
                      await ref
                          .read(authStateProvider.notifier)
                          .loginWithFacebook();
                      Navigator.of(context).pop();
                    },
                    child: const FacebookButton(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.loginButtonColor,
                      foregroundColor: AppColors.loginButtonTextColor,
                    ),
                    onPressed: () async {
                      loadingScrean(context, str.Strings.loading);
                      await ref
                          .read(authStateProvider.notifier)
                          .loginWithGoogle();
                      Navigator.of(context).pop();
                    },
                    child: const GoogleButton(),
                  ),
                  const DividerWithMargins(),
                  const LoginViewSignupLinks(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
