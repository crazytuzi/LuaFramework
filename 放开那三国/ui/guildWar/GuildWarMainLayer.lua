
-- FileName: GuildWarMainLayer.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarMainLayer 跨服军团战接口模块

module("GuildWarMainLayer", package.seeall)


require "script/ui/tip/AnimationTip"
require "script/ui/guildWar/GuildWarMainData"
require "script/ui/guildWar/GuildWarStageEvent"
require "script/ui/guildWar/GuildWarMainService"
require "script/ui/guildWar/GuildWarMainController"
require "script/ui/guildWar/GuildWarUtil"


local _bgLayer               = nil
local _layerSize             = nil
local _showServerButton      = nil
local _hiddenServerButton    = nil
local _registerButton        = nil
local _registeredButton      = nil
local _checkReportButton     = nil
local _updateInfoButton      = nil
local _enterBattleInfoButton = nil
local _worshipButton         = nil
local _interiorReportButton  = nil
local _externalReportButton  = nil
local _nowRoundEndTime       = nil
local _timeString 			 = nil
local _nowRoundEndTime 		 = nil
local _roundDesNode 		 = nil
local _curRoundType 		 = nil
local _fightingLabel 		 = nil
local _myGuildInfoButton 	 = nil
local _isEnter 			     = nil
--[[
	@des 	:初始化
--]]
function init()
	_bgLayer               = nil
	_layerSize             = nil
	_showServerButton      = nil
	_hiddenServerButton    = nil
	_registerButton        = nil
	_checkReportButton     = nil
	_updateInfoButton      = nil
	_enterBattleInfoButton = nil
	_worshipButton         = nil
	_interiorReportButton  = nil
	_externalReportButton  = nil
	_timeString            = nil
	_roundDesNode          = nil
	_curRoundType          = nil 
	_fightingLabel         = nil
	_registeredButton      = nil
	_myGuildInfoButton     = nil
end

--[[
	@des 	:入口函数，用于场景切换
--]]
function show()
    local layer = GuildWarMainLayer.createLayer()
    MainScene.changeLayer(layer, "GuildWarMainLayer")
end


--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(event)
	if event == "enter" then
	elseif eventType == "exit" then
		GuildWarStageEvent:removeListener(stageChangeCallback)
	end
end


--[[
	@des : 创建layer
--]]
function createLayer()
    init()
    _isEnter = true
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_layerSize = g_winSize 
    playBgm()
	MainScene.setMainSceneViewsVisible(false, false, false)

	-- local bgSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/lord_war/effect/kfbeijing"), -1,CCString:create(""))
	local bgSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/juntuansaicj/juntuansaicj"), -1,CCString:create(""))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setScale(g_fBgScaleRatio * 1.02)
	_bgLayer:addChild(bgSprite)

	GuildWarMainService.enter(function ()
		GuildWarMainService.getUserGuildWarInfo(function ()
			GuildWarMainService.getMyTeamInfo(function ()
				--初始化监听器
				GuildWarStageEvent.initate()
				createTopUi()
				createCenterUi()
				crateServerListPanel()
				updateButtonStatus()
				GuildWarStageEvent.registerListener(stageChangeCallback)
			end)
		end)
	end)
	playBgm()
	return _bgLayer
end

--[[
	@des : 创建顶部ui
--]]
function createTopUi()

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-504)

	--标题
	local titleSprite = GuildWarUtil.getGuildWarNameSprite()
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccps(0.5, 0.97))
	titleSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(titleSprite)

	local timeTitle = GuildWarUtil.getRoundTitle()
	_bgLayer:addChild(timeTitle)
	timeTitle:setAnchorPoint(ccp(0.5, 1))
	timeTitle:setPosition(ccps(0.5, 0.93))
	timeTitle:setScale(MainScene.elementScale)
    

	local timeNode = GuildWarUtil.getTimeTitle("LordWarMainLayer")
	_bgLayer:addChild(timeNode)
	timeNode:setAnchorPoint(ccp(0.5, 1))
	timeNode:setPosition(ccps(0.5, 0.85))
	timeNode:setScale(MainScene.elementScale)
    
	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(GuildWarMainController.closeCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.95))
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

	--活动说明
	local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(GuildWarMainController.explainCallFunc)
	explainButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.77))
	menu:addChild(explainButton)
	explainButton:setScale(MainScene.elementScale)

	--奖励预览按钮
	local rewardPreviewButton = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
	rewardPreviewButton:setAnchorPoint(ccp(0.5, 0.5))
	rewardPreviewButton:setPosition(ccp(_layerSize.width * 0.73 ,_layerSize.height * 0.77))
	rewardPreviewButton:registerScriptTapHandler(GuildWarMainController.rewardPreviewCallback)
	menu:addChild(rewardPreviewButton)
	rewardPreviewButton:setScale(MainScene.elementScale)
