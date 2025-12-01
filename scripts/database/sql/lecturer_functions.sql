-- ============================================================================
-- LECTURER CONTROLLER SQL FUNCTIONS
-- Rewritten to match REAL PostgreSQL Database Schema
-- ============================================================================

-- ============================================================================
-- PROFILE MANAGEMENT FUNCTIONS
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

-- ============================================================================
-- COURSE MANAGEMENT FUNCTIONS
-- ============================================================================

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
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_DATE,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_DATE + INTERVAL '7 days'
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

-- ============================================================================
-- GRADE MANAGEMENT FUNCTIONS
-- ============================================================================

-- Get grades for all students in a class
CREATE OR REPLACE FUNCTION func_get_lecturer_class_grades(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    ma_lop CHARACTER(20),
    ma_lop_goc CHARACTER(20),
    diem_qua_trinh NUMERIC,
    diem_giua_ky NUMERIC,
    diem_thuc_hanh NUMERIC,
    diem_cuoi_ky NUMERIC,
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2),
    ghi_chu VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RAISE EXCEPTION 'Lecturer does not teach this class';
    END IF;

    RETURN QUERY
    SELECT 
        kq.mssv AS mssv,
        sv.ho_ten AS ho_ten,
        kq.ma_lop AS ma_lop,
        kq.ma_lop_goc AS ma_lop_goc,
        kq.diem_qua_trinh AS diem_qua_trinh,
        kq.diem_giua_ky AS diem_giua_ki,
        kq.diem_thuc_hanh AS diem_thuc_hanh,
        kq.diem_cuoi_ky AS diem_cuoi_ki,
        -- Calculate diem_tong_ket based on weights from bang_diem
        (
            COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
            COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
            COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
            COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
        ) AS diem_tong_ket,
        CASE
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 8.5 THEN 'A'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 7.0 THEN 'B'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 5.5 THEN 'C'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 4.0 THEN 'D'
            ELSE 'F'
        END AS diem_chu,
        kq.ghi_chu AS ghi_chu
    FROM ket_qua_hoc_tap kq
    INNER JOIN sinh_vien sv ON kq.mssv = sv.mssv
    LEFT JOIN bang_diem bd ON kq.ma_lop_goc = bd.ma_lop_goc
    WHERE kq.ma_lop = p_ma_lop::CHARACTER(20)
    ORDER BY sv.ho_ten;
END;
$$;

-- Get student grade detail
CREATE OR REPLACE FUNCTION func_get_lecturer_student_grade(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHARACTER(20),
    ma_lop_goc CHARACTER(20),
    diem_qua_trinh NUMERIC,
    diem_giua_ky NUMERIC,
    diem_thuc_hanh NUMERIC,
    diem_cuoi_ky NUMERIC,
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2),
    ghi_chu VARCHAR(20),
    trong_so_qua_trinh INTEGER,
    trong_so_giua_ki INTEGER,
    trong_so_thuc_hanh INTEGER,
    trong_so_cuoi_ki INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RAISE EXCEPTION 'Lecturer does not teach this class';
    END IF;

    RETURN QUERY
    SELECT 
        kq.mssv AS mssv,
        sv.ho_ten AS ho_ten,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        kq.ma_lop,
        kq.ma_lop_goc,
        kq.diem_qua_trinh AS diem_qua_trinh,
        kq.diem_giua_ky AS diem_giua_ki,
        kq.diem_thuc_hanh AS diem_thuc_hanh,
        kq.diem_cuoi_ky AS diem_cuoi_ki,
        (
            COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
            COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
            COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
            COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
        ) AS diem_tong_ket,
        CASE
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 8.5 THEN 'A'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 7.0 THEN 'B'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 5.5 THEN 'C'
            WHEN (
                COALESCE(kq.diem_qua_trinh, 0) * COALESCE(bd.trong_so_qua_trinh, 0) / 100.0 +
                COALESCE(kq.diem_giua_ky, 0) * COALESCE(bd.trong_so_giua_ki, 0) / 100.0 +
                COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(bd.trong_so_thuc_hanh, 0) / 100.0 +
                COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(bd.trong_so_cuoi_ki, 0) / 100.0
            ) >= 4.0 THEN 'D'
            ELSE 'F'
        END AS diem_chu,
        kq.ghi_chu AS ghi_chu,
        bd.trong_so_qua_trinh,
        bd.trong_so_giua_ki,
        bd.trong_so_thuc_hanh,
        bd.trong_so_cuoi_ki
    FROM ket_qua_hoc_tap kq
    INNER JOIN sinh_vien sv ON kq.mssv = sv.mssv
    INNER JOIN thoi_khoa_bieu tkb ON kq.ma_lop = tkb.ma_lop
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    LEFT JOIN bang_diem bd ON kq.ma_lop_goc = bd.ma_lop_goc
    WHERE kq.mssv = p_mssv
        AND kq.ma_lop = p_ma_lop::CHARACTER(20)
        AND tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
    LIMIT 1;
