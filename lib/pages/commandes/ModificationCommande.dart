import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Commande.dart';

class ModificationCommande extends StatefulWidget {
  final Commande cmd;
  const ModificationCommande({super.key, required this.cmd});

  @override
  State<ModificationCommande> createState() => _ModificationCommandeState();
}

class _ModificationCommandeState extends State<ModificationCommande> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
