setTextureResolutionHalf(false)
setTextureForceRGBA4444(false)

LOAD_DEPRECATED_API = true               -- 在框架初始化时载入过时的 API 定义
USE_DEPRECATED_EVENT_ARGUMENTS = true    -- 使用过时的事件回调参数
DISABLE_DEPRECATED_WARNING = false       -- true: 不显示过时 API 警告，false: 要显示警告

require("global")
require("envConfig")
require("app.base.FinalSDK")
-- test for lay 0001
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = DEBUG or 1
DEBUG_FPS = true
DEBUG_MEM = false
DEBUG_NETWORK = true
DEBUG_OTHER = true
DEBUG_PROP = true
DEBUG_USER = 0
USER = {"all", "wk", "xurui"}
DEBUG_PRINT_LUA_ERROR = true
ENABLE_CHECK_GLOBAL = true --检查全局变量
-- DEBUG_EXTEND_GAMEOPID = "2001"
ENABLE_CHECK_GLOBAL = true

CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

--是否开启全面屏适配
CONFIG_ALL_SCREEN_SCALE = true

ENCRYPT = 1

Q_DEBUG_TEXTURE_HISTORY = 0

-- log level - 0:dumb, 1:error, 2:info, 3:debug
LOG_LEVEL = 3

--set UTC time
UTC = 8


--ui界面背景图缩放比
UI_BG_SCALE = 1.25
UI_VIEW_MIN_WIDTH = 1280

-- ui resolution
UI_DESIGN_WIDTH = 1136
UI_DESIGN_HEIGHT = 640

-- screen resolution
CONFIG_SCREEN_WIDTH  = 1136
CONFIG_SCREEN_HEIGHT = 640

-- scaling range
CONFIG_SCALE_MIN = 960/640  -- Iphone 4S   
CONFIG_SCALE_MAX = 2208/1242 -- Iphone 6 plus

-- test config
VIDEOPLAYER_ENABLE = true

BATTLE_EDITOR_HIDE_MENU = false

DISPLAY_ACTOR_RECT = false
DISPLAY_ACTOR_CORE_RECT = false
DISPLAY_ACTOR_TOUCH_RECT = false
DISPLAY_ACTOR_MOVE = false     -- 显示人物移动的目的地和路径
DISPLAY_PROPERTY_GRID = false  -- 显示屏幕站位网格
DISPLAY_SKILL_RANGE = false -- 显示群体魂技的攻击范围(显示为椭圆范围的外接矩形)
DISPLAY_TRAP_RANGE = false -- 显示陷阱的影响范围(显示为椭圆范围的外接矩形)
CHECK_SKELETON_FILE = false -- 检查spine的导出文件是否有效
SHOW_STATS_WINDOW = true -- 打开运行统计数据窗口（仅在Windows上有效）
SAVE_BATTLE_RECORD = true -- 在windows上保存战斗录像

SKIP_PLAY_AUDIO = false
ENABLE_CLEAN_TEXTURE_SCHDULER = false
DISABLE_LOAD_BATTLE_RESOURCES = false
ENABLE_CONSOLE_COLOR = true
ENABLE_CCB_TO_LUA = false
ACTOR_PRINT_ID = 0 --需要打印属性的魂师ID
DISPLAY_MORE_BATTLE_DETAIL = false -- 战斗“数据”对话框中，点击头像显示按魂技排列的伤害、治疗统计
DISPLAY_TORNADO_BULLET_RANGE = false -- 显示tornado子弹的攻击范围

DEBUG_ENABLE_REPLAY_LOG = false -- 开启战斗复盘log输出, 打开后会把战斗中所有的数据全部输出到 logs目录下的replay_log开头的文件中

DEBUG_RAGE_ALWAYS_ENOUGH = false -- 怒气魂技永远可用
DEBUG_RAGE = false -- 怒气debug

SHOW_OVERDOSE_TREAT = false --显示过量治疗

DUMP_ALLOCATOR_INFO = false 
DEBUG_SKIP_BATTLE = false

ENABLE_DEBUG_ABSORB = false --test debug护盾

DISPLAY_UNION_GRAGON_WAR_DAMAGE = true --战斗中显示宗门龙战的伤害

SKIP_TUTORIAL = false -- 是否跳过新手引导
SKIP_FIRST_BATTLE_TUTORIAL = false -- 是否跳过新手开场剧情引导
TUTORIAL_WORD_TIME = 1 -- 新手引导对话框延迟时间
TUTORIAL_ONEWORD_TIME = 0.05 --新手引导打字机打字速度
ONLY_BATTLE_TUTORIAL = true -- 是否只运行战斗部分的引导（首次战斗新手引导，第一关引导使用剑刃风暴，第二关引导攻击毒蛇）
CAN_SKIP_BATTLE = false
FIRST_BATTLE_NEVER_END = false -- 开场战斗永远不结束

ALWAYS_SHOW_BOSS_INTRODUCTION = false -- 展示boss信息
ALWAYS_SHOW_NEW_ENEMY = false --永远显示新兵种介绍
ALWAYS_SHOW_NEW_ENEMY_TUTORIAL = false -- 永远显示新兵种介绍引导

HIDE_DAMAGE_VIEW = false --隐藏伤害数字

UNLOCK_DELAY_TIME = 1.5   --解锁提示消失的延迟时间

-- ui config:true翻页、false滑动
MAIN_MENU_DRAG_PAGE = false

-- actor config
ENABLE_ACTOR_RENDER_TEXTURE = false
DISPLAY_HIT_ANIMATION = true
DEBUG_DAMAGE = false
ENABLE_SKILL_DISPLAY = true
ENABLE_MANUAL_SKILL_DISPLAY = true

ENABLE_ENCHANT_EFFECT = true

ENABLE_LOADING_PAGE = false

ENABLE_GRAY = true

IS_DISABLE_UPDATE = true --是否关闭更新


-- 是否允许点击符文
ALLOW_RUNE_CLICK = false

-- 是否要介绍魂师怪
INTRODUCE_HEROIC_MONSTER = true
-- 是否打开自动魂技对话框
ENABLE_AUTOSKILL_DIALOG = true
-- 是否保存回放流格式
ENABLE_STREAM_REPLAY = false
-- 是否自动选中魂师
ENABLE_AUTO_SELECT_HERO = false
-- 微信认证功能启动
ENABLE_WECHAT_VERIFY = false
-- 是否html公告
ENABLE_HTML_ANNOUNCEMENT = true
-- 是否检查服务器版本来强制重启游戏
ENABLE_VERSION_CHECK = true
-- 强行开启所有战斗的加速功能
ENABLE_BATTLE_SPEED_UP = false
-- 开启斗魂场先结算后战斗
ENABLE_ARENA_QUICK_BATTLE = true
-- 开启荣耀斗魂场先结算后战斗
ENABLE_GLORY_ARENA_QUICK_BATTLE = true
-- 开启风暴斗魂场先结算后战斗
ENABLE_STORM_ARENA_QUICK_BATTLE = true
-- 开启银矿战PVP战斗先结算后战斗
ENABLE_SILVERMINE_PVP_QUICK_BATTLE = true
-- 在pvp战斗中开启徽章属性
ENABLE_BADGE_IN_PVP = false
-- 开启QHeroSUtils的内存校验
ENABLE_QHEROSUTILS_VALIDATION = false
-- 开启QStaticDatabase的内存校验
ENABLE_QSTATICDATABASE_VALIDATION = false
-- 是否允许充值
ENABLE_GAME_CHARGE = true
-- 是否开启线下充值
ENABLE_CHARGE_BY_WEB = false
CHARGE_WEB_URL = "http://123.59.76.242/guGTlpfj"
--是否开启装备无框显示
ENABLE_EQUIPMENT_FRAME = false

--是否开启多线程网络通信
NEW_TCP_SOCKET = false

--斗罗渠道编号
DL_CHANNEL_NUMBER = 0
--是否cache UI图片
ENABLE_CACHE_UI_PIC = false

--是否打开局域网对战
ENABLE_LOCAL_NET_BATTLE = false

ENABLE_NEW_UPDATE = false

-- 阅文渠道id
YW_CHANNEL_ID = 0
YW_SUB_CHANNEL_ID = 0

DELIVERY_NAME = QDeliveryWrapper:getDeliveryName()
print("DELIVERY_NAME   :  ",DELIVERY_NAME)

-- 祖时（founder time），即1990-01-01 00:00:00的时间戳（单位毫秒）
FOUNDER_TIME = 631123200000

local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()

PLATFORM_IS_IOS = target == kTargetIphone or target == kTargetIpad
PLATFORM_IS_IPAD = target == kTargetIpad
PLATFORM_IS_ANDROID = target == kTargetAndroid

-- 是否启动充值
ENABLE_CHARGE = function(no_tip)

    if not PLATFORM_IS_ANDROID then
        return true
    else
        -- if QDeliveryWrapper.getDeliveryExtend2 then
        --     local extend = QDeliveryWrapper:getDeliveryExtend2()
        --     local extendTbl = string.split(extend, "|")
        --     local flag 
        --     if type(extendTbl) == "table" then
        --         flag = extendTbl[1]
        --     end

        --     if flag and tostring(flag) == "true" then 
        --         return true
        --     end
        -- end

        -- if not no_tip then
        --     app.tip:floatTip("充值暂未开放!")
        -- end
        -- return false
        return true
    end
