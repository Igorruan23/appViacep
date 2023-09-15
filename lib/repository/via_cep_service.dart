import 'dart:convert';
import 'package:http/http.dart' as http;

class CEPService {
  Future<Map<String, dynamic>> fetchCEP(String cep) async {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
     else {
      throw Exception('Falha ao consultar o CEP.');
    }
  }
}
