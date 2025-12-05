# Fix Lecturer Courses Function - Allow empty semester parameter
# Run this script to update the database function

Write-Host "🔧 Updating func_get_lecturer_courses..." -ForegroundColor Cyan

$env:PGPASSWORD = "postgres"
psql -U postgres -d eUIT -f fix_lecturer_courses_function.sql

Write-Host "✅ Function updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Test with:" -ForegroundColor Yellow
Write-Host "  SELECT * FROM func_get_lecturer_courses('80068', '');" -ForegroundColor White
