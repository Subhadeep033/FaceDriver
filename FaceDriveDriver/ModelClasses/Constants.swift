//
//  Constants.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 23/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit


class Constants: NSObject {
    
    struct StoryboardIDConstants {
        static let kSelectCarStoryboardId = "selectCarViewControllerID"
        static let kSignInStoryboardId = "signInViewControllerID"
        static let kHomeStoryboardId = "homeViewStoryBoardID"
        static let kProfileStoryboardId = "profileStoryboardID"
        static let kForgotPasswordStoryboardId = "forgotPasswordStoryboardID"
        static let kChangePasswordStoryboardId = "changePasswordStoryboardID"
        static let kSignUpOptionStoryboardId = "signUpOptionStoryboardId"
        static let kEnlargeStoryboardId = "enlargeImageViewStoryBoardID"
        static let kUploadDriverDocumentsStoryboardId = "uploadDriverDocsStoryboardID"
        static let kCarDetailsStoryboardId = "carDetailsViewStoryboardID"
        static let kMyEarningsStoryboardId = "myEarningsStoryboardID"
        static let kDriverEarningsStoryboardId = "driverEarningsStoryboardID"
        static let kMyTripsStoryboardId = "myTripsStoryboardID"
        static let kMyTripsStoryboardDetailsId = "myTripsDetailsStoryboardID"
        static let kLegalStoryboardId = "legalStoryBoardID"
        static let kSideMenuStoryboardId = "SideMenuStoryBoardID"
        static let kReferEarnStoryboardId = "referEarnStoryboardID"
        static let kDriverPayoutStoryboardId = "driverPayoutStoryBoardID"
        static let kCarListStoryboardId = "CarListViewController"
        static let kMyAccountStoryboardId = "MyAccountViewController"
        static let kInitialViewStoryBoardId = "InitialViewController"
        static let kCountryStatePopupViewStoryBoardId = "CountryStatePopupViewController"
        static let kSelectCarPopupViewStoryBoardId = "SelectCarPopupViewController"
        static let kPayoutDetailsView = "PayoutDetailsViewController"
        static let kMapWebViewId = "mapInWebViewStoryboardID"
        static let kLegalDetailsId = "legalDetailsStoryboardID"
        static let kSelectRegionPopupViewStoryBoardId = "SelectRegionPopupViewController"
        static let kVerifyPhoneNumberPopupsViewStoryBoardId = "VerifyPhoneNumberPopupsViewController"
        static let kPTCDocumentsStoryBoardId = "ptcDocumentsStoryboardID"
        static let kSOSPopupStoryBoardId = "sosViewController"
        static let kStatusStoryBoardId = "StatusViewControllerID"
        static let kDocumentsHelpStoryBoardId = "documentsHelpStoryboardID"
    }
    
    struct StoryboardSegueConstants {
        static let kSelectCarSegue = "goToSelectCar"
        static let kTripDetailsSegue = "gotoTripDetails"
        static let kSignUpSegue = "goToSignUp"
        static let kForgotPasswordSegue = "goToForgotPassword"
        static let kChangePasswordSegue = "goToChangePassword"
        static let kSignUpOptionSegue = "goToSignUpOption"
        static let kDocumentsUploadSegue = "goToDocumentsUpload"
        static let kEnlargeSegue = "goToEnlargeView"
        static let kCarDetailsSegue = "goToCarDetails"
        static let kCarDocumentsUploadSegue = "goToCarDocumentsUploadSegue"
        static let kDocumentsHelpSegue = "goToDocumentHelpViewController"
    }
    
    struct SocialLoginKeys {
        static let kGoogleMapsApiKey = "AIzaSyCJEDJXbBtlNuRPtghBCJnXfJIDZ_XlRDU"   //"AIzaSyAwmklfE4cEswmYHiP38sD5HKJllvLXt1A"
        static let kGoogleClientId = "176284847486-8v60hs4hukekc8jdson43ontmt352tq9.apps.googleusercontent.com" //"987490378236-pqmpiffnao87gsffv2gaq1q8c8hnq9ns.apps.googleusercontent.com"
        static let kGoogleReserveClientId = "com.googleusercontent.apps.176284847486-8v60hs4hukekc8jdson43ontmt352tq9"//"com.googleusercontent.apps.987490378236-pqmpiffnao87gsffv2gaq1q8c8hnq9ns"
    }
    
