import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/shared/blocs/network/network_bloc.dart';
import 'package:tiko_tiko/shared/blocs/network/network_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'cursorbulen@gmail.com');
  final _passwordController = TextEditingController(text: 'aina1234');

  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackBar.show(
              context,
              state.message,
              type: SnackType.error,
              position: SnackPosition.top,
            );
          } else if (state is AuthNeedsVerification) {
            context.go("/otp-verification", extra: state.email);
          } else if (state is AuthAuthenticated) {
            AppSnackBar.show(
              context,
              'Bienvenue ${state.user.firstName}',
              type: SnackType.success,
              position: SnackPosition.top,
            );
            context.go("/client/dashboard");
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),

                    // LOGO avec shadow douce
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: size.width * 0.52,
                          height: size.width * 0.52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "Bienvenue ",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connectez-vous pour continuer",
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),

                    const SizedBox(height: 40),

                    // EMAIL avec shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Entrez votre email";
                          if (!v.contains("@")) return "Email invalide";
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: "Adresse email",
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: Colors.grey[700],
                            size: 22,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD avec shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Entrez votre mot de passe";
                          if (v.length < 6) return "Min. 6 caractères";
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: Colors.grey[700],
                            size: 22,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                            onPressed: () => setState(() {
                              _isObscure = !_isObscure;
                            }),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // LOGIN BUTTON avec shadow comme bonbon
                    BlocBuilder<NetworkBloc, NetworkState>(
                      builder: (context, netState) {
                        final isOffline = netState.connectionStatus.contains(
                          ConnectivityResult.none,
                        );
                        return Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CustomButton(
                            text: isOffline
                                ? "Pas de connexion"
                                : "Se connecter",
                            isLoading: state is AuthLoading,
                            onPressed: isOffline
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        AuthLoginRequested(
                                          _emailController.text,
                                          _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                            height: 56,
                            borderRadius: 14,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // REGISTER - lien en noir
                    TextButton(
                      onPressed: () => context.go('/register'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                          ),
                          children: const [
                            TextSpan(text: "Pas encore de compte ? "),
                            TextSpan(
                              text: "Inscrivez-vous",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