END;
$$;

-- Update student grade
CREATE OR REPLACE FUNCTION func_lecturer_update_grade(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_ma_lop TEXT,
    p_diem_qua_trinh NUMERIC DEFAULT NULL,
    p_diem_giua_ky NUMERIC DEFAULT NULL,
    p_diem_thuc_hanh NUMERIC DEFAULT NULL,
    p_diem_cuoi_ky NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    hoc_ky CHARACTER(11),
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ma_mon_hoc CHARACTER(8);
    v_ten_mon_hoc VARCHAR(255);
    v_hoc_ky CHARACTER(11);
    v_ma_lop_goc CHARACTER(20);
    v_diem_tong_ket NUMERIC;
    v_diem_chu VARCHAR(2);
    v_trong_so_qt INTEGER;
    v_trong_so_gk INTEGER;
    v_trong_so_th INTEGER;
    v_trong_so_ck INTEGER;
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RETURN QUERY SELECT FALSE, 'Lecturer does not teach this class'::TEXT, 
            NULL::CHARACTER(8), NULL::VARCHAR(255), NULL::CHARACTER(11), 
            NULL::NUMERIC, NULL::VARCHAR(2);
        RETURN;
    END IF;

    -- Get course info
    SELECT tkb.ma_mon_hoc, mh.ten_mon_hoc_vn, tkb.hoc_ky
    INTO v_ma_mon_hoc, v_ten_mon_hoc, v_hoc_ky
    FROM thoi_khoa_bieu tkb
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.ma_lop = p_ma_lop::CHARACTER(20)
    LIMIT 1;

    -- Get ma_lop_goc
    SELECT ma_lop_goc INTO v_ma_lop_goc
    FROM ket_qua_hoc_tap
    WHERE mssv = p_mssv AND ma_lop = p_ma_lop::CHARACTER(20)
    LIMIT 1;

    -- Get weights
    SELECT trong_so_qua_trinh, trong_so_giua_ki, trong_so_thuc_hanh, trong_so_cuoi_ki
    INTO v_trong_so_qt, v_trong_so_gk, v_trong_so_th, v_trong_so_ck
    FROM bang_diem
    WHERE ma_lop_goc = v_ma_lop_goc
    LIMIT 1;

    -- Update grades
    UPDATE ket_qua_hoc_tap
    SET 
        diem_qua_trinh = COALESCE(p_diem_qua_trinh, diem_qua_trinh),
        diem_giua_ky = COALESCE(p_diem_giua_ky, diem_giua_ky),
        diem_thuc_hanh = COALESCE(p_diem_thuc_hanh, diem_thuc_hanh),
        diem_cuoi_ky = COALESCE(p_diem_cuoi_ky, diem_cuoi_ky)
    WHERE mssv = p_mssv 
        AND ma_lop = p_ma_lop::CHARACTER(20);

    -- Calculate final grade
    SELECT 
        (
            COALESCE(kq.diem_qua_trinh, 0) * COALESCE(v_trong_so_qt, 0) / 100.0 +
            COALESCE(kq.diem_giua_ky, 0) * COALESCE(v_trong_so_gk, 0) / 100.0 +
            COALESCE(kq.diem_thuc_hanh, 0) * COALESCE(v_trong_so_th, 0) / 100.0 +
            COALESCE(kq.diem_cuoi_ky, 0) * COALESCE(v_trong_so_ck, 0) / 100.0
        )
    INTO v_diem_tong_ket
    FROM ket_qua_hoc_tap kq
    WHERE kq.mssv = p_mssv AND kq.ma_lop = p_ma_lop::CHARACTER(20);

    -- Calculate letter grade
    v_diem_chu := CASE
        WHEN v_diem_tong_ket >= 8.5 THEN 'A'
        WHEN v_diem_tong_ket >= 7.0 THEN 'B'
        WHEN v_diem_tong_ket >= 5.5 THEN 'C'
        WHEN v_diem_tong_ket >= 4.0 THEN 'D'
        ELSE 'F'
    END;

    RETURN QUERY SELECT TRUE, 'Grade updated successfully'::TEXT, 
        v_ma_mon_hoc, v_ten_mon_hoc, v_hoc_ky, v_diem_tong_ket, v_diem_chu;
END;
$$;

-- ============================================================================
-- EXAM MANAGEMENT FUNCTIONS
-- ============================================================================

-- Get lecturer exams
CREATE OR REPLACE FUNCTION func_get_lecturer_exams(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT DEFAULT '',
    p_exam_type TEXT DEFAULT ''
)
RETURNS TABLE (
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHARACTER(20),
    ngay_thi DATE,
    ca_thi INTEGER,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR(20),
    gk_ck CHARACTER(2),
    si_so INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lt.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        lt.ma_lop,
        lt.ngay_thi,
        lt.ca_thi,
        lt.phong_thi,
        lt.hinh_thuc_thi,
        lt.gk_ck,
        tkb.si_so
    FROM lich_thi lt
    INNER JOIN thoi_khoa_bieu tkb ON lt.ma_lop = tkb.ma_lop
    LEFT JOIN mon_hoc mh ON lt.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky::CHARACTER(11))
        AND (p_exam_type = '' OR lt.gk_ck = p_exam_type::CHARACTER(2))
    ORDER BY lt.ngay_thi, lt.ca_thi;
END;
$$;

-- Get exam detail
CREATE OR REPLACE FUNCTION func_get_lecturer_exam_detail(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    ma_mon_hoc CHARACTER(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHARACTER(20),
    ngay_thi DATE,
    ca_thi INTEGER,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR(20),
    gk_ck CHARACTER(2),
    si_so INTEGER,
    giam_thi_1 CHARACTER(5),
    giam_thi_2 CHARACTER(5)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lt.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        lt.ma_lop,
        lt.ngay_thi,
        lt.ca_thi,
        lt.phong_thi,
        lt.hinh_thuc_thi,
        lt.gk_ck,
        tkb.si_so,
        ct.giam_thi_1,
        ct.giam_thi_2
    FROM lich_thi lt
    INNER JOIN thoi_khoa_bieu tkb ON lt.ma_lop = tkb.ma_lop
    LEFT JOIN mon_hoc mh ON lt.ma_mon_hoc = mh.ma_mon_hoc
    LEFT JOIN coi_thi ct ON lt.ma_lop = ct.ma_lop AND lt.phong_thi = ct.phong_thi
    WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND lt.ma_lop = p_ma_lop::CHARACTER(20)
    LIMIT 1;
END;
$$;

-- Get exam students
CREATE OR REPLACE FUNCTION func_get_exam_students(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    lop_sinh_hoat CHARACTER(10),
    phong_thi VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RAISE EXCEPTION 'Lecturer does not teach this class';
    END IF;

    RETURN QUERY
    SELECT 
        sv.mssv,
        sv.ho_ten,
        sv.lop_sinh_hoat,
        lt.phong_thi
    FROM ket_qua_hoc_tap kq
    INNER JOIN sinh_vien sv ON kq.mssv = sv.mssv
    LEFT JOIN lich_thi lt ON kq.ma_lop = lt.ma_lop
    WHERE kq.ma_lop = p_ma_lop::CHARACTER(20)
    ORDER BY sv.ho_ten;
END;
$$;

-- ============================================================================
-- ADMINISTRATIVE FUNCTIONS
-- ============================================================================

-- Create confirmation letter for student
CREATE OR REPLACE FUNCTION func_lecturer_create_confirmation_letter(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_purpose TEXT
)
RETURNS TABLE (
    serial_number INTEGER,
    expiry_date TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_serial_number INTEGER;
    v_expiry_date TIMESTAMP;
BEGIN
    -- Verify student exists
    IF NOT EXISTS (SELECT 1 FROM sinh_vien WHERE mssv = p_mssv) THEN
        RAISE EXCEPTION 'Student not found';
    END IF;

    -- Generate serial number (simple incrementing)
    SELECT COALESCE(MAX(serial_number), 0) + 1 INTO v_serial_number
    FROM confirmation_letters;

    -- Set expiry date (30 days from now)
    v_expiry_date := NOW() + INTERVAL '30 days';

    -- Insert confirmation letter
    INSERT INTO confirmation_letters (mssv, purpose, serial_number, expiry_date, status)
    VALUES (p_mssv, p_purpose, v_serial_number, v_expiry_date, 'approved');

    RETURN QUERY SELECT v_serial_number, v_expiry_date;
END;
$$;

-- Get student tuition info
CREATE OR REPLACE FUNCTION func_get_student_tuition(
    p_mssv INTEGER,
    p_hoc_ky TEXT DEFAULT ''
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    hoc_ky CHARACTER(11),
    so_tin_chi INTEGER,
    hoc_phi NUMERIC,
    no_hoc_ky_truoc DOUBLE PRECISION,
    da_dong DOUBLE PRECISION,
    so_tien_con_lai DOUBLE PRECISION,
    don_gia_tin_chi INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hp.mssv,
        sv.ho_ten,
        hp.hoc_ky,
        hp.so_tin_chi,
        hp.hoc_phi,
        hp.no_hoc_ky_truoc,
        hp.da_dong,
        hp.so_tien_con_lai,
        hp.don_gia_tin_chi
    FROM hoc_phi hp
    INNER JOIN sinh_vien sv ON hp.mssv = sv.mssv
    WHERE hp.mssv = p_mssv
        AND (p_hoc_ky = '' OR hp.hoc_ky = p_hoc_ky::CHARACTER(11))
    ORDER BY hp.hoc_ky DESC
    LIMIT 1;
END;
$$;

-- ============================================================================
-- APPEALS MANAGEMENT FUNCTIONS
-- ============================================================================

-- Get lecturer appeals
CREATE OR REPLACE FUNCTION func_get_lecturer_appeals(
    p_ma_giang_vien TEXT,
    p_status TEXT DEFAULT ''
)
RETURNS TABLE (
    id INTEGER,
    mssv INTEGER,
    ho_ten VARCHAR(50),
    course_id VARCHAR(20),
    course_name VARCHAR(255),
    reason TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.mssv,
        sv.ho_ten,
        a.course_id,
        mh.ten_mon_hoc_vn,
        a.reason,
        a.payment_method,
        a.payment_status,
        a.status,
        a.created_at
    FROM appeals a
    INNER JOIN sinh_vien sv ON a.mssv = sv.mssv
    LEFT JOIN mon_hoc mh ON a.course_id::CHARACTER(8) = mh.ma_mon_hoc
    WHERE EXISTS (
        SELECT 1 FROM thoi_khoa_bieu tkb
        WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND tkb.ma_mon_hoc = a.course_id::CHARACTER(8)
    )
    AND (p_status = '' OR a.status = p_status::VARCHAR(20))
    ORDER BY a.created_at DESC;
END;
$$;

-- Get appeal detail
CREATE OR REPLACE FUNCTION func_get_lecturer_appeal_detail(
    p_ma_giang_vien TEXT,
    p_appeal_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    mssv INTEGER,
    ho_ten VARCHAR(50),
    course_id VARCHAR(20),
    course_name VARCHAR(255),
    reason TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.mssv,
        sv.ho_ten,
        a.course_id,
        mh.ten_mon_hoc_vn,
        a.reason,
        a.payment_method,
        a.payment_status,
        a.status,
        a.created_at,
        a.updated_at
    FROM appeals a
    INNER JOIN sinh_vien sv ON a.mssv = sv.mssv
    LEFT JOIN mon_hoc mh ON a.course_id::CHARACTER(8) = mh.ma_mon_hoc
    WHERE a.id = p_appeal_id
    AND EXISTS (
        SELECT 1 FROM thoi_khoa_bieu tkb
        WHERE tkb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND tkb.ma_mon_hoc = a.course_id::CHARACTER(8)
    )
    LIMIT 1;
END;
$$;

-- Process appeal
CREATE OR REPLACE FUNCTION func_lecturer_process_appeal(
    p_ma_giang_vien TEXT,
    p_appeal_id INTEGER,
    p_status TEXT,
    p_comment TEXT DEFAULT ''
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_course_id VARCHAR(20);
BEGIN
    -- Get course_id from appeal
    SELECT course_id INTO v_course_id
    FROM appeals
    WHERE id = p_appeal_id;

    -- Verify lecturer teaches this course
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_mon_hoc = v_course_id::CHARACTER(8)
    ) THEN
        RETURN QUERY SELECT FALSE, 'You do not have permission to process this appeal'::TEXT;
        RETURN;
    END IF;

    -- Update appeal status
    UPDATE appeals
    SET 
        status = p_status::VARCHAR(20),
        updated_at = NOW()
    WHERE id = p_appeal_id;

    RETURN QUERY SELECT TRUE, 'Appeal processed successfully'::TEXT;
END;
$$;

-- ============================================================================
-- NOTIFICATION FUNCTIONS
-- ============================================================================

-- Get lecturer notifications (from thong_bao table)
CREATE OR REPLACE FUNCTION func_get_lecturer_notifications(
    p_ma_giang_vien TEXT,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id INTEGER,
    tieu_de VARCHAR(100),
    noi_dung TEXT,
    ngay_tao DATE,
    ngay_cap_nhat DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tb.id,
        tb.tieu_de,
        tb.noi_dung,
        tb.ngay_tao,
        tb.ngay_cap_nhat
    FROM thong_bao tb
    ORDER BY tb.ngay_tao DESC, tb.id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- Mark notification as read (placeholder - actual implementation depends on requirements)
CREATE OR REPLACE FUNCTION func_mark_notification_read(
    p_ma_giang_vien TEXT,
    p_notification_id INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- This is a placeholder since thong_bao doesn't have read status
    -- You might need to create a separate table for tracking read notifications
    NULL;
END;
$$;

-- ============================================================================
-- ABSENCE & MAKEUP CLASS FUNCTIONS
-- ============================================================================

-- Report absence
CREATE OR REPLACE FUNCTION func_lecturer_report_absence(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT,
    p_ngay_nghi DATE,
    p_ly_do TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    absence_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_absence_id INTEGER;
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RETURN QUERY SELECT FALSE, 'You do not teach this class'::TEXT, 0;
        RETURN;
    END IF;

    -- Insert absence record
    INSERT INTO bao_nghi_day (ma_lop, ma_giang_vien, ly_do, ngay_nghi, tinh_trang)
    VALUES (
        p_ma_lop::CHARACTER(20),
        p_ma_giang_vien::CHARACTER(5),
        p_ly_do::VARCHAR(200),
        p_ngay_nghi,
        'pending'::VARCHAR(20)
    )
    RETURNING id INTO v_absence_id;

    RETURN QUERY SELECT TRUE, 'Absence reported successfully'::TEXT, v_absence_id;
END;
$$;

-- Schedule makeup class
CREATE OR REPLACE FUNCTION func_lecturer_schedule_makeup(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT,
    p_ngay_hoc_bu DATE,
    p_tiet_bat_dau INTEGER,
    p_tiet_ket_thuc INTEGER,
    p_phong_hoc TEXT,
    p_ly_do TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    makeup_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_makeup_id INTEGER;
BEGIN
    -- Verify lecturer teaches this class
    IF NOT EXISTS (
        SELECT 1 FROM thoi_khoa_bieu 
        WHERE ma_giang_vien = p_ma_giang_vien::CHARACTER(5) 
        AND ma_lop = p_ma_lop::CHARACTER(20)
    ) THEN
        RETURN QUERY SELECT FALSE, 'You do not teach this class'::TEXT, 0;
        RETURN;
    END IF;

    -- Insert makeup class record
    INSERT INTO bao_hoc_bu (ma_lop, ma_giang_vien, ly_do, ngay_hoc_bu, tiet_bat_dau, tiet_ket_thuc, tinh_trang)
    VALUES (
        p_ma_lop::CHARACTER(20),
        p_ma_giang_vien::CHARACTER(5),
        p_ly_do::VARCHAR(200),
        p_ngay_hoc_bu,
        p_tiet_bat_dau,
        p_tiet_ket_thuc,
        'pending'::VARCHAR(20)
    )
    RETURNING id INTO v_makeup_id;

    RETURN QUERY SELECT TRUE, 'Makeup class scheduled successfully'::TEXT, v_makeup_id;
END;
$$;

-- Get lecturer absences
CREATE OR REPLACE FUNCTION func_get_lecturer_absences(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT DEFAULT ''
)
RETURNS TABLE (
    id INTEGER,
    ma_lop CHARACTER(20),
    ten_mon_hoc VARCHAR(255),
    ngay_nghi DATE,
    ly_do VARCHAR(200),
    tinh_trang VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bnd.id,
        bnd.ma_lop,
        mh.ten_mon_hoc_vn,
        bnd.ngay_nghi,
        bnd.ly_do,
        bnd.tinh_trang
    FROM bao_nghi_day bnd
    INNER JOIN thoi_khoa_bieu tkb ON bnd.ma_lop = tkb.ma_lop
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE bnd.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky::CHARACTER(11))
    ORDER BY bnd.ngay_nghi DESC;
END;
$$;

-- Get lecturer makeup classes
CREATE OR REPLACE FUNCTION func_get_lecturer_makeup_classes(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT DEFAULT ''
)
RETURNS TABLE (
    id INTEGER,
    ma_lop CHARACTER(20),
    ten_mon_hoc VARCHAR(255),
    ngay_hoc_bu DATE,
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    phong_hoc VARCHAR(10),
    ly_do VARCHAR(200),
    tinh_trang VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bhb.id,
        bhb.ma_lop,
        mh.ten_mon_hoc_vn,
        bhb.ngay_hoc_bu,
        bhb.tiet_bat_dau,
        bhb.tiet_ket_thuc,
        tkb.phong_hoc,
        bhb.ly_do,
        bhb.tinh_trang
    FROM bao_hoc_bu bhb
    INNER JOIN thoi_khoa_bieu tkb ON bhb.ma_lop = tkb.ma_lop
    LEFT JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE bhb.ma_giang_vien = p_ma_giang_vien::CHARACTER(5)
        AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky::CHARACTER(11))
    ORDER BY bhb.ngay_hoc_bu DESC;
END;
$$;

-- ============================================================================
-- END OF LECTURER FUNCTIONS
-- ============================================================================

