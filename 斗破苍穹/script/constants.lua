require"Lang"
require "utils"
require "SDK"

dp = dp or { }

if not dp.NOTICE_URL then
    local channel = SDK.getChannel()
    local anncUrl = "http://dpres.huayigame.com/public/"
    if channel == "iosy2game" or channel == "iosy2gamenew" then
        anncUrl = "http://dpres.huayigame.com/ios/"
    elseif channel == "???" then
        anncUrl = "http://announcementUrl"
    end
    dp.NOTICE_URL = anncUrl
    anncUrl = nil
end

dp.PROGRAM_VER = dp.PROGRAM_VER or ""
dp.LOGIN_URL = dp.LOGIN_URL or ""

dp.SCROLLVIEW_DIRECTION_NONE = 0
dp.SCROLLVIEW_DIRECTION_VERTICAL = 1
dp.SCROLLVIEW_DIRECTION_HORIZONTAL = 2
dp.SCROLLVIEW_DIRECTION_BOTH = 3

dp.kEdgeFlagLeft = 1
dp.kEdgeFlagRight = 2
dp.kEdgeFlagTop = 4
dp.kEdgeFlagBottom = 8

dp.DIALOG_SCALE = 0.95

--[[
dp.RELEASE = false
dp.SERVERS_IP = "42.62.56.25"
dp.SERVERS_PORT = 10001
]]
dp.musicSwitch = true -- 音乐开关
dp.soundSwitch = true -- 音效开关

local function readConfig()
    dp.RELEASE = true
    local config = cc.FileUtils:getInstance():getStringFromFile("hyconfig")
    local a = utils.stringSplit(config, "\n")
    for k, v in pairs(a) do
        if string.find(v, "RELEASE") then
            dp.RELEASE = utils.stringSplit(v, "=")[2]
            dp.RELEASE = tonumber(dp.RELEASE) == 1 and true or false
        elseif string.find(v, "SERVERS_IP") then
            dp.SERVERS_IP = utils.stringSplit(v, "=")[2]
        elseif string.find(v, "SERVERS_PORT") then
            dp.SERVERS_PORT = utils.stringSplit(v, "=")[2]
        end
    end

    local musicSwitch = cc.UserDefault:getInstance():getStringForKey("musicSwitch")
    local soundSwitch = cc.UserDefault:getInstance():getStringForKey("soundSwitch")
    if musicSwitch == "0" then dp.musicSwitch = false end
    if soundSwitch == "0" then dp.soundSwitch = false end
end
readConfig()

dp.FONT = "data/ui_font.ttf"

dp.FightType = {
    FIGHT_PAGODA = "pagoda",
    -- 爬塔战斗
    FIGHT_TASK =
    {
        ELITE = "elite",
        -- 精英副本
        COMMON = "common",
        -- 普通副本
        ACTIVITY = "activity",-- 活动副本

    },
    -- 副本战斗
    FIGHT_CHIP =
    {
        PC = "pc",
        -- 玩家角色
        NPC = "npc"-- 非玩家角色
    },
    -- 抢碎片战斗
    FIGHT_ARENA = "arena",
    -- 竞技场战斗
    FIGHT_FIRST = "fight_first",
    FIGHT_BOSS = "boss",
    -- 世界boss
    FIGHT_TRY_PRACTICE = "tryPractice",
    -- 试炼日战斗
    FIGHT_PILL_TOWER = "pillTower",
    -- 丹塔战斗
    FIGHT_MINE = "mine",
    -- 抢矿战斗
    FIGHT_UNION_REPLAY = "unionReplay",
    -- 劫镖战斗
    FIGHT_ESCORT = "escort",
    -- 开箱子战斗（先祖遗宝）
    FIGHT_BAG_OPEN_BOX = "bagOpenBox",

    FIGHT_TOWER_UP = "towerUp" ,--云顶天关战斗

    FIGHT_3V3 = "3v3", --3v3战斗

    FIGHT_WING = "wing" -- 神羽溶洞
}

dp.QualityImageType = {
    small = 0,
    -- 小号品质图
    middle = 1,
    -- 中号品质图
    big = 2-- 大号品质图
}

dp.Quality = {
    card = 0,
    -- 卡牌品质
    equip = 1,
    -- 装备品质
    gongFa = 2,
    -- 功法品质
    fire = 3,
    -- 异火品质
    fireSkill = 4,
    -- 异火技能品质
    skill = 5,
    -- 手动技能品质
    fightSoul = 6
}

dp.FireType = {
    strangeFire = 1,
    -- 异火
    beastFire = 2,-- 兽火
}

dp.MagicType = {
    treasure = 1,
    -- 法宝
    gongfa = 2,-- 功法
}

