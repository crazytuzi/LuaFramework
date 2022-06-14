--wz
function handleUIWorldPosTick(dt)
end	
include = function (...)
	print(...)
	return require(...)
end


math.PI					= 3.14159265358979323846264338327950288419716939937511 --math.pi
math.PI_DIV2			= math.PI * 0.5
math.PI_2 = math.PI * 2;

math.SQUARER3			= 1.7320508075689
--定义枚举总table
enum = {};

OPEN_GUIDE  = true

include("bitExtend")
include("json")
include("xml")
include("functions")
include("debugs")
include("engine")
include("resManager")
include("scheduler")
include("uiaction")
include("event")
include("eventManager")
--include("enum")
include("networkcommon")
include("enumUserDefine")
include("layout")
include("layoutManager")
include("scheduler")
include("sceneManager")
include("dataConfig")
include("objectManager")
include("cropData")
--include("map")
include("homeland")
include("instanceScene")
include("limitedActivityBase")
include("limitedActivityNull")
include("limitedActivityChapter")
include("limitedActivityEquipEnhance")
include("limitedActivityGoldLevel")
include("limitedActivityKingLevel")
include("limitedActivityPvpOffline")
include("limitedActivityPvpOnline")
include("limitedActivityUnitCount")
include("limitedActivityAllRecharge")
include("limitedActivityDiamondCost")
include("limitedActivityLimitRecharge")
include("limitedActivityTab")
include("limitedActivityData")
include("crusadeActivityData")
include("speedChallegeRankData")
include("buyResPriceData")
include("activityInfoData")
include("dataManager")
include("buffer")
include("battleDistance")
include("battleRecord")
include("castMagic")
include("battleprepareData")
include("unitsinbagData")
include("cropsUnit")
include("skill")
include("attackCallback")
include("battlePlayer")
include("battleText")
include("battlePrepareScene")
include("item")
include("sendHelper")
include("global")
include("hpMonitor")
include("report")
include("packetMap")
include("guide")
include("sdk")
include("displayCardLogic")
include("homelandUnit")
include("homelandUnitState")
include("homelandUnitStateIdle")
include("homelandUnitStateWin")
include("homelandUnitStateMove")
include("homelandUnitStateSkill")
include("uiframe")
include("uianimate")
include("chatRecord")
include("imageSprite")
include("moneyFlyObject")
include("displayFuli")

local _AutopacketHandler  = packetHandler

function packetHandler(packetID)
	_AutopacketHandler(packetID)
	global.OnpacketHandler(packetID)
end



DEBUG = 1
DEBUG_FPS = true
DEBUG_MEM = false


DEBUG_MUSIC_OPEN = true


CONFIG_SCREEN_WIDTH = 960
CONFIG_SCREEN_HEIGHT = 640
MAIN_TICK_INTERVAL = 0.05

CHECK_LOCK_TIME = 5
DEBUG_GAME_MODE = true

PLAYER_NAME_MAX_SIZE = 14 --- 14个字节

INSTANCE_JUMP_STEP = 11

INSTANCESCENE_STAGE_OFFSET_X = 0
INSTANCESCENE_STAGE_OFFSET_Y = 0

----飞船飞起
INSTANCESCENE_STAGE_flyUpAirshipSpeed = 3 -- 速度1
INSTANCESCENE_STAGE_flyUpAirshipTime = 0.8 -- 3s

INSTANCESCENE_STAGE_flyDownAirshipSpeed = 3 -- 速度1
INSTANCESCENE_STAGE_flyDownAirshipTime = 0.8 -- 3s

INSTANCESCENE_STAGE_ACTOR_ACRION_Time = 10-- 10s
INSTANCESCENE_STAGE_ACTOR_ACRION_WinTime = 4.5-- 4.5s

INSTANCESCENE_STAGE_MAX_HEIGHT = 20-- 
INSTANCESCENE_STAGE_MINHEIGHT = 5--  

INSTANCESCENE_STAGE_SCALE_RATE = 19 


FTP_URL =  "ftp://ftp1:20140512@163.177.178.234:21/test1/record/"-- "ftp://tt:123456@192.168.1.106/" 


GLOBAL_CONFIG_BLOCK_VIP = false;

if type(DEBUG) ~= "number" then DEBUG = 1 end


SPEED_UP_GAME = {1.7,2.2,3.4}
UNIT_ICON_SATRT_INDEX = 1000
PACKET_TIP_WAIT_TIMR = 1

--echoInfo("# DEBUG                        = "..DEBUG)

local function showMemoryUsage()
   -- echoInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
	--local str = string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count"))
	--eventManager.dispatchEvent( {name = global_event.TEST_UPDATE, vm = str} )
	--print(str)
end

if DEBUG_MEM then 
    --scheduler.scheduleGlobal(showMemoryUsage,5)
end	