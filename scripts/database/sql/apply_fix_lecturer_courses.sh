#!/bin/bash

# Fix Lecturer Courses Function - Allow empty semester parameter
# Run this script to update the database function

echo "🔧 Updating func_get_lecturer_courses..."

psql -U postgres -d eUIT -f fix_lecturer_courses_function.sql

echo "✅ Function updated successfully!"
echo ""
echo "Test with:"
echo "  SELECT * FROM func_get_lecturer_courses('80068', '');"