end

--是否打开豪华签到
ENABLE_DELUXE_SIGNIN = false
--是否打开等级开启提示
ENABLE_LEVEL_GUIDE = true
--是否打开等级开启宿命
ENABLE_COMBINATION = true
--是否打开首冲奖励
ENABLE_FIRST_RECHARGE = true


-- client mode
GAME_MODE = 1
EDITOR_MODE = 2
ANIMATION_MODE = 3
CURRENT_MODE = QUtility:getLaunchMode()
-- CURRENT_MODE = EDITOR_MODE
if CURRENT_MODE == EDITOR_MODE then
    -- DEBUG_FPS = false
    require("arenadatabase")
end

ENVIRONMENT["Alpha"] = ENVIRONMENT["alpha"]
ENVIRONMENT["Beta"] = ENVIRONMENT["beta"]
ENVIRONMENT["beta2"] = ENVIRONMENT["Beta2"]

local envName = require("environment")
IS_GO = false
-- check is Go
if string.find(envName, "Go") == string.len(envName) - 1 then
    IS_GO = true
    envName = string.sub(envName, 1, string.find(envName, "Go") - 1)
    for _, config in pairs(ENVIRONMENT) do
        config.VERSION_URL = string.sub(config.VERSION_URL, 1, string.len(config.VERSION_URL) - 1).."_go/"
        config.STATIC_URL = string.sub(config.STATIC_URL, 1, string.len(config.STATIC_URL) - 1).."_go/"
        config.SERVER_URL = config.SERVER_URL_GO or config.SERVER_URL
    end
end

local envFile = CCFileUtils:sharedFileUtils():fullPathForFilename("env")
if CCFileUtils:sharedFileUtils():isFileExist(envFile) == true then
    envName = CCFileUtils:sharedFileUtils():getFileData(envFile)
end
local versionFile = CCFileUtils:sharedFileUtils():fullPathForFilename("ver")
if CCFileUtils:sharedFileUtils():isFileExist(versionFile) == true then
    VERSION_URL = CCFileUtils:sharedFileUtils():getFileData(versionFile)
end
--[[
@wkwang
在渠道下面可以配置闪屏和logo图片，在_startGame和pagelogin的时候读取
@showLogo 是否显示logo图片
@channelId 配置渠道ID是多少
@copyright 配置著作权说明 在QUIPageLogin中读取 example:"著作权人：xxxx||出版单位名称:xxx"
@announcementUrl 公告地址 example:"game_11"
@hideAvatar 是否显示avatar人物
]]
CHANNEL_RES = require("channelConfig")
local resFile = CCFileUtils:sharedFileUtils():fullPathForFilename("resConfig")
if CCFileUtils:sharedFileUtils():isFileExist(resFile) == true then
    local json = require("framework.json")
    local data = CCFileUtils:sharedFileUtils():getFileData(resFile)
    local jsonData = json.decode(data)
    if jsonData then
        for k,v in pairs(jsonData) do
            CHANNEL_RES[k] = v
        end
    end
end

assert(envName)

if  envName ~= "alpha" and envName ~= "publish" and envName ~= "beta2" and envName ~= "gong" and envName ~= "li" and 
    envName ~= "tang" and envName ~= "beta2" and envName ~= "pan" and envName ~= "chen" and envName ~= "chw" and envName ~= "nyx" and 
    envName ~= "jian" and envName ~= "peng" and envName ~= "peng2" and envName ~= "lsl" and envName ~= "qjw" then
    DEBUG = 0
    DEBUG_FPS = false
    DEBUG_MEM = false
    DEBUG_NETWORK = false
    DEBUG_DAMAGE = false
    DEBUG_PRINT_LUA_ERROR = false
    DUMP_ALLOCATOR_INFO = false
    LOG_LEVEL = 3
    ENABLE_CHECK_GLOBAL = false
end

-- windows下关闭三个debug开关
if target == kTargetWindows then
    DEBUG_NETWORK = false
    DEBUG_OTHER = false
    DEBUG_PROP = false
end

if PLATFORM_IS_ANDROID or PLATFORM_IS_IOS then
    DEBUG = 0
end

print("[Environment] " .. envName)
-- @qinyuanji, 这个问题为了解决appstore更新的问题
-- 当appstore更新覆盖时，如果writable path下有较老的envConfig，游戏启动就会找不到正确的env，此时就使用默认的配置，version拼接出来
if not ENVIRONMENT[envName] then
    print("Environment " .. envName .. " not exist. Using default config instead")
    ENVIRONMENT[envName] = ENVIRONMENT.default
    VERSION_URL = ENVIRONMENT[envName]["VERSION_URL"] .. envName .. "/"
else
    VERSION_URL = VERSION_URL or ENVIRONMENT[envName]["VERSION_URL"]
end

if nil ~= CHANNEL_RES.envName then
    local revurl = string.reverse(VERSION_URL)
    local pos1 = string.find(revurl,"/")
    local pos2 = string.find(VERSION_URL, "/", pos1 * -1)
    if CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_238" or CHANNEL_RES["envName"] == "dljxol_test") then
        VERSION_URL = string.sub(VERSION_URL, 0, pos2) .. "dljxol_239"
    elseif CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "whjx_239" or CHANNEL_RES["envName"] == "dljxol_test") then
        VERSION_URL = string.sub(VERSION_URL, 0, pos2) .. "whjx_240"
    else
        VERSION_URL = string.sub(VERSION_URL, 0, pos2) .. CHANNEL_RES.envName
    end
end

if PLATFORM_IS_IOS then
    VERSION_URL = VERSION_URL.."_ios/"
elseif PLATFORM_IS_ANDROID then
    VERSION_URL = VERSION_URL.."_android/"
end

CHANNEL_NAME = CHANNEL_NAME or ENVIRONMENT[envName]["CHANNEL_NAME"]
SERVER_URL = SERVER_URL or ENVIRONMENT[envName]["SERVER_URL"]
SERVER_URL_BACK = SERVER_URL_BACK or ENVIRONMENT[envName]["SERVER_URL_BACK"]
SERVER_URL_GO = SERVER_URL_GO or ENVIRONMENT[envName]["SERVER_URL_GO"]
STATIC_URL = STATIC_URL or ENVIRONMENT[envName]["STATIC_URL"]
XMPP_SERVER = XMPP_SERVER or ENVIRONMENT[envName]["XMPP_SERVER"]
LOGINHISTORY_URL = LOGINHISTORY_URL or ENVIRONMENT[envName]["LOGINHISTORY_URL"]
ANNOUNCEMENT_URL = ANNOUNCEMENT_URL or ENVIRONMENT[envName]["ANNOUNCEMENT_URL"]
DISPLAY_VCS = DISPLAY_VCS or ENVIRONMENT[envName]["DISPLAY_VCS"]
POINT_URL = POINT_URL or ENVIRONMENT[envName]["POINT_URL"]  -- 埋点链接地址
ENVIRONMENT_NAME = envName

INFO_APP_UDID = QUtility:getAppUUID()
INFO_PLATFORM = QUtility:getPlatform()
INFO_SYSTEM_VERSION = QUtility:getSystemVersion()
INFO_SYSTEM_MODEL = QUtility:getSystemModel() or ""
INFO_DEVICE_MEMORY = QUtility.getDeviceMemorySizeInMB and QUtility:getDeviceMemorySizeInMB() or 4096

print("INFO_APP_UDID " .. tostring(INFO_APP_UDID))
print("INFO_PLATFORM " .. tostring(INFO_PLATFORM))
print("INFO_SYSTEM_VERSION " .. tostring(INFO_SYSTEM_VERSION))
print("INFO_SYSTEM_MODEL " .. tostring(INFO_SYSTEM_MODEL))
print("INFO_DEVICE_MEMORY " .. tostring(INFO_DEVICE_MEMORY))
print("VERSION_URL " .. tostring(VERSION_URL))
print("POINT_URL" .. tostring(POINT_URL))

IS_64_BIT_CPU = false
if QUtility.is64BitCPU ~= nil then
    IS_64_BIT_CPU = QUtility:is64BitCPU()
end

if INFO_SYSTEM_MODEL == "iPhone4,1" or INFO_SYSTEM_MODEL == "iPhone3,1" or INFO_SYSTEM_MODEL == "iPhone3,2" or INFO_SYSTEM_MODEL == "iPhone3,3" 
    or INFO_SYSTEM_MODEL == "iPod5,1" then
    DISABLE_LOAD_BATTLE_RESOURCES = true
end
ENABLE_CLEAN_TEXTURE_SCHDULER = true

-- 设备相关内存策略
-- UI中贴图分辨率减半
UI_TEXTURE_RESOLUTION_HALF = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY <= 768) or (PLATFORM_IS_IOS and INFO_DEVICE_MEMORY <= 1024)
-- 战斗中贴图（角色和特效）分辨率减半
BATTLE_TEXTURE_RESOLUTION_HALF = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY <= 1536) or (PLATFORM_IS_IOS and not PLATFORM_IS_IPAD and INFO_DEVICE_MEMORY <= 1024)
-- UI中实时清理内存
UI_ENABLE_CLEAN_TEXTURE_SCHEDULER = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY <= 1536) or (PLATFORM_IS_IOS and INFO_DEVICE_MEMORY <= 1024)
-- 战斗中实时清理内存
BATTLE_ENABLE_CLEAN_TEXTURE_SCHEDULER = false
-- 强行把32位的png转换成rgba4444
TEXTURE_FORCE_RGBA4444 = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY <= 1024) or (PLATFORM_IS_IOS and INFO_DEVICE_MEMORY <= 1024)
-- 进入战斗时把主界面的贴图卸载
HIBERNATE_TEXTURE = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY <= 1024) or (PLATFORM_IS_IOS --[[and INFO_DEVICE_MEMORY <= 512]])
HIBERNATE_TEXTURE_2 = false -- do not turn it on !!!
-- 安卓的2G内存和苹果1G内存以上设备cacheUI图片
ENABLE_CACHE_UI_PIC = (PLATFORM_IS_ANDROID and INFO_DEVICE_MEMORY >= 2048) or (PLATFORM_IS_IOS and INFO_DEVICE_MEMORY >= 1024) or (PLATFORM_IS_ANDROID == false and PLATFORM_IS_IOS == false)

-- backward compatible
if isTextureResolutionHalf == nil then
    function isTextureResolutionHalf() return false end
end
if setTextureResolutionHalf == nil then
    function setTextureResolutionHalf(...) end
end
if isTextureForceRGBA4444 == nil then
    function isTextureForceRGBA4444() return false end
end
if setTextureForceRGBA4444 == nil then
    function setTextureForceRGBA4444(...) end
end
if setSpriteCheckInCamera then
    setSpriteCheckInCamera(true)
end
if QDeliveryWrapper.setBuglyTag == nil then
    QDeliveryWrapper.setBuglyTag = function ( ... )
    end
end
if QUtility.getDeviceMemorySizeInMB == nil then
    if INFO_SYSTEM_MODEL == "iPhone4,1" or INFO_SYSTEM_MODEL == "iPhone3,1" or INFO_SYSTEM_MODEL == "iPhone3,2" or INFO_SYSTEM_MODEL == "iPhone3,3" 
        or INFO_SYSTEM_MODEL == "iPod5,1" then
        UI_ENABLE_CLEAN_TEXTURE_SCHEDULER = true
        BATTLE_ENABLE_CLEAN_TEXTURE_SCHEDULER = true
    end
end

--游戏中所有颜色的源头
-- todo Kumo  "ccc3(0, 0, 0), -- 空位" 這表示遊戲裡搜索未被引用的，暫時改成黑色方便QA確認，遊戲2個版本（當前2.4.0）之後刪除
COLORS = {
    -- 深色背景
    a = ccc3(255, 216, 173), -- 普通描述文字，深色背景
    b = ccc3(255, 255, 255), -- 强调描述文字，深色背景
    c = ccc3(183, 246, 83),  -- 增加的属性数字，深色背景
    d = nil, -- 无颜色
    e = ccc3(255, 93, 93),   -- 警示文本字，深色背景
    f = ccc3(165, 165, 165), -- 未激活文本字，深色背景

    -- 淺色背景
    g = ccc3(230, 93, 0), -- 強調描述字II，浅色背景
    h = nil, -- 空位
    i = nil, -- 空位
    j = ccc3(122, 84, 47), -- 普通描述文字，浅色背景
    k = ccc3(85, 37, 7),    -- 强调描述文字，浅色背景；二级标题
    l = ccc3(27, 114, 20),  -- 增加的属性数字，浅色背景
    m = ccc3(182, 16, 16),  -- 警示文本字，浅色背景;聊天紅
    n = ccc3(109, 109, 109), -- 未激活文本字，浅色背景

    o = nil, -- 空位
    p = ccc3(255, 232, 168), -- 仙品升星展示界面用
    q = nil, -- 空位
    r = nil, -- 空位
    s = nil, -- 空位 
    t = ccc3(0, 0, 0), -- 黑
    u = nil, -- 空位
    v = ccc3(0, 255, 0), -- 純绿
    w = ccc3(255, 116, 61), -- 树状图亮线颜色
    x = ccc3(185, 137, 107), -- 树状图暗线颜色
    y = ccc3(255, 216, 173), -- #FFD8AD pvp属性显示使用
    z = nil, -- 空位
    
    -- 品質色
    A = ccc3(255, 255, 255), -- 品质白，暂时与b相同，但是依然单独列出来
    B = ccc3(162, 247, 139), -- 品质绿
    C = ccc3(152, 229, 248), -- 品质蓝
    D = ccc3(254, 147, 255), -- 品质紫
    E = ccc3(255, 170, 95), -- 品质橙
    F = ccc3(255, 131, 131), -- 品质红，暂时与e相同，但是依然单独列出来
    G = ccc3(248, 243, 111), -- 品质金
    H = ccc3(133, 40, 4), -- 橙色描边
    I = nil, -- 空位

    -- 聊天色
    J = ccc3(27, 114, 20), -- 聊天綠
    K = ccc3(7, 101, 178), -- 聊天藍
    L = ccc3(151, 15, 135), -- 聊天紫
    M = ccc3(255, 108, 43), -- 聊天橙
    N = ccc3(182, 16, 16), -- 聊天紅
    O = ccc3(215, 126, 0), -- 聊天黃
    P = ccc3(60, 97, 0), -- 绿色描边
    Q = ccc3(26, 60, 97), -- 蓝色描边
    R = ccc3(105, 18, 105), -- 紫色描边

    -- 特殊作用
    S = ccc3(171, 21, 21), -- 列表按鈕字（亮）
    T = ccc3(163, 95, 54), -- 列表按鈕字（暗）
    U = ccc3(255, 244, 181), -- 副本界面名称（亮）
    V = ccc3(165, 159, 125), -- 副本界面名称（暗）
    W = nil, -- 空位
    X = ccc4(255, 93, 93, 255), -- 小紅線，小助手宗門祭祀設置
    Y = ccc3(45, 19, 0), -- 默认字体描边颜色
    Z = ccc3(131, 215, 246), -- 魂力试炼画线用
}


ANIMATION_EFFECT = {
    VICTORY = "common_victory",
    ULTRA_VICTORY = "common_ultra_victory",
    ULTRA_VICTORY_WITHDELAY = "common_ultra_victory_withdelay",
    WALK = "common_walk",
    DEAD = "common_dead",
    INSTANT_DEAD = "instant_dead",
    COMMON_FADEOUT = "common_fadeout",
    COMMON_FIGHT = "common_fight",
    COMMON_MONSTER_FIGHT = "common_monster_fight",
    COMMON_FADEIN = "common_fadein",
    COMMON_FADEOUT_HALF = "common_fadeout_half",
}

ROOT_BONE = "root"

DUMMY = {
    -- free dummy
    TOP = "dummy_top",
    CENTER = "dummy_center",
    BOTTOM = "dummy_bottom",
    -- move with animation
    BODY = "dummy_body",
    WEAPON = "dummy_weapon",
    WEAPON1 = "dummy_weapon1",
    WEAPON2 = "dummy_weapon2",
    HEAD = "dummy_head",
    FOOT = "dummy_foot",
    LEFT_HAND = "dummy_left_hand",
    RIGHT_HAND = "dummy_right_hand",
    L_HAND = "dummy_l_hand",
    R_HAND = "dummy_r_hand",
}



--装备品质
EQUIPMENT_QUALITY = {
    "white",
    "green",
    "blue",
    "purple",
    "orange",
    "red",
    "yellow",
}

--英雄总览蒙版颜色
HEOR_FRAME_MASK_COLORS = {
    white = ccc3(255, 255, 255),
    green = ccc3(70, 109, 68),
    blue = ccc3(62, 102, 130),
    purple = ccc3(102, 67, 120),
    orange = ccc3(155, 89, 49),
    red = ccc3(137, 48, 48),
    yellow = ccc3(139, 128, 51)
}

ITEM_QUALITY_INDEX = {
    WHITE = 1,
    GREEN = 2,
    BLUE = 3,
    PURPLE = 4,
    ORANGE = 5,
    RED = 6
}



-- 品质色对应描边色，desc自测打印时调用
FONTCOLOR_TO_OUTLINECOLOR = {
    {fontColor = COLORS.B, outlineColor = ccc3(37, 80, 24), desc = "绿"}, -- 绿
    {fontColor = COLORS.C, outlineColor = ccc3(14, 69, 89), desc = "蓝"}, -- 蓝
    {fontColor = COLORS.D, outlineColor = ccc3(122, 3, 123), desc = "紫"}, -- 紫
    {fontColor = COLORS.E, outlineColor = ccc3(133, 40, 4), desc = "橙"}, -- 橙
    {fontColor = COLORS.F, outlineColor = ccc3(139, 0, 0), desc = "红"}, -- 红
    {fontColor = COLORS.G, outlineColor = ccc3(91, 71, 0), desc = "金"}, -- 金
}

