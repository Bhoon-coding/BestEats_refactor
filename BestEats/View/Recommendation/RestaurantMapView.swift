//
//  RecommendationView.swift
//  BestEats
//
//  Created by BH on 2024/07/16.
//

import SwiftUI
import MapKit

enum PlaceInfoError: Error {
    case emptyData
    
    var messageDescription: String {
        switch self {
        case .emptyData:
            return "정보없음"
        }
    }
}

struct RestaurantMapView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RestaurantMapViewModel()
    @State private var isPresentedSheet: Bool = false
    @State private var nearestPlace: V2.Local.Search.Keyword.Response.PlaceInfo? = nil
    @State private var selectedPlace: V2.Local.Search.Keyword.Response.PlaceInfo?
    @State var foodType: FoodType = .cafe
    
    var body: some View {
        ZStack {
            map
            
            VStack {
                topContentContainer
                Spacer()
                bottomContentContainer
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .onAppear {
            vm.getCurrentLocation()
            self.isPresentedSheet = true
        }
        .onChange(of: vm.nearRestaurants) { newPlaces in
            if let place = newPlaces.first {
                self.nearestPlace = place
                zoomToLocation(location: place.coordinate)
            }
        }
        .onChange(of: selectedPlace) { newPlace in
            if let selectedPlace = vm.nearRestaurants.first(where: { $0.id == newPlace!.id }) {
                zoomToLocation(location: selectedPlace.coordinate)
            }
        }
        .onChange(of: foodType) { newFoodType in
            Task { await vm.fetchNearRestaurant(foodType: newFoodType) }
        }
        .sheet(isPresented: $isPresentedSheet) {
            FoodTypeSheetView(foodType: $foodType)
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Function
    
    private func setInfoNearPlaceCount() -> String {
        let placeCount: Int = vm.nearRestaurants.count
        return "근처에 \(placeCount)개의 맛집이 있어요!"
    }
    
    private func setPlaceName() -> String {
        guard let place = selectedPlace else {
            return self.nearestPlace?.placeName ?? PlaceInfoError.emptyData.messageDescription
        }
        return place.placeName
    }
    
    private func setCategoryName() -> String {
        
        guard let place = selectedPlace,
              let categoryName = place.categoryName else {
            return self.nearestPlace?.categoryName ?? PlaceInfoError.emptyData.messageDescription
        }
        return categoryName
    }
    
    private func setAddressName() -> String {
        guard let place = selectedPlace,
              let roadAddress = place.roadAddressName else {
            return self.nearestPlace?.roadAddressName ?? PlaceInfoError.emptyData.messageDescription
        }
        return place.addressName ?? roadAddress
    }
    
    private func setDistance() -> String {
        var distance: String?
        
        if let place = selectedPlace {
            distance = place.distance
        } else {
            distance = nearestPlace?.distance
        }
        
        guard let validDistance = distance,
              let distanceValue = Double(validDistance) else {
            return PlaceInfoError.emptyData.messageDescription
        }
        
        return distanceValue.convertedDistance()
    }
    
    private func zoomToLocation(location: CLLocationCoordinate2D) {
        withAnimation(.easeIn) {
            vm.region.center = location
        }
    }
}

// MARK: - View

extension RestaurantMapView {
    
    private var map: some View {
        Map(
            coordinateRegion: $vm.region,
            showsUserLocation: true,
            //                userTrackingMode: .constant(.follow),
            annotationItems: vm.nearRestaurants
        ) { nearPlace in
            MapAnnotation(coordinate: nearPlace.coordinate) {
                CustomMapMarkerView(
                    selectedPlace: $selectedPlace,
                    place: nearPlace,
                    type: foodType
                )
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var topContentContainer: some View {
        ZStack {
            searchedPlaceText // 가운데로 두기 위함
            
            HStack {
                Spacer()
                menuButton
            }
        }
    }
    
    private var searchedPlaceText: some View {
        Text(setInfoNearPlaceCount())
            .font(.pretendardBold14)
            .foregroundStyle(.white)
            .padding()
            .background(.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var menuButton: some View {
        Button(action: {
            self.isPresentedSheet = true
        }, label: {
            Image(systemName: "line.3.horizontal")
                .font(.pretendardBold18)
        })
        .frame(width: 48, height: 48)
        .foregroundStyle(.white)
        .background(.green)
        .clipShape(Circle())
    }
    
    private var bottomContentContainer: some View {
        VStack(spacing: 16) {
            currentLocationContainer
            placeInfoAndButtonContainer
        }
    }
    
    private var currentLocationContainer: some View {
        HStack {
            Spacer()
            currentLocationButton
        }
    }
    
    private var currentLocationButton: some View {
        Button(action: {
            vm.getCurrentLocation()
        }, label: {
            Image(Img.currentLocation)
                .resizable()
                .frame(width: 24, height: 24)
        })
        .padding()
        .background(.green)
        .clipShape(Circle())
    }
    
    private var placeInfoAndButtonContainer: some View {
        HStack(spacing: 16) {
            placeInfoContainer
            placeInfoButtonContainer
        }
        .frame(maxHeight: 128)
    }
    
    private var placeInfoContainer: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(setPlaceName())
                .font(.pretendardBold20)
            
            HStack(alignment: .bottom) {
                placeInfoContents
                Spacer()
                placeDistanceButton
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var placeInfoContents: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(setCategoryName())
            Text(setAddressName())
        }
        .font(.pretendardRegular14)
        .foregroundStyle(.gray)
    }
    
    private var placeDistanceButton: some View {
        Button {
            // TODO: [] 길안내 준비중 팝업
            print("길안내는 준비중 입니다")
        } label: {
            HStack {
                Image(systemName: "location.fill")
                Text(setDistance())
            }
        }
        .font(.pretendardBold14)
        .padding(8)
        .foregroundStyle(.white)
        .background(.green)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var placeInfoButtonContainer: some View {
        VStack {
            Button("더보기") {
                // TODO: [] WebView 띄우기
            }
            .padding()
            .frame(width: 88)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            Button("예약하기") {
                // TODO: [] 전화 팝업 띄우기
            }
            .padding()
            .frame(width: 88)
            .background(.red)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .font(.pretendardBold14)
        .foregroundStyle(.white)
    }
}

#Preview {
    @State var type: FoodType = .cafe
    return RestaurantMapView()
}
