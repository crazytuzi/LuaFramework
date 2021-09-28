game = {}
require "src/PreloadHeader"
require "src/net/NetMsgDispacher"
require "src/TimeProfile"
g_font_path = "fonts/msyh.ttf"
cclog = function(...)
    if _G_NO_DEBUG then return end
        print(string.format(...))
    
    --  local pFile =  io.open("logfile.log","a")
    --   if pFile then
    --       pFile:write(string.format(...).."\n")
    --       pFile:close()
    --   end  
end
log = cclog
local function loadFiles()
    require("src/tools")
    require "src/AudioPlay"
    require "src/config/Debug"
    require "src/config/FontColor"
    require "src/MultiHandler"
    
    require "src/CommonFunc"
    require "src/CommonDefine"
end

-- G_ROLE_MAIN = nil
-- userInfo = {}
-- G_TEAM_INFO = {}
-- G_FACTION_INFO = {}
-- G_CHAT_INFO={}
-- G_MAIL_INFO={}
-- g_TestHandler = {}
-- g_EventHandler = {}

Director = cc.Director:getInstance()
TextureCache = Director:getTextureCache()

--网络分发实例
g_msgHandlerInst = require("src/net/NetMsgHandler").new()
g_scrSize = Director:getWinSize()
g_scrCenter = cc.p(g_scrSize.width/2, g_scrSize.height/2)
require "src/layers/pay/PayMsg"

local qqVipQueryed = false

testHander = function(msgid,...)
    if g_TestHandler[msgid] then 
       g_TestHandler[msgid](...)
    end
end

function checkBackgroundTime(isBegain)
    G_Background = G_Background or {}
    if isBegain == 1 then
        G_Background.BegainTime = os.time()
        G_Background.BegainTimestr = os.date("%H:%M:%S", G_Background.BegainTime)
    else
        G_Background.EndTime = os.time()
        G_Background.EndTimestr = os.date("%H:%M:%S", G_Background.EndTime)
    end
    G_Background.isBegain = isBegain
    --dump(G_Background, "checkBackgroundTime .. G_Background")

    if 1 ~= isBegain then
        if G_Background then
            if G_Background.BegainTime and G_Background.EndTime and G_Background.BegainTime ~= 0 then
                if G_Background.EndTime - G_Background.BegainTime > 20 * 60 then
                    G_Background.BegainTime = 0
                    G_Background.EndTime = 0

                    local luaEventMgr = LuaEventManager:instance()
                    local mbuff = luaEventMgr:getLuaEventEx(2012)
                    LuaSocket:getInstance():sendSocket(mbuff)
                    game.ToLoginScene()
                else
                    G_Background.BegainTime = 0
                    G_Background.EndTime = 0
                end
            end
        end
    end
end

