# 🚀 Deploy Monkeytype lên Vercel

Hướng dẫn deploy dự án Monkeytype (monorepo) lên Vercel.

## 📋 Cấu trúc dự án

Monkeytype là một **monorepo** sử dụng:
- **pnpm workspaces** cho package management
- **Turbo** cho build orchestration  
- **Frontend**: Vite + TypeScript
- **Backend**: Node.js + Express (không deploy trên Vercel)

## 🔧 Bước 1: Chuẩn bị

### 1.1 Yêu cầu hệ thống
- Node.js 20.16.0
- pnpm 9.6.0
- Git repository (GitHub/GitLab)

### 1.2 Tạo file environment variables

Tạo file `.env` trong **thư mục root**:

```bash
# Bắt buộc cho build
RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI

# Tùy chọn: Firebase Authentication  
FIREBASE_APIKEY=your_api_key
FIREBASE_AUTHDOMAIN=your_domain.firebaseapp.com
FIREBASE_PROJECTID=your_project_id
FIREBASE_STORAGEBUCKET=your_project.appspot.com
FIREBASE_MESSAGINGSENDERID=your_sender_id
FIREBASE_APPID=your_app_id

# Tùy chọn: Backend URL
BACKEND_URL=

# Tùy chọn: Sentry
SENTRY=false
SERVER_OPEN=false
```

## 🌐 Bước 2: Deploy lên Vercel

### 2.1 Qua Vercel Dashboard

1. **Login**: Truy cập [vercel.com](https://vercel.com) và đăng nhập
2. **New Project**: Click "New Project"
3. **Import Repository**: Chọn repository Monkeytype của bạn
4. **Cấu hình Project**:
   - **Framework Preset**: `Other`
   - **Root Directory**: `.` (để trống)
   - **Build Command**: Vercel sẽ tự động detect từ `vercel.json`
   - **Output Directory**: Vercel sẽ tự động detect từ `vercel.json`

### 2.2 Environment Variables

Trong **Vercel Dashboard > Settings > Environment Variables**, thêm:

| Variable | Value | Environment |
|----------|-------|-------------|
| `RECAPTCHA_SITE_KEY` | `6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI` | All |
| `FIREBASE_APIKEY` | `your_firebase_key` | All (nếu có) |
| `FIREBASE_AUTHDOMAIN` | `your_domain.firebaseapp.com` | All (nếu có) |
| `FIREBASE_PROJECTID` | `your_project_id` | All (nếu có) |
| `FIREBASE_STORAGEBUCKET` | `your_bucket.appspot.com` | All (nếu có) |
| `FIREBASE_MESSAGINGSENDERID` | `your_sender_id` | All (nếu có) |
| `FIREBASE_APPID` | `your_app_id` | All (nếu có) |

### 2.3 Qua Vercel CLI

```bash
# Cài đặt Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

## 🔥 Bước 3: Test local build

Trước khi deploy, test build local:

```bash
# Install dependencies
pnpm install

# Build frontend
pnpm build-fe

# hoặc build tất cả
pnpm build

# Test build thành công
ls frontend/dist
```

## 🎯 Bước 4: Cấu hình Firebase (tùy chọn)

### 4.1 Tạo Firebase Project

1. [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "monkeytype"
3. Disable Google Analytics

### 4.2 Enable Authentication

1. **Authentication > Sign-in method**
2. Enable **Email/Password**
3. Save

### 4.3 Get Firebase Config

1. **Project Settings** ⚙️
2. **Your apps** section
3. Add **Web app** `</>`
4. App nickname: "monkeytype"
5. Copy config và thêm vào Vercel Environment Variables

## ⚙️ Build Process

Vercel sẽ thực hiện:

1. **Install**: `corepack enable && pnpm install --frozen-lockfile`
2. **Dependencies**: Tự động install workspace dependencies
3. **Build**: `cd frontend && npm run build`
4. **Output**: `frontend/dist/` → Vercel hosting

## 🔍 Kiểm tra sau deploy

✅ **Những gì hoạt động**:
- Typing tests
- Themes switching  
- Settings persistence (localStorage)
- Responsive design
- Static assets loading

❌ **Những gì KHÔNG hoạt động** (chỉ frontend):
- User registration/login (cần Firebase)
- Result saving (cần backend)
- Leaderboards (cần backend + database)
- Account system (cần backend)

## 🛠️ Troubleshooting

### Build lỗi

```bash
# Kiểm tra Node version
node --version  # Should be v20.16.0

# Clean install
rm -rf node_modules
rm pnpm-lock.yaml
pnpm install

# Test build local
pnpm build-fe
```

### Environment variables không hoạt động

1. Check Vercel Dashboard > Settings > Environment Variables
2. Đảm bảo `RECAPTCHA_SITE_KEY` được set (bắt buộc)
3. Redeploy sau khi thay đổi env vars

### Routing lỗi

- Kiểm tra `vercel.json` đã commit chưa
- Check browser network tab cho 404 errors
- Verify rewrites rules

## 🏗️ Cấu trúc file quan trọng

```
monkeytype/
├── vercel.json          # Vercel config
├── package.json         # Root scripts 
├── pnpm-workspace.yaml  # Workspace config
├── turbo.json          # Build pipeline
└── frontend/
    ├── package.json     # Frontend deps
    ├── vite.config.js   # Vite config
    └── dist/           # Build output
```

## 📚 Lưu ý quan trọng

### Frontend-only deployment
- Deploy này chỉ bao gồm **frontend static files**
- **Backend không được deploy** trên Vercel
- Cần setup riêng cho full functionality

### Full-stack options
- **Backend**: Deploy riêng trên Railway/Render/DigitalOcean
- **Database**: MongoDB Atlas
- **Authentication**: Firebase Auth

## 🚀 Quick Deploy Commands

```bash
# 1. Clone và setup
git clone your-monkeytype-repo
cd monkeytype
pnpm install

# 2. Tạo .env với RECAPTCHA_SITE_KEY

# 3. Test build
pnpm build-fe

# 4. Deploy
vercel --prod
```

---

✨ **Thành công!** Dự án sẽ có URL: `https://your-project.vercel.app`

🔥 **Pro tip**: Để có full functionality, bạn cần deploy backend riêng và setup Firebase Authentication. 