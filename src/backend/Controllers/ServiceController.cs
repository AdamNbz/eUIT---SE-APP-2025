using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using Npgsql;
using System.Security.Claims;
using System.ComponentModel.DataAnnotations;

namespace eUIT.API.Controllers;

#region DTO Classes
public class ConfirmationLetterRequestDto
{
    [Required(ErrorMessage = "Vui lòng nhập lý do")]
    public string Purpose { get; set; } = string.Empty;
}

public class ConfirmationLetterResponseDto
{
    public int SerialNumber { get; set; }
    public string ExpiryDate { get; set; } = string.Empty; // Trả về string cho dễ format dd/MM/yyyy
}

// Class này dùng để hứng kết quả từ SQL Raw (tên biến phải khớp output SQL)
public class ConfirmationLetterResult
{
    public int so_thu_tu { get; set; }
    public DateTime ngay_het_han { get; set; }
}

public class LanguageCertificateRequestDto
{
    [Required(ErrorMessage = "Vui lòng chọn loại chứng chỉ")]
    [FromForm(Name = "certificate_type")]
    public string CertificateType { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập điểm số")]
    [FromForm(Name = "score")]
    public float Score { get; set; }

    [Required(ErrorMessage = "Vui lòng nhập ngày cấp")]
    [FromForm(Name = "issue_date")]
    public DateTime IssueDate { get; set; }

    [FromForm(Name = "expiry_date")]
    public DateTime? ExpiryDate { get; set; }
}


#endregion

[Authorize]
[ApiController]
[Route("api/service")]
public class ServiceController : ControllerBase
{
    private readonly eUITDbContext _context;
    private readonly IWebHostEnvironment _env;

    public ServiceController(eUITDbContext context, IWebHostEnvironment env)
    {
        _context = context;
        _env = env;
    }

    [HttpPost("confirmation-letter")]
    public async Task<ActionResult<ConfirmationLetterResponseDto>> RequestConfirmationLetter([FromBody] ConfirmationLetterRequestDto requestDto)
    {
        // 1. Lấy MSSV từ Token
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        if (!ModelState.IsValid) return BadRequest(ModelState);

        try
        {
            // 2. Chuẩn bị tham số gọi hàm SQL
            var mssvParam = new NpgsqlParameter("p_mssv", mssv.Value);
            var purposeParam = new NpgsqlParameter("p_purpose", requestDto.Purpose ?? "");

            // 3. Gọi hàm SQL
            // Lưu ý: Tên cột trong SELECT phải map với class ConfirmationLetterResult
            string sql = "SELECT * FROM func_request_confirmation_letter(@p_mssv, @p_purpose)";

            var result = await _context.Database
                .SqlQueryRaw<ConfirmationLetterResult>(sql, mssvParam, purposeParam)
                .ToListAsync(); // Dùng ToListAsync an toàn hơn SingleOrDefault với Raw SQL đôi khi

            var record = result.FirstOrDefault();

            if (record == null)
            {
                return StatusCode(500, "Lỗi hệ thống: Không nhận được kết quả từ Database.");
            }

            // 4. Trả về kết quả
            return Ok(new ConfirmationLetterResponseDto
            {
                SerialNumber = record.so_thu_tu,
                ExpiryDate = record.ngay_het_han.ToString("dd/MM/yyyy")
            });
        }
        catch (Exception ex)
        {
            // Log error here if needed
            return StatusCode(500, $"Lỗi Server: {ex.Message}");
        }
    }

    [HttpPost("language-certificate")]
    [RequestSizeLimit(5 * 1024 * 1024)] // 5 MB
    public async Task<IActionResult> SubmitLanguageCertificate([FromForm] LanguageCertificateRequestDto requestDto, IFormFile file)
    {
        // 1. Lấy MSSV từ Token
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        // 2. Validate DTO và file
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (file == null || file.Length == 0)
        {
            return BadRequest(new { file = "Vui lòng tải lên file chứng chỉ." });
        }

        // 3. Kiểm tra định dạng file
        var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
        var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (string.IsNullOrEmpty(fileExtension) || !allowedExtensions.Contains(fileExtension))
        {
            return BadRequest(new { error = "Định dạng file không hợp lệ. Chỉ chấp nhận PDF, JPG, PNG." });
        }

        // 4. Lưu file vào thư mục (ví dụ: wwwroot/uploads/certificates)
        string webRootPath = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
        var uploadsFolder = Path.Combine(webRootPath, "uploads", "certificates");

        if (!Directory.Exists(uploadsFolder))
        {
            Directory.CreateDirectory(uploadsFolder);
        }

        // Tạo tên file duy nhất để tránh trùng lặp
        var uniqueFileName = $"{mssv}_{DateTime.UtcNow:yyyyMMdd}_{Guid.NewGuid().ToString("N")[..8]}{fileExtension}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        try
        {
            await using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // 5. Lưu thông tin vào database
            var mssvParam = new NpgsqlParameter("p_mssv", mssv.Value);
            var typeParam = new NpgsqlParameter("p_certificate_type", requestDto.CertificateType);
            var scoreParam = new NpgsqlParameter("p_score", requestDto.Score);
            var issueDateParam = new NpgsqlParameter("p_issue_date", requestDto.IssueDate);
            var expiryDateParam = new NpgsqlParameter("p_expiry_date", (object)requestDto.ExpiryDate ?? DBNull.Value);
            var filePathParam = new NpgsqlParameter("p_file_path", $"uploads/certificates/{uniqueFileName}"); // Lưu đường dẫn tương đối

            // SỬA DÒNG NÀY
// Thêm ::date vào sau @p_issue_date và @p_expiry_date
            string sql = "SELECT func_submit_language_certificate(@p_mssv, @p_certificate_type, @p_score, @p_issue_date::date, @p_expiry_date::date, @p_file_path)";

            await _context.Database.ExecuteSqlRawAsync(sql, mssvParam, typeParam, scoreParam, issueDateParam, expiryDateParam, filePathParam);;

            return Ok(new { message = "Nộp chứng chỉ ngoại ngữ thành công." });
        }
        catch (PostgresException pgEx)
        {
            // Xóa file đã tải lên nếu có lỗi từ database
            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }
            // Giả sử mã lỗi 'P0001' là raise_exception trong PostgreSQL
            if (pgEx.SqlState == "P0001")
            {
                return BadRequest(new { error = pgEx.Message });
            }
            return StatusCode(500, $"Lỗi Database: {pgEx.Message}");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Lỗi Server: {ex.Message}");
        }
    }

    private (int? mssv, ActionResult? errorResult) GetCurrentMssv()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (claim == null || string.IsNullOrEmpty(claim.Value))
        {
            return (null, Unauthorized("Không tìm thấy thông tin người dùng."));
        }

        if (int.TryParse(claim.Value, out int mssv))
        {
            return (mssv, null);
        }
        return (null, BadRequest("Mã số sinh viên không hợp lệ."));
    }
}