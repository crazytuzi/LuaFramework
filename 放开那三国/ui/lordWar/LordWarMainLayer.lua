-- Filename: LordWarMainLayer.lua
-- Author: lichenyang
-- Date: 2014-08-14
-- Purpose: 个人跨服赛数据层

module("LordWarMainLayer", package.seeall)

require "script/ui/lordWar/LordWarEventDispatcher"
require "script/ui/lordWar/LordWarUtil"
require "script/ui/lordWar/LordWarService"
require "script/ui/lordWar/LordWarData"
require "script/ui/tip/AnimationTip"


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
local _isEnter 			     = nil
--[[
	@des 	:初始化
--]]
function init( ... )
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
	_nowRoundEndTime       = nil
	_timeString 		   = nil
	_nowRoundEndTime 	   = nil
	_timeString 		   = nil
	_nowRoundEndTime 	   = nil
	_roundDesNode 		   = nil
	_curRoundType 		   = nil 
	_fightingLabel 		   = nil
	_registeredButton      = nil
end

--[[
	@des 	:入口函数，用于场景切换
--]]
function show()
    local layer = LordWarMainLayer.createLayer()
    MainScene.changeLayer(layer, "LordWarMainLayer")
end

--[[
	@des : 创建layer
--]]
function createLayer( ... )
    init()
    _isEnter = true
	_bgLayer = CCLayer:create()
	_layerSize = g_winSize 
    playBgm()
	MainScene.setMainSceneViewsVisible(false, false, false)
	local bgSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/lord_war/effect/kfbeijing"), -1,CCString:create(""))
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setScale(g_fBgScaleRatio * 1.02)
	_bgLayer:addChild(bgSprite)
	
	LordWarService.enterLordwar(function ( ... )
		LordWarService.getLordInfo(function ( ... )
			createTopUi()
			createCenterUi()
			crateServerListPanel()
            --LordWarUtil.initUpdateRound()
			--schedule(_bgLayer,updateTime, 1)
            LordWarEventDispatcher.open()
            -- LordWarEventDispatcher.addListener("LordWarMainLayer.updateTime", updateTime)
            LordWarEventDispatcher.addListener("LordWarMainLayer.roundUpdatePushCallback", roundUpdatePushCallback)
			updateButtonStatus()
			--阶段时间:
			print("阶段时间:")
			for i=LordWarData.kRegister,LordWarData.kCross2To1 do
				print(i, "开始时间", TimeUtil.getTimeFormatYMDHMS(LordWarData.getRoundStartTime(i)))
				print(i, "结束时间", TimeUtil.getTimeFormatYMDHMS(LordWarData.getRoundEndTime(i)))
			end
		end)
	end)
	require "script/model/utils/ActivityConfigUtil"
	local data = ActivityConfigUtil.getDataByKey("lordwar").data
	local lastTimeArrConfig = string.split(data[1].lastTimeArr, ",")
	printTable("lordwar data", data)
	printTable("lastTimeArr", lastTimeArrConfig)
	return _bgLayer
end

--[[
	@des : 创建顶部ui
--]]
function createTopUi( ... )

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-504)

	--标题
	local titleSprite = LordWarUtil.createTitleSprite()
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccps(0.5, 0.97))
	titleSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(titleSprite)

    local timeNode = LordWarUtil.getTimeTitle("LordWarMainLayer")
    _bgLayer:addChild(timeNode)
    timeNode:setAnchorPoint(ccp(0.5, 1))
	timeNode:setPosition(ccps(0.5, 0.87))
	timeNode:setScale(MainScene.elementScale)
    
	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.95))
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

	--活动说明
	local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallFunc)
	explainButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.79))
	menu:addChild(explainButton)
	explainButton:setScale(MainScene.elementScale)

	--奖励预览按钮
	local rewardPreviewButton = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
	rewardPreviewButton:setAnchorPoint(ccp(0.5, 0.5))
	rewardPreviewButton:setPosition(ccp(_layerSize.width * 0.73 ,_layerSize.height * 0.79))
	rewardPreviewButton:registerScriptTapHandler(rewardPreviewButtonCallback)
	menu:addChild(rewardPreviewButton)
	rewardPreviewButton:setScale(MainScene.elementScale)

	--跨服赛商店
	require "script/ui/lordWar/shop/LordwarShopData"
	local shopButton = CCMenuItemImage:create("images/lord_war/shop_n.png","images/lord_war/shop_h.png")
	shopButton:setAnchorPoint(ccp(0.5, 0.5))
	shopButton:setPosition(ccp(_layerSize.width * 0.56 ,_layerSize.height * 0.79))
	shopButton:registerScriptTapHandler(shopButtonCallback)
	menu:addChild(shopButton)
	shopButton:setScale(MainScene.elementScale)
	shopButton:setVisible(LordwarShopData.isShopOpen()) --当前版本屏蔽入口
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

