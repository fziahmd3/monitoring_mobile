# Solusi Masalah Database - Progress Hafalan Santri

## Masalah yang Ditemui

### Error Database
```
sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError) (1054, "Unknown column 'PenilaianHafalan.guru_id' in 'field list'")
```

### Analisis Masalah
- Model `PenilaianHafalan` di Python memiliki kolom `guru_id`
- Database MySQL tidak memiliki kolom `guru_id` di tabel `PenilaianHafalan`
- Migration untuk menambahkan kolom `guru_id` belum dijalankan
- SQLAlchemy mencoba mengakses kolom yang tidak ada di database

## Solusi yang Diterapkan

### 1. Migration Database
Membuat dan menjalankan migration untuk menambahkan kolom `guru_id`:

#### File Migration: `monitoring_app/migrations/versions/add_guru_id_to_penilaianhafalan.py`
```python
"""add guru_id column to PenilaianHafalan table

Revision ID: add_guru_id_penilaian
Revises: 7ec29af99622
Create Date: 2025-01-27 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    # Add guru_id column to PenilaianHafalan table
    op.add_column('PenilaianHafalan', sa.Column('guru_id', sa.Integer(), nullable=True))
    
    # Add foreign key constraint
    op.create_foreign_key(
        'fk_penilaianhafalan_guru_id',
        'PenilaianHafalan', 'Guru',
        ['guru_id'], ['guru_id']
    )

def downgrade():
    # Remove foreign key constraint
    op.drop_constraint('fk_penilaianhafalan_guru_id', 'PenilaianHafalan', type_='foreignkey')
    
    # Remove guru_id column
    op.drop_column('PenilaianHafalan', 'guru_id')
```

### 2. Script Migration Manual
Membuat script untuk menjalankan migration secara manual:

#### File: `monitoring_app/run_migration.py`
```python
#!/usr/bin/env python3
"""
Script untuk menjalankan migration secara manual
"""
import os
import sys
from alembic import command
from alembic.config import Config

def run_migration():
    # Set up Alembic configuration
    alembic_cfg = Config("migrations/alembic.ini")
    
    try:
        # Run the migration
        print("Running migration to add guru_id column...")
        command.upgrade(alembic_cfg, "add_guru_id_penilaian")
        print("Migration completed successfully!")
        
    except Exception as e:
        print(f"Error running migration: {e}")
        return False
    
    return True

if __name__ == "__main__":
    # Set environment variable
    os.environ['FLASK_APP'] = 'run.py'
    
    # Run migration
    success = run_migration()
    
    if success:
        print("Database updated successfully!")
    else:
        print("Failed to update database.")
        sys.exit(1)
```

### 3. Update Model Database
Mengubah model `PenilaianHafalan` untuk membuat `guru_id` nullable:

#### File: `monitoring_app/app/models.py`
```python
class PenilaianHafalan(db.Model):
    __tablename__ = 'PenilaianHafalan'
    penilaian_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    santri_id = db.Column(db.Integer, db.ForeignKey('Santri.santri_id'), nullable=False)
    guru_id = db.Column(db.Integer, db.ForeignKey('Guru.guru_id'), nullable=True) # Tambahkan field guru (nullable untuk data lama)
    surat = db.Column(db.String(50), nullable=False)
    dari_ayat = db.Column(db.Integer, nullable=False)
    sampai_ayat = db.Column(db.Integer, nullable=False)
    penilaian_tajwid = db.Column(db.Integer, nullable=False)
    kelancaran = db.Column(db.Integer, nullable=False)
    kefasihan = db.Column(db.Integer, nullable=False)
    catatan = db.Column(db.Text, nullable=True)
    hasil_naive_bayes = db.Column(db.String(50), nullable=False, default='Belum Diprediksi')
    tanggal_penilaian = db.Column(db.DateTime, default=db.func.current_timestamp())

    santri = db.relationship('Santri', backref=db.backref('penilaian_hafalan', lazy=True))
    guru = db.relationship('Guru', backref=db.backref('penilaian_hafalan', lazy=True))
```

### 4. Aktifkan guru_id di API
Mengaktifkan penggunaan `guru_id` di endpoint penilaian:

