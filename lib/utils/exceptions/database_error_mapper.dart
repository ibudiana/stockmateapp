class DatabaseErrorMapper {
  static String map(Object e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('username sudah digunakan')) {
      return 'Username sudah digunakan.';
    }

    if (msg.contains('email sudah digunakan')) {
      return 'Email sudah terdaftar.';
    }

    if (msg.contains('unique') && msg.contains('username')) {
      return 'Username sudah digunakan.';
    }

    if (msg.contains('unique') && msg.contains('email')) {
      return 'Email sudah terdaftar di database lokal.';
    }

    if (msg.contains('database is locked')) {
      return 'Database sedang digunakan, coba lagi.';
    }

    return 'Terjadi kesalahan pada penyimpanan data.';
  }
}
