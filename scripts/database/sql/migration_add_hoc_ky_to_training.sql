-- =================================================================================
-- MIGRATION SCRIPT: Thêm cột hoc_ky vào bảng chi_tiet_hoat_dong_ren_luyen
-- Mục đích: Hỗ trợ lưu trữ điểm rèn luyện theo học kỳ
-- =================================================================================

-- Thêm cột hoc_ky vào bảng chi_tiet_hoat_dong_ren_luyen
ALTER TABLE chi_tiet_hoat_dong_ren_luyen 
ADD COLUMN IF NOT EXISTS hoc_ky CHAR(11) DEFAULT '2025_2026_1';

-- Cập nhật dữ liệu có sẵn với học kỳ mặc định
UPDATE chi_tiet_hoat_dong_ren_luyen 
SET hoc_ky = '2025_2026_1' 
WHERE hoc_ky IS NULL;

-- Thêm comment cho cột mới
COMMENT ON COLUMN chi_tiet_hoat_dong_ren_luyen.hoc_ky IS 'Học kỳ mà sinh viên tham gia hoạt động rèn luyện (ví dụ: 2025_2026_1)';

-- Kiểm tra kết quả
SELECT 
    table_name, 
    column_name, 
    data_type, 
    column_default 
FROM information_schema.columns 
WHERE table_name = 'chi_tiet_hoat_dong_ren_luyen' 
    AND column_name = 'hoc_ky';
