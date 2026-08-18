# ShopMate - Architecture

ShopMate is an AI-assisted, budget-aware in-store supermarket shopping decision-support mobile application.

## 1. System Architecture

- **Frontend (Mobile App)**: Flutter (Dart) with Riverpod.
- **Backend API**: Python FastAPI.
- **Database**: MySQL.
- **AI/ML Engine**: Python.
  - *Computer Vision*: YOLO + OpenCV + EasyOCR.
  - *Recommendation*: Weighted scoring + similarity.
  - *Budget Optimization*: 0/1 Knapsack.
  - *Product Association*: Apriori.
  - *Navigation*: Dijkstra's algorithm.
- **Authentication**: JWT.

## 2. Module List

1. **User Management Module**: Auth, profile.
2. **Store & Product Module**: Supermarket selection, lookup.
3. **Shopping Session Module**: Budget, active cart, estimated bill.
4. **Computer Vision Module**: YOLO product detection and OCR text extraction.
5. **AI & Analytics Module**: Budget optimization, recommendations, path planning.

## 3. Database Module List

- **Users**: id, email, password_hash, preferences_json, created_at
- **Stores**: id, name, location, layout_graph_json
- **Products**: id, store_id, name, brand, category, price, discount, location_node_id, image_url
- **Shopping_Lists**: id, user_id, name, budget_limit, created_at, status
- **Shopping_List_Items**: id, list_id, product_id, quantity, is_purchased
- **Transactions**: id, user_id, store_id, total_amount, date
- **User_Interactions**: id, user_id, product_id, interaction_type

## 4. API Module List (FastAPI)

- `POST /auth/register`, `POST /auth/login`
- `GET /stores`, `GET /stores/{store_id}`
- `GET /products/{store_id}`, `GET /products/search`
- `POST /vision/analyze`
- `POST /cart/optimize`
- `GET /recommendations/{user_id}`
- `GET /recommendations/alternatives/{product_id}`
- `GET /associations/{product_id}`
- `POST /navigation/route`
- `GET /analytics/spending/{user_id}`

## 5. AI Module List (Python)

- `vision_pipeline.py`: OpenCV, YOLO, EasyOCR.
- `product_matcher.py`: Match CV features to DB.
- `budget_optimizer.py`: 0/1 Knapsack.
- `recommendation_engine.py`: Weighted similarity.
- `association_rules.py`: Apriori.
- `store_navigator.py`: Dijkstra.

## 6. Flutter Screen List

1. **Onboarding**: Splash, Login, Register.
2. **Home**: Store Selection, Budget, Recent Lists.
3. **Shopping Setup**: Create List, Set Budget.
4. **Active Shopping**: Camera, Product Details, Cart, Budget Warning.
5. **AI Insights**: Recommendations, Cheaper Alternatives, Associations.
6. **Store Navigation**: Map/Route View.
7. **Profile**: Settings, Past Receipts.

## 7. Development Phases

- **Phase 1**: Foundation & Architecture Setup (DB, FastAPI, Flutter skeleton).
- **Phase 2**: Core Computer Vision Pipeline.
- **Phase 3**: Core Shopping Features.
- **Phase 4**: Advanced AI Integration.
- **Phase 5**: Navigation & Analytics.
- **Phase 6**: Polish, Testing, and Deployment.

## 8. Dependencies

- **Frontend**: flutter_riverpod, camera, http, shared_preferences, image_picker, fl_chart.
- **Backend/AI**: fastapi, sqlalchemy, pymysql, python-jose, opencv-python, ultralytics, easyocr, pandas, scikit-learn, mlxtend, networkx.

## 9. Testing Strategy

- **Backend**: pytest, httpx.
- **AI/CV**: Validation dataset accuracy testing.
- **Frontend**: Flutter Widget and Riverpod unit tests.
- **E2E**: Integration testing for the primary flow.
