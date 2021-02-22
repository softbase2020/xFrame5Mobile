## 1. 개요

    xFrame5Mobile 프레임워크는 (주)소프트베이스에서 개발한 U.I 통합 솔루션인 xFrame5의 iOS앱 용 프레임워크이다.
    xFrame5로 작성된 화면이 iOS앱에서 동작할 수 있도록 Web to App를 위한 scheme과 App to Web을 위한 자바스크립트를 제공한다.

## 2. 사용법

**cocoapod로 설치**

    pod "xFrame5Mobile"

**info.plist에 xFrame5키 추가**

xFrame5Mobile 프레임워크를 사용하는 프로젝트를 선택한 후 info.plist에 NSDictionary 타입의 xFrame5 키를 생성

```
    <key>xFrame5</key>
	<dict>
		<key>START_PAGE</key>
		<string>http://xxxxxx/test.html</string>
		<key>debug</key>
		<true/>
	</dict>
```

* START_PAGE : 앱 구동시 처음 호출되는 URL
* debug : 디버그 모드 여부
* PushEnable

**사용되는 기능에 따라 info.plist에 권한 문구 추가**

* 앨범 기능을 사용하는 경우
	* Privacy - Photo Library Usage Description 항목 추가
* 카메라 기능을 사용하는 경우
	* Privacy - Camera Usage Description 항목 추가
* 위치 기능을 사용하는 경우
	* Privacy - Location Always Usage Description 항목 추가
	* Privacy - Location When In Use Usage Description 항목 추가