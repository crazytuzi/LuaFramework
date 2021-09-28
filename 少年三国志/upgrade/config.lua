
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1
DEBUG_FPS = false
DEBUG_MEM = true

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960

CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
-- auto scale mode
--CONFIG_SCREEN_AUTOSCALE = function ( w, h )
--	
--end

local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()
if target == kTargetAndroid then
	--JSON_ENCRYPT_POSTFIX = "encode"
	--JSON_ENCRYPT_KEY	= "905AC7969EC5"
	--PNG_ENCRYPT_KEY 		= "7917ACD719E8"
	--PNG_ENCRYPT_POSTFIX		= "encode"
	--USE_ENCRYPT_RES = true
else
	JSON_ENCRYPT_POSTFIX 	= ""
	JSON_ENCRYPT_KEY		= ""
	PNG_ENCRYPT_KEY 		= ""
	PNG_ENCRYPT_POSTFIX		= ""
	USE_ENCRYPT_RES = false
end

-- debug control flag
SHOW_DEBUG_PANEL = 0

-- 更新模块开关，1表示打开，其它值为关闭
CONFIG_UPGRADE_MODULE = 1
-- windows 版本使用内更新的开关,1为打开,其它为关闭,开发人员最好关闭
WINDOWS_USE_UPGRADE	 = 0

LOAD_APP_ZIP = 0

-- 是否使用加密版本的lua代码（用于使用了对单个lua文件字节码和加密的对外的设备版本）
USE_ENCRYPT_LUA	= false

-- new user guide
SHOW_NEW_USER_GUIDE = true

-- flag which decide if to show exception tip layer
SHOW_EXCEPTION_TIP = true

--是否是和谐版
IS_HEXIE_VERSION = false

--是否是appstore版本
IS_APPSTORE_VERSION = false


GAME_VERSION_NAME = "10.0.3"
GAME_VERSION_NO	= 3
GAME_PACKAGE_NAME = "少年三国志"

USE_FLAT_LUA = "0"

--写死的OP ID, 如果包里没有接SDK,想额外制定OP ID
SPECIFIC_OP_ID = "1"
SPECIFIC_GAME_OP_ID = "1"
SPECIFIC_GAME_ID = "94"


PROXY_CLASS= "app.platform.testPlatform.TestProxy"

VERSION_URL_TMPL = "http://patch.n.m.youzu.com/nconfig/services/nconfig?action=get_config&game=#game#&op_game=#op_game#&op=#op#&v=#v#&iv=#iv#&d=#d#&platform=#platform#&t=#t#&model=#model#&m=#mem#&c=#cpu#&cm=#checkmodel#"
DEV_UPGRADE_ZIP_URL = ""

CC_USE_DEPRECATED_API = true