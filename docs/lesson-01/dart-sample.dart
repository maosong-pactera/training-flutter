import 'dart:async';

main() {
  printDatetime();
}

void printDatetime() async {
  print('Start at: ${DateTime.now()}\n');
  Sample sample = Sample('Now datetime');
  print(await sample.test());
  print('Finish at: ${DateTime.now()}\n');
}

class Sample {
  String text;

  Sample(this.text);

  Future<String> test() {
    return Future.delayed(
        Duration(seconds: 3), () => '${this.text}: ${DateTime.now()}\n');
  }
}
