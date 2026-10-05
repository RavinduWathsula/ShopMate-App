<div align="center">
  <h1>🛒 ShopMate</h1>
  <p><strong>A Next-Generation Smart Grocery Shopping App powered by AI</strong></p>
</div>

---

## 🌟 About The Project
**ShopMate** is an intelligent mobile application designed to revolutionize the in-store grocery shopping experience. It features a stunning, dynamic user interface built with Flutter and is powered by a robust Python FastAPI backend.

The crown jewel of ShopMate is its **Cargills AI Scanner**. Utilizing a custom-trained YOLO object detection model, users can simply point their camera at real-world items (like Toothpaste, Astra Cup, or Sprite) and the app will instantly recognize the product and add it to their digital shopping cart!

---

## 🚀 Key Features
* **🤖 Real-time AI Product Recognition**: Point your camera at groceries to instantly identify and cart them using YOLO object detection.
* **📱 Beautiful UI/UX**: A highly polished, responsive, and dynamic user interface with custom animations and perfect camera scaling.
* **🗺️ Smart Store Navigation**: Built-in store map screens to help users navigate aisles.
* **⚡ Blazing Fast Backend**: Powered by FastAPI and an SQLite/SQLAlchemy database to handle requests instantly.

---

## 🛠️ Technology Stack
* **Frontend**: Flutter & Dart (Cross-platform Mobile UI)
* **Backend**: Python 3, FastAPI, SQLAlchemy
* **AI/Machine Learning**: Ultralytics YOLO (You Only Look Once) Object Detection
* **Database**: SQLite (Development)

---

## 🏃‍♂️ How To Run The Project
Follow these simple steps to get both the Backend and the Mobile App running on your local machine.

### 1. Start the Backend Server
The backend handles the AI processing and database management. It must be running for the app to function properly.
1. Open a terminal in the root `ShopMate` folder.
2. Run the provided startup script:
   ```powershell
   .\start_backend.bat
   ```
3. The server will start on `http://0.0.0.0:8000`. **Keep this terminal window open!**

### 2. Start the Frontend Mobile App
1. Open a **new, second** terminal window.
2. Navigate into the frontend directory:
   ```powershell
   cd frontend
   ```
3. Launch the Flutter application:
   ```powershell
   flutter run
   ```
4. *Note: If you get a "Cannot find path" error, it means you are already inside the frontend folder and can just type `flutter run`.*

---

## 🧠 Train Your Own Custom AI
ShopMate's AI Scanner is trained to recognize physical grocery items. If you want to train it on your own household items, we've built a fully automated pipeline for you!

### Step 1: Add your photos
1. Open the `my_pictures` folder in the root of the project.
2. You will see folders named `toothpaste`, `astra`, and `sprite`.
3. Drop photos of your physical items into their matching folders.

### Step 2: Auto-Import & Label
YOLO requires complex coordinate files to learn. We wrote a script that does this for you instantly. Open a terminal in the root `ShopMate` folder and run:
```powershell
.\backend\venv\Scripts\python.exe scripts/import_dataset.py
```
*(This automatically prepares your photos and generates the AI labels).*

### Step 3: Train the Model
Now, train the AI to recognize the items in your photos by running:
```powershell
.\backend\venv\Scripts\python.exe scripts/train_yolo.py
```
*(Wait 1-2 minutes for the training to finish).*

### Step 4: Restart the Backend
To load your new, smarter AI into the app:
1. Go to the terminal where your backend is running.
2. Stop it by pressing `Ctrl + C`.
3. Start it again (`.\start_backend.bat`).

Now, open your Flutter app and scan your item! 🎉
