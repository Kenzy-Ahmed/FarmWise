# farmwise

A new Flutter project.

## Run the demo

Backend (FastAPI, Python 3.10+):
```bash
cd backend
pip install -r requirements.txt
./run.sh                     # API on http://localhost:8000, docs at /docs
```

Frontend (Flutter), in a second terminal from the repo root:
```bash
flutter pub get
flutter run -d chrome        # uses http://localhost:8000/api/v1 by default
```

To point the app at another backend: `flutter run -d chrome --dart-define=API_URL=http://<host>:8000/api/v1`.
If the backend is not running, the app still opens with illustrative demo data.

See [backend/README.md](backend/README.md) for the architecture and API reference.
