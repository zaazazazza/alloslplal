@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

if not exist ".env" (
  echo [ERREUR] Le fichier .env est introuvable.
  echo Copie les valeurs dans .env puis relance start.bat.
  pause
  exit /b 1
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in (".env") do (
  if not "%%A"=="" set "%%A=%%B"
)

if "%PORT%"=="" set "PORT=5000"
if "%SHOP_PORT%"=="" set "SHOP_PORT=5173"
if "%NODE_ENV%"=="" set "NODE_ENV=development"
set "API_PORT=%PORT%"

where npm >nul 2>&1
if errorlevel 1 (
  echo [ERREUR] npm est introuvable. Installe Node.js puis relance ce fichier.
  pause
  exit /b 1
)

echo Construction du serveur API...
call npm run build --workspace=@workspace/api-server
if errorlevel 1 (
  echo [ERREUR] La construction du serveur a echoue.
  pause
  exit /b 1
)

echo Demarrage du bot API sur http://localhost:%PORT%
start "Shop API" /D "%~dp0" cmd /k "call npm run start --workspace=@workspace/api-server"

echo Demarrage du site Sicario Store sur http://localhost:%SHOP_PORT%
start "Sicario Store" /D "%~dp0" cmd /k "set PORT=%SHOP_PORT%&&set BASE_PATH=/&&set SHOP_API_PORT=%API_PORT%&&call npm run dev --workspace=@workspace/shop-bot -- --open"

echo Demarrage du bot Discord...
call npm start
echo.
echo Le bot Discord s'est arrete. Code retour: %ERRORLEVEL%
pause
