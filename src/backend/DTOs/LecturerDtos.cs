namespace eUIT.API.DTOs;

// ========================================
// PROFILE DTOs - Based on giang_vien table
// ========================================

public sealed record LecturerProfileDto
{
    public string MaGiangVien { get; init; } = "";
    public string HoTen { get; init; } = "";
    public string? KhoaBoMon { get; init; }
    public DateTime? NgaySinh { get; init; }
    public string? NoiSinh { get; init; }
    public string? Cccd { get; init; }
    public DateTime? NgayCapCccd { get; init; }
    public string? NoiCapCccd { get; init; }
    public string? DanToc { get; init; }
    public string? TonGiao { get; init; }
    public string? SoDienThoai { get; init; }
    public string? DiaChiThuongTru { get; init; }
    public string? TinhThanhPho { get; init; }
    public string? PhuongXa { get; init; }
}

public sealed record UpdateLecturerProfileDto
{
    public string? Phone { get; init; }
    public string? Address { get; init; }
}

// ========================================
// COURSE DTOs - Based on thoi_khoa_bieu table
// ========================================

public sealed record LecturerCourseDto
{
    public string? HocKy { get; init; }
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string MaLop { get; init; } = "";
    public int? SoTinChi { get; init; }
    public int? SiSo { get; init; }
    public string? PhongHoc { get; init; }
    public string? HinhThucGiangDay { get; init; }
}

public sealed record LecturerCourseDetailDto
{
    public string? HocKy { get; init; }
    public string? MaMonHoc { get; init; }
    public string? TenMonHocVn { get; init; }
    public string? TenMonHocEn { get; init; }
    public string MaLop { get; init; } = "";
    public int? SoTinChi { get; init; }
    public int? SiSo { get; init; }
    public string? PhongHoc { get; init; }
    public string? Thu { get; init; }
    public int? TietBatDau { get; init; }
    public int? TietKetThuc { get; init; }
    public int? CachTuan { get; init; }
    public DateTime? NgayBatDau { get; init; }
    public DateTime? NgayKetThuc { get; init; }
    public string? HinhThucGiangDay { get; init; }
    public string? GhiChu { get; init; }
}

public sealed record LecturerScheduleDto
{
    public string? HocKy { get; init; }
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string MaLop { get; init; } = "";
    public string? Thu { get; init; }
    public int? TietBatDau { get; init; }
    public int? TietKetThuc { get; init; }
    public string? PhongHoc { get; init; }
    public DateTime? NgayBatDau { get; init; }
    public DateTime? NgayKetThuc { get; init; }
    public int? CachTuan { get; init; }
    public string? HinhThucGiangDay { get; init; }
}

// ========================================
// GRADE MANAGEMENT DTOs - Based on ket_qua_hoc_tap + bang_diem tables
// ========================================

public sealed record LecturerGradeViewDto
{
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string MaLop { get; init; } = "";
    public string? MaLopGoc { get; init; }
    public decimal? DiemQuaTrinh { get; init; }
    public decimal? DiemGiuaKy { get; init; }
    public decimal? DiemThucHanh { get; init; }
    public decimal? DiemCuoiKy { get; init; }
    public decimal? DiemTongKet { get; init; }
    public string? DiemChu { get; init; }
    public string? GhiChu { get; init; }
}

public sealed record StudentGradeDetailDto
{
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string MaLop { get; init; } = "";
    public string? MaLopGoc { get; init; }
    public decimal? DiemQuaTrinh { get; init; }
    public decimal? DiemGiuaKy { get; init; }
    public decimal? DiemThucHanh { get; init; }
    public decimal? DiemCuoiKy { get; init; }
    public decimal? DiemTongKet { get; init; }
    public string? DiemChu { get; init; }
    public string? GhiChu { get; init; }
    public int? TrongSoQuaTrinh { get; init; }
    public int? TrongSoGiuaKi { get; init; }
    public int? TrongSoThucHanh { get; init; }
    public int? TrongSoCuoiKi { get; init; }
}

public sealed record LecturerUpdateGradeDto
{
    public string MaLop { get; init; } = "";
    public decimal? DiemQuaTrinh { get; init; }
    public decimal? DiemGiuaKy { get; init; }
    public decimal? DiemThucHanh { get; init; }
    public decimal? DiemCuoiKy { get; init; }
}

public sealed record UpdateGradeResultDto
{
    public bool Success { get; init; }
    public string? Message { get; init; }
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string? HocKy { get; init; }
    public decimal? DiemTongKet { get; init; }
    public string? DiemChu { get; init; }
}

// ========================================
// EXAM DTOs - Based on lich_thi + coi_thi tables
// ========================================

public sealed record LecturerExamDto
{
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string MaLop { get; init; } = "";
    public DateTime? NgayThi { get; init; }
    public int? CaThi { get; init; }
    public string? PhongThi { get; init; }
    public string? HinhThucThi { get; init; }
    public string? GkCk { get; init; }
    public int? SiSo { get; init; }
}

