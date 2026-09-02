@echo off
title Doe+ - App (Flutter Web)
cd /d "%~dp0"
echo Subindo o app Doe+ em http://localhost:5050 ...
echo (deixe esta janela aberta enquanto estiver usando o app)
echo.
flutter run -d web-server --web-port 5050 --web-hostname 0.0.0.0
echo.
echo O processo terminou. Pressione qualquer tecla para fechar.
pause >nul
