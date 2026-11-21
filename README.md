# BMI Tracker — Flutter UI (FastAPI integrated)

This is the updated Flutter UI source for the BMI Calculator API. It keeps the original dark navy/green health-tech direction and replaces the in-memory mock services with real HTTP requests to your FastAPI backend.

## Included screens and capabilities

- Login and account registration; access token is stored with `shared_preferences`.
- Dashboard with latest BMI, previous-result comparison, trend chart, and saved-record count.
- Create BMI measurements and save them to the API.
- BMI history with trend chart, edit, and delete actions.
- Profile view and editing (name, age, height).
- Weight goals: create, activate/deactivate, delete, and progress view.
- Settings: metric/imperial units, notification preference, and dark/light/system theme.
- About screen and sign out.

## 1. Put this source into your Flutter project

The ZIP contains `lib/`, `pubspec.yaml`, and `analysis_options.yaml` (not generated Android/iOS platform folders).

Recommended: make a backup of your existing Flutter project, then replace its `lib` folder with this package's `lib` folder and replace/merge its `pubspec.yaml` dependencies. If you want to use it as a fresh project, run `flutter create bmi_tracker` first, then copy these files into the generated project.

From the Flutter project root, run:

```powershell
flutter pub get
```

## 2. Set the API address

The default API URL in `lib/services/api_client.dart` is:

```text
http://127.0.0.1:8000/api/v1
```

Choose the correct URL for the device running Flutter:

### Flutter Web or Windows desktop

Keep the default URL if the FastAPI server is running on the same computer.

### Android emulator

Run Flutter with:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` is the Android emulator's special route to the host computer. Do not use `127.0.0.1` from the Android emulator; that points to the emulator itself.

### Physical Android phone

1. Connect the phone and computer to the same Wi-Fi network.
2. On Windows, run `ipconfig` and find the computer's IPv4 address (for example `192.168.1.20`).
3. Start FastAPI so it listens on the network interface:

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4. Run Flutter using your computer's actual IPv4 address:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api/v1
```

Replace the example IP with your own. Allow Python/Uvicorn through Windows Firewall if prompted. Never expose this development server to the public internet.

## 3. Android development HTTP permission

For local HTTP development, check `android/app/src/main/AndroidManifest.xml`. Inside the `<manifest>` element, before `<application>`, ensure this permission exists:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

For local HTTP only, the `<application>` element may also need:

```xml
android:usesCleartextTraffic="true"
```

Use HTTPS and remove the cleartext allowance for production.

## 4. Flutter Web CORS

If you run the app in Chrome, the browser sends requests from the Flutter Web origin (the host and port shown in the browser address bar). Add that exact origin to `CORS_ORIGINS` in the backend `.env` file. For example:

```env
CORS_ORIGINS=http://localhost:5000,http://127.0.0.1:5000
```

Use the actual origin/port Flutter prints for your run. Restart FastAPI after changing `.env`. Android and Windows desktop requests are not subject to browser CORS enforcement.

## 5. Start both applications

Terminal 1 — backend (from `BMI-Calculator-API`):

```powershell
.\.venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --reload
```

Terminal 2 — Flutter (from your Flutter project):

```powershell
flutter run
```

For Android emulator or a physical phone, use the relevant `--dart-define` command above.

## API routes used by this UI

| Feature | API route |
|---|---|
| Register | `POST /auth/register` |
| Login | `POST /auth/login` |
| Current profile | `GET /users/profile` |
| Update profile | `PATCH /users/profile` |
| Dashboard | `GET /dashboard` |
| BMI create/list | `POST /bmi/records`, `GET /bmi/records` |
| BMI edit/delete | `PATCH /bmi/records/{id}`, `DELETE /bmi/records/{id}` |
| BMI compare/statistics | `GET /bmi/compare`, `GET /bmi/statistics` |
| Goals | `/goals` and `/goals/progress` |
| Settings | `GET /settings`, `PATCH /settings` |

The backend stores height in centimeters and weight in kilograms. The UI converts imperial input to metric before sending it and converts values back for display.

## Notes

- This source is designed to match the BMI Calculator API scaffold created for this project. Keep the API endpoint names and JSON field names in sync if you later change the backend.
- BMI is a screening measure, not a medical diagnosis. Adult BMI categories should not be used alone to assess an individual's health.
- No real push notifications are implemented. The notification switch saves the user's preference to the backend; a notification delivery service would be a separate feature.
- The API URL is configurable at launch with `--dart-define=API_BASE_URL=...`; no source edit is needed when switching between emulator, web, and phone.
