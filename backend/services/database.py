import aiosqlite
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from schemas import (
    UserModel, ApplianceModel, UsageLogModel, 
    ApplianceCreate, UsageLogCreate, AnalyticsModel, EcoTipModel,
    LoginRequest, RegisterRequest, AuthResponse
)

EMISSION_FACTOR = 0.82
DATABASE_PATH = "eco_warrior.db"


class Database:
    def __init__(self):
        self.db_path = DATABASE_PATH
        self._initialized = False
        self._lock = asyncio.Lock()
    
    async def initialize(self):
        async with self._lock:
            if self._initialized:
                return
            
            async with aiosqlite.connect(self.db_path) as db:
                await db.execute("""
                    CREATE TABLE IF NOT EXISTS users (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        username TEXT NOT NULL,
                        email TEXT NOT NULL UNIQUE,
                        password TEXT NOT NULL,
                        role TEXT DEFAULT 'user',
                        member_since TEXT NOT NULL,
                        total_carbon_emissions REAL DEFAULT 0.0,
                        dark_mode INTEGER DEFAULT 0,
                        eco_tips_notifications INTEGER DEFAULT 1
                    )
                """)
                
                await db.execute("""
                    CREATE TABLE IF NOT EXISTS appliances (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id INTEGER NOT NULL,
                        name TEXT NOT NULL,
                        appliance_type TEXT NOT NULL,
                        wattage REAL NOT NULL,
                        quantity INTEGER NOT NULL,
                        created_at TEXT NOT NULL,
                        FOREIGN KEY (user_id) REFERENCES users (id)
                    )
                """)
                
                await db.execute("""
                    CREATE TABLE IF NOT EXISTS usage_logs (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id INTEGER NOT NULL,
                        appliance_id INTEGER NOT NULL,
                        hours REAL NOT NULL,
                        date TEXT NOT NULL,
                        carbon_emission REAL NOT NULL,
                        created_at TEXT NOT NULL,
                        FOREIGN KEY (user_id) REFERENCES users (id),
                        FOREIGN KEY (appliance_id) REFERENCES appliances (id)
                    )
                """)
                
                await db.execute("""
                    CREATE TABLE IF NOT EXISTS eco_tips (
                        id INTEGER PRIMARY KEY,
                        title TEXT NOT NULL,
                        description TEXT NOT NULL,
                        category TEXT NOT NULL
                    )
                """)
                
                await db.commit()
                
                cursor = await db.execute("SELECT COUNT(*) FROM users")
                row = await cursor.fetchone()
                if row[0] == 0:
                    await self._insert_sample_data(db)
                    await db.commit()
            
            self._initialized = True
    
    async def _insert_sample_data(self, db):
        await db.execute("""
            INSERT INTO users (id, username, email, password, role, member_since, total_carbon_emissions, dark_mode, eco_tips_notifications)
            VALUES (1, 'eco_warrior', 'demo@ecowarrior.com', 'password123', 'user', ?, 125.5, 0, 1)
        """, (datetime.now().strftime("%Y-%m-%d"),))
        
        created_at = datetime.now().isoformat()
        await db.execute("""
            INSERT INTO appliances (id, user_id, name, appliance_type, wattage, quantity, created_at)
            VALUES (1, 1, 'LED Bulb', 'Lighting', 10, 5, ?)
        """, (created_at,))
        
        await db.execute("""
            INSERT INTO appliances (id, user_id, name, appliance_type, wattage, quantity, created_at)
            VALUES (2, 1, 'Air Conditioner', 'Cooling', 1500, 1, ?)
        """, (created_at,))
        
        await db.execute("""
            INSERT INTO appliances (id, user_id, name, appliance_type, wattage, quantity, created_at)
            VALUES (3, 1, 'Refrigerator', 'Kitchen', 150, 1, ?)
        """, (created_at,))
        
        eco_tips = [
            (1, "Switch to LED", "Replace incandescent bulbs with LED lights to save up to 75% energy.", "Lighting"),
            (2, "Optimal Temperature", "Set AC to 24°C for optimal energy efficiency.", "Cooling"),
            (3, "Unplug Idle Devices", "Unplug chargers and devices when not in use to eliminate phantom energy consumption.", "General"),
            (4, "Use Natural Light", "Maximize natural daylight to reduce artificial lighting needs.", "Lighting"),
            (5, "Energy Star Appliances", "Choose Energy Star certified appliances for 10-50% less energy consumption.", "General"),
            (6, "Regular Maintenance", "Clean AC filters monthly for better efficiency and lower emissions.", "Cooling"),
            (7, "Power Strip Strategy", "Use power strips to easily switch off multiple devices at once.", "General"),
            (8, "Efficient Cooking", "Use lids while cooking to reduce energy usage by up to 30%.", "Kitchen"),
        ]
        
        for tip in eco_tips:
            await db.execute("""
                INSERT INTO eco_tips (id, title, description, category)
                VALUES (?, ?, ?, ?)
            """, tip)
        
        await self._initialize_sample_usage(db)
    
    async def _initialize_sample_usage(self, db):
        today = datetime.now()
        created_at = datetime.now().isoformat()
        
        appliance_data = {
            1: {"wattage": 10, "quantity": 5},
            2: {"wattage": 1500, "quantity": 1},
            3: {"wattage": 150, "quantity": 1},
        }
        
        def calc_emission(appliance_id, hours):
            app = appliance_data.get(appliance_id, {"wattage": 0, "quantity": 1})
            return round((app["wattage"] * hours * app["quantity"] / 1000) * EMISSION_FACTOR, 3)
        
        dates = []
        for i in range(60):
            date = (today - timedelta(days=59-i)).strftime("%Y-%m-%d")
            dates.append(date)
        
        last_7_dates = []
        for i in range(10):
            date = (today - timedelta(days=6-i)).strftime("%Y-%m-%d")
            last_7_dates.append(date)
        
        sample_logs = [
            (1, 6.0, last_7_dates[0]),
            (2, 8.0, last_7_dates[1]),
            (3, 24.0, last_7_dates[2]),
            (1, 5.0, last_7_dates[3]),
            (2, 10.0, last_7_dates[4]),
            (1, 7.0, last_7_dates[5]),
            (2, 6.0, last_7_dates[6]),
            (3, 24.0, last_7_dates[7]),
            (1, 4.0, last_7_dates[8]),
            (2, 12.0, last_7_dates[9]),
            (1, 6.0, dates[10]),
            (2, 8.0, dates[11]),
            (3, 24.0, dates[12]),
            (1, 5.0, dates[13]),
            (2, 10.0, dates[14]),
            (1, 7.0, dates[15]),
            (3, 12.0, dates[16]),
            (2, 8.0, dates[17]),
            (1, 6.0, dates[18]),
            (2, 9.0, dates[19]),
            (3, 24.0, dates[20]),
            (1, 5.0, dates[21]),
            (2, 11.0, dates[22]),
            (1, 6.0, dates[23]),
            (3, 24.0, dates[24]),
            (2, 7.0, dates[25]),
            (1, 5.0, dates[26]),
            (2, 10.0, dates[27]),
            (1, 6.0, dates[28]),
            (3, 24.0, dates[29]),
        ]
        
        for appliance_id, hours, date in sample_logs:
            emission = calc_emission(appliance_id, hours)
            await db.execute("""
                INSERT INTO usage_logs (user_id, appliance_id, hours, date, carbon_emission, created_at)
                VALUES (1, ?, ?, ?, ?, ?)
            """, (appliance_id, hours, date, emission, created_at))
    
    async def calculate_carbon_emission(self, appliance_id: int, hours: float) -> float:
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute(
                "SELECT wattage, quantity FROM appliances WHERE id = ?",
                (appliance_id,)
            )
            row = await cursor.fetchone()
            
            if not row:
                return 0.0
            
            emission = (row['wattage'] * hours * row['quantity'] / 1000) * EMISSION_FACTOR
            return round(emission, 3)
    
    async def get_user(self, user_id: int) -> Optional[UserModel]:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,)
            )
            row = await cursor.fetchone()
            
            if not row:
                return None
            
            return UserModel(
                id=row['id'],
                username=row['username'],
                email=row['email'],
                role=row['role'],
                member_since=row['member_since'],
                total_carbon_emissions=row['total_carbon_emissions'],
                dark_mode=bool(row['dark_mode']),
                eco_tips_notifications=bool(row['eco_tips_notifications'])
            )
    
    async def update_user(self, user_id: int, username: Optional[str] = None,
                          email: Optional[str] = None,
                          dark_mode: Optional[bool] = None, 
                          eco_tips_notifications: Optional[bool] = None) -> Optional[UserModel]:
        await self.initialize()
        
        updates = []
        params = []
        
        if username is not None:
            updates.append("username = ?")
            params.append(username)
        if email is not None:
            updates.append("email = ?")
            params.append(email)
        if dark_mode is not None:
            updates.append("dark_mode = ?")
            params.append(1 if dark_mode else 0)
        if eco_tips_notifications is not None:
            updates.append("eco_tips_notifications = ?")
            params.append(1 if eco_tips_notifications else 0)
        
        if not updates:
            return await self.get_user(user_id)
        
        params.append(user_id)
        
        async with aiosqlite.connect(self.db_path) as db:
            await db.execute(
                f"UPDATE users SET {', '.join(updates)} WHERE id = ?",
                params
            )
            await db.commit()
        
        return await self.get_user(user_id)
    
    async def get_appliances(self, user_id: int) -> List[ApplianceModel]:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute(
                "SELECT * FROM appliances WHERE user_id = ?",
                (user_id,)
            )
            rows = await cursor.fetchall()
            
            return [
                ApplianceModel(
                    id=row['id'],
                    user_id=row['user_id'],
                    name=row['name'],
                    appliance_type=row['appliance_type'],
                    wattage=row['wattage'],
                    quantity=row['quantity'],
                    created_at=row['created_at']
                )
                for row in rows
            ]
    
    async def create_appliance(self, user_id: int, appliance: ApplianceCreate) -> ApplianceModel:
        await self.initialize()
        created_at = datetime.now().isoformat()
        
        async with aiosqlite.connect(self.db_path) as db:
            cursor = await db.execute("""
                INSERT INTO appliances (user_id, name, appliance_type, wattage, quantity, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (user_id, appliance.name, appliance.appliance_type, appliance.wattage, appliance.quantity, created_at))
            await db.commit()
            appliance_id = cursor.lastrowid
        
        return ApplianceModel(
            id=appliance_id,
            user_id=user_id,
            name=appliance.name,
            appliance_type=appliance.appliance_type,
            wattage=appliance.wattage,
            quantity=appliance.quantity,
            created_at=created_at
        )
    
    async def delete_appliance(self, appliance_id: int) -> bool:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            cursor = await db.execute(
                "DELETE FROM appliances WHERE id = ?",
                (appliance_id,)
            )
            await db.commit()
            return cursor.rowcount > 0
    
    async def create_usage_log(self, user_id: int, log: UsageLogCreate) -> UsageLogModel:
        await self.initialize()
        emission = await self.calculate_carbon_emission(log.appliance_id, log.hours)
        created_at = datetime.now().isoformat()
        
        async with aiosqlite.connect(self.db_path) as db:
            cursor = await db.execute("""
                INSERT INTO usage_logs (user_id, appliance_id, hours, date, carbon_emission, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (user_id, log.appliance_id, log.hours, log.date, emission, created_at))
            await db.commit()
            log_id = cursor.lastrowid
            
            await db.execute("""
                UPDATE users SET total_carbon_emissions = total_carbon_emissions + ?
                WHERE id = ?
            """, (emission, user_id))
            await db.commit()
        
        return UsageLogModel(
            id=log_id,
            user_id=user_id,
            appliance_id=log.appliance_id,
            hours=log.hours,
            date=log.date,
            carbon_emission=emission,
            created_at=created_at
        )
    
    async def get_usage_logs(self, user_id: int, limit: Optional[int] = None) -> List[UsageLogModel]:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            query = "SELECT * FROM usage_logs WHERE user_id = ? ORDER BY date DESC"
            params = [user_id]
            
            if limit:
                query += " LIMIT ?"
                params.append(limit)
            
            cursor = await db.execute(query, params)
            rows = await cursor.fetchall()
            
            return [
                UsageLogModel(
                    id=row['id'],
                    user_id=row['user_id'],
                    appliance_id=row['appliance_id'],
                    hours=row['hours'],
                    date=row['date'],
                    carbon_emission=row['carbon_emission'],
                    created_at=row['created_at']
                )
                for row in rows
            ]
    
    async def get_analytics(self, user_id: int) -> AnalyticsModel:
        await self.initialize()
        today = datetime.now()
        today_str = today.strftime("%Y-%m-%d")
        
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            cursor = await db.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,)
            )
            user_row = await cursor.fetchone()
            total_carbon_emissions = user_row['total_carbon_emissions'] if user_row else 0.0
            
            cursor = await db.execute(
                "SELECT * FROM appliances WHERE user_id = ?",
                (user_id,)
            )
            appliance_rows = await cursor.fetchall()
            appliances = {row['id']: row for row in appliance_rows}
            
            cursor = await db.execute(
                "SELECT * FROM usage_logs WHERE user_id = ?",
                (user_id,)
            )
            log_rows = await cursor.fetchall()
            logs = list(log_rows)
            
            daily_emissions = []
            for i in range(7):
                date = (today - timedelta(days=6-i)).strftime("%Y-%m-%d")
                day_emission = sum(
                    row['carbon_emission'] for row in logs if row['date'] == date
                )
                daily_emissions.append({
                    "date": date,
                    "emission": round(day_emission, 3)
                })
            
            last_7_days = [(today - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)]
            weekly_logs = [row for row in logs if row['date'] in last_7_days]
            weekly_total = sum(row['carbon_emission'] for row in weekly_logs)
            
            month_start = today.replace(day=1)
            month_logs = [row for row in logs if row['date'] >= month_start.strftime("%Y-%m-%d")]
            monthly_total = sum(row['carbon_emission'] for row in month_logs)
            
            year_start = today.replace(month=1, day=1)
            year_logs = [row for row in logs if row['date'] >= year_start.strftime("%Y-%m-%d")]
            yearly_total = sum(row['carbon_emission'] for row in year_logs)
            
            monthly_emissions = []
            for i in range(4):
                week_start = today - timedelta(days=today.weekday() + 7*(3-i))
                week_end = week_start + timedelta(days=6)
                week_logs = [
                    row for row in logs 
                    if week_start.strftime("%Y-%m-%d") <= row['date'] <= week_end.strftime("%Y-%m-%d")
                ]
                week_emission = sum(row['carbon_emission'] for row in week_logs)
                monthly_emissions.append({
                    "week": f"Week {4-i}",
                    "emission": round(week_emission, 3)
                })
            
            emissions_by_appliance = []
            for app_id, appliance in appliances.items():
                app_logs = [row for row in logs if row['appliance_id'] == app_id]
                total_emission = sum(row['carbon_emission'] for row in app_logs)
                emissions_by_appliance.append({
                    "name": appliance['name'],
                    "type": appliance['appliance_type'],
                    "emission": round(total_emission, 3),
                    "quantity": appliance['quantity']
                })
            
            emissions_by_appliance.sort(key=lambda x: x["emission"], reverse=True)
            top_appliances = emissions_by_appliance[:5]
            highest_emission_appliance = emissions_by_appliance[0] if emissions_by_appliance else None
            
            today_logs = [row for row in logs if row['date'] == today_str]
            today_emission = sum(row['carbon_emission'] for row in today_logs)
            
            daily_average = sum(row['carbon_emission'] for row in weekly_logs) / 7 if weekly_logs else 0
            
            return AnalyticsModel(
                daily_emissions=daily_emissions,
                weekly_total=round(weekly_total, 3),
                monthly_total=round(monthly_total, 3),
                yearly_total=round(yearly_total, 3),
                monthly_emissions=monthly_emissions,
                emissions_by_appliance=emissions_by_appliance,
                top_appliances=top_appliances,
                highest_emission_appliance=highest_emission_appliance,
                today_emission=round(today_emission, 3),
                daily_average=round(daily_average, 3),
                total_carbon_emissions=round(total_carbon_emissions, 3)
            )
    
    async def get_eco_tips(self, limit: int = 5) -> List[EcoTipModel]:
        import random
        await self.initialize()
        
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute("SELECT * FROM eco_tips")
            rows = await cursor.fetchall()
            
            all_tips = [
                EcoTipModel(
                    id=row['id'],
                    title=row['title'],
                    description=row['description'],
                    category=row['category']
                )
                for row in rows
            ]
            
            return random.sample(all_tips, min(limit, len(all_tips)))

    async def login_user(self, login_data: LoginRequest) -> AuthResponse:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute(
                "SELECT * FROM users WHERE email = ? AND password = ?",
                (login_data.email, login_data.password)
            )
            row = await cursor.fetchone()
            
            if not row:
                return AuthResponse(
                    success=False,
                    message="Invalid email or password"
                )
            
            user = UserModel(
                id=row['id'],
                username=row['username'],
                email=row['email'],
                role=row['role'],
                member_since=row['member_since'],
                total_carbon_emissions=row['total_carbon_emissions'],
                dark_mode=bool(row['dark_mode']),
                eco_tips_notifications=bool(row['eco_tips_notifications'])
            )
            
            return AuthResponse(
                success=True,
                message="Login successful",
                user_id=row['id'],
                user=user
            )
    
    async def register_user(self, register_data: RegisterRequest) -> AuthResponse:
        await self.initialize()
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            cursor = await db.execute(
                "SELECT * FROM users WHERE email = ?",
                (register_data.email,)
            )
            existing = await cursor.fetchone()
            
            if existing:
                return AuthResponse(
                    success=False,
                    message="Email already registered"
                )
            
            member_since = datetime.now().strftime("%Y-%m-%d")
            cursor = await db.execute("""
                INSERT INTO users (username, email, password, role, member_since, total_carbon_emissions, dark_mode, eco_tips_notifications)
                VALUES (?, ?, ?, 'user', ?, 0.0, 0, 1)
            """, (register_data.username, register_data.email, register_data.password, member_since))
            await db.commit()
            
            user_id = cursor.lastrowid
            
            user = UserModel(
                id=user_id,
                username=register_data.username,
                email=register_data.email,
                role='user',
                member_since=member_since,
                total_carbon_emissions=0.0,
                dark_mode=False,
                eco_tips_notifications=True
            )
            
            return AuthResponse(
                success=True,
                message="Registration successful",
                user_id=user_id,
                user=user
            )