function globalInit(reset)
    --注册pb文件，用于协议解析
    g_msgHandlerInst:registerPB()

    require("src/PandoraFunction")
    PandoraCloseAllDialog()
    G_PandoraIconState = {pandoraOn = false, iconShow = false, flagShow = false}
    
    if G_ROLE_MAIN then
        local lv = MRoleStruct:getAttr(ROLE_LEVEL)
        if g_roleTable and #g_roleTable > 0 then
            for k,v in pairs(g_roleTable)do
                if v["RoleID"] == userInfo.currRoleStaticId then
                    v["Level"] = lv
                end
            end
        end
        G_ROLE_MAIN = nil
    end
    G_TOP_STATE = {}
    __TASK = nil
    __TOPS = {}
    if userInfo and userInfo.sweepTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(userInfo.sweepTimer) 
    end
    local tempID = userInfo and userInfo.serverId or nil
    local tempSessionToken = userInfo and userInfo.sessionToken or nil
    userInfo = {}
    userInfo.isReconn = nil
    userInfo.noNetTransforTime = 0
    userInfo.serverId = tempID
    userInfo.sessionToken = tempSessionToken
    userInfo.pingNum = math.random(5, 50)
    
    G_TEAM_INFO = {}
    G_TEAM_APPLYRED = {false,nil,nil}
    G_TEAM_INVITE = {}
    G_TEAM_TARGET = 1
    G_TEAM_ATUOTURN = {true,false,0}

    G_OFFLINE_DATA = {}
    G_OFFLINE_DATA.couldGotoNext = false
    
    --退出实时语聊
    if G_FACTION_INFO ~= nil and G_FACTION_INFO.isInRealVoiceRoom then
        cclog("yuexiaojun game VoiceApollo:onExitRoom")
        VoiceApollo:onExitRoom()
    end

    VoiceApollo:SetUploadDoneCallback(0)
    require("src/layers/chat/ChatRealOpenNoticeNode"):resetRecord()

    G_FACTION_INFO = {StartFbId = -1}
    G_FACTION_INVITE_DATA = {}
    G_CHAT_INFO={}
    G_MAIL_INFO={}
    g_TestHandler = {}
    g_EventHandler = {}
    g_multi_handler =  {} 
    g_multi_handler_ex = {} 
    G_WING_INFO = {}
    G_RIDING_INFO = {id={}}
    G_ZHJ_INFO = {}
    G_ZHR_INFO = {}
    G_BLACK_INFO = {}
    G_BEAUTY_INFO = {}
    G_BUFF_TIME = 0
    G_TUTO_NODE = nil
    G_TUTO_DATA =  {}
    G_SETPOSTEMP = {}
    G_SETPOSTEMPE = {}
    G_NFTRIGGER_NODE = nil
    G_NF_DATA = {}
    G_VIP_INFO = { vipLevel = 0 , ingotScore = 0 , ingotAll = 0 , sendType = 1 }
    G_RING_INFO = {}
    G_WR_ADVANCE_INFO = {}
    G_FIREND_DATA = {}
    G_LOCAL_TIME_CD = nil
	G_jifen = 0
    g_buffs = {}
    g_buffs_ex = {}
    G_keepTime = nil
    --G_DIR_REDBAG = {}
    --G_DIR_REDBAG_RECV = {}
    G_SKILL_REDCHECK = {{},{},0}
    G_SKILLPROP_POS = {}
    G_EMPIRE_INFO = {BATTLE_INFO={}, REDHOT_INFO={}, defaultHoldTime = 3600 ,BIQI_KING = {}, CAPTURED_INFO = {}}
    G_SHOW_ORDER_DATA = {showFunc=false, showTuto=false, showFuncEx=false}
    RED_BAG_INTEGRAL = { data = {} , integral = 0 , refreshFun = {} }        --红包积分初始化
    G_FBMULTIPLE_DATA = {isCallPlay = false}
    G_CallGotoTimeFlg = 0
    activityDelayFun = nil    --活动数据延迟执行
    G_MULTITOUCH_DATA = {}
    G_DRUG_MP = nil    --要自动吃蓝药表
    G_DRUG_HP = nil    --要自动吃红药表
    G_DRUG_HP_SHORT = nil   --要自动吃短红药表
    G_DRUG_TAB = nil     --可设置总药表
    G_DRUG_CHECK = {}    --存放不再提示便捷买药的表
    G_CharmRankList  = nil
    G_SHAWAR_DATA = {mapId = 4100 , mapId1 = 4101, startInfo = {}, holdData = {}, KING = {}}  --沙巴克攻城战数据
    G_BABEL_DATA = {}
    G_JJC_INFO = {}
    G_MY_STEP_SOUND = nil
    G_NPC_SOUND = nil
    G_NO_ONEINFO = {}
    G_TIME_INFO = {time = os.time()}
    G_WKINFO = {}
    G_TARGETAWARD = {{},{}}
    G_RED_DOT_DATA = {}
    G_VS_MAP_MSG_CACHE = {}
    G_MYSTERIOUS_MAP_MSG_CACHE = {}
    G_STORY_FB_MODE = false

    if DATA_Mission then
        DATA_Mission:clearData()
        
        if DATA_Mission.DART_STATIC then
             DATA_Mission.DART_STATIC = nil
             game.setAutoStatus( 0 )
        end

    end

    if DATA_Activity then
        DATA_Activity:clearData()
    end
    
    if DATA_Battle then
        DATA_Battle:init()
    end

    if SOCIAL_DATA then
        SOCIAL_DATA:clearData()
    end
    
    
    game.setAutoStatus(0)
	
    if DATA_Activity then  DATA_Activity:regClockFun( "sys_msg" , nil ) end
    --AudioEnginer.setMusicVolume(1)
    G_ONCREATE_GAME = nil
	
    g_reconnect_auto_status = nil
    resetConfigItems()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    qqVipQueryed = false
    --重新登录默认不录制
    setLocalRecordByKey(3,"isAutoRecorder",false)
    setLocalRecordByKey(3,"isAutoRecorder3v3",false)
