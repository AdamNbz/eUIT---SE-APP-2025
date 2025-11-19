using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;
using System.Text;
using System.Globalization;

namespace eUIT.API.Controllers;

[Authorize]
[ApiController]
[Route("api/student/schedule")]
public class ScheduleController : ControllerBase
{
    private readonly eUITDbContext _context;

    public ScheduleController(eUITDbContext context)
    {
        _context = context;
    }

    // Internal class for mapping database results
    private class ScheduleResult
    {
        public string hoc_ky { get; set; } = string.Empty;
        public string ma_mon_hoc { get; set; } = string.Empty;
        public string ten_mon_hoc { get; set; } = string.Empty;
        public string ma_lop { get; set; } = string.Empty;
        public int so_tin_chi { get; set; }
        public string ma_giang_vien { get; set; } = string.Empty;
        public string ten_giang_vien { get; set; } = string.Empty;
        public string thu { get; set; } = string.Empty;
        public int tiet_bat_dau { get; set; }
        public int tiet_ket_thuc { get; set; }
        public int cach_tuan { get; set; }
        public DateTime ngay_bat_dau { get; set; }
        public DateTime ngay_ket_thuc { get; set; }
        public string phong_hoc { get; set; } = string.Empty;
        public int si_so { get; set; }
        public string hinh_thuc_giang_day { get; set; } = string.Empty;
        public string? ghi_chu { get; set; }
    }

    private class ExamResult
    {
        public string ma_mon_hoc { get; set; } = string.Empty;
        public string ten_mon_hoc { get; set; } = string.Empty;
        public string ma_lop { get; set; } = string.Empty;
        public string? ma_giang_vien { get; set; }
        public string? ten_giang_vien { get; set; }
        public DateTime ngay_thi { get; set; }
        public int ca_thi { get; set; }
        public string phong_thi { get; set; } = string.Empty;
        public string? hinh_thuc_thi { get; set; }
        public string gk_ck { get; set; } = string.Empty;
        public int so_tin_chi { get; set; }
    }