    struct TableCellId {
        static let kSelectCarTableCellID = "chooseCarCell"
        static let kPopupTableCellID = "popUPTableCellId"
        static let kCountryCodePopupCellID = "countryCodeTableCellID"
        static let kCountryStatePopupCellID = "countryStateTableCellID"
        static let kProfileCellID = "profileInputCell"
        static let kProfileCarListCell = "profileCarListCellID"
        static let kDocumentsCell = "documentCellID"
        static let kForgotPasswordTableCell = "PhoneNumberForgotPassTableViewCell"
        static let kForgotPasswordOTPTableCell = "ForgotPassOTPTableViewCell"
        static let kForgotPasswordSetPasswordTableCell = "SetPasswordForgotPassTableViewCell"
        static let kLoginCollectionCell = "LoginCollectionViewCell"
        static let kSignUpCollectionCell = "SignInOTPCollectionViewCell"
        static let kChangePasswordCell = "changePassWordCellId"
        static let kMyEaringsCell = "myEarningsCellId"
        static let kMyTripsCell = "myTripsCellId"
        static let kLegalCell = "legalTableCellID"
        static let kDriverPayoutCell = "driverPayoutCellId"
        static let kRiderDetailsCellId = "riderDetailsCellId"
        static let kPaymentCellId = "paymentCellId"
        static let kSOSCellId = "sosCellId"
        static let kDividerCellId = "dividerCell"
        static let kTimeDistanceCellId = "timeDistanceCell"
        static let kPickupDropCellId = "pickUpDropCell"
        static let kReceiptCellId = "receiptCell"
        static let kRatingCellId = "ratingReviewCell"
        static let kMyAccountCellId = "MyAccountCell"
        static let kDocumentsCellId = "documentsCell"
        static let kCarDetailsTextCellId = "CarDetailsTextFieldCell"
        static let kCarDetailsPopupCellId = "CarDetailsPopupCell"
        static let kCarDetailsDocumentCellId = "CarDetailsDocumantCell"
        static let kCarImageUploadCellId = "CarImageUploadCell"
        static let kPTCDocumentCellId = "PTCDocumentCell"
        static let kSeperatorCellId = "SeperatorCell"
        static let kTripDetailsCellId = "tripDetailsCellId"
        static let kPickDropCellId = "pickUpDropCellID"
        static let kTimeSpanCellId = "timeSpanCellId"
        static let kOnlineOfflineCellId = "onlineOfflineCellId"
        static let kCarDetailsInfoCellId = "CarDetailsInfoCell"
        static let kSideMenuCellId = "sideMenuTableCell"
        static let kCountryCellId = "CountryTableViewCell"
    }
    
    struct AppAlertMessage {
        static let kAlertTitle = "Facedriver"
        static let kNetworkError = "Please check your internet connection."
        static let kNoNetworkAccess = "No Network Access."
        static let kBackToOnline = "Back Online."
        static let kAlertSupportCallTitle = "Contact Us"
        
