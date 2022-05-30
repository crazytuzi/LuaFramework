_APPCZURL = "http://192.168.8.111:81/pay/pay.php"
NewServerInfo = {}
if NET_TYPE == 0 then
	_URL = "http://192.168.8.111:81/"
	NewServerInfo = {
		IOS_SHEN_SERVER = _URL,
		ANDROID_SHEN_SERVER = _URL,
		YUN_LOGIN_SERVER = _URL .. "login.php",
		DEV_LOGIN_SERVER = _URL .. "login.php",
		IOS_LOGIN_SERVER = _URL .. "login.php",
		ANDROID_LOGIN_SERVER = _URL .. "login.php",
		VERSION_URL = _URL .. "version.php",
		DEV_VERSION_URL = _URL .. "version.php",
		LOG_URL = _URL .. "help/clog",
		CHECK_LOGIN_URL = _URL .. "checkLogin.php",
		SERVER_LIST_URL = _URL .. "servers.php",
		TUIGUANG_URL = _URL .. "url/tg.php",
	}
elseif NET_TYPE == 1 then
	_URL = "http://192.168.8.111:81/"
	NewServerInfo = {
		IOS_SHEN_SERVER = _URL,
		ANDROID_SHEN_SERVER = _URL,
		YUN_LOGIN_SERVER = _URL .. "login.php",
		DEV_LOGIN_SERVER = _URL .."login.php",
		IOS_LOGIN_SERVER = _URL .."login.php",
		ANDROID_LOGIN_SERVER = _URL.. "login.php",
		VERSION_URL = _URL .. "version.php",
		DEV_VERSION_URL = _URL .. "version.php",
		LOG_URL = _URL .."help/clog",
		CHECK_LOGIN_URL = _URL .."checkLogin.php",
		SERVER_LIST_URL = _URL .."servers.php",
		TUIGUANG_URL = _URL .. "url/tg.php",
	}
else
	_URL = "http://192.168.8.111:81/"
	NewServerInfo = {	
		IOS_SHEN_SERVER = _URL,
		ANDROID_SHEN_SERVER = _URL,
		YUN_LOGIN_SERVER = _URL .. "login.php",
		DEV_LOGIN_SERVER = _URL .. "login.php",
		IOS_LOGIN_SERVER = _URL .. "login.php",
		ANDROID_LOGIN_SERVER = _URL .. "login.php",
		VERSION_URL = _URL .. "version.php",
		DEV_VERSION_URL = _URL .. "version.php",
		LOG_URL = _URL .. "help/clog",
		CHECK_LOGIN_URL = _URL .. "checkLogin.php",
		SERVER_LIST_URL = _URL .. "servers.php",
		TUIGUANG_URL = _URL .. "url/tg.php",
	}
end