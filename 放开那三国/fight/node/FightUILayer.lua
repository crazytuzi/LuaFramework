-- FileName: FightUILayer.lua
-- Author: lcy
-- Date: 2015-07-24
-- Purpose: 战斗相关ui显示
--[[TODO List]]

module("FightUILayer", package.seeall)

local _uiLayer          = nil
local _resLabel         = nil
local _skipButton       = nil
local _resIcon          = nil
local _doBattleBtn      = nil
local _doBattleCallback = nil
local _autoButton       = nil
local _speedButton      = nil
local _dropHeroNum      = nil
local _team1Force       = nil
local _team2Force       = nil
function init( ... )
    _uiLayer          = nil
    _resLabel         = nil
    _skipButton       = nil
    _resIcon          = nil
    _doBattleBtn      = nil
    _doBattleCallback = nil
    _autoButton       = nil
    _speedButton      = nil
    _dropHeroNum      = 0
    _team1Force       = nil
    _team2Force       = nil
end

--[[
	@des:创建uiLayer
--]]
function createLayer()
    init()
	_uiLayer = CCLayer:create()
	--顶部ui
	local topMenu = createTopUI()
	_uiLayer:addChild(topMenu)
	--底部按钮
	local bottomBtn = createBottomButton()
	_uiLayer:addChild(bottomBtn)
    --创建信息面板
    createInfoPanel()
    --创建战斗力
    createFihgthForce()

    local autoVisible = FightScene.getAutoVisible()
    local skipVisible = FightScene.getSkipVisible()
    if FightModel.getbModel() == BattleModel.SINGLE then
        setSkipVisible(skipVisible)
        setAutoVisible(false)
    else
        setAutoVisible(autoVisible)
        setSkipVisible(false)
    end
    --设置默认战斗速度
    setDefaultSpeed()

	return _uiLayer
end

--[[
	@des:创建顶部ui条
--]]
function createTopUI()

    local battleUperLayer = CCLayer:create()

    local blackBackLayer = CCLayerColor:create(ccc4(0,0,0,111))
    blackBackLayer:setContentSize(CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCDirector:sharedDirector():getWinSize().height*0.05))
    blackBackLayer:setPosition(0,CCDirector:sharedDirector():getWinSize().height*0.96)
    battleUperLayer:addChild(blackBackLayer)

    battleRoundIcon = CCLabelTTF:create(GetLocalizeStringBy("key_1672"),g_sFontName,g_winSize.height/35)
    battleRoundIcon:setAnchorPoint(ccp(0.5,0.5))
    battleRoundIcon:setPosition(g_winSize.width*0.75,g_winSize.height*0.98)
    battleUperLayer:addChild(battleRoundIcon)

    _roundLabel = CCLabelTTF:create("0/30",g_sFontName,g_winSize.height/35)
    _roundLabel:setAnchorPoint(ccp(0.5,0.5))
    _roundLabel:setPosition(g_winSize.width*0.9,g_winSize.height*0.98)
    battleUperLayer:addChild(_roundLabel)

    local startX = g_winSize.width*0.05
    local intervalX = g_winSize.width*0.11
    local labelX = g_winSize.width*0.05

    _resIcon = CCSprite:create("images/battle/icon/icon_resource.png")
    _resIcon:setAnchorPoint(ccp(0.5,0.5))
    _resIcon:setPosition(startX+intervalX*0,g_winSize.height*0.98)
    battleUperLayer:addChild(_resIcon)
    _resIcon:setScale(MainScene.elementScale)

    _resLabel = CCLabelTTF:create("0",g_sFontName,g_winSize.height/35)
    _resLabel:setAnchorPoint(ccp(0,0.5))
    _resLabel:setPosition(startX+intervalX*0.5,g_winSize.height*0.98)
    battleUperLayer:addChild(_resLabel)

    local soulIcon = CCSprite:create("images/battle/icon/icon_soul.png")
    soulIcon:setAnchorPoint(ccp(0.5,0.5))
    soulIcon:setPosition(startX+intervalX*2,g_winSize.height*0.98)
    battleUperLayer:addChild(soulIcon)
    soulIcon:setScale(MainScene.elementScale)

    _soulLabel = CCLabelTTF:create("0",g_sFontName,g_winSize.height/35)
    _soulLabel:setAnchorPoint(ccp(0,0.5))
    _soulLabel:setPosition(startX+intervalX*2.5,g_winSize.height*0.98)
    battleUperLayer:addChild(_soulLabel)

    local moneyIcon = CCSprite:create("images/battle/icon/icon_money.png")
    moneyIcon:setAnchorPoint(ccp(0.5,0.5))
    moneyIcon:setPosition(startX+intervalX*4,g_winSize.height*0.98)
    battleUperLayer:addChild(moneyIcon)
    moneyIcon:setScale(MainScene.elementScale)

    _moneyLabel = CCLabelTTF:create("0",g_sFontName,g_winSize.height/35)
    _moneyLabel:setAnchorPoint(ccp(0,0.5))
    _moneyLabel:setPosition(startX+intervalX*4.5,g_winSize.height*0.98)
    battleUperLayer:addChild(_moneyLabel)
    _moneyLabel:setColor(ccc3(0xff,0xdc,0x20))

    return battleUperLayer 