        static let kEnterMobileNumber = "Please enter your mobile number."
        static let kEnterFirstName = "Please enter your first name."
        static let kEnterLastName = "Please enter your last name."
        static let kEnterEmailIdAlert = "Please enter your email address."
        static let kEnterPasswordAlert = "Please enter your password."
        static let kValidEmailIdAlert = "Please enter a valid email address."
        static let kValidPasswordAlert = "Password must contain six characters."
        static let kSomeThingWentWrong = "Something Went Wrong."
        static let kThankYouNote = "Write A Thank You Note."
        static let kCompleteStageOne = "Please complete all fields in the 1st step of verification."
        static let kCompleteStageTwo = "Please complete all fields in the 2nd step of verification."
        static let kEnterMobileNumberAndCountryCode = "Please enter your mobile number including the country code."
        static let kEnterVerificationCode = "Please enter verification code."
        static let kVerificationCodeText = "Verification code has been sent to you on your registered mobile number."
        static let kPasswordCheck = "Your Passwords Do Not Match."
        static let kNewPasswordConfirmPasswordCheck = "Your new and confirmed passwords do not match."
        static let kOldPasswordCheck = "Your Passwords Match!"
        static let kValidPhoneNumber = "Please enter a valid phone number."
        static let kSameMobileNumber = "Please re-enter your phone Number."
        static let kEnterCountry = "Please enter your country."
        static let kEnterStateOrProvince = "Please enter or select from list the Province or State."
        static let kEnterCity = "Please enter City name."
        static let kEnterOtpToValidatePhoneNumber = "Please enter OTP to verify your mobile number."
        static let kDriverRegistrationTermsAndConditions = "Please accept the Terms & Conditions to complete your registration. You can use the link to review detailed content."
        static let kDriverProfileImage = "Please include your profile image to complete registration.\n\nYour self portrait here is mandatory for verification on submitted documents and approval by administration."
        static let kVerifyMobileNumber = "Please verify mobile number."
        static let kLogoutPemission = "Do you want to logout from Facedriver?"
        static let kProfileApprove = "Please Verify Your Account By Uploading Your Car Details And Documents From My Account, Located In The Side Menu.\n If You Have Already Uploaded These Documents Please Wait For Admin Approval!"
        static let kSelectCarError = "Please select a car."
        static let kEndTripAlert = "Are you sure you have arrived at the drop off location?"
        static let kStartTripAlert = "Please confirm that the rider is in your car and ready for you to start the trip?"
        static let kConfirmStopAlert = "The App will automatically calculate your wait time at this stop and pay you accordingly at the end of your ride. Please press Yes if you have successfully reached the stop."
        static let kArrivedTripAlert = "Are you sure you have arrived at the pickup location?"
        static let kRemoveCarAlert = "Do you want to remove this car from your account?"
        static let kCancelTripAlert = "Do You Want To Cancel This Trip?"
        static let kEnterOldPassword = "Please enter your old password."
        static let kEnterNewPassword = "Please enter your new password."
        static let kConfirmPassword = "Please enter your confirm password same as new password."
        static let kProfileViewMode = "Your Profile Is In View Mode."
        static let kEmailVerification = "We Will Send You An Email Verification Link, When You Save Your Profile Details.\nThank You."
        static let kSelectRegion = "Please select the regions you would like to accept rides."
        static let kSelectPassengerSeat = "Please enter number of passenger seats."
        static let kEnterYearOfVehicle = "Please enter the year your car was made."
        static let kEnterRegistrationOfVehicle = "Please enter registration date of vehicle."
        static let kEnterRegistraionNumber = "Please enter your car registration number."
        static let kEnterCarType = "Please enter details of your car type."
        static let kEnterEnergyType = "Please enter car energy type."
        static let kEnterCarModel = "Please enter details of your car model."
        static let kEnterCarManufacturer = "Please enter details of your car manufacturer."
        static let kInvalidOTP = "Please enter the verification code sent to you via SMS."
        static let kVerifyPhoneNumber = "Please Verify Your Phone Number."
        static let kNoCarsAdded = "Sorry! You Have Not Added Any Cars Or No Cars Have Been Approved."
        static let kNoCarAvailable = "Sorry! You Can't Go Online. You Have No Cars Or No Approved Cars."
        static let kNoBankAccountAdded = "Add Your Bank Account Under Payout To Go Online."
        static let kCarManuFacturer = "Please select car manufacturer."
        static let kEnterCarLiecenseNumber = "Please enter your car license plate number."
        static let kEnterCarColor = "Please enter your car's colour."
        static let kInvalidSession = "Your Session Has Expired. Please Login Again."
        static let kNoTrips = "You Have Not Completed Any Rides Yet."
        static let kTryAgain = "Please try again."
        
