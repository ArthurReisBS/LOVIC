import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/services/chat_service.dart';

void main() {
  group('conversationKey', () {
    const a = '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed';
    const b = '9c5b94b1-35ad-49bb-b118-8e8fc24abf80';

    test('é a mesma dos dois lados da conversa', () {
      expect(ChatService.conversationKey(a, b), ChatService.conversationKey(b, a));
    });

    test('segue o formato da coluna gerada no banco: menor:maior', () {
      expect(ChatService.conversationKey(b, a), '$a:$b');
    });
  });

  group('ChatMessage.fromRow', () {
    final row = {
      'id': 7,
      'remetente_id': 'eu',
      'texto': 'oi',
      'criado_em': '2026-10-06T18:00:00+00:00',
    };

    test('marca como minha quando eu sou o remetente', () {
      expect(ChatMessage.fromRow(row, 'eu').isMine, isTrue);
      expect(ChatMessage.fromRow(row, 'outra').isMine, isFalse);
    });

    test('lê id, texto e horário', () {
      final message = ChatMessage.fromRow(row, 'eu');
      expect(message.id, 7);
      expect(message.text, 'oi');
      expect(message.sentAt.toUtc(), DateTime.utc(2026, 10, 6, 18));
    });
  });
}
