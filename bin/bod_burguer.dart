import 'package:bod_burguer/bod_burguer.dart' as bod_burguer;

void main(List<String> arguments) {
  final methods = bod_burguer.LoginMethodSelector().methods();
  print('Métodos de login disponibles: ${methods.join(', ')}');
  print('Hello world: ${bod_burguer.calculate()}!');
}