        static let kEnterAccountHolderName = "Please enter the account holder's name."
        static let kEnterRoutingNumber = "Please enter Transit (Bank Branch) Number.\nYou can find this information on your cheque book or your bank statement."
        static let kEnterInstitutionNumber = "Please enter Institution (Bank Branch) Number.\nYou can find this information on your cheque book or your bank statement."
        static let kEnterAccountNumber = "Please enter your Financial Institution (Bank) Number.\nYou can find this information on your cheque book or your bank statement."
        static let kEnterIdNumber = "Please enter your Bank Account Number.\nYou can find this information on your cheque book or your bank statement."
        static let kEnterAddress = "Please enter your address."
        static let kEnterPostalCode = "Please enter your Postal Code."
        static let kEnterDOB = "Please enter your Date Of Birth (YYYY/MM/DD)"
        static let kSpecialCharacter = "Please Remove Special Characters or Numbers"
        static let kAllowNotificationService = "Please Allow Notification Services."
        static let kAllowCameraAccess = "Please Allow Camera Access."
        static let kAllowGalleryAccess = "Please Allow Access To Your Gallery."
        static let kAllowLocationService = "Please Allow Your Location Services."
        static let kOutOfRegion = "You Are Out Of Your Region."
        static let kGoBackToRegion = "Please Return To Your Region To Receive Ride Requests."
        static let kGoOffline = "Would you like to go Offline?"
        static let kForceUpdateMessage = "There Is A New Version Of Facedriver Available In The AppStore! Please Update Your App To Use Facedriver. Thank You!"
        static let kOptionalUpdateMessage = "There Is A New Version Of Facedriver Available In The AppStore! Please Update Your App For A Better Experience. Thank You!"
        static let kFirebaseErrorMessage = "There Is No Record Of A User Corresponded To This ID. The User May Have Been Deleted."
        static let kChangeCurrentStatus = "You cannot change your Online status as you are in an ongoing trip."
        static let kLogoutPermission = "You cannot logout from Facedriver. \n As you are in an ongoing trip."
        static let kReviewStatus = "Sit back and relax! Your Account is under review.\n Keep an eye out on your email address to get a background check e-consent form from us soon. (Background checks could take up to 2 business days).\n Thanks for joining the Facedrive family!"
        static let eConsentStatus = "Hello Facedrive driver, We have successfully sent you an e-consent form on your registered email address.\n Please check your mailbox and look for an email that says “Facedrive has requested that you complete an online application via eConsent”.\n We will be able to move you on the next step as soon as you do that."
        static let kAbstractReadyStatus = "Congratulations! Your background check has been approved.\n We are doing some final changes to your account."
        static let kFingerprintsRequiredStatus = "Based on the information provided, a search of the RCMP National Repository of Criminal Records could not be completed.\n Positive identification that a criminal record does or does not exist requires you to submit fingerprints to the RCMP National Repository of Criminal Records by an authorized police service or accredited private fingerprinting company.\n If you have already done so, Please contact support or mail it to us on docs@facedrive.com"
        static let kAbstractRejectedStatus = "Apologies! We cannot approve your account right now as it does not meet the requirements in your region to drive with us.\n Please contact support on 1-888-776-7889 or email us on docs@facedrive.com to find out more about your account."
        static let kPTCSubmissionReadyStatus = "You’re almost there! We are doing a final review of your account.\n This could take up to 2 business days.\n Please keep an eye out for an email or call from us."
        static let kOrientationReadyStatus = "Congratulations! You’re ready to be a Facedrive driver.\n All you need to do now is to visit one of our offices for a quick orientation where we will provide you with all the information you need to be a successful facedrive driver."
        static let kWaitingListHamilton = "Apologies, Due to limited number of drivers allowed in your region, we cannot activate your account right now.\n We are adding new drivers everyday. Keep an eye out on your email to hear back from us soon."
        static let kDefaultPTCMessage = "Thank You for registering with Facedrive to drive.\nPlease make sure to add a car and upload all documents related to driver and car, before submitting your application."
        static let kSubmitMessage = "Thank you for submitting your information to partner as a driver with Facedrive.\n\nWe will contact you on the next steps required for approval.\n\nPlease logout of the app now and await our communication."
        
