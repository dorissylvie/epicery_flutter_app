import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_app/theme/app_colors.dart';

class ModificationClient extends StatefulWidget {
  final Client client;

  const ModificationClient({super.key, required this.client});

  @override
  State<ModificationClient> createState() => _ModificationClientState();
}

class _ModificationClientState extends State<ModificationClient> {
  final _formKey = GlobalKey<FormState>();

  // Champs texte
  final nomController = TextEditingController();
  final surnomController = TextEditingController();
  final adresseController = TextEditingController();
  String selectedSexe = 'M';

  PhoneNumber? _currentPhoneNumber;

  final List<Map<String, String>> sexes = [
    {"label": "Masculin", "value": "M"},
    {"label": "Féminin", "value": "F"},
  ];
  @override
  void initState() {
    super.initState();

    nomController.text = widget.client.nom;
    surnomController.text = widget.client.surnom;
    adresseController.text = widget.client.adresse;
    selectedSexe = widget.client.sexe;

    _initPhoneNumber();
  }

  void _initPhoneNumber() async {
    PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
      widget.client.num,
    );
    setState(() {
      _currentPhoneNumber = number;
    });
  }

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
        title: const Text("Modification client"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _currentPhoneNumber != null) {
                  Client updatedClient = Client(
                    nom: nomController.text,
                    surnom: surnomController.text,
                    num: _currentPhoneNumber!.phoneNumber!, // +26134...
                    adresse: adresseController.text,
                    sexe: selectedSexe,
                  );

                  ClientService clientService = ClientService();
                  clientService.updateClient(
                      widget.client.id, updatedClient.toMap());

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
              child: const Text("Enregistrer"),
            ),
          ),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez remplir le nom'
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: surnomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Surnom',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez remplir le surnom'
                    : null,
              ),
              const SizedBox(height: 15),
              if (_currentPhoneNumber != null)
                InternationalPhoneNumberInput(
                  initialValue: _currentPhoneNumber,
                  onInputChanged: (PhoneNumber number) {
                    _currentPhoneNumber = number;
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    setSelectorButtonAsPrefixIcon: true,
                    useBottomSheetSafeArea: true,
                    leadingPadding: 10,
                  ),
                  formatInput: true,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  inputDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Numéro de téléphone",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: false,
                  ),
                ),
              if (_currentPhoneNumber == null)
                const CircularProgressIndicator(),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sexe',
                ),
                value: selectedSexe,
                items: sexes
                    .map((sexe) => DropdownMenuItem(
                        value: sexe['value'], child: Text(sexe['label']!)))
                    .toList(),
                onChanged: (value) {
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
              ), // En attendant le chargement du numéro
            ],
          ),
        ),
      ),
    );
  }
}
