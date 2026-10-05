/// Credenciais do Supabase, lidas do `.env` passado no `flutter run`:
///
/// ```bash
/// flutter run --dart-define-from-file=.env
/// ```
///
/// Sem o `.env`, o app roda em modo demonstração: as telas navegam com os
/// dados mockados, sem falar com o banco.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');

  /// `sb_publishable_...` (ou a antiga anon key, que também funciona).
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
