import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotiz_app/core/services/kyc_service.dart';
import 'package:kotiz_app/core/netework/api_config.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomLegalController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _adresseController = TextEditingController();
  final _nationaliteController = TextEditingController();
  final _numeroController = TextEditingController();
  final _dateController = TextEditingController();

  String _typePiece = 'CNI';
  File? _photoRecto;
  File? _photoVerso;
  bool _isSubmitting = false;
  bool _confirmInfo = false;

  final ImagePicker _picker = ImagePicker();
  late final KycService _kycService;

  @override
  void initState() {
    super.initState();
    _kycService = KycService(ApiConfig());
  }

  @override
  void dispose() {
    _nomLegalController.dispose();
    _dateNaissanceController.dispose();
    _adresseController.dispose();
    _nationaliteController.dispose();
    _numeroController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog(bool isRecto) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir ${isRecto ? 'le recto' : 'le verso'}'),
          content: const Text('Comment souhaitez-vous ajouter la photo ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(isRecto, ImageSource.camera);
              },
              child: const Text('📷 Prendre une photo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(isRecto, ImageSource.gallery);
              },
              child: const Text('📁 Choisir depuis fichiers'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(bool isRecto, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isRecto) {
            _photoRecto = File(image.path);
          } else {
            _photoVerso = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Erreur'),
          description: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red.shade200,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoRecto == null || _photoVerso == null) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Photos manquantes'),
        description: const Text('Veuillez prendre les photos recto et verso'),
        backgroundColor: Colors.red.shade200,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }
    if (!_confirmInfo) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Confirmation requise'),
        description: const Text(
          'Veuillez confirmer que les informations sont exactes',
        ),
        backgroundColor: Colors.red.shade200,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _kycService.submitKyc(
        nomLegal: _nomLegalController.text.trim(),
        dateNaissance: _dateNaissanceController.text.trim(),
        adresse: _adresseController.text.trim(),
        nationalite: _nationaliteController.text.trim(),
        typePiece: _typePiece,
        numeroPiece: _numeroController.text.trim(),
        dateExpiration: _dateController.text.trim(),
        photoRecto: _photoRecto!,
        photoVerso: _photoVerso!,
      );

      if (mounted) {
        if (response['success'] == true) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            title: const Text('KYC soumis'),
            description: Text(
              response['message'] ??
                  'Votre demande de vérification a été envoyée',
            ),
            backgroundColor: Colors.green.shade200,
            autoCloseDuration: const Duration(seconds: 3),
          );
          context.pop();
        } else {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            title: const Text('Erreur'),
            description: Text(
              response['message'] ?? 'Erreur lors de la soumission',
            ),
            backgroundColor: Colors.red.shade200,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Erreur'),
          description: Text('Erreur lors de la soumission: $e'),
          backgroundColor: Colors.red.shade200,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification d\'identité'),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(
              child: Text('Vous devez être connecté pour accéder à cette page'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pour vérifier votre identité, veuillez fournir les informations suivantes :',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Nom complet
                  TextFieldComponent(
                    labelTitle: 'Nom complet',
                    controller: _nomLegalController,
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom complet est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date de naissance
                  TextFieldComponent(
                    labelTitle: 'Date de naissance',
                    controller: _dateNaissanceController,
                    astherix: true,
                    hintText: 'JJ/MM/AAAA',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La date de naissance est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Adresse
                  TextFieldComponent(
                    labelTitle: 'Adresse',
                    controller: _adresseController,
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'adresse est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nationalité
                  TextFieldComponent(
                    labelTitle: 'Nationalité',
                    controller: _nationaliteController,
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La nationalité est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Type de pièce
                  const Text(
                    'Type de pièce d\'identité',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _typePiece,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'CNI',
                        child: Text('Carte Nationale d\'Identité'),
                      ),
                      DropdownMenuItem(
                        value: 'PASSPORT',
                        child: Text('Passeport'),
                      ),
                      DropdownMenuItem(
                        value: 'PERMIS_CONDUIRE',
                        child: Text('Permis de conduire'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _typePiece = value!),
                  ),
                  const SizedBox(height: 16),

                  // Numéro de pièce
                  TextFieldComponent(
                    labelTitle: 'Numéro de la pièce',
                    controller: _numeroController,
                    astherix: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le numéro de la pièce est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date d'expiration
                  TextFieldComponent(
                    labelTitle: 'Date d\'expiration (JJ/MM/AAAA)',
                    controller: _dateController,
                    astherix: true,
                    hintText: '31/12/2030',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La date d\'expiration est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Photos
                  const Text(
                    'Photos de la pièce d\'identité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Photo recto
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _photoRecto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _photoRecto!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : InkWell(
                            onTap: () => _showImageSourceDialog(true),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.camera,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Photo RECTO',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Appuyez pour choisir une image',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Photo verso
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _photoVerso != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _photoVerso!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : InkWell(
                            onTap: () => _showImageSourceDialog(false),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.camera,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Photo VERSO',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Appuyez pour choisir une image',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Checkbox de confirmation
                  Row(
                    children: [
                      Checkbox(
                        value: _confirmInfo,
                        onChanged: (value) =>
                            setState(() => _confirmInfo = value ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Je confirme que les informations fournies sont exactes et que les documents téléchargés sont valides.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bouton de soumission
                  AppButton(
                    text: _isSubmitting
                        ? 'Envoi en cours...'
                        : 'Soumettre ma demande',
                    backgroundColor: _isSubmitting
                        ? Colors.grey
                        : ColorConstant.colorGreen,
                    onPressed: _isSubmitting ? null : _submitKyc,
                    widget: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : null,
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