public sealed record LecturerExamDetailDto
{
    public string? MaMonHoc { get; init; }
    public string? TenMonHoc { get; init; }
    public string MaLop { get; init; } = "";
    public DateTime? NgayThi { get; init; }
    public int? CaThi { get; init; }
    public string? PhongThi { get; init; }
    public string? HinhThucThi { get; init; }
    public string? GkCk { get; init; }
    public int? SiSo { get; init; }
    public string? GiamThi1 { get; init; }
    public string? GiamThi2 { get; init; }
}

public sealed record ExamStudentDto
{
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string? LopSinhHoat { get; init; }
    public string? PhongThi { get; init; }
}

// ========================================
// ADMINISTRATIVE SERVICE DTOs - Based on confirmation_letters table
// ========================================

public sealed record LecturerConfirmationLetterDto
{
    public int Mssv { get; init; }
    public string? Purpose { get; init; }
}

public sealed record ConfirmationLetterResultDto
{
    public int SerialNumber { get; init; }
    public DateTime? ExpiryDate { get; init; }
}

// ========================================
// TUITION DTOs - Based on hoc_phi table
// ========================================

public sealed record StudentTuitionDto
{
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string? HocKy { get; init; }
    public int? SoTinChi { get; init; }
    public decimal? HocPhi { get; init; }
    public double? NoHocKyTruoc { get; init; }
    public double? DaDong { get; init; }
    public double? SoTienConLai { get; init; }
    public int? DonGiaTinChi { get; init; }
}

// ========================================
// APPEAL DTOs - Based on appeals table
// ========================================

public sealed record LecturerAppealDto
{
    public int Id { get; init; }
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string? CourseId { get; init; }
    public string? CourseName { get; init; }
    public string? Reason { get; init; }
    public string? PaymentMethod { get; init; }
    public string? PaymentStatus { get; init; }
    public string? Status { get; init; }
    public DateTime? CreatedAt { get; init; }
}

public sealed record LecturerAppealDetailDto
{
    public int Id { get; init; }
    public int Mssv { get; init; }
    public string? HoTen { get; init; }
    public string? CourseId { get; init; }
    public string? CourseName { get; init; }
    public string? Reason { get; init; }
    public string? PaymentMethod { get; init; }
    public string? PaymentStatus { get; init; }
    public string? Status { get; init; }
    public DateTime? CreatedAt { get; init; }
    public DateTime? UpdatedAt { get; init; }
}

public sealed record ProcessAppealDto
{
    public string Status { get; init; } = "";
    public string? Comment { get; init; }
}

public sealed record AppealProcessResultDto
{
    public bool Success { get; init; }
    public string? Message { get; init; }
}

// ========================================
// NOTIFICATION DTOs - Based on thong_bao table
// ========================================

public sealed record NotificationDto
{
    public int Id { get; init; }
    public string? TieuDe { get; init; }
    public string? NoiDung { get; init; }
    public DateTime? NgayTao { get; init; }
    public DateTime? NgayCapNhat { get; init; }
}

// ========================================
// ABSENCE & MAKEUP CLASS DTOs - Based on bao_nghi_day + bao_hoc_bu tables
// ========================================

public sealed record LecturerAbsenceDto
{
    public string MaLop { get; init; } = "";
    public DateTime NgayNghi { get; init; }
    public string? LyDo { get; init; }
}

public sealed record AbsenceResultDto
{
    public bool Success { get; init; }
    public string? Message { get; init; }
    public int AbsenceId { get; init; }
}

public sealed record LecturerMakeupClassDto
{
    public string MaLop { get; init; } = "";
    public DateTime NgayHocBu { get; init; }
    public int TietBatDau { get; init; }
    public int TietKetThuc { get; init; }
    public string? PhongHoc { get; init; }
    public string? LyDo { get; init; }
}

public sealed record MakeupClassResultDto
{
    public bool Success { get; init; }
    public string? Message { get; init; }
    public int MakeupId { get; init; }
}

public sealed record LecturerAbsenceHistoryDto
{
    public int Id { get; init; }
    public string MaLop { get; init; } = "";
    public string? TenMonHoc { get; init; }
    public DateTime? NgayNghi { get; init; }
    public string? LyDo { get; init; }
    public string? TinhTrang { get; init; }
}

public sealed record LecturerMakeupClassHistoryDto
{
    public int Id { get; init; }
    public string MaLop { get; init; } = "";
    public string? TenMonHoc { get; init; }
    public DateTime? NgayHocBu { get; init; }
    public int? TietBatDau { get; init; }
    public int? TietKetThuc { get; init; }
    public string? PhongHoc { get; init; }
    public string? LyDo { get; init; }
    public string? TinhTrang { get; init; }
}

