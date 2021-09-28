-- Filename：	BossMainLayer.lua
-- Author：		Li Pan
-- Date：		2013-12-26
-- Purpose：		世界boss

module("BossMainLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/utils/BaseUI"

require "script/ui/boss/BossData"
require "script/ui/tip/AnimationTip"

require "db/DB_Worldboss"
require "db/DB_Worldbossinspire"


local winSize = CCDirector:sharedDirector():getWinSize()
local leftTimeLabel = nil -- 剩余时间检测标签
local timeLabel = nil -- 剩余时间提示

local scheduleTag = nil -- 定时器标签
local inspireScheduleTag = nil -- 鼓舞定时器tag
local fightScheduleTag = nil -- 攻击定时器tag


local fightButtonLabel = nil -- 按钮攻击label
local fightButtonLabel2 = nil -- 按钮攻击label,显示时间

local isInFight = nil -- 是否在可以攻打中

local autoFightLabel = nil -- 自动攻击label

local isAutoFight = nil --是否是自动攻击

local fightAddData = nil -- 攻击加成数值

local inspireCDLabel = nil -- 鼓舞cdlabel

local m_silverLabel = nil -- 银币label
local m_goldLabel = nil  --金币label


local leftFightCD = nil -- 剩余攻击cd
local leftInspireCD = nil -- 剩余的鼓舞cd

local rebirthGold = nil --复活金币

local fightTimesLabel = nil -- 攻击次数label
local attackTotalLabel = nil -- 总攻击伤害label
local playerRankLabel = nil -- 玩家排名label

local blood_bottom = nil --血条的底

local bossIsDead = nil -- 判断boss 是不是死了

local rebirthItem = nil -- 复活按钮

local netKey = "BossMainLayer"-- 断线重连key

local lastAttackTime = nil-- 上一次攻击的时间

local isInfightNet = nil -- 如果断线了 在战斗中

local _isNewBoos = false -- 是否是新的boos

local _checkBtn = nil   -- 是否使用boss阵型
local _checkTagSprite = nil -- 勾选标识
local _formationBtn = nil -- Boss阵型

function init( )
    _checkBtn = nil
    _checkTagSprite = nil
    _formationBtn = nil
end

function createBoss( ... )
    init()
	MainScene.getAvatarLayerObj():setVisible(false)
	MenuLayer.getObject():setVisible(false)
	BulletinLayer.getLayer():setVisible(true)

    bossLayer = CCLayer:create()

    sendEnterBoss()

    --注册断线重连
    LoginScene.addObserverForNetBroken(netKey, leaveBoss)

	return bossLayer
end


function sendEnterBoss( ... )
    --判断时间
    require "script/ui/boss/BossNet"
    BossNet.getBossInfo(enterBoss)
end

function enterBoss( ... )
    print("enter boss ")
    -- print_t(BossData.bossInfo)
    print("the BossData.getBossTimeOffset()"..BossData.getBossTimeOffset())

    bossIsDead = BossData.bossInfo.boss_dead
    isInFight = BossData.bossInfo.boss_time

    -- 是否是新boos
    _isNewBoos = BossData.getIsNewBoos()

    if(tonumber(isInFight) == 0) then
        createTopUI()

        createBeforeFight()
    else
        createTopUI()
        showFightBoss()
        onPushBossKill()
        onPushBossUpdate()
    end
    createCheckUseFormation()
end

--------------- 世界boss结束推送 ----------------------
function re_push_boss_kill(cbFlag, dictData, bRet)
    print("re_push_boss_kill is on")
    print_t(dictData.ret)
    BossData.killName = dictData.ret[1].uname
    print("the BossData.killName is ",BossData.killName)
    isAutoFight = false
    leftTime = 0

    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)
    if(fightScheduleTag) then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(fightScheduleTag)
    end

    createFightPrize()
end

--------------- 世界boss掉血推送 ----------------------
function re_push_boss_update(cbFlag, dictData, bRet)
    print("re_push_boss_update is on")
    print_t(dictData)
    --减血，提示掉血
    BossData.bossInfo.hp = dictData.ret.hp
    blood_bottom:removeChildByTag(909011, true)
    blood_bottom:removeChildByTag(909012, true)
    setBossBlood()
-- 推送的排名消息
    local rankInfo = dictData.ret.atkList
    changeRank(rankInfo)

--如果后端推的是自己的消息，则不需要跟新数据
    local uid = tonumber(dictData.ret.uid)
    if(UserModel.getUserUid() == uid) then
        return
    end
    showFightInfo(dictData.ret)
end

function changeRank(rankInfo)
    local myUid = UserModel.getUserUid()
    print("my uid is ",myUid)
    for i,v in ipairs(rankInfo) do
        local uid = tonumber(v)
        print("the uid is ...",uid)
        if(uid == tonumber(myUid)) then
            print("my rank is >>>>>> ", i)
            --如果我是前十，那么直接更新
            if(not playerRankLabel) then
                return
            end
            playerRankLabel:setString(tonumber(i))
            if(not BossData.attackData) then
                return
            end
            BossData.attackData.rank = tonumber(i)
            return
        end
    end
--自己上次排名，如果这次不再前十，那么更新数据
    if(not BossData.attackData) then
        return
    end

    local myLastRank = BossData.attackData.rank
    print("my last髯口k is ",myLastRank)
    if(tonumber(myLastRank) < 11) then
        --发送消息
        BossNet.getRank(function ( ... )
            print("getRank is >>>>>>>")
            if(not playerRankLabel) then
                return
            end
            playerRankLabel:setString(BossData.rankInfo)
            BossData.attackData.rank = BossData.rankInfo
        end)
    end
end

--boss掉血回调
function onPushBossUpdate()
    print("register onPushBossUpdate")
    Network.re_rpc(re_push_boss_update, "push.boss.update", "push.boss.update")
end

--boss结束回调
function onPushBossKill()
    print("register onPushBossKill")
    Network.re_rpc(re_push_boss_kill, "push.boss.kill", "push.boss.kill")
end

-- 注销推送
local function remove_push_boss()
    Network.remove_re_rpc("push.boss.update")
    Network.remove_re_rpc("push.boss.kill")
end

--[[
    @author:        bzx
    @desc:          刷新选择使用摇钱树的UI标识
    @return:    nil
--]]
function refreshCheckTagSprite( ... )
    if BossData.isUseFormation() == "1" then
        if tolua.isnull(_checkTagSprite) then
            _checkTagSprite = CCSprite:create("images/common/checked.png")
            _checkBtn:addChild(_checkTagSprite)
            _checkTagSprite:setAnchorPoint(ccp(0.5, 0.5))
            _checkTagSprite:setPosition(ccpsprite(0.5, 0.5, _checkBtn))
        end
    else
        if not tolua.isnull(_checkTagSprite) then
            _checkTagSprite:removeFromParentAndCleanup(true)
            _checkTagSprite = nil
        end
    end
end

--[[
    @author:        bzx
    @desc:          选择使用Boss阵型的回调
    @return:        nil
--]]
function checkCallback(p_tag, p_menuItem)
    if table.isEmpty(BossData.getFormation()) then
        AnimationTip.showTip(GetLocalizeStringBy("key_8551"))
        return
    end
    BossNet.useFormation(refreshCheckTagSprite)
end

--[[
    @author:    bzx
    @desc:      使用Boss阵型的勾选框
--]]
function createCheckUseFormation( ... )
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bossLayer:addChild(menu)
    menu:setTouchPriority(- 400)
        -- added by bzx
    _checkBtn = CCMenuItemImage:create("images/common/s9_4.png", "images/common/s9_4.png")
    menu:addChild(_checkBtn)
    _checkBtn:setAnchorPoint(ccp(0.5, 0.5))
    _checkBtn:setPosition(ccp(menu:getContentSize().width * 0.36, menu:getContentSize().height * 0.78))
    _checkBtn:registerScriptTapHandler(checkCallback)
    _checkBtn:setScale(g_fScaleX)
    refreshCheckTagSprite()

    local tipBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _checkBtn:addChild(tipBg)
    tipBg:setAnchorPoint(ccp(0, 0.5))
    tipBg:setPosition(ccpsprite(0.8, 0.5, _checkBtn))
    tipBg:setContentSize(CCSizeMake(200, 40))

    local tip = CCRenderLabel:create(GetLocalizeStringBy("key_8549"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tipBg:addChild(tip)
    tip:setAnchorPoint(ccp(0.5, 0.5))
    tip:setPosition(ccpsprite(0.5, 0.5, tipBg))
end

function createBeforeFight( ... )
	local bg = CCSprite:create("images/boss/boss_bg.jpg")
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bossLayer:addChild(bg)
	bg:setScale(g_fBgScaleRatio)
	bg:setPosition(ccp(winSize.width/2, winSize.height/2))

 -- 动画
    local boosEffectFile = nil
    if(_isNewBoos)then
        boosEffectFile = "images/boss/effect/wordboss_lvlong"
    else
        boosEffectFile = "images/boss/effect/wordboss"
    end
    local loadEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(boosEffectFile), -1,CCString:create(""));
    loadEffectSprite:retain()
    loadEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadEffectSprite:setPosition(ccp(winSize.width/2, winSize.height/2))
    bossLayer:addChild(loadEffectSprite)
    loadEffectSprite:release()
    loadEffectSprite:setScale(g_fBgScaleRatio)

-- 按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bossLayer:addChild(menu)
    menu:setTouchPriority(- 400)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/boss/back_normal.png","images/boss/back_selected.png")
    backItem:registerScriptTapHandler(closeSelf)
    backItem:setAnchorPoint(ccp(1,0))
    menu:addChild(backItem)
    local posY = bossLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX - bossLayer:getChildByTag(19876):getContentSize().height*bossLayer:getChildByTag(19876):getScale()-100*g_fScaleX
    backItem:setPosition(bossLayer:getContentSize().width*0.95,posY)
    backItem:setScale(g_fScaleX)
    -- 排名按钮
    local rankItem = CCMenuItemImage:create("images/common/btn/btn_hurt_n.png", "images/common/btn/btn_hurt_h.png")
    rankItem:registerScriptTapHandler(fightRank)
    rankItem:setAnchorPoint(ccp(0,0))
    menu:addChild(rankItem)
    rankItem:setPosition(ccp(bossLayer:getContentSize().width*0.05,posY))
    rankItem:setScale(g_fScaleX)
    -- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0,1))
    local posY = rankItem:getPositionY()-10*g_fScaleX
    rewardMenuItem:setPosition(ccp(bossLayer:getContentSize().width*0.05, posY))
    menu:addChild(rewardMenuItem)
    rewardMenuItem:registerScriptTapHandler(fnRewardMenuAction)
    rewardMenuItem:setScale(g_fScaleX)

    _formationBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(200, 73), GetLocalizeStringBy("key_8550"), ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(_formationBtn)
    _formationBtn:setAnchorPoint(ccp(0.5, 0.5))
    _formationBtn:setPosition(ccpsprite(0.5, 0.06, menu))
    _formationBtn:registerScriptTapHandler(formationCallback)
    _formationBtn:setScale(g_fScaleX)
    -- boos 名字
    local boosNameFile = nil
    if(_isNewBoos)then
        boosNameFile = "images/boss/new_name.png"
    else
        boosNameFile = "images/boss/boss_name.png"
    end
    local icon = CCSprite:create(boosNameFile)
    bossLayer:addChild(icon)
    icon:setAnchorPoint(ccp(0.5,0))
    icon:setScale(g_fScaleX)
    icon:setPosition(ccp(winSize.width/2, backItem:getPositionY()))

--名字背景
    local fullRect = CCRectMake(0, 0, 111, 32)
    local insetRect = CCRectMake(40, 15, 1, 1)
    local nameBg = CCScale9Sprite:create("images/boss/boss_name_bg.png", fullRect, insetRect)
    nameBg:setPreferredSize(CCSizeMake(250, 35))
    nameBg:setAnchorPoint(ccp(0.5,0.5))
    nameBg:setScale(g_fElementScaleRatio)
    bossLayer:addChild(nameBg, 1)

