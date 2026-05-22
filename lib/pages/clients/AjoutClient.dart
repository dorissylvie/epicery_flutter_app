import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_app/theme/app_colors.dart';

class AjoutClient extends StatefulWidget {
  const AjoutClient({super.key});

  @override
  State<AjoutClient> createState() => _AjoutClientState();
}

class _AjoutClientState extends State<AjoutClient> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumber initialPhoneNumber =
      PhoneNumber(isoCode: 'MG'); // 🇲🇬 par défaut
  PhoneNumber? _currentPhoneNumber;

  // Champs texte
  final nomController = TextEditingController();
  final surnomController = TextEditingController();
  final adresseController = TextEditingController();
  String selectedSexe = 'M';

  final List<Map<String, String>> sexes = [
    {"label": "Masculin", "value": "M"},
    {"label": "Féminin", "value": "F"},
  ];

  @override
  void dispose() {
    nomController.dispose();
    surnomController.dispose();
    adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop(); // Retour
          },
        ),
        title: Text("Ajout client"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final phone = _currentPhoneNumber?.phoneNumber ?? '';

                  Client newClient = Client(
                    nom: nomController.text,
                    surnom: surnomController.text,
                    num: phone,
                    adresse: adresseController.text,
                    sexe: selectedSexe,
                  );

                  ClientService clientService = ClientService();
                  clientService.insertClient(newClient.toMap());

                  Navigator.pop(context, true); // Retour avec succès
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Enregistrer"),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nom complet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez remplir le nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: surnomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Surnom',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez remplir le surnom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  _currentPhoneNumber = number;
                },
                onInputValidated: (bool isValid) {
                  // Tu peux afficher une validation ici si tu veux
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  setSelectorButtonAsPrefixIcon: true,
                  useBottomSheetSafeArea: true,
                  leadingPadding: 10,
                ),
                initialValue: initialPhoneNumber,
                inputDecoration: const InputDecoration(
                  hintText: "Numéro de téléphone",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                formatInput: true,
                autoValidateMode: AutovalidateMode.disabled,
                ignoreBlank: false,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: false,
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sexe',
                ),
                value: selectedSexe,
                items: sexes
                    .map((sexe) => DropdownMenuItem(
                        value: sexe['value'], child: Text(sexe['label']!)))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedSexe = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez choisir un sexe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: adresseController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Adresse',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez remplir l\'adresse';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
