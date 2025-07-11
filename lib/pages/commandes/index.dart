import 'package:flutter/material.dart' ;

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appli name") ,
        shadowColor:  Theme.of(context).colorScheme.shadow,
        actions: <Widget>[
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.notifications))
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Accueil'),
      ),
    );
  }
}