end

--[[
	@des:创建底部按钮
--]]
function createBottomButton()
	local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:setTouchPriority(-470)

    local x1Button = CCMenuItemImage:create("images/battle/btn/btn_speed1_n.png", "images/battle/btn/btn_speed1_d.png")
    local x2Button = CCMenuItemImage:create("images/battle/btn/btn_speed2_n.png", "images/battle/btn/btn_speed2_d.png")
    local x3Button = CCMenuItemImage:create("images/battle/btn/btn_speed3_n.png", "images/battle/btn/btn_speed3_d.png")
    x1Button:setAnchorPoint(ccp(0.5, 0.5))
    x2Button:setAnchorPoint(ccp(0.5, 0.5))
    x3Button:setAnchorPoint(ccp(0.5, 0.5))

    _speedButton = CCMenuItemToggle:create(x1Button)
    _speedButton:addSubItem(x2Button)
    _speedButton:addSubItem(x3Button)
    _speedButton:setAnchorPoint(ccp(0, 0))
    _speedButton:setPosition(ccps(0, 0))
    _speedButton:registerScriptTapHandler(speedButtonCallback)
    menu:addChild(_speedButton)
    _speedButton:setScale(MainScene.elementScale)

    _skipButton = CCMenuItemImage:create("images/battle/icon/icon_skip_n.png","images/battle/icon/icon_skip_h.png")
    _skipButton:registerScriptTapHandler(skipButtonCallback)
    _skipButton:setAnchorPoint(ccp(1,0))
    _skipButton:setPosition(ccps(1, 0))
    menu:addChild(_skipButton)
    _skipButton:setScale(MainScene.elementScale)

    --托管按钮
    local button1 = CCMenuItemImage:create("images/battle/icon/icon_autofight.png","images/battle/icon/icon_autofight.png")
    button1:setAnchorPoint(ccp(0.5, 0.5))
    
    local label1  = CCLabelTTF:create(GetLocalizeStringBy("key_2379"), g_sFontPangWa,25)
    label1:setPosition(ccpsprite(0.5,0.5, button1))
    label1:setColor(ccc3(255,220,0))
    button1:addChild(label1)
    label1:setAnchorPoint(ccp(0.5, 0.5))

    local button2 = CCMenuItemImage:create("images/battle/icon/icon_autofight.png","images/battle/icon/icon_autofight.png")
    button2:setAnchorPoint(ccp(0.5, 0.5))

    local label2  = CCLabelTTF:create(GetLocalizeStringBy("key_1712"), g_sFontPangWa,25)
    label2:setPosition(ccpsprite(0.5,0.5, button2))
    label2:setColor(ccc3(255,220,0))
    button2:addChild(label2)
    label2:setAnchorPoint(ccp(0.5, 0.5))
    
    _autoButton = CCMenuItemToggle:create(button1)
    _autoButton:addSubItem(button2)
    _autoButton:registerScriptTapHandler(autoFightClick)
    _autoButton:setAnchorPoint(ccp(1,0))
    _autoButton:setPosition(ccps(1,0))
    menu:addChild(_autoButton)
    _autoButton:setScale(MainScene.elementScale)
    _autoButton:setSelectedIndex(1)

    --关闭按钮
    -- local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    -- closeButton:setAnchorPoint(ccp(0.5, 0.5))
    -- closeButton:registerScriptTapHandler(closeButtonCallFunc)
    -- closeButton:setPosition(ccp(g_winSize.width * 0.9, g_winSize.height * 0.95))
    -- menu:addChild(closeButton, 10000)
    -- closeButton:setScale(MainScene.elementScale)

    _doBattleBtn = CCMenuItemImage:create("images/battle/btn/btn_start_n.png", "images/battle/btn/btn_start_d.png")
    _doBattleBtn:setAnchorPoint(ccp(0.5, 0.5))
    _doBattleBtn:setPosition(g_winSize.width / 2, g_winSize.height / 2)
    _doBattleBtn:registerScriptTapHandler(doBattleClick)
    _doBattleBtn:setScale(MainScene.elementScale)
    _doBattleBtn:setVisible(false)
    menu:addChild(_doBattleBtn)

    return menu
