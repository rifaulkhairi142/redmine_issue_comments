# Redmine Issue Comments

Plugin Redmine 6 yang menambahkan bagian **Komentar** di halaman detail setiap issue
(di bawah deskripsi), terpisah dari history/journal bawaan.

## Fitur

- Daftar komentar per issue: avatar, author, waktu, penanda "diubah".
- Format wiki (Textile/Markdown/CommonMark) + toolbar editor.
- Balas komentar (satu level).
- Edit inline dan hapus komentar.
- Permission per role: lihat, tambah, ubah sendiri/semua, hapus sendiri/semua.
- Komentar ikut terhapus saat issue dihapus.
- Locale: English, Bahasa Indonesia.

## Instalasi (Redmine biasa)

```sh
cd /path/to/redmine
cp -r redmine_issue_comments plugins/
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

Restart Redmine, lalu lanjut ke [Aktivasi](#aktivasi).

## Instalasi (Redmine di Docker)

Contoh ini memakai container bernama `redmine` (image resmi `redmine`, plugin di `/usr/src/redmine/plugins`).
Jalankan dari folder yang berisi `redmine_issue_comments/`.

1. Salin plugin ke container dan perbaiki kepemilikan file:

   ```sh
   docker cp redmine_issue_comments redmine:/usr/src/redmine/plugins/redmine_issue_comments
   docker exec -u root redmine chown -R redmine:redmine /usr/src/redmine/plugins/redmine_issue_comments
   ```

2. Jalankan migrasi database plugin (membuat tabel `issue_comments`):

   ```sh
   docker exec -e RAILS_ENV=production redmine bundle exec rake redmine:plugins:migrate
   ```

   Cek hasilnya, harus ada baris `Migrating to CreateIssueComments (1)`:

   ```sh
   docker exec -e RAILS_ENV=production redmine bundle exec rake redmine:plugins:migrate NAME=redmine_issue_comments
   ```

3. Restart container supaya plugin dimuat:

   ```sh
   docker restart redmine
   ```

4. Pastikan plugin terdaftar: buka **Administration > Plugins**, atau jalankan:

   ```sh
   docker exec redmine ls /usr/src/redmine/plugins
   docker logs --tail 50 redmine
   ```

Catatan:

- `docker cp` hanya menyalin ke container yang sedang berjalan. Jika container dibuat ulang
  (`docker compose up --force-recreate`, `docker rm`), plugin hilang. Agar permanen, mount folder plugin
  sebagai volume, lalu ulangi langkah 2 dan 3:

  ```yaml
  services:
    redmine:
      volumes:
        - ./plugins:/usr/src/redmine/plugins
  ```

  Letakkan `redmine_issue_comments/` di dalam `./plugins` pada host.
- Jika memakai `docker compose`, ganti `docker exec redmine` dengan `docker compose exec redmine`.
- Jika `RAILS_ENV` sudah `production` di container (default image resmi), opsi `-e RAILS_ENV=production` boleh dibuang.
- Backup database sebelum migrasi pada server produksi.

## Aktivasi

1. **Project > Settings > Project** : centang modul **Issue comments**.
2. **Administration > Roles and permissions** : beri permission **Issue comments** ke role.

## Update plugin

Setelah mengganti file plugin, jalankan lagi migrasi dan restart:

```sh
docker cp redmine_issue_comments/. redmine:/usr/src/redmine/plugins/redmine_issue_comments/
docker exec -u root redmine chown -R redmine:redmine /usr/src/redmine/plugins/redmine_issue_comments
docker exec -e RAILS_ENV=production redmine bundle exec rake redmine:plugins:migrate
docker restart redmine
```

## Uninstall

Redmine biasa:

```sh
bundle exec rake redmine:plugins:migrate NAME=redmine_issue_comments VERSION=0 RAILS_ENV=production
rm -r plugins/redmine_issue_comments
```

Docker (rollback migrasi dulu, baru hapus plugin):

```sh
docker exec -e RAILS_ENV=production redmine bundle exec rake redmine:plugins:migrate NAME=redmine_issue_comments VERSION=0
docker exec redmine rm -r /usr/src/redmine/plugins/redmine_issue_comments
docker restart redmine
```
