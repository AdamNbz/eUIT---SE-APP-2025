-- Fix placeholder "string" values in giang_vien table
-- Run this script to clean up test/mock data

-- Update giang_vien table - remove "string" placeholders
UPDATE giang_vien 
SET so_dien_thoai = NULL
WHERE so_dien_thoai = 'string';

UPDATE giang_vien 
SET dia_chi_thuong_tru = NULL
WHERE dia_chi_thuong_tru = 'string';

UPDATE giang_vien 
SET email = NULL
WHERE email = 'string';

-- Also check sinh_vien table
UPDATE sinh_vien 
SET so_dien_thoai = NULL
WHERE so_dien_thoai = 'string';

UPDATE sinh_vien 
SET dia_chi_thuong_tru = NULL
WHERE dia_chi_thuong_tru = 'string';

UPDATE sinh_vien 
SET email_ca_nhan = NULL
WHERE email_ca_nhan = 'string';

-- Verify changes
SELECT 'Giang vien with string values:' as message, COUNT(*) as count
FROM giang_vien 
WHERE so_dien_thoai = 'string' 
   OR dia_chi_thuong_tru = 'string'
   OR email = 'string';

SELECT 'Sinh vien with string values:' as message, COUNT(*) as count
FROM sinh_vien 
WHERE so_dien_thoai = 'string' 
   OR dia_chi_thuong_tru = 'string'
   OR email_ca_nhan = 'string';