    // GET: api/student/schedule/classes
    [HttpGet("classes")]
    public async Task<ActionResult<ScheduleResponseDto>> GetSchedule(
        [FromQuery] string? view_mode = "week",
        [FromQuery] string? filter_by_course = null,
        [FromQuery] string? filter_by_lecturer = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            // Get all schedule for the student
            var scheduleResults = await _context.Database
                .SqlQuery<ScheduleResult>($"SELECT * FROM func_get_student_schedule({mssvInt})")
                .ToListAsync();

            if (scheduleResults == null || scheduleResults.Count == 0)
            {
                return Ok(new ScheduleResponseDto
                {
                    Classes = new List<ScheduleClassDto>(),
                    Message = "Chưa có lịch học"
                });
            }

            // Apply filters
            var filteredResults = scheduleResults.AsQueryable();

            if (!string.IsNullOrEmpty(filter_by_course))
            {
                filteredResults = filteredResults.Where(s => 
                    s.ma_mon_hoc.Contains(filter_by_course, StringComparison.OrdinalIgnoreCase) ||
                    s.ten_mon_hoc.Contains(filter_by_course, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(filter_by_lecturer))
            {
                filteredResults = filteredResults.Where(s => 
                    s.ten_giang_vien.Contains(filter_by_lecturer, StringComparison.OrdinalIgnoreCase) ||
                    s.ma_giang_vien.Contains(filter_by_lecturer, StringComparison.OrdinalIgnoreCase));
            }

            // Apply view mode filtering
            var now = DateTime.Now;
            switch (view_mode?.ToLower())
            {
                case "day":
                    // Show today's classes
                    filteredResults = filteredResults.Where(s => 
                        IsClassOnDate(s, now));
                    break;
                case "week":
                    // Show this week's classes
                    var startOfWeek = now.Date.AddDays(-(int)now.DayOfWeek + (int)DayOfWeek.Monday);
                    var endOfWeek = startOfWeek.AddDays(6);
                    filteredResults = filteredResults.Where(s => 
                        s.ngay_bat_dau <= endOfWeek && s.ngay_ket_thuc >= startOfWeek);
                    break;
                case "month":
                    // Show this month's classes
                    var startOfMonth = new DateTime(now.Year, now.Month, 1);
                    var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);
                    filteredResults = filteredResults.Where(s => 
                        s.ngay_bat_dau <= endOfMonth && s.ngay_ket_thuc >= startOfMonth);
                    break;
            }

            var classes = filteredResults.Select(s => new ScheduleClassDto
            {
                HocKy = s.hoc_ky,
                MaMonHoc = s.ma_mon_hoc,
                TenMonHoc = s.ten_mon_hoc,
                MaLop = s.ma_lop,
                SoTinChi = s.so_tin_chi,
                MaGiangVien = s.ma_giang_vien,
                TenGiangVien = s.ten_giang_vien,
                Thu = s.thu,
                TietBatDau = s.tiet_bat_dau,
                TietKetThuc = s.tiet_ket_thuc,
                CachTuan = s.cach_tuan,
                NgayBatDau = s.ngay_bat_dau,
                NgayKetThuc = s.ngay_ket_thuc,
                PhongHoc = s.phong_hoc,
                SiSo = s.si_so,
                HinhThucGiangDay = s.hinh_thuc_giang_day,
                GhiChu = s.ghi_chu
            }).ToList();

            return Ok(new ScheduleResponseDto
            {
                Classes = classes
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new ScheduleResponseDto
            {
                Classes = new List<ScheduleClassDto>(),
                Message = "Không thể tải lịch học"
            });
        }
    }

    // Helper method to check if a class occurs on a specific date
    private bool IsClassOnDate(ScheduleResult schedule, DateTime date)
    {
        if (date < schedule.ngay_bat_dau || date > schedule.ngay_ket_thuc)
            return false;

        // Check if the day of week matches
        var dayOfWeek = date.DayOfWeek;
        var thuNumber = schedule.thu;
        
        // Convert thu (2-8) to DayOfWeek (0-6)
        var expectedDay = thuNumber switch
        {
            "2" => DayOfWeek.Monday,
            "3" => DayOfWeek.Tuesday,
            "4" => DayOfWeek.Wednesday,
            "5" => DayOfWeek.Thursday,
            "6" => DayOfWeek.Friday,
            "7" => DayOfWeek.Saturday,
            "8" => DayOfWeek.Sunday,
            _ => (DayOfWeek)(-1)
        };

        if (dayOfWeek != expectedDay)
            return false;

        // Check cach_tuan (interval weeks)
        var weeksSinceStart = (date - schedule.ngay_bat_dau).Days / 7;
        return weeksSinceStart % schedule.cach_tuan == 0;
    }

    // GET: api/student/schedule/classes/export
    [HttpGet("classes/export")]
    public async Task<IActionResult> ExportSchedule([FromQuery] string? export_format = "ics")
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            var scheduleResults = await _context.Database
                .SqlQuery<ScheduleResult>($"SELECT * FROM func_get_student_schedule({mssvInt})")
                .ToListAsync();

            if (scheduleResults == null || scheduleResults.Count == 0)
            {
                return NotFound(new { message = "Không có lịch học để xuất" });
            }

            // Generate ICS file
            var icsContent = GenerateIcsFile(scheduleResults, mssvInt);
            var fileName = $"lich-hoc-{mssvInt}.ics";

            return File(
                Encoding.UTF8.GetBytes(icsContent),
                "text/calendar",
                fileName
            );
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Không thể xuất lịch học", error = ex.Message });
        }
    }

    // Helper method to generate ICS file content
    private string GenerateIcsFile(List<ScheduleResult> schedules, int mssv)
    {
        var sb = new StringBuilder();
        
        // ICS header
        sb.AppendLine("BEGIN:VCALENDAR");
        sb.AppendLine("VERSION:2.0");
        sb.AppendLine("PRODID:-//eUIT//Student Schedule//VN");
        sb.AppendLine("CALSCALE:GREGORIAN");
        sb.AppendLine("METHOD:PUBLISH");
        sb.AppendLine("X-WR-CALNAME:Lịch học eUIT");
        sb.AppendLine("X-WR-TIMEZONE:Asia/Ho_Chi_Minh");

        foreach (var schedule in schedules)
        {
            // Generate all occurrences of this recurring class
            var occurrences = GenerateClassOccurrences(schedule);
            
            foreach (var occurrence in occurrences)
            {
                sb.AppendLine("BEGIN:VEVENT");
                
                // Unique identifier
                var uid = $"{schedule.ma_lop}-{occurrence:yyyyMMdd}-{mssv}@euit.edu.vn";
                sb.AppendLine($"UID:{uid}");
                
                // Summary (title)
                sb.AppendLine($"SUMMARY:{schedule.ten_mon_hoc} - {schedule.ma_lop}");
                
                // Description
                var description = $"Giảng viên: {schedule.ten_giang_vien}\\n" +
                                $"Phòng: {schedule.phong_hoc}\\n" +
                                $"Tiết: {schedule.tiet_bat_dau}-{schedule.tiet_ket_thuc}\\n" +
                                $"Hình thức: {schedule.hinh_thuc_giang_day}";
                if (!string.IsNullOrEmpty(schedule.ghi_chu))
                    description += $"\\nGhi chú: {schedule.ghi_chu}";
                sb.AppendLine($"DESCRIPTION:{description}");
                
                // Location
                sb.AppendLine($"LOCATION:{schedule.phong_hoc}");
                
                // Start and end times
                var (startTime, endTime) = GetClassTimes(occurrence, schedule.tiet_bat_dau, schedule.tiet_ket_thuc);
                sb.AppendLine($"DTSTART:{startTime:yyyyMMdd'T'HHmmss}");
                sb.AppendLine($"DTEND:{endTime:yyyyMMdd'T'HHmmss}");
                
                // Timestamp
                sb.AppendLine($"DTSTAMP:{DateTime.UtcNow:yyyyMMdd'T'HHmmss'Z'}");
                
                sb.AppendLine("END:VEVENT");
            }
        }

        sb.AppendLine("END:VCALENDAR");
        
        return sb.ToString();
    }

    // Generate all occurrences of a recurring class
    private List<DateTime> GenerateClassOccurrences(ScheduleResult schedule)
    {
        var occurrences = new List<DateTime>();
        var currentDate = schedule.ngay_bat_dau;
        
        // Map thu to DayOfWeek
        var targetDayOfWeek = schedule.thu switch
        {
            "2" => DayOfWeek.Monday,
            "3" => DayOfWeek.Tuesday,
            "4" => DayOfWeek.Wednesday,
            "5" => DayOfWeek.Thursday,
            "6" => DayOfWeek.Friday,
            "7" => DayOfWeek.Saturday,
            "8" => DayOfWeek.Sunday,
            _ => DayOfWeek.Monday
        };

        // Find first occurrence
        while (currentDate.DayOfWeek != targetDayOfWeek && currentDate <= schedule.ngay_ket_thuc)
        {
            currentDate = currentDate.AddDays(1);
        }

        // Generate all occurrences
        while (currentDate <= schedule.ngay_ket_thuc)
        {
            occurrences.Add(currentDate);
            currentDate = currentDate.AddDays(7 * schedule.cach_tuan);
        }

        return occurrences;
    }

    // Get start and end times for a class period
    private (DateTime startTime, DateTime endTime) GetClassTimes(DateTime date, int tietBatDau, int tietKetThuc)
    {
        // Standard class schedule (each period is 50 minutes)
        var periodTimes = new Dictionary<int, (int hour, int minute)>
        {
            { 1, (7, 0) },
            { 2, (7, 55) },
            { 3, (8, 50) },
            { 4, (9, 50) },
            { 5, (10, 45) },
            { 6, (11, 40) },
            { 7, (13, 0) },
            { 8, (13, 55) },
            { 9, (14, 50) },
            { 10, (15, 50) },
            { 11, (16, 45) },
            { 12, (17, 40) },
            { 13, (18, 30) },
            { 14, (19, 25) },
            { 15, (20, 20) }
        };

        var startPeriod = periodTimes.GetValueOrDefault(tietBatDau, (7, 0));
        var endPeriod = periodTimes.GetValueOrDefault(tietKetThuc, (7, 50));

        var startTime = new DateTime(date.Year, date.Month, date.Day, startPeriod.Item1, startPeriod.Item2, 0);
        var endTime = new DateTime(date.Year, date.Month, date.Day, endPeriod.Item1, endPeriod.Item2 + 50, 0);

        return (startTime, endTime);
    }

    // GET: api/student/schedule/exams
    [HttpGet("exams")]
    public async Task<ActionResult<ExamScheduleResponseDto>> GetExamSchedule(
        [FromQuery] string? filter_by_semester = null,
        [FromQuery] string? filter_by_group = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            List<ExamResult> examResults;

            if (!string.IsNullOrEmpty(filter_by_semester))
            {
                examResults = await _context.Database
                    .SqlQuery<ExamResult>($"SELECT * FROM func_get_student_exam_schedule_by_semester({mssvInt}, {filter_by_semester})")
                    .ToListAsync();
            }
            else
            {
                examResults = await _context.Database
                    .SqlQuery<ExamResult>($"SELECT * FROM func_get_student_exam_schedule({mssvInt})")
                    .ToListAsync();
            }

            if (examResults == null || examResults.Count == 0)
            {
                return Ok(new ExamScheduleResponseDto
                {
                    Exams = new List<ExamScheduleDto>(),
                    Message = "Chưa công bố lịch thi"
                });
            }

            // Apply group filter if specified (GK or CK)
            if (!string.IsNullOrEmpty(filter_by_group))
            {
                examResults = examResults
                    .Where(e => e.gk_ck.Equals(filter_by_group, StringComparison.OrdinalIgnoreCase))
                    .ToList();
            }

            var exams = examResults.Select(e => new ExamScheduleDto
            {
                MaMonHoc = e.ma_mon_hoc,
                TenMonHoc = e.ten_mon_hoc,
                MaLop = e.ma_lop,
                MaGiangVien = e.ma_giang_vien,
                TenGiangVien = e.ten_giang_vien,
                NgayThi = e.ngay_thi,
                CaThi = e.ca_thi,
                PhongThi = e.phong_thi,
                HinhThucThi = e.hinh_thuc_thi,
                GkCk = e.gk_ck,
                SoTinChi = e.so_tin_chi
            }).ToList();

            return Ok(new ExamScheduleResponseDto
            {
                Exams = exams
            });
        }
        catch (Exception)
        {
            return Ok(new ExamScheduleResponseDto
            {
                Exams = new List<ExamScheduleDto>(),
                Message = "Chưa công bố lịch thi"
            });
        }
    }
}
