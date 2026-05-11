# 🦯 Guidio — AI Navigation Assistant for the Visually Impaired

> **Spec-Driven Development (SDD) Document**  
> Real-Time Object Detection · Self-Hosted AI · Voice-First UX  
> Politeknik Elektronika Negeri Surabaya · Sarjana Terapan Teknik Informatika · 2026

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [AI Model Theory & Rationale](#-ai-model-theory--rationale)
- [Feature Specifications](#-feature-specifications)
  - [SPEC-01: Camera Health & Position Handler](#spec-01-camera-health--position-handler)
  - [SPEC-02: Proactive Navigation Mode (Mode Tuntun)](#spec-02-proactive-navigation-mode-mode-tuntun)
  - [SPEC-03: Maps Integration & Audio Priority Mixer](#spec-03-maps-integration--audio-priority-mixer)
  - [SPEC-04: Voice Assistant & OCR Service](#spec-04-voice-assistant--ocr-service)
  - [SPEC-05: Risk Zone Learning](#spec-05-risk-zone-learning)
- [API Contract](#-api-contract)
- [Data Models](#-data-models)
- [System Requirements](#-system-requirements)
- [Development Workflow (Agile/Scrum)](#-development-workflow-agilescrum)
- [Sprint Roadmap](#-sprint-roadmap)
- [Environment Setup](#-environment-setup)
- [Testing Strategy](#-testing-strategy)

---

## 🌟 Project Overview

**Guidio** is an Android-first AI navigation assistant designed exclusively for blind and low-vision users. The app uses the phone camera as a "digital eye," streams frames to a self-hosted backend server, and returns voice-guided safety alerts — all in real time.

| Attribute | Detail |
|-----------|--------|
| **Platform** | Android 10 (API 29+) · Flutter |
| **Language** | Bahasa Indonesia (primary) |
| **Processing** | Self-hosted server (on-premise / VPS) |
| **Primary UX** | Voice-in / Voice-out (zero screen dependency) |
| **STT / TTS** | Gemini API (`gemini-1.5-flash`) |
| **LLM** | GPT-4 (OpenAI API) |
| **Object Detection** | YOLOv8 (self-hosted, downloaded weights) |
| **Scene Description** | BLIP (self-hosted, downloaded weights) |
| **Depth / Distance** | ZoeDepth (self-hosted, downloaded weights) |
| **OCR** | OpenOCR + Google ML Kit (self-hosted + API) |
| **RAG** | Self-hosted ChromaDB + local embedding model |

### Target Users

| Segment | Description | Key Need |
|---------|-------------|----------|
| Tunanetra Total | Total vision loss | Proactive voice alerts, full voice command |
| Low Vision | Partial vision | Object description, text reading, navigation overlay |

---

## 🏗 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    LAYER 1 — USER                       │
│              Speaker · Vibration · Screen               │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│               LAYER 2 — MOBILE APP (Flutter)            │
│     Camera │ Gemini STT/TTS │ GPS │ Audio Queue         │
└────────────────────────┬────────────────────────────────┘
                         │ WebSocket / REST
┌────────────────────────▼────────────────────────────────┐
│           LAYER 3 — SELF-HOSTED BACKEND SERVER          │
│                                                         │
│  API Gateway (FastAPI)                                  │
│  ├── Detection Engine → YOLOv8 (downloaded weights)     │
│  ├── Description      → BLIP  (downloaded weights)      │
│  ├── Depth Estimation → ZoeDepth (downloaded weights)   │
│  ├── OCR Engine       → OpenOCR + Google ML Kit         │
│  ├── LLM              → GPT-4 (OpenAI API)              │
│  ├── RAG Engine       → ChromaDB + local embeddings     │
│  ├── Geospatial       → PostGIS + GeoPandas             │
│  └── Navigation       → Google Maps Directions API      │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                    LAYER 4 — DATA LAYER                 │
│       PostgreSQL + PostGIS · Redis · ChromaDB           │
│       Firebase Auth · Local Model Storage               │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

### Mobile (Client)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter (Dart) | Android UI & app logic |
| Speech-to-Text | Gemini API (`gemini-1.5-flash`) | Convert voice command to text |
| Text-to-Speech | Gemini API / Google TTS | Natural voice output (Bahasa Indonesia) |
| Navigation | Google Maps SDK | Turn-by-turn directions display |
| HTTP/WS Client | Dio | WebSocket streaming to backend |
| State Management | Riverpod / Bloc | App state & audio queue management |
| Accessibility | Android TalkBack API | OS-level accessibility integration |

### Backend (Server) — Self-Hosted

| Component | Technology | Purpose |
|-----------|-----------|---------|
| API Framework | FastAPI (Python 3.11+) | REST + WebSocket endpoints |
| Object Detection | YOLOv8 (downloaded `.pt` weights) | Deteksi objek & rintangan dari frame kamera |
| Scene Description | BLIP (downloaded weights, self-hosted) | Menghasilkan deskripsi teks dari gambar/frame |
| Depth Estimation | ZoeDepth (downloaded weights, self-hosted) | Estimasi jarak objek per-pixel dari gambar tunggal |
| OCR | OpenOCR + Google ML Kit | Ekstraksi teks dari foto (papan, label, rambu) |
| LLM | GPT-4 (OpenAI API) | Intent routing, reasoning kontekstual, respons natural |
| RAG | ChromaDB + local embedding model | Retrieval pengetahuan navigasi & konteks lokasi |
| LLM Orchestration | LangChain 0.2+ | Prompt management, RAG pipeline, memory, tool-calling |
| Geospatial | PostGIS + GeoPandas + Shapely | Risk zone spatial analysis & clustering |
| Task Queue | Redis + Celery | Async frame processing queue |
| Auth | JWT + OAuth2 (Firebase Auth) | Session & token management |
| Containerization | Docker + Docker Compose | Service isolation & VPS deployment |

### External APIs

| API | Purpose | Used In |
|-----|---------|---------|
| Gemini API (`gemini-1.5-flash`) | STT + TTS only | Mobile client |
| GPT-4 (OpenAI API) | LLM intent routing & reasoning | Backend |
| Google Maps Directions API | Route generation | Backend Navigation Service |
| Google ML Kit | OCR fallback / mobile-side OCR | Backend + Mobile |
| Firebase Auth | OAuth2 / JWT | Backend Auth |

> **All vision AI models (YOLOv8, BLIP, ZoeDepth, OpenOCR) are downloaded and run entirely on the self-hosted backend server. No vision inference is sent to third-party APIs.**

### Database

| DBMS | Data Type | Purpose |
|------|-----------|---------|
| PostgreSQL + PostGIS | Users, routes, events | Relational + geospatial (risk zones) |
| ChromaDB | Vector embeddings | RAG knowledge base for contextual responses |
| Redis | Sessions, cache, task queue | In-memory, <1ms latency |
| Firebase Auth | Auth credentials | OAuth2 + JWT management |

---

## 🧠 AI Model Theory & Rationale

Bagian ini menjelaskan **mengapa** setiap model dipilih, cara kerjanya secara konseptual, dan bagaimana setiap model berkontribusi dalam pipeline Guidio. Ini menjadi landasan teori bagi seluruh keputusan teknis di sistem.

---

### 1. YOLOv8 — Object Detection

**Peran dalam sistem:** Mendeteksi objek dan rintangan dari frame kamera secara real-time.

**Cara kerja:**  
YOLO (*You Only Look Once*) adalah arsitektur neural network yang memproses seluruh gambar dalam satu kali forward pass. Berbeda dengan metode deteksi dua tahap (seperti R-CNN) yang memerlukan proses region proposal terpisah, YOLOv8 langsung memprediksi bounding box dan label kelas objek secara simultan dari satu gambar input.

```
Input: Frame kamera (gambar RGB)
  → Single-pass CNN inference
  → Grid cell predictions (bounding box + class + confidence)
Output: [label, confidence, x, y, w, h] per objek terdeteksi
```

**Kenapa YOLOv8:**
- Latensi inferensi rendah (< 50ms pada GPU T4) — krusial untuk real-time
- Sudah terlatih pada dataset COCO 80 kelas — cocok untuk objek umum di jalanan
- Bobot model ringan (YOLOv8m ≈ 50 MB) — efisien untuk self-hosted server
- Output bounding box digunakan langsung oleh ZoeDepth dan modul estimasi jarak

**Output yang digunakan Guidio:**
```json
{ "label": "person", "confidence": 0.87, "bbox": [x, y, w, h] }
```

---

### 2. BLIP — Scene Description (Image Captioning)

**Peran dalam sistem:** Menghasilkan deskripsi teks dari frame kamera, digunakan saat pengguna bertanya *"Apa yang ada di depan saya?"*

**Cara kerja:**  
BLIP (*Bootstrapping Language-Image Pre-training*) adalah model Vision-Language yang dilatih untuk memahami hubungan antara gambar dan teks. BLIP menggunakan arsitektur encoder-decoder: bagian visual encoder mengekstrak fitur dari gambar, lalu language decoder menghasilkan kalimat deskriptif berdasarkan fitur tersebut.

```
Input: Foto/frame kamera
  → Vision Encoder (ViT) → image features
  → Language Decoder (BERT-based) → caption text
Output: "a person walking on the sidewalk"
```

**Kenapa BLIP:**
- Menghasilkan kalimat natural yang mudah diucapkan via TTS
- Tidak hanya mendeteksi label, tapi mendeskripsikan konteks visual secara holistik
- Model downloadable dan dapat dijalankan self-hosted dengan transformers library
- Output-nya langsung dilempar ke GPT-4 sebagai konteks untuk jawaban yang lebih natural

**Contoh output dalam pipeline Guidio:**
```
Frame input: foto orang berjalan di trotoar
BLIP output: "a person walking on the sidewalk"
GPT-4 (dengan konteks BLIP): "Ada seseorang sedang berjalan di trotoar di depan Anda."
TTS: [membacakan ke pengguna]
```

---

### 3. ZoeDepth — Monocular Depth Estimation

**Peran dalam sistem:** Mengestimasi jarak objek dari kamera hanya dari satu gambar (monocular), tanpa sensor tambahan seperti LiDAR atau kamera stereo.

**Cara kerja:**  
ZoeDepth adalah model depth estimation berbasis transformer yang dilatih pada jutaan gambar dengan ground-truth depth map. ZoeDepth langsung memprediksi jarak (dalam meter) untuk setiap pixel dari gambar input tunggal. Model ini tidak memerlukan informasi kamera (focal length, baseline) — ia mempelajari korelasi visual-to-depth dari data training.

```
Input: Gambar RGB tunggal
  → DPT (Dense Prediction Transformer) backbone
  → Per-pixel depth regression
Output: Depth map — setiap pixel bernilai estimasi jarak dalam meter
```

**Perbandingan dengan metode lain:**

| Metode | Cara Kerja | Kelemahan |
|--------|-----------|-----------|
| Similar Triangle | `d = (H_real × f) / H_pixel` | Butuh focal length + ukuran objek diketahui |
| Stereo Camera | Triangulasi dua kamera | Butuh hardware khusus |
| LiDAR | Sensor laser jarak | Mahal, tidak ada di smartphone |
| **ZoeDepth** | **Belajar dari data, prediksi langsung** | **Hanya butuh satu gambar** |

**Kenapa ZoeDepth:**
- Tidak bergantung pada spesifikasi kamera pengguna (focal length beda tiap HP)
- Menghasilkan depth map seluruh frame sekaligus — tidak hanya objek terdeteksi YOLO
- Akurasi metrik baik untuk jarak 0–10 meter (range paling relevan untuk navigasi pejalan kaki)
- Bobot model downloadable dan dapat dijalankan self-hosted

**Integrasi dengan YOLO dalam Guidio:**
```
YOLO → bounding box objek (x, y, w, h)
ZoeDepth → depth map seluruh frame
Guidio → ambil nilai depth pada titik tengah bounding box YOLO
Output: estimasi jarak objek dalam meter (lebih akurat dari Similar Triangle)
```

---

### 4. GPT-4 — Large Language Model

**Peran dalam sistem:** Intent routing dari perintah suara pengguna, menghasilkan respons natural Bahasa Indonesia, dan menggabungkan output dari BLIP + YOLO + ZoeDepth menjadi panduan suara yang koheren.

**Cara kerja:**  
GPT-4 adalah large language model berbasis transformer decoder yang dilatih dengan RLHF (*Reinforcement Learning from Human Feedback*). GPT-4 menerima prompt berisi instruksi sistem, konteks percakapan, dan output dari model vision, lalu menghasilkan teks respons yang natural dan kontekstual.

**Peran GPT-4 dalam pipeline Guidio:**

```
[Konteks yang dikirim ke GPT-4]
- System prompt: "Kamu asisten navigasi untuk tunanetra..."
- YOLO output: "Detected: person (0.87), 1.4m, front-right"
- BLIP output: "a person walking on the sidewalk"
- ZoeDepth: "closest object at 1.4m"
- User query (via STT): "Apa yang ada di depan saya?"

[Output GPT-4]
"Ada seseorang sedang berjalan di trotoar, sekitar 1 meter di depan kanan Anda."
```

**Kenapa GPT-4 (bukan self-hosted):**
- Reasoning kompleks dan Bahasa Indonesia yang natural — krusial untuk UX tunanetra
- Tool-calling untuk routing intent ke fungsi yang tepat (navigate, OCR, describe, dll)
- Tidak perlu mengelola server LLM besar (GPT-4 70B+ terlalu berat untuk self-hosted)

---

### 5. Gemini API — Speech-to-Text & Text-to-Speech

**Peran dalam sistem:** Konversi suara pengguna ke teks (STT) dan konversi teks respons sistem ke suara (TTS) — berjalan di sisi mobile client.

**Cara kerja:**  
Gemini `gemini-1.5-flash` mendukung multimodal input termasuk audio streaming. Untuk STT, audio dari mikrofon dikirim ke Gemini API dan dikembalikan sebagai transkrip teks. Untuk TTS, teks dikirim ke Google TTS API dan dikembalikan sebagai audio stream yang langsung diputar.

**Kenapa Gemini untuk STT/TTS:**
- Dukungan Bahasa Indonesia yang sangat baik — akurasi tinggi untuk aksen lokal
- Latensi rendah untuk konversi suara (< 1.5 detik)
- Tidak perlu menjalankan model STT/TTS di server sendiri (menghemat resource)
- TTS menghasilkan suara yang natural dan mudah dipahami tanpa melihat layar

---

### 6. OpenOCR + Google ML Kit — Text Recognition

**Peran dalam sistem:** Membaca teks dari lingkungan sekitar (papan nama, label produk, rambu jalan) saat pengguna meminta fitur "baca tulisan ini".

**Cara kerja:**

| Komponen | Cara Kerja | Keunggulan |
|----------|-----------|-----------|
| **OpenOCR** | CNN + CTC decoder untuk scene text recognition | Akurasi tinggi untuk teks di lingkungan alami (miring, berbagai font) |
| **Google ML Kit** | On-device OCR (TensorFlow Lite based) | Bisa berjalan offline, latensi sangat rendah untuk teks sederhana |

**Pipeline OCR dalam Guidio:**
```
Frame kamera (snapshot 1080p)
  → OpenCV: pre-processing (deskew, denoise, binarize, contrast enhance)
  → OpenOCR: ekstraksi teks utama (akurasi tinggi)
  → Google ML Kit: validasi / fallback jika OpenOCR confidence rendah
  → GPT-4: format teks mentah menjadi kalimat natural Bahasa Indonesia
  → Gemini TTS: bacakan ke pengguna
```

**Kenapa dua OCR engine:**
- OpenOCR unggul untuk scene text yang kompleks (miring, bervariasi)
- Google ML Kit sebagai fallback yang cepat dan ringan
- Kombinasi keduanya memaksimalkan coverage dan akurasi

---

### Ringkasan Pipeline Antar Model

```
Kamera Frame
    │
    ├──► YOLOv8 ──────────────► Daftar objek + bounding box
    │                                    │
    ├──► ZoeDepth ────────────► Depth map per-pixel ──► Estimasi jarak per objek (gabung dengan YOLO bbox)
    │                                    │
    ├──► BLIP ────────────────► Deskripsi teks gambar
    │                                    │
    └──► OpenOCR + ML Kit ───► Teks dari gambar (jika intent OCR)
                                         │
                              ┌──────────▼──────────┐
                              │    GPT-4 (LLM)       │
                              │  + RAG (ChromaDB)    │
                              │  Intent routing &    │
                              │  Response generation │
                              └──────────┬──────────┘
                                         │
                              Gemini TTS → Suara ke pengguna
```

---

## 📐 Feature Specifications

---

### SPEC-01: Camera Health & Position Handler

**Priority:** P0 — Foundational (must pass before any AI pipeline runs)

**Description:**  
Before any frame is sent to the server, the app performs 4 parallel hardware validation checks. Frames are never silently dropped — any failure triggers a specific TTS alert.

**Validation Checks (run in parallel):**

| Check | Method | Threshold | Failure Voice Output |
|-------|--------|-----------|----------------------|
| Camera Orientation | Accelerometer pitch/roll | Tilt > 70° from horizontal | `"Arahkan kamera ke depan"` |
| Blur Detection | Laplacian variance | Below calibrated threshold | `"Gerakan terlalu cepat, mohon perlahan"` |
| Light Level | Light sensor (lux) | < 10 lux | `"Cahaya terlalu gelap"` |
| Lens Obstruction | Dominant dark pixel ratio | > 85% dark pixels | `"Kamera tertutup, periksa lensa"` |

**Behavior:**
- All 4 checks **pass** → frame forwarded to detection pipeline
- Any check **fails** → emit specific TTS alert immediately; frame not sent to server
- Re-check interval: every 500ms, independent of frame streaming rate
- System auto-recovers when condition clears (no user action needed)

**Acceptance Criteria:**
- [ ] All 4 checks complete in < 50ms combined
- [ ] TTS alert plays within 200ms of failure detection
- [ ] No frame sent to server if orientation or lens check fails
- [ ] Auto-recovery confirmed by integration test (simulate failure → fix → verify pipeline resumes)

---

### SPEC-02: Proactive Navigation Mode (Mode Tuntun)

**Priority:** P0 — Core Feature

**Description:**  
Continuously streams camera frames to the self-hosted backend. YOLOv8 (self-hosted, downloaded weights) infers detections server-side. Distance is estimated via the Similar Triangle method. A 3-zone filter prevents alert flooding.

**Distance Estimation — ZoeDepth:**  
Guidio menggunakan ZoeDepth (monocular depth estimation) untuk memperkirakan jarak objek, menggantikan metode Similar Triangle yang bergantung pada focal length dan ukuran objek yang diketahui. ZoeDepth menghasilkan depth map per-pixel dari gambar tunggal — nilai depth pada titik tengah bounding box YOLO diambil sebagai estimasi jarak objek tersebut.

```
YOLO output     → bounding box objek (x, y, w, h)
ZoeDepth output → depth map seluruh frame (meter per pixel)
Guidio          → depth[center_y][center_x] = estimasi jarak objek
```

> ZoeDepth tidak memerlukan spesifikasi kamera pengguna — ia belajar langsung dari data visual.

**3-Zone Alert Filter:**

| Zone | Distance | Alert Behavior | Example Output |
|------|----------|---------------|----------------|
| Zone 1 — Critical | 0.5 – 2 m | Specific, detailed | `"Ada orang 1 meter di depan kanan"` |
| Zone 2 — Awareness | 2 – 4 m | General awareness | `"Ada orang agak jauh di kanan"` |
| Zone 3 — Ignore | > 4 m | Suppressed | *(silent)* |

**Supported Object Classes (v1):**
- `person`, `car`, `motorcycle`, `bicycle`, `dog`
- `stairs_up`, `stairs_down`, `door`, `pole`, `hole`, `puddle`
- `curb`, `speed_bump`, `construction_barrier`

**Streaming Parameters:**

| Parameter | Value |
|-----------|-------|
| Server YOLO inference target | < 300ms round-trip |
| Frame upload rate | Adaptive: 5–15 fps (network-dependent) |
| Minimum detection confidence | 0.60 |
| Same-object alert cooldown | 3 seconds |
| Max audio queue depth | 2 messages |

**Acceptance Criteria:**
- [ ] Zone 1 alert plays within 400ms of obstacle entering frame
- [ ] Same object class not re-alerted within 3-second cooldown
- [ ] Audio queue enforced at 2-item max; oldest dropped if exceeded
- [ ] Frame streaming degrades gracefully on poor network (frequency reduced, not stopped)

---

### SPEC-03: Maps Integration & Audio Priority Mixer

**Priority:** P1 — Navigation Feature

**Description:**  
Combines Google Maps turn-by-turn directions with real-time YOLO obstacle alerts. The **Audio Priority Mixer** ensures navigation audio and obstacle alerts never conflict or overlap.

**Audio Priority Rules:**

| Rule | Description |
|------|-------------|
| **P0 Interrupt** | YOLO obstacle alert always preempts Maps guidance immediately |
| **Silence Rule** | Same object class not repeated within 3-second window |
| **Queue Limit** | Maximum 2 messages in audio queue at any time |
| **No Overlap** | Maps and YOLO audio never play simultaneously |
| **Resume** | Maps guidance resumes 1 second after YOLO alert finishes |

**Navigation Flow:**
1. User speaks destination → Gemini STT → text sent to backend
2. Backend self-hosted LLM parses `navigate` intent → calls Google Maps Directions API
3. Route waypoints returned to mobile client
4. Turn-by-turn instructions enter audio queue at P1 priority
5. YOLO alerts enter at P0 (preemptive interrupt)

**Acceptance Criteria:**
- [ ] YOLO alert interrupts Maps guidance in < 100ms
- [ ] Maps resumes from correct waypoint after interrupt
- [ ] Full destination-to-navigation flow operable by voice only (no screen touch required)
- [ ] Audio queue enforced at 2-item max in all edge cases

---

### SPEC-04: Voice Assistant & OCR Service

**Priority:** P1 — Core Feature

**Description:**  
Voice input converted to text via **Gemini STT**. Self-hosted LLM (Ollama + LangChain) routes intent. RAG (ChromaDB + local embeddings) provides contextual knowledge for navigation queries. All AI runs on the self-hosted server.

**Intent Routing Table:**

| Intent | Example Trigger | Action |
|--------|----------------|--------|
| `navigate` | "Antar saya ke Indomaret" | → SPEC-03 Navigation flow |
| `read_text` | "Baca tulisan ini" | → OCR pipeline |
| `describe_scene` | "Apa yang ada di depan saya?" | → YOLO labels + LLM description |
| `identify_object` | "Ini benda apa?" | → YOLO + LLM label |
| `rag_query` | "Di sini biasanya aman gak?" | → RAG retrieval + LLM response |
| `general_query` | "Jam berapa sekarang?" | → LLM direct response |
| `save_location` | "Simpan lokasi ini sebagai rumah" | → PostgreSQL write |

**OCR Pipeline:**
```
User: "Baca tulisan ini"
  → Gemini STT converts voice to text
  → Intent classified as `read_text`
  → Camera Health check (SPEC-01)
  → Capture high-res snapshot (1080p)
  → OpenCV pre-processes image (deskew, denoise, binarize, contrast enhance)
  → OpenOCR extracts text (primary, high accuracy for scene text)
  → Google ML Kit validates / fallback if OpenOCR confidence low
  → GPT-4 formats raw text into natural Bahasa Indonesia sentence
  → Gemini TTS reads result aloud
```

**LLM Configuration (GPT-4 via OpenAI API):**

| Parameter | Value |
|-----------|-------|
| Model | `gpt-4` / `gpt-4o` |
| Orchestration | LangChain 0.2+ |
| Memory | `ConversationBufferWindowMemory(k=10)` |
| Tools | navigate, describe_scene, read_text, save_location, rag_query |
| System prompt | `"Kamu adalah asisten navigasi untuk tunanetra. Jawab singkat, jelas, dan natural dalam Bahasa Indonesia."` |

**RAG Configuration (Self-Hosted):**

| Parameter | Value |
|-----------|-------|
| Vector Store | ChromaDB (self-hosted) |
| Embedding Model | Local embedding model (e.g. `nomic-embed-text` via Ollama) |
| Knowledge Base | Navigation tips, hazard descriptions, location context |
| Retrieval strategy | Top-3 chunks, cosine similarity |

**Acceptance Criteria:**
- [ ] Gemini STT latency < 1.5s for commands under 10 words
- [ ] Intent correctly classified > 90% on test set
- [ ] OCR result returned and spoken aloud within 5s of command
- [ ] All LLM responses in Bahasa Indonesia
- [ ] RAG retrieval supplements LLM for location-context queries
- [ ] Conversation context maintained across 10 most recent turns

---

### SPEC-05: Risk Zone Learning

**Priority:** P2 — Enhancement Feature

**Description:**  
Builds a geospatial hazard heatmap from accumulated YOLO detection events. When a user enters a high-risk coordinate cluster, a supplementary contextual warning is prepended to navigation audio.

**Risk Score Formula:**
```
risk_score(zone) = Σ (detection_events × recency_weight) / total_passes

recency_weight: < 7 days = 1.0 | 7–30 days = 0.75 | > 30 days = 0.5
```

**Alert Thresholds:**

| Score | Classification | Voice Output |
|-------|---------------|-------------|
| 0.0 – 0.3 | Safe | *(no additional alert)* |
| 0.3 – 0.6 | Caution | `"Area ini kadang ada hambatan"` |
| 0.6 – 1.0 | High Risk | `"Area ini sering ada hambatan, harap hati-hati"` |

**Key Rules:**
- Risk zone alert is **supplementary** — live YOLO detection (SPEC-02) always takes absolute precedence
- All zone data stored fully anonymized (no individual GPS history retained)
- Zones computed via `ST_ClusterKMeans` in PostGIS
- Risk zone alert never delays or replaces any live obstacle alert

**Acceptance Criteria:**
- [ ] Warning triggers on zone boundary entry (not just centroid)
- [ ] All risk data anonymized before database write
- [ ] Zone scores recompute within 24h of new detection events
- [ ] Risk alert does not block or delay any P0 YOLO alert

---

## 📡 API Contract

### Base URL
```
Self-Hosted:  http://<your-server-ip>:8000/v1
Development:  http://localhost:8000/v1
```

### Authentication
```
Authorization: Bearer <JWT_TOKEN>
```

---

### `WS /stream/detect`
Real-time frame streaming for object detection.

**Client → Server:**
```json
{
  "frame": "<base64_encoded_jpeg>",
  "timestamp": 1700000000000,
  "gps": { "lat": -7.2575, "lng": 112.7521 },
  "device_id": "uuid"
}
```

**Server → Client:**
```json
{
  "detections": [
    {
      "label": "person",
      "confidence": 0.87,
      "distance_m": 1.4,
      "direction": "front-right",
      "zone": 1
    }
  ],
  "alert_text": "Ada orang 1 meter di depan kanan",
  "risk_zone": { "active": false, "score": 0.2 }
}
```

---

### `POST /ocr`
Extract and format text from an image snapshot.

**Request:**
```json
{
  "image": "<base64_encoded_jpeg>",
  "language": "id"
}
```

**Response:**
```json
{
  "raw_text": "BUKA 08:00 - 22:00",
  "formatted": "Toko ini buka dari jam 8 pagi sampai jam 10 malam.",
  "confidence": 0.94
}
```

---

### `POST /assistant/message`
Send voice command text for LLM intent routing.

**Request:**
```json
{
  "text": "Antar saya ke Indomaret terdekat",
  "context": { "lat": -7.2575, "lng": 112.7521 },
  "session_id": "uuid"
}
```

**Response:**
```json
{
  "intent": "navigate",
  "response_text": "Mencari Indomaret terdekat dari lokasi Anda.",
  "action": {
    "type": "navigate",
    "destination": "Indomaret Keputih",
    "destination_coords": { "lat": -7.2601, "lng": 112.7548 }
  }
}
```

---

### `POST /risk-zones/report`
Report a detected hazard at a GPS coordinate (called automatically by the detection pipeline).

**Request:**
```json
{
  "lat": -7.2575,
  "lng": 112.7521,
  "hazard_type": "hole",
  "confidence": 0.82
}
```

---

## 🗄 Data Models

### `users`
```sql
CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  preferences  JSONB DEFAULT '{}',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

### `navigation_events`
```sql
CREATE TABLE navigation_events (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES users(id),
  location     GEOGRAPHY(POINT, 4326),
  hazard_type  VARCHAR(64),
  confidence   FLOAT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON navigation_events USING GIST (location);
```

### `risk_zones`
```sql
CREATE TABLE risk_zones (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  boundary    GEOGRAPHY(POLYGON, 4326),
  risk_score  FLOAT CHECK (risk_score BETWEEN 0.0 AND 1.0),
  event_count INTEGER DEFAULT 0,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON risk_zones USING GIST (boundary);
```

### `saved_locations`
```sql
CREATE TABLE saved_locations (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES users(id),
  name       VARCHAR(128),
  location   GEOGRAPHY(POINT, 4326),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## ⚙️ System Requirements

### Mobile Device (Minimum)

| Component | Minimum Spec | Reason |
|-----------|-------------|--------|
| OS | Android 10 (API 29) | Full TalkBack + Camera2 API support |
| CPU | Snapdragon 665 / Helio G85 | Flutter + Gemini STT/TTS concurrent |
| RAM | 3 GB | App + audio/video streaming + OS overhead |
| Camera | 8 MP, 30 fps stable | Consistent frame quality for detection |
| GPS | GPS + GLONASS | Accurate geospatial + risk zone features |
| Network | 4G LTE minimum | Frame streaming to self-hosted server |
| Battery | 3000 mAh | Camera + GPS + network = high drain |

### Server (Self-Hosted / VPS)

| Node | Minimum Spec | Notes |
|------|-------------|-------|
| API + LLM | 8-core CPU, 16 GB RAM | FastAPI + Ollama LLM inference |
| Vision Processing | NVIDIA GPU (T4 recommended) or 16-core CPU | YOLO + OpenCV inference |
| Storage | 100 GB SSD | OS + YOLO weights + LLM model weights + DB |
| Database | 8 GB RAM, 50 GB SSD | PostgreSQL + PostGIS + ChromaDB |
| Cache & Queue | 4 GB RAM | Redis + Celery |

> **Model storage estimate:**  
> YOLOv8m weights ≈ 50 MB · BLIP base ≈ 990 MB · ZoeDepth ≈ 400 MB · OpenOCR ≈ 200 MB · nomic-embed-text ≈ 270 MB  
> **Total: ~2 GB model storage** (SSD recommended)

---

## 🔄 Development Workflow (Agile/Scrum)

```
Product Backlog → Sprint Planning → Development → Daily Scrum → Sprint Review → Retrospective
                                        ↑_____________________________________|
```

**Definition of Done (DoD):**
- [ ] Feature matches spec acceptance criteria 100%
- [ ] Unit tests written and passing
- [ ] API contract tested via Postman / pytest
- [ ] Tested on physical Android device (not emulator only)
- [ ] Voice output validated in Bahasa Indonesia
- [ ] No regressions on previously completed specs

---

## 🗓 Sprint Roadmap

| Sprint | Duration | Goal | Specs Covered |
|--------|---------|------|--------------|
| **Sprint 1** | 2 weeks | Backend foundation + auth | FastAPI, PostgreSQL+PostGIS, Redis, Firebase Auth, Docker |
| **Sprint 2** | 2 weeks | Self-hosted vision models + RAG | Download & serve BLIP, ZoeDepth, OpenOCR; ChromaDB + RAG pipeline; Gemini STT/TTS |
| **Sprint 3** | 2 weeks | Vision pipeline | SPEC-01 (Camera Health), SPEC-02 (YOLO + OpenCV) |
| **Sprint 4** | 2 weeks | Voice assistant + OCR | SPEC-04 (GPT-4 intent routing, OpenOCR + ML Kit, RAG integration) |
| **Sprint 5** | 2 weeks | Maps + Audio Mixer | SPEC-03 (Google Maps, Audio Priority Mixer) |
| **Sprint 6** | 2 weeks | Risk zones + polish | SPEC-05 (Risk Zone Learning, PostGIS clustering) |
| **Sprint 7** | 1 week | UAT + accessibility audit | End-to-end test with visually impaired users |

---

## 🚀 Environment Setup

### Prerequisites
- Flutter 3.19+ (`flutter doctor` all green)
- Python 3.11+
- Docker & Docker Compose
- [Ollama](https://ollama.ai) installed on server
- Android device (physical, API 29+)

### 1. Clone Repository
```bash
git clone https://github.com/your-org/guidio.git
cd guidio
```

### 2. Download AI Models (Server)
```bash
# Download YOLO weights
wget -O backend/models/yolov8m.pt \
  https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8m.pt

# Download BLIP (via Python / huggingface)
python -c "from transformers import BlipProcessor, BlipForConditionalGeneration; \
  BlipProcessor.from_pretrained('Salesforce/blip-image-captioning-base', cache_dir='backend/models/blip'); \
  BlipForConditionalGeneration.from_pretrained('Salesforce/blip-image-captioning-base', cache_dir='backend/models/blip')"

# Download ZoeDepth (via torch hub)
python -c "import torch; torch.hub.load('isl-org/ZoeDepth', 'ZoeD_NK', pretrained=True)"

# Download OpenOCR weights
# See: https://github.com/Topdu/OpenOCR — follow model download instructions

# Pull local embedding model (for RAG)
ollama pull nomic-embed-text
```

### 3. Backend Setup
```bash
cd backend
cp .env.example .env
# Fill in required variables (see table below)

docker-compose up -d
# Starts: FastAPI, PostgreSQL+PostGIS, Redis, ChromaDB
```

### 4. Database Migration
```bash
docker exec -it guidio_api alembic upgrade head
```

### 5. Flutter (Mobile) Setup
```bash
cd mobile
cp .env.example .env
# Fill in: API_BASE_URL, GEMINI_API_KEY, GOOGLE_MAPS_SDK_KEY

flutter pub get
flutter run --release
```

### Environment Variables

| Variable | Location | Description |
|----------|---------|-------------|
| `GEMINI_API_KEY` | Mobile + Backend `.env` | Gemini API for STT / TTS |
| `OPENAI_API_KEY` | Backend `.env` | GPT-4 API key (OpenAI) |
| `GOOGLE_MAPS_API_KEY` | Backend `.env` | Google Maps Directions API |
| `GOOGLE_MAPS_SDK_KEY` | Mobile `.env` | Maps SDK for Flutter |
| `DATABASE_URL` | Backend `.env` | PostgreSQL connection string |
| `REDIS_URL` | Backend `.env` | Redis connection string |
| `CHROMA_HOST` | Backend `.env` | ChromaDB host (default: `localhost:8001`) |
| `OLLAMA_BASE_URL` | Backend `.env` | Ollama server URL (for RAG embeddings only) |
| `EMBED_MODEL` | Backend `.env` | Embedding model name (e.g. `nomic-embed-text`) |
| `YOLO_MODEL_PATH` | Backend `.env` | Path to downloaded YOLOv8 `.pt` weights |
| `BLIP_MODEL_PATH` | Backend `.env` | Path to downloaded BLIP model directory |
| `ZOEDEPTH_MODEL` | Backend `.env` | ZoeDepth model variant (e.g. `ZoeD_NK`) |
| `OPENOCR_MODEL_PATH` | Backend `.env` | Path to OpenOCR model weights |
| `FIREBASE_CREDENTIALS` | Backend `.env` | Path to Firebase service account JSON |
| `JWT_SECRET` | Backend `.env` | JWT signing secret |

---

## 🧪 Testing Strategy

### Unit Tests
- Backend: `pytest` — YOLO inference, OCR pipeline, LLM intent routing, RAG retrieval in isolation
- Mobile: `flutter test` — audio queue logic, camera health check validators

### Integration Tests
- WebSocket frame streaming: simulate 10 concurrent users
- Audio Priority Mixer: verify P0 YOLO interrupt with recorded sequences
- RAG retrieval: verify top-3 chunks returned for navigation queries

### Performance Benchmarks

| Metric | Target | Method |
|--------|--------|--------|
| Camera health check | < 50ms | Unit test timer |
| YOLO server inference | < 150ms | Server-side benchmark |
| ZoeDepth inference | < 200ms | Server-side benchmark |
| BLIP captioning | < 500ms | Server-side benchmark |
| Full detection round-trip (YOLO + ZoeDepth + BLIP) | < 400ms | WebSocket timestamp delta |
| Gemini STT conversion | < 1.5s | End-to-end timer |
| OCR full pipeline (OpenOCR + GPT-4 format) | < 5s | End-to-end timer |
| GPT-4 intent response | < 2s | API response timer |
| RAG retrieval | < 500ms | ChromaDB query timer |
| Audio alert latency (Zone 1) | < 400ms | Physical device stopwatch |

### Accessibility Testing
- All features operable **without looking at the screen**
- Tested with Android TalkBack enabled
- Validated with at least one visually impaired user per sprint review

---

> *"Guidio doesn't just react to obstacles — it helps users anticipate them."*