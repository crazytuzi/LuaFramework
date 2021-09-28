-- 游戏中的常量
GameConst = {}

GameConst.GameName = AppConst.GameName
GameConst.Debug = AppConst.DebugEngine == true
GameConst.GId = AppConst.GameId -- 游戏平台返回id
GameConst.SId = AppConst.SubGameId -- 游戏平台返回子id

-- 是否为sdk平台
isSDKPlat = AppConst.isSDKPlat == true
GameConst.isAppleIAP = AppConst.isAppleIAP == true
GameConst.IAPPriceUnit = AppConst.IAPPriceUnit
local webIP = AppConst.webIP
local webPort = AppConst.webPort

-- 平台
PhonePlat = AppConst.PlatId -- 手机平台
XH = "XH" == PhonePlat -- 迅海平台
SHENHE = "SHENHE" == PhonePlat -- 审核服

GameConst.RegistURL = string.format("http://%s:%s%s", webIP, webPort, "/register") -- 账户注册
GameConst.LoginURL = string.format("http://%s:%s%s", webIP, webPort, "/login")     -- 账户登录
GameConst.VisitorBindURL = string.format("http://%s:%s%s", webIP, webPort, "/binding") --游客绑定
GameConst.GetbackPasswordURL = string.format("http://%s:%s%s", webIP, webPort, "/retPassword") --找回密码
GameConst.ResetPasswordURL = string.format("http://%s:%s%s", webIP, webPort, "/changePassword") --修改密码

GameConst.PRINT_PROTO = GameConst.Debug -- 打印收发协议消息
GameConst.scaleX = UnityEngine.Screen.width/layerMgr.WIDTH
GameConst.scaleY = UnityEngine.Screen.height/layerMgr.HEIGHT
GameConst.PI2 = 2*math.pi
GameConst.defaultFont = "方正粗圆简体"
GameConst.USE_PRELOAD = not GameConst.Debug -- 使用预加载

GameConst.ViewType = 0 --0:主界面 1:战斗界面
GameConst.heartCD = 5 -- 心跳
GameConst.FrameRate = 0.01666666667 -- 1/60