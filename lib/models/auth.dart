import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';

class Authent {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> criarUsuario(
      String nome, String email, String senha, String genero, context) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: senha);
    String codigo = DatabaseMethods().gerarCodigo(10);
    Map<String, dynamic> userInfoMap = {
      'uid': auth.currentUser!.uid,
      'nome': nome,
      'email': email,
      'genero': genero,
      'categoria': 'Iniciante',
      'codigo': codigo
    };

    if (userCredential != null) {
      DatabaseMethods().addUserInfoToDB(auth.currentUser!.uid, userInfoMap);
    }
  }

  Future<void> loginSenhaEmail(String email, String password) async {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}