end


function createMenuItem(normalString, selectedString, disabledString, size)
    local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite:setContentSize(size)
	local norTitle  =  CCRenderLabel:create(normalString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle:setPosition(ccpsprite(0.5, 0.5, norSprite))
	norTitle:setAnchorPoint(ccp(0.5, 0.5))
	norSprite:addChild(norTitle)
	
	local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite:setContentSize(size)
    selectedString = selectedString or normalString
	local higTitle  =  CCRenderLabel:create(selectedString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle:setPosition(ccpsprite(0.5, 0.5, higSprite))
	higTitle:setAnchorPoint(ccp(0.5, 0.5))
	higSprite:addChild(higTitle)
	
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(size)
    disabledString = disabledString or normalString
	local grayTitle  =  CCRenderLabel:create(disabledString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	grayTitle:setColor(ccc3(78, 78, 78))
	grayTitle:setPosition(ccpsprite(0.5, 0.5, graySprite))
	grayTitle:setAnchorPoint(ccp(0.5, 0.5))
	graySprite:addChild(grayTitle)
	
	local button = CCMenuItemSprite:create(norSprite, higSprite, graySprite)
    return button
end

function createCenterUi()

	--特效字
	local effectWord = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/dayoushi/dayoushi"), -1,CCString:create(""))
	effectWord:setPosition(ccps(0.2, 0.5))
	effectWord:setScale(MainScene.elementScale)
	_bgLayer:addChild(effectWord)
	effectWord:setFPS_interval(1/120.0)

	local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ()
    	effectWord:cleanup()
    end)
    effectWord:setDelegate(delegate)


	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(-504)
	_bgLayer:addChild(menu)
	
	--报名按钮
	_registerButton = createMenuItem(GetLocalizeStringBy("key_8266"), nil, nil, CCSizeMake(188, 70))
	_registerButton:setAnchorPoint(ccp(0.5, 1))
	_registerButton:registerScriptTapHandler(GuildWarMainController.registerCallback)
	_registerButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_registerButton)
	_registerButton:setScale(MainScene.elementScale)

	--已报名按钮
    _registeredButton = createMenuItem(GetLocalizeStringBy("key_8267"), nil, GetLocalizeStringBy("key_8267"), CCSizeMake(188, 70))
    _registeredButton:setAnchorPoint(ccp(0.5, 1))
	_registeredButton:registerScriptTapHandler(GuildWarMainController.registerCallback)
	_registeredButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_registeredButton)
	_registeredButton:setScale(MainScene.elementScale)
	_registeredButton:setEnabled(false)
	--查看战绩
    _checkReportButton = createMenuItem(GetLocalizeStringBy("lcyx_165"), nil, nil, CCSizeMake(193, 70))
	_checkReportButton:setAnchorPoint(ccp(0.5, 1))
	_checkReportButton:registerScriptTapHandler(GuildWarMainController.checkReportCallback)
	_checkReportButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_checkReportButton)
	_checkReportButton:setScale(MainScene.elementScale)

	--进入赛场
	_enterBattleInfoButton = createMenuItem(GetLocalizeStringBy("key_8264"), nil, nil, CCSizeMake(198, 70))
    _enterBattleInfoButton:setAnchorPoint(ccp(0.5, 1))
	_enterBattleInfoButton:registerScriptTapHandler(GuildWarMainController.enterCallback)
	_enterBattleInfoButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_enterBattleInfoButton)
	_enterBattleInfoButton:setScale(MainScene.elementScale)

	--膜拜冠军
    _worshipButton = createMenuItem(GetLocalizeStringBy("key_8263"), nil, nil, CCSizeMake(195, 70))
	_worshipButton:setAnchorPoint(ccp(0.5, 1))
	_worshipButton:registerScriptTapHandler(GuildWarMainController.worshipCallback)
	_worshipButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_worshipButton)
	_worshipButton:setScale(MainScene.elementScale)

	--战斗信息
    _myGuildInfoButton = createMenuItem(GetLocalizeStringBy("lcyx_167"), nil, nil, CCSizeMake(195, 70))
	_myGuildInfoButton:setAnchorPoint(ccp(0.5, 1))
	_myGuildInfoButton:registerScriptTapHandler(GuildWarMainController.battleInfoCallback)
	_myGuildInfoButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_myGuildInfoButton)
	_myGuildInfoButton:setScale(MainScene.elementScale)

	--服内战况回顾
    _promotionInfoButton = createMenuItem(GetLocalizeStringBy("lcyx_163"), nil, nil, CCSizeMake(200, 70))
	_promotionInfoButton:setAnchorPoint(ccp(0.5, 1))
	_promotionInfoButton:registerScriptTapHandler(GuildWarMainController.promotionInfoCallback)
	_promotionInfoButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_promotionInfoButton)
	_promotionInfoButton:setScale(MainScene.elementScale)										
