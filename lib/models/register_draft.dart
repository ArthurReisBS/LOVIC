/// Dados do cadastro, preenchidos tela a tela e enviados ao Supabase só no
/// final, na tela de senha.
class RegisterDraft {
  String email = '';
  String nome = '';
  String sobrenome = '';

  /// Data no formato do banco (`AAAA-MM-DD`), ou null se não informada.
  String? dataNascimento;
  String username = '';
}
