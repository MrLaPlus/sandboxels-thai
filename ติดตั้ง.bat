@echo off
setlocal
set "SRC=%~dp0thai.js"
set "DEST=%APPDATA%\sandboxels\mods"
if not exist "%SRC%" (
  echo ไม่พบ thai.js คู่กับสคริปต์นี้
  exit /b 1
)
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%SRC%" "%DEST%\thai.js"
echo คัดลอกไปที่ %DEST%\thai.js
echo เปิดเกมใหม่ แล้วดูบรรทัด [มอดไทย] ใช้งานแล้ว ในคอนโซล
echo อย่าวางไฟล์อื่นจากโฟลเดอร์นี้เข้า mods
endlocal
