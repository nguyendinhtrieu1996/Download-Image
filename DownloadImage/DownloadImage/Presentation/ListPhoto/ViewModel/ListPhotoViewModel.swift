//
//  ListPhotoViewModel.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import Foundation
import RxSwift
import RxCocoa

class ListPhotoViewModel: BaseViewModel {
    
    var currentPage = 0
    let limitPhotoPerPage = 100
    
    var fetchPhotosUseCase: FetchListPhotoUseCase
    var userConfigurationUseCase: UserConfigurationUseCase
    
    init(fetchPhotosUseCase: FetchListPhotoUseCase,
         userConfigurationUseCase: UserConfigurationUseCase) {
        
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.userConfigurationUseCase = userConfigurationUseCase
    }
}

// MARK: ViewModelTypeProtocol

extension ListPhotoViewModel: ViewModelTypeProtocol {
    
    struct Input {
        let viewDidload: Observable<Void>
        let pullToRefresh: Observable<Void>
        let updateLayoutMode: Observable<PhotoListMode>
    }
    
    struct Output {
        let errrorMessage: Driver<String>
        let photos: Driver<[Photo]>
        
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let photosSubject = PublishSubject<[Photo]>()
        
        input.viewDidload
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.loadPhotos(photosSubject: photosSubject,
                                errorTracker: errorTracker)
            })
            .disposed(by: self.disposeBag)
        
        input.pullToRefresh
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                
            })
            .disposed(by: self.disposeBag)
        
        input.updateLayoutMode
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
            })
            .disposed(by: self.disposeBag)
        
        let errorMessageEvent = errorTracker.map {
            return $0.localizedDescription
        }
        
        return Output(errrorMessage: errorMessageEvent.asDriver(),
                      photos: photosSubject.asDriverOnErrorJustComplete())
    }
}

// MARK: Fetch Photos

extension ListPhotoViewModel {
    
    func loadPhotos(photosSubject: PublishSubject<[Photo]>,
                    errorTracker: ErrorTracker) {
        
        
    }
    
    func loadPhotosWithCurrentPage(_ currentPage: Int, limit: Int) {
        let photoQuery = PhotoQuery(page: currentPage, limit: limit)
        
        self.fetchPhotosUseCase.fetchListPhoto(query: photoQuery) { result in
            
        }
    }
}
