import 'package:flutter/material.dart' ; 

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
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
