# puzzle_dot 프로젝트 세팅 문서

Flutter + Chaquopy(Python) + OpenCV Android 앱 세팅 정리.

---

## 아키텍처

```
Flutter (Dart) → MethodChannel → Kotlin (Android) → Chaquopy → Python (cv2)
```

---

## 환경 버전

| 항목 | 버전 |
|------|------|
| Flutter | ^3.x (Dart SDK ^3.8.1) |
| Android compileSdk | 35 |
| Android minSdk | 26 |
| Android targetSdk | 34 |
| Android NDK | 27.0.12077973 |
| Kotlin | 2.1.0 |
| Android Gradle Plugin | 8.7.3 |
| Chaquopy | 16.0.0 |
| **Python** | **3.8** ← 반드시 3.8이어야 함 |
| opencv-python | 4.5.1.48 (Chaquopy 미러 버전) |
| numpy | 1.19.5 (Chaquopy 미러 버전) |

---

## 중요 주의사항: Python 버전은 반드시 3.8

Chaquopy Android 패키지 미러(`chaquo.com/pypi-13.1`)에 opencv-python이
**Python 3.8용만 존재**함. 3.9 이상으로 설정하면 Windows용 wheel이
빌드되어 Android에서 실행 시 크래시 발생.

---

## Flutter 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  image_picker: ^1.0.7       # 이미지 선택
  path_provider: ^2.1.2      # 임시 파일 경로
  permission_handler: ^11.3.0 # 권한 처리
```

---

## Android Gradle 설정

### settings.gradle.kts

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://chaquo.com/maven") }  // Chaquopy 저장소
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    // com.chaquo.python은 여기서 선언하지 않음 (build.gradle.kts buildscript로 처리)
}
```

### build.gradle.kts (루트)

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://chaquo.com/maven") }
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("com.chaquo.python:gradle:16.0.0")  // Chaquopy 플러그인
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://chaquo.com/maven") }
    }
}
```

### app/build.gradle.kts

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.chaquo.python")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        minSdk = 26
        targetSdk = 34

        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }
}

chaquopy {
    defaultConfig {
        version = "3.8"   // 반드시 3.8
        pip {
            install("opencv-python")
            install("numpy")
        }
    }
}
```

---

## MethodChannel 구조

채널 이름: `com.example.puzzle_dot/python`

| 메서드 | 인자 | 반환 |
|--------|------|------|
| `processImage` | `imagePath: String` | JSON `{"circles": [{x, y, radius}, ...]}` |
| `getImageInfo` | `imagePath: String` | JSON `{"width", "height", "channels"}` |

---

## 파일 구조

```
android/
  app/src/main/
    kotlin/com/example/puzzle_dot/MainActivity.kt  # MethodChannel → Python 호출
    python/image_processor.py                       # Python cv2 처리 코드
  build.gradle.kts                                  # Chaquopy, compileSdk, NDK 설정
build.gradle.kts (루트)                             # Chaquopy classpath 선언
settings.gradle.kts                                 # 플러그인 저장소 설정

lib/
  main.dart                                         # 테스트 UI
  services/python_bridge.dart                       # Flutter MethodChannel 브릿지
```

---

## 트러블슈팅

### `ImportError: OpenCV loader: missing configuration file ['config.py']`
→ Python 버전이 3.8이 아닌 경우. `app/build.gradle.kts`의 `version = "3.8"` 확인.

### `Failed to find plugin com.android.tools.build:gradle`
→ 루트 `build.gradle.kts`에 `buildscript { classpath("com.android.tools.build:gradle:...") }` 블록 누락.

### `Failed to find plugin com.chaquo.python:gradle`
→ 루트 `build.gradle.kts`에 `classpath("com.chaquo.python:gradle:16.0.0")` 누락.

### `compileSdk` 관련 빌드 에러
→ `compileSdk = 35`, `ndkVersion = "27.0.12077973"` 로 설정.
