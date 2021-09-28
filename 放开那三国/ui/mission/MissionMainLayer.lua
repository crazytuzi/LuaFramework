-- FileName: MissionMainLayer.lua
-- Author: lcy
-- Date: 2015-08-28
-- Purpose: 悬赏榜主界面
--[[TODO List]]

module("MissionMainLayer", package.seeall)
require "script/ui/mission/MissionMainService"
require "script/ui/mission/MissionMainData"
require "script/ui/mission/gold/MissionGoldDialog"
require "script/ui/mission/MissionMainController"

local _bgLayer     = nil
local _taskButton  = nil
local _goldButton  = nil
local _itemButton  = nil
local _goldPanel   = nil
local _rewardPanel = nil
function init( ... )
	_bgLayer     = nil
	_taskButton  = nil
	_goldButton  = nil
	_itemButton  = nil
	_goldButton  = nil
	_rewardPanel = nil
end
--[[
	@des 	:入口函数，用于场景切换
--]]
function showLayer()
    local layer = MissionMainLayer.createLayer()
    MainScene.changeLayer(layer, "MissionMainLayer")
end

--[[
	@des : 创建layer
--]]
function createLayer()
    init()
    _isEnter = true
	_bgLayer = CCLayer:create()
	_layerSize = g_winSize 
	MainScene.setMainSceneViewsVisible(false, false, false)
	local bgSprite = CCSprite:create("images/mission/mission_bg.jpg")
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setScale(g_fBgScaleRatio * 1.0)
	_bgLayer:addChild(bgSprite)

	local effectBg = CCSprite:create("images/mission/effect_bg.png")
	effectBg:setPosition(ccps(0.5, 0.63))
	effectBg:setAnchorPoint(ccp(0.5, 0.5))
	effectBg:setScale(MainScene.elementScale)
	_bgLayer:addChild(effectBg)

	local bgEffect = XMLSprite:create("images/mission/xuanshangbangjiemian/xuanshangbangjiemian")
	bgEffect:setPosition(ccpsprite(0.5, 0.5, effectBg))
	bgEffect:setReplayTimes(1, false)
	effectBg:addChild(bgEffect)

	createTopUi()
	MissionMainService.getMissionInfo(function ( pRetData )
		MissionMainData.setInfo(pRetData)
		--如果没在分组内
		if MissionMainData.getTeamId() <= 0 then
			require "script/ui/tip/AlertTip"
	    	AlertTip.showAlert(GetLocalizeStringBy("lcyx_1972"), function ( ... )
	   			closeButtonCallFunc()
			end,nil,nil,nil,nil,nil,nil,false)
		else
			createCenterUi()
			createDayRewardLayer()
			updateUI()
			createActivityTimeTitle()
		end
	end)
	return _bgLayer
end

--[[
	@des : 创建顶部ui
--]]
function createTopUi( ... )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(376,48))
	retSprite:setAnchorPoint(ccp(0.5, 1))
	retSprite:setPosition(ccps(0.5, 0.98))
	_bgLayer:addChild(retSprite, 10)
	-- 背景特效
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mission/xuanshangbang/xuanshangbang"), -1,CCString:create(""))
    animSprite:setAnchorPoint(ccp(0.5, 0.5))
    animSprite:setPosition(ccpsprite(0.5,0.5,retSprite))
    retSprite:addChild(animSprite)
	-- 第几届
	local num = MissionMainData.getSeason()-1 -- 策划需求
	local numFont = CCLabelTTF:create(num, g_sFontPangWa,40)
	numFont:setColor(ccc3(0xff,0xf6,0x00))
	numFont:setAnchorPoint(ccp(0.5,0.5))
	numFont:setPosition(ccp(125,retSprite:getContentSize().height*0.5))
	retSprite:addChild(numFont,2)
	retSprite:setScale(MainScene.elementScale)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-504)
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
	--商店
	local shopButton = CCMenuItemImage:create("images/mission/fame_btn_n.png","images/mission/fame_btn_h.png")
	shopButton:setAnchorPoint(ccp(0.5, 0.5))
	shopButton:setPosition(ccp(_layerSize.width * 0.56 ,_layerSize.height * 0.79))
	shopButton:registerScriptTapHandler(shopButtonCallback)
	menu:addChild(shopButton)
	shopButton:setScale(MainScene.elementScale)
	--排行榜按钮
	local rankButton = CCMenuItemImage:create("images/mission/rank_btn_n.png","images/mission/rank_btn_h.png")
	rankButton:setAnchorPoint(ccp(0.5, 0.5))
	rankButton:setPosition(ccp(_layerSize.width * 0.40 ,_layerSize.height * 0.79))
	rankButton:registerScriptTapHandler(rankButtonCallback)
	menu:addChild(rankButton)
	rankButton:setScale(MainScene.elementScale)
	-- rankButton:setVisible(LordwarShopData.isShopOpen()) --当前版本屏蔽入口
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

--[[
	@des:创建任务，金币捐献，物品捐献按钮
--]]
function createCenterUi( ... )
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)
	menu:setTouchPriority(-504)
	--任务
	_taskButton = createMenuItem(GetLocalizeStringBy("lcyx_1930"), nil, nil, CCSizeMake(205, 70))
	_taskButton:setAnchorPoint(ccp(0.5, 1))
	_taskButton:registerScriptTapHandler(taskButtonCallback)
	_taskButton:setPosition(ccps(0.18, 0.2))
	menu:addChild(_taskButton)
	_taskButton:setScale(MainScene.elementScale)
	--金币捐献按钮
	local selectedString = GetLocalizeStringBy("lcyx_1931")
	local normalString   = GetLocalizeStringBy("lcyx_1931")
	local size = CCSizeMake(205, 70)
	local norSprite1 = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite1:setContentSize(size)
	norSprite1:setAnchorPoint(ccp(0.5, 0.5))
	local norTitle1  =  CCRenderLabel:create(normalString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle1:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle1:setPosition(ccpsprite(0.5, 0.5, norSprite1))
	norTitle1:setAnchorPoint(ccp(0.5, 0.5))
	norSprite1:addChild(norTitle1)

	local norSprite2 = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite2:setContentSize(size)
	norSprite2:setAnchorPoint(ccp(0.5, 0.5))
	local norTitle2  =  CCRenderLabel:create(normalString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle2:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle2:setPosition(ccpsprite(0.5, 0.5, norSprite2))
	norTitle2:setAnchorPoint(ccp(0.5, 0.5))
	norSprite2:addChild(norTitle2)

	local higSprite1 = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite1:setContentSize(size)
	higSprite1:setAnchorPoint(ccp(0.5, 0.5))
	local higTitle1  =  CCRenderLabel:create(selectedString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle1:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle1:setPosition(ccpsprite(0.5, 0.5, higSprite1))
	higTitle1:setAnchorPoint(ccp(0.5, 0.5))
	higSprite1:addChild(higTitle1)

	local higSprite2 = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite2:setContentSize(size)
	higSprite2:setAnchorPoint(ccp(0.5, 0.5))
	local higTitle2  =  CCRenderLabel:create(selectedString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle2:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle2:setPosition(ccpsprite(0.5, 0.5, higSprite2))
	higTitle2:setAnchorPoint(ccp(0.5, 0.5))
	higSprite2:addChild(higTitle2)

	local itemNormal = CCMenuItemSprite:create(norSprite1, norSprite2)
	itemNormal:setAnchorPoint(ccp(0.5, 0.5))
	local itemHight  = CCMenuItemSprite:create(higSprite1, higSprite2)
	itemHight:setAnchorPoint(ccp(0.5, 0.5))
	_goldButton = CCMenuItemToggle:create(itemNormal)
	_goldButton:addSubItem(itemHight)
    _goldButton:setAnchorPoint(ccp(0.5, 1))
	_goldButton:registerScriptTapHandler(goldButtonCallback)
	_goldButton:setPosition(ccps(0.5, 0.2))
	menu:addChild(_goldButton)
	_goldButton:setScale(MainScene.elementScale)
	--物品捐献
    _itemButton = createMenuItem(GetLocalizeStringBy("lcyx_1932"), nil, nil, CCSizeMake(205, 70))
	_itemButton:setAnchorPoint(ccp(0.5, 1))
	_itemButton:registerScriptTapHandler(itemButtonCallback)
	_itemButton:setPosition(ccps(0.82, 0.2))
	menu:addChild(_itemButton)
	_itemButton:setScale(MainScene.elementScale)

	_goldPanel = MissionGoldDialog.create()
	_goldPanel:setAnchorPoint(ccp(0.5, -0.1))
	_goldPanel:setPosition(ccpsprite(0.5, 1, _goldButton))
	_goldButton:addChild(_goldPanel, -10)
end

--[[
	@des:创建每日领奖界面
--]]
function createDayRewardLayer()

	_rewardPanel = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	_rewardPanel:setPreferredSize(CCSizeMake(630, 265))
	_rewardPanel:setAnchorPoint(ccp(0.5, 0))
	_rewardPanel:setPosition(ccps(0.5, 0))
	_bgLayer:addChild(_rewardPanel)
	_rewardPanel:setScale(MainScene.elementScale)

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(585, 140))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(_rewardPanel:getContentSize().width*0.5, 70))
	_rewardPanel:addChild(tableBackground)

	local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/dress_room/name_bg.png")
	_rewardPanel:addChild(nameBg, 10)
	nameBg:setPreferredSize(CCSizeMake(300, 68))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(_rewardPanel:getContentSize().width * 0.5, _rewardPanel:getContentSize().height - 3))
	
	local title = MissionMainData.getRewardTitle()
	local name = CCLabelTTF:create(title, g_sFontPangWa, 30)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))

	local rewardList = MissionMainData.getDayRewardItemList()
	local function rewardItemTableCallback( fn, table, a1, a2 )
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110, 140)
		elseif fn == "cellAtIndex" then
			a2 = createRewardCell(rewardList[a1 + 1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #rewardList
		elseif fn == "cellTouched" then

		end
		return r
	end
	local tableViewSize = CCSizeMake(580,140)
	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0, 0))
	rewardItemTable:setPosition(ccp(5, 0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-600)
	tableBackground:addChild(rewardItemTable)
	rewardItemTable:reloadData()

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_rewardPanel:addChild(menu)
	menu:setTouchPriority(-504)
	--领取奖励
	_rewardButton = createMenuItem(GetLocalizeStringBy("lcyx_1945"), nil, GetLocalizeStringBy("lcyx_1958"), CCSizeMake(188, 70))
	_rewardButton:setAnchorPoint(ccp(0.5, 0))
	_rewardButton:registerScriptTapHandler(reciveRewardButtonCallback)
	_rewardButton:setPosition(ccpsprite(0.5, 0.01, _rewardPanel))
	menu:addChild(_rewardButton)
	local reciveTime = MissionMainData.getDayrewardTime()
	local nowTime = TimeUtil.getSvrTimeByOffset()
	if TimeUtil.isSameDay(reciveTime, nowTime) then
		_rewardButton:setEnabled(false)
	end
end

--[[
	@des:创建一个每日奖励单元格
--]]
function createRewardCell( pInfo )
	local itemInfo = ItemUtil.getItemsDataByStr(pInfo)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo)
	local cell = CCTableViewCell:create()
	cell:setContentSize(icon:getContentSize())
	icon:setPosition(ccpsprite(0.2, 0.4, cell))
	cell:addChild(icon)
	return cell