dp.TableType = {
    DictUnionPractice = 1000
}

dp.rechargeGold = 0
dp.DictFightProp = { }
dp.DictFightProp[StaticFightProp.blood] = { sname = Lang.constants1, value = 15 } -- 1根骨 ==> 15生命
dp.DictFightProp[StaticFightProp.wAttack] = { sname = Lang.constants2, value = 2.5 } -- 1力量 ==> 2.5物攻
dp.DictFightProp[StaticFightProp.wDefense] = { sname = Lang.constants3, value = 1 } -- 1护甲 ==> 1物防
dp.DictFightProp[StaticFightProp.fAttack] = { sname = Lang.constants4, value = 2.5 } -- 1智力 ==> 2.5法功
dp.DictFightProp[StaticFightProp.fDefense] = { sname = Lang.constants5, value = 1 } -- 1抗性 ==> 1法防

function dp.getUserData()
    local userData = nil
    if net.InstPlayer then
        userData = { }
        userData.roleId = net.InstPlayer.int["1"]
        userData.accountId = net.InstPlayer.string["2"]
        userData.roleName = net.InstPlayer.string["3"]
        userData.roleLevel = net.InstPlayer.int["4"]
        userData.serverId = dp.serverId or 0
        userData.serverName = dp.serverName or ""
        userData.vipLevel = net.InstPlayer.int["19"]
    end
    return userData
end

function dp.getAccountId()
    local accountId = nil
    if net.accountId then
        accountId = net.accountId
    end
    return accountId
end

function dp.isNewServer()
    local serverId = dp.serverId or 0
    local isNew = false

    if serverId >= 20001 and serverId <= 29999 then
        -- Android
        isNew = true
    elseif serverId >= 30001 and serverId <= 39999 then
        -- IOS
        isNew = true
    elseif serverId >= 40001 and serverId <= 49999 then
        -- 掌阅
        isNew = true
    elseif serverId >= 50001 and serverId <= 59999 then
        -- 腾讯
        isNew = true
    end

    return isNew
end

function dp.Logout()
    if SHOW_VIDEO then
        local videoPlayer = UIManager.gameScene:getChildByTag(-10000)
        if videoPlayer then
            videoPlayer:removeFromParent()
            videoPlayer = nil
            UIManager.uiLayer:removeAllChildren()
        end
    end
    local layout = UIManager.gameScene:getChildByTag(-10001)
    if layout then
        layout:removeFromParent()
        layout = nil
    end
    netDisconnect()
    dp.stopTimer()
    UIHomePage.flag = false
    UIMenu.Logined = nil
    UIFightTaskChoose.reset = false
    UIGuidePeople.isPushScene = false
    dp.rechargeGold = 0
    UIShop.clearData()
    UIAwardSign.DictActivitySignIn1 = { }
    UIAwardSign.DictActivitySignIn2 = { }
    UIAwardSign.todayRechargeGold = 0
    UIWar.myUnionBattle = nil
    UIWar.myUnionMemberBattle = nil
    UIWar.enemyUnionBattle = nil
    UIWar.enemyUnionMemberBattle = nil
    UIWar.my = nil
    UIWar.reports = nil
    UIWar.state = nil
    AudioEngine.stopMusic(true)
    UIActivityPurchaseGift.resetData()
    UITeam.stopRecoverState()
    UILoot.stopSchedule()
    UIMenu.cleanHintData()
    UIManager.free()
    if dp.RELEASE then
        if not(UILogin.Widget and UILogin.Widget:getParent()) then
            UIManager.showScreen("ui_login")
        else
            UILogin.setup()
        end
    else
        if not(TestLogin.Widget and TestLogin.Widget:getParent()) then
            UIManager.showScreen("test_login")
        end
    end
    WidgetManager.delete(UIBeauty)
    UIGuidePeople.free()
    UIGuidePeople.guideStep = nil
    UIGuidePeople.levelStep = nil
    UIGuidePeople.guideFlag = nil
    for key, obj in pairs(net.GameDataTable) do
        net[obj] = nil
    end
    net.FilterData = nil

    if UITalkFly.layer then
        UITalkFly.remove()
    end
    if SDK.getChannel() =="360" then
        local role = dp.getUserData()
        local params = {"exitServer", tostring(role.serverId) ,role.serverName , tostring(role.roleId), role.roleName ,"0" ,"无","无",tostring(role.roleLevel) ,tostring(utils.getFightValue()) , tostring(role.vipLevel) ,"0","元宝",tostring(net.InstPlayer.int["5"]),"0","无","0","无","无"}
        SDK.doSubmitExtendData(params)     
    end
end

