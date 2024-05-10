import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // pacote que permite a manipulação de banco de dados
import 'package:path/path.dart'; // permite pegar o diretório de onde o bd é criado

void main()async {
  runApp(MaterialApp(
    home:  Home(),
  ));
   WidgetsFlutterBinding.ensureInitialized(); // Para garantir que o Flutter esteja inicializado antes de acessar o banco de dados
  await _insertInitialProd(); 
}
// função para inserir dados no banco de dados
Future<void> _insertInitialProd() async {
  var database = await _initializeDatabase();
  var trakinas = Prod(id: 5, nome: "Trakinas", qtde: 10);
  var nescau = Prod(id: 6, nome: "Nescau", qtde: 7);
  await _insertProd(database, trakinas);
  await _insertProd(database, nescau);
}
// função para inicializar o banco de dados
Future<Database> _initializeDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'prods_a.db'),
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE prodsa(id INTEGER PRIMARY KEY, nome TEXT, quantidade INTEGER)',
      );
    },
    version: 1,
  );
}

Future<void> _insertProd(Database database, Prod prod) async {
  await database.insert('prodsa', prod.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> _deleteProd(int id) async {
  final db = await _initializeDatabase();
  await db.delete('prodsa',where: 'id = ?',whereArgs: [id]);
  print("Deletando dado");
}

Future<void> updateProd(Prod prod) async {
  final db = await _initializeDatabase();
  await db.update('prodsa', prod.toMap(), where: 'id = ?', whereArgs: [prod.id]);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
   late Future<List<Prod>> _prods;
  @override
  void initState() {
    super.initState();
    _prods = _fetchProds();
  }
   Future<List<Prod>> _fetchProds() async {
    var database = await _initializeDatabase();
    final List<Map<String, dynamic>> maps = await database.query('prodsa');

    return List.generate(maps.length, (i) {
      return Prod(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        qtde: maps[i]['quantidade'],
      );
    });
  }
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("APP BD"),
      ),
      body: FutureBuilder<List<Prod>>(
        future: _prods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final prods = snapshot.data!;
            return ListView.builder(
              itemCount: prods.length,
              itemBuilder: (context, index) {
                final prod = prods[index];
                return ListTile(
                  title: Text(prod.nome),
                  subtitle: Text('Quantidade: ${prod.qtde}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class Prod{
  final int id;
  String nome;
  final int qtde;
  Prod({
    required this.id,
    required this.nome,
    required this.qtde
  });
   // função para transformar os dados em Map para salvar no banco de dados
  Map<String,dynamic> toMap(){
    return { 'id':id, 'nome':nome, 'quantidade':qtde};
  }

}