end

--[[
	@des : 创建服务器列表
--]]
function crateServerListPanel()
	
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-504)

	_showServerButton = CCMenuItemImage:create("images/lord_war/server_btn_n.png", "images/lord_war/server_btn_h.png")
	_showServerButton:setAnchorPoint(ccp(1, 0.5))
	_showServerButton:setPosition(ccps(1, 0.5))
	_showServerButton:registerScriptTapHandler(showServerButtonCallback)
	menu:addChild(_showServerButton)
	_showServerButton:setScale(MainScene.elementScale)

	_hiddenServerButton = CCMenuItemImage:create("images/star/btn_hidden_n.png", "images/star/btn_hidden_h.png")
	_hiddenServerButton:setAnchorPoint(ccp(1, 0.5))
	_hiddenServerButton:setPosition(ccps(1, 0.5))
	_hiddenServerButton:registerScriptTapHandler(hiddenServerButtonCallback)
	menu:addChild(_hiddenServerButton)
	_hiddenServerButton:setScale(MainScene.elementScale)
	_hiddenServerButton:setVisible(false)

	local fullRect = CCRectMake(0,0,75,75)
	local insetRect = CCRectMake(30,30,15,15)
	local serverListPanel = CCScale9Sprite:create("images/star/intimate/attr9s.png", fullRect, insetRect)
	serverListPanel:setContentSize(CCSizeMake(255, 350))
	serverListPanel:setAnchorPoint(ccp(0, 0.5))
	serverListPanel:setPosition(ccpsprite(0.87, 0.5, _hiddenServerButton))
	_hiddenServerButton:addChild(serverListPanel, 10)

	local fullRect_2 = CCRectMake(0,0,75,75)
	local insetRect_2 = CCRectMake(30,30,15,15)
	local listBg = CCScale9Sprite:create("images/star/intimate/attr9s_2.png", fullRect, insetRect)
	listBg:setContentSize(CCSizeMake(250, 310))
	listBg:setAnchorPoint(ccp(0.5, 0))
	listBg:setPosition(ccp( serverListPanel:getContentSize().width * 0.5, 2))
	serverListPanel:addChild(listBg)

	-- 标题
	local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_8260"), g_sFontName, 23)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x65))
	titleLabel:setAnchorPoint(ccp(0.5 , 1))
	titleLabel:setPosition(ccp(serverListPanel:getContentSize().width*0.5, serverListPanel:getContentSize().height * 0.98))
	serverListPanel:addChild(titleLabel)

	local serverInfo = GuildWarMainData.getMyTeamInfo()
	local cellSize = CCSizeMake(250,46)			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then

            a2 = createServerListTabelCell(serverInfo[a1 + 1].name, a1+1 )
			r = a2
		elseif fn == "numberOfCells" then
			r = #serverInfo
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
		end
		return r
	end)
	local serverListTableView = LuaTableView:createWithHandler(h, CCSizeMake(listBg:getContentSize().width, listBg:getContentSize().height-10))
    serverListTableView:setAnchorPoint(ccp(0,0))
	serverListTableView:setBounceable(true)
	serverListTableView:setPosition(ccpsprite(0, 0, listBg))
	serverListTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	listBg:addChild(serverListTableView)

	-- refreshAttrTableView()