        static let kDriverLicense = "1. Must have a valid G license or equivalent.\n\n2. Age Limit: 21 years or older."
        static let kWorkEligibility = "1. Valid documents: Canadian Passport, Birth Certificates, Citizenship Card, Residency Card and Work Permit.\n\n2. Documents cannot be expired."
        static let kVehicleInsurance = "1. Your name must be visible on the vehicle insurance slip.\n\n2. If you are a secondary driver, include a photo of the full policy document with your name on it."
        static let kVehicleRegistration = "1. Both sides of the registration are required.\n\n2. Vehicle cannot be older than 7 years."
        static let kVehicleInspection = "1. All vehicles must pass a safety inspection and receive a Safety Standards Certificate (SSC).\n\n2. Complete a vehicle inspection at any mechanic licensed by the Ministry of Transportation Ontario (MTO).\n\n3. Must be completed within the year.\n\n4. Valid for one year."
        static let kBankDetailsOfCanada = "(003) Royal Bank of Canada (RBC)\n\n(004)Toronto-Dominion Bank (TD Bank Group)\n\n(002) Bank of Nova Scotia (Scotiabank)\n\n(001) Bank of Montreal (BMO)\n\n(010) Canadian Imperial Bank of Commerce (CIBC)\n\n(006) National Bank of Canada\n\n(016) HSBC Bank Canada\n\n(039) Laurentian Bank of Canada (LBC)\n\n(030) Canadian Western Bank (CWB)\n\n(260) Citibank Canada"
        static let kSupportCallMessage = "Contact us via tollfree number:\n(1-877-360-5318)"

    }
    
    struct AppAlertAction {
        static let kChooseProfilePicture = "Add Profile Picture"
        static let kChangeProfilePicture = "Change Profile Picture"
        static let kChooseImageSource = "Choose Source Type"
        static let kChooseFromGallery = "Choose Image From Gallery"
        static let kCancel = "Cancel"
        static let kNo = "No"
        static let kPickFromCamera = "Capture Image from Camera"
        static let kViewImage = "View Image"
        static let kChangeImage = "Change Image"
        static let kDeleteAccount = "Delete Account"
        static let kMakeDefaultAccount = "Make Account As Default"
        static let kTurnOn = "Turn On >"
        static let kOKButton = "Ok"
        static let kYESButton = "Yes"
        static let kAddBank = "Add Bank"
        static let kCall = "Call"
        static let kPhoneNumber = "1-877-360-5318"
    }
    
    struct legalURL{
        static let kCopyRightUrl = "https://prod2.apps.fdv2.com/apps/static/copyright.html"
        static let kTermsConditionUrl = "https://prod2.apps.fdv2.com/apps/static/terms_condition.html"
        static let kPrivacyUrl = "https://prod2.apps.fdv2.com/apps/static/privacy_policy.html"
        static let kDataProvidersUrl = "https://prod2.apps.fdv2.com/apps/static/data_providers.html"
        static let kSoftwareLiecenseUrl = "https://prod2.apps.fdv2.com/apps/static/software_license.html"
        static let kLocationUrl = "https://prod2.apps.fdv2.com/apps/static/location_information.html"
    }
    
    struct NotificationConstant {
        static let kNotificationTitle = "Facedriver"
        static let kSignUpSubTitle = "Welcome To Facedriver"
        static let kSignUpBody = "You have successfully registered as a Facedrive Driver."
        static let kSignUpNotificationID = "signUpNotification"
        static let kNewRequestSubTitle = "New Request Received"
        static let kNewRequestBody = "You have received a new ride request."
        static let kNewRequestNotificationID = "newRequestNotification"
        static let kScheduleRequestSubTitle = "Schedule Request Received"
        static let kScheduleRequestBody = "You have received a new schedule ride request."
        static let kScheduleRequestNotificationID = "scheduleRequestNotification"
        static let kEndTripSubTitle = "Trip End"
        static let kEndTripBody = "You have successfully completed trip."
        static let kEndTripNotificationID = "endTripNotification"
        static let kCancelTripSubTitle = "Trip Cancelled"
        static let kCancelTripBody = "Sorry! Trip has been cancelled by Rider."
        static let kCancelTripNotificationID = "cancelTripNotification"
    }
    
