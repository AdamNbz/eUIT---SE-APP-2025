        kq.mssv,
        sv.ho_ten,
        kq.ma_lop,
        kq.ma_lop_goc,
        kq.diem_qua_trinh,
        kq.diem_giua_ky,
        kq.diem_thuc_hanh,
        kq.diem_cuoi_ky,
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
        kq.ghi_chu
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
        kq.mssv,
        sv.ho_ten,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
        kq.ma_lop,
        kq.ma_lop_goc,
        kq.diem_qua_trinh,
        kq.diem_giua_ky,
        kq.diem_thuc_hanh,
        kq.diem_cuoi_ky,
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
        kq.ghi_chu,
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