end

--[[
	@des : 创建服务器列表cell
--]]
function createServerListTabelCell(p_serverInfo, p_index)

	local index = tonumber(p_index)

	local tCell = CCTableViewCell:create()
	local bgSprite = nil
	if(index%2 == 1)then
		bgSprite = CCSprite:create()
	else
		bgSprite = CCScale9Sprite:create( "images/star/intimate/item9s.png" )
	end
	bgSprite:setContentSize(CCSizeMake(250, 46))
	tCell:addChild(bgSprite)

	local bgSpriteSize = bgSprite:getContentSize()
	local ccc_color = ccc3(0x00, 0x6d, 0x2f)
	local attr_nameColor = ccc3(0x78, 0x25, 0x00)
	-- 索引
	local indexLabel = CCLabelTTF:create(index, g_sFontName, 25)
	indexLabel:setColor(ccc_color)
	indexLabel:setAnchorPoint(ccp(0.5, 0.5))
	indexLabel:setPosition(ccp(bgSpriteSize.width*0.1, bgSpriteSize.height*0.5))
	bgSprite:addChild(indexLabel)

	-- 属性名称
	local attrNameLabel = CCLabelTTF:create(p_serverInfo, g_sFontName, 21)
	attrNameLabel:setColor(attr_nameColor)
	attrNameLabel:setAnchorPoint(ccp(0, 0.5))
	attrNameLabel:setPosition(ccp(bgSpriteSize.width*0.28, bgSpriteSize.height*0.5))
	bgSprite:addChild(attrNameLabel)

	return tCell
end