end

--[[
    @des:创建战斗力显示   
--]]
function createFihgthForce()
    if FightModel.getbModel() == BattleModel.COPY then
        return
    end
    local battleInfo = FightStrModel.getFightInfo()
    _team1Force = CCSprite:create("images/battle/strength/strength_bg.png")
    _team1Force:setAnchorPoint(ccp(0,0))
    _team1Force:setPosition(ccp(20*g_fScaleX, 390*g_fScaleX))
    FightScene.getFightLayer():addChild(_team1Force,ZOrderType.FORCE)
    _team1Force:setScale(MainScene.elementScale)

    local team1Strength = battleInfo.team1.fightForce==nil and 0 or battleInfo.team1.fightForce
    local team1StrengthLabel = CCLabelTTF:create(team1Strength .. "",g_sFontName,21)
    team1StrengthLabel:setAnchorPoint(ccp(0.5,0.5))
    team1StrengthLabel:setPosition(ccpsprite(0.65, 0.43, _team1Force))
    _team1Force:addChild(team1StrengthLabel)

    _team2Force = CCSprite:create("images/battle/strength/strength_bg.png")
    _team2Force:setAnchorPoint(ccp(1,1))
    _team2Force:setPosition(ccp(g_winSize.width - 20*g_fScaleX, g_winSize.height - 390*g_fScaleX))
    FightScene.getFightLayer():addChild(_team2Force,ZOrderType.FORCE)
    _team2Force:setScale(MainScene.elementScale)

    local team2Strength = battleInfo.team2.fightForce==nil and 0 or battleInfo.team2.fightForce
    local team2StrengthLabel = CCLabelTTF:create(team2Strength .. "",g_sFontName,21)
    team2StrengthLabel:setAnchorPoint(ccp(0.5,0.5))
    team2StrengthLabel:setPosition(_team2Force:getContentSize().width*0.65,_team2Force:getContentSize().height*0.43)
    _team2Force:addChild(team2StrengthLabel)

    local advantageSprite = CCSprite:create("images/battle/strength/firstAttack.png")
    advantageSprite:setAnchorPoint(ccp(0.5,0.5))

    local firstAttack = tonumber(battleInfo.firstAttack)
    if(firstAttack == 1)then
        advantageSprite:setPosition(_team1Force:getContentSize().width*0.5,_team1Force:getContentSize().height*1.5)
        _team1Force:addChild(advantageSprite)
    else
        advantageSprite:setPosition(_team1Force:getContentSize().width*0.5,-_team1Force:getContentSize().height*0.5)
        _team2Force:addChild(advantageSprite)
    end
end

--[[
    @des:创建信息面板
--]]
function createInfoPanel( ... )
    local battleInfo = FightStrModel.getFightInfo()
        --线下显示战斗信息id
    if g_debug_mode and not table.isEmpty(battleInfo) then

        local bgPanel = CCLayerColor:create(ccc4(0,0,0,111))
        bgPanel:setContentSize(CCSizeMake(200,200))
        bgPanel:setAnchorPoint(ccp(0, 0.5))
        bgPanel:setPosition(ccps(0, 0.5))
        bgPanel:setScale(g_fElementScaleRatio)

        local interY = 30

        local bridLabel = CCLabelTTF:create("brid:"..battleInfo.brid or 0,g_sFontName,22)
        bridLabel:setAnchorPoint(ccp(0.0, 1))
        bridLabel:setPosition(10, bgPanel:getContentSize().height - 10)
        bgPanel:addChild(bridLabel)

        local firstAttack = CCLabelTTF:create("firstAttack:".. (battleInfo.firstAttack or 0),g_sFontName,22)
        firstAttack:setAnchorPoint(ccp(0.0, 1))
        firstAttack:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 1)
        bgPanel:addChild(firstAttack)

        local musicId = CCLabelTTF:create("musicId:"..battleInfo.musicId or 0,g_sFontName,22)
        musicId:setAnchorPoint(ccp(0.0, 1))
        musicId:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 2)
        bgPanel:addChild(musicId)

        local appraisal = CCLabelTTF:create("appraisal:"..battleInfo.appraisal or 0,g_sFontName,22)
        appraisal:setAnchorPoint(ccp(0.0, 1))
        appraisal:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 3)
        bgPanel:addChild(appraisal)

        _uiLayer:addChild(bgPanel,200)
    end
end

--[[
    @des:更新ui显示
--]]
function updateUI()
    local curRound = 0
    local battleIndex = FightMainLoop.getBattleIndex()
    if battleIndex <= FightStrModel.getMaxBlockIndex() then
        curRound = FightStrModel.getCurRound(battleIndex)
    end
    local maxRound = 30
    _roundLabel:setString(curRound .. "/" .. maxRound)