--颜色的相互对应值
COLOR_CONTRAST = {
    {colorLight=0xffd8ad, colorDark=0x865537},
    {colorLight=0xffffff, colorDark=0x5a2d11},
    {colorLight=0xb7f653, colorDark=0x1b7214},
    {colorLight=0xff5d5d, colorDark=0xb61010},
    {colorLight=0xa5a5a5, colorDark=0x6d6d6d},
    {colorLight=0x1cec17, colorDark=0x1b7214},
    {colorLight=0x83d7f6, colorDark=0x0765b2},
    {colorLight=0xf67cf7, colorDark=0x970f86},
    {colorLight=0xff6c2b, colorDark=0xff6c2b},
    {colorLight=0xfff000, colorDark=0xd77e00},
}

--品质颜色
QIDEA_QUALITY_COLOR = {
    WHITE = COLORS.A,
    GREEN = COLORS.B,
    BLUE = COLORS.C,
    PURPLE = COLORS.D,
    ORANGE = COLORS.E,
    RED = COLORS.F,
    YELLOW = COLORS.G, 
}

--系统描边文字颜色
QIDEA_STROKE_COLOR = COLORS.Y
QIDEA_STROKE_SIZE = 2

--字体大小
-- QIDEA_FONT_SIZE = {
--     SMALL = 20,       --特殊小文本字体大小
--     NORMAL = 22,      --普通文字大小 列表物品名称
--     SMALL_TITLE = 26，--小标题
-- }

--装备品质
EQUIPMENT_COLOR = {
    QIDEA_QUALITY_COLOR.WHITE, -- white 
    QIDEA_QUALITY_COLOR.GREEN, -- green
    QIDEA_QUALITY_COLOR.BLUE, --blue
    QIDEA_QUALITY_COLOR.PURPLE, --purple
    QIDEA_QUALITY_COLOR.ORANGE, --orange
    QIDEA_QUALITY_COLOR.RED,  -- red
    QIDEA_QUALITY_COLOR.YELLOW  -- yellow
}

--浅色的颜色标准
--白：R：255 G：255 B:255  
--绿：R：74 G:255 B:0  
--蓝色：R：40 G:119 B:234     
--紫：R：196 G：32 B:244 
BREAKTHROUGH_COLOR_LIGHT = {
    white  = QIDEA_QUALITY_COLOR.WHITE, -- white
    green  = QIDEA_QUALITY_COLOR.GREEN, -- green
    blue   = QIDEA_QUALITY_COLOR.BLUE, --blue
    purple = QIDEA_QUALITY_COLOR.PURPLE, --purple
    orange = QIDEA_QUALITY_COLOR.ORANGE, --orange
    red    = QIDEA_QUALITY_COLOR.RED,  -- red
    yellow = QIDEA_QUALITY_COLOR.YELLOW  -- yellow
}

--游戏中统一的颜色值(暗色)
UNITY_COLOR = {
    white = COLORS.b, -- white
    green = COLORS.l, -- green
    blue = COLORS.C, -- blue
    purple = COLORS.D, -- purple
    orange = COLORS.M, -- orange
    red = COLORS.m, -- red
    yellow = COLORS.G, -- yellow
    black = COLORS.t, --black
    brown = COLORS.j, -- normal
    dark = COLORS.k,
    shit_yellow = ccc3(219, 188, 132),
    gray = COLORS.n, -- gray
}

--游戏中统一的颜色值(亮色)
UNITY_COLOR_LIGHT = {
    white = COLORS.A, -- white
    green = COLORS.B, -- green
    blue = COLORS.C,
    purple = COLORS.D, --purple
    orange = COLORS.E, --orange
    red = COLORS.F, --red
    yellow = COLORS.G, --yellow
    gray = ccc3(144, 144, 144), --gray
    ash = ccc3(173, 173, 173),  -- ash
}

--游戏中统一的特殊颜色值(亮色)
GAME_COLOR_LIGHT = {
    normal = COLORS.j, -- 棕
    stress = COLORS.k, -- 棕
    property = COLORS.l, -- 绿
    warning = COLORS.m, --红
    notactive = COLORS.n, --灰
}

--游戏中统一的特殊颜色值(暗色)
GAME_COLOR_SHADOW = {
    normal = COLORS.a, -- 棕
    stress = COLORS.b, -- 白
    property = COLORS.c, -- 绿
    warning = COLORS.e, -- 红
    notactive = COLORS.f, -- 灰
}

CONSUM_MONEY_ID = {
    GOLD_BAR = 8,
    GOLD_BRICK = 9,
    CRYSTAL = 10,
    DIAMOND = 11,
}

HERO_SABC = {
    {aptitude = APTITUDE.SSS, qc = "SSS", lower = "sss", color = "yellow", colour3 = COLORS.G, breakLevel = 24, colorLetter = "m"},
    {aptitude = APTITUDE.SSR, qc = "SS+", lower = "ss+", color = "red", colour3 = COLORS.F, breakLevel = 17, colorLetter = "r"},
    {aptitude = APTITUDE.SS, qc = "SS", lower = "ss", color = "red", colour3 = COLORS.F, breakLevel = 17, colorLetter = "r"},
    {aptitude = APTITUDE.S, qc = "S", lower = "s", color = "orange", colour3 = COLORS.E, breakLevel = 12, colorLetter = "l", soulPrice = 50},
    {aptitude = APTITUDE.AA, qc = "A+", lower = "a+", color = "purple", colour3 = COLORS.D, breakLevel = 7, colorLetter = "k"},
    {aptitude = APTITUDE.A, qc = "A", lower = "a", color = "purple", colour3 = COLORS.D, breakLevel = 7, colorLetter = "k"},
    {aptitude = APTITUDE.B, qc = "B", lower = "b", color = "blue", colour3 = COLORS.C, breakLevel = 2, colorLetter = "a"},
    {aptitude = APTITUDE.C, qc = "C", lower = "c", color = "green", colour3 = COLORS.B, breakLevel = 0, colorLetter = "g"},
}

ITEM_CONFIG_CATEGORY = {
    CONSUM = 1, -- 背包消耗品
    SOUL = 2, -- 背包魂力精魄
    MATERIAL = 3, -- 背包材料
    GEMSTONE = 4, -- 宝石
    GEMSTONE_PIECE = 5, -- 宝石碎片
    GEMSTONE_MATERIAL = 6, -- 宝石消耗品
    MOUNT = 7, -- 坐骑
    MOUNT_PIECE = 8, -- 坐骑碎片
    MOUNT_MATERIAL = 9, -- 坐骑消耗品
    ARTIFACT = 10, -- 神器
    ARTIFACT_PIECE = 11, -- 神器碎片
    ARTIFACT_MATERIAL = 12, -- 神器消耗品
    SPAR = 13, -- 晶石
    SPAR_PIECE = 14, -- 晶石碎片
    MONOPOLY = 15, -- 大富翁内部道具
    MAGICHERB = 16, -- 仙品养成系统
    SOULSPIRIT_PIECE = 18, -- 魂灵碎片
    SOULSPIRIT_CONSUM = 19, -- 魂灵消耗品
    SOULSPIRIT_BOX = 20, -- 魂灵箱子
    GODARM_CONSUM = 21, -- 神器消耗品
    GODARM_PIECE  = 22, -- 神器碎片
    GODARM_BOX = 23, -- 神器箱子    
    FOOD = 24, -- 食物    
}

--item类型
ITEM_TYPE = {
    MONEY = "money",
    TRAIN_MONEY = "trainMoney",
    TOKEN_MONEY = "token",
    ARENA_MONEY = "arenaMoney",
    SUNWELL_MONEY = "sunwellMoney",
    ENERGY = "energy",
    ITEM = "item",
    HERO = "hero",
    HERO_PIECE = "heroPiece",
    TEAM_EXP = "team_exp",
    ACHIEVE_POINT = "achieve_point",
    SWEEP = "sweep",
    GLYPHS = "glyphsMoney",
    VIP = "vip",
    MATERIAL_MONEY = "materialMoney",
    SOULMONEY = "soulMoney",
    TOWER_MONEY = "towerMoney",
    CONSORTIA_MONEY = "consortiaMoney",
    THUNDER_MONEY = "thunderMoney",
    SUMMONCARD_NORMAL = "summonCard_normal", --召唤牌
    SUMMONCARD_ADVANCED = "summonCard_advanced", --召唤牌
    ARCHAEOLOGY_MONEY = "archaeologyMoney",
    INTRUSION_MONEY = "intrusion_money",
    INTRUSION_MTOKEN = "intrusion_token",
    BATTLE_FORCE="battleForce",
    HERO_LEVEL = "hero_level",
    TASK_POINT = "task_point",
    TASKWK_POINT = "taskwk_point",
    SUNWAR_REVIVE_COUNT = "battlefield_revive_times",
    ENCHANT_SCORE = "enchantScore",
    SUMMONCARD_ENCHANT = "summonCard_Enchant",
    SUMMONCARD_MOUNT = "summonCard_Mount",
    VIP_EXP = "vip_exp",
    SOCIATY_CHAPTER_TIMES = "sociaty_chapter_times",
    SILVERMINE_MONEY = "silvermineMoney",
    GEMSTONE_PIECE = "gemstone_piece",
    GEMSTONE = "gemstone",
    SILVERMINE_LIMIT = "silvermine_limit",
    GEMSTONE_ENERGY = "gemstoneEnergy",
    GEMSTONE_EXCHANGE_TOKEN = "601004",
    GLYPH_MONEY = "glyphMoney",
    ZUOQI = "zuoqi",
    SOUL_SPIRIT = "soulSpirit",
    STORM_MONEY = "stormMoney",
    GOLDPICKAXE_TIMES = "huangjinkuanggao_times",
    STORM_EXCHANGE_TOKEN = "4200001",
    UNION_TASK_POINT = "gonghui_huoyue",
    REFINE_MONEY = "refine_money",
    TEAM_MONEY = "teamMoney",
    BLACKROCK_INTEGRAL = "black_rock_integral",
    PLUNDER_TIMES = "gh_ykz_ld_times",
    PLUNDER_SCORE = "gonghui_kuangshi",
    MARITIME_MONEY = "maritimeMoney",
    ARTIFACT = "artifact",
    MARITIME_EXCHANGE_TOKEN1 = "10000003",
    MARITIME_EXCHANGE_TOKEN2 = "10000004",
    TOWER_INTEGRAL = "tower_integral",
    RUSH_BUY_MONEY = "rushBuyMoney",
    RUSH_BUY_SCORE = "rushBuyScore",
    DRAGON_STONE = "11000001",
    DRAGON_SOUL = "11000002",
    DRAGON_EXP = "DRAGON_EXP",
    DRAGON_WAR_MONEY = "dragonWarMoney",
    SANCTUARY_MONEY = "sanctuaryMoney",
    SPAR = "spar",
    SPAR_PIECE = "sparPiece",
    JEWELRY_MONEY = "jewelryMoney",
    TURN_TABLE_CARD = "TURN_TABLE_CARD",
    CALNIVAL_POINTS = "calnival_points",
    CELEBRATION_POINTS = "celebration_points",
    MAGICHERB = "magicHerb",
    MAGICHERB_UPLEVEL = "17100043",
    SUPER_EXP = "99999",
    SUPER_STONE = "14000006",
    POWERFUL_PIECE = "160001",
    PRIZE_WHEEL_MONEY = "prize_wheel_money",
    CRYSTAL_PRIZE = "crystalPiece",
    MOCK_BATTLE_PRIZE = "mock_battle_integral",
    MOCK_BATTLE_MONEY = "mock_battle_money",
    GOD_ARM_MONEY = "godArmMoney",
    RAT_FESTIVAL_MONEY = "ratFestivalMoney",
    CHECK_IN_MONEY = "checkInMoney",
    SOULSPIRIT_XUEJIN = "4300012",
    TAVERN_NORMAL_MONEY = "23",
    TAVERN_ADVANCE_MONEY = "24",
    INHERIT_PIECE = "3599999",
    SKIN_SHOP_ITEM = "1000509",

    SILVESARENA_SHOP_MONEY = "silvesarenasilverMoney",
    SILVESARENA_SHOP_GOLD = "silvesarenagoldMoney",

    MAZE_EXPLORE_ENERGY = "maze_explore_energy",
    MAZE_EXPLORE_MEROY = "maze_explore_memery_piece",
    MAZE_EXPLORE_KEY = "maze_explore_key",

    MUSIC_GAME_NOTE = "1000539",

    MUSIC_GAME_NOTE = "1000539",

    ABYSS_EXCHANGE_TOKEN = "4200002",
}

ITEM_USE_TYPE ={
    OPEN = 1,           -- 随机礼包
    SELECT_OPEN = 2,    -- 多选一礼包
    USE_LINK = 3,       -- 通过 item_use_link 使用
    SELL = 4,           -- 出售
    RECYCLE = 5,        -- 回收
    COMPOSITE = 6,      -- 合成
    OPEN_USE = 7,       -- 打开并使用
    EQUIP = 8,          -- 装备
}

--topbar资源类型
TOP_BAR_TYPE = {
    TOKEN_MONEY = "token",
    MONEY = "money",
    ENERGY = "energy",
    BATTLE_FORCE="battleForce",
    THUNDER_MONEY = "thunderMoney",
    ARENA_MONEY = "arenaMoney",
    INTRUSION_MONEY = "intrusion_money",
    SUNWELL_MONEY = "sunwellMoney",
    SOULMONEY = "soulMoney",
    TOWER_MONEY = "towerMoney",
    CONSORTIA_MONEY = "consortiaMoney",
    SILVERMINE_MONEY = "silvermineMoney",
    BATTLE_FORCE_FOR_LOCAL="battleForceForLocal",
    BATTLE_FORCE_FOR_SUNWAR="battleForceForSunwar",
    BATTLE_FORCE_FOR_SPAR="battleForceForSpar",
    BATTLE_FORCE_FOR_UNIONAR="battleForceForUnionWar",
    ENCHANT_SCORE ="enchantScore",
    GEMSTONE_ENERGY = "gemstoneEnergy",
    GEMSTONE_EXCHANGE_TOKEN = "gemstoneExchangeToken",
    GLYPH_MONEY = "glyphMoney",
    STORM_MONEY = "stormMoney",
    STORM_EXCHANGE_TOKEN = "stormExchangeToken",
    REFINE_MONEY = "refine_money",
    TEAM_MONEY = "teamMoney",
    MARITIME_MONEY = "maritimeMoney",
    MARITIME_EXCHANGE_TOKEN1 = "maritimeExchangeToken1",
    MARITIME_EXCHANGE_TOKEN2 = "maritimeExchangeToken2",
    RUSH_BUY_MONEY = "rushBuyMoney",
    RUSH_BUY_SCORE = "rushBuyScore",
    DRAGON_STONE = "dragon_stone",
    DRAGON_SOUL = "dragon_soul",
    DRAGON_STONE = "DRAGON_STONE",
    DRAGON_SOUL = "DRAGON_SOUL",
    DRAGON_WAR_MONEY = "dragonWarMoney",
    JEWELRY_MONEY = "jewelryMoney",
    SANCTUARY_MONEY = "sanctuaryMoney",
    MAGICHERB_MONEY = "magicherbMoney",
    MAGICHERB_UPLEVEL = "MAGICHERB_UPLEVEL",
    PRIZE_WHEEL_MONEY = "PRIZE_WHEEL_MONEY",
    CRYSTAL_PRIZE = "crystalPiece",
    MOCK_BATTLE_PRIZE = "mock_battle_integral",
    MOCK_BATTLE_MONEY = "mock_battle_money",
    GOD_ARM_MONEY = "godArmMoney",
    RAT_FESTIVAL_MONEY = "ratFestivalMoney",
    CHECK_IN_MONEY = "checkInMoney",
    SOULSPIRIT_XUEJIN = "soulspirit_xuejin",
    TAVERN_NORMAL_MONEY = "TAVERN_NORMAL_MONEY",
    TAVERN_ADVANCE_MONEY = "TAVERN_ADVANCE_MONEY",
    SKIN_SHOP_ITEM = "skin_shop_item",

    SILVESARENA_SHOP_MONEY = "silvesarenasilverMoney",
    SILVESARENA_SHOP_GOLD = "silvesarenagoldMoney",

    MAZE_EXPLORE_ENERGY = "maze_explore_energy",
    MUSIC_GAME_NOTE = "music_game_note",

    ABYSS_EXCHANGE_TOKEN = "abyssExchangeToken",
}





NPC_TYPE = {
    HERO = 1,
    NPC = 2,
    MOUNT = 3,
    GODARM = 5,
}

--进阶的最高级
GRAD_MAX = 5

--一次好友赠送的体力值
FRIEND_GIFT_COUNT = 2

-- 魂骨宝箱商店id
GEMSTONE_SHOP_ID = 160

-- 外附魂骨宝箱商店id
GEMSPAR_SHOP_ID = 10000013

-- 仙品宝箱商店id
MAGIC_HERB_ID = 17100040

-- 
VERSION_NOT_COMPATIBLE = "战报已过期"





--完成事件
EVENT_COMPLETED = "Completed"

EFFECT_ANIMATION = "animation"

--时间换算
MIN = 60
HOUR = 60 * 60
DAY = 24 * 60 * 60
WEEK = 7 * 24 * 60 * 60

--推送通知
NOTIFICATION_12 = "12:00 午间体力豪礼大放送~继续愉快的玩耍起来吧~"
NOTIFICATION_18 = "18:00 晚间体力豪礼大放送~魂师们都跃跃欲试了呢！"
NOTIFICATION_21 = "21:00 深夜体力豪礼大放送~快来游戏战个痛快！"
NOTIFICATION_ENERGY_RECOVERED = "体力全部回复满了~魂师快来继续远征吧~"
NOTIFICATION_SKILL_RECOVERED = "魂技点全部回复满了~快来给魂师们提高战斗力吧！"
NOTIFICATION_STORE_REFRESHED = "商店货物已更新~更多优惠尽在其中，不来看看嘛~"

ACTIVITY_DUNGEON_TYPE = {
    TREASURE_BAY = "activity1_1", -- 藏宝海湾
    BLACK_IRON_BAR = "activity2_1", -- 黑铁酒吧
    STRENGTH_CHALLENGE = "activity3_1", -- 力量试炼
    WISDOM_CHALLENGE = "activity4_1", -- 智慧试炼
}




