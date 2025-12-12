# Module Giảng viên

Tài liệu này mô tả chi tiết các chức năng của Module Giảng viên trong project (phiên bản đã loại bỏ tính năng upload tài liệu công khai). Mục tiêu: mô tả rõ UI, luồng nghiệp vụ, API và dữ liệu để dev/QA/PM dễ theo dõi và hiện thực.

## 1. Tổng quan
Module Giảng viên hỗ trợ toàn bộ workflow giảng dạy và hành chính đối với giảng viên: quản lý lớp, điểm danh, nhập điểm, phúc khảo, tạo giấy xác nhận cho sinh viên, tra cứu học phí sinh viên (từ hệ thống), giao tiếp với sinh viên và nhận thông báo real-time.

Nguyên tắc thiết kế:
- Tối giản thao tác (few taps) cho các tác vụ thường xuyên.
- Đồng bộ dữ liệu với backend (SIS/DB) và đảm bảo audit (lưu lịch sử thay đổi điểm/chuyên cần).
- Real-time: push notifications / SignalR cho các thay đổi quan trọng.
- Không có tính năng upload tài liệu trong phạm vi này (đã loại bỏ).

---

## 2. Chức năng chính (chi tiết)

### 2.1. Hồ sơ giảng viên
- Màn thẻ giảng viên: ảnh, họ tên, mã GV, khoa/bộ môn, email, số điện thoại.
- Trang chi tiết: học vị, chuyên môn, các môn đảm nhiệm, lịch sử giảng dạy (các lớp đã dạy), thời khóa biểu cá nhân.
- Hành vi: dữ liệu lấy từ API `GET /lecturer/profile`; cho phép chỉnh sửa trường liên hệ qua `PUT /lecturer/profile` (theo phân quyền).

### 2.2. Danh sách & thẻ lớp
- Danh sách lớp hiển thị: mã môn, tên môn, nhóm, phòng, sĩ số, trạng thái (Đang dạy / Kết thúc / Tạm dừng).
- Lọc: theo năm học/học kỳ/môn/nhóm.
- Thẻ lớp chi tiết (màn `class detail`):
  - Thông tin lớp: mã môn, tên môn, nhóm, mã lớp, phòng học, sĩ số, giảng viên phụ (nếu có), lịch học (buổi), danh sách sinh viên (liên kết tới hồ sơ).
  - Tài liệu liên quan: chỉ xem các tài liệu có sẵn (nếu backend cung cấp URL). **Không hỗ trợ upload**.
- API mẫu:
  - `GET /lecturer/classes?semester=...` — danh sách lớp
  - `GET /lecturer/classes/{classId}` — chi tiết lớp
  - `GET /lecturer/classes/{classId}/students` — danh sách sinh viên

### 2.3. Lịch dạy & thay thế
- Hiển thị theo ngày/tuần/học kỳ.
- Tạo yêu cầu thay giảng: form gồm ngày, buổi, lý do — gửi `POST /lecturer/requests/substitute`.
- Khi yêu cầu được duyệt bởi phòng quản lý, server push event `class_updated` để cập nhật lịch sinh viên.
- Hỗ trợ export iCal: `GET /lecturer/calendar.ics?classId=...`.

### 2.4. Điểm danh & chuyên cần
- Chấm công: giảng viên có thể đánh dấu có mặt/vắng cho từng buổi trong giao diện lớp.
- Cách chấm: thủ công (UI), QR code (nếu triển khai sau), hoặc nhập hàng loạt (CSV import).
- API:
  - `POST /lecturer/classes/{classId}/attendance` — cập nhật attendance cho buổi
  - `GET /lecturer/classes/{classId}/attendance?from=...&to=...` — báo cáo
- Audit: mọi chỉnh sửa lưu `userId`, `timestamp`, `reason`.
- Triggers: nếu sinh viên vắng vượt ngưỡng, gửi notification hoặc đánh dấu để phòng đào tạo xử lý.

### 2.5. Quản lý điểm & Phúc khảo
- Gradebook:
  - Khai báo các thành phần điểm (ví dụ: chuyên cần, bài tập, giữa kỳ, cuối kỳ) và trọng số.
  - Nhập điểm: thủ công trên UI hoặc import CSV cho lớp.
  - Tính toán tổng điểm: có thể tính tạm trên client, nhưng phần chính thức tính/ghi nhận trên backend (stored function hoặc service) để đảm bảo đồng nhất.
