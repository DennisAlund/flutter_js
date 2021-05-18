import 'dart:math';

const _Characters =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const _CharactersLength = _Characters.length;

Random _rnd = Random();

String randomStr([int length = 6]) => String.fromCharCodes(Iterable.generate(
    length, (_) => _Characters.codeUnitAt(_rnd.nextInt(_CharactersLength))));