SDK_ERRORS = {
    SDK_ERROR_CODE_NO_ERROR = 0,
    -- initialize SuperSDK
    SDK_ERROR_CODE_READ_SUPERSDK_PLATFORM_CONFIG_FAILED = 1,
    SDK_ERROR_CODE_SUPERSDK_INITAILIZE_FAILED = 2,
    -- version check
    SDK_ERROR_CODE_NEW_VERSION_OF_GAME = 3,
    SDK_ERROR_CODE_WITHOUT_VERSION_CHECK = 4,
    SDK_ERROR_CODE_CHECK_VERISON_FAILED = 5,
    -- logout
    SDK_ERROR_CODE_LOGOUT_FAILED = 6,
    -- login
    SDK_ERROR_CODE_YOUZU_LOGIN_FAILED = 7,
    SDK_ERROR_CODE_PLATFORM_LOGIN_FAILED = 8,
    -- extra
    SDK_ERROR_CODE_LOGOUT_SUCCESS = 9,
    --大师课堂返回
    SDK_ERROR_CODE_DASHIBACK_SUCCESS = 10,
}

SDK_EVENTS = {
    LOGOUT_WITH_OPEN_OR_NOT_OPEN_LOGIN =  108, --兼容旧版注销用，不知道注销后会不会打开登录页面
    LOGOUT_WITH_NOT_OPEN_LOGIN         = 109, --注销后不会打开登录页面
    LOGOUT_WITH_OPEN_LOGIN             = 110, --注销后会打开登录页面    
}

GAME_EVENTS = {
    -- GAME_EVENT_ENTER_GAME = "0",
    -- GAME_EVENT_CREATE_ROLE = "1",
    -- GAME_EVENT_ROLE_LEVEL_UP = "2",
    -- GAME_EVENT_EXIT_GAME = "3",
    -- GAME_EVENT_ENTER_MAIN_PAGE = "NONE"
    GAME_EVENT_TOKEN_CONSUME = 0, -- 钻石消耗事件
    GAME_EVENT_INIT_ENDED = 1,
    GAME_EVENT_UPDATE_START = 2,
    GAME_EVENT_UPDATE_SUCCESS = 3,
    GAME_EVENT_UPDATE_FAILED = 4,
    GAME_EVENT_ENTER_LOGIN_PAGE = 5,
    GAME_EVENT_ENTER_GAME = 6,
    GAME_EVENT_CREATE_ROLE = 7,
    GAME_EVENT_ENTER_MAIN_PAGE = 8,
    GAME_EVENT_ROLE_LEVEL_UP = 9,
    GAME_EVENT_EXIT_GAME = 10,
    GAME_EVENT_SELECT_SERVER = 11,
    GAME_EVENT_NEW_ROLE_GUIDE = 12,
}

REPORT_TYPE = {
    GLORY_TOWER = "GloryTower",
    ARENA = "Arena",
    SILVERMINE = "SilverMine",
    GLORY_ARENA = "GloryArena",
    STORM_ARENA = "StormArena",  
    PLUNDER = "Plunder",   --宗门矿战
    MARITIME = "Maritime",  
    DRAGON_WAR = "DRAGON_WAR",  
    SPAR_FIELD = "SparField",  
    METAL_CITY = "METAL_CITY",  
    FIGHT_CLUB = "FIGHT_CLUB",  
    SANCTUARY_WAR = "SANCTUARY_WAR",  
    CONSORTIA_WAR = "CONSORTIA_WAR",  
    SOTO_TEAM = "SOTO_TEAM",  
    MOCK_BATTLE = "MOCK_BATTLE",  
    SILVES_ARENA = "SILVES_ARENA",
    SOUL_TOWER = "SOUL_TOWER",
}

BATTLE_NAME = {
    GLORY_TOWER = "荣耀段位赛",
    ARENA = "斗魂场",
    SILVERMINE = "魂兽森林",
    PLUNDER = "极北之地",
    GLORY_ARENA = "荣耀争霸赛",
    STORM_ARENA = "索托斗魂场", 
    MARITIME = "仙品聚宝盆", 
    DRAGON_WAR = "武魂争霸赛", 
    FIGHT_CLUB = "地狱杀戮场",
    SANCTUARY_WAR = "全大陆精英赛",  
    CONSORTIA_WAR = "宗门战",  
    SOTO_TEAM = "云顶之战",  
    MOCK_BATTLE = "大师赛",
    SILVES_ARENA = "西尔维斯"
}

BattleTypeEnum = {
    DUNGEON_NORMAL = "DUNGEON_NORMAL",          --战斗类型-普通副本
    DUNGEON_ELITE = "DUNGEON_ELITE",            --战斗类型-精英副本
    DUNGEON_ACTIVITY = "DUNGEON_ACTIVITY",      --战斗类型-活动副本
    DUNGEON_WELFARE = "DUNGEON_WELFARE",        --战斗类型-史诗副本
    DUNGEON_NIGHTMARE = "DUNGEON_NIGHTMARE",    --战斗类型-噩梦副本
    ARENA = "ARENA",                            --战斗类型-斗魂场
    INTRUSION = "INTRUSION",                    --战斗类型-要塞入侵
    THUNDER = "THUNDER",                        --战斗类型-雷电王座
    THUNDER_ELITE = "THUNDER_ELITE",            --战斗类型-雷电王座精英试炼
    CONSORTIA_BOSS = "CONSORTIA_BOSS",          --战斗类型-宗门副本
    BATTLEFIELD = "BATTLEFIELD",                --战斗类型-战场
    GLORY_TOWER = "GLORY_TOWER",                --战斗类型-荣耀段位赛
    GLORY_COMPETITION = "GLORY_COMPETITION",    --战斗类型-荣耀争霸赛
    SILVER_MINE = "SILVER_MINE",                --战斗类型-宝石矿洞
    STORM = "STORM",                            --战斗类型-风暴竞技场
    WORLD_BOSS = "WORLD_BOSS",                  --战斗类型-要塞BOSS
    BLACK_ROCK = "BLACK_ROCK",                  --战斗类型-熔火组队战
    MARITIME = "MARITIME",                      --战斗类型-海商
    DRAGON_WAR = "DRAGON_WAR",                  --战斗类型-巨龙斗场
    CONSORTIA_WAR = "CONSORTIA_WAR",            --战斗类型-宗门战
    KUAFU_MINE = "KUAFU_MINE",                  --战斗类型-宗门矿战
    SPAR_FIELD = "SPAR_FIELD",                  --战斗类型-晶石幻境
    SANCTUARY_WAR = "SANCTUARY_WAR",            --战斗类型-全大陆精英赛
    SOUL_TRIAL = "SOUL_TRIAL",                  --战斗类型-魂力试炼
    METAL_CITY = "METAL_CITY",                  --战斗类型-金属之城
    FIGHT_CLUB = "FIGHT_CLUB",                  --战斗类型-地狱杀戮场
    DRAGON_TASK = "DRAGON_TASK",                --战斗类型-宗门养龙任务战斗
    SOTO_TEAM = "SOTO_TEAM",                    --战斗类型-云顶之战
    COLLEGE_TRAIN = "COLLEGE_TRAIN",            --战斗类型-训练关
    MOCK_BATTLE = "MOCK_BATTLE",                --战斗类型-大师赛
    TOTEM_CHALLENGE = "TOTEM_CHALLENGE",        --战斗类型-圣柱挑战
    SOUL_TOWER = "SOUL_TOWER",                  --战斗类型-升灵台     
    SILVES_ARENA = "SILVERS_ARENA",             --战斗类型-西尔维斯 
    MAZE_EXPLORE = "MAZE_EXPLORE",              --战斗类型-破碎位面          
    ABYSS = "ABYSS",                            --战斗类型-金属深渊       
}

VIPALERT_TYPE = {
    NOT_ENOUGH = "NOT_ENOUGH",
    OPEN_FUNC = "OPEN_FUNC",
    NO_TOKEN = "NO_TOKEN",
    FIRST_RECHARGE = "FIRST_RECHARGE",
    NO_RUSH_BUY_MONEY = "NO_RUSH_BUY_MONEY",
    NOT_ENOUGH_FOR_SKILL = "NOT_ENOUGH_FOR_SKILL",
}