- Phúc khảo (quan trọng):
  - Sinh viên nộp phúc khảo từ module Sinh viên. Phúc khảo liên quan tới lớp/ môn/ sinh viên/ thành phần điểm.
  - Luồng xử lý:
    1. Sinh viên nộp yêu cầu phúc khảo -> `POST /appeals` (bao gồm `classId`, `studentId`, `component`, `reason`).
    2. Giảng viên nhận thông báo (SignalR event `appeal_submitted`), có thể xem yêu cầu trong giao diện phúc khảo lớp.
    3. Giảng viên kiểm tra, cập nhật kết luận và sửa điểm nếu cần -> `PUT /appeals/{appealId}` (kèm `newScore` nếu chỉnh điểm).
    4. Khi giảng viên xác nhận, backend gửi kết quả cho sinh viên và log lại (audit).
  - Yêu cầu UI: danh sách phúc khảo, chi tiết yêu cầu, form trả lời + khả năng chỉnh điểm (nếu được quyền).
- API mẫu:
  - `GET /lecturer/classes/{classId}/gradebook`
  - `POST /lecturer/classes/{classId}/grades` — submit/update grades
  - `GET /lecturer/appeals` — list appeals assigned to lecturer
  - `PUT /lecturer/appeals/{id}` — resolve appeal

### 2.6. Giấy xác nhận cho sinh viên (Giấy XN)
- Mục tiêu: giảng viên có thể tạo/ký/duyệt các giấy xác nhận tiêu chuẩn cho sinh viên (ví dụ: giấy xác nhận sinh viên đang theo học) — tính năng này thường cần minimal fields và quy trình đơn giản.
- Luồng tạo giấy xác nhận:
  1. Giảng viên mở trang `Tạo giấy XN` hoặc tại trang hồ sơ sinh viên bấm `Tạo giấy XN`.
  2. Form gồm: `studentId`, `loại giấy` (mẫu), `ngôn ngữ`, `lý do`, `ngày cần`, `ghi chú`.
  3. Submit -> `POST /lecturer/confirmations`.
  4. Backend tạo record, cấp số phiếu, và trạng thái `Pending`.
  5. Nếu quy trình yêu cầu ký số/ duyệt, gửi tới người duyệt/ban liên quan; khi duyệt xong backend cập nhật trạng thái `Approved` và cung cấp file PDF (generated) hoặc URL để download.
- UI: form tạo, danh sách yêu cầu (Pending/Approved/Rejected), chi tiết phiếu (số, ngày tạo, trạng thái), nút tải PDF khi Approved.
- API mẫu: `POST /lecturer/confirmations`, `GET /lecturer/confirmations/{id}`

### 2.7. Tra cứu học phí sinh viên (có sẵn trong project)
- Giảng viên có thể tra cứu học phí theo MSSV và học kỳ.
- Luồng:
  - UI: form nhập MSSV (bắt buộc) và học kỳ (tùy chọn) -> nhấn Tra cứu.
  - Backend: `GET /lecturer/tuition?studentId=...&semester=...` hoặc provider tương đương.
  - Kết quả: danh sách học kỳ với `soTinChi`, `hocPhi`, `daDong`, `soTienConLai`, `noHocKyTruoc`.
- Lưu ý: cần xử lý quyền truy cập (chỉ giảng viên được phép tra cứu thông tin học phí của sinh viên trong phạm vi họ được phép xem).

### 2.8. Giao tiếp & Thông báo (SignalR)
- Thông báo real-time: group theo `lecturer_{id}`, `class_{classId}`.
- Event tiêu biểu: `grade_published`, `appeal_submitted`, `attendance_flagged`, `confirmation_created`, `tuition_query_result`.
- UI: icon thông báo toàn ứng dụng, màn `Notifications` liệt kê, trạng thái read/unread.

### 2.9. Báo cáo & Export
- Dashboard lớp: average grade, điểm phân bố, tỷ lệ chuyên cần.
- Export: CSV/PDF cho bảng điểm, danh sách chuyên cần, báo cáo lớp.
- API: `GET /lecturer/classes/{classId}/report?type=grades|attendance`

---

