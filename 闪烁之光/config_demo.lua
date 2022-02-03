----------------------------------------------------
---- 项目具体使用到的配置
---- @author whjing2011@gmail.com
------------------------------------------------------
GAME_CODE                   = "sszg"           		-- 游戏标识(一个游戏唯一值 不能修改)
CHANNEL_NAME                = "demo"                -- 渠道名
GAME_NAME                   = "闪烁之光"             -- 游戏名
PLATFORM_NAME               = "demo"                -- 平台名，决定读取的cdn，注册服地址之类的。

DATA_DEBUG                  = true                  -- 测试
SOCKET_DEBUG                = nil                   -- SOCKET调试
is_change_print             = true                  -- true表示原生print输出
WIN_UPDATE                  = false 
UPDATE_SKIP                 = true                  -- 是否跳过版本更新
SHOW_GM                     = true
MUTIL_LOGIN                 = 0                     -- 客户端登录入口个数 (0平台登录 ) 
WAIT_SDK_INIT_SUC           = false                 -- 需要等待SDK初始化完成
CC_SHOW_FPS                 = true

MAIN_VERSION                = 100                   -- 主版本号，显示用，1.0.100前面的1.0就是这个算出来的
NOW_VERSION                 = 0                     -- 热更新版本号
BUILD_VERSION               = 0                     -- 编译版本号，控制强更删除老文件
APP_ROUTE                   = "app"                 -- app路由，用于区分不同平台登录界面的一些图标的
IS_PLATFORM_LOGIN           = false                 -- 是否平台登录
IS_WIN_PLATFORM 			= false 					-- 战盟登录的标识
PLATFORM_PNG                = APP_ROUTE or "app"    -- 具备平台特征的路径,比如闪屏和logo
DEFAULT_FONT                = "fonts/mini.ttf"      -- 默认字体
GAME_INITED                 = false                 -- 是都初始化完成

IS_TEST_APK                 = false                 -- 是否是云测试包
NEED_CHECK_CLOSE            = false                 -- 是否需要检测服务器维护状态

IS_REQUIRE_RES_GY		    = false                 -- 是否是边玩边下模式
AUTO_DOWN_RES			    = false                 -- 边玩边下的自动模式
RESOURCES_DOWNLOAD_PRO_MAX  = 5                     -- 边玩边下的下载进程数量
RESOURCES_DOWNLOAD_PRO      = 3                     -- 边玩边下用于优先下载的进程数

SHOW_BAIDU_TIEBA            = true                  -- 是否显示百度贴吧
SHOW_SINGLE_INVICODE        = true                  -- 是否显示个人推荐码
SHOW_BIND_PHONE             = true                  -- 是否需要显示手机绑定界面
SHOW_WECHAT_CERTIFY         = true                  -- 是否显示微信公众号
SHOW_GAME_SHARE             = true                  -- 是否显示游戏分享
WECHAT_SUBSCRIPTION         = "sy_sszg"             -- 微信公众号
WECHAT_SUBSCRIPTION_NAME    = "闪烁之光手游"          -- 微信公众号名字

IS_NEED_SHOW_LOGO 			= true 					-- 是否显示logo
IS_NEED_SHOW_ERWEIMA		= true 					-- 控制部分是否显示二维码

NEEDPLAYVIDEO 				= true

CAN_ADD_SCANNING            = true

IS_TEST_STATUS              = false                 -- 是否是提审服,提审服状态修改一些属性
IS_SY_GAME				    = not IS_TEST_STATUS    -- 是否是公司的包,这个时候要显示登录模型
IS_NEED_LOGIN_EFFECT		= not IS_TEST_STATUS    -- 是否需要播放login特效
MAKELIFEBETTER				= IS_TEST_STATUS        -- 是否是审核服
USESCENEMAKELIFEBETTER		= IS_TEST_STATUS        -- 是否使用审核服主城,提审服需要使用替换主城
IS_IOS_PLATFORM             = IS_TEST_STATUS

CUSTOMER_QQ                 = 800185843             -- 客服QQ
FILTER_CHARGE               = false                 -- 是否屏蔽充值
IS_SHOW_SHARE               = true                  -- 是否显示分享界面

IS_NEED_REAL_NAME			= true 					--防沉迷系统
-- 是否是专家服
IS_EXPERT                   = CHANNEL_NAME == "expert" or CHANNEL_NAME == "expert2"
NEW_DOWNLOAD_URL			= true 					-- 新的下载版本方式

NEED_PLAY_FLASHVIDEO 		= true
-- 平台
PLATFORM                    = cc.Application:getInstance():getTargetPlatform()
IOS_SUBSCRIBE               = false                 --是否是可订阅
IS_ONECENTGIFT              = true                  --一毛礼包是否开启
-- 配置信息获取地址
URL_LUA_CONFIG="http://cdn.demo.zsyz.shiyuegame.com/update/config/url_config_demo.lua" 

--外服测试 用 --by lwc
-- CHANNEL_NAME                = "release2"                -- 外服测试 渠道名
-- PLATFORM_NAME               = "release2"                -- 外服测试平台名，决定读取的cdn，注册服地址之类的。
-- URL_LUA_CONFIG="http://register.sszg.shiyuegame.com/update/config/url_config_release2gy.lua"
-- CAN_USE_CAMERA=true

-- --渠道平台
-- CHANNEL_PRE                   = ""
-- PLATFORM_NAME               = "symlf"               -- 平台名，决定读取的cdn，注册服地址之类的。
-- URL_LUA_CONFIG="https://register-sszg.shiyuegame.com/update/config/url_config_sszgmix.lua"    

-- 日志上报地址
LOG_URL = "http://192.168.1.110/index.php"