dp.changeFightValueHeader = {
    StaticMsgRule.login,-- 玩家登陆
-- StaticMsgRule.cardInTeam, 				--卡牌上阵
-- StaticMsgRule.convertCard,				--更换卡牌
-- StaticMsgRule.deleteCard,					--吃卡
-- StaticMsgRule.addEquipment,				--添加/更换装备
-- StaticMsgRule.putOffEquip,				--卸装备
-- StaticMsgRule.strengthen,					--强化装备
-- StaticMsgRule.quickStrengthen,		--一键强化
-- StaticMsgRule.refinement,					--洗练
-- StaticMsgRule.equipInlay,					--装备镶嵌宝石
-- StaticMsgRule.takeOffGem,					--装备宝石拆除
-- StaticMsgRule.packGemUpgrade,			--装备背包中宝石升级
-- StaticMsgRule.equipGemUpgrade,		--装备装备身上宝石升级
-- StaticMsgRule.cardInPartner,			--小伙伴上阵
-- StaticMsgRule.cardOutPartner,			--小伙伴下阵
-- StaticMsgRule.trainAccept,				--接受卡牌修炼
-- StaticMsgRule.breakThrough,				--卡牌突破
-- StaticMsgRule.addKungFu,					--添加功法
-- StaticMsgRule.addNode,						--运功
-- StaticMsgRule.addNodes,						--一键升满
-- StaticMsgRule.convertKungFu,			--更换功法
-- StaticMsgRule.deleteKungFu,				--吞噬功法
-- StaticMsgRule.changeFireSkill,		--开启/蜕变异火技能
-- StaticMsgRule.trainFireSkill,			--保留异火斗技
-- StaticMsgRule.fireUse,						--异火上阵
-- StaticMsgRule.fireUpgrade,				--异火升级
-- StaticMsgRule.fireInherit,				--异火传承
-- StaticMsgRule.usePill,						--使用丹药
-- StaticMsgRule.coreConvert,				--魔核转换
-- StaticMsgRule.war,								--爬塔——战
-- StaticMsgRule.mop,								--爬塔——扫荡
-- StaticMsgRule.commonWar,					--副本——普通战斗
-- StaticMsgRule.aKeyCommonWar,			--一键战斗
-- StaticMsgRule.eliteWar,						--精英战斗
-- StaticMsgRule.activityWar,				--活动战斗
-- StaticMsgRule.cardAdvance,				--卡牌进阶
-- StaticMsgRule.lootWarWin,					--战斗胜利
-- StaticMsgRule.eatPill,						--吃丹
-- StaticMsgRule.use,								--手动技能上阵使用
-- StaticMsgRule.convertManualSkill,	--更换/卸下
-- StaticMsgRule.eatManualSkill,			--吃技能/升级
-- StaticMsgRule.arenaWarWin,				--竞技场抢夺胜利/失败
-- StaticMsgRule.putOn,							--功法/法宝  上阵/更换
-- StaticMsgRule.putOff,							--功法/法宝下阵
-- StaticMsgRule.strengthenMagic,		--强化法宝与功法
-- StaticMsgRule.courtship,					--示爱(赠送亲密度)
-- StaticMsgRule.linger,							--缠绵
-- StaticMsgRule.quickUpgrade,				--快速升级（战队）
}

--[[ **************************** 定时器 **************************** ]]--
local _timerEventFunc = nil
local _timerFlag = nil
local _timerScheduleId = nil
dp.curTimerNumber = 0

function dp.updateTimer(interval)
    dp.curTimerNumber = dp.curTimerNumber + interval
end

local function doTimer(dt)
    if _timerFlag == nil then
        _timerFlag = os.time()
    end
    if tonumber(os.time()) - tonumber(_timerFlag) >= 1 then
        dp.curTimerNumber = dp.curTimerNumber + 1
        _timerFlag = os.time()
        if _timerEventFunc then
            for key, timerFunc in pairs(_timerEventFunc) do
                timerFunc()
            end
        end
    end
end

function dp.startTimer()
    dp.curTimerNumber = 0
    _timerScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(doTimer, 0, false)
end

function dp.stopTimer()
    if _timerScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_timerScheduleId)
        _timerScheduleId = nil
        _timerFlag = nil
        _timerEventFunc = nil
    end
    dp.curTimerNumber = 0
end

function dp.addTimerListener(_func)
    if _timerEventFunc == nil then
        _timerEventFunc = { }
    end
    for key, obj in pairs(_timerEventFunc) do
        if obj == _func then
            return
        end
    end
    table.insert(_timerEventFunc, _func)
end

function dp.removeTimerListener(_func)
    if _timerEventFunc then
        for key, obj in pairs(_timerEventFunc) do
            if obj == _func then
                _timerEventFunc[key] = nil
                break
            end
        end
    end
end
--[[ **************************** 定时器 **************************** ]]--