-- 名字等级
    local nameFont = nil
    if(_isNewBoos)then
        nameFont =  DB_Worldboss.getDataById(1).boss2name
    else
        nameFont = DB_Worldboss.getDataById(1).name
    end
    local nameLabel = CCRenderLabel:create(nameFont, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(nameBg:getContentSize().width/2 - 100, nameBg:getContentSize().height/2))
    nameBg:addChild(nameLabel)

    local lvSprite = CCSprite:create("images/boss/LV.png")
    nameBg:addChild(lvSprite)
    lvSprite:setAnchorPoint(ccp(0, 0.5))
    lvSprite:setPosition(ccp(nameLabel:getPositionX() + nameLabel:getContentSize().width, nameBg:getContentSize().height/2))

    local lvLabel = CCRenderLabel:create(BossData.bossInfo.level, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setAnchorPoint(ccp(0, 0.5))
    lvLabel:setPosition(ccp(lvSprite:getPositionX() + lvSprite:getContentSize().width, nameBg:getContentSize().height/2))
    nameBg:addChild(lvLabel)


--描述label1
    local labelTabel1 = {}
    labelTabel1[1] = CCRenderLabel:create(GetLocalizeStringBy("key_3316"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel1[1]:setColor(ccc3(0xfe, 0xdb, 0x1c))

    labelTabel1[2] = CCRenderLabel:create(nameFont, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    if(_isNewBoos)then
        labelTabel1[2]:setColor(ccc3(0xff, 0x00, 0x00))
    else
         labelTabel1[2]:setColor(ccc3(0xf0, 0x45, 0xff))
    end

    labelTabel1[3] = CCRenderLabel:create(GetLocalizeStringBy("key_1573"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel1[3]:setColor(ccc3(0xfe, 0xdb, 0x1c))

    labelTabel1[4] = CCRenderLabel:create(GetLocalizeStringBy("key_3349"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel1[4]:setColor(ccc3(0xf9, 0x59, 0xff))

    local normalDesNode1 = BaseUI.createHorizontalNode(labelTabel1)
    normalDesNode1:setAnchorPoint(ccp(0.5, 0.5))
    normalDesNode1:setScale(g_fElementScaleRatio)
    bossLayer:addChild(normalDesNode1)

--击杀排名，击杀着
    local threeString = nil
    local threePlayer = BossData.bossInfo.top_three
    if(table.count(threePlayer) == 0) then
        threeString = GetLocalizeStringBy("key_2538")
    elseif(table.count(threePlayer) == 1) then
        threeString = threePlayer[1].name
    elseif(table.count(threePlayer) == 2) then
        threeString = threePlayer[1].name..","..threePlayer[2].name
    else
        threeString = threePlayer[1].name..","..threePlayer[2].name..","..threePlayer[3].name
    end

    local firstThreeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1990")..threeString, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    firstThreeLabel:setColor(ccc3(0xff, 0xff, 0xff))
    firstThreeLabel:setAnchorPoint(ccp(0.5, 0.5))
    firstThreeLabel:setScale(g_fElementScaleRatio)
    bossLayer:addChild(firstThreeLabel)

    local killerString = BossData.bossInfo.boss_killer.uname
    if(not killerString) then
        killerString = GetLocalizeStringBy("key_2538")
    end

    local killerLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1916")..killerString, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    killerLabel:setColor(ccc3(0xff, 0xff, 0xff))
    killerLabel:setAnchorPoint(ccp(0.5, 0.5))
    killerLabel:setScale(g_fElementScaleRatio)
    bossLayer:addChild(killerLabel)

-- 每天开启时间
    local beginTimeSp = CCSprite:create("images/boss/boss_time.png")
    bossLayer:addChild(beginTimeSp)
    beginTimeSp:setAnchorPoint(ccp(0.5, 0.5))
    beginTimeSp:setScale(g_fElementScaleRatio)

    --由于每个服都不一样，所以就得分开
    local dayBeginTime = DB_Worldboss.getDataById(1).dayBeginTime
    --时间戳
    local bTime = TimeUtil.getIntervalByTime(tonumber(dayBeginTime))
    bTime = BossData.getBossTimeOffset() + bTime
    --真正的时间戳
    local times = TimeUtil.getTimeOnlyMin(bTime)
    local timeDataLabel = CCRenderLabel:create(times, g_sFontPangWa, 40, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeDataLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    beginTimeSp:addChild(timeDataLabel, 1)
    timeDataLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeDataLabel:setPosition(ccp(beginTimeSp:getContentSize().width/2, beginTimeSp:getContentSize().height/2))

-- 剩余开启时间：
    local timeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2195"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    bossLayer:addChild(timeLabel, 1, 909099)
    timeLabel:setAnchorPoint(ccp(0,0.5))
    timeLabel:setScale(g_fElementScaleRatio)
    --时间转换
    local nowTime = BTUtil:getSvrTimeInterval()
    local sh = DB_Worldboss.getDataById(1)
    local beginTime = DB_Worldboss.getDataById(1).dayBeginTime
    -- print("the begin time is >>> "..beginTime)
    --得到时间戳
    require "script/utils/TimeUtil"
    local bTime = TimeUtil.getIntervalByTime(tonumber(beginTime))
    --添加bossoffset
    bTime = bTime + BossData.getBossTimeOffset()
    if(bTime < nowTime) then
        bTime = bTime + 24*3600
    end
    -- print("the btime and the now time is ",bTime,nowTime)
    local leftTime = TimeUtil.getTimeString(tonumber(bTime - nowTime))
    leftTimeLabel = CCLabelTTF:create(leftTime, g_sFontPangWa, 23)
    leftTimeLabel:setColor(ccc3(0xff, 0xff, 0xff))
    bossLayer:addChild(leftTimeLabel)
    leftTimeLabel:setAnchorPoint(ccp(0,0.5))
    leftTimeLabel:setScale(g_fElementScaleRatio)
    scheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeLeftTime, 1, false)

    -- 坐标调整
    if(_isNewBoos)then
        -- 新boos
        nameBg:setPosition(ccp(winSize.width/2, 380*g_fElementScaleRatio))
        normalDesNode1:setPosition(winSize.width/2, 340*g_fElementScaleRatio)
    else
        -- 旧boos
        --描述label2
        local labelTabel2 = {}
        labelTabel2[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1283"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[1]:setColor(ccc3(0xf0, 0x45, 0xff))

        labelTabel2[2] = CCRenderLabel:create(GetLocalizeStringBy("lic_1263"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[2]:setColor(ccc3(0x00, 0xff, 0x18))

        local needLv = DB_Worldboss.getDataById(1).boss2level
        labelTabel2[3] = CCRenderLabel:create(needLv, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[3]:setColor(ccc3(0xfe, 0xdb, 0x1c))

        labelTabel2[4] = CCRenderLabel:create(GetLocalizeStringBy("lic_1264"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[4]:setColor(ccc3(0x00, 0xff, 0x18))

        labelTabel2[5] = CCRenderLabel:create(GetLocalizeStringBy("lic_1265"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[5]:setColor(ccc3(0xfe, 0xdb, 0x1c))

        labelTabel2[6] = CCRenderLabel:create(GetLocalizeStringBy("lic_1266"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[6]:setColor(ccc3(0x00, 0xff, 0x18))

        local newNameStr = DB_Worldboss.getDataById(1).boss2name
        labelTabel2[7] = CCRenderLabel:create(newNameStr, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel2[7]:setColor(ccc3(0xff, 0x00, 0x00))

        local normalDesNode2 = BaseUI.createHorizontalNode(labelTabel2)
        normalDesNode2:setAnchorPoint(ccp(0.5, 0.5))
        normalDesNode2:setScale(g_fElementScaleRatio)
        bossLayer:addChild(normalDesNode2)

        nameBg:setPosition(ccp(winSize.width/2, 420*g_fElementScaleRatio))
        normalDesNode1:setPosition(winSize.width/2, 380*g_fElementScaleRatio)
        normalDesNode2:setPosition(winSize.width/2, 340*g_fElementScaleRatio)
    end

    firstThreeLabel:setPosition(ccp(bossLayer:getContentSize().width/2, 290*g_fElementScaleRatio))
    killerLabel:setPosition(ccp(bossLayer:getContentSize().width/2, 250*g_fElementScaleRatio))
    beginTimeSp:setPosition(ccp(winSize.width/2, 200*g_fElementScaleRatio))
    timeLabel:setPosition(ccp(170*g_fElementScaleRatio, 145*g_fElementScaleRatio))
    leftTimeLabel:setPosition(ccp(330*g_fElementScaleRatio, 145*g_fElementScaleRatio))
end


--传入等级和位置
function createLvLabel(level, pos)
    local lvSprite = CCSprite:create("images/common/lv.png")
    lvSprite:setAnchorPoint(ccp(0, 0.5))
    lvSprite:setPosition(pos)

    local LvLabel = CCRenderLabel:create(level, g_sFontName, 23, 1, ccc3(0,0,0))
    LvLabel:setPosition(ccp(lvSprite:getContentSize().width + 10, lvSprite:getContentSize().height/2))
    LvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    LvLabel:setAnchorPoint(ccp(0, 0.5))
    lvSprite:addChild(LvLabel)
    return lvSprite
end

function closeBeforeBoss( ... )
    if(scheduleTag) then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)
        scheduleTag = nil -- 攻击定时器tag
    end
end

function closeBoss( ... )
--定时器制空
    if(fightScheduleTag) then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(fightScheduleTag)
        fightScheduleTag = nil -- 攻击定时器tag
    end

    if(inspireScheduleTag) then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(inspireScheduleTag)
        inspireScheduleTag = nil -- 攻击定时器tag
    end
--变量制空

    fightButtonLabel = nil -- 按钮攻击label
    fightButtonLabel2 = nil -- 攻击按钮 显示时间

    isInFight = nil -- 是否在可以攻打中

    autoFightLabel = nil -- 自动攻击label

    isAutoFight = nil --是否是自动攻击

    fightAddData = nil -- 攻击加成数值

    inspireCDLabel = nil -- 鼓舞cdlabel


    leftFightCD = nil -- 剩余攻击cd

    rebirthGold = nil --复活金币

    fightTimesLabel = nil -- 攻击次数label
    attackTotalLabel = nil -- 总攻击伤害label
    playerRankLabel = nil -- 玩家排名label

    leftTimeLabel = nil -- 剩余时间检测标签
    m_silverLabel = nil -- 银币label
    m_goldLabel = nil  --金币label

    blood_bottom = nil -- 血条底

    rebirthItem = nil--

    lastInspireTime = nil--上次鼓舞时间

    lastAttackTime = nil

    isInfightNet = nil
end

function formationCallback( ... )
    require "script/ui/copy/FormationSettingLayer"
    FormationSettingLayer.show(FormationSettingLayer.LayerType.WorldBoss, -6000, 1000)
end

function closeButtonCallback( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    print("close closeButtonCallback")
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:removeChildByTag(90901, true)

end

--伤害排名
function fightRank( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("======settlePanel======")
    local maskLayer = BaseUI.createMaskLayer(-450)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(maskLayer,10,90901)

    local spriteBg = CCScale9Sprite:create("images/common/bg/bg_ng.png")
    spriteBg:setContentSize(CCSizeMake(632,802))
    -- spriteBg:setPosition(maskLayer:getContentSize().width*0.5, 200)
    -- spriteBg:setScale(1/MainScene.elementScale)

    spriteBg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
    spriteBg:setAnchorPoint(ccp(0.5, 0.5))
    maskLayer:addChild(spriteBg)
    AdaptTool.setAdaptNode(spriteBg)


    local _titileSprite = CCSprite:create("images/common/title_bg.png")
    _titileSprite:setPosition(ccp(0, spriteBg:getContentSize().height))
    _titileSprite:setAnchorPoint(ccp(0,1))
    spriteBg:addChild(_titileSprite)

    -- 文字 菜单
    local menuLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1357"), g_sFontPangWa, 33, 1,ccc3(0x00,0x00,0x00), type_stroke)
    menuLabel:setColor(ccc3(0xff,0xe4,0x00))
    menuLabel:setPosition(ccp(_titileSprite:getContentSize().width*0.5,_titileSprite:getContentSize().height*0.5+3))
    menuLabel:setAnchorPoint(ccp(0.5,0.5))
    _titileSprite:addChild(menuLabel)

    --关闭按钮
    local closeMenu = CCMenu:create()
    closeMenu:setPosition(ccp(0, 0))
    _titileSprite:addChild(closeMenu)

    local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeButton:setPosition(_titileSprite:getContentSize().width * 0.95, _titileSprite:getContentSize().height/2)
    closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:registerScriptTapHandler(closeButtonCallback)
    closeMenu:addChild(closeButton, 9999)
    closeMenu:setTouchPriority(-455)

    --提示
    local tipLabel1 = CCRenderLabel:create(GetLocalizeStringBy("key_3111"), g_sFontPangWa, 24, 1, ccc3(0xff, 0xff, 0xff))
    tipLabel1:setPosition(ccp(80, spriteBg:getContentSize().height - 100))
    tipLabel1:setColor(ccc3(0x78, 0x25, 0x00))
    tipLabel1:setAnchorPoint(ccp(0, 0))
    spriteBg:addChild(tipLabel1)

    local tipLabel2 = CCRenderLabel:create(GetLocalizeStringBy("key_1599"), g_sFontPangWa, 24, 1, ccc3(0xff, 0xff, 0xff))
    tipLabel2:setPosition(ccp(spriteBg:getContentSize().width/2, spriteBg:getContentSize().height - 140))
    tipLabel2:setColor(ccc3(0x78, 0x25, 0x00))
    tipLabel2:setAnchorPoint(ccp(0.5, 0))
    spriteBg:addChild(tipLabel2)

    local tipLabel3 = CCRenderLabel:create(GetLocalizeStringBy("key_3079"), g_sFontPangWa, 24, 1, ccc3(0xff, 0xff, 0xff))
    tipLabel3:setPosition(ccp(200, spriteBg:getContentSize().height - 180))
    tipLabel3:setColor(ccc3(0x78, 0x25, 0x00))
    tipLabel3:setAnchorPoint(ccp(0, 0))
    spriteBg:addChild(tipLabel3)

    BossNet.getRankList(function ()
        --bg
        local fullRect = CCRectMake(0, 0, 75, 75)
        local insetRect = CCRectMake(30, 30, 15, 10)
        local listBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
        listBg:setPreferredSize(CCSizeMake(600, 570))
        listBg:setPosition(ccp(15, 45))
        spriteBg:addChild(listBg)


        -- --scrollview
        local scrollView = CCScrollView:create()
        scrollView:setViewSize(CCSizeMake(600, 565))
        scrollView:setTouchPriority(-455)
        scrollView:setContentSize(CCSizeMake(600, 110 * 10))
        scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - scrollView:getContentSize().height))
        -- scrollView:setContentOffset(ccp(0, - 430))
        scrollView:setBounceable(true)
             -- 垂直方向滑动
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setAnchorPoint(ccp(0,0))
        scrollView:setPosition(ccp(0, 0))
        listBg:addChild(scrollView)

--内容bg
        local contentBg = CCNode:create()
        scrollView:addChild(contentBg)
        contentBg:setPosition(ccp(0, 0))
        contentBg:setAnchorPoint(ccp(0, 0))

    --内容
        if(table.isEmpty(BossData.rankList)) then
            return nil
        end
        -- if(table.count(BossData.rankList)) then
        --     scrollView:isc
        -- end
        if(table.count(BossData.rankList) < 6) then
            scrollView:setTouchEnabled(false)
        end
        print("the BossData.rankList is ?????")
        print_t(BossData.rankList)
        for i,v in ipairs(BossData.rankList) do
            local cellBackground = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
            cellBackground:setContentSize(CCSizeMake(583, 112))
            cellBackground:setAnchorPoint(ccp(0, 0))
            contentBg:addChild(cellBackground)
            cellBackground:setPosition(ccp(10, scrollView:getContentSize().height - i*110))

            local rankIcon = CCSprite:create("images/boss/rank_bg.png")
            rankIcon:setAnchorPoint(ccp(0, 0.5))
            cellBackground:addChild(rankIcon)
            rankIcon:setPosition(ccp(10, cellBackground:getContentSize().height/2))

            if(i < 4) then
                local rankNum = "images/boss/rank_" .. i ..".png"
                local rankNumIcon = CCSprite:create(rankNum)
                rankNumIcon:setAnchorPoint(ccp(0.5, 0.5))
                rankIcon:addChild(rankNumIcon)
                rankNumIcon:setPosition(ccp(rankIcon:getContentSize().width/2, rankIcon:getContentSize().height/2))
            else
                local rankNum = CCRenderLabel:create(i, g_sFontPangWa, 48, 1, ccc3(0,0,0))
                rankNum:setPosition(ccp(rankIcon:getContentSize().width/2, rankIcon:getContentSize().height/2))
                rankNum:setColor(ccc3(0xff, 0xff, 0xff))
                rankNum:setAnchorPoint(ccp(0.5, 0.5))
                rankIcon:addChild(rankNum)
            end

            -- 名字label
            local nameBg = CCScale9Sprite:create("images/boss/boss_rank_bg.png")
            nameBg:setContentSize(CCSizeMake(420, 33))
            nameBg:setAnchorPoint(ccp(0.5, 1))
            cellBackground:addChild(nameBg)
            nameBg:setPosition(ccp(cellBackground:getContentSize().width/2 + 20, 100))


            local lvSprite = CCSprite:create("images/common/lv.png")
            -- lvSprite:setPosition(ccp(80, nameBg:getContentSize().height/2))
            lvSprite:setPosition(ccp(20, nameBg:getContentSize().height/2))
            lvSprite:setAnchorPoint(ccp(0, 0.5))
            nameBg:addChild(lvSprite)

            local LvLabel = CCRenderLabel:create(v.level, g_sFontName, 23, 1, ccc3(0,0,0))
            -- LvLabel:setPosition(ccp(120, nameBg:getContentSize().height/2))
            LvLabel:setPosition(ccp(lvSprite:getContentSize().width + lvSprite:getPositionX() + 5, nameBg:getContentSize().height/2))
            LvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
            LvLabel:setAnchorPoint(ccp(0, 0.5))
            nameBg:addChild(LvLabel)

            local nameLabel = CCRenderLabel:create(v.name, g_sFontName, 23, 1, ccc3(0,0,0))
            nameLabel:setPosition(ccp(LvLabel:getContentSize().width + LvLabel:getPositionX() + 20, nameBg:getContentSize().height/2))
            nameLabel:setColor(ccc3(0xf9, 0x59, 0xff))
            nameLabel:setAnchorPoint(ccp(0, 0.5))
            nameBg:addChild(nameLabel)
            if(i == 2) then
                nameLabel:setColor(ccc3(0x00, 0xef, 0xff))
            elseif(i == 3) then
                nameLabel:setColor(ccc3(0x00, 0xff, 0x18))
            elseif(i == 1) then
            else
                nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
            end
        --军团名称
            if(v.guild_name) then
                local guildLabel = CCRenderLabel:create("["..v.guild_name.."]", g_sFontName, 21, 1, ccc3(0,0,0))
                -- LvLabel:setPosition(ccp(120, nameBg:getContentSize().height/2))
                guildLabel:setPosition(ccp(nameLabel:getContentSize().width + nameLabel:getPositionX() + 20, nameBg:getContentSize().height/2))
                guildLabel:setColor(ccc3(0xff, 0xf6, 0x00))
                guildLabel:setAnchorPoint(ccp(0, 0.5))
                nameBg:addChild(guildLabel)
            end


        --伤害
            local bloodLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1274"),g_sFontName,23)
            bloodLabel:setPosition(ccp(180, 30))
            bloodLabel:setColor(ccc3(0x78, 0x25, 0x00))
            bloodLabel:setAnchorPoint(ccp(0, 0.5))
            cellBackground:addChild(bloodLabel)

            local bloodDataLabel = CCLabelTTF:create(v.hpCost,g_sFontName,23)
            bloodDataLabel:setPosition(ccp(300, 30))
            bloodDataLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
            bloodDataLabel:setAnchorPoint(ccp(0, 0.5))
            cellBackground:addChild(bloodDataLabel)

            --阵型按钮
            local formationMenu = CCMenu:create()
            formationMenu:setPosition(ccp(0, 0))
            cellBackground:addChild(formationMenu)

            local closeButton = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
            closeButton:setPosition(cellBackground:getContentSize().width * 0.85, 35)
            closeButton:setAnchorPoint(ccp(0.5, 0.5))
            closeButton:registerScriptTapHandler(showFormation)
            print("the uid is >>> ", v.uid)
            formationMenu:addChild(closeButton, 9999)
            formationMenu:setTouchPriority(-454)
            formationMenu:setTag(v.uid)
            closeButton:setTag(v.uid)

            local formationLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1133"), g_sFontPangWa, 30, 1, ccc3(0,0,0))
            formationLabel:setPosition(ccp(closeButton:getContentSize().width/2, closeButton:getContentSize().height/2))
            formationLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
            formationLabel:setAnchorPoint(ccp(0.5, 0.5))
            closeButton:addChild(formationLabel)
        end
    end)

end

function showFormation(tag, sender)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print("showFormation is on", tag)

    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(tag), nil, nil ,false,false, true)
end

function changeInspireTime()
    local nowTime = BTUtil:getSvrTimeInterval()
    if(not lastInspireTime) then
        lastInspireTime = nowTime - 45
        print("the now lastAttackTime is ".. lastInspireTime)
    end
    local leftCD = tonumber(nowTime - lastInspireTime)
    local fightCD = DB_Worldbossinspire.getDataById(1).inspireCd
    local leftInspireCD = tonumber(fightCD - leftCD)

    local leftTime = TimeUtil.getTimeString(leftInspireCD)
    inspireCDLabel:setString(leftTime)
    if(leftInspireCD <= 0) then
        inspireCDLabel:setVisible(false)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(inspireScheduleTag)
    end
end


function changeLeftTime( ... )
    require "script/utils/TimeUtil"

    local nowTime = BTUtil:getSvrTimeInterval()
    local sh = DB_Worldboss.getDataById(1)

    local beginTime = DB_Worldboss.getDataById(1).dayBeginTime
    local endTime = DB_Worldboss.getDataById(1).dayEndTime
    local bTime = TimeUtil.getIntervalByTime(tonumber(beginTime))
     --添加bossoffset
    bTime = bTime + BossData.getBossTimeOffset()
    local eTime = TimeUtil.getIntervalByTime(tonumber(endTime))
    eTime = eTime + BossData.getBossTimeOffset()
    local leftTime = nil
    print("change left time")
    if(tonumber(bTime - nowTime) >= 0) then
--开始前
    print("before boss fight")
        leftTime = TimeUtil.getTimeString(tonumber(bTime - nowTime))
        if(tonumber(bTime - nowTime) == 0) then
            -- print("enter the r(bTime - nowTime) ")
            --显示进入按钮,隐藏剩余时间
            leftTimeLabel:removeFromParentAndCleanup(true)
            leftTimeLabel = nil
            bossLayer:removeChildByTag(909099, true)
            -- bossLayer:removeChildByTag(909098, true)
            if _formationBtn ~= nil then
                _formationBtn:removeFromParentAndCleanup(true)
            end

            local enterItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(230, 75),GetLocalizeStringBy("key_2390"),ccc3(0xff, 0xff, 0xff),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
            enterItem:setAnchorPoint(ccp(0.5, 0.5))
            enterItem:setPosition(ccp(0, 0))
            enterItem:registerScriptTapHandler(enterFightBoss)
            local enterMenu = CCMenu:createWithItem(enterItem)
            bossLayer:addChild(enterMenu)
            enterMenu:setPosition(ccp(winSize.width/2, 75*g_fElementScaleRatio))
            enterMenu:setTouchPriority(-400)
            enterMenu:setScale(g_fElementScaleRatio)

            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)
            return
        end
    elseif(tonumber(eTime - nowTime) >= 0) and (tonumber(bossIsDead) == 0) then
--开始了,世界boss 没有死
        print("in boss fight")
        leftTime = TimeUtil.getTimeString(tonumber(eTime - nowTime))
        if(tonumber(eTime - nowTime) == 0) then
            print("begin over")
        --倒计时停止
                --停止自动攻击
            isAutoFight = false
            leftTime = 0
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)

            if(fightScheduleTag) then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(fightScheduleTag)
            end
            print("begin over ++++++++")
            -- 为防止前后端时间误差 delay1秒 发over请求
            performWithDelay(bossLayer,createFightPrize,1)
        end
    else
--结束了
        print("after boss fight")
        bTime = bTime + 24*3600
        -- print("the btime is ...",bTime)
        -- print("nowTime is ...",nowTime)
        leftTime = TimeUtil.getTimeString(tonumber(bTime - nowTime))
    end
    if(leftTimeLabel) then
        leftTimeLabel:setString(leftTime)
    end
    print("the lefttime is >>>",leftTime)
end


function changeFightCD( ... )
---最后几秒2个两个的减
    local nowTime = BTUtil:getSvrTimeInterval()
    print("the lastAttackTime is ".. lastAttackTime)
    if(not lastAttackTime) then
        lastAttackTime = nowTime - 45
        print("the now lastAttackTime is ".. lastAttackTime)
    end
    local leftCD = tonumber(nowTime - lastAttackTime)
    --世界boss fight cd 添加1次
    local fightCD = DB_Worldbossinspire.getDataById(1).cd + 1
    leftFightCD = tonumber(fightCD - leftCD)

    local leftTime = TimeUtil.getTimeString(tonumber(leftFightCD))
    fightButtonLabel:setString(leftTime)
    fightButtonLabel:setVisible(true)
    fightButtonLabel2:setVisible(false)
    print("the leftFightCD is ",leftFightCD)

    if(leftFightCD <= 0) then
        fightButtonLabel:setVisible(false)
        fightButtonLabel2:setVisible(true)
        -- rebirthItem:setEnabled(false)
        -- setRirthColor(1)

        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(fightScheduleTag)
        --判断自动攻击
        if(isAutoFight) then
            fightBoss()
        end
        return
    end
    -- rebirthItem:setEnabled(true)
    -- setRirthColor(2)
end

function enterFightBoss()
    sendEnterBoss()
    closeBeforeBoss()
    bossLayer:removeAllChildrenWithCleanup(true)
end

function closeSelf()
    print("in leave closeSelf")

    if(tonumber(isInFight) == 1) then
    --判断是不是结束
        print("in leave isInFight")
            -- 弹出确认提示框
        if(isAutoFight) then
            require "script/ui/tip/AlertTip"
            local str = GetLocalizeStringBy("key_2332")
            AlertTip.showAlert( str, yesToreceive, true)
            return
        end
    end
    BossNet.leaveBoss(leaveBoss)
end

function yesToreceive(param_1, param_2)
    if(param_1 == true) then
        BossNet.leaveBoss(leaveBoss)
    end
end

function leaveBoss( ... )
    print("in leave boss")
    require "script/battle/BattleLayer"
    if(BattleLayer.isBattleOnGoing) then
        isInfightNet = 1
        return
    end

--注销推送
    remove_push_boss()
--注销断网回调
    LoginScene.removeObserverForNetBroken(netKey)
--可能有界面没有关闭
    closeButtonCallback()


    closeBoss()
    closeBeforeBoss()
    bossLayer = nil

    -- 关闭弹幕
    require "script/ui/bulletLayer/BulletLayer"
    BulletLayer.closeLayer()
    require "script/ui/bulletLayer/InputChatLayer"
    InputChatLayer.closeButtonCallback()

--如果实在战斗中则不掉音乐
    AudioUtil.playBgm("audio/main.mp3")

    require "script/ui/active/ActiveList"
    local  activeList = ActiveList.createActiveListLayer()
    MainScene.changeLayer(activeList, "activeList")
end


function showFightBoss( ... )
--播放音乐
    local music = nil
    if(_isNewBoos)then
        music = DB_Worldboss.getDataById(1).boss2BackGroundMusic
    else
        music = DB_Worldboss.getDataById(1).backGroundMusic
    end
    AudioUtil.playBgm("audio/bgm/"..music)
--背景
    local bg = CCSprite:create("images/boss/boss_bg.jpg")
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bossLayer:addChild(bg)
    bg:setScale(g_fBgScaleRatio)
    bg:setPosition(ccp(winSize.width/2, winSize.height/2))
--青龙特效
 -- 动画
    local boosEffectFile = nil
    if(_isNewBoos)then
        boosEffectFile = "images/boss/effect/wordboss_lvlong"
    else
        boosEffectFile = "images/boss/effect/wordboss"
    end
    local loadEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(boosEffectFile), -1,CCString:create(""));
    loadEffectSprite:retain()
    loadEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadEffectSprite:setPosition(ccp(winSize.width/2, winSize.height/2))
    bossLayer:addChild(loadEffectSprite)
    loadEffectSprite:release()
    loadEffectSprite:setScale(g_fBgScaleRatio)

--顶部
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bossLayer:addChild(menu)
    menu:setTouchPriority(- 400)
    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/boss/back_normal.png","images/boss/back_selected.png")
    backItem:registerScriptTapHandler(closeSelf)
    backItem:setAnchorPoint(ccp(1,0))
    menu:addChild(backItem)
    local posY = bossLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX - bossLayer:getChildByTag(19876):getContentSize().height*bossLayer:getChildByTag(19876):getScale()-150*g_fScaleX
    backItem:setPosition(bossLayer:getContentSize().width*0.95,posY)
    backItem:setScale(g_fScaleX)
    -- 排名按钮
    local rankItem = CCMenuItemImage:create("images/common/btn/btn_hurt_n.png", "images/common/btn/btn_hurt_h.png")
    rankItem:registerScriptTapHandler(fightRank)
    rankItem:setAnchorPoint(ccp(0,0))
    menu:addChild(rankItem)
    rankItem:setPosition(ccp(bossLayer:getContentSize().width*0.05,posY))
    rankItem:setScale(g_fScaleX)
    -- 奖励预览按钮
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0,1))
    local posY = rankItem:getPositionY()-10*g_fScaleX
    rewardMenuItem:setPosition(ccp(bossLayer:getContentSize().width*0.05, posY))
    menu:addChild(rewardMenuItem)
    rewardMenuItem:registerScriptTapHandler(fnRewardMenuAction)
    rewardMenuItem:setScale(g_fScaleX)

-- 血量
    local bloodBg = CCScale9Sprite:create("images/boss/blood_bg.png")
    bloodBg:setContentSize(CCSizeMake(winSize.width, 60*g_fScaleX))
    bloodBg:setAnchorPoint(ccp(0.5, 1))
    bossLayer:addChild(bloodBg)
    bloodBg:setPosition(ccp(winSize.width/2, winSize.height - 80*g_fElementScaleRatio))

    local sh = DB_Worldboss.getDataById(1)
    local beginTime = DB_Worldboss.getDataById(1).dayBeginTime

--名字
    local nameFont = nil
    if(_isNewBoos)then
        nameFont =  DB_Worldboss.getDataById(1).boss2name
    else
        nameFont = DB_Worldboss.getDataById(1).name
    end
    local nameLabel = CCRenderLabel:create(nameFont, g_sFontPangWa, 23, 1, ccc3(0,0,0))
    nameLabel:setPosition(ccp(winSize.width/8, bloodBg:getContentSize().height/2))
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setScale(g_fScaleX)
    bloodBg:addChild(nameLabel)

    local level = BossData.bossInfo.level
    local lvSprite = createLvLabel(level, ccp(winSize.width/4, bloodBg:getContentSize().height/2))
    lvSprite:setScale(g_fScaleX)
    bloodBg:addChild(lvSprite)

--血条
    -- blood_bottom = CCSprite:create("images/boss/blood_bottom.png")
    blood_bottom = CCScale9Sprite:create("images/boss/blood_bottom.png")
    blood_bottom:setContentSize(CCSizeMake(243, 35))

    blood_bottom:setAnchorPoint(ccp(0, 0.5))
    blood_bottom:setScale(g_fScaleX)
    bloodBg:addChild(blood_bottom)
    blood_bottom:setPosition(ccp(250/640*winSize.width, bloodBg:getContentSize().height/2))

    setBossBlood()

--剩余时间
    local nowTime = BTUtil:getSvrTimeInterval()
    local sh = DB_Worldboss.getDataById(1)
    local endTime = DB_Worldboss.getDataById(1).dayEndTime
    require "script/utils/TimeUtil"
    local eTime = TimeUtil.getIntervalByTime(tonumber(endTime))
    eTime = eTime + BossData.getBossTimeOffset()

    local leftTime = TimeUtil.getTimeString(tonumber(eTime - nowTime))
    print("the leftTIme +++++++++  >>>> ",leftTime)

    if(leftTimeLabel) then
        leftTimeLabel:removeFromParentAndCleanup(true)
        leftTimeLabel = nil
    end

    leftTimeLabel = CCLabelTTF:create(leftTime, g_sFontName, 23)
    leftTimeLabel:setColor(ccc3(0xff, 0xff, 0xff))
    leftTimeLabel:setScale(g_fScaleX)
    bloodBg:addChild(leftTimeLabel)
    leftTimeLabel:setAnchorPoint(ccp(0,0.5))
    leftTimeLabel:setPosition(ccp(520/640*winSize.width, bloodBg:getContentSize().height/2))

    scheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeLeftTime, 1, false)

    createDownUI()

    createInspire()
end

--设置血量
function setBossBlood()
    print("BossData.bossInfo is" )
    print_t(BossData.bossInfo)
    --防止打完后，后端还推送
    if(tonumber(BossData.bossInfo.boss_time) == 0) then
        return
    end

    local nowHp = tonumber(BossData.bossInfo.hp)
    local maxHp = tonumber( BossData.bossInfo.boss_maxhp)
    local percent = tonumber(nowHp)/tonumber(maxHp)
    print("the nowHp is "..nowHp.. "  the maxhp ..",maxHp)
    print("the percent is >>> "..percent)
    local maxWidth = blood_bottom:getContentSize().width
    local nowWidth = maxWidth*percent*0.98
    print("the nowWidth is >>> "..nowWidth)

    local nowBlood = CCScale9Sprite:create("images/boss/blood_base.png")
    nowBlood:setContentSize(CCSizeMake(nowWidth, 28))
    nowBlood:setAnchorPoint(ccp(0, 0.5))
    nowBlood:setPosition(ccp(4, blood_bottom:getContentSize().height/2 + 1))
    blood_bottom:addChild(nowBlood, 1, 909012)

    local bloodLabel = CCRenderLabel:create(nowHp .."/".. maxHp, g_sFontName, 23, 1, ccc3(0,0,0))
    bloodLabel:setPosition(ccp(blood_bottom:getContentSize().width/2, blood_bottom:getContentSize().height/2))
    bloodLabel:setColor(ccc3(0xff, 0xff, 0xff))
    bloodLabel:setAnchorPoint(ccp(0.5, 0.5))
    blood_bottom:addChild(bloodLabel, 1, 909011)
end

function createInspire( ... )

    local silverItem = CCMenuItemImage:create("images/boss/silver_inspire_normal.png", "images/boss/silver_inspire_selected.png")
    silverItem:registerScriptTapHandler(silverInspire)
    silverItem:setPosition(0, 0)
    silverItem:setAnchorPoint(ccp(0.5, 0.5))
    silverItem:setScale(g_fElementScaleRatio)

    local silverIcon = CCSprite:create("images/common/coin.png")
    silverItem:addChild(silverIcon)
    silverIcon:setAnchorPoint(ccp(0.5, 1))
    silverIcon:setPosition(ccp(silverItem:getContentSize().width/2 - 25, - 5))

    local needSilver = DB_Worldbossinspire.getDataById(1).inspireSilver

    local silverCostLabel = CCRenderLabel:create(needSilver, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    silverCostLabel:setColor(ccc3(0xff, 0xff, 0xff))
    silverItem:addChild(silverCostLabel)
    silverCostLabel:setAnchorPoint(ccp(0, 0.5))
    silverCostLabel:setPosition(ccp(silverItem:getContentSize().width/2, - 20))


    inspireCDLabel = CCRenderLabel:create(0, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    inspireCDLabel:setColor(ccc3(0x00, 0xef, 0x16))
    silverItem:addChild(inspireCDLabel, 1)
    inspireCDLabel:setAnchorPoint(ccp(0.5, 0.5))
    inspireCDLabel:setPosition(ccp(silverItem:getContentSize().width/2, silverItem:getContentSize().height/2))

--剩余cd时间
    lastInspireTime = BossData.bossInfo.inspire_time_silver
    local needCD = DB_Worldbossinspire.getDataById(1).inspireCd
    if(not needCD) then
        inspireCDLabel:setVisible(false)
    else
        local nowTime = BTUtil:getSvrTimeInterval()
        local leftInspireCD = tonumber(needCD) - tonumber(nowTime - lastInspireTime)

        if (leftInspireCD > 0) then
            local leftTime = TimeUtil.getTimeString(leftInspireCD)
            inspireScheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeInspireTime, 1, false)
            inspireCDLabel:setString(leftTime)
        else
            inspireCDLabel:setVisible(false)
        end
    end

    local goldItem = CCMenuItemImage:create("images/boss/gold_inspire_normal.png", "images/boss/gold_inspire_selected.png")
    goldItem:registerScriptTapHandler(goldInspire)
    goldItem:setPosition(0, 0)
    goldItem:setAnchorPoint(ccp(0.5, 0.5))
    goldItem:setScale(g_fElementScaleRatio)

    local goldIcon = CCSprite:create("images/common/gold.png")
    goldItem:addChild(goldIcon)
    goldIcon:setAnchorPoint(ccp(0.5, 1))
    goldIcon:setPosition(ccp(goldItem:getContentSize().width/2 - 25, - 5))

    local needGold = DB_Worldbossinspire.getDataById(1).inspireGold
    local goldCostLabel = CCRenderLabel:create(needGold, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    goldCostLabel:setColor(ccc3(0xff, 0xff, 0xff))
    goldItem:addChild(goldCostLabel)
    goldCostLabel:setAnchorPoint(ccp(0, 0.5))
    goldCostLabel:setPosition(ccp(goldItem:getContentSize().width/2 , - 20))

    local menuArray = CCArray:create()
    menuArray:addObject(silverItem)
    menuArray:addObject(goldItem)

    local rankMenu = CCMenu:createWithArray(menuArray)
    rankMenu:setTouchPriority(-400)
    bossLayer:addChild(rankMenu)
    rankMenu:setAnchorPoint(ccp(0.5, 0.5))
    rankMenu:setPosition(ccp(winSize.width/2, 270*g_fElementScaleRatio))
    rankMenu:alignItemsHorizontallyWithPadding(150*g_fElementScaleRatio)

    -- 弹幕按钮
    require "script/ui/bulletLayer/BulletDef"
    require "script/ui/bulletLayer/BulletUtil"
    local tanMenu = CCMenu:create()
    tanMenu:setPosition(ccp(0,0))
    tanMenu:setTouchPriority(-400)
    bossLayer:addChild(tanMenu)

    local tanButton = BulletUtil.createItem( BulletType.SCREEN_TYPE_BOSS )
    tanMenu:addChild(tanButton)
    tanButton:setAnchorPoint(ccp(1, 0.5))
    tanButton:setPosition(ccp(winSize.width-10*g_fElementScaleRatio, 270*g_fElementScaleRatio))
    tanButton:setScale(g_fElementScaleRatio)
end

function silverInspire()
    local maxInspireLevel = DB_Worldbossinspire.getDataById(1).maxLv
    print("the bossInfo is ....")
    print_t(BossData.bossInfo)
    local inspireTime = BossData.bossInfo.inspire
    if(tonumber(inspireTime) == tonumber(maxInspireLevel)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3018"))
        return nil
    end

    local needSilver = DB_Worldbossinspire.getDataById(1).inspireSilver
    if(UserModel.getSilverNumber() < needSilver) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        return
    end
    if(inspireCDLabel:isVisible()) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2979"))
        return
    end

    BossNet.silverInspire(function ( ... )

        if (tostring(BossData.inspireInfo) == "true") then
            BossData.bossInfo.inspire = tonumber(BossData.bossInfo.inspire) + 1
            local inspireTime = BossData.bossInfo.inspire
            local inspireArr = DB_Worldbossinspire.getDataById(1).inspireArr
            inspireArr = string.split(inspireArr, ",")
            local baseInspire = string.split(inspireArr[1], "|")

            local inspireNumber = inspireTime * baseInspire[2] / 100
            fightAddData:setString(inspireNumber.."%")
            AnimationTip.showTip(GetLocalizeStringBy("key_3259"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("key_1416"))
        end
        lastInspireTime = BTUtil:getSvrTimeInterval()
        local leftInspireCD = DB_Worldbossinspire.getDataById(1).inspireCd
        if((tonumber(leftInspireCD) == 0) or (not leftInspireCD)) then
            inspireCDLabel:setVisible(false)
        else
            local leftTime = TimeUtil.getTimeString(leftInspireCD)
            inspireCDLabel:setString(leftTime)
            inspireCDLabel:setVisible(true)
            inspireScheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeInspireTime, 1, false)
        end
        local userInfo = UserModel.addSilverNumber(-tonumber(needSilver))
        -- modified by yangrui at 2015-12-03
        m_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
        print("silver inspire")
    end)
end

function goldInspire()
    local maxInspireLevel = DB_Worldbossinspire.getDataById(1).maxLv
    print("the max inspire time is ".. maxInspireLevel)
    local inspireTime = BossData.bossInfo.inspire
    print("the inspire time is .. "..inspireTime)
    if(tonumber(inspireTime) >= tonumber(maxInspireLevel)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3018"))
        return nil
    end
    local needGold = DB_Worldbossinspire.getDataById(1).inspireGold
    if(UserModel.getGoldNumber() < needGold)then
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return nil
    end

    BossNet.goldInspire(function ( ... )
        local userInfo = UserModel.addGoldNumber(- tonumber(needGold))
        m_goldLabel:setString(UserModel.getGoldNumber())
        AnimationTip.showTip(GetLocalizeStringBy("key_3259"))

        BossData.bossInfo.inspire = tonumber(BossData.bossInfo.inspire) + 1
        local inspireTime = BossData.bossInfo.inspire
        local inspireArr = DB_Worldbossinspire.getDataById(1).inspireArr
        print_t(inspireArr)
        inspireArr = string.split(inspireArr, ",")
        print_t(inspireArr)
        local baseInspire = string.split(inspireArr[1], "|")

        local inspireNumber = inspireTime * baseInspire[2] / 100
        fightAddData:setString(inspireNumber.."%")
        return nil
    end)

    print("gold inspire")
end

--下面的ui
function createDownUI( ... )
    local downBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")
    downBg:setAnchorPoint(ccp(0.5, 0))
    downBg:setContentSize(CCSizeMake(winSize.width - 50*g_fElementScaleRatio, 150*g_fElementScaleRatio))
    downBg:setPosition(ccp(winSize.width/2, 20*g_fElementScaleRatio))
    bossLayer:addChild(downBg)
    -- AdaptTool.setAdaptNode(downBg)

--已攻击次数
    local fightTimeSp = CCSprite:create("images/boss/fight_time.png")
    downBg:addChild(fightTimeSp)
    fightTimeSp:setPosition(ccp(60*g_fElementScaleRatio, 130*g_fElementScaleRatio))
    fightTimeSp:setAnchorPoint(ccp(0, 0.5))
    fightTimeSp:setScale(g_fElementScaleRatio)


    local fightTime = BossData.bossInfo.attack_num
    fightTimesLabel = CCRenderLabel:create(fightTime, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightTimesLabel:setColor(ccc3(0x00, 0xef, 0x16))
    fightTimeSp:addChild(fightTimesLabel)
    fightTimesLabel:setAnchorPoint(ccp(0.5, 0.5))
    fightTimesLabel:setPosition(ccp(98, 16))

    local fightTotal = BossData.bossInfo.attack_hp
    local fightPercent = tonumber(BossData.bossInfo.attack_hp)/tonumber(BossData.bossInfo.boss_maxhp)*100

    fightPercent = string.format("%6.2f",fightPercent)

    attackTotalLabel = CCRenderLabel:create(fightTotal.."("..fightPercent.."%)", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attackTotalLabel:setColor(ccc3(0x00, 0xef, 0x16))
    fightTimeSp:addChild(attackTotalLabel)
    attackTotalLabel:setAnchorPoint(ccp(0, 0.5))
    attackTotalLabel:setPosition(ccp(305, 16))


--攻击加成
    local fightAdd = CCSprite:create("images/boss/fight_add.png")
    downBg:addChild(fightAdd)
    fightAdd:setPosition(ccp(60*g_fElementScaleRatio, 95*g_fElementScaleRatio))
    fightAdd:setAnchorPoint(ccp(0, 0.5))
    fightAdd:setScale(g_fElementScaleRatio)

    local inspireTime = BossData.bossInfo.inspire
    local inspireArr = DB_Worldbossinspire.getDataById(1).inspireArr
    print_t(inspireArr)
    inspireArr = string.split(inspireArr, ",")
    print_t(inspireArr)
    local baseInspire = string.split(inspireArr[1], "|")

    local inspireNumber = inspireTime * baseInspire[2] / 100
    fightAddData = CCRenderLabel:create(inspireNumber.."%", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightAddData:setColor(ccc3(0x00, 0xef, 0x16))
    downBg:addChild(fightAddData)
    fightAddData:setPosition(ccp(175*g_fElementScaleRatio, 95*g_fElementScaleRatio))
    fightAddData:setAnchorPoint(ccp(0, 0.5))
    fightAddData:setScale(g_fElementScaleRatio)

--攻击排名
    local rankBg = CCSprite:create("images/boss/now_rank.png")
    downBg:addChild(rankBg)
    rankBg:setPosition(ccp(310*g_fElementScaleRatio, 95*g_fElementScaleRatio))
    rankBg:setAnchorPoint(ccp(0, 0.5))
    rankBg:setScale(g_fElementScaleRatio)

    local rankData = BossData.bossInfo.atk_rank
    print("fasdfasdf ")
    print_t(BossData.bossInfo)
    playerRankLabel = CCRenderLabel:create(rankData, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    playerRankLabel:setColor(ccc3(0x00, 0xef, 0x16))
    downBg:addChild(playerRankLabel)
    playerRankLabel:setAnchorPoint(ccp(0, 0.5))
    playerRankLabel:setPosition(ccp(410*g_fElementScaleRatio, 95*g_fElementScaleRatio))
    playerRankLabel:setScale(g_fElementScaleRatio)

-- 自动攻击
    local fullRect = CCRectMake(0, 0, 119, 64)
    local insetRect = CCRectMake(30, 30, 1, 1)
    local autoBg1 = CCScale9Sprite:create("images/boss/auto_fight_normal.png", fullRect, insetRect)
    autoBg1:setPreferredSize(CCSizeMake(160, 64))
    local autoBg2 = CCScale9Sprite:create("images/boss/auto_fight_selected.png", fullRect, insetRect)
    autoBg2:setPreferredSize(CCSizeMake(160, 64))

    local autoItem = CCMenuItemSprite:create(autoBg1,autoBg2)
    autoItem:registerScriptTapHandler(setAutoFight)
    autoItem:setPosition(ccp(30*g_fElementScaleRatio, 10*g_fElementScaleRatio))
    autoItem:setTag(1)  -- 默认是1，表示 开始自动攻击
    local autoMenu = CCMenu:createWithItem(autoItem)
    autoMenu:setTouchPriority(-400)
    downBg:addChild(autoMenu)
    autoMenu:setPosition(ccp(0, 0))
    autoMenu:setScale(g_fElementScaleRatio)

    autoFightLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1668"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    autoFightLabel:setColor(ccc3(0xff, 0xff, 0xff))
    autoItem:addChild(autoFightLabel)
    autoFightLabel:setPosition(ccp(autoItem:getContentSize().width/2, autoItem:getContentSize().height/2))
    autoFightLabel:setAnchorPoint(ccp(0.5, 0.5))
    -- autoFightLabel:setScale(g_fElementScaleRatio)

    isAutoFight = false

-- 攻击按钮
    require "script/libs/LuaCC"
    rebirthItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", "images/common/btn/btn1_g.png",CCSizeMake(200,73))
    rebirthItem:registerScriptTapHandler(playerRebirth)
    rebirthItem:setPosition(0, 0)
    rebirthItem:setAnchorPoint(ccp(0.5, 0.5))
    rebirthItem:setScale(g_fElementScaleRatio)
--复活
    local rebirthLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1035"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rebirthLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    rebirthItem:addChild(rebirthLabel,1,90903)
    rebirthLabel:setPosition(ccp(rebirthItem:getContentSize().width/2 - 40, rebirthItem:getContentSize().height/2))
    rebirthLabel:setAnchorPoint(ccp(0.5, 0.5))

    local goldSp = CCSprite:create("images/common/gold.png")
    rebirthItem:addChild(goldSp,1,90904)
    goldSp:setPosition(ccp(rebirthItem:getContentSize().width/2 , rebirthItem:getContentSize().height/2))
    goldSp:setAnchorPoint(ccp(0, 0.5))

    local rebirthBase = DB_Worldbossinspire.getDataById(1).rebirthBaseGold
    local rebirthGrow = DB_Worldbossinspire.getDataById(1).rebirthGrowGold
    local rebirthTime = tonumber(BossData.bossInfo.revive)
    local needGold = rebirthBase
    if(rebirthTime > 0) then
        needGold = rebirthBase + rebirthGrow*(rebirthTime)
    end
    rebirthGold = CCRenderLabel:create(needGold, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rebirthGold:setColor(ccc3(0xff, 0xf6, 0x00))
    rebirthItem:addChild(rebirthGold,1,90905)
    rebirthGold:setPosition(ccp(rebirthItem:getContentSize().width/2 + 50, rebirthItem:getContentSize().height/2))
    rebirthGold:setAnchorPoint(ccp(0.5, 0.5))

--需要写花费金币，和剩余时间
    local attackItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png","images/common/btn/btn1_g.png" , CCSizeMake(160,73))
    attackItem:registerScriptTapHandler(attackBoss)
    attackItem:setPosition(0, 0)
    attackItem:setAnchorPoint(ccp(0.5, 0.5))
    attackItem:setScale(g_fElementScaleRatio)


--攻击按钮
    fightButtonLabel2 = CCRenderLabel:create(GetLocalizeStringBy("key_1727"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
     -- CCRenderLabel:
    fightButtonLabel2:setColor(ccc3(0xff, 0xf6, 0x00))
    attackItem:addChild(fightButtonLabel2)
    fightButtonLabel2:setPosition(ccp(attackItem:getContentSize().width/2, attackItem:getContentSize().height/2))
    fightButtonLabel2:setAnchorPoint(ccp(0.5, 0.5))
    fightButtonLabel2:setVisible(false)


    fightButtonLabel = CCLabelTTF:create("", g_sFontPangWa, 25)
     -- CCRenderLabel:create(fightTitle, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightButtonLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    attackItem:addChild(fightButtonLabel)
    fightButtonLabel:setPosition(ccp(attackItem:getContentSize().width/2, attackItem:getContentSize().height/2))
    fightButtonLabel:setAnchorPoint(ccp(0.5, 0.5))
    fightButtonLabel:setVisible(false)

--判断有没有cd
    local fightFlag = BossData.bossInfo.flags
    if(tonumber(fightFlag) == 0) then
        lastAttackTime = BossData.bossInfo.last_attack_time

        local nowTime = BTUtil:getSvrTimeInterval()

        print("the lastAttackTime is ".. lastAttackTime)
        if(not lastAttackTime) then
            lastAttackTime = nowTime - 45
            print("the now lastAttackTime is ".. lastAttackTime)
        end
        local leftCD = tonumber(nowTime - lastAttackTime)
--鉴于可能出现前后端不一致问题，所以时间延长1秒
        local fightCD = DB_Worldbossinspire.getDataById(1).cd + 1
        leftFightCD = tonumber(fightCD - leftCD)
        if(leftFightCD <= 0) then
            leftFightCD = 0
            fightButtonLabel2:setVisible(true)
            -- rebirthItem:setEnabled(false)
            -- setRirthColor(1)
        else
            fightButtonLabel:setString(TimeUtil.getTimeString(tonumber(leftFightCD)))
            fightButtonLabel:setVisible(true)
            fightScheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeFightCD, 1, false)
        end
    else
        fightButtonLabel2:setVisible(true)
        -- rebirthItem:setEnabled(false)
        -- setRirthColor(1)
    end



    local menuArray = CCArray:create()
    menuArray:addObject(rebirthItem)
    menuArray:addObject(attackItem)

    local rankMenu = CCMenu:createWithArray(menuArray)
    rankMenu:setTouchPriority(-400)
    downBg:addChild(rankMenu)
    rankMenu:setPosition(ccp(downBg:getContentSize().width/2 + 90*g_fElementScaleRatio, downBg:getContentSize().height*0.3))
    rankMenu:alignItemsHorizontallyWithPadding(10*g_fElementScaleRatio)
    print("the rankMenu position ... >> " .. rankMenu:getPositionX()..rankMenu:getPositionY())
end

function setRirthColor(tag)
    local label = tolua.cast(rebirthItem:getChildByTag(90903),"CCRenderLabel")
    local icon = tolua.cast(rebirthItem:getChildByTag(90904),"CCSprite")
    local gold = tolua.cast(rebirthItem:getChildByTag(90905),"CCRenderLabel")
    if(tonumber(tag) == 1) then
        label:setColor(ccc3(100,100,100))
        icon:setColor(ccc3(100,100,100))
        gold:setColor(ccc3(100,100,100))
    else
        label:setColor(ccc3(0xff, 0xf6, 0x00))
        icon:setColor(ccc3(255, 255, 255))
        gold:setColor(ccc3(0xff, 0xf6, 0x00))
    end
end

function playerRebirth(tag, sender)
--是否需要复活
    if( leftFightCD == nil or leftFightCD == 0) then
        print("playerRebirth leftFightCD",leftFightCD)
        -- AnimationTip.showTip(GetLocalizeStringBy("key_3386"))
        AnimationTip.showTip(GetLocalizeStringBy("lic_1178"))
        return
    end

    local rebirthBase = DB_Worldbossinspire.getDataById(1).rebirthBaseGold
    local rebirthGrow = DB_Worldbossinspire.getDataById(1).rebirthGrowGold
    local rebirthTime = tonumber(BossData.bossInfo.revive)
    print("the rebirthTime is >>>>> "..rebirthTime)
    local needGold = rebirthBase
    if(rebirthTime > 0) then
        needGold = rebirthBase + rebirthGrow*(rebirthTime)
    end
    if(UserModel.getGoldNumber() < needGold)then
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    BossNet.rebirthBoss(function ( ... )

        local userInfo = UserModel.addGoldNumber(- tonumber(needGold))
        m_goldLabel:setString(UserModel.getGoldNumber())

        leftFightCD = 0
        fightButtonLabel:setVisible(false)
        fightButtonLabel2:setVisible(true)
        -- rebirthItem:setEnabled(false)
        -- setRirthColor(1)

        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(fightScheduleTag)

        BossData.bossInfo.revive = tonumber(BossData.bossInfo.revive) + 1
        print("the BossData.bossInfo.revive  is >>>>> ".. BossData.bossInfo.revive )

        needGold = rebirthBase + rebirthGrow*(rebirthTime+1)
        rebirthGold:setString(needGold)

        if(isAutoFight) then
            isAutoFight = false
            setAutoFight()
        end
    end)


end

function reEnterBoss( ... )
    print("reEnterBoss")

    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
    if(tonumber(isInfightNet) == 1) then
        leaveBoss()
        return
    end
    --播放音乐
    local music = nil
    if(_isNewBoos)then
        music = DB_Worldboss.getDataById(1).boss2BackGroundMusic
    else
        music = DB_Worldboss.getDataById(1).backGroundMusic
    end
    AudioUtil.playBgm("audio/bgm/"..music)
end

--每次战斗的结算面板
function settlePanel(returnBoss)
    --遮挡层
    local maskLayer = BaseUI.createMaskLayer(-600)

    -- local runningScene = CCDirector:sharedDirector():getRunningScene()
    -- runningScene:addChild(maskLayer,10,90901)

  -- 创建背景框
    local bg_sprite = BaseUI.createViewBg(CCSizeMake(520,420))
    local bg_sprite = CCScale9Sprite:create("images/upgrade/upgrade_bg.png")
    bg_sprite:setContentSize(CCSizeMake(520,420))
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width*0.5,winSize.height*0.50))
    maskLayer:addChild(bg_sprite)
    -- 适配
    setAdaptNode(bg_sprite)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(ccp(bg_sprite:getContentSize().width/2, bg_sprite:getContentSize().height-6.6 ))
    bg_sprite:addChild(titlePanel)
    local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2956"), g_sFontPangWa, 34)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(90, 10))
    titlePanel:addChild(titleLabel)

    -- 按钮
    local menu = CCMenu:create()
    menu:setTouchPriority(-610)
    menu:setPosition(ccp(0, 0))
    menu:setAnchorPoint(ccp(0, 0))
    bg_sprite:addChild(menu,2)

    -- 确定
    local okItem = createButtonItem(GetLocalizeStringBy("key_1985"))
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(reEnterBoss)
    menu:addChild(okItem,2)
    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,75))

    -- 战绩如下
    local line = CCScale9Sprite:create("images/common/line2.png")
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-85))
    bg_sprite:addChild(line)
    local font_str = GetLocalizeStringBy("key_1221")
    local font = CCRenderLabel:create(font_str, g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setAnchorPoint(ccp(0.5,0.5))
    font:setColor(ccc3(0x78,0x25,0x00))
    font:setPosition(ccp(line:getContentSize().width*0.5,line:getContentSize().height*0.5))
    line:addChild(font)

    -- 挑战伤害总值
    local bg1 = CCScale9Sprite:create("images/common/labelbg_white.png")
    bg1:setContentSize(CCSizeMake(450,45))
    bg1:setAnchorPoint(ccp(0.5,1))
    bg1:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-150))
    bg_sprite:addChild(bg1)
    local font1 = CCRenderLabel:create(GetLocalizeStringBy("key_3105"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setAnchorPoint(ccp(0,0.5))
    font1:setColor(ccc3(0xfe,0xdb,0x1c))
    font1:setPosition(ccp(10,bg1:getContentSize().height*0.5))
    bg1:addChild(font1)

    -- 伤害数值
    local harm = BossData.attackData.bossAtkHp or 0

    local font2 = CCRenderLabel:create(harm, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font2:setAnchorPoint(ccp(0,0.5))
    font2:setColor(ccc3(0xff,0x42,0x00))
    font2:setPosition(ccp(222,bg1:getContentSize().height*0.5))
    bg1:addChild(font2)

  -- 获得将魂奖励
    local bg3 = CCScale9Sprite:create("images/common/labelbg_white.png")
    bg3:setContentSize(CCSizeMake(450,45))
    bg3:setAnchorPoint(ccp(0.5,1))
    bg3:setPosition(ccp(bg_sprite:getContentSize().width*0.5, bg_sprite:getContentSize().height-220))
    bg_sprite:addChild(bg3)

    local soul = CCRenderLabel:create(GetLocalizeStringBy("key_1885"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soul:setAnchorPoint(ccp(0,0.5))
    soul:setColor(ccc3(0xfe,0xdb,0x1c))
    soul:setPosition(ccp(10, bg3:getContentSize().height*0.5))
    bg3:addChild(soul)
    local soulIcon = CCSprite:create("images/common/prestige.png")
    soulIcon:setAnchorPoint(ccp(0,0.5))
    soulIcon:setPosition(ccp(222,bg3:getContentSize().height*0.5))
    bg3:addChild(soulIcon)
    -- 获得将魂数量

    local soulData = DB_Worldboss.getDataById(1).attackRestige or 0
    local soul_data = CCRenderLabel:create(soulData, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soul_data:setAnchorPoint(ccp(0,0.5))
    soul_data:setColor(ccc3(0xd7,0xd7,0xd7))
    soul_data:setPosition(ccp(252,bg3:getContentSize().height*0.5))
    bg3:addChild(soul_data)

    return maskLayer
end

function createButtonItem( str )
    local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 字体
    local item_font = CCRenderLabel:create( str , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
    item:addChild(item_font)
    return item
end

function attackBoss( ... )
    print("the leftFightCD is ",leftFightCD)
    if(leftFightCD) and (tonumber(leftFightCD) > 0) then
        print("enter the leftFightCD the fightBoss")
        AnimationTip.showTip(GetLocalizeStringBy("key_2999"))
        return nil
    end
print("the is autoFight is ",isAutoFight)
    if(isAutoFight) then
        print("enter the isAutoFight the fightBoss")
        AnimationTip.showTip(GetLocalizeStringBy("key_1732"))
        return nil
    end
    print("before the fightBoss")
    fightBoss()
end

function fightBoss( ... )
    print("before the fightBoss,fightBoss,fightBoss,fightBoss,fightBoss")
    BossNet.attackBoss(function ( ... )
        --加1 秒 防止后端 差1秒
        leftFightCD = DB_Worldbossinspire.getDataById(1).cd + 1

        fightScheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeFightCD, 1, false)

        lastAttackTime = BTUtil:getSvrTimeInterval()
        BossData.bossInfo.last_attack_time = lastAttackTime

        if(not BossData.attackData) then
            return
        end
    --次数
        BossData.bossInfo.attack_num = tonumber(BossData.bossInfo.attack_num) + 1
        if(fightTimesLabel) then
            fightTimesLabel:setString(BossData.bossInfo.attack_num)
        end
    --总伤害
        local fightTotal = BossData.attackData.attack_hp or 0
        local maxHp = BossData.bossInfo.boss_maxhp or 1
        local fightPercent = tonumber(fightTotal)/tonumber(maxHp)*100
        fightPercent = string.format("%6.2f",fightPercent)
        attackTotalLabel:setString(fightTotal.."("..fightPercent.."%)")
    --当前排名
        local rankData = BossData.attackData.rank or " "
        print("rankData==>",BossData.attackData.rank)
        print_t(BossData.attackData)
        playerRankLabel:setString(rankData)

        --添加声望
        local soulData = DB_Worldboss.getDataById(1).attackRestige or 0
        UserModel.addPrestigeNum(soulData)

        if(not isAutoFight) then
            -- local strongholdId = DB_Worldboss.getDataById(1).strongholdId
            -- require "db/DB_Stronghold"
            -- local fire_music = DB_Stronghold.getDataById(strongholdId).fire_music
            -- local armyId = DB_Worldboss.getDataById(1).armyId

            local strongholdId = nil
            local armyId = nil
            if(_isNewBoos)then
                -- 新boos
                strongholdId = DB_Worldboss.getDataById(1).boss2StrongholdId
                armyId = DB_Worldboss.getDataById(1).boss2ArmyId
            else
                strongholdId = DB_Worldboss.getDataById(1).strongholdId
                armyId = DB_Worldboss.getDataById(1).armyId
            end
            require "db/DB_Stronghold"
            local fire_music = DB_Stronghold.getDataById(strongholdId).fire_music

            require "script/battle/BattleLayer"
            BattleLayer.showBattleWithString(BossData.attackData.fight_ret ,nil ,settlePanel(), nil, fire_music, tonumber(armyId))
        else
            showFightInfo(BossData.attackData)

            -- 弹活动声望提示
            local richInfo = {
                elements =
                {   
                    {   
                        type = "CCLabelTTF", 
                        text =  GetLocalizeStringBy("lic_1637"),
                    },
                    {
                        type = "CCSprite",
                        image = "images/common/prestige.png"
                    },
                    {   
                        type = "CCLabelTTF",
                        text =  soulData,
                    }
                }
            }
            require "script/ui/tip/RichAnimationTip"
            RichAnimationTip.showTip(richInfo)
        end
    --设置总血量
        BossData.bossInfo.hp = BossData.attackData.hp
        blood_bottom:removeChildByTag(909011, true)
        blood_bottom:removeChildByTag(909012, true)
        setBossBlood()
   
    end)
end


function showFightInfo(fightInfo)
    local fullRect = CCRectMake(0, 0, 111, 32)
    local insetRect = CCRectMake(40, 20, 1, 1)
    local fightBg = CCScale9Sprite:create("images/boss/fight_info_bg.png", fullRect, insetRect)
    fightBg:setPreferredSize(CCSizeMake(200, 35))
    bossLayer:addChild(fightBg, 1000, 909079)
    fightBg:setAnchorPoint(ccp(0.5, 0.5))
    fightBg:setScale(g_fElementScaleRatio)
--位置随机设置
    local randomX = math.random(100*g_fElementScaleRatio, winSize.width - 100*g_fElementScaleRatio)
    local randomY = math.random(1, 200*g_fElementScaleRatio)

    print("the randomX is , the randomY is ",randomX,randomY)
    fightBg:setPosition(ccp(randomX, winSize.height/2 - 100*g_fElementScaleRatio + randomY))

    local name = fightInfo.uname
    local item_font = CCRenderLabel:create( name , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(fightBg:getContentSize().width*0.5,fightBg:getContentSize().height*0.5))
    fightBg:addChild(item_font)
    -- 自己的名字 绿色
    if(tonumber(fightInfo.uid) == UserModel.getUserUid())then
        item_font:setColor(ccc3(0x00, 0xff, 0x18))
    else
        item_font:setColor(ccc3(0xff, 0xff, 0xff))
    end

    local hpLabel = LuaCC.createNumberSprite02("images/battle/number/red","-" .. fightInfo.bossAtkHp )
    hpLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    hpLabel:setAnchorPoint(ccp(0.5,0.5))
    hpLabel:setPosition(ccp(fightBg:getContentSize().width*0.5,fightBg:getContentSize().height + 40))
    fightBg:addChild(hpLabel)



    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCScaleTo:create(0.1,2))
    damageActionArray:addObject(CCScaleTo:create(0.05,1))
    damageActionArray:addObject(CCDelayTime:create(1))
    damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
    hpLabel:runAction(CCSequence:create(damageActionArray))


    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCDelayTime:create(1.2))
    layerActionArray:addObject(CCCallFunc:create(removeFightInfo))
    fightBg:runAction(CCSequence:create(layerActionArray))
end

function removeFightInfo( ... )
    bossLayer:removeChildByTag(909079, true)
end


function setAutoFight(item, tag)
    -- 自动打龙
    local isOpen, needLv, needVip = BossData.getIsOpenAutoFight()
    if( isOpen ~= true ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1516", needVip, needLv))
        return
    end

    if(isAutoFight) then
        isAutoFight = false
        autoFightLabel:setString(GetLocalizeStringBy("key_1668"))
    else
        isAutoFight = true
        autoFightLabel:setString(GetLocalizeStringBy("key_2757"))
        if(not leftFightCD) or (leftFightCD <= 0) then
           -- attackBoss()
           fightBoss()
    --判断是否在cd中，如果没有直接攻击
        end
    end
end

function createFightPrize()
     -- 关闭弹幕
    require "script/ui/bulletLayer/BulletLayer"
    BulletLayer.closeLayer()
    require "script/ui/bulletLayer/InputChatLayer"
    InputChatLayer.closeButtonCallback()
    
    print("createFightPrize .... . .. .. ")

    --判断如果在 战斗界面，那么直接跳出,不知道需不需要判断是不否那个界面
    -- require "script/battle/BattleLayer"
    -- BattleLayer.closeLayer()

    local maskLayer = BaseUI.createMaskLayer(-450)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(maskLayer,999,90902)
--分两种情况，是不是击杀

    BossNet.bossOver(function ( ... )
        print("++++++++++++BossNet.bossOver++++++++++")

        --击杀
        local background = CCScale9Sprite:create("images/common/viewbg1.png")
        background:setAnchorPoint(ccp(0.5, 0.5))
        maskLayer:addChild(background)
        background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
        AdaptTool.setAdaptNode(background)

        local killer = 0
        if(BossData.prizeData)then
            killer = BossData.prizeData.is_killer
        end
        if(tonumber(killer) == 1) then
            background:setContentSize(CCSizeMake(490, 700))
        else
            background:setContentSize(CCSizeMake(490, 520))
        end

    -- 彩带--标题
        local ribbon = CCSprite:create("images/boss/ribbon.png")
        background:addChild(ribbon)
        ribbon:setAnchorPoint(ccp(0.5, 0.5))
        ribbon:setPosition(ccp(background:getContentSize().width/2, background:getContentSize().height - 50))

        local prizeName = CCSprite:create("images/boss/boss_prize_icon.png")
        ribbon:addChild(prizeName)
        prizeName:setAnchorPoint(ccp(0.5, 0.5))
        prizeName:setPosition(ccp(ribbon:getContentSize().width/2, ribbon:getContentSize().height/2 + 40))

        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));

        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5));
        backAnimSprite:setPosition(490/2, background:getContentSize().height - 40);
        background:addChild(backAnimSprite,-1);

        local function showBg2()
            --print("================showBg2")
            local backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));

            backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5));
            backAnimSprite2:setPosition(490/2, background:getContentSize().height - 40);
            -- backAnimSprite2:setScale(scale)
            background:addChild(backAnimSprite2,-2);

        end

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(1.5))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite:runAction(CCSequence:create(layerActionArray))

        function animationFrameChanged(animationName,xmlSprite,functionName)

        end
        function animationEnd(animationName,xmlSprite,functionName)
            if(backAnimSprite~=nil)then
                backAnimSprite:cleanup()
            end
        end
        local delegate = BTAnimationEventDelegate:create()
        --delegate:retain()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        backAnimSprite:setDelegate(delegate)


        local labelTabel1 = {}
        labelTabel1[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1356"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        labelTabel1[1]:setColor(ccc3(0xff, 0xe4, 0x00))

        local normalDesNode = BaseUI.createHorizontalNode(labelTabel1)
        normalDesNode:setAnchorPoint(ccp(0.5, 0))
        normalDesNode:setPosition(background:getContentSize().width/2, background:getContentSize().height - 90)
        background:addChild(normalDesNode)

    --文字描述2
        local getPrizeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1273"), g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
        getPrizeLabel:setColor(ccc3(0x78, 0x25, 0x00))
        background:addChild(getPrizeLabel)
        getPrizeLabel:setPosition(ccp(background:getContentSize().width/2, 100))
        getPrizeLabel:setAnchorPoint(ccp(0.5, 0.5))
    --确定按钮
        local closeMenu = CCMenu:create()
        closeMenu:setPosition(ccp(0, 0))
        background:addChild(closeMenu)

        local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
        local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
        local closeButton = CCMenuItemSprite:create(normalSprite,selectSprite)
        closeButton:setPosition(background:getContentSize().width/2, 50)
        closeButton:setAnchorPoint(ccp(0.5, 0.5))
        closeButton:registerScriptTapHandler(closePrize)
        closeMenu:addChild(closeButton, 9999)
        closeMenu:setTouchPriority(-455)

        local okLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        okLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
        closeButton:addChild(okLabel)
        okLabel:setPosition(ccp(closeButton:getContentSize().width/2, closeButton:getContentSize().height/2))
        okLabel:setAnchorPoint(ccp(0.5, 0.5))

        --奖励内容
        local fullRect = CCRectMake(0, 0, 75, 75)
        local insetRect = CCRectMake(30, 30, 15, 10)
        local listBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
        if(tonumber(killer) == 1) then
            listBg:setContentSize(CCSizeMake(440, 460))
        else
            listBg:setContentSize(CCSizeMake(440, 300))
        end
        listBg:setPosition(ccp(25, 125))
        background:addChild(listBg)

        local cutF = CCSprite:create("images/boss/boss_cut_flower.png")
        cutF:setAnchorPoint(ccp(0.5, 0.5))
        listBg:addChild(cutF)
        cutF:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 30))

        local resultLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1952"), g_sFontPangWa, 23, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
        resultLabel:setColor(ccc3(0x78, 0x25, 0x00))
        listBg:addChild(resultLabel)
        resultLabel:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 25))
        resultLabel:setAnchorPoint(ccp(0.5, 0.5))

        BossData.prizeData = BossData.prizeData or {}
        if(tonumber(BossData.prizeData.is_expired) == 1) then
            return
        end
    -- 成绩
        local killStatus = CCSprite:create("images/boss/kill_status.png")
        listBg:addChild(killStatus)
        killStatus:setAnchorPoint(ccp(0, 0))
        killStatus:setPosition(ccp(65, listBg:getContentSize().height - 80))

--判断是否击杀
        local KillerTitle = GetLocalizeStringBy("key_2888")
        if(BossData.killName) then
            KillerTitle = BossData.killName..GetLocalizeStringBy("key_1800")
        end
        local killDataLabel = CCRenderLabel:create(KillerTitle, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        killDataLabel:setColor(ccc3(0xf9, 0x59, 0xff))
        listBg:addChild(killDataLabel)
        killDataLabel:setPosition(ccp(190, listBg:getContentSize().height - 80))
        killDataLabel:setAnchorPoint(ccp(0, 0))

        local fightNum = CCSprite:create("images/boss/fight_num.png")
        listBg:addChild(fightNum)
        fightNum:setAnchorPoint(ccp(0, 0))
        fightNum:setPosition(ccp(65, listBg:getContentSize().height - 110))

        print("BossData.prizeData is ...")
        print_t(BossData.prizeData)
        local attackLabel = CCRenderLabel:create(BossData.prizeData.attack_hp, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        attackLabel:setColor(ccc3(0x00, 0xe4, 0xff))
        attackLabel:setAnchorPoint(ccp(0, 0))
        listBg:addChild(attackLabel)
        attackLabel:setPosition(ccp(190, listBg:getContentSize().height - 110))
        attackLabel:setAnchorPoint(ccp(0, 0))


        local killRank = CCSprite:create("images/boss/kill_rank.png")
        listBg:addChild(killRank)
        killRank:setAnchorPoint(ccp(0, 0))
        killRank:setPosition(ccp(65, listBg:getContentSize().height - 140))

        local rankdata = BossData.prizeData.rank
        local rankLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886")..rankdata..GetLocalizeStringBy("key_1311"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rankLabel:setColor(ccc3(0xff, 0xe4, 0x00))
        rankLabel:setAnchorPoint(ccp(0, 0))
        listBg:addChild(rankLabel)
        rankLabel:setPosition(ccp(190, listBg:getContentSize().height - 140))
        rankLabel:setAnchorPoint(ccp(0, 0))

    --分割线
        local fullRect = CCRectMake(0, 0, 116, 4)
        local insetRect = CCRectMake(60, 2, 1, 1)
        local line = CCScale9Sprite:create("images/chat/spliter.png", fullRect, insetRect)
        line:setPreferredSize(CCSizeMake(450, 3))
        line:setAnchorPoint(ccp(0.5, 0.5))
        line:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 150))
        listBg:addChild(line)

        -- 奖励
        local titleBg1 = CCSprite:create("images/common/star_bg.png")
        listBg:addChild(titleBg1)
        titleBg1:setAnchorPoint(ccp(0.5, 0.5))
        titleBg1:setPosition(listBg:getContentSize().width/2, listBg:getContentSize().height - 180)

        local prizeTitle = GetLocalizeStringBy("key_1809")
        if(tonumber(killer) == 1) then
            prizeTitle = GetLocalizeStringBy("key_2639")
        end
        local tipLabel1 = CCRenderLabel:create(prizeTitle, g_sFontPangWa, 24, 1, ccc3(0,0,0))
        tipLabel1:setPosition(ccp(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2))
        tipLabel1:setColor(ccc3(0xff, 0xe4, 0x00))
        tipLabel1:setAnchorPoint(ccp(0.5, 0.5))
        titleBg1:addChild(tipLabel1)

    --获得的银币和将魂
        local silverBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        silverBg:setContentSize(CCSizeMake(410, 35))
        silverBg:setAnchorPoint(ccp(0.5, 0.5))
        silverBg:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 220))
        listBg:addChild(silverBg)

        local silverLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2470"), g_sFontName, 24)
        silverLabel:setPosition(ccp(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2))
        silverLabel:setColor(ccc3(0x78, 0x25, 0x00))
        silverLabel:setAnchorPoint(ccp(0.5, 0.5))
        silverBg:addChild(silverLabel)
        silverLabel:setPosition(ccp(90, silverBg:getContentSize().height/2))

        local silverIcon = CCSprite:create("images/common/coin.png")
        silverBg:addChild(silverIcon)
        silverIcon:setAnchorPoint(ccp(0.5, 0.5))
        silverIcon:setPosition(ccp(200, silverBg:getContentSize().height/2))

        local silverData = BossData.prizeData.reward_rank.silver or 0
        local silverDataLabel = CCLabelTTF:create(silverData, g_sFontName, 24)
        CCRenderLabel:create(silverData, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        silverDataLabel:setColor(ccc3(0x00, 0x00, 0x00))
        silverBg:addChild(silverDataLabel)
        silverDataLabel:setPosition(ccp(230, silverBg:getContentSize().height/2))
        silverDataLabel:setAnchorPoint(ccp(0, 0.5))


        local soulBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        soulBg:setContentSize(CCSizeMake(410, 35))
        soulBg:setAnchorPoint(ccp(0.5,0.5))
        soulBg:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 260))
        listBg:addChild(soulBg)

        local soulLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2090"), g_sFontName, 24)
        soulLabel:setPosition(ccp(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2))
        soulLabel:setColor(ccc3(0x78, 0x25, 0x00))
        soulLabel:setAnchorPoint(ccp(0.5, 0.5))
        soulBg:addChild(soulLabel)
        soulLabel:setPosition(ccp(90, soulBg:getContentSize().height/2))

        local soulIcon = CCSprite:create("images/common/prestige.png")
        soulBg:addChild(soulIcon)
        soulIcon:setAnchorPoint(ccp(0.5, 0.5))
        soulIcon:setPosition(ccp(200, soulBg:getContentSize().height/2))

        local soulData = BossData.prizeData.reward_rank.prestige or 0
        local soulDataLabel = CCLabelTTF:create(soulData, g_sFontName, 24)
        soulDataLabel:setColor(ccc3(0x00, 0x00, 0x00))
        soulBg:addChild(soulDataLabel)
        soulDataLabel:setPosition(ccp(230, soulBg:getContentSize().height/2))
        soulDataLabel:setAnchorPoint(ccp(0, 0.5))

 --击杀奖励
        if(tonumber(killer) == 1) then
            local titleBg2 = CCSprite:create("images/common/star_bg.png")
            listBg:addChild(titleBg2)
            titleBg2:setAnchorPoint(ccp(0.5, 0.5))
            titleBg2:setPosition(listBg:getContentSize().width/2, listBg:getContentSize().height - 300)

            local tipLabel2 = CCRenderLabel:create(GetLocalizeStringBy("key_2318"), g_sFontPangWa, 24, 1, ccc3(0,0,0))
            tipLabel2:setPosition(ccp(titleBg2:getContentSize().width/2, titleBg2:getContentSize().height/2))
            tipLabel2:setColor(ccc3(0xff, 0xe4, 0x00))
            tipLabel2:setAnchorPoint(ccp(0.5, 0.5))
            titleBg2:addChild(tipLabel2)

             --获得的银币和将魂
            local silverBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
            silverBg:setContentSize(CCSizeMake(410, 35))
            silverBg:setAnchorPoint(ccp(0.5, 0.5))
            silverBg:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 340))
            listBg:addChild(silverBg)

            local silverLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2470"), g_sFontName, 24)
            silverLabel:setPosition(ccp(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2))
            silverLabel:setColor(ccc3(0x78, 0x25, 0x00))
            silverLabel:setAnchorPoint(ccp(0.5, 0.5))
            silverBg:addChild(silverLabel)
            silverLabel:setPosition(ccp(90, silverBg:getContentSize().height/2))

            local silverIcon = CCSprite:create("images/common/coin.png")
            silverBg:addChild(silverIcon)
            silverIcon:setAnchorPoint(ccp(0.5, 0.5))
            silverIcon:setPosition(ccp(200, silverBg:getContentSize().height/2))

            local silverData = BossData.prizeData.reward_kill.silver or 0
            local silverDataLabel = CCLabelTTF:create(silverData, g_sFontName, 24)
            CCRenderLabel:create(silverData, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            silverDataLabel:setColor(ccc3(0x00, 0x00, 0x00))
            silverBg:addChild(silverDataLabel)
            silverDataLabel:setPosition(ccp(230, silverBg:getContentSize().height/2))
            silverDataLabel:setAnchorPoint(ccp(0, 0.5))


            local soulBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
            soulBg:setContentSize(CCSizeMake(410, 35))
            soulBg:setAnchorPoint(ccp(0.5,0.5))
            soulBg:setPosition(ccp(listBg:getContentSize().width/2, listBg:getContentSize().height - 380))
            listBg:addChild(soulBg)

            local soulLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2090"), g_sFontName, 24)
            soulLabel:setPosition(ccp(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2))
            soulLabel:setColor(ccc3(0x78, 0x25, 0x00))
            soulLabel:setAnchorPoint(ccp(0.5, 0.5))
            soulBg:addChild(soulLabel)
            soulLabel:setPosition(ccp(90, soulBg:getContentSize().height/2))

            local soulIcon = CCSprite:create("images/common/prestige.png")
            soulBg:addChild(soulIcon)
            soulIcon:setAnchorPoint(ccp(0.5, 0.5))
            soulIcon:setPosition(ccp(200, soulBg:getContentSize().height/2))

            local soulData = BossData.prizeData.reward_kill.prestige or 0
            local soulDataLabel = CCLabelTTF:create(soulData, g_sFontName, 24)
            soulDataLabel:setColor(ccc3(0x00, 0x00, 0x00))
            soulBg:addChild(soulDataLabel)
            soulDataLabel:setPosition(ccp(230, soulBg:getContentSize().height/2))
            soulDataLabel:setAnchorPoint(ccp(0, 0.5))
        end
    end)
end

function closePrize( ... )
    print("=======closePrize=======")
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    local childrenArray = runningScene:getChildren()
    for i=0,childrenArray:count()-1 do
        print("closePrize runningScene child:",tolua.cast(childrenArray:objectAtIndex(i),"CCNode"):getTag())
    end
    runningScene:removeChildByTag(90902, true)

    isAutoFight = false
    closeSelf()
end


function createTopUI( ... )
	local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0, bossLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
    topBg:setScale(g_fScaleX)
    bossLayer:addChild(topBg, 1,19876)

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)

    local m_powerLabel = CCRenderLabel:create("" .. UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3(0, 0, 0), type_stroke)
    m_powerLabel:setColor(ccc3(255, 0xf6, 0))
    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(m_powerLabel)

    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    m_silverLabel:setAnchorPoint(ccp(0,0.5))
    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(m_silverLabel)

    m_goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    m_goldLabel:setAnchorPoint(ccp(0,0.5))
    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(m_goldLabel)
end

-- 奖励预览
function fnRewardMenuAction( ... )
    require "script/ui/boss/BossRewardView"
    BossRewardView.showRewardView()
end