------------------------------[[ ui更新方法 ]]-------------------------------------
function updateButtonStatus()
    if tolua.cast(_bgLayer, "CCLayer") == nil 
    	or tolua.cast(_registerButton, "CCMenuItem") == nil then
        return
    end
    _registerButton:setVisible(false)
	_registeredButton:setVisible(false)
	_checkReportButton:setVisible(false)
	_enterBattleInfoButton:setVisible(false)
	_worshipButton:setVisible(false)
	_promotionInfoButton:setVisible(false)
	_myGuildInfoButton:setVisible(false)

	local curTime 	   = TimeUtil.getSvrTimeByOffset(-1)
	local buttonStatus = nil
	if GuildWarMainData.getRound() == GuildWarDef.INVALID then
		buttonStatus = 1
	elseif GuildWarMainData.getRound() == GuildWarDef.SIGNUP then
		if GuildWarMainData.isSignUp() then
			--已报名
			buttonStatus = 2
		else
			buttonStatus = 3
			if curTime > GuildWarMainData.getEndTime(GuildWarDef.SIGNUP) then
				_registerButton:setEnabled(false)
			end
		end
	elseif GuildWarMainData.getRound() == GuildWarDef.AUDITION 
		and GuildWarMainData.getStatus() == GuildWarDef.FIGHTING then
			buttonStatus = 4
	elseif (GuildWarMainData.getRound() == GuildWarDef.AUDITION and GuildWarMainData.getStatus() <= GuildWarDef.DONE) then
			buttonStatus = 4
	elseif (GuildWarMainData.getRound() == GuildWarDef.AUDITION and GuildWarMainData.getStatus() >= GuildWarDef.END) then
			buttonStatus = 5
	elseif (GuildWarMainData.getRound() >= GuildWarDef.ADVANCED_16 and GuildWarMainData.getRound() <= GuildWarDef.ADVANCED_2) then
		-- 海选赛和晋级赛期间
		if GuildWarMainData.getRound() == GuildWarDef.ADVANCED_2 
			and GuildWarMainData.getStatus() >= GuildWarDef.DONE then
				--晋级赛结束
				buttonStatus = 6
		else
				buttonStatus = 5
		end
	end
	-- buttonStatus = 1
	if buttonStatus == 1 then
		_registerButton:setVisible(true)
		_registeredButton:setVisible(false)
		_checkReportButton:setVisible(false)
		_enterBattleInfoButton:setVisible(false)
		_worshipButton:setVisible(false)
		_promotionInfoButton:setVisible(false)
		_myGuildInfoButton:setVisible(false)

		_registerButton:setPosition(ccps(0.5, 0.2))
	elseif buttonStatus == 2 then
		_registerButton:setVisible(false)
		_registeredButton:setVisible(true)
		_checkReportButton:setVisible(false)
		_enterBattleInfoButton:setVisible(false)
		_worshipButton:setVisible(false)
		_promotionInfoButton:setVisible(false)
		_myGuildInfoButton:setVisible(true)

		_registeredButton:setPosition(ccps(0.25, 0.2))
		_myGuildInfoButton:setPosition(ccps(0.75, 0.2))
	elseif buttonStatus == 3 then
		_registerButton:setVisible(true)
		_registeredButton:setVisible(false)
		_checkReportButton:setVisible(false)
		_enterBattleInfoButton:setVisible(false)
		_worshipButton:setVisible(false)
		_promotionInfoButton:setVisible(false)
		_myGuildInfoButton:setVisible(false)

		_registerButton:setPosition(ccps(0.5, 0.2))
	elseif buttonStatus == 4 then
		_registerButton:setVisible(false)
		_registeredButton:setVisible(false)
		_checkReportButton:setVisible(true)
		_enterBattleInfoButton:setVisible(false)
		_worshipButton:setVisible(false)
		_promotionInfoButton:setVisible(false)
		_myGuildInfoButton:setVisible(true)

		_checkReportButton:setPosition(ccps(0.25, 0.2))
		_myGuildInfoButton:setPosition(ccps(0.75, 0.2))
	elseif buttonStatus == 5 then
		_registerButton:setVisible(false)
		_registeredButton:setVisible(false)
		_checkReportButton:setVisible(true)
		_enterBattleInfoButton:setVisible(true)
		_worshipButton:setVisible(false)
		_promotionInfoButton:setVisible(false)
		_myGuildInfoButton:setVisible(true)

		_checkReportButton:setPosition(ccps(0.25, 0.2))
		_myGuildInfoButton:setPosition(ccps(0.75, 0.2))
		_enterBattleInfoButton:setPosition(ccps(0.5, 0.3))
	elseif buttonStatus == 6 then
		_registerButton:setVisible(false)
		_registeredButton:setVisible(false)
		_checkReportButton:setVisible(false)
		_enterBattleInfoButton:setVisible(false)
		_worshipButton:setVisible(true)
		_promotionInfoButton:setVisible(true)
		_myGuildInfoButton:setVisible(false)

		_promotionInfoButton:setPosition(ccps(0.25, 0.2))
		_worshipButton:setPosition(ccps(0.75, 0.2))
		if GuildWarMainData.getSignCuildCont() ==0 then
			_worshipButton:setEnabled(false)
		end
	end
end

--------------------[[ 按钮事件 ]] ------------------------
--[[
	@des: 关闭按钮回调事件
--]]
function showServerButtonCallback()
	_showServerButton:setVisible(false)
	_hiddenServerButton:setVisible(true)
    local position = ccps(1, 0.5)
    position.x = position.x - 255 * MainScene.elementScale
	local action = CCMoveTo:create(0.5, position)
    _hiddenServerButton:stopAllActions()
	_hiddenServerButton:runAction(action)
end

--[[
	@des: 关闭按钮回调事件
--]]
function hiddenServerButtonCallback()

	local position = ccps(1, 0.5)
    position.x = position.x + 255 * MainScene.elementScale
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.5, position))
	actionArray:addObject(CCCallFunc:create(function ()
		_showServerButton:setVisible(true)
		_hiddenServerButton:setVisible(false)
	end))
	local seqAction = CCSequence:create(actionArray)
    _hiddenServerButton:stopAllActions()
	_hiddenServerButton:runAction(seqAction)
end

--[[
    @des: 播放背景音乐
--]]
function playBgm()
	AudioUtil.playBgm("audio/bgm/music15.mp3")
end

function stageChangeCallback()

	print("stageChangeCallback")
	print("curRound",GuildWarMainData.getRound())
	print("curStatus",GuildWarMainData.getStatus())
	print("curSubRound",GuildWarMainData.getSubRound())
	print("curSubStatus",GuildWarMainData.getSubStatus())

	updateButtonStatus()
end

function getIsEneter( ... )
	if _isEnter == nil then
		return false
	else
		return true
	end
end
