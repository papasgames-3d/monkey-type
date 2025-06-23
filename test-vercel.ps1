Write-Host "🚀 Testing Monkeytype Monorepo Build for Vercel" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check Node.js version
Write-Host ""
Write-Host "📦 Checking Node.js version..." -ForegroundColor Yellow
$nodeVersion = node --version
Write-Host "Current Node.js version: $nodeVersion" -ForegroundColor White

if ($nodeVersion -ne "v20.16.0") {
    Write-Host "⚠️  Warning: Expected Node.js v20.16.0, but found $nodeVersion" -ForegroundColor Yellow
    Write-Host "   This might cause build issues on Vercel" -ForegroundColor Yellow
}

# Check pnpm
Write-Host ""
Write-Host "📦 Checking pnpm..." -ForegroundColor Yellow
try {
    $pnpmVersion = pnpm --version
    Write-Host "✅ pnpm version: $pnpmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ pnpm not found. Installing..." -ForegroundColor Red
    corepack enable
    corepack prepare pnpm@latest --activate
}

# Check environment variables
Write-Host ""
Write-Host "🔧 Checking environment variables..." -ForegroundColor Yellow

if (Test-Path ".env") {
    Write-Host "✅ Found .env file" -ForegroundColor Green
    
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "RECAPTCHA_SITE_KEY") {
        Write-Host "✅ RECAPTCHA_SITE_KEY is set" -ForegroundColor Green
    } else {
        Write-Host "❌ RECAPTCHA_SITE_KEY is missing (required for build)" -ForegroundColor Red
        Write-Host "   Add to .env: RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Missing .env file in root directory" -ForegroundColor Red
    Write-Host "   Create .env with: RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" -ForegroundColor Red
    exit 1
}

# Check workspace structure
Write-Host ""
Write-Host "🏗️  Checking monorepo structure..." -ForegroundColor Yellow

$requiredFiles = @("pnpm-workspace.yaml", "turbo.json", "frontend/package.json")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing $file" -ForegroundColor Red
        exit 1
    }
}

# Clean previous builds
Write-Host ""
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow

if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force "node_modules"
    Write-Host "   Removed root node_modules" -ForegroundColor Gray
}

if (Test-Path "frontend/node_modules") {
    Remove-Item -Recurse -Force "frontend/node_modules"
    Write-Host "   Removed frontend/node_modules" -ForegroundColor Gray
}

if (Test-Path "frontend/dist") {
    Remove-Item -Recurse -Force "frontend/dist"
    Write-Host "   Removed frontend/dist" -ForegroundColor Gray
}

if (Test-Path "pnpm-lock.yaml") {
    Remove-Item -Force "pnpm-lock.yaml"
    Write-Host "   Removed pnpm-lock.yaml" -ForegroundColor Gray
}

# Install dependencies
Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
Write-Host "   Running: pnpm install --frozen-lockfile" -ForegroundColor Gray

pnpm install --frozen-lockfile

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green

# Build frontend
Write-Host ""
Write-Host "🔨 Building frontend..." -ForegroundColor Yellow
Write-Host "   Running: pnpm build-fe" -ForegroundColor Gray

pnpm build-fe

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend build failed!" -ForegroundColor Red
    exit 1
}

# Check build output
Write-Host ""
Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host "📊 Build output in frontend/dist:" -ForegroundColor White

if (Test-Path "frontend/dist") {
    $files = Get-ChildItem "frontend/dist" -Name | Select-Object -First 10
    foreach ($file in $files) {
        Write-Host "   $file" -ForegroundColor Gray
    }
    
    $totalFiles = (Get-ChildItem "frontend/dist" -Recurse -File).Count
    Write-Host "   ... and $totalFiles total files" -ForegroundColor Gray
    
    # Get build size
    $buildSize = (Get-ChildItem "frontend/dist" -Recurse | Measure-Object -Property Length -Sum).Sum
    $buildSizeMB = [math]::Round($buildSize / 1MB, 2)
    Write-Host "📦 Total build size: $buildSizeMB MB" -ForegroundColor White
} else {
    Write-Host "❌ Build output directory not found!" -ForegroundColor Red
    exit 1
}

# Check critical files
Write-Host ""
Write-Host "🔍 Checking critical build files..." -ForegroundColor Yellow

$criticalFiles = @("frontend/dist/index.html", "frontend/dist/static")
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found $file" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Warning: Missing $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Ready for Vercel deployment!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Commit changes: git add . && git commit -m 'Add Vercel config'" -ForegroundColor White
Write-Host "   2. Push to repository: git push" -ForegroundColor White
Write-Host "   3. Go to vercel.com and import your repository" -ForegroundColor White
Write-Host "   4. Set environment variables in Vercel dashboard" -ForegroundColor White
Write-Host "   5. Deploy!" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Required Vercel Environment Variables:" -ForegroundColor Cyan
Write-Host "   RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" -ForegroundColor White
Write-Host ""
Write-Host "💡 Or use Vercel CLI: npm i -g vercel && vercel --prod" -ForegroundColor Yellow 