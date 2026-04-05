# iOS Setup Instructions

Since you are currently setting up the project on Windows, you will need to perform these steps once you clone this repository onto a Mac to build for iOS.

## 1. Permission Handler Podfile Setup
The `permission_handler` plugin requires you to explicitly define which iOS permissions you want to compile with. Without this, your app will be rejected by the Apple App Store or crash on permission requests.

Once you have run `flutter pub get` and `flutter build ios --config-only` (or simply tried to run the app) on your Mac, it will generate the `ios/Podfile`. 

Open `ios/Podfile`, go to the very bottom, and locate the `post_install do |installer|` block. Update it to match the following configuration:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # ADD THESE LINES TO ENABLE SPECIFIC PERMISSION MODULES
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        
        ## dart: PermissionGroup.camera
        'PERMISSION_CAMERA=1',

        ## dart: PermissionGroup.photos
        'PERMISSION_PHOTOS=1',

        ## dart: PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse
        'PERMISSION_LOCATION=1',

        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=1',
        
        ## dart: PermissionGroup.sms
        'PERMISSION_SMS=1',
      ]
    end
  end
end
```

## 2. Testing iOS SOS Feature
The background SMS functionality we implemented recently is native to Android. On iOS, silent background SMS sending is strictly prohibited by Apple. 
Therefore, the codebase is already designed to gracefully fall back to opening the native iOS SMS composer pre-filled with the required GPS link and contact list. To trigger the message on iOS, the user must tap the final **"Send"** arrow in the messages app. This is expected and required behavior on iOS devices.