function createCenterUi( ... )

	--特效字
	local effectWord = CCLayerSprite:layerSpriteWithName(CCString:create("images/lord_war/effect/ziyinxian"), -1,CCString:create(""))
	effectWord:setPosition(ccps(0.2, 0.5))
	effectWord:setScale(MainScene.elementScale)
	_bgLayer:addChild(effectWord)
	effectWord:setFPS_interval(1/120.0)

	local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ( ... )
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
	_registerButton:registerScriptTapHandler(registerButtonCallback)
	_registerButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_registerButton)
	_registerButton:setScale(MainScene.elementScale)

	--已报名按钮
    _registeredButton = createMenuItem(GetLocalizeStringBy("key_8266"), nil, GetLocalizeStringBy("key_8267"), CCSizeMake(188, 70))
    _registeredButton:setAnchorPoint(ccp(0.5, 1))
	_registeredButton:registerScriptTapHandler(registerButtonCallback)
	_registeredButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_registeredButton)
	_registeredButton:setScale(MainScene.elementScale)

	--查看战绩
    _checkReportButton = createMenuItem(GetLocalizeStringBy("key_8265"), nil, nil, CCSizeMake(193, 70))
	_checkReportButton:setAnchorPoint(ccp(0.5, 1))
	_checkReportButton:registerScriptTapHandler(checkReportButtonCallback)
	_checkReportButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_checkReportButton)
	_checkReportButton:setScale(MainScene.elementScale)

	--更新战斗信息
	_updateInfoButton = LordWarUtil.createUpdateInfoButton("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(255, 70), -600) --CCMenuItemSprite:create(norSprite, higSprite, graySprite)
	_updateInfoButton:setAnchorPoint(ccp(0.5, 1))
	_updateInfoButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.15))
	_bgLayer:addChild(_updateInfoButton)
	_updateInfoButton:setScale(MainScene.elementScale)

	--进入赛场
	_enterBattleInfoButton = createMenuItem(GetLocalizeStringBy("key_8264"), nil, nil, CCSizeMake(198, 70))
    _enterBattleInfoButton:setAnchorPoint(ccp(0.5, 1))
	_enterBattleInfoButton:registerScriptTapHandler(enterBattleInfoButtonCallback)
	_enterBattleInfoButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_enterBattleInfoButton)
	_enterBattleInfoButton:setScale(MainScene.elementScale)

	--膜拜冠军
    _worshipButton = createMenuItem(GetLocalizeStringBy("key_8263"), nil, nil, CCSizeMake(195, 70))
	_worshipButton:setAnchorPoint(ccp(0.5, 1))
	_worshipButton:registerScriptTapHandler(worshipButtonCallback)
	_worshipButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_worshipButton)
	_worshipButton:setScale(MainScene.elementScale)

	--服内战况回顾
    _interiorReportButton = createMenuItem(GetLocalizeStringBy("key_8262"), nil, nil, CCSizeMake(255, 70))
	_interiorReportButton:setAnchorPoint(ccp(0.5, 1))
	_interiorReportButton:registerScriptTapHandler(interiorReportButtonCallback)
	_interiorReportButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_interiorReportButton)
	_interiorReportButton:setScale(MainScene.elementScale)

	--跨服战况回顾
    _externalReportButton = createMenuItem(GetLocalizeStringBy("key_8261"), nil, nil, CCSizeMake(255, 70))
	_externalReportButton:setAnchorPoint(ccp(0.5, 1))
	_externalReportButton:registerScriptTapHandler(externalReportButtonCallback)
	_externalReportButton:setPosition(ccp(_layerSize.width * 0.5 ,_layerSize.height * 0.5))
	menu:addChild(_externalReportButton)
	_externalReportButton:setScale(MainScene.elementScale)
										
end

--[[
	@des : 创建服务器列表
--]]
function crateServerListPanel( ... )
	
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

	local serverInfo = LordWarData.getServerInfo()
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
    if tolua.cast(_bgLayer, "CCLayer") == nil then
        return
    end
	local status = LordWarData.getMainLayerState()
	print("updateButtonStatus", status)
    local btnStatuses = {}
    local btns = {_registerButton, _registeredButton, _checkReportButton, _updateInfoButton, _enterBattleInfoButton,
    _worshipButton, _interiorReportButton, _externalReportButton}
    btnStatuses[0]    = {true,  false, false, false, false, false, false, false, ["p1"] = ccps(0.5, 0.15)}
    btnStatuses[101]  = {false, true,  false, true,  false, false, false, false, ["p2"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15), ["e2"] = false}
    btnStatuses[1]    = {true,  false, false, false, false, false, false, false, ["p1"] = ccps(0.5, 0.15)}
    btnStatuses[102]  = {false, false, true,  true,  false, false, false, false, ["p3"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15)}
    btnStatuses[2]    = {true,  false, false, false, false, false, false, false, ["p1"] = ccps(0.5, 0.15), ["p2"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15), ["e1"] = false}
    btnStatuses[103]  = {false, false, true,  true,  true,  false, false, false, ["p3"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15), ["p5"] = ccps(0.5, 0.23)}
    btnStatuses[3]    = {false, false, false, false, true,  false, false, false, ["p5"] = ccps(0.5, 0.23)}
    btnStatuses[104]  = {false, false, true,  true,  false, false, true,  false, ["p3"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15), ["p7"] = ccps(0.5, 0.23)}
    btnStatuses[4]    = {false, false, false, false, false, false, true,  false, ["p7"] = ccps(0.5, 0.23)}
    btnStatuses[105]  = {false, false, true,  true,  true,  false, true,  false, ["p3"] = ccps(0.3, 0.15), ["p4"] = ccps(0.7, 0.15), ["p5"] = ccps(0.3, 0.23), ["p7"] = ccps(0.7, 0.23)}
    btnStatuses[5]    = {false, false, false, false, true,  false, true,  false, ["p5"] = ccps(0.5, 0.23), ["p7"] = ccps(0.5, 0.15)}
    btnStatuses[8]    = {false, false, false, false, false, true,  true,  true,  ["p6"] = ccps(0.5, 0.23), ["p7"] = ccps(0.3, 0.15), ["p8"] = ccps(0.7, 0.15)}
    for i = 1, #btns do
        local btn = btns[i]
        local btnStatus = btnStatuses[status]
        btn:setVisible(btnStatus[i])
        local position = btnStatus["p" .. i]
        if position ~= nil then
            btn:setPosition(position)
        end
        if i == 1 or i == 2 then
            local enabled = btnStatus["e" .. i]
            if enabled ~= nil then
                btn:setEnabled(enabled)
            else
                btn:setEnabled(true)
            end
        end
    end
end



------------------------------[[ 事件回调 ]]----------------------------------------

--[[
	@des: 关闭按钮回调事件
--]]
function showServerButtonCallback( ... )
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
function hiddenServerButtonCallback( ... )

	local position = ccps(1, 0.5)
    position.x = position.x + 255 * MainScene.elementScale
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.5, position))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		_showServerButton:setVisible(true)
		_hiddenServerButton:setVisible(false)
	end))
	local seqAction = CCSequence:create(actionArray)
    _hiddenServerButton:stopAllActions()
	_hiddenServerButton:runAction(seqAction)
end

--[[
	@des: 关闭按钮回调事件
--]]
function closeButtonCallFunc( ... )
	require "script/model/utils/ActivityConfigUtil"
	if(ActivityConfigUtil.isActivityOpen("lordwar") == true) then
		LordWarService.leaveLordwar(function ( ... )
			AudioUtil.playMainBgm()
	        LordWarEventDispatcher.close()
			--清除阶段监听
			-- LordWarUtil.clearRoundAction()

			require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		    MainScene.setMainSceneViewsVisible(true,true,true)
		    print("closeButtonCallFunc")
		end)
	else
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
	end
end


--[[
	@des: 活动说明按钮
--]]
function explainButtonCallFunc( ... )
	require "script/ui/lordWar/LordWarExplainDialog"
	LordWarExplainDialog.show(-1024)
end

--[[
	@des: 奖励预览按钮
--]]
function rewardPreviewButtonCallback(tag,menuItem)
   require "script/ui/lordWar/reward/LordWarRewardSelect"
   LordWarRewardSelect.showLayer(menuItem:getPositionX(),menuItem:getPositionY(), -504)
end

--[[
	@des: 商店按钮
--]]
function shopButtonCallback( ... )
	-- require "script/ui/lordWar/shop/LordwarShopLayer"
	-- LordwarShopLayer.show()
	require "script/ui/shopall/loardwarshop/LordwarShopLayer"
	LordwarShopLayer.show()
end

--[[
	@des: 报名按钮回调事件
--]]
function registerButtonCallback( ... )

	--检查报名等级
	if(UserModel.getHeroLevel() < LordWarData.getRegisgterLevel()) then	
		AnimationTip.showTip(string.format(GetLocalizeStringBy("lcy_50097"), LordWarData.getRegisgterLevel()))
		return
	end
	
	--检查报名时间
	local nowTime = BTUtil:getSvrTimeInterval()
	if LordWarData.getRoundStartTime(LordWarData.kRegister) > nowTime then
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50046"))
        return
	end

	local requestCallback = function ( ... )
        AnimationTip.showTip(GetLocalizeStringBy("key_8259"))
		updateButtonStatus()
	end
	LordWarService.register(requestCallback)
end

--[[
	@des : 查看战绩
--]]
function checkReportButtonCallback( ... )
	require "script/ui/lordWar/MyInfoLayer"
	MyInfoLayer.show(-504)
end

--[[
	@des : 进入赛场
--]]
function enterBattleInfoButtonCallback( ... )
	print("enterBattleInfoButtonCallback")
	require "script/ui/lordWar/LordWar32Layer"
	require "script/ui/lordWar/LordWar4Layer"
	
	LordWarService.getPromotionInfo(function ( ... )
		local curRound = LordWarData.getCurRound()
		local curStatus = LordWarData.getCurRoundStatus()
        print("curRound=", curRound)
        print("curStatus=", curStatus)
        if (curRound == LordWarData.kInnerAudition and curStatus == LordWarData.kRoundEnd)
            or (curRound >= LordWarData.kInner32To16 and curRound < LordWarData.kInner8To4)
            or (curRound == LordWarData.kInner8To4 and curStatus < LordWarData.kRoundFighted) then
            LordWar32Layer.show()
        elseif (curRound == LordWarData.kInner8To4 and curStatus >= LordWarData.kRoundFighted)
            or (curRound >= LordWarData.kInner4To2 and curRound < LordWarData.kInner2To1)
            or (curRound == LordWarData.kInner2To1 and curStatus < LordWarData.kRoundFighted) then
            LordWar4Layer.show()
        elseif (curRound == LordWarData.kCrossAudition and curStatus == LordWarData.kRoundEnd)
            or (curRound >= LordWarData.kCross32To16 and curRound < LordWarData.kCross8To4)
            or (curRound == LordWarData.kCross8To4 and curStatus < LordWarData.kRoundFighted) then
            LordWar32Layer.show()
        elseif (curRound == LordWarData.kCross8To4 and curStatus >= LordWarData.kRoundFighted)
            or (curRound >= LordWarData.kCross4To2 and curRound < LordWarData.kCross2To1)
            or (curRound == LordWarData.kCross2To1 and curStatus < LordWarData.kRoundFighted) then
            LordWar4Layer.show()
        end
    end)
end

--[[
    @des: 播放背景音乐
--]]
function playBgm()
	AudioUtil.playBgm("audio/bgm/music15.mp3")
end

--[[
	@des : 膜拜冠军
--]]
function worshipButtonCallback( ... )
	require "script/model/utils/ActivityConfigUtil"
	if(ActivityConfigUtil.isActivityOpen("lordwar") == true) then
		require "script/ui/lordWar/ChampionLayer"
		ChampionLayer.show()
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1220"))
	end
end

--[[
	@des : 服内战况回顾
--]]
function interiorReportButtonCallback( ... )
	require "script/model/utils/ActivityConfigUtil"
	if(ActivityConfigUtil.isActivityOpen("lordwar") == true) then
		LordWarService.getPromotionHistory(LordWarData.kInner2To1, function ( ... )
			require "script/ui/lordWar/LordWar4Layer"
			LordWar4Layer.show(LordWarData.kInnerType)
		end)
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1220"))
	end
end

--[[
	@des : 跨服战况回顾
--]]
function externalReportButtonCallback( ... )
	require "script/model/utils/ActivityConfigUtil"
	if(ActivityConfigUtil.isActivityOpen("lordwar") == true) then
		LordWarService.getPromotionHistory(LordWarData.kCross2To1, function ( ... )
			require "script/ui/lordWar/LordWar4Layer"
			LordWar4Layer.show(LordWarData.kCrossType)
		end)
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1220"))
	end
end

--[[
	@des : 阶段状态变化推送
--]]
function roundUpdatePushCallback(p_round, p_status, p_event)
    if p_event == "roundChange" then
        if(MainScene.getOnRunningLayerSign() == "LordWarMainLayer") then
            updateButtonStatus()
        end
    end
end

-----------------------------------------[[ 工具方法 ]]------------------------------

function getTimeDes( p_timeInterval )
	local hour = math.floor(p_timeInterval/3600)
	local min  = math.floor((p_timeInterval - hour*3600)/60)
	local sec  = p_timeInterval - hour*3600 - 60*min
	local ret1 = string.format("%02d",hour) .. "  :  " .. string.format("%02d",min) .. "  :  ".. string.format("%02d",sec)
	local ret2 = string.format("%02d",hour) .. ":" .. string.format("%02d",min) .. ":".. string.format("%02d",sec)
	return ret1
end

function getIsEneter( ... )
	if _isEnter == nil then
		return false
	else
		return true
	end
end