end

_OnGameAppEvent = function(event) 
    if event == "1" then
        g_msgHandlerInst:sendNetDataByTableEx( LOGIN_CG_UNLOAD_PLAYER, "LoginUnloadPlayerReq", {})
        print("_OnGameAppEvent Ok 1")
        cc.Director:getInstance():endToLua()
    elseif event == "onLogout" then
        print("_OnGameAppEvent Ok")
        game.setAutoStatus(0)
        g_msgHandlerInst:sendNetDataByTableEx( LOGIN_CG_UNLOAD_PLAYER, "LoginUnloadPlayerReq", {})
        CommonSocketClose()
        game.ToLoginScene()
    end
end

function game.startup()
    --print("getMemory: start up",getMemory())
    --Director:setDisplayStats(true)
    --loadFiles()
    performWithDelay(Director:getRunningScene(),loadFiles,0.0)
    Director:setAnimationInterval(1.0 / 30)
    --cc.Node:setCheckAllocationNode(false)
    --cc.Node:setCheckAllocationNodeSub(1,false)
    local version = cc.UserDefault:getInstance():getStringForKey("current-version-code") 
    MdsAgent:init(tostring(g_Channel_tab.adChannel),tostring(version))
    --MapView:setMaxLockNum(4)
end

function game.goToMapScenes(scene_str,param)
	local scene = require(scene_str).new(param)
	Director:replaceScene(scene)
end

