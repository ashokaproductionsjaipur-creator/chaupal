# CHAUPAL Project Handoff / Resume Notes

Last updated: 2026-09-09

## Project
- App: **चौपाल | CHAUPAL**
- Platform: FlutterFlow UI + Flutter code + Supabase backend
- GitHub repository: `ashokaproductionsjaipur-creator/chaupal`
- Working branch: **develop**
- Do NOT intentionally modify the FlutterFlow-generated `flutterflow` branch.
- User's goal: production-ready app; user should mainly perform testing while implementation/fixes are handled in code/backend.

## Source of truth
- The user's latest Master Development Prompt is the authoritative product specification.
- Preserve all Master Prompt rules unless the user explicitly changes them.
- Latest user clarification: **Create Job Audio Note is REQUIRED**, max 1 minute.

## Core product rules
- Two normal mobile roles: Owner and Worker. Admin is backend/web only.
- Owner creates job -> Worker finds matching job -> Accept/Reject/Negotiate -> Owner reviews -> Owner manually contacts Worker using displayed mobile number -> Owner confirms exactly one Worker -> booking -> completion -> retention/cleanup.
- Login UI: role selection + Username/Mobile Number + Password.
- Authentication is user-facing username/password only. No OTP, SMS verification, email login, email verification, phone auth, or mobile-auth flow.
- Username is unique; mobile number is a separate DB field and may also be entered as username.
- Worker accounts start PENDING VERIFICATION and cannot interact with jobs until approved.
- Owner accounts are active without manual verification.
- Worker mobile number after Accept/Negotiate is READ-ONLY TEXT. No call button, click-to-call, dialer, phone link, contacts permission, auto-dial, or in-app calling.
- One job has one final worker; one worker can have one final job per date.
- Default max active requests: 10, configurable by Admin.
- Posting window: previous day 10:30 AM IST through job day 9:50 AM IST, enforced by backend/server time.
- Retention default: 3 days, configurable; heavy/detailed data is cleaned while lightweight history remains. Aadhaar never goes into history.
- No payments/wallet/escrow/gateway, video calls, social feed/comments, video uploads, large galleries, unnecessary chat/contact integration.

## Supabase
- ONLY current project: `iaumkrgocskwhhwdwnxj`
- Old project `lrdugubqvytysyooovjb` must not be used unless explicitly requested.
- public `users` table is linked to `auth.users`.
- Current public users fields include: id, username (unique normalized lowercase), mobile_number, full_name, role, account_status, timestamps.
- RLS is configured so clients cannot directly insert/update/delete user rows; backend/service function handles protected operations.
- `verify_chaupal_password` SECURITY DEFINER function exists and verifies the entered password against Supabase auth password hash.
- Known test user used during backend verification: username `testowner3`, role `owner`, mobile `9876543212`, active. Do not store or add any password here.

## Authentication architecture
- Previous direct custom username-auth approaches caused FlutterFlow 401/invalid_credentials issues.
- Current chosen architecture: **username/role -> hidden Supabase auth identity -> native Supabase login with the entered password**.
- Edge Function: `chaupal-login-identity`
  - Purpose: resolve username/mobile + role to hidden Supabase login identity.
  - Password must NOT be sent to this resolver API.
- FlutterFlow native Supabase login is intended to use the returned hidden login email internally; the user still sees only username/password.

## FlutterFlow
- Current pages include: RoleSelection, LoginScreen, WorkerRegistration, OwnerDashboard, WorkerJobFeed, CreateJobPost, JobRequestManagement, WorkerProfileStatus, AdminVerificationPanel, JobHistoryArchive, Notifications.
- Login UI is bilingual Hindi/English and currently visually present in FlutterFlow.
- Previous generated LoginScreen had button action wiring limitations; custom code/action integration is being handled in the code branch rather than relying on missing generated callbacks.

## GitHub / local development
- Private GitHub repo exists: `ashokaproductionsjaipur-creator/chaupal`
- `develop` branch is the working/testing branch.
- FlutterFlow's generated branch should be treated as generated source and not manually maintained.
- CI workflow exists at `.github/workflows/flutter_ci.yml` on `develop`.
- CI uses Flutter **3.29.3**.
- CI steps: checkout -> Flutter setup -> `flutter pub get` -> analyze -> test -> debug APK build -> upload debug artifact.
- Latest dependency compatibility fix: `google_fonts` is pinned to **6.3.2** for Flutter 3.29.3 / Dart 3.7.2; `intl` is 0.19.0; Supabase packages remain `supabase: 2.7.0`, `supabase_flutter: 2.9.0`.
- A previous CI run failed before this latest dependency commit because `google_fonts >=6.3.3` required Dart >=3.9.0. The latest fix was committed after that stale run; a fresh run should be checked.
- Do not recreate old Android v1 embedding compatibility shims. MainActivity uses `io.flutter.embedding.android.FlutterActivity` and the old shim files should remain absent.

## Current immediate task
1. User has installed/opened VS Code on their Windows computer.
2. User wants to run/test the `develop` branch on this same computer using Flutter Run/Debug, not an APK on another device.
3. Next local setup sequence is:
   - Open VS Code.
   - Open Terminal -> New Terminal.
   - Clone the develop branch:
     `git clone -b develop https://github.com/ashokaproductionsjaipur-creator/chaupal.git`
   - `cd chaupal`
   - `flutter pub get`
   - `flutter devices`
   - `flutter run`
4. User is non-technical and prefers one-step-at-a-time screenshot guidance. Do not ask them to make unnecessary code changes.
5. If GitHub authentication is requested during clone, stop and guide from the screenshot.

## Resume protocol after computer shutdown
- First confirm VS Code/project folder is available.
- If the repo is already cloned, do NOT clone again; open the existing `chaupal` folder and check out/update `develop`.
- If needed:
  `git fetch origin`
  `git checkout develop`
  `git pull origin develop`
- Then run `flutter pub get`, check `flutter devices`, and `flutter run`.
- Continue from the latest runtime/build error reported by the user.
- Before changing product behavior, compare the requested change against the Master Development Prompt and this handoff.

## Important exclusions
- Never use the old Supabase project.
- Never put secrets/passwords/service-role keys into GitHub or this handoff file.
- Never reintroduce OTP/SMS/email verification/mobile auth/click-to-call/phone permission/payment features unless the user explicitly changes the Master Prompt.
