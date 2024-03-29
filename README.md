# 수원 메이트

수원대학교의 개설 강좌 목록이나 학사 일정, 공지사항 등을 볼 수 있는 앱 입니다.  
Google play에 게시된 버전과 달리 광고 자체가 포함되어있지 않은 버전이며, 아직 게시된 버전에 적용되지 않은 변경사항들이 있을 수 있습니다.
대신 안정성이 떨어질 가능성이 높습니다.  
사용해보기에 있는 링크로 들어가시면 웹 버전으로 또는 빌드된 파일로 사용해보실 수 있습니다.  

## 목차
- [수원 메이트](#수원-메이트)
    - [목차](#목차)
    - [분기(브랜치) 소개](#분기-소개)
    - [지원되는 플랫폼](#지원되는-플랫폼)
    - [간단 기능 소개](#간단-기능-소개)
    - [사용해보기](#사용해보기)
        - [사전 빌드된 파일 사용하기](#사전-빌드된-파일-사용하기)
        - [Web 플랫폼에서 사용해보기](#web-플랫폼에서-사용해보기)
    - [앱 테스트 해보기](#앱-테스트-해보기)
    - [앱 사용 도움말](#앱-사용-도움말)
    - [DB안내](#DB안내)
    - [빌드해보기](#빌드해보기)
    - [개발 참고 사항](#개발-참고-사항)
        - [설정 내 디버그 설정 표시하기](#설정-내-디버그-설정-표시하기)
        - [Web버전에서는 왜 일부 기능이 안되나요?](#Web버전에서의-일부-동작-제한-안내)

## 분기 소개
해당 저장소에는 기본적으로 아래 3가지의 브랜치가 존재합니다.(이 외 브랜치는 사라질 수 있음)  
* `main`: 안정적으로 동작하는 브랜치(Google Play에 게시된 버전은 해당 브랜치를 기반으로 합니다.)
* `next`: 가장 최신 기능이 적용된 브랜치. 안정성이 낮을 수 있습니다.
* `legacy`: 이전 버전(v1.x)의 앱 디자인 및 기능을 지원하는 브랜치(대부분 버그 수정만 반영 중)

## 지원되는 플랫폼
현재 확인된 기능 별 지원되는 플랫폼 목록입니다.

| 플랫폼  | 앱 실행(메인화면) | 도움말 | 학사 일정 | 개설 강좌 조회 | 공지사항 | 즐겨찾는 과목(베타) | 설정  |
| :-----: | :---------------: | :----: | :-------: | :------------: | :------: | :-----------------: | :---: |
| Android |         ✅         |   ✅    |     ✅     |       ✅        |    ✅     |          ✅          |   ✅   |
|   iOS   |         ✅         |   ✅    |     ✅     |       ✅        |    ✅     |          ✅          |   ✅   |
|  macOS  |         ✅         |   ✅    |     ✅     |       ✅        |    ✅     |          ✅          |   ✅   |
|   Web   |         ✅         |   ✅    |     ❌     |       ✅        |    ❌     |          ✅          |   ✅   |
| Windows |         ✅         |   ✅    |     ✅     |       ❌        |    ✅     |          ❌          |   ❌   |
|  Linux  |         ✅         |   ✅    |     ✅     |       ❌        |    ✅     |          ❌          |   ❌   |

❌ Windows/Linux플랫폼은 현재 작동하지 않습니다.

## 간단 기능 소개
* 학사 일정을 간단하게 볼 수 있음
* 학교에 대한 공지사항을 볼 수 있음
* 학과 및 학년 별 개설 강좌를 볼 수 있음
* 강의자의 이름, 과목명, 과목코드로 검색하기
* 개설강좌를 탭하면 자세한 정보가 나오고, 해당 강의자의 다른 과목들도 볼 수 있음
## 사용해보기
macOS, Windows, Android, Linux용으로 빌드된 파일을 사용하거나 Web 사이트 상에서 바로 사용이 가능합니다.

### 사전 빌드된 파일 사용하기
> ⚠️ 태그를 지정한 커밋만 빌드됩니다. 모든 커밋의 변경사항을 바로 추척하려면 Web 플랫폼을 사용하세요.

아래 사이트에 접속하셔서 파일을 받으시면 됩니다.

[Github Release](https://github.com/sun30812/suwon_mate/releases)

* suwon_mate_android.apk: Android 기기에서 동작하는 파일입니다.
* suwon_mate_win.zip: windows 환경에서 동작하는 파일입니다.
  * 압축을 푼 후 폴더안에 내용물은 **전부** 유지시켜야 합니다.
  * [Visual C++ 재배포 가능 패키지](https://docs.microsoft.com/ko-kr/cpp/windows/latest-supported-vc-redist?view=msvc-170) 가 필요합니다. 본인의 아키텍쳐에 맞게 설치하시면 됩니다.(가장 최신 버전 설치하면 됨)
* suwon_mate.app.zip: macOS환경에서 동작하는 파일입니다.
  * 압축을 푼 후 나오는 파일을 Application 폴더에 넣으시면 됩니다.(Finder에서 Cmd+Shift+A누르면 나옴)
  * 만일 실행이 불가능 하다고 나오면 Application 폴더에 들어가서 해당 앱을 우클릭해서 열기를 누르면 이후에 실행이 계속 가능해집니다.
* suwon_mate_linux.zip: Linux(Ubuntu 20.04LTS, CentOS7에서 작동 확인 됨)환경에서 동작하는 파일입니다.

### Web 플랫폼에서 사용해보기
아래 링크에 접속하시면 다운로드 및 실행 없이 바로 이 앱을 체험할 수 있습니다.  
다만, 아래 링크는 Web플랫폼이기 때문에 상단에 있는 [지원되는 플랫폼](#지원되는-플랫폼)에 명시된 것 처럼 일부 기능이 동작하지 않습니다.

- [Firebase hosting](https://suwon-mate.web.app)
- [Firebase hosting-legacy](https://suwon-mate-legacy.web.app)

## 앱 테스트 해보기
> ⚠️ 테스트 기능은 현재 새로운 구조에 맞추어 변경이 이루어지지 않았기에 현재 작동하지 않습니다.  

만일 해당 앱을 자유롭게 수정해보시는 경우 정상 동작 여부가 궁금하다면 `flutter test` 를 실행해보세요.  
아래 항목들을 검사해줍니다.
* 메인 화면의 버튼 개수가 일치하는지
* 도움말 항목의 개수가 올바른지
* 개설 강좌 조회가 정상적으로 이루어지고, 검색이 정상적으로 수행되는지
* 즐겨찾는 과목에 정상적으로 추가 및 제거 되는지

## 앱 사용 도움말
앱의 도움말 메뉴를 참고하면 대부분의 설명을 보실 수 있습니다.

## DB안내
개설 강좌 조회 버튼을 누를 때 사용되는 DB는 Google의 Firebase를 사용합니다. **수원대 서버에서 직접 받아오지 않습니다.** 본인이 직접 DB를 Firebase로 업로드 하기 때문에 항상 최신 정보를 보장하지 않습니다.

DB가 언제 업데이트 되었는지는 앱 내 설정에서 로컬 DB 버전에서 확인할 수 있습니다.

## 빌드해보기
해당 소스코드를 다운받아서 iOS, Android, Web앱 등으로 빌드할 수 있습니다.
어느 플랫폼이든 Flutter SDK가 기본적으로 필요합니다.

* iOS나 macOS용으로 빌드하려면 **Xcode가 설치 된 macOS**가 필요합니다.
* 일부 플랫폼의 경우 활성화가 필요할 수 있습니다.
* Android용으로 빌드를 위해서는 Android SDK설치가 되어 있어야 합니다.
```bash
# 앱 빌드를 위한 필수 패키지 다운로드
flutter pub get
# Android용
flutter build apk
# iOS용
flutter build ios
# Web용
flutter build web
```
나머지 옵션은 터미널 창에 `flutter build --help` 를 입력하면 알 수 있습니다.
## 개발 참고 사항
### 설정 내 디버그 설정 표시하기
소스코드 내에 `settings.dart` 에 `isDebug` 변수가 있습니다. 이 값을 `true` 로 지정하시면 디버그 설정이 설정 메뉴에 표시됩니다.

### Web버전에서의 일부 동작 제한 안내
특정 사이트가 다른 특정 사이트의 데이터를 가져오는 경우 CORS를 차단하기 위해 데이터를 가져올 수 없습니다.  
물론 이를 해결하기 위한 방법이 있는 것으로 알지만 지금 저의 능력으로는
해결이 불가능 합니다.  
만일 해결에 성공한다면 기능 제한을 풀 것입니다.

세부적인 내용은 [여기](https://developer.mozilla.org/ko/docs/Web/HTTP/CORS) 를 참고하세요.


README.md에 추가해야할 내용이 있다면 언제든 건의 부탁드립니다.