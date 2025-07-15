//
//  DD.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import AppTrackingTransparency

func TrackingTransparencyPermissionRequest() {
    
    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        print("requestTrackingAuthorization status:", status)
    })
}
