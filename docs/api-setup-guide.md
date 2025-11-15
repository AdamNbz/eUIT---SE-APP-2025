# Hướng dẫn Setup Database cho API mới

## 1. Cài đặt SQL Functions

### Bước 1: Chạy migration thêm cột hoc_ky
```bash
psql -U postgres -d eUIT -f scripts/database/sql/migration_add_hoc_ky_to_training.sql
```

Hoặc chạy trực tiếp trong PostgreSQL:
```sql
ALTER TABLE chi_tiet_hoat_dong_ren_luyen 
ADD COLUMN hoc_ky CHAR(11) DEFAULT '2025_2026_1';

UPDATE chi_tiet_hoat_dong_ren_luyen 
SET hoc_ky = '2025_2026_1' 
WHERE hoc_ky IS NULL;
```

### Bước 2: Tạo function điểm rèn luyện
```bash
psql -U postgres -d eUIT -f scripts/database/sql/training_scores.sql
```

## 2. Test các API endpoints

### 2.1 API Tra cứu Kết quả học tập

**Lấy tất cả điểm:**
```bash
curl -X GET "http://localhost:5093/grades" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Lọc theo học kỳ:**
```bash
curl -X GET "http://localhost:5093/grades?filter_by_semester=2025_2026_1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 2.2 API Tra cứu Điểm rèn luyện

**Lấy tất cả điểm rèn luyện:**
```bash
curl -X GET "http://localhost:5093/training-scores" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Lọc theo học kỳ:**
```bash
curl -X GET "http://localhost:5093/training-scores?filter_by_semester=2025_2026_1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 2.3 API Xem Quy chế đào tạo

**Lấy danh sách quy chế:**
```bash
curl -X GET "http://localhost:5093/api/public/regulations"
```

**Tìm kiếm quy chế:**
```bash
curl -X GET "http://localhost:5093/api/public/regulations?search_term=đào%20tạo"
```

**Download file quy chế:**
```bash
curl -X GET "http://localhost:5093/api/public/regulations?download=true&file_name=QuyCheDaoTao.pdf" \
  --output QuyCheDaoTao.pdf
```

## 3. Response Formats

### Grades API Response:
```json
{
  "grades": [
    {
      "hocKy": "2025_2026_1",
      "maMonHoc": "IT001",
      "tenMonHoc": "Nhập môn lập trình",
      "soTinChi": 4,
      "diemTongKet": 8.5
    }
  ],
  "message": null
}
```

### Training Scores API Response:
```json
{
  "trainingScores": [
    {
      "hocKy": "2025_2026_1",
      "tongDiem": 85,
      "xepLoai": "Tốt",
      "tinhTrang": "Đã xác nhận"
    }
  ],
  "message": null
}
```

### Regulations API Response:
```json
{
  "regulations": [
    {
      "tenVanBan": "Quy chế đào tạo 2025",
      "urlVanBan": "http://localhost:5093/files/Regulations/QuyCheDaoTao2025.pdf",
      "ngayBanHanh": "2025-01-15"
    }
  ],
  "message": null
}
```

## 4. Error Handling

Tất cả các API đều xử lý các edge cases sau:

- **Grades API**: 
  - Trả về `message: "Chưa có dữ liệu"` nếu không có điểm
  - Trả về `message: "Không thể tải dữ liệu"` nếu lỗi server

- **Training Scores API**:
  - Trả về `message: "Đang chờ xác nhận"` nếu chưa có dữ liệu

- **Regulations API**:
  - Trả về `message: "Không tìm thấy quy chế nào"` nếu không có kết quả
  - Trả về 404 nếu file không tồn tại khi download

## 5. Database Functions

### func_get_student_semester_transcript
Lấy điểm của sinh viên trong một học kỳ cụ thể.

### func_get_student_full_transcript
Lấy toàn bộ điểm của sinh viên.

### func_get_student_training_scores
Lấy điểm rèn luyện của sinh viên theo học kỳ.

## 6. Files Created/Modified

### Backend:
- ✅ `Controllers/StudentController.cs` - Added `/grades` and `/training-scores` endpoints
- ✅ `Controllers/RegulationsController.cs` - New controller for `/api/public/regulations`
- ✅ `DTOs/GradeDTO.cs` - Grade response models
- ✅ `DTOs/TrainingScoreDTO.cs` - Training score response models
- ✅ `DTOs/RegulationDTO.cs` - Regulation response models

### Database:
- ✅ `scripts/database/sql/training_scores.sql` - SQL functions for training scores
- ✅ `scripts/database/sql/migration_add_hoc_ky_to_training.sql` - Migration script

### Documentation:
- ✅ `docs/api-setup-guide.md` - This file
