# 🌿 Eco Warrior - Carbon Footprint Tracker

A Flutter-based mobile application for tracking carbon footprint from home appliances, paired with a FastAPI backend for data management.

## 📱 Features

- **Dashboard** - View daily/weekly/monthly carbon footprint statistics
- **Appliance Management** - Add and manage home appliances with power ratings
- **Usage Logging** - Log appliance usage hours and calculate emissions
- **Reports & Analytics** - Visual charts showing consumption trends
- **Eco Tips** - Personalized recommendations to reduce carbon footprint
- **Achievements** - Gamification system with badges for eco-friendly habits
- **Dark/Light Mode** - Theme toggle support

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **fl_chart** - Data visualization
- **shared_preferences** - Local storage
- **http** - API communication

### Backend
- **FastAPI** - Python web framework
- **SQLite** - Database (via Python's sqlite3)
- **Pydantic** - Data validation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.2.0+)
- Python 3.9+
- Node.js (optional, for web build)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Abhay9058/Carbon-footrpint-for-Home-Appliances.git
   cd Carbon-footrpint-for-Home-Appliances
   ```

2. **Start the backend**
   ```bash
   cd backend
   pip install -r requirements.txt
   python main.py
   ```
   Backend runs on `http://127.0.0.1:8000`

3. **Run the Flutter app**
   ```bash
   flutter pub get
   flutter run
   ```

### Running on Chrome (Web)
```bash
# Terminal 1 - Backend
python backend/main.py

# Terminal 2 - Frontend
flutter run -d chrome
```

## 📁 Project Structure

```
├── lib/                    # Flutter frontend
│   ├── core/              # Theme, constants, utilities
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── screens/           # App screens
│   ├── services/          # API services
│   └── widgets/           # Reusable widgets
├── backend/               # FastAPI backend
│   ├── routes/           # API endpoints
│   ├── schemas/          # Data schemas
│   └── services/         # Database services
└── web/                  # Web build files
```

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/health` | API health status |
| POST | `/calculate` | Calculate carbon footprint |
| GET | `/user/{user_id}` | Get user data |
| GET | `/appliances/{user_id}` | Get user appliances |
| POST | `/appliances/{user_id}` | Add new appliance |
| GET | `/usage/{user_id}` | Get usage logs |
| POST | `/usage/{user_id}` | Create usage log |
| GET | `/analytics/{user_id}` | Get analytics data |

## 🌐 Screenshots

- Dashboard with carbon footprint overview
- Appliance management with CRUD operations
- Reports with interactive charts
- Achievement badges system

## 📝 License

MIT License

---

Made with ❤️ for a greener planet 🌏