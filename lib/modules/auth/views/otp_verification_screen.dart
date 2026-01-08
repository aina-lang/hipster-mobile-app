import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      AppSnackBar.show(
        context,
        'Veuillez entrer le code complet',
        type: SnackType.error,
      );
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(widget.email, code));
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackBar.show(context, state.message, type: SnackType.error);
          } else if (state is AuthAuthenticated) {
            AppSnackBar.show(
              context,
              'Vérification réussie ! Bienvenue.',
              type: SnackType.success,
            );
            context.go('/client/dashboard');
          } else if (state is AuthInitial) {
            AppSnackBar.show(
              context,
              'Email vérifié ! Veuillez vous connecter.',
              type: SnackType.success,
            );
            context.go('/login');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Vérification',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nous avons envoyé un code de 6 chiffres à\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOtpField(index)),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Vérifier',
                  isLoading: state is AuthLoading,
                  onPressed: _onVerify,
                  height: 55,
                  borderRadius: 15,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _resendCountdown == 0 ? _resendCode : null,
                  child: Text(
                    _resendCountdown == 0
                        ? 'Renvoyer le code'
                        : 'Renvoyer le code dans ${_resendCountdown}s',
                    style: TextStyle(
                      color: _resendCountdown == 0
                          ? theme.primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_controllers.map((c) => c.text).join().length == 6) {
            _onVerify();
          }
        },
      ),
    );
  }
}
