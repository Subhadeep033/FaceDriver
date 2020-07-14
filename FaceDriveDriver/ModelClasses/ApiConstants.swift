//
//  ApiConstants.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 25/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit


class ApiConstants: NSObject {
    struct kBaseUrl {
        //static let baseUrl = "https://prod2.apps.fdv2.com/apps/driver/api/"         //For Production.
        //static let baseUrl = "http://apps.dev.fdv2.com/apps/driver/api/"
        //static let baseUrl = "http://apps.demo.fdv2.com/apps/driver/api/"      //For demo purpose it is commented
       //static let baseUrl = "http://apps.fdv2demo.deeccus.com:9596/apps/driver/api/"
        
        static let baseUrl = "https://dev.apps.fdv2.com/apps/driver/api/" // For Dev Server
//        static let baseUrl = "https://dev.apps.fdv2aws.com/apps/driver/api/"   //For AWS Server
    }
    
    struct kApisEndPoint {
        static let kLoginWithEmail = "10540-login-email-password"
        static let kOnlineOfflineStatusApi = "10570-status"
        static let kAcceptRejectApi = "10580-accept-reject-request"
        //static let kTripStatusApi = "new-10590-change-trip-status"
        static let kTripStatusApi = "new-10590-change-trip-status-v1"
        static let kRatingReviewApi = "10600-complete-trip"
        static let kForgotPasswordSendOtp = "10560-send-otp"
        static let kForgotPasswordVerifyOtp = "10561-verify-otp"
        static let kChangePassword = "10562-update-password"
        static let kDriverProfile = "10610-profile"
        static let kSendOtpForUpdateProfie = "10622-new-mobile-send-otp"
        static let kVerifyOtpForUpdateProfile = "10621-verify-otp"
        static let kUpdateProfile = "10620-update-profile"
        static let kSendOtpForLogin = "10555-login-get-otp"
        static let kVerifyOtpForLogin = "10556-login-with-otp"
        static let kLogoutApi = "10630-logout"
        static let kForceLogoutApi = "10990-force-logout"
        static let kGetOtpForMobileVerificationSignUp = "10650-driver-registration-step1"
        static let kVerifyOtpForSignUp = "10660-driver-registration-step2"
        static let kCountryStateList = "10670-get-countries-states-regions"
        static let kDriverSignUp = "10640-driver-registration-step3"
        static let kUpdatePassword = "10680-update-password"
        static let kSocialLogin = "10690-social-login"
        static let kSocialRegistration = "10700-social-registration"
        static let kChangeMultipleStopStatus = "10750-multiple-stop-status"
        static let kUploadDriverDocuments = "10740-upload-document"
        static let kGetCarDetails = "10730-car-info-listing"
        static let kAddCarDocuments = "10720-car-add-document"
        static let kAddNewCar = "10710-add-car"
        static let kRemoveCar = "10725-car-delete"
        static let kSelectCar = "10760-select-a-car"
        static let kTripHistory = "10780-driver-history?"
        static let kGetRegion = "10800-get-regions-using-state"
        static let kGetEnergyType = "10950-get-energy-type-list"
        static let kGetAddedCarList = "10790-added-car-list"
        static let kGetCarManufacturerList = "10810-get-car-manufacturer-list"
        static let kGetCarModelList = "10820-model-list"
        static let kGetDriverAddedAllCarList = "10830-driver-all-added-cars"
        static let kReferalCode = "10850-send-referral-code"
        static let kGetDriverBankDetails = "10860-get-bank-info"
        static let kDeleteDriverBankAccount = "10880-delete-account"
        static let kMarkDefaultDriverAccount = "10870-set-account-default"
        static let kAddPayoutAccount = "10840-add-bank-account"
        static let kGetStripeState = "10890-strip-state-list"
        static let kGetAverageRating = "10900-average-rating"
        static let kCallMaskingApi = "10910-call-masking"
        static let kUpdateFcmTokenApi = "10930-update-fcm-token"
        static let kGetCarServiceType = "10970-get-current-service"
        static let kGetTripInfo = "10980-get-trip-info"
        static let kCancelRide = "10960-cancel-ride"
        static let kApiLogs = "save-api-call-logs"
        static let kLegalList = "10991-get-legal-page-list"
//        static let kDriverStaticticsApi = "10920-driver-statistics"
    }
}
