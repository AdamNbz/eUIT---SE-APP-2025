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
#endregion

[Authorize]
[ApiController]
[Route("api/service")]
public class ServiceController : ControllerBase
{
    private readonly eUITDbContext _context;

    public ServiceController(eUITDbContext context)
    {
        _context = context;
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