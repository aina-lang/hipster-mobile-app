import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/models/user_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';
import 'package:tiko_tiko/shared/widgets/searchable_country_dropdown.dart';
import 'package:tiko_tiko/shared/models/country_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String _clientType = "particulier";

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _siretController;
  late TextEditingController _tvaController;
  late TextEditingController _websiteController;
  late TextEditingController _billingAddressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  late TextEditingController _contactEmailController;
  List<TextEditingController> _phoneControllers = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _initControllers(state.user);
      if (!state.user.isProfileComplete) {
        _isEditing = true;
      }
      // Récupérer les données les plus récentes du backend
      context.read<AuthBloc>().add(AuthProfileRefreshRequested());
    }
  }

  bool _controllersInitialized = false;

  void _initControllers(UserModel user) {
    _clientType = user.clientProfile?.clientType ?? "individual";
    // Normalization pour le dropdown
    if (_clientType == "particulier") _clientType = "individual";
    if (_clientType == "entreprise") _clientType = "company";

    if (!_controllersInitialized) {
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _companyNameController = TextEditingController(
        text: user.clientProfile?.companyName ?? "",
      );
      _siretController = TextEditingController(
        text: user.clientProfile?.siret ?? "",
      );
      _tvaController = TextEditingController(
        text: user.clientProfile?.tvaNumber ?? "",
      );
      _websiteController = TextEditingController(
        text: user.clientProfile?.website ?? "",
      );
      _billingAddressController = TextEditingController(
        text: user.clientProfile?.billingAddress ?? "",
      );
      _cityController = TextEditingController(
        text: user.clientProfile?.city ?? "",
      );
      _zipCodeController = TextEditingController(
        text: user.clientProfile?.zipCode ?? "",
      );
      _countryController = TextEditingController(
        text: user.clientProfile?.country ?? "",
      );
      _contactEmailController = TextEditingController(
        text: user.clientProfile?.contactEmail ?? user.contactEmail ?? "",
      );
      _phoneControllers = (user.phones.isEmpty)
          ? [TextEditingController()]
          : user.phones.map((p) => TextEditingController(text: p)).toList();
      _controllersInitialized = true;
    } else {
      // Update existing controllers instead of recreating them
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _companyNameController.text = user.clientProfile?.companyName ?? "";
      _siretController.text = user.clientProfile?.siret ?? "";
      _tvaController.text = user.clientProfile?.tvaNumber ?? "";
      _websiteController.text = user.clientProfile?.website ?? "";
      _billingAddressController.text = user.clientProfile?.billingAddress ?? "";
      _cityController.text = user.clientProfile?.city ?? "";
      _zipCodeController.text = user.clientProfile?.zipCode ?? "";
      _countryController.text = user.clientProfile?.country ?? "";
      _contactEmailController.text =
          user.clientProfile?.contactEmail ?? user.contactEmail ?? "";

      // Handle phones carefully: try to keep existing controllers to avoid flickering
      if (user.phones.isNotEmpty) {
        // Simple approach for now: if lengths differ greatly, reuse or truncate
        while (_phoneControllers.length < user.phones.length) {
          _phoneControllers.add(TextEditingController());
        }
        while (_phoneControllers.length > user.phones.length &&
            _phoneControllers.length > 1) {
          _phoneControllers.removeLast().dispose();
        }
        for (int i = 0; i < user.phones.length; i++) {
          if (_phoneControllers[i].text != user.phones[i]) {
            _phoneControllers[i].text = user.phones[i];
          }
        }
      }
    }
  }

  @override
  void dispose() {
    if (_controllersInitialized) {
      _firstNameController.dispose();
      _lastNameController.dispose();
      _companyNameController.dispose();
      _siretController.dispose();
      _tvaController.dispose();
      _websiteController.dispose();
      _billingAddressController.dispose();
      _cityController.dispose();
      _zipCodeController.dispose();
      _countryController.dispose();
      _contactEmailController.dispose();
      for (var c in _phoneControllers) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext BC) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    _uploadAvatar(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    _uploadAvatar(image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadAvatar(String path) {
    context.read<AuthBloc>().add(AuthAvatarUploadRequested(path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            // Si les noms sont manquants dans les controllers mais présents dans le user, on ré-initialise
            if (_firstNameController.text.isEmpty &&
                state.user.firstName.isNotEmpty) {
              setState(() {
                _initControllers(state.user);
              });
            }

            if (state.user.isProfileComplete) {
              setState(() => _isEditing = false);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profil mis à jour avec succès !"),
                ),
              );

              // Redirection vers /choice-space si c'est un client
              if (state.user.roles.contains('client')) {
                context.go('/choice-space');
              }
            } else {
              setState(() => _isEditing = true);
              // On s'assure que les champs sont remplis lors du premier chargement/refresh
              _initControllers(state.user);
            }
          });
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthEmailChangeCurrentOtpSent) {
          _showVerifyCurrentEmailDialog();
        } else if (state is AuthEmailChangeNewOtpSent) {
          _showVerifyNewEmailDialog();
        } else if (state is AuthEmailChangeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login');
        }
      },
      builder: (context, state) {
        if (state is! AuthAuthenticated &&
            state is! AuthLoading &&
            state is! AuthFailure) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If it's a failure, we wait for the next state (which the bloc will emit as AuthAuthenticated)
        // or we show the last known user data if available.
        // For now, let's just make sure we don't show a blank screen or permanent loader.
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        } else if (state is AuthLoading || state is AuthFailure) {
          // Try to get user from previous state or keep current one
          // BloC usually keeps the last state, but here we can try to find it
          final prevState = context.read<AuthBloc>().state;
          if (prevState is AuthAuthenticated) user = prevState.user;
        }

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        print(
          'ProfileScreen: Rendering user - email: ${user.email}, firstName: "${user.firstName}", lastName: "${user.lastName}", phones: ${user.phones}',
        );

        final bool forceEdit = !user.isProfileComplete;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/client/dashboard');
                }
              },
            ),
            title: const Text('Mon Profil'),
            centerTitle: true,
            actions: [
              if (!forceEdit)
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: () {
                    if (!_isEditing) {
                      _initControllers(user!);
                    }
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (forceEdit)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Veuillez compléter votre profil pour accéder à toutes les fonctionnalités.",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Center(
                    child: GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(
                                    AppConstants.resolveFileUrl(
                                      user.avatarUrl,
                                    ),
                                  )
                                : null,
                            child: user.avatarUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Type de profil"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField<String>(
                      initialValue: _clientType,
                      decoration: InputDecoration(
                        labelText: "Vous êtes ?",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "individual",
                          child: Text("Un Particulier"),
                        ),
                        DropdownMenuItem(
                          value: "company",
                          child: Text("Une Entreprise"),
                        ),
                      ],
                      onChanged: _isEditing
                          ? (val) => setState(() => _clientType = val!)
                          : null,
                    ),
                  ),

                  _buildSectionHeader("Informations de base"),
                  _buildTextField(
                    label: "Prénom",
                    controller: _firstNameController,
                    enabled: _isEditing,
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  _buildTextField(
                    label: "Nom",
                    controller: _lastNameController,
                    enabled: _isEditing,
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  _buildSectionHeader("Téléphones"),
                  ..._phoneControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Téléphone ${index + 1}",
                            controller: controller,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        if (_isEditing && _phoneControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () => setState(() {
                              _phoneControllers[index].dispose();
                              _phoneControllers.removeAt(index);
                            }),
                          ),
                      ],
                    );
                  }),
                  if (_isEditing)
                    TextButton.icon(
                      onPressed: () => setState(
                        () => _phoneControllers.add(TextEditingController()),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter un numéro"),
                    ),
                  const SizedBox(height: 16),

                  if (_clientType == "company" ||
                      _clientType == "entreprise") ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader("Informations Entreprise"),
                    _buildTextField(
                      label: "Nom de l'entreprise",
                      controller: _companyNameController,
                      enabled: _isEditing,
                      validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                    ),
                    _buildTextField(
                      label: "SIRET",
                      controller: _siretController,
                      enabled: _isEditing,
                    ),
                    _buildTextField(
                      label: "Numéro de TVA",
                      controller: _tvaController,
                      enabled: _isEditing,
                    ),
                    _buildTextField(
                      label: "Email de contact",
                      controller: _contactEmailController,
                      enabled: _isEditing,
                      validator: (v) =>
                          (v != null && v.isNotEmpty && !v.contains('@'))
                          ? "Email invalide"
                          : null,
                    ),
                    _buildTextField(
                      label: "Site Web",
                      controller: _websiteController,
                      enabled: _isEditing,
                    ),
                  ],

                  const SizedBox(height: 20),
                  _buildSectionHeader("Adresse de facturation"),
                  _buildTextField(
                    label: "Adresse",
                    controller: _billingAddressController,
                    enabled: _isEditing,
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: "Ville",
                          controller: _cityController,
                          enabled: _isEditing,
                          validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: "Code Postal",
                          controller: _zipCodeController,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  SearchableCountryDropdown(
                    initialValue: _countryController.text,
                    enabled: _isEditing,
                    onSelected: (Country country) {
                      _countryController.text = country.name;
                      // Suggestion de préfixe téléphonique si le premier champ est vide
                      if (_isEditing &&
                          _phoneControllers.isNotEmpty &&
                          _phoneControllers[0].text.isEmpty &&
                          country.callingCodes.isNotEmpty) {
                        setState(() {
                          _phoneControllers[0].text =
                              "+${country.callingCodes.first} ";
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                  if (_isEditing)
                    CustomButton(
                      text: "Enregistrer les modifications",
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final emailVal = _contactEmailController.text.trim();
                          final contactEmail = emailVal.isNotEmpty
                              ? emailVal
                              : null;

                          final payload = {
                            "firstName": _firstNameController.text.trim(),
                            "lastName": _lastNameController.text.trim(),
                            "contactEmail": contactEmail,
                            "phones": _phoneControllers
                                .map((c) => c.text.trim())
                                .where((t) => t.isNotEmpty)
                                .toList(),
                            "clientProfile": {
                              "clientType":
                                  _clientType, // individual or company
                              "companyName": (_clientType == "company")
                                  ? _companyNameController.text.trim()
                                  : null,
                              "siret": (_clientType == "company")
                                  ? _siretController.text.trim()
                                  : null,
                              "tvaNumber": (_clientType == "company")
                                  ? _tvaController.text.trim()
                                  : null,
                              "contactEmail": contactEmail,
                              "website": _websiteController.text.trim(),
                              "billingAddress": _billingAddressController.text
                                  .trim(),
                              "city": _cityController.text.trim(),
                              "zipCode": _zipCodeController.text.trim(),
                              "country": _countryController.text.trim(),
                            },
                          };
                          context.read<AuthBloc>().add(
                            AuthUpdateProfileRequested(payload),
                          );
                        }
                      },
                    ),

                  if (!forceEdit) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader("Sécurité"),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text("Email de connexion"),
                            subtitle: Text(user.email),
                            trailing: const Icon(Icons.edit, size: 20),
                            onTap: () => _showRequestEmailChangeDialog(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: const Text("Mot de passe"),
                            subtitle: const Text("••••••••••••"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement change password dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Fonctionnalité de changement de mot de passe à venir",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => _logout(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Déconnexion"),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: !enabled,
          fillColor: enabled ? Colors.transparent : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showRequestEmailChangeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Changer l\'email'),
        content: const Text(
          'Pour votre sécurité, nous allons envoyer un code de vérification à votre adresse email actuelle avant de pouvoir la modifier.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthEmailChangeRequested());
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showVerifyCurrentEmailDialog() {
    final codeController = TextEditingController();
    final newEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Code de vérification'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez le code envoyé à votre email actuel et saisissez votre nouvelle adresse email.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code OTP (Email actuel)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newEmailController,
                decoration: const InputDecoration(
                  labelText: 'Nouvel Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final code = codeController.text.trim();
                final newEmail = newEmailController.text.trim();
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(
                  AuthEmailChangeVerifyCurrentRequested(
                    code: code,
                    newEmail: newEmail,
                  ),
                );
              }
            },
            child: const Text('Suivant'),
          ),
        ],
      ),
    );
  }

  void _showVerifyNewEmailDialog() {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dernière étape'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Un code a été envoyé à votre nouvelle adresse email. Entrez-le pour confirmer le changement.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code OTP (Nouvel email)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final code = codeController.text.trim();
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(
                  AuthEmailChangeConfirmNewRequested(code: code),
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