end

--[[
    @des:加速按钮回调
--]]
function speedButtonCallback( tag, sender )
    local button = tolua.cast(sender, "CCMenuItemToggle")
    local index = button:getSelectedIndex()
    local level = UserModel.getHeroLevel()
    local group = ServerList.getSelectServerInfo().group
    local uid   = UserModel.getUserUid()
    if index == 2 and level < FightSpeedType.SPEED_3 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2997") .. FightSpeedType.SPEED_3 .. GetLocalizeStringBy("key_2462"))
        setFightSpeed(1)
        return
    end
    if index == 1 and level < FightSpeedType.SPEED_2 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2997") .. speedUpLevel .. GetLocalizeStringBy("key_2293"))
        setFightSpeed(1)
        return
    end
    setFightSpeed(index + 1)
    -- CCDirector:sharedDirector():getScheduler():setTimeScale(index + 1)
    -- CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid, index + 1)
    -- CCUserDefault:sharedUserDefault():flush()
end

--[[
    @des:跳过战斗按钮回调
--]]
function skipButtonCallback()
    FightSceneAction.skipFightAction()
end

--[[
    @des:托管按钮回调
--]]
function autoFightClick(tag, sender)
    local button = tolua.cast(sender, "CCMenuItemToggle")
    local index = button:getSelectedIndex()
    if index == 0 then
        FightModel.setAutoBattle(false)
    else
        FightModel.setAutoBattle(true)
    end
end

--[[
	@des:关闭按钮回调
--]]
function closeButtonCallFunc(...)
    FightScene.closeScene()
end

--[[
    @des：得到资源图标
--]]
function getResIcon()
    return _resIcon
end

--[[
    @des:战斗按钮回调时间
--]]
function doBattleClick( ... )
    AudioUtil.playEffect("audio/effect/start_fight.mp3")
    if _doBattleCallback then
        _doBattleCallback()
    end
end

--[[
    @des:设置战斗按钮显示
--]]
function setDoBattleVisible( pVisble )
    _doBattleBtn:setVisible(pVisble)
end

--[[
    @des:战斗战斗按钮回调
--]]
function setDoBattleCallback( pCallback )
    _doBattleCallback = pCallback
end

--[[
    @des:设置跳过按钮是否显示
--]]
function setSkipVisible( pVisble )
    _skipButton:setVisible(pVisble)
end

--[[
    @des:设置是否显示托管按钮
--]]
function setAutoVisible( pVisble )
    _autoButton:setVisible(pVisble)
    if pVisble then
        local x = _skipButton:getPositionX()
        local y = (_autoButton:getContentSize().height + 10)*MainScene.elementScale
        _skipButton:setPosition(x,  y)
    else
        _skipButton:setPosition(ccps(1,0))
    end
end

--[[
    @des:设置战斗速度
--]]
function setFightSpeed( pNum )
    local group = ServerList.getSelectServerInfo().group
    local uid   = UserModel.getUserUid()
    _speedButton:setSelectedIndex(pNum - 1)
    CCDirector:sharedDirector():getScheduler():setTimeScale(FightSpeedNumType[pNum])
    CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid, pNum)
    CCUserDefault:sharedUserDefault():flush()
end

--[[
    @des:设置默认战斗速度
--]]
function setDefaultSpeed()
    local group = ServerList.getSelectServerInfo().group
    local uid   = UserModel.getUserUid()
    local saveSpeed = CCUserDefault:sharedUserDefault():getIntegerForKey("battle_speed_"..group.."_"..uid)
    if saveSpeed > 0 then
        setFightSpeed(saveSpeed)
    else
        setFightSpeed(1)
    end
end

--[[
    @des:添加掉落英雄数量
--]]
function addDropHeroNum( pNum )
    _dropHeroNum = _dropHeroNum + pNum
    local dropNum = table.count(FightModel.getHeroArray()) + _dropHeroNum
    _resLabel:setString(tostring(dropNum))
end

--[[
    @des:设置战斗力显示
--]]
function setForceVisible( pVisible )
    local visbile = false
    if pVisible ~= nil then
        visbile = pVisible
    end
    if FightModel.getbModel() ~= BattleModel.COPY then
        _team1Force:setVisible(visbile)
        _team2Force:setVisible(visbile)
    end
end


--[[
    @des:刷新资源
--]]
function updateRes( ... )
    local heroAry = FightModel.getHeroArray()
    if not tolua.isnull(_resLabel) then
        _resLabel:setString(table.count(heroAry))
        _soulLabel:setString(FightModel.getSoul())
        _moneyLabel:setString(FightModel.getSilver())
    end
end