local queryOpenIds = {}
local qqVipMap = {}
local function sendQueryQQVipsRequest()
    if #queryOpenIds > 0 then
        local LoginScene = require("src/login/LoginScene")
        local ret = {accessToken = LoginScene.user_pwd, flags = "qq_vip,qq_svip", pf = sdkGetPf()}

        --每次最多查询50个
        if #queryOpenIds <= 50 then
            ret.fopenids = queryOpenIds
            g_msgHandlerInst:sendNetDataByTable(FRAME_CS_QUERY_QQFRIENDS_VIP_INFO, "QueryQQFriendsVipInfoRequest", ret)
            print("sendQueryQQVipsRequest", #ret.fopenids)

            queryOpenIds = {}
        else
            ret.fopenids = {}
            for i = 1, 50 do
                ret.fopenids[i] = queryOpenIds[i]
                g_msgHandlerInst:sendNetDataByTable(FRAME_CS_QUERY_QQFRIENDS_VIP_INFO, "QueryQQFriendsVipInfoRequest", ret)
                print("sendQueryQQVipsRequest", #ret.fopenids)
            end

            local openids = {}
            for i = 51, #queryOpenIds do
                openids[#openids + 1] = queryOpenIds[i]
            end
            queryOpenIds = openids
        end
    else
        --查询完毕保存到缓存
        LoginUtils.saveQQVipMap(qqVipMap)

        --重新创建QQVIP界面
        if G_MAINSCENE then 
            G_MAINSCENE:createQQVipSign() 
        end
    end
end

local function onQueryQQVipsResult (luaBuffer)
    print("onQQVipInfoResult")
    local retTable = g_msgHandlerInst:convertBufferToTable("QQFriendsVipInfoResult", luaBuffer)

    if retTable.ret ~= 0 or retTable.is_lost == 1 then
        print("onQueryQQVipsResult failed", retTable.ret, retTable.is_lost)
        return
    end

    if retTable.friendsVipInfo then
        local myOpenId = sdkGetOpenId()
        for k,v in ipairs(retTable.friendsVipInfo) do
            local level = 0
            if v.is_qq_svip == 1 then
                level = 2
            elseif v.is_qq_vip == 1 then
                level = 1
            end

            if v.openid then
                qqVipMap[v.openid] = level
            end

            print("onQQVipInfoResult", v.openid, level)
        end

        sendQueryQQVipsRequest()
    end
end

local function onRelationFriendsInfoNotify(result, str)
    local openids = {}
    openids[1] = sdkGetOpenId()

    local ret = require("json").decode(str)
    if #ret > 0 then
        for i = 1, #ret do
            openids[#openids + 1] = ret[i].openId
            if #openids >= 200 then
                break
            end
        end
    end

    for k,v in ipairs(openids) do
        print("openids ", k, v)
    end

    g_msgHandlerInst:registerMsgHandler(FRAME_SC_QQFRIENDS_VIP_INFO, onQueryQQVipsResult)

    queryOpenIds = openids
    sendQueryQQVipsRequest()
end

local function queryFriendsQQVips()

    if not qqVipQueryed then
        qqVipQueryed = true
        
        --queryOpenIds = {"abc", "def"}
        --g_msgHandlerInst:registerMsgHandler(FRAME_SC_QQFRIENDS_VIP_INFO, onQueryQQVipsResult)
        --sendQueryQQVipsRequest()

        if LoginUtils.isQQLogin() then

            if isAndroid() then
                g_msgHandlerInst:sendNetDataByTableExEx(QQVIP_CS_REWARD_INFO, "QQVipRewardInfoRequest", {})
                cclog("QQVIP_CS_REWARD_INFO")
            end

            qqVipMap = LoginUtils.loadQQVipMap()
            if qqVipMap then
                --重新创建QQVIP界面
                if G_MAINSCENE then
                    G_MAINSCENE:createQQVipSign() 
                end
            else
                qqVipMap = {}
                LoginUtils.queryFriendsInfo(onRelationFriendsInfoNotify)
            end
        end
    end
end

--0 非会员
--1 会员
--2 超级会员
function game.getVipLevel(openid)

    if isWindows() then
        return 0
    end

    if not openid then
        openid = sdkGetOpenId()
    end

    local level = qqVipMap[openid]
    if level then
        return level
    end

    return 0
end

function game.onEnterMapScene(luaBuffer)
    GetMultiPlayerCtr()
    --local params = {luaBuffer:readByFmt("bissscs")}
    local proto = g_msgHandlerInst:convertBufferToTable("FrameEntityEnterProtocol", luaBuffer)
    local params = {proto.isMe,proto.roleID,proto.mapID,proto.x,proto.y,proto.type}

    -- cclog("game.onEnterMapScene........"..tostring(params[1])..tostring(params[6])..",id:"..tostring(params[2]) .. ",mapid:"..tostring(params[3]))
    if __G_ON_CREATE_ROLE or _G_IS_LOGINSCENE or __G_IS_OPENSCENE then
        return
    end

    if proto.isMe then
        queryFriendsQQVips()
        --PayMsg.checkPayResult()
    end

    if params[1] and params[3] and (params[3] < 10) then
        print("invalid map ********************")
        dump(params)
        userInfo.connStatus = RECONNECTFAILED
        globalInit()
        TIPS( { type = 1 , str = "^c(green)进入地图异常，请重新登录^" } )
        local func = function()
            game.ToLoginScene()
        end
       performWithDelay(getRunScene(),func,1.0)
    else
        --因为迷仙阵地图存在进入同一个mapId的情况，需要特殊处理，如果是玩家自己进入，则强制刷新map
        --not G_MAINSCENE.map_layer.willEnterNextRoom这一个条件是用来识别是否是小退断线重连导致接收到enterMapScene消息
        --在迷仙阵传送消息发生之前会设置willEnterNextRoom,这时才不会忽略小退重连导致的enterMapScene刷新场景
        local bool_isMiXianZhen = false
        for k, v in pairs(require("src/config/fanxianfront")) do
            if v.q_map_id == proto.mapID then
                bool_isMiXianZhen = true
                break
            end
        end
        if G_MAINSCENE and params[3] == G_MAINSCENE.mapId and not (proto.isMe and bool_isMiXianZhen and G_MYSTERIOUS_REVIVE_STETE.alive and G_MAINSCENE.map_layer.willEnterNextRoom) then
            if proto.isMe and bool_isMiXianZhen and not G_MYSTERIOUS_REVIVE_STETE.alive then
                G_MYSTERIOUS_REVIVE_STETE.alive = true
            end
            if params[1] and G_MAINSCENE and G_MAINSCENE.map_layer then
                if G_MAINSCENE.map_layer.isStory == true then
                    if G_ROLE_MAIN then
                        G_ROLE_MAIN.obj_id = params[2]
                    end
                    return
                end              

                if G_MAINSCENE and G_MAINSCENE.shaWarDeadLayer and 
                (G_MAINSCENE.mapId == G_SHAWAR_DATA.mapId or G_MAINSCENE.mapId == G_SHAWAR_DATA.mapId1) then
                    removeFromParent(G_MAINSCENE.shaWarDeadLayer)
                    G_MAINSCENE.shaWarDeadLayer = nil
                end

                local map_name = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId,"q_map_name")
                if userInfo and userInfo.lastFbType == 3 and G_MAINSCENE.mapId == 5100 then
                    local fbId = userInfo.lastFb
                    local itemDate = getConfigItemByKey("FBTower", "q_id", fbId)
                    if itemDate and itemDate.q_copyLayer then
                        map_name = map_name .. string.format(game.getStrByKey("fb_layer"), tonumber(itemDate.q_copyLayer or 1))
                    end
                end


                if G_MAINSCENE and G_MAINSCENE.mapName then
                    --dump(map_name)
                    G_MAINSCENE.mapName:setString(map_name)
                end

                if G_MAINSCENE.map_layer:isHasAllLoaded() then
                    if g_reconnect_auto_status then
                        local MPackManager = require "src/layers/bag/PackManager"
                        MPackManager:updateDressPack(true, nil)
                    else
                        G_MAINSCENE.map_layer:cleanAstarPath(true,true)
                    end
                -- elseif g_reconnect_auto_status and MRoleStruct:getAttr(ROLE_HP) > 0 then
                --     print("************** invalid map ********************")
                --     return
                end
                AudioEnginer.stopAllEffects()
                G_MAINSCENE.map_layer.play_step = nil
                if DATA_Mission then DATA_Mission:setFindPath( false ) end
            end
            G_MAINSCENE:onEnterMapScene(proto,params)
        elseif params[1] then
            local scene = require("src/LoadingScene").new(proto,params)
        end
    end
end

function game.goToScenes(scene_str,param,noaction)
    --Director:replaceScene(require(scene_str).new(param))
    if getRunScene() then
        if noaction then
            Director:replaceScene(require(scene_str).new(param))
        else
            Director:replaceScene(cc.TransitionFade:create(0.2,require(scene_str).new(param)))
        end
    else
        cc.Director:getInstance():runWithScene(require(scene_str).new(param))
    end
end

function game.exit()
	Director:endToLua()
end

function game.ToLoginScene(no_auto)
    globalInit()
    local scene = require("src/login/LoginScene").new()
    Director:replaceScene(scene)
end

function game.getStrByKey(key)
    local str_tab = {}
    if g_Channel_tab.language and g_Channel_tab.language == "hk" then
        str_tab = require("src/config_hk/StringCfg")
    else
        str_tab = require("src/config/StringCfg")
    end
    if str_tab[key] then
        return str_tab[key]
    else
        return ""
    end  
end

AUTO_TASK = 1 
AUTO_PATH = 2      -- 任务自动寻路
AUTO_PATH_MAP = 3  -- 地图自动寻路
AUTO_ATTACK = 4
AUTO_MINE = 5
AUTO_PICKUP = 6
AUTO_MATIC = 7      --镖车护送
AUTO_ESCORT = 8     --任务护送

local auto_status = 0

function game.getAutoStatus()
    return auto_status
end
function game.setAutoStatus(status,no_effect)
    auto_status = status
    if DATA_Battle then DATA_Battle:beginTime( status ) end
    
    --print("status",status)
    --print(string.format(debug.traceback()))
    if (not no_effect) and G_MAINSCENE then
        if status == AUTO_PATH or  status == AUTO_PATH_MAP then
            local checkPath = function()
                if G_MAINSCENE and (auto_status == AUTO_PATH or  auto_status == AUTO_PATH_MAP) and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer:hasPath() then
                    G_MAINSCENE:playHangupEffect(1)
                end
            end
            performWithDelay(G_MAINSCENE,checkPath,0.3)
        elseif status == AUTO_ATTACK then
            G_MAINSCENE:playHangupEffect(0)
        elseif status == AUTO_MINE then 
            G_MAINSCENE:playHangupEffect(4)  
        elseif status == AUTO_MATIC then
            G_MAINSCENE:playHangupEffect(3)
        elseif status == AUTO_ESCORT then
            G_MAINSCENE:playHangupEffect(5)
        elseif status == 0 then
            G_MAINSCENE:playHangupEffect(2)
            if DATA_Mission then DATA_Mission:setAutoPath( false ) end
        end
    end
end
local attack_status = false
function game.setMainRoleAttack(status)
    attack_status = status
end
function game.getMainRoleAttack()
   return attack_status
end
wingAndRidingType = {
    WR_TYPE_WING = 1,
    WR_TYPE_RIDING = 2,
    WR_TYPE_ZHR = 3,
    WR_TYPE_ZHJ = 4,
}