set SDKROOT=C:\Library\Developer\Platforms\Windows.platform\Developer\SDKs\Windows.sdk
set SWIFTFLAGS=-sdk %SDKROOT% -I %SDKROOT%/usr/lib/swift -L %SDKROOT%/usr/lib/swift/windows
swiftc -o main.exe main.swift player.swift lib.swift ship.swift gameController.swift %SWIFTFLAGS%