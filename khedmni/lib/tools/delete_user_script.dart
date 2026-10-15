import 'package:flutter/widgets.dart';
import 'package:khedmni/data/dao/user_dao.dart';

Future<void> deleteStuckUser() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dao = UserDao();
  final user = await dao.getUserByEmail('leena.ikhlef@ensia.edu.dz');
  if (user != null) {
    await dao.deleteUser(user.id);
    print('User leena.ikhlef@ensia.edu.dz deleted.');
  } else {
    print('User not found.');
  }
}

void main() async {
  await deleteStuckUser();
}
