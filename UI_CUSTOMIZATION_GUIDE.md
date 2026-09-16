# คู่มือการปรับแต่งหน้าตาโปรแกรม (UI Customization Guide - RustDesk Flutter)

คู่มือนี้จัดทำขึ้นเพื่อให้ทีมพัฒนา UI (Flutter Developer) สามารถเข้าปรับแต่งหน้าตา ดีไซน์ สี โลโก้ และเลย์เอาต์ของโปรแกรม RustDesk Client ได้อย่างสะดวก ก่อนส่งขึ้นไปคอมไพล์เป็นไฟล์ `.exe` ผ่าน GitHub Actions

---

## 1. ข้อมูลสำคัญของระบบ (Pre-configured Core)
ในส่วนของ Core Engine (ภาษา Rust) ระบบเชื่อมต่อกับ Self-Hosted Server และ Public Key จะถูกฝังอัตโนมัติในกระบวนการ Build ผ่าน **GitHub Secrets**:
- **ID / Rendezvous Server**: กำหนดผ่าน Secret `CUSTOM_SERVER`
- **Relay Server**: กำหนดผ่าน Secret `CUSTOM_SERVER`
- **Public Key**: กำหนดผ่าน Secret `CUSTOM_KEY`
*(ทีม UI ไม่จำเป็นต้องแก้โค้ดภาษา Rust หรือกังวลเรื่องการเชื่อมต่อระบบ Server)*

---

## 2. แผนผังและตำแหน่งไฟล์สำหรับทีม UI

โค้ดสำหรับหน้าตาโปรแกรมทั้งหมดอยู่ในโฟลเดอร์ **`flutter/`**

```
flutter/
├── assets/                               # รูปภาพ, โลโก้, ไอคอนเวกเตอร์
│   ├── logo.png                          # โลโก้หลักของโปรแกรม
│   ├── logo_light.png                    # โลโก้สำหรับธีมสว่าง
│   └── logo_dark.png                     # โลโก้สำหรับธีมมืด
├── lib/
│   ├── main.dart                         # จุดเริ่มต้นของแอปพลิเคชัน
│   ├── common.dart                       # ธีมหลัก (Colors, Styles, ThemeProvider)
│   ├── desktop/
│   │   ├── pages/
│   │   │   ├── desktop_home_page.dart    # [สำคัญ] หน้าหลักของโปรแกรม (Home Screen)
│   │   │   ├── desktop_setting_page.dart # [สำคัญ] หน้าการตั้งค่า (Settings Screen)
│   │   │   └── desktop_tab_page.dart     # แท็บด้านบนของโปรแกรม
│   │   └── widgets/                      # ปุ่ม, กล่องข้อความ, การ์ดต่างๆ
├── windows/
│   └── runner/
│       ├── resources/
│       │   └── app_icon.ico              # ไอคอนของโปรแกรมบน Windows (.ico)
│       └── Runner.rc                     # ข้อมูล Metadata, ชื่อโปรแกรมบน Windows
└── pubspec.yaml                          # รายการ Dependency และ Assets
```

---

## 3. จุดสำคัญที่แนะนำให้ปรับแต่ง

### 3.1 หน้าจอหลัก (Home Screen)
📁 **ไฟล์:** `flutter/lib/desktop/pages/desktop_home_page.dart`
- **ฝั่งซ้าย (`buildLeftPane`)**: แสดง ID เครื่องของลูกค้า, One-time Password, สถานะ Service
  - สามารถเพิ่มโลโก้บริษัท, เบอร์โทรฝ่าย Support หรือข้อความแนะนำการใช้งานได้ที่นี่
- **ฝั่งขวา (`buildRightPane`)**: กล่องสำหรับกรอก ID เพื่อเชื่อมต่อไปยังเครื่องอื่น
  - สำหรับตัว Client ของลูกค้า ถ้าต้องการให้ทำหน้าที่เป็น **"ผู้รอรับการซัพพอร์ตอย่างเดียว"** (ห้ามแอบกดรีโมทไปหาใคร) สามารถซ่อนฝั่งขวาออกได้ที่บรรทัด `67-68` โดยใช้เงื่อนไขหรือคอมเมนต์ออกได้เลย

