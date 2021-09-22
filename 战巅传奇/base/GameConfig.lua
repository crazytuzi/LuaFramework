
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- design resolution
CONFIG_SCREEN_WIDTH  = 1136
CONFIG_SCREEN_HEIGHT = 640

DESIGN_WIDTH = 1136
DESIGN_HEIGHT = 640

-- auto scale mode
-- CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"

function get_autoscale()
    local autoscale = "FIXED_HEIGHT";
    local ratio = DESIGN_WIDTH / DESIGN_HEIGHT
    if ratio <= 1.34 then
        -- iPad 768*1024(1536*2048) is 4:3 screen
        autoscale = "FIXED_WIDTH"
    end
    return autoscale;
end

CONFIG_SCREEN_AUTOSCALE = get_autoscale()

---------------------------------------------------
CONFIG_CENTER_URL=""


TILE_WIDTH = 66
TILE_HEIGHT = 44

FONT_NAME = "image/typeface/game.ttf"
cc.SystemUtil:setDefaultFont(FONT_NAME)

PLATFORM_BANSHU = false
PLATFORM_MILI_LOGIN = true;  --自有渠道，自己做的登录。接入第三方sdk，这边要设置为false

GAME_TEST_SERVERS={
  {
    id=4990,
    serverId=9999,
    name="删档测试",
    zoneName="删档测试",
    zoneNumber="8001",
    serial=1,
    sequence=1,
    socket="127.0.0.1:7863",
    --loginCallback="http://127.0.0.1/cqlogin.php",
	loginCallback="http://cdn.niuonline.cn/app/cglogin.php",
    renameUrl="http://127.0.0.1/app/rename.php",
    giftUrl="http://cdn.niuonline.cn/app/actgift.php",
    status=1,
    isNew=1,
    isHot=1,
    openDateTime="2018-01-26 11:00:00",
    checkDate=1
  },
}


function set_fps(fps)
	cc.SystemUtil:setRenderFps(fps)
	CONFIG_FPS=fps
	cc.Director:getInstance():setAnimationInterval(1.0 / CONFIG_FPS)
end
set_fps(40)


--[[
    enum class Platform
    {
        OS_WINDOWS,/** Windows */
        OS_LINUX,/** Linux */
        OS_MAC,/** Mac*/
        OS_ANDROID,/** Android */
        OS_IPHONE,/** Iphone */
        OS_IPAD,/** Ipad */
        OS_BLACKBERRY,/** BLACKBERRY */
        OS_NACL,/** Nacl */
        OS_EMSCRIPTEN,/** Emscripten */
        OS_TIZEN,/** Tizen */
        OS_WINRT,/** Windows Store Applications */
        OS_WP8/** Windows Phone Applications */
    };
]]

if cc.Application:getInstance():getTargetPlatform() == 0 then  --windows系统
	CONFIG_TEST_IP="127.0.0.1"
	CONFIG_TEST_PORT="7863"
	CONFIG_TEST_MODE=true
	DEBUG_FPS = true
else
	DEBUG = 0
	DEBUG_FPS = false
end

GROUP_TYPE = {
    CLOTH=0,  --衣服
    WEAPON=1, --武器
    MOUNT=2,  --坐骑
    WING=3,   --翅膀
    EFFECT=4,  --特效
	FDRESS=5,  --时装
	FABAO=6,    --
	CLOTH_REVIEW=7,  --装备内观
	WEAPON_REVIEW=8,  --武器内观
	FDRESS_REVIEW=9,   --时装内观
	CELL_REVIEW=10,    --动态格子
	TITLE=11,    --动态称号
	WING_REVIEW=12,    --翅膀内观
};