VIPALERT_MODEL = {
    ARENA_REFRESH_COUNT = 1,
    ARENA_RESET_COUNT = 2,
    BAR_MAX_COUNT = 3,
    SEA_MAX_COUNT = 4,
    STENGTH_MAX_COUNT = 5,
    INTELLECT_MAX_COUNT = 6,
    INVASION_TOKEN_BUY_COUNT = 7,
    BUY_VIRTUAL_MONEY_COUNT = 8,
    BUY_VIRTUAL_ENERGY_COUNT = 9,
    PTSHOP_LIMIT_COUNT = 10,
    GNSHOP_LIMIT_COUNT = 11,
    YLSHOP_LIMIT_COUNT = 12,
    HSSHOP_LIMIT_COUNT = 13,
    TOWER_BUY_COUNT = 14,
    RESET_ELITE_COUNT = 15,
    SUNWAR_BUY_REVIVECOUNT = 16,
    SOCIETYDUNGEON_BUY_FIGHTCOUNT = 17,
    SILVERMINE_BUY_FIGHTCOUNT = 18,
    GLORY_ARENA_REFRESH_COUNT = 19,
    GLORY_ARENA_RESET_COUNT = 20,
    STORM_ARENA_REFRESH_COUNT = 19,
    STORM_ARENA_RESET_COUNT = 20,
    SILVERMINE_BUY_GOLDPICKAXECOUNT = 23,
    BLACKROCK_BUY_AWARDS_COUNT = 24,
    PLUNDER_BUY_LOOTCOUNT = 25,
    MARITIME_BUY_LOOTCOUNT = 26,
    MARITIME_BUY_TRANSPORT_COUNT = 27,
    WORLDBOSS_BUY_COUNT = 28,
    DRAGONWAR_BUY_COUNT = 29,
    SOTO_TEAM_REFRESH_COUNT = 30,
    SOTO_TEAM_RESET_COUNT = 31,
}

DROP_TYPE = {
    NORMAL_ITEM = 1,
    COMPOSE_ITEM = 2,
    RESOURCE_ITEM = 3
}


SHOP_ID = {
    generalShop = "1",                      -- 普通商店
    goblinShop = "2",                       -- 地精商店
    blackShop = "3",                        -- 黑市商店
    arenaShop = "4",                        -- 斗魂场商店
    sunwellShop = "5",                      -- 太阳井商店
    itemShop = "201",                       -- 道具商城 
    vipShop = "301",                        -- vip商城
    weekShop = "701",                       -- 每周礼包商城
    soulShop = "501",                       -- 魂师商店
    gloryTowerShop = "101",                 -- 魂师大赛商店
    gloryTowerFreeShop = "401",             -- 魂师大赛免费商店
    consortiaShop = "601",                  -- 宗门商店
    thunderShop = "91",                     -- 雷电王座商店       
    invasionShop = "1001",                  -- 叛军商店    
    arenaAwardsShop = "40000",              -- 斗魂场奖励商店
    sunwellAwardsShop = "50000",            -- 太阳井奖励商店
    gloryTowerAwardsShop = "1010000",       -- 魂师大赛奖励商店
    gloryTowerArenaAwardsShop = "1020000",  -- 魂师大赛争霸赛奖励商店
    consortiaAwardsShop = "6010000",        -- 宗门奖励商店
    thunderAwardsShop = "910000",           -- 雷电王座奖励商店
    invationAwardsShop = "10010000",        -- 要塞奖励商店
    silverShop = "801",                     -- 银矿战商店
    silverAwardsShop = "10020000",          -- 银矿战奖励商店
    metalCityShop = "802",                  -- 风暴斗魂场商店
    metalCityAwardsShop = "10030000",       -- 风暴斗魂场奖励商店
    blackRockShop = "808",                  -- 黑石商店
    blackRockAwardsShop = "10040000",       -- 黑石奖励商店
    artifactShop = "901",                   -- 武魂真身商店
    artifactAwardsShop = "10100000",        -- 武魂真身奖励商店
    rushBuyShop = "804",                    -- 夺宝商店
    dragonWarShop = "805",                  -- 龙战商店
    dragonWarAwardsShop = "10070000",       -- 龙战奖励商店
    sparShop = "806",                       -- 晶石商店
    sparAwardsShop = "10080000",            -- 晶石奖励商店
    sanctuaryShop = "807",                  -- 全大陆精英赛商店
    sanctuaryAwardsShop = "10300000",       -- 全大陆精英赛奖励商店
    crystalShop = "809",                    -- 水晶商店
    mockbattleShop = "810",                 -- 大师赛商店
    mockbattleAwardsShop = "10400000",      -- 大师赛奖励商店
    godarmShop = "811",                     -- 神器商店
    godarmAwardsShop = "10500000",          -- 神器奖励商店、
    monthSignInShop = "812",                -- 签到商店
    skinShop = "813",                       -- 皮肤商店
    silvesShop = "814",                     -- 希尔维斯商店
    silvesAwardShop = "10600000",           -- 希尔维斯奖励商店
    highTeaShop = "815",                    -- 食材商店
    musicShop = "816",                      -- 音浪商店
    EnchantSynShop = "817",                 -- 觉醒饰品合成

}

QUICK_LOGIN = {
    isQuick = false,
    osdkUserId = "0060023_s57244f23b89c6",
    gameArea = "f2289310004",
    deviceModel = "test by inside",
    deviceId = "88888888"
}

--银矿战类型
SILVERMINEWAR_TYPE = {
    NORMAL = 1,
    SENIOR = 2,
}

--矿品质类型
SILVERMINE_TYPE = {
    DIAMOND = 7, --钻石
    RICH_GOLD = 6, --富金
    GOLD = 5, --金
    RICH_SILVER = 4, --富银
    SILVER = 3, --银
    COPPER = 2, --铜
    IRON = 1, --铁
}

--占领类型
LORD_TYPE = {
    NORMAL = 1, --非宗门成员
    SOCIETY = 2, --宗门成员
    BOSS = 3, --怪物
    SELF = 4, --自己
    OTHER = 5, --非自己，包括NORMAL、SOCIETY、BOSS
}



--魂师职业类型
HERO_TALENT = {
    TANK = 1, --防御
    DPS_PHYSISC = 2, --物理攻击
    DPS_MAGIC = 3, --法术攻击
    HEALTH = 4, --治疗
}

--xurui: 每天只显示一次类型
DAILY_TIME_TYPE = {
    REBORN = "REBORN", --重生殿
    BACKPACK = "BACKPACK", --背包
    ACTIVITYGROUPBUY = "ACTIVITYGROUPBUY",
    WORLDBOSS = "WORLDBOSS", --世界BOSS
    UNION_PLUNDER = "UNION_PLUNDER", --宗门矿战
    MONTH_FUND = "MONTH_FUND",
    WEEK_FUND = "WEEK_FUND",   --周基金未激活小红点
    NEW_SERVICE_FUND = "NEW_SERVICE_FUND",  --新服基金未激活小红点
    RUSH_BUY = "RUSH_BUY",
    GOLE_CHEST = "GOLE_CHEST",                  -- 酒馆豪华召唤
    GOLE_CHEST_HALF = "GOLE_CHEST_HALF",        -- 酒馆豪华召唤半价
    MOUNT_ORIENT = "MOUNT_ORIENT",              -- 坐骑宝箱召唤
    ENCHANT_ORIENT = "ENCHANT_ORIENT",          -- 觉醒宝箱召唤
    MARITIME_REFRESH = "MARITIME_REFRESH",      -- 海商刷新船只
    MARITIME_ISBEST_REFRESH = "MARITIME_ISBEST_REFRESH",  --仙品等级已经最大提示
    MARITIME_ISLAST_REFRESH = "MARITIME_ISLAST_REFRESH",  --仙品等级已经最低提示
    TURN_TABLE = "TURN_TABLE",                  -- 豪华转盘召唤
    NIGHTMARE = "NIGHTMARE",                  -- 噩梦副本
    ACTIVITY_SEVEN_CONSUME = "ACTIVITY_SEVEN_CONSUME",          -- 7、14日活动半价抢购
    ACTIVITY_SEVENDAY_ENTRY = "ACTIVITY_SEVENDAY_ENTRY",          -- 7、14日登录
    ACTIVITY_FIRST_RECHARGE = "ACTIVITY_FIRST_RECHARGE",          -- 首冲
    ACTIVITY_FOR_FORCE = "ACTIVITY_FOR_FORCE",                   -- 开服竞赛
    ACTIVITY_JIANIANHUA = "ACTIVITY_JIANIANHUA",                   -- 嘉年华    
    ACTIVITY_FOR_REPEATPAY = "ACTIVITY_FOR_REPEATPAY", -- 7、14日活动连续充值
    ACTIVITY_FOR_WEEK = "ACTIVITY_FOR_WEEK", -- 7、14周礼包
    ACTIVITY_MONTH_FUND = "ACTIVITY_MONTH_FUND", -- 268月基金宣传图弹脸
    ACTIVITY_MONTH_FUND_2 = "ACTIVITY_MONTH_FUND_2", -- 168月基金宣传图弹脸
    ACTIVITY_WEEK_FUND = "ACTIVITY_WEEK_FUND", -- 周基金宣传图弹脸
    ACTIVITY_NEWSERVICE_FUND = "ACTIVITY_NEWSERVICE_FUND", -- 新服基金宣传图弹脸
    SHOW_MASTER_TIP = "SHOW_MASTER_TIP", --成长大师tip
    MONOPOLY = "MONOPOLY", --大富翁tip
    SANCTUARY_TIPS = "SANCTUARY_TIPS", --精英赛tip
    SANCTUARY_ANNOUNCE = "SANCTUARY_ANNOUNCE", --精英赛通告
    USERCOMEBACK = "USERCOMEBACK", -- 老玩家回归
    SECRETARY = "SECRETARY", -- 小屋助手
    FORGE_BEST_HAMMER = "FORGE_BEST_HAMMER", -- 铸造昊天锤提醒
    SOUL_LETER_ACTIVE_ELITE = "SOUL_LETER_ACTIVE_ELITE", -- 魂师手札激活精英提示
    IOS_BINDING_PHONE = "IOS_BINDING_PHONE", -- 魂师手札激活精英提示
    MONOPOLY_YJZSZ_BUYNUM = "MONOPOLY_YJZSZ_BUYNUM",  -- 一键掷骰子购买次数
    FIRST_RECHARGE_POSTER = "FIRST_RECHARGE_POSTER",  -- 新首冲彈臉
    MAGICHERB_MAX_COUNT = "MAGICHERB_MAX_COUNT",  -- 仙品最大拥有量提示
    UNION_DUNGEON_MAX_TIP = "UNION_DUNGEON_MAX_TIP",  -- 宗门副本通过最大章节每日提示
    SILVES_ARENA = "SILVES_ARENA",  -- 西尔维斯
    SILVES_ARENA_OPEN_DOOR = "SILVES_ARENA_OPEN_DOOR",  -- 西尔维斯战斗期每天开门
    SOUL_SPIRIT_AWAKEN = "SOUL_SPIRIT_AWAKEN",  -- 魂灵觉醒
    SOUL_SPIRIT_INHERIT = "SOUL_SPIRIT_INHERIT",  -- 魂灵传承
    MOUNT_REFORM = "MOUNT_REFORM",  -- 暗器改良
    MOUNT_MAILL = "MOUNT_MAILL",  -- 暗器商城宝箱
    HANDBOOK = "HANDBOOK",  -- 魂师图鉴
}