### 3.2 หน้าต่างการตั้งค่า (Settings Screen)
📁 **ไฟล์:** `flutter/lib/desktop/pages/desktop_setting_page.dart`
- ที่ตัวแปร `tabKeys` (ประมาณบรรทัด 63–81):
  ```dart
  static final List<SettingsTabKey> tabKeys = [
    SettingsTabKey.general,
    // SettingsTabKey.safety,   // หากต้องการซ่อนแท็บความปลอดภัย
    // SettingsTabKey.network,  // ซ่อนแท็บ Network เพื่อไม่ให้ลูกค้าแก้ Server
    SettingsTabKey.display,
    SettingsTabKey.about,
  ];
  ```
  - สามารถลบหรือคอมเมนต์ `SettingsTabKey.network` ออกเพื่อป้องกันไม่ให้ลูกค้าเข้าไปดูหรือแก้ไข Server IP ได้ 100%

### 3.3 สีและธีม (Colors & Themes)
📁 **ไฟล์:** `flutter/lib/common.dart`
- ค้นหาคลาส `MyTheme`:
  - `MyTheme.accent`: สีเน้นหลักของโปรแกรม (ปรับตาม Brand Color ของคุณ)
  - `MyTheme.darkTheme` / `MyTheme.lightTheme`: กำหนดรูปแบบธีมของแอป

### 3.4 โลโก้และไอคอนโปรแกรม
- **โลโก้ในแอป**: นำภาพโลโก้ของคุณมาวางทับไฟล์ใน `flutter/assets/logo.png`
- **ไอคอนไฟล์ `.exe`**: นำไฟล์ไอคอน `.ico` มาวางทับที่ `flutter/windows/runner/resources/app_icon.ico`

---

## 4. วิธีการรันพรีวิว UI ในเครื่อง Local (สำหรับทีม UI)

หากทีม UI ติดตั้ง Flutter SDK ไว้แล้วในเครื่อง สามารถทดสอบดูหน้าตาได้ง่ายๆ:
1. เปิด Terminal ในโฟลเดอร์ `flutter/`
2. ดึง Library:
   ```bash
   flutter pub get
   ```
3. สั่งรันบน Windows:
   ```bash
   flutter run -d windows
   ```
*(หรือออกแบบผ่าน Hot Reload ได้ตามปกติ)*

---

## 5. วิธีการสั่ง Build เป็นไฟล์ `.exe` (เมื่อทีม UI ทำเสร็จแล้ว)

เมื่อทีม UI ทำการปรับแต่งหน้าตาเสร็จและ Commit + Push ขึ้น GitHub แล้ว:
1. เข้าไปที่ Repository บน GitHub ของคุณ
2. ไปที่แท็บ **Actions** ด้านบน
3. เลือก Workflow **Flutter Nightly Build** (หรือเมนูที่มีปุ่ม **Run workflow**)
4. กดปุ่ม **Run workflow**
5. รอระบบ GitHub Cloud ทำการคอมไพล์ประมาณ 15–20 นาที
6. เมื่อเสร็จแล้ว เลื่อนลงไปดูที่หัวข้อ **Artifacts** จะพบไฟล์:
   - **`rustdesk-client-x86_64`**
7. ดาวน์โหลดและแตกไฟล์ออกมา จะได้ไฟล์ `.exe` ตัวโปรแกรมที่ตกแต่งหน้าตาและฝัง Server ถาวรเรียบร้อยแล้ว
8. นำไฟล์ `.exe` นี้ไปใส่แทน `rustdesk-setup.exe` ในโฟลเดอร์ตัวติดตั้ง และรัน Inno Setup ได้ทันที!