db = Database()


def get_sync_user(user_id: int) -> Optional[UserModel]:
    return asyncio.get_event_loop().run_until_complete(db.get_user(user_id))

def update_sync_user(user_id: int, username: Optional[str] = None, 
                     dark_mode: Optional[bool] = None, 
                     eco_tips_notifications: Optional[bool] = None) -> Optional[UserModel]:
    return asyncio.get_event_loop().run_until_complete(
        db.update_user(user_id, username, dark_mode, eco_tips_notifications)
    )

def get_sync_appliances(user_id: int) -> List[ApplianceModel]:
    return asyncio.get_event_loop().run_until_complete(db.get_appliances(user_id))

def create_sync_appliance(user_id: int, appliance: ApplianceCreate) -> ApplianceModel:
    return asyncio.get_event_loop().run_until_complete(db.create_appliance(user_id, appliance))

def delete_sync_appliance(appliance_id: int) -> bool:
    return asyncio.get_event_loop().run_until_complete(db.delete_appliance(appliance_id))

def create_sync_usage_log(user_id: int, log: UsageLogCreate) -> UsageLogModel:
    return asyncio.get_event_loop().run_until_complete(db.create_usage_log(user_id, log))

def get_sync_usage_logs(user_id: int, limit: Optional[int] = None) -> List[UsageLogModel]:
    return asyncio.get_event_loop().run_until_complete(db.get_usage_logs(user_id, limit))

def get_sync_analytics(user_id: int) -> AnalyticsModel:
    return asyncio.get_event_loop().run_until_complete(db.get_analytics(user_id))

def get_sync_eco_tips(limit: int = 5) -> List[EcoTipModel]:
    return asyncio.get_event_loop().run_until_complete(db.get_eco_tips(limit))

def login_sync_user(email: str, password: str) -> AuthResponse:
    return asyncio.get_event_loop().run_until_complete(
        db.login_user(LoginRequest(email=email, password=password))
    )

def register_sync_user(username: str, email: str, password: str) -> AuthResponse:
    return asyncio.get_event_loop().run_until_complete(
        db.register_user(RegisterRequest(username=username, email=email, password=password))
    )