## 3. Dữ liệu & mô hình (tóm tắt)
Các trường cần chú ý cho các endpoint trên:
- Class: `classId`, `maMon`, `tenMon`, `nhom`, `phong`, `siSo`, `namHoc`, `semesterId`.
- Student: `studentId`, `mssv`, `hoTen`, `nganh`, `khoa`.
- Attendance record: `attendanceId`, `classId`, `date`, `studentId`, `status`, `markedBy`, `reason`, `timestamp`.
- Grade item: `gradeId`, `classId`, `studentId`, `component`, `score`, `weight`, `enteredBy`, `timestamp`.
- Appeal: `appealId`, `classId`, `studentId`, `component`, `reason`, `status`, `requestedAt`, `resolvedAt`, `resolvedBy`, `notes`.
- Confirmation (Giấy XN): `confirmationId`, `studentId`, `type`, `language`, `requestedBy`, `status`, `number`, `pdfUrl`, `createdAt`.

---

## 4. Sequence flows (chú trọng phúc khảo & giấy xác nhận)

### Phúc khảo (Appeal)
1. Sinh viên nộp appeal -> `POST /appeals`
2. Backend lưu và emit SignalR `appeal_submitted` tới `lecturer_{lecturerId}`
3. Giảng viên mở danh sách appeal, xem chi tiết -> `GET /lecturer/appeals`
4. Giảng viên phản hồi/điều tra, nếu cần chỉnh điểm gọi `PUT /lecturer/appeals/{id}` và `POST /lecturer/classes/{classId}/grades` để cập nhật điểm.
5. Backend gửi notification tới sinh viên và log thay đổi.

### Tạo Giấy XN
1. Giảng viên mở form -> điền `studentId`, `type`, `ngôn ngữ`, `ngày cần` -> `POST /lecturer/confirmations`.
2. Backend tạo record, cấp `number` -> trạng thái `Pending` hoặc `Approved` tùy quy trình.
3. Khi approved, backend tạo PDF và cung cấp `pdfUrl` để download.
4. Client hiển thị danh sách và link tải khi ready.

---

## 5. API & Real-time (tóm tắt)
- REST endpoints: dùng cấu trúc `/lecturer/...` để phân biệt quyền và routing.
- Real-time hub: `notifications` (SignalR) — events: `class_updated`, `appeal_submitted`, `confirmation_updated`, `grade_published`, `attendance_flagged`.

---

## 6. UI notes (gợi ý triển khai mobile)
- Home quick access: icon/tiles cho `Lịch giảng`, `Danh sách lớp`, `Nhập điểm`, `Phúc khảo`, `Giấy XN`, `Tra cứu học phí`.
 - Home quick access: icon/tiles cho `Lịch giảng`, `Danh sách lớp`, `Nhập điểm`, `Phúc khảo`, `Giấy XN`, `Tra cứu học phí`, `Quy định`.
- Class list: card-based, show status and quick actions (Attendance / Gradebook / Appeals).
- Gradebook: editable table with components header; confirm/publish action.
- Appeals screen: list with filters (Pending, Resolved), each item expandable to see student remarks and evidence.
- Confirmation screen: form + list of requests.
- Tuition lookup: simple form (MSSV + Học kỳ) + result list per học kỳ.

- Quy định: nút truy cập nhanh hiển thị các quy định, quy chế và hướng dẫn đào tạo (danh mục đọc nhanh cho giảng viên).

---

## 7. Bảo mật & phân quyền
- Chỉ giảng viên authenticated mới gọi `lecturer` endpoints.
- Kiểm tra quyền: giảng viên chỉ được thao tác lên lớp họ phụ trách (classId) trừ trường hợp admin.
- Audit trail cho mọi thao tác thay đổi điểm/chuyên cần.

---

## 8. Next steps & đề xuất
- Xác nhận lại endpoints backend hiện có; bổ sung/điều chỉnh nếu backend chưa có route.
- Tạo acceptance criteria cho những màn chính: Class Detail, Gradebook, Appeals, Confirmation, Tuition Lookup.
- Phân tách task implementation: UI (Flutter) và API (backend). Cần priority: (1) Gradebook + publish, (2) Appeals flow, (3) Confirmation flow, (4) Attendance, (5) Tuition lookup (nếu chưa hoàn thiện).

---

Nếu bạn đồng ý, mình sẽ:
- Lưu file này vào `docs/lecturer-module.md` (đã thực hiện),
- Hoặc chuyển sang một bộ ticket (viết dưới dạng task list / Jira-style) để triển khai.

Bạn muốn mình tiếp theo: phá nhỏ thành task UI + API, hay giữ dạng tài liệu như này và chỉnh thêm chi tiết API thực tế?