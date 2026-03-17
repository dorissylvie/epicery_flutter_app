import 'package:flutter/material.dart' ;

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
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
        child: Text('Paramètres'),
      ),
    );
  }
}
