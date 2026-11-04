# Redmine Done Ratio Step

Plugin Redmine 6 yang mengganti dropdown **% Done** (bawaan: kelipatan 10) dengan
**slider + input angka** yang kelipatannya bisa diatur, misal 1, 2, 3, 5.

## Fitur

- Kelipatan (step) diatur di halaman setting plugin, nilai 1-100.
- Nilai 100 selalu bisa dipilih walau step bukan pembagi 100.
  Contoh step 3: 0, 3, 6, ... 99, 100.
- Dua jenis input: **Slider + angka** atau **Angka saja**.
- Angka yang diketik dibulatkan ke kelipatan terdekat (step 5: 42 jadi 40, 43 jadi 45).
- Panah atas/bawah naik/turun satu kelipatan.
- Nilai lama yang bukan kelipatan (misal 37) tetap dipertahankan sampai diubah user.
- Berlaku di form new/edit issue (termasuk saat form di-refresh karena ganti tracker/status) dan bulk edit.
- Tidak ada migrasi database, tidak meng-copy view core Redmine.
- Locale: English, Bahasa Indonesia.

Batasan:

- Context menu klik kanan di daftar issue tetap kelipatan 10 (nilai tersebut tetap valid).
- Default % Done per status (Administration > Issue statuses) tetap dropdown bawaan.
- Step hanya dipaksa di UI. API REST tetap menerima nilai 0-100 berapa pun.
- Setting berlaku global untuk semua project.

## Instalasi (Redmine biasa)

```sh
cd /path/to/redmine
cp -r redmine_done_ratio_step plugins/
```

Restart Redmine, lalu lanjut ke [Konfigurasi](#konfigurasi).

## Instalasi (Redmine di Docker)

Contoh ini memakai container bernama `redmine` (image resmi `redmine`, plugin di `/usr/src/redmine/plugins`).
Jalankan dari folder yang berisi `redmine_done_ratio_step/`.

```sh
docker cp redmine_done_ratio_step redmine:/usr/src/redmine/plugins/redmine_done_ratio_step
docker exec -u root redmine chown -R redmine:redmine /usr/src/redmine/plugins/redmine_done_ratio_step
docker restart redmine
```

Plugin ini tidak punya migrasi, jadi `redmine:plugins:migrate` tidak wajib.
Catatan volume dan `docker compose` sama seperti di README `redmine_issue_comments`.

## Konfigurasi

1. **Administration > Plugins > Redmine Done Ratio Step > Configure**.
2. Isi **Kelipatan** (misal `5`) dan pilih **Jenis input**.
3. Simpan. Reload halaman issue (Ctrl+F5 jika JS lama masih ter-cache).

## Update plugin

```sh
docker cp redmine_done_ratio_step/. redmine:/usr/src/redmine/plugins/redmine_done_ratio_step/
docker exec -u root redmine chown -R redmine:redmine /usr/src/redmine/plugins/redmine_done_ratio_step
docker restart redmine
```

## Uninstall

Hapus folder plugin lalu restart Redmine. Data issue tidak berubah.

```sh
docker exec redmine rm -r /usr/src/redmine/plugins/redmine_done_ratio_step
docker restart redmine
```
