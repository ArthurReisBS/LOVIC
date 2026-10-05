import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/models/user_profile_mapper.dart';

void main() {
  group('calcularIdade', () {
    final hoje = DateTime(2026, 6, 15);

    test('antes do aniversário ainda não completou o ano', () {
      expect(calcularIdade(DateTime(2000, 6, 16), hoje), 25);
    });

    test('no dia e depois do aniversário já completou', () {
      expect(calcularIdade(DateTime(2000, 6, 15), hoje), 26);
      expect(calcularIdade(DateTime(2000, 1, 1), hoje), 26);
    });

    test('data nula ou no futuro devolve null', () {
      expect(calcularIdade(null, hoje), isNull);
      expect(calcularIdade(DateTime(2030, 1, 1), hoje), isNull);
    });

    test('nascido em 29/02 faz aniversário em 01/03 em ano não bissexto', () {
      final nascimento = DateTime(2000, 2, 29);
      expect(calcularIdade(nascimento, DateTime(2023, 2, 28)), 22);
      expect(calcularIdade(nascimento, DateTime(2023, 3, 1)), 23);
      expect(calcularIdade(nascimento, DateTime(2024, 2, 29)), 24);
    });
  });

  group('perfilDeLinha', () {
    final hoje = DateTime(2026, 6, 15);

    test('junta nome e sobrenome e usa username, idade e bio', () {
      final p = perfilDeLinha({
        'id': 'abc',
        'nome': 'Ana',
        'sobrenome': 'Souza',
        'username': 'ana.souza',
        'bio': 'Amo rock',
        'data_nascimento': '2000-06-15',
      }, hoje: hoje);
      expect(p.id, 'abc');
      expect(p.name, 'Ana Souza');
      expect(p.username, 'ana.souza');
      expect(p.bio, 'Amo rock');
      expect(p.age, 26);
    });

    test('sem sobrenome, bio nula e sem data usa os padrões', () {
      final p = perfilDeLinha({
        'id': 'abc',
        'nome': 'Ana',
        'sobrenome': null,
        'username': 'ana',
        'bio': null,
        'data_nascimento': null,
      }, hoje: hoje);
      expect(p.name, 'Ana');
      expect(p.bio, bioPadrao);
      expect(p.age, isNull);
    });

    test('bio só com espaços vira a bio padrão e nome vazio usa o username', () {
      final p = perfilDeLinha({
        'id': 'abc',
        'nome': '',
        'sobrenome': '  ',
        'username': 'ana',
        'bio': '   ',
      }, hoje: hoje);
      expect(p.bio, bioPadrao);
      expect(p.name, 'ana');
    });
  });

  group('gêneros e cor de exemplo', () {
    test('o mesmo id sempre dá o mesmo resultado', () {
      expect(
        generosDeExemplo('id-1').map((g) => g.name),
        generosDeExemplo('id-1').map((g) => g.name),
      );
      expect(corDeExemplo('id-1'), corDeExemplo('id-1'));
    });

    test('sempre devolve 2 ou 3 gêneros sem repetir', () {
      for (var i = 0; i < 200; i++) {
        final nomes = generosDeExemplo('usuario-$i').map((g) => g.name).toList();
        expect(nomes.length, inInclusiveRange(2, 3));
        expect(nomes.toSet().length, nomes.length);
      }
    });
  });
}
