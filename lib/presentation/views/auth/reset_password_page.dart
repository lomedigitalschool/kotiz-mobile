import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Email envoyé'),
          description: const Text('Vérifiez votre boîte mail pour réinitialiser votre mot de passe'),
          backgroundColor: Colors.green.shade100,
          autoCloseDuration: const Duration(seconds: 5),
        );
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun compte ne correspond à cet e-mail';
          break;
        case 'invalid-email':
          message = 'Adresse e-mail invalide';
          break;
        default:
          message = 'Une erreur est survenue';
      }

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text('Erreur: $message'),
          backgroundColor: Colors.red.shade100,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
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
      backgroundColor: ColorConstant.colorWhite,
      appBar: AppBar(
        title: const Text("Réinitialiser le mot de passe"),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              const Icon(
                LucideIcons.lockKeyhole,
                size: 80,
                color: ColorConstant.colorGreen,
              ),
              const SizedBox(height: 24),
              
              const Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              const Text(
                "Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFieldComponent(
                labelTitle: "Adresse e-mail",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'adresse e-mail est requise';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Adresse e-mail invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              AppButton(
                text: _isLoading ? "Envoi en cours..." : "Envoyer le lien",
                backgroundColor: ColorConstant.colorGreen,
                onPressed: _isLoading ? null : _resetPassword,
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  "Retour à la connexion",
                  style: TextStyle(color: ColorConstant.colorGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}