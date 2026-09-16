# RustDesk UI Customization Guide — Solutionbizsoft Client

> **สำหรับ Agent**: อ่านไฟล์นี้ก่อนแก้ไข UI เสมอ เพื่อไม่ให้ทำซ้ำหรือขัดกับงานที่ทำไปแล้ว
>
> **เป้าหมาย**: สร้าง Client สำหรับฝั่งลูกค้า (Incoming-Only) ที่แสดงเฉพาะ ID + One-time Password
> ลูกค้าแค่ถ่ายรูปส่งให้ช่างเข้าไป Remote ได้ทันที โดยไม่ต้องกดอะไร

---

## 📁 โครงสร้างไฟล์ที่สำคัญ

### Flutter UI (Dart)

| ไฟล์ | หน้าที่ | ปรับแต่ง |
|------|---------|----------|
| [`desktop_home_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_home_page.dart) | **หน้าหลัก** — แสดง Logo, ID, Password, Online Status | ✅ แก้แล้ว |
| [`desktop_tab_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_tab_page.dart) | **Tab Container** — ควบคุมขนาดหน้าต่าง, แถบ Tab, ปุ่ม Settings | ✅ แก้แล้ว |
| [`desktop_setting_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_setting_page.dart) | **หน้าตั้งค่า** — Tab ต่างๆ (General, Safety, Network, ...) | ✅ แก้แล้ว |
| [`connection_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/connection_page.dart) | **Right Pane** — ช่อง Remote ID + Peer list (ซ่อนเพราะ Incoming-Only) | ❌ ไม่ต้องแก้ |
| [`server_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/server_page.dart) | **Connection Manager** — หน้าต่าง Accept/Reject เมื่อมีคนเชื่อมต่อ | ✅ แก้แล้ว |
| [`common.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/common.dart) | **Theme & Utils** — สี, ขนาดหน้าต่าง, ฟังก์ชันทั่วไป | ✅ แก้แล้ว |
| [`remote_toolbar.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/widgets/remote_toolbar.dart) | **Toolbar ขณะ Remote** — เมนูด้านบนตอนควบคุมเครื่อง | ❌ ไม่ต้องแก้ (ฝั่งช่าง) |
| [`server_model.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/models/server_model.dart) | **Server State** — จัดการ ID, Password, Approve Mode | ❌ ไม่ต้องแก้ |

### Assets & Branding

| ไฟล์ | หน้าที่ |
|------|---------|
| [`flutter/assets/logo.png`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/assets/logo.png) | โลโก้หน้า Light Mode |
| [`flutter/assets/logo_dark.png`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/assets/logo_dark.png) | โลโก้หน้า Dark Mode **(ใช้อันนี้)** |
| [`flutter/assets/icon.svg`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/assets/icon.svg) | ไอคอนแอปใน Taskbar |

### Configuration & Installer

| ไฟล์ | หน้าที่ |
|------|---------|
| [`setup-builder-client.iss`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/setup-builder-client.iss) | **Inno Setup** — ตัวติดตั้ง + เขียน `RustDesk2.toml` config |
| [`.github/workflows/flutter-build.yml`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/.github/workflows/flutter-build.yml) | **GitHub Actions** — CI/CD pipeline สำหรับ build |

---

## 🎨 สิ่งที่แก้ไปแล้ว (Current Customizations)

### 1. Theme & Branding — [`common.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/common.dart)

```dart
// Line ~252: เปลี่ยนสี Accent เป็นสีเขียว Solutionbizsoft
static const Color accent = Color(0xFF52B63D); // Solutionbizsoft Green
static const Color accent50 = Color(0x7752B63D);
static const Color accent80 = Color(0xAA52B63D);
static const Color idColor = Color(0xFF52B63D);
static const Color cmIdColor = Color(0xFF52B63D);
```

```dart
// Line ~3685: ขนาดหน้าต่าง Incoming-Only (กะทัดรัด)
var imcomingOnlyHomeSize = Size(340, 400);
```

> **วิธีเปลี่ยนสี**: ค้นหา `0xFF52B63D` ทั้งไฟล์แล้วเปลี่ยนเป็นรหัสสีที่ต้องการ

### 2. หน้าหลัก — [`desktop_home_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_home_page.dart)

**Layout ปัจจุบัน (function `buildLeftPane`, line ~70):**
```
┌─────────────────────────┐
│    Logo (logo_dark.png)  │  ← buildLeftPane → Image.asset()
│    "Your Desktop"        │  ← buildTip()
│    "desk_tip"            │
├─────────────────────────┤
│  ID                      │  ← buildIDBoard()
│  123 456 789    [📋]     │     ปุ่ม Copy ID
├─────────────────────────┤
│  One-time Password       │  ← buildPasswordBoard2()
│  a8X2kP         [🔄]    │     ปุ่ม Refresh (สุ่มใหม่)
├─────────────────────────┤
│  ● Ready / Not Ready     │  ← OnlineStatusWidget
└─────────────────────────┘
```

**สิ่งที่ซ่อน/ลบออกแล้ว:**

| Element | วิธีที่ซ่อน | ตำแหน่ง |
|---------|-------------|---------|
| ข้อความคำแนะนำ (Tip) | ปรับเป็นข้อความแนะนำเฉพาะของ Solutionbizsoft | `buildTip()` line ~360 |
| ปุ่มดินสอ (Edit Password) | ลบโค้ดทั้ง `InkWell` block ออก | `buildPasswordBoard2()` |
| Popup Menu (เมนู 3 จุด) | return `SizedBox.shrink()` | `buildPopupMenu()` line ~227 |
| เงื่อนไข `showOneTime` | ลบออก — แสดง password เสมอ | `buildPasswordBoard2()` |
| password แสดง `-` ในโหมด click | ลบเงื่อนไขออก — ใช้ refresh กดสุ่มแทน | `buildPasswordBoard2()` |

**ปุ่ม Refresh Password (line ~309-348):**
```dart
AnimatedRotationWidget(
  onPressed: () {
    // ถ้าอยู่ในโหมด click → เปลี่ยนเป็นโหมดปกติก่อน
    if (model.approveMode == 'click') {
      model.setApproveMode('');
    }
    // สุ่มรหัสใหม่
    bind.mainUpdateTemporaryPassword();
  },
  // ... UI ของปุ่ม
)
```

> ⚠️ **ห้ามใช้ `async/await`** ใน `onPressed` ของ `AnimatedRotationWidget` — จะทำให้ build fail

### 3. Tab Container — [`desktop_tab_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_tab_page.dart)

```dart
// Line ~55-57: บังคับให้หน้าต่างเป็นขนาด compact เสมอ
windowManager.setSize(getIncomingOnlyHomeSize());
setResizable(false);

// Line ~103-105: ซ่อนปุ่ม Settings icon (ฟันเฟือง) บน Tab bar
tail: const Offstage(
  offstage: true, // Solutionbizsoft: hide settings icon
),
```

> **วิธีเปิดปุ่ม Settings กลับมา**: เปลี่ยน `offstage: true` เป็น `offstage: false`

### 4. หน้าตั้งค่า — [`desktop_setting_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_setting_page.dart)

```dart
// Line ~65-74: ซ่อน Tab ที่ไม่ต้องการ
static final List<SettingsTabKey> tabKeys = [
  if (bind.mainGetBuildinOption(key: kOptionHideGeneralSetting) != 'Y')
    SettingsTabKey.general,
  // SettingsTabKey.safety,   // Hidden: prevent changing access permissions
  // SettingsTabKey.network,  // Hidden: prevent changing server
  // SettingsTabKey.display,  // Hidden: not needed for incoming-only
  // SettingsTabKey.account,  // Hidden: not needed
  // SettingsTabKey.printer,  // Hidden: not needed
  SettingsTabKey.about,
];
```

> **วิธีเปิด Tab กลับมา**: เอา `//` comment ออกจาก Tab ที่ต้องการ

### 5. Connection Manager — [`server_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/server_page.dart)

หน้าต่างที่เด้งขึ้นมาบนหน้าจอของลูกค้าเวลาช่างเชื่อมต่อเข้ามา:

**สิ่งที่ปรับแต่ง:**
1. **ล็อค Permissions ไม่ให้ลูกค้าคลิกปิด (`_PrivilegeBoardState`, line ~663)**:
   - กำหนด `canModifyPermission = false` เพื่อป้องกันไม่ให้ลูกค้าเผลอคลิกปิด Keyboard, Mouse, หรือ Clipboard ของช่าง
   - ปรับสีไอคอนที่เปิดอยู่ให้เป็นสีเขียวทึบ (`MyTheme.accent`) สวยงามชัดเจน
2. **ซ่อนปุ่ม Switch Sides (`buildAuthorized`, line ~1007)**:
   - ตั้ง `offstage: true` ป้องกันลูกค้ากดสลับไปควบคุมเครื่องของช่าง
3. **ซ่อนปุ่ม Voice Call (`buildAuthorized`, line ~888, 974)**:
   - ตั้ง `offstage: true` ทั้งส่วนควบคุมโทรเสียงและสายเรียกเข้า เพื่อไม่ให้รกหน้าต่าง
4. **รวมปุ่ม Accept ให้เหลือปุ่มเดียวที่ได้ Admin อัตโนมัติ (`buildUnAuthorized`, line ~1074)**:
   - ซ่อนปุ่มซ้ำซ้อน "Accept and Elevate"
   - ในปุ่ม "Accept" เมื่อลูกค้ากดรับ จะสั่ง `handleElevate(context)` พ่วงด้วยทันทีหากเครื่องรองรับสิทธิ์ Admin ทำให้ลูกค้าไม่ต้องเลือกระหว่าง 2 ปุ่มให้สับสน

### 6. Installer Config — [`setup-builder-client.iss`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/setup-builder-client.iss)

ค่าสำคัญใน `RustDesk2.toml` ที่ตัวติดตั้งเขียน (line ~61-82):

| Key | ค่า | ผลลัพธ์ |
|-----|-----|---------|
| `approve-mode` | `''` (ว่าง) | รองรับทั้ง Password + กด Accept |
| `hide-security-settings` | `'Y'` | ซ่อนเมนู Security |
| `hide-server-settings` | `'Y'` | ซ่อนเมนู Server |
| `hide-network-settings` | `'Y'` | ซ่อนเมนู Network |
| `hide-proxy-settings` | `'Y'` | ซ่อนเมนู Proxy |
| `hide-stop-service` | `'Y'` | ซ่อนปุ่ม Stop Service |
| `disable-change-id` | `'Y'` | ห้ามเปลี่ยน ID |
| `disable-change-permanent-password` | `'Y'` | ห้ามเปลี่ยนรหัสถาวร |
| `allow-remote-config-modification` | `'Y'` | อนุญาตให้แก้ config จาก Remote |
| `enable-keyboard` | `'Y'` | เปิดใช้ Keyboard |
| `enable-clipboard` | `'Y'` | เปิดใช้ Clipboard |
| `enable-file-transfer` | `'Y'` | เปิด File Transfer |
| `enable-remote-restart` | `'Y'` | เปิด Remote Restart |

---

## 🔧 เทคนิคการซ่อน/แสดง UI ใน RustDesk

### วิธีที่ 1: ลบโค้ดทิ้ง (ถาวร)
```dart
// ลบ Widget ออกจาก children list
// เหมาะกับสิ่งที่ไม่ต้องการกลับมาแน่ๆ
```

### วิธีที่ 2: `Offstage` widget (ซ่อนแต่ยังอยู่)
```dart
Offstage(
  offstage: true,  // true = ซ่อน, false = แสดง
  child: MyWidget(),
)
```

### วิธีที่ 3: `if` condition (ซ่อนตามเงื่อนไข)
```dart
if (!bind.isDisableSettings()) ...[
  // Widget ที่แสดงเฉพาะเมื่อ settings ไม่ถูกปิด
]
```

### วิธีที่ 4: Return `SizedBox.shrink()` (Widget ว่าง)
```dart
Widget buildPopupMenu(BuildContext context) {
  return const SizedBox.shrink(); // ไม่แสดงอะไรเลย
}
```

### วิธีที่ 5: Config flags ผ่าน `RustDesk2.toml`
```toml
# ค่าเหล่านี้ตรวจสอบผ่าน bind.mainGetBuildinOption()
hide-security-settings = 'Y'
hide-server-settings = 'Y'
```
> ใช้ได้กับบาง element ที่ RustDesk สร้าง `if` ไว้ให้แล้ว

---

## 🔑 Bindings & APIs ที่ใช้บ่อย

| Binding | หน้าที่ |
|---------|---------|
| `bind.mainUpdateTemporaryPassword()` | สุ่ม One-time Password ใหม่ |
| `bind.isIncomingOnly()` | ตรวจว่าเป็น Client แบบรับอย่างเดียวไหม |
| `bind.isOutgoingOnly()` | ตรวจว่าเป็น Client แบบส่งอย่างเดียวไหม |
| `bind.isDisableSettings()` | ตรวจว่าปุ่มตั้งค่าถูกปิดไหม |
| `bind.isCustomClient()` | ตรวจว่าเป็น Custom Client ไหม |
| `bind.mainGetBuildinOption(key: ...)` | อ่านค่า builtin option |
| `bind.mainGetOption(key: ...)` | อ่านค่า option จาก config |
| `bind.mainSetOption(key: ..., value: ...)` | เขียนค่า option |
| `model.setApproveMode('...')` | เปลี่ยนโหมด Approve (`''`, `'password'`, `'click'`) |
| `model.serverId` | TextEditingController ของ ID |
| `model.serverPasswd` | TextEditingController ของ Password |
| `model.approveMode` | โหมดอนุมัติปัจจุบัน |

### Approve Modes

| Mode | ชื่อ | พฤติกรรม |
|------|------|----------|
| `''` (ว่าง) | Password + Accept | ใส่ Password ได้ทันที หรือ ลูกค้ากด Accept ก็ได้ |
| `'password'` | Password เท่านั้น | ต้องใส่ Password ถึงจะเข้าได้ (ลูกค้าไม่ต้องกด) |
| `'click'` | Click เท่านั้น | ลูกค้าต้องกด Accept (ไม่มี Password แสดง = `-`) |

> ⚠️ ตัว Client นี้ใช้ `approve-mode = ''` เพื่อให้ช่างใส่ Password เข้าได้ทันที
> แต่ถ้ายังไม่ได้ Password ก็ยังสามารถขอให้ลูกค้ากด Accept ได้

---

## 📐 ขนาดหน้าต่าง

ตั้งค่าใน [`common.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/common.dart) line ~3685:

```dart
var imcomingOnlyHomeSize = Size(340, 400);  // หน้าแรก (compact)

Size getIncomingOnlySettingsSize() {
  return Size(768, 600);  // หน้า Settings (กว้างกว่า)
}
```

ควบคุมการสลับขนาดหน้าต่างใน [`desktop_tab_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/desktop_tab_page.dart):
```dart
tabController.onSelected = (key) {
  if (key == kTabLabelHomePage) {
    windowManager.setSize(getIncomingOnlyHomeSize());
    setResizable(false);
  } else {
    windowManager.setSize(getIncomingOnlySettingsSize());
    setResizable(true);
  }
};
```

---

## 🎯 Comment Markers สำหรับค้นหาจุดที่แก้ไข

ค้นหาด้วย keyword เหล่านี้ในโค้ด:
- `Solutionbizsoft` — marker comment ของเราในโค้ด
- `SBS Custom` — marker comment แบบสั้น
- `// Hidden:` — comment อธิบายว่าทำไมถึงซ่อน

---

## ⚠️ ข้อควรระวังเมื่อแก้ไข

1. **ห้ามใช้ `async/await` ใน `onPressed` callback ของ `AnimatedRotationWidget`**
   - จะทำให้ build fail เพราะ type mismatch
   - ใช้แค่เรียก function ตรงๆ (fire-and-forget)

2. **ระวัง Line Endings (CRLF vs LF)**
   - Git อาจแจ้งเตือน — ไม่ส่งผลต่อ build แต่ให้ระวังไม่สร้าง diff ที่ไม่จำเป็น

3. **ไม่ต้องแก้ Rust Code**
   - UI ทั้งหมดอยู่ใน Flutter (Dart) layer
   - Rust code (ใน `src/`) เป็น core engine ไม่ต้องแตะ

4. **ถ้าจะ build ใหม่**
   - Push ขึ้น GitHub → GitHub Actions build อัตโนมัติ (~40 นาที)
   - ไม่สามารถ build ในเครื่องได้ง่ายๆ (ต้องมี Flutter SDK + Rust toolchain + VCPKG)

5. **ทดสอบ syntax ก่อน push**
   - ตรวจ syntax ด้วยการอ่านโค้ดอย่างละเอียด
   - ดูว่า brackets `{}` จับคู่ครบ
   - ตรวจ trailing commas ใน Widget tree

---

## 📋 Checklist สำหรับการเพิ่ม/ซ่อน Element ใหม่

- [ ] ระบุไฟล์และ function ที่ต้องแก้
- [ ] ตรวจว่ามีค่า config flag ใน RustDesk2.toml ที่ทำได้อยู่แล้วหรือไม่
- [ ] ถ้าซ่อน → ใช้ `Offstage`, `if`, หรือ `SizedBox.shrink()`
- [ ] ถ้าลบ → ลบให้ครบทั้ง Widget tree (ตรวจ brackets)
- [ ] ถ้าเพิ่ม → ดูรูปแบบ Widget ที่มีอยู่แล้วเป็นตัวอย่าง
- [ ] ตรวจ syntax (brackets, commas, async/await)
- [ ] Commit ด้วย message ชัดเจน (prefix: `feat:`, `fix:`, `style:`)
- [ ] Push แล้วรอ GitHub Actions build

---

## 🗂️ หน้าที่ยังไม่ได้แก้ไข (ที่อาจต้องดูในอนาคต)

| หน้า | ไฟล์ | สิ่งที่อาจต้องแก้ |
|------|------|-------------------|
| Remote Page | [`remote_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/desktop/pages/remote_page.dart) | หน้าจอขณะ Remote (ฝั่งช่าง — อาจไม่ต้องแก้) |
| Mobile Home | [`mobile/pages/home_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/mobile/pages/home_page.dart) | หน้าแรกบนมือถือ (ถ้าต้องทำ Android client ด้วย) |
| Mobile Server | [`mobile/pages/server_page.dart`](file:///c:/Users/SBS/Desktop/RustDesk-Customized/rustdesk-source/flutter/lib/mobile/pages/server_page.dart) | หน้า Server บนมือถือ |
