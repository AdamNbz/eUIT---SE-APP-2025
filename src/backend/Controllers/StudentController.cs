using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;
using System.Runtime.CompilerServices;

namespace eUIT.API.Controllers;

[Authorize] // Yêu cầu tất cả các API trong controller này đều phải được xác thực
[ApiController]
[Route("api/[controller]")] // Đường dẫn sẽ là /api/students
public class StudentsController : ControllerBase
{
    private readonly eUITDbContext _context;

    public StudentsController(eUITDbContext context)
    {
        _context = context;
    }

    // GET: api/students/nextclass
    [HttpGet("/nextclass")]
    public async Task<ActionResult<NextClassDto>> GetNextClass()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return Forbid();
        }

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var NextClassResult = await
        _context.Database.SqlQuery<NextClassInfoDto>
        ($"SELECT * FROM func_get_next_class({mssvInt})")
        .FirstOrDefaultAsync();

        if (NextClassResult == null) return NoContent();

        var NextClass = new NextClassDto
        {
            MaLop = NextClassResult.ma_lop,
            TenLop = NextClassResult.ten_mon_hoc_vn,
            GiangVien = NextClassResult.ho_ten,
            Thu = NextClassResult.thu,
            TietBatDau = NextClassResult.tiet_bat_dau,
            TietKetThuc = NextClassResult.tiet_ket_thuc,
            PhongHoc = NextClassResult.phong_hoc,
            NgayHoc = NextClassResult.ngay_hoc,
            CountdownMinutes = NextClassResult.countdown_minutes
        };

        return Ok(NextClass);
    }

    // GET: api/students/card
    [HttpGet("/card")]
    public async Task<ActionResult<StudentCardDto>> GetStudentCard()
    {
        // Bước 1: Xác định người dùng đang thực hiện yêu cầu từ Token
        // Lấy mssv của người dùng đã đăng nhập từ claim trong JWT
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return Forbid();
        }

        // Bước 2: Truy vấn thông tin sinh viên từ database ===
        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var student = await
            _context.Database.SqlQuery<CardInfoResultDto>(
            $"SELECT * FROM func_get_student_card_info({mssvInt})")
            .FirstOrDefaultAsync();

        if (student == null)
        {
            return NotFound(); // Không tìm thấy sinh viên với mssv này
        }

        // === Bước 3: Xây dựng đường dẫn URL đầy đủ cho ảnh thẻ ===
        string? avatarFullUrl = null;
        if (!string.IsNullOrEmpty(student.anh_the_url))
        {
            // Ghép địa chỉ server + request path + đường dẫn tương đối trong DB
            // Ví dụ: https://localhost:5093 + /files + /Students/Avatars/23520560.jpg
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            avatarFullUrl = $"{baseUrl}/files/{student.anh_the_url}";

        }

        // === Bước 4: Ánh xạ dữ liệu từ entity của database sang DTO để trả về ===
        var studentCard = new StudentCardDto
        {
            Mssv = student.mssv,
            HoTen = student.ho_ten,
            KhoaHoc = student.khoa_hoc,
            NganhHoc = student.nganh_hoc,
            AvatarFullUrl = avatarFullUrl
        };

        return Ok(studentCard);
    }

    // GET: api/students/quickgpa
    [HttpGet("/quickgpa")]
    public async Task<ActionResult<QuickGpaDto>> GetQuickGpa()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var result = await
            _context.Database.SqlQuery<QuickGpaResultDto>(
            $"SELECT * FROM func_calculate_gpa({mssvInt})")
            .FirstOrDefaultAsync();

        if (result == null) return NotFound();

        var gpaAndCredits = new QuickGpaDto
        {
            Gpa = result.gpa,
            SoTinChiTichLuy = result.so_tin_chi_tich_luy
        };

        return Ok(gpaAndCredits);
    }

    // GET: api/students/grades
    [HttpGet("/grades")]
    public async Task<ActionResult<GradeListResponseDto>> GetGrades([FromQuery] string? filter_by_semester = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        try
        {
            List<GradeResultDto> gradeResults;

            if (!string.IsNullOrEmpty(filter_by_semester))
            {
                // Get grades for a specific semester
                gradeResults = await _context.Database
                    .SqlQuery<GradeResultDto>($"SELECT * FROM func_get_student_semester_transcript({mssvInt}, {filter_by_semester})")
                    .ToListAsync();
            }
            else
            {
                // Get all grades (full transcript)
                gradeResults = await _context.Database
                    .SqlQuery<GradeResultDto>($"SELECT * FROM func_get_student_full_transcript({mssvInt})")
                    .ToListAsync();
            }

            if (gradeResults == null || gradeResults.Count == 0)
            {
                return Ok(new GradeListResponseDto
                {
                    Grades = new List<GradeDto>(),
                    Message = "Chưa có dữ liệu"
                });
            }

            var grades = gradeResults.Select(g => new GradeDto
            {
                HocKy = g.hoc_ky,
                MaMonHoc = g.ma_mon_hoc,
                TenMonHoc = g.ten_mon_hoc,
                SoTinChi = g.so_tin_chi,
                DiemTongKet = g.diem_tong_ket
            }).ToList();

            return Ok(new GradeListResponseDto
            {
                Grades = grades
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new GradeListResponseDto
            {
                Grades = new List<GradeDto>(),
                Message = "Không thể tải dữ liệu"
            });
        }
    }

    // GET: api/students/grades/details
    [HttpGet("/grades/details")]
    public async Task<ActionResult<TranscriptOverviewDto>> GetDetailedTranscript([FromQuery] string? filter_by_semester = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            var overall = await _context.Database.SqlQuery<QuickGpaResultDto>($"SELECT * FROM func_calculate_gpa({mssvInt})").FirstOrDefaultAsync();

            List<DetailedGradeRowDto> rows;
            if (string.IsNullOrEmpty(filter_by_semester))
            {
                rows = await _context.Database
                    .SqlQuery<DetailedGradeRowDto>($"SELECT * FROM func_get_student_full_transcript_details({mssvInt})")
                    .ToListAsync();
            }
            else
            {
                rows = await _context.Database
                    .SqlQuery<DetailedGradeRowDto>($"SELECT * FROM func_get_student_semester_transcript_details({mssvInt}, {filter_by_semester})")
                    .ToListAsync();
            }

            if (rows == null || rows.Count == 0)
            {
                return Ok(new TranscriptOverviewDto
                {
                    OverallGpa = overall?.gpa ?? 0f,
                    AccumulatedCredits = overall?.so_tin_chi_tich_luy ?? 0,
                    Semesters = new List<SemesterTranscriptDto>()
                });
            }

            var semesters = rows
                .GroupBy(r => r.hoc_ky)
                .Select(g => new SemesterTranscriptDto
                {
                    HocKy = g.Key,
                    Subjects = g.Select(r => new SubjectGradeDetailDto
                    {
                        HocKy = r.hoc_ky,
                        MaMonHoc = r.ma_mon_hoc,
                        TenMonHoc = r.ten_mon_hoc,
                        SoTinChi = r.so_tin_chi,
                        TrongSoQuaTrinh = r.trong_so_qua_trinh,
                        TrongSoGiuaKi = r.trong_so_giua_ki,
                        TrongSoThucHanh = r.trong_so_thuc_hanh,
                        TrongSoCuoiKi = r.trong_so_cuoi_ki,
                        DiemQuaTrinh = r.diem_qua_trinh,
                        DiemGiuaKi = r.diem_giua_ki,
                        DiemThucHanh = r.diem_thuc_hanh,
                        DiemCuoiKi = r.diem_cuoi_ki,
                        DiemTongKet = r.diem_tong_ket
                    }).ToList(),
                    SemesterGpa = CalculateSemesterGpa(g.ToList())
                })
                .OrderBy(s => s.HocKy)
                .ToList();

            var overview = new TranscriptOverviewDto
            {
                OverallGpa = overall?.gpa ?? 0f,
                AccumulatedCredits = overall?.so_tin_chi_tich_luy ?? 0,
                Semesters = semesters
            };

            return Ok(overview);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error in GetDetailedTranscript: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
            
            return StatusCode(500, new TranscriptOverviewDto
            {
                OverallGpa = 0f,
                AccumulatedCredits = 0,
                Semesters = new List<SemesterTranscriptDto>()
            });
        }
    }

    private static float? CalculateSemesterGpa(List<DetailedGradeRowDto> subjects)
    {
        var validSubjects = subjects.Where(s => s.diem_tong_ket.HasValue).ToList();
        if (validSubjects.Count == 0) return null;

        var totalCredits = validSubjects.Sum(s => s.so_tin_chi);
        if (totalCredits == 0) return null;

        var weightedSum = validSubjects.Sum(s => s.diem_tong_ket!.Value * s.so_tin_chi);
        return (float)Math.Round(weightedSum / totalCredits, 2);
    }

    // GET: api/students/training-scores
    [HttpGet("/training-scores")]
    public async Task<ActionResult<TrainingScoreListResponseDto>> GetTrainingScores([FromQuery] string? filter_by_semester = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        try
        {
            List<TrainingScoreResultDto> trainingScoreResults;

            if (string.IsNullOrEmpty(filter_by_semester))
            {
                trainingScoreResults = await _context.Database
                    .SqlQuery<TrainingScoreResultDto>($"SELECT hoc_ky, tong_diem, xep_loai, 'Đã xác nhận' as tinh_trang FROM func_get_student_training_scores({mssvInt})")
                    .ToListAsync();
            }
            else
            {
                trainingScoreResults = await _context.Database
                    .SqlQuery<TrainingScoreResultDto>($"SELECT hoc_ky, tong_diem, xep_loai, 'Đã xác nhận' as tinh_trang FROM func_get_student_training_scores({mssvInt}) WHERE hoc_ky = {filter_by_semester}")
                    .ToListAsync();
            }

            if (trainingScoreResults == null || trainingScoreResults.Count == 0)
            {
                return Ok(new TrainingScoreListResponseDto
                {
                    TrainingScores = new List<TrainingScoreDto>(),
                    Message = "Đang chờ xác nhận"
                });
            }

            var trainingScores = trainingScoreResults.Select(ts => new TrainingScoreDto
            {
                HocKy = ts.hoc_ky,
                TongDiem = ts.tong_diem,
                    XepLoai = ts.tong_diem >= 90 ? "Xuất sắc" :
                              ts.tong_diem >= 80 ? "Giỏi" :
                              ts.tong_diem >= 70 ? "Khá" :
                              ts.tong_diem >= 60 ? "Trung bình khá" : "Trung bình",
                TinhTrang = ts.tinh_trang
            }).ToList();

            return Ok(new TrainingScoreListResponseDto
            {
                TrainingScores = trainingScores
            });
        }
        catch (Exception)
        {
            return Ok(new TrainingScoreListResponseDto
            {
                TrainingScores = new List<TrainingScoreDto>(),
                Message = "Đang chờ xác nhận"
            });
        }
    }
}
