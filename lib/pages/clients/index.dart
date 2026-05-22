import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/pages/clients/AfficheClient.dart';
import 'package:flutter_app/pages/clients/AjoutClient.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:flutter_app/theme/app_colors.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> clients = [];
  final ClientService _clientService = ClientService();

  @override
  void initState() {
    super.initState();
    _loadClients(); // charge les données dès le démarrage
  }

  Future<void> _loadClients() async {
    final data = await _clientService.getAllClients();
    // 🧠 Transformation de Map → Client
    final List<Client> loadedClients =
        data.map((map) => Client.fromMap(map)).toList();
    setState(() {
      clients = loadedClients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text("Clients", style: TextStyle(color: AppColors.textPrimary)),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: clients.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final client = clients[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AfficheClient(clt: client!)));
              _loadClients();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // Pas de shadow ici
              ),
              child: Row(
                children: [
                  // Avatar avec initiale
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      client.nom[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.onAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Infos client
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${client.sexe == "M" ? "Mr" : "Mme"} ${client.nom}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        client.adresse,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AjoutClient()));
          if (result == true) {
            // Rafraîchir les clients
            _loadClients();
            // Afficher message de succès
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Client ajouté avec succès')),
            );
          }
        },
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
