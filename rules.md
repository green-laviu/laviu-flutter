# Flutter 프로젝트 개발 규칙 (`rules.md`)

## 1. Git 관리 규칙

### 1.1 브랜치 전략

- `main`: 운영 배포용 브랜치
- `dev`: 통합 개발 브랜치
- 기능 개발은 `dev`에서 분기한 **topic 브랜치**에서 수행
- PR 머지는 반드시 **Squash and Merge** 방식 사용

### 1.2 브랜치 명명 규칙

- 기능 수정 또는 오류 수정: `fix/`
- UI 작업: `ui/`
- 형식: `도메인/기능` 또는 `도메인/상세페이지`
  - 예시: `board/write`, `fix/ui/user/update`

### 1.3 커밋 메시지

- 커밋 메시지는 **한국어로 간결하고 명확하게 작성**
- 필요 시 특정 용어만 영어 사용 가능
- 의미 없는 메시지는 금지

---

## 2. 코드 작성 및 스타일 규칙

### 2.1 메서드명 규칙

| 동작 | 접두사 |
|------|--------|
| 조회 | `get` |
| 등록 | `write` |
| 수정 | `update` |
| 삭제 | `delete` |
| 단일 항목 | `One` |
| 전체 항목 | `All` |
| 목록 | `List` |

> 예: `getOne`, `getList`, `deleteAll`

### 2.2 파일 및 클래스명

- **파일명**: `snake_case.dart`
- **클래스명**: `PascalCase`
- 중복 가능성 있는 경우 도메인명 접두어 추가

> 예: `visit_record_detail_body.dart` → `VisitRecordDetailBody`

### 2.3 모델 필드명

- **형식**: `camelCase`
- 공통 필드에는 **모델명 접두어** 사용 (예: `userId` → `replyUserId`)
- 날짜 관련:
  - 날짜만: `birthDate`
  - 날짜+시간: `createdAt`
  - 상대 시간: `relativeTime`
- 복수형 필드명은 반드시 `~s` 사용 (예: `imgs`)
- 리스트 구조의 필드명은 `~List` 사용

### 2.4 이미지 처리 방식

- 클라이언트 → 서버: `base64` 문자열 전송
- 서버 → 클라이언트: 이미지 `URL` 전달

---

## 3. 정적 리소스 관리 (assets)

### 3.1 디렉토리 구조

```
assets/
├── images/
├── videos/
```

- `pubspec.yaml`에 하위 폴더 등록 필요:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/videos/
```

### 3.2 파일명 규칙

- `snake_case` 사용
- 의미 있는 이름 지정 (예: `team_logo_lg.png`, `background_night.jpg`)

---

## 4. 페이지 구조 및 개발용 버튼

### 4.1 페이지 구성 파일

- 전체 화면 담당: `*_page.dart`
- body 분리: `*_body.dart`

### 4.2 개발용 floatingActionButton (`MDevFloatingBtn`)

```dart
floatingActionButton: MDevFloatingBtn(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  },
)
```

> 개발 중 특정 페이지로 빠르게 이동하거나 테스트할 때 사용  
> 내부적으로 `isDevMode`를 통해 운영 환경에서는 자동 숨김 처리

---

## 5. 폴더 구조 및 네이밍 규칙

| 항목 | 규칙 | 예시 |
|------|------|------|
| ViewModel | `*_vm.dart` | `live_stream_vm.dart` |
| 공통 위젯 | `m_위젯명.dart` | `m_text_btn.dart` |
| 페이지 전용 위젯 | `페이지명_위젯명.dart` | `user_detail_body.dart` |
| 스타일 / 유틸 | `m_파일명.dart` | `m_colors.dart`, `m_text.dart` |

### 5.1 model 폴더 사용 기준

- **단순 조회용 모델**: ViewModel 내부에서 상태 없이 사용하는 구조
  - 예: 승부 예측, 상대 전적, 우천 취소 예측 등

- **상태 변화 필요 모델**: `model` 정의 + ViewModel과 함께 상태 관리
  - 예: 게시글 작성/수정, 유저 정보 변경 등

---

## 6. 테스트 코드 작성 규칙

- `lib/` 내부 구조와 동일하게 유지
- 테스트 파일명: 기존 파일명에 `_test` 접미사 추가

```
test/
└── ui/
    └── mypage/
        └── user/
            └── user_update_page_test.dart
```

---

## 7. 코드 작성 위치 규칙

- 기존 파일 내에서는 항상 **맨 아래에 코드 추가**
- 중간 삽입은 금지 → merge 충돌 최소화를 위해