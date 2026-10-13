@echo off
cd /d "%~dp0"
py -3 "%~dp0runtime\commit-units.py"
if errorlevel 1 pause