FIRST_RECHARGE_TIPS = {
    LEVEL_ONE = "FIRST_RECHARGE_TIPS_ONE",
    LEVEL_TWO = "FIRST_RECHARGE_TIPS_TWO",
}

-- Kumo: 游戏功能模块 用于阵容预览
GAME_MODEL = {
    NORMAL = 1,
    SUNWAR = 2,
    STORM = 3,
    SILVERMINE = 4,
    AERNA = 5,
    GLORYTOWER = 6,
    MOCKBATTLE = 7,
}

--宗门战页码
PAGE_NUMBER = {
    ONE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
}

--矿品质类型
PLUNDER_TYPE = {
    DIAMOND = 7, --钻石
    RICH_GOLD = 6, --富金
    GOLD = 5, --金
    RICH_SILVER = 4, --富银
    SILVER = 3, --银
    COPPER = 2, --铜
    IRON = 1, --铁
}

CHANNEL_TYPE = {
    GLOBAL_CHANNEL = 1,
    UNION_CHANNEL = 2,
    PRIVATE_CHANNEL = 3,
    TEAM_CHANNEL = 4,
    TEAM_INFO_CHANNEL = 5,
    USER_DYNAMIC_CHANNEL = 6,
    TEAM_SILVES_CHANNEL = 7, -- 希尔维斯组队聊天
    TEAM_CROSS_CHANNEL = 8,  -- 希尔维斯跨服聊天
}

CHAT_CHANNEL_INTYPE = {
    CHANNEL_IN_NORMAL = 1,
    CHANNEL_IN_SILVES = 2,
}

SEND_PUSH_MESSAGE_TYPE = {
    SILVES_ARENA_MEMBER_JOIN     =  "SILVES_ARENA_MEMBER_JOIN",
    SILVES_ARENA_MEMBER_QUIT     =  "SILVES_ARENA_MEMBER_QUIT",
    SILVES_ARENA_MEMBER_KICKED   =  "SILVES_ARENA_MEMBER_KICKED",
    SILVES_ARENA_MEMBER_CHAT     =  "SILVES_ARENA_MEMBER_CHAT",
}

ALERT_TYPE = {
    CONFIRM = "confirm",
    CANCEL = "cancel",
    CLOSE = "close",
    CONFIRM_RED = "confirm_red",
}
ALERT_BTN = {
    BTN_OK = "btn_ok",
    BTN_CLOSE = "btn_close",
    BTN_OK_RED = "btn_ok_red",
    BTN_CANCEL = "btn_cancel",
    BTN_CANCEL_RED = "btn_cancel_red",
}

HERO_FUNC_TYPE = {
    TANK = 1,
    HEALTH = 2,
    DPS_P = 3,
    DPS_M = 4,
}

HERO_FUNC_TYPE_DESC = {
    TANK = "t",
    HEALTH = "health",
    DPS = "dps",
    DPS_M = "dps_m",
    DPS_P = "dps_p",
}

LEVEL_GOAL = {
    MAIN_MENU = 1,
    UNION = 2,
}

ENTERGAME_LOADING_ANI = {name = "fca/chengnianxiaowu",animation = "walk2",offset = 0,scale = 0.12}

SEND_MSG_LOADING_ANI = {name = "fca/chengnianxiaowu",animation = "loading",offset = 0,scale = 0.1}

YUXIAOGANG_QUESTION_ANI = {name = "fca/yuxiaogang2",animation = "stand",offset = 0,scale = 0.13}

TAVERN_SHOW_HERO_CARD = {
    SILVER_TAVERN_TYPE = "SILVER_TAVERN_TYPE",
    GOLD_TAVERN_TYPE = "GOLD_TAVERN_TYPE",
    ORIENT_TAVERN_TYPE = "ORIENT_TAVERN_TYPE",
}

SHIELDS_TYPE = {
    HERO = 1,           -- 魂师
    HERO_PIECE = 2,     -- 魂师碎片
    HERO_ENCHANT = 3,   -- 魂师武器附魔
    HERO_ARTIFACT = 4,  -- 魂师武魂真身
    HEAD_DEFAULT = 5,   -- 头像id
    PUBLICITY_MAP = 6,  -- 宣传图id
    GAME_LOAD = 7,      -- 加载图
    MOUNT = 8,          -- 暗器
    MOUNT_PIECE = 9,    -- 暗器碎片
    ITEM = 10,          -- 特殊道具
    SKIN_ID = 11,       -- 皮肤ID
    SOUL_SPIRIT = 12,   -- 魂灵
    SOUL_SPIRIT_PIECE = 13,   -- 魂灵碎片
    MOUNT_COMBINATION = 14, --暗器图鉴
}

-- 宗門職位
SOCIETY_OFFICIAL_POSITION = {
    BOSS = 9, -- 老大
    ADJUTANT = 8, -- 副官
    ELITE = 4, -- 精英
    MEMBER = 2, -- 成員
}

TASK_SYSTEM_TYPE = {
    SOUL_LETTER_TASK = "SOUL_LETTER_TASK",                   --魂师手札任务系统
    TRAILER_TASK = "TRAILER_TASK",                           --新功能預告任务系统
}

FAST_FIGHT_TYPE = {
    RANK_FAST = 1,      --排名玩法扫荡
    DUNGEON_FAST = 2,   --副本类型扫荡
    BOSS_FAST   = 3,    --boss类型扫荡
    METALCITY_FAST = 4, --金属之城扫荡
}

GEMSTONE_MAXADVANCED_LEVEL = 25                     --  魂骨进阶最大等级
S_GEMSTONE_MAXEVOLUTION_LEVEL = 21                     --  S魂骨突破最大等级 需要进阶才可继续突破

UNION_DUNGEON_MAX_BOSS_OPACITY = 170                     --宗门副本无限血量boss透明度

NATIVE_VERSION_CODE = {}
local version = QUtility:getNativeCodeVersion()
local major, minor, revision
local index1 = string.find(version, ".", 1, true)
local index2 = string.find(version, ".", index1 + 1, true)
major = tonumber(string.sub(version, 1, index1 - 1))
minor = tonumber(string.sub(version, index1 + 1, index2 - 1))
revision = tonumber(string.sub(version, index2 + 1))

NATIVE_VERSION_CODE.version = version
NATIVE_VERSION_CODE.major = major
NATIVE_VERSION_CODE.minor = minor
NATIVE_VERSION_CODE.revision = revision

--异形屏适配版本号
FULL_SCREEN_ADAPTATION_VERSION = {
    major = 1,
    minor = 5,
    revision = 4
}

--VIVO游戏中心sdk版本好
VIVO_GAMECENTER_ADAPTATION_VERSION = {
    major = 1,
    minor = 5,
    revision = 7
}


--OPPO游戏中心sdk版本好
OPPO_GAMECENTER_ADAPTATION_VERSION = {
    major = 1,
    minor = 5,
    revision = 9
}

--通知后端推送场景类型
SceneEnum = {
    SCENE_WORLD_BOSS = "SCENE_WORLD_BOSS",
}


SILVES_ARENA_CHAT_TYPE = {
    SILVERS_ARENA_GLOBAL = "SILVERS_ARENA_GLOBAL",
    SILVERS_ARENA_TEAM_SHARE = "SILVERS_ARENA_TEAM_SHARE",
    SILVERS_ARENA_TEAM = "SILVERS_ARENA_TEAM",
}

-- 分享类型
SHARE_IMAGE_TYPE = {
    WECHAT = 1,--微信
    MOMENT = 2,--朋友圈
    TENCENTQQ = 3,--qq
    QZONE = 4,--QQ空间
    WEIBO = 5,--微博
}

-- 破碎位面格子状态
GridStatus = {
    DEFAULT = "DEFAULT", 
    OPEN = "OPEN",
    INVALID = "INVALID",
}