end

--[[
	@des:活动时间
--]]
function createActivityTimeTitle()

	local bgSprite = CCSprite:create()
	bgSprite:setPosition(ccps(0.5, 0.90))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(bgSprite)
	bgSprite:setScale(MainScene.elementScale)
	--活动时间
	local timeDes = MissionMainData.getTimeDes()
	_activityTimeLable = CCRenderLabel:create(timeDes, g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	_activityTimeLable:setColor(ccc3(0x00,0xff,0x18))
	_activityTimeLable:setPosition(ccpsprite(0.5, 0.5, bgSprite))
	_activityTimeLable:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:addChild(_activityTimeLable)

	local bgSprite2 = CCSprite:create()
	bgSprite2:setPosition(ccps(0.5, 0.86))
	bgSprite2:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(bgSprite2)
	bgSprite2:setScale(MainScene.elementScale)

	--活动剩余时间
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local havaTime = TimeUtil.getTimeString(MissionMainData.getStartTime() + MissionMainData.getDonateTime() - nowTime)
	local havaTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1951", havaTime), g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	havaTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	havaTimeLabel:setPosition(ccpsprite(0.5, 0.5, bgSprite2))
	havaTimeLabel:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite2:addChild(havaTimeLabel)
	if not MissionMainData.isCanDonate() then
		havaTimeLabel:setVisible(false)
	end
	schedule(havaTimeLabel, function ( ... )
		local nowTime = TimeUtil.getSvrTimeByOffset()
		if not MissionMainData.isCanDonate() then
			havaTimeLabel:setVisible(false)
		end
		local havaTime = TimeUtil.getTimeString(MissionMainData.getStartTime() + MissionMainData.getDonateTime() - nowTime)
		havaTimeLabel:setString(GetLocalizeStringBy("lcyx_1951", havaTime))
		local timeDes = MissionMainData.getTimeDes()
		_activityTimeLable:setString(timeDes)
		updateUI()
	end, 1)
end

--[[
	@des:刷新ui显示
--]]
function updateUI()
	if not MissionMainData.isCanDonate() then
		_rewardPanel:setVisible(true)
		_taskButton:setVisible(false)
		_goldButton:setVisible(false)
		_itemButton:setVisible(false)
	else
		_taskButton:setVisible(true)
		_goldButton:setVisible(true)
		_itemButton:setVisible(true)
		_rewardPanel:setVisible(false)
	end
end

--[[
	@des:任务回调
--]]
function taskButtonCallback( ... )
	MissionGoldDialog.hide()
	_goldButton:setSelectedIndex(0)
	require "script/ui/mission/task/MissionTaskDialog"
	MissionTaskDialog.showLayer()
end

--[[
	@des:金币捐献按钮
--]]
function goldButtonCallback( pTag, pSender )
	local button = tolua.cast(pSender, "CCMenuItemToggle")
	local selectIndex = button:getSelectedIndex()
	if selectIndex == 0 then
		MissionGoldDialog.hide()
	else
		MissionGoldDialog.show()
	end
end

--[[
	@des:物品捐献
--]]
function itemButtonCallback( ... )
	MissionGoldDialog.hide()
	_goldButton:setSelectedIndex(0)
	require "script/ui/mission/item/MissionItemDialog"
	MissionItemDialog.show()
end

--[[
	@des:排行榜按钮
--]]
function rankButtonCallback( ... )
	require "script/ui/mission/rank/MissionRankLayer"
	MissionRankLayer.show()
end

--[[
	@des:关闭按钮回调
--]]
function closeButtonCallFunc( ... )
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)
end

--[[
	@des:活动说明
--]]
function explainButtonCallFunc( ... )
	require "script/ui/mission/MissionExplainDialog"
	MissionExplainDialog.show(-512)
end

--[[
	@des:奖励预览
--]]
function rewardPreviewButtonCallback( ... )
	require "script/ui/mission/reward/MissionRewardLayer"
	MissionRewardLayer.show(nil,nil,"bounty")
end

--[[
	@des:商店按钮回调
--]]
function shopButtonCallback( ... )
	require "script/ui/mission/shop/MissionShopLayer"
	MissionShopLayer.showLayer()
end

--[[
	@des:领取每日奖励按钮
--]]
function reciveRewardButtonCallback()
	MissionMainController.receiveDayReward(function()
		_rewardButton:setEnabled(false)
	end)
end
