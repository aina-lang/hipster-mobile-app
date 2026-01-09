import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';
import 'package:tiko_tiko/shared/blocs/network/network_bloc.dart';
import 'package:tiko_tiko/shared/blocs/network/network_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onVerify([String? code]) {
    final pin = code ?? _pinController.text;
    if (pin.length < 6) {
      AppSnackBar.show(
        context,
        'Veuillez entrer le code complet',
        type: SnackType.error,
      );
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(widget.email, pin));
  }

  void _resendCode() {
    if (_resendCountdown == 0) {
      context.read<AuthBloc>().add(AuthResendOtpRequested(widget.email));
      _startResendTimer();
      AppSnackBar.show(
        context,
        'Un nouveau code a été envoyé',
        type: SnackType.success,
      );
    }
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

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackBar.show(context, state.message, type: SnackType.error);
            _pinController.clear();
          } else if (state is AuthAuthenticated) {
            AppSnackBar.show(
              context,
              'Vérification réussie ! Bienvenue.',
              type: SnackType.success,
            );
            context.go('/client/dashboard');
          } else if (state is AuthInitial) {
            // Handling potential navigate back to login loops if strict
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Vérification',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      children: [
                        const TextSpan(text: 'Nous avons envoyé un code à\n'),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    onCompleted: (pin) => _onVerify(pin),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

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
                          text: isOffline ? "Pas de connexion" : "Vérifier",
                          isLoading: state is AuthLoading,
                          onPressed: isOffline
                              ? null
                              : () => _onVerify(_pinController.text),
                          height: 56,
                          borderRadius: 14,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: _resendCountdown == 0 ? _resendCode : null,
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text(
                      _resendCountdown == 0
                          ? 'Renvoyer le code'
                          : 'Renvoyer le code dans ${_resendCountdown}s',
                      style: TextStyle(
                        color: _resendCountdown == 0
                            ? Colors
                                  .black // Black for active
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
