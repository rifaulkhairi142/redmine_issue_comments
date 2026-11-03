# Redmine Issue Comments

Plugin Redmine 6 yang menambahkan bagian **Komentar** di halaman detail setiap issue
(di bawah deskripsi), terpisah dari history/journal bawaan.

## Fitur

- Daftar komentar per issue: avatar, author, waktu, penanda "diubah".
- Format wiki (Textile/Markdown/CommonMark) + toolbar editor.
- Edit inline dan hapus komentar.
- Permission per role: lihat, tambah, ubah sendiri/semua, hapus sendiri/semua.
- Komentar ikut terhapus saat issue dihapus.
- Locale: English, Bahasa Indonesia.

## Instalasi

```sh
cd /path/to/redmine
cp -r redmine_issue_comments plugins/
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

Restart Redmine, lalu:

1. **Project > Settings > Project** : centang modul **Issue comments**.
2. **Administration > Roles and permissions** : beri permission **Issue comments** ke role.

## Uninstall

```sh
bundle exec rake redmine:plugins:migrate NAME=redmine_issue_comments VERSION=0 RAILS_ENV=production
rm -r plugins/redmine_issue_comments
```