#### File: `monitoring_app/app/routes.py`
```python
# Simpan penilaian dengan guru_id
penilaian = PenilaianHafalan(
    santri_id=santri.santri_id,
    guru_id=guru.guru_id, # Aktifkan guru_id setelah migration
    surat=surat,
    dari_ayat=dari_ayat,
    sampai_ayat=sampai_ayat,
    penilaian_tajwid=penilaian_tajwid,
    kelancaran=kelancaran,
    kefasihan=kefasihan,
    catatan=catatan,
    hasil_naive_bayes=hasil_prediksi_naive_bayes
)
```

## Langkah-langkah Implementasi

### 1. Jalankan Migration
```bash
cd monitoring_app
python run_migration.py
```

### 2. Verifikasi Database
```sql
-- Periksa struktur tabel
DESCRIBE PenilaianHafalan;

-- Periksa foreign key
SHOW CREATE TABLE PenilaianHafalan;
```

### 3. Test API Endpoint
```bash
# Test endpoint daftar santri
curl https://constantly-disco-failed-baghdad.trycloudflare.com/api/daftar_santri

# Test endpoint penilaian santri
curl https://constantly-disco-failed-baghdad.trycloudflare.com/api/santri/SANTRI001/penilaian
```

## Hasil yang Diharapkan

### 1. Database Structure
- Tabel `PenilaianHafalan` memiliki kolom `guru_id`
- Foreign key constraint ke tabel `Guru`
- Kolom `guru_id` nullable untuk kompatibilitas data lama

### 2. API Functionality
- Endpoint `/api/santri/{kode_santri}/penilaian` berfungsi normal
- Tidak ada error database saat mengakses data penilaian
- Data penilaian dapat ditampilkan di aplikasi mobile

### 3. Mobile App
- Fitur "Progress Santri" berfungsi dengan baik
- Guru dapat melihat progress hafalan santri
- Tidak ada error 404 atau database error

## Monitoring dan Verifikasi

### 1. Log Monitoring
Periksa log aplikasi untuk:
- Tidak ada error database
- API endpoint berfungsi normal
- Response status 200 untuk endpoint penilaian

### 2. Database Monitoring
```sql
-- Periksa data penilaian
SELECT * FROM PenilaianHafalan LIMIT 5;

-- Periksa foreign key
SELECT 
    p.penilaian_id,
    p.surat,
    s.nama_lengkap as santri_nama,
    g.nama_lengkap as guru_nama
FROM PenilaianHafalan p
JOIN Santri s ON p.santri_id = s.santri_id
LEFT JOIN Guru g ON p.guru_id = g.guru_id;
```

### 3. API Testing
- Test endpoint dengan data real
- Verifikasi response format
- Test dengan berbagai kode santri

## Prevention Measures

### 1. Migration Management
- Selalu jalankan migration sebelum deploy
- Backup database sebelum migration
- Test migration di environment development

### 2. Model Consistency
- Pastikan model Python sesuai dengan database
- Gunakan nullable=True untuk kolom opsional
- Dokumentasikan perubahan model

### 3. API Testing
- Test semua endpoint setelah perubahan database
- Monitor error logs secara regular
- Implementasi health check endpoint

## Troubleshooting

### Jika Migration Gagal
1. Backup database
2. Rollback migration: `flask db downgrade`
3. Periksa error log
4. Fix migration script
5. Jalankan ulang migration

### Jika API Masih Error
1. Restart Flask server
2. Periksa database connection
3. Verifikasi model import
4. Test endpoint manual

### Jika Mobile App Error
1. Clear app cache
2. Restart aplikasi
3. Periksa API response
4. Test dengan data baru

## Kesimpulan

Masalah database telah berhasil diatasi dengan:
1. ✅ Menambahkan kolom `guru_id` ke tabel `PenilaianHafalan`
2. ✅ Membuat foreign key constraint
3. ✅ Mengaktifkan penggunaan `guru_id` di API
4. ✅ Memastikan kompatibilitas dengan data lama

Fitur "Progress Hafalan Santri" sekarang seharusnya berfungsi dengan baik tanpa error database. 