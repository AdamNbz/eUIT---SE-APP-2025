-- ============================================================================
-- LECTURER PROFILE & COURSE MANAGEMENT FUNCTIONS
-- Part 1 of 4: Profile and Course Operations
-- ============================================================================

-- Get lecturer profile from giang_vien table
CREATE OR REPLACE FUNCTION func_get_lecturer_profile(
    p_ma_giang_vien TEXT
)
RETURNS TABLE (
    ma_giang_vien CHARACTER(5),
    ho_ten VARCHAR(50),
    khoa_bo_mon CHARACTER(5),
    ngay_sinh DATE,
    noi_sinh VARCHAR(200),
    cccd CHARACTER(12),
    ngay_cap_cccd DATE,
    noi_cap_cccd VARCHAR(50),
    dan_toc VARCHAR(10),
    ton_giao VARCHAR(20),
    so_dien_thoai CHARACTER(10),
    dia_chi_thuong_tru VARCHAR(200),
    tinh_thanh_pho VARCHAR(20),
    phuong_xa TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gv.ma_giang_vien,
        gv.ho_ten,
        gv.khoa_bo_mon,
        gv.ngay_sinh,
        gv.noi_sinh,
        gv.cccd,
        gv.ngay_cap_cccd,
        gv.noi_cap_cccd,
        gv.dan_toc,
        gv.ton_giao,
        gv.so_dien_thoai,
        gv.dia_chi_thuong_tru,
        gv.tinh_thanh_pho,
        gv.phuong_xa
    FROM giang_vien gv
    WHERE gv.ma_giang_vien = p_ma_giang_vien::CHARACTER(5);
END;
$$;

-- Update lecturer profile
CREATE OR REPLACE FUNCTION func_update_lecturer_profile(
    p_ma_giang_vien TEXT,
    p_so_dien_thoai TEXT,
    p_dia_chi_thuong_tru TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE giang_vien
    SET 
        so_dien_thoai = CASE WHEN p_so_dien_thoai <> '' THEN p_so_dien_thoai::CHARACTER(10) ELSE so_dien_thoai END,
        dia_chi_thuong_tru = CASE WHEN p_dia_chi_thuong_tru <> '' THEN p_dia_chi_thuong_tru ELSE dia_chi_thuong_tru END
    WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5);
END;
$$;

-- Get courses taught by lecturer from thoi_khoa_bieu
CREATE OR REPLACE FUNCTION func_get_lecturer_courses(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT DEFAULT ''
)
RETURNS TABLE (
    hoc_ky CHARACTER(11),
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHARACTER(20),
    so_tin_chi INTEGER,
    si_so INTEGER,
    phong_hoc VARCHAR(10),
    hinh_thuc_giang_day CHARACTER(5)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        tkb.hoc_ky,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        tkb.ma_lop,
        tkb.so_tin_chi,
        tkb.si_so,
        tkb.phong_hoc,
        tkb.hinh_thuc_giang_day
    FROM thoi_khoa_bieu tkb
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky::CHARACTER(11))
    ORDER BY tkb.hoc_ky DESC, tkb.ma_lop;
END;
$$;

-- Get course detail
CREATE OR REPLACE FUNCTION func_get_lecturer_course_detail(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    hoc_ky CHARACTER(11),
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc_vn VARCHAR(255),
    ten_mon_hoc_en VARCHAR(255),
    ma_lop CHARACTER(20),
    so_tin_chi INTEGER,
    si_so INTEGER,
    phong_hoc VARCHAR(10),
    thu CHARACTER(2),
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    cach_tuan INTEGER,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    hinh_thuc_giang_day CHARACTER(5),
    ghi_chu VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tkb.hoc_ky,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        mh.ten_mon_hoc_en,
        tkb.ma_lop,
        tkb.so_tin_chi,
        tkb.si_so,
        tkb.phong_hoc,
        tkb.thu,
        tkb.tiet_bat_dau,
        tkb.tiet_ket_thuc,
        tkb.cach_tuan,
        tkb.ngay_bat_dau,
        tkb.ngay_ket_thuc,
        tkb.hinh_thuc_giang_day,
        tkb.ghi_chu
    FROM thoi_khoa_bieu tkb
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND tkb.ma_lop = p_ma_lop::CHARACTER(20)
    LIMIT 1;
END;
$$;

-- Get lecturer schedule
CREATE OR REPLACE FUNCTION func_get_lecturer_schedule(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT DEFAULT '',
    p_start_date DATE DEFAULT CURRENT_DATE,
    p_end_date DATE DEFAULT CURRENT_DATE + INTERVAL '7 days'
)
RETURNS TABLE (
    hoc_ky CHARACTER(11),
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHARACTER(20),
    thu CHARACTER(2),
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    phong_hoc VARCHAR(10),
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    cach_tuan INTEGER,
    hinh_thuc_giang_day CHARACTER(5)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tkb.hoc_ky,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        tkb.ma_lop,
        tkb.thu,
        tkb.tiet_bat_dau,
        tkb.tiet_ket_thuc,
        tkb.phong_hoc,
        tkb.ngay_bat_dau,
        tkb.ngay_ket_thuc,
        tkb.cach_tuan,
        tkb.hinh_thuc_giang_day
    FROM thoi_khoa_bieu tkb
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky::CHARACTER(11))
        AND (
            (tkb.ngay_bat_dau IS NULL) OR
            (tkb.ngay_bat_dau <= p_end_date AND tkb.ngay_ket_thuc >= p_start_date)
        )
    ORDER BY tkb.thu, tkb.tiet_bat_dau;
END;
$$;

