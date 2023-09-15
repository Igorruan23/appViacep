// lib/main.dart
import 'package:flutter/material.dart';
import 'package:viacep/repository/shared_preferences.dart';
import 'package:viacep/repository/via_cep_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEP Lookup',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cepController = TextEditingController();
  final CEPService _cepService = CEPService();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  List<Map<String, dynamic>> searchResults = [];

  void _searchCEP() async {
    final cep = _cepController.text;

    try {
      final result = await _cepService.fetchCEP(cep);

      if (result != null &&
          (!result.containsKey('erro') || result['erro'] == false) &&
          result.containsKey('cep') &&
          result.containsKey('localidade')) {
        setState(() {
          searchResults.insert(0, result);
        });
        await _sharedPreferencesService.saveSearchResult(cep, result);
      } else {
        _showInvalidCEPDialog();
      }
    } catch (e) {
      print("erro ao buscar cep");
    }
  }

  void _showInvalidCEPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('CEP Inválido'),
          content: Text(
              'O CEP inserido é inválido. Por favor, verifique e tente novamente.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousSearchResults();
  }

  void _loadPreviousSearchResults() async {
    // Carregue as consultas anteriores das preferências compartilhadas e atualize searchResults.
    final previousResults =
        await _sharedPreferencesService.getPreviousSearchResults();
    setState(() {
      searchResults.addAll(previousResults);
    });
  }

  void _removeCEP(int index) async {
    final result = searchResults[index];
    final cep = result['cep'];
    await _sharedPreferencesService.removeSearchResult(cep);
    setState(() {
      searchResults.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa Cep'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              "https://m.media-amazon.com/images/I/51WcUuvChzL.png",
              width: 100,
              height: 100,
            ),
            TextField(
              maxLength: 8,
              keyboardType: TextInputType.number,
              controller: _cepController,
              decoration: const InputDecoration(labelText: 'CEP'),
            ),
            ElevatedButton(
              onPressed: _searchCEP,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Consultas Anteriores",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
            ),
            const Divider(
              color: Colors.black,
              thickness: 1.0,
              height: 20,
              indent: 20,
              endIndent: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                          title: Text(
                            'CEP: ${result['cep']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Cidade: ${result['localidade']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _removeCEP(index);
                              })));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