    struct AppColour {
        static let kAppRedColor = UIColor(red: 242/255, green: 48/255, blue: 48/255, alpha: 1.0)
        static let kAppGreenColor = UIColor(red: 59/255, green: 133/255, blue: 47/255, alpha: 1.0)
        static let kAppLightRedColor = UIColor(red: 239/255, green: 106/255, blue: 106/255, alpha: 1.0)
        static let kAppBlackColor = UIColor(red: 35/255, green: 32/255, blue: 33/255, alpha: 1.0)
        static let kAppLightBlackColor = UIColor(red: 81/255, green: 79/255, blue: 80/255, alpha: 1.0)
        static let kAppLightGreyColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1.0)
        static let kAppPolyLineGreenColor = UIColor(red: 53/255.0, green: 124/255.0, blue: 49/255.0, alpha: 1.0)
        static let kAppPolygonGreenColor = UIColor(red: 59.0/255.0, green: 133.0/255.0, blue: 47.0/255.0, alpha: 0.2)
        static let kAppBorderColor = UIColor(red: 80.0/255.0, green: 79.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    }
    
    struct DeviceSize {
        static  let FULLWIDTH = UIScreen.main.bounds.width
        static  let FULLHEIGHT = UIScreen.main.bounds.height
        static  let SCREEN_MAX_LENGTH    = max(DeviceSize.FULLWIDTH, DeviceSize.FULLHEIGHT)
        static  let SCREEN_MIN_LENGTH    = min(DeviceSize.FULLWIDTH, DeviceSize.FULLHEIGHT)
    }
    
    struct StaticSizes {
        static let TABBARHEIGHT = CGFloat(68.0)
        static let TOASTVIEW = CGFloat(45)
        static let REGIONVIEWHEIGHT = CGFloat(85)
    }
    
    struct MapStyle {
        static let mapStyle = "style=element:geometry|color:0xf5f5f5&style=element:labels.icon|visibility:off&style=element:labels.text.fill|color:0x616161&style=element:labels.text.stroke|color:0xf5f5f5&style=feature:administrative.land_parcel|element:labels.text.fill|color:0xbdbdbd&style=feature:poi|element:geometry|color:0xeeeeee&style=feature:poi|element:labels.text.fill|color:0x757575&style=feature:poi.park|element:geometry|color:0xe5e5e5&style=feature:poi.park|element:geometry.fill|color:0xe8f8d1&style=feature:poi.park|element:labels.text.fill|color:0x9e9e9e&style=feature:road|element:geometry|color:0xffffff&style=feature:road.arterial|element:labels.text.fill|color:0x757575&style=feature:road.highway|element:geometry|color:0xdadada&style=feature:road.highway|element:labels.text.fill|color:0x616161&style=feature:road.local|element:labels.text.fill|color:0x9e9e9e&style=feature:transit.line|element:geometry|color:0xe5e5e5&style=feature:transit.station|element:geometry|color:0xeeeeee&style=feature:transit.station|element:geometry.fill|color:0xabb7d6&style=feature:water|element:geometry|color:0xc9c9c9&style=feature:water|element:geometry.fill|color:0xc1e9f4&style=feature:water|element:labels.text.fill|color:0x47689a"
    }
    
    enum TextFieldDelegateType {
        case textFieldShouldBeginEditing
        case textFieldDidBeginEditing
        case textFieldShouldChangeCharactersIn
        case textFieldShouldReturn
        case textFieldDidEndEditing
    }
    
    typealias TextFieldCompletionBlock = (  _ textField: UITextField,  _ texFieldDelegType: TextFieldDelegateType) -> Bool?
    typealias TextFieldShouldChangeCompletionBlock = (  _ textField: UITextField,  _ text: String) -> Bool?
    
    enum VersionError: Error {
        case invalidBundleInfo
        case invalidResponse
    }
    
    enum TextViewDelegateType {
        case textViewDidBeginEditing
        case textViewShouldChangeTextIn
        case textViewDidEndEditing
    }
    
    typealias TextViewCompletionBlock = (  _ textField: UITextView,  _ texFieldDelegType: TextViewDelegateType) -> Bool?
    typealias TextViewShouldChangeCompletionBlock = (  _ textField: UITextView,  _ text: String) -> Bool?
}
