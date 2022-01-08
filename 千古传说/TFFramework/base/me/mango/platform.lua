--
-- Author: MiYu
-- Date: 2014-02-13 13:50:31
--

me = me or {}

me.PLATFORM_UNKNOWN           =  0
me.PLATFORM_IOS               =  1
me.PLATFORM_ANDROID           =  2
me.PLATFORM_WIN32             =  3
me.PLATFORM_MARMALADE         =  4
me.PLATFORM_LINUX             =  5
me.PLATFORM_BADA              =  6
me.PLATFORM_BLACKBERRY        =  7
me.PLATFORM_MAC               =  8
me.PLATFORM_NACL              =  9
me.PLATFORM_EMSCRIPTEN        = 10
me.PLATFORM_TIZEN             = 11
me.PLATFORM_WINRT             = 12
me.PLATFORM_WP8               = 13

me.PLATFORM 				  = CC_TARGET_PLATFORM

me.platforms = {
	[me.PLATFORM_UNKNOWN          ] =		"unknown",
	[me.PLATFORM_IOS              ] =		"ios",
	[me.PLATFORM_ANDROID          ] =		"android",
	[me.PLATFORM_WIN32            ] =		"win32",
	[me.PLATFORM_MARMALADE        ] =		"marmalade",
	[me.PLATFORM_LINUX            ] =		"linux",
	[me.PLATFORM_BADA             ] =		"bada",
	[me.PLATFORM_BLACKBERRY       ] =		"blackberry",
	[me.PLATFORM_MAC              ] =		"mac",
	[me.PLATFORM_NACL             ] =		"nacl",
	[me.PLATFORM_EMSCRIPTEN       ] =		"emscripten",
	[me.PLATFORM_TIZEN            ] =		"tizen",
	[me.PLATFORM_WINRT            ] =		"winrt",
	[me.PLATFORM_WP8              ] =		"wp8",
} 

me.platform = me.platforms[me.PLATFORM]

me.KeyCode = {
	BACK_SPACE 		= 0x0008,
	TFNU 			= 0x1067,
}