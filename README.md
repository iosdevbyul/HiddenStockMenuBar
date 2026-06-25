# StockMask

macOS 메뉴바 환경에서 실시간 주가 데이터를 모니터링하고, 다양한 스킨으로 화면 표시 형식을 전환할 수 있는 데스크톱 위젯입니다.

## 1. Requirements & Tech Stack
- OS: macOS 14.0 (Sonoma) 이상
- Language: Swift 5.10+
- Framework: SwiftUI (MenuBar Extra), Combine
- Architecture: MVVM Pattern

## 2. Directory Structure
- App/StockMaskApp.swift
- Managers/StockManager.swift
- Services/StockService.swift
- Models/StockItem.swift

## 3. Key Features
- Real-time Data Parsing: ac.stock.naver.com 세션을 모방하여 10초 주기로 실시간 국내 주가 수신 및 파싱을 수행합니다.
- LRU Cache & Persistence: 유저가 최근 선택한 종목을 최대 3개까지 최근 순으로 정렬하며, UserDefaults를 통해 주식 목록, 선택 종목, 위장 테마 상태를 로컬에 영속적으로 저장합니다.
- Disguise System: 사용자의 환경에 맞춰 화면 출력을 제어하는 3가지 위장 스킨을 제공합니다.
  - 날씨 테마: 주가 데이터를 변환하여 백분율 기온 형태로 포맷팅 (1994.00°C)
  - 엑셀 테마: 수식 셀 구조를 모방하여 쉼표 없이 대괄호 데이터로 출력 ([199400])
  - 시계 테마: 주가 자릿수를 분할 연산하여 시/분/초 형태로 매핑 (08:56:00)

## 4. License
This project is licensed under the MIT License.# HiddenStockMenuBar
