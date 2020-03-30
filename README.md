# favoriteGifs

## API ##
https://developers.giphy.com/docs/api/
    - GifService class에서 API 주소 호출

## 필수구현 ##
1. Keyword 검색
    - [SearchViewController](FavoriteGifs/ViewControllers/SearchViewController.swift)
2. 검색된 이미지 목록 화면과 상세화면
    - - [SearchViewController](FavoriteGifs/ViewControllers/SearchViewController.swift) & - [DetailViewController](FavoriteGifs/ViewControllers/DetailViewController.swift)
    1. 상세화면에서 Favorites On/Off 기능 구현 
        - [DetailViewController](FavoriteGifs/ViewControllers/DetailViewController.swift)의 navigation item의 rignt bar button으로 구현
3. Favorites된 이미지의 목록화면과 상세 화면
    - [FavoriteViewController](FavoriteGifs/ViewControllers/FavoriteViewController.swift)
    1. 상세화면에서 Favorites On/Off 기능 구현
4. Favorites된 목록은 앱을 다시 시작해도 유지되도록 구현
    - CoreData를 이용하여 데이터 유지되도록 구현
    - [DataController](FavoriteGifs/Models/Utils/DataController.swift)에서 매니징 
    
## 추가구현 ##
1. gif 이미지 크기에 따라 다이나믹한 셀 사이즈 설정
    - [DynamicHeightCollectionViewLayout](FavoriteGifs/Views/DynamicHeightCollectionViewLayout.swift)에서 각 셀을 그려갈 때 각 칼럼의 가장 하단 위치를 저장하여, 가장 하단 위치가 높은 칼럼부터 셀을 채워감. 
    셀의 frame.origin.x를 각 셀의 높이를 반영한 각 칼럼의 가장 하단 위치로 설정해줌으로서 컬럼별로 셀의 크기에 맞게 셀들이 위치하도록 함.
2. gif 재생
- [UIImage+Extensions](FavoriteGifs/Views/UIKit+Extensions/UIImage+Extensions.swift)에서 gif 데이터를 받아 각 프레임의 딜레이 시간을 ms으로 치환하여 딜레이 시간 간의 최대공약수로 나눈 값만큼 각 프레임을 더해서 UIImage.animatedImage을 이용함 
- 최대공약수 관련 함수: [NumericFunctions](FavoriteGifs/Utils/NumericFunctions.swift)
