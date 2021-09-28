-- Filename: RechargeFeedbackLayer.lua
-- Author: ZQ
-- Date: 2014-01-08
-- Purpose: 创建充值回馈界面

module("RechargeFeedbackLayer",package.seeall)

require "script/ui/rechargeActive/RechargeFeedbackCache"
require "script/model/utils/ActivityConfigUtil"

--local _layer = nil
local _layerBg = nil
local _offsetY = nil
local _visibleHeight = nil

function createLayer()
	_visibleHeight = g_winSize.height / g_fScaleX
	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
    require "script/ui/rechargeActive/RechargeActiveMain"
	_offsetY = RechargeActiveMain.getTopBgHeight()+bulletinLayerSize.height

	-- 创建充值回馈活动层
	layer = CCLayer:create()
	layer:setTouchPriority(-170)
	layer:setTouchEnabled(true)
	--layer:setContentSize(CCSizeMake(640,960))
	layer:setContentSize(CCSizeMake(640,_visibleHeight))
	--layer:setScaleX(g_fScaleX)
	--layer:setScaleY(g_fScaleY)
	layer:setScale(g_fScaleX)
	--_layer:addChild(layer)
	-- require "script/ui/main/MainScene"
	-- layer:setScale(MainScene.bgScale)

	local function funcCb()
		createLayerElements(layer)
	end
	RechargeFeedbackCache.getRechargeFeedbackInfoFromSever(funcCb)

	return layer
end

function createLayerElements(layer)
	-- 红色背景
	_layerBg = CCSprite:create("images/recharge/fund/fund_bg.png")
	_layerBg:setAnchorPoint(ccp(0,0))
	local layerBgScale = ((g_fScaleX > g_fScaleY) and g_fScaleX or g_fScaleY) / g_fScaleX
	_layerBg:setScale(layerBgScale)
	_layerBg:setPosition(0,0)
	layer:addChild(_layerBg)

	-- 人物背景
	local characterBg = createCharacter(layer)

	--标题“充值回馈”
	local title = createTitle(layer)

	--累计y轴上的偏移量
	_offsetY = _offsetY + characterBg:getContentSize().height

	--活动内容
	local content = createContent(title)

	--活动时间
	local timeLog = createTimeLog(layer)

	-- 从服务器获取充值回馈活动数据并创建回馈奖励表
	local feedbackTable,notShieldArea = createFeedbackTable(layer)

	-- 划分屏蔽区域
	require "script/ui/rechargeActive/RechargeActiveMain"
	local rect = getSpriteScreenRect(RechargeActiveMain.getTopBgSp())
	local function touchCb(eventType,touch)
		if eventType == "began" then
			local x = touch[1]
			local y = touch[2]
			--local tag = touch[3]
			local rect0 = getSpriteScreenRect(notShieldArea)
			if rect:containsPoint(ccp(x,y)) or rect0:containsPoint(ccp(x,y)) then
				--print("yyyyyyy")
				return false
			end
			return true
		end
	end
	layer:registerScriptTouchHandler(touchCb,false,-170,true)

	return layer
end

function createCharacter(layer)
	local characterBg = CCSprite:create("images/recharge/feedback_active/character_bg.png")
	characterBg:setAnchorPoint(ccp(0,1))
	characterBg:setPosition(0, _visibleHeight - _offsetY)
	layer:addChild(characterBg)

	return characterBg
end

function createTitle(layer)
	local title = CCSprite:create("images/recharge/feedback_active/title.png")
	title:setAnchorPoint(ccp(0,1))
	title:setPosition(231, _visibleHeight - _offsetY + 65)
	layer:addChild(title)

	return title
end

function createContent(title)
	local fullRect = CCRectMake(0,0,187,30)
	local insertRect = CCRectMake(53,5,81,20)
	local contentBg = CCScale9Sprite:create("images/recharge/feedback_active/content_bg.png",
		                                    fullRect,insertRect)
	contentBg:setPreferredSize(CCSizeMake(400,100))
	contentBg:setAnchorPoint(ccp(0.5,1))
	contentBg:setPosition(title:getContentSize().width*0.5+5,-3)
	title:addChild(contentBg)

	-- local textStr = GetLocalizeStringBy("key_1512")
	-- local text = CCRenderLabel:create(textStr,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- text:setColor(ccc3(0xff,0xf6,0x00))
	local contentBgPreferredSize = contentBg:getPreferredSize()
	-- --text:setContentSize(CCSizeMake(contentBgPreferredSize.width-5,contentBgPreferredSize.height-4))
	-- --text:setDimensions(CCSizeMake(400,100))
	-- --text:setHorizontalAlignment(kCCTextAlignmentCenter) nil?
	-- --text:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	local text = CCSprite:create("images/recharge/feedback_active/context.png")
	text:setAnchorPoint(ccp(0.5,0.5))
	text:setPosition(contentBgPreferredSize.width*0.5,contentBgPreferredSize.height*0.5)
	contentBg:addChild(text)

	return contentBg
end

function createTimeLog(layer)
	local layerContentSize = layer:getContentSize()

	local fullRect = CCRectMake(0,0,112,29)
	local insertRect = CCRectMake(10,5,92,19)
	local timeLog = CCScale9Sprite:create("images/recharge/feedback_active/time_bg.png",
		                                  fullRect,insertRect)
	timeLog:setPreferredSize(CCSizeMake(640,28))
	timeLog:setAnchorPoint(ccp(0.5,0.5))
	timeLog:setPosition(layerContentSize.width*0.5,_visibleHeight - 392)
	layer:addChild(timeLog)

	-- 获得活动开始时间
	-- require "script/ui/activity/ActivityUtil"
	-- local startTime = ActivityUtil.getRechargeFeedbackStartTime()
	local startTime = RechargeFeedbackCache.getFeedbackStartTime()
	require "script/utils/TimeUtil"
	local startTimeStr = TimeUtil.getTimeToMin(startTime) or " "

	-- --获得活动结束时间
	-- local endTime = ActivityUtil.getRechargeFeedbackEndTime()
	local endTime = RechargeFeedbackCache.getFeedbackEndTime()
	local endTimeStr = TimeUtil.getTimeToMin(endTime) or " "

	local timeLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3174") .. startTimeStr .. " — " .. endTimeStr,
		                                g_sFontName,21--[[,timeLog:getContentSize(),
		                                kCCTextAlignmentCenter,
		                                kCCVerticalTextAlignmentCenter]])
	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	timeLabel:setAnchorPoint(ccp(0.5,0.5))
	--timeLabel:setDimensions(CCSizeMake(100,100))
	local timeLogContentSize = timeLog:getContentSize()
	timeLabel:setPosition(timeLogContentSize.width*0.5,timeLogContentSize.height*0.5)
	timeLog:addChild(timeLabel)

	return timeLog
end

function createFeedbackTable(layer)
	local layerContentSize = layer:getContentSize()

	local fullRect = CCRectMake(0,0,75,75)
	local insertRect = CCRectMake(10,10,55,55)
	local tableBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png",fullRect,insertRect)
	tableBg:setPreferredSize(CCSizeMake(603,_visibleHeight - _offsetY - 111 - 8))
	tableBg:setAnchorPoint(ccp(0.5,1))
	tableBg:setPosition(layerContentSize.width*0.5,_visibleHeight - _offsetY + 20)
	--tableBg:registerScriptTouchHandler(setTouchAbleAreaCb)
	layer:addChild(tableBg)

	require "script/ui/rechargeActive/RechargeFeedbackCache"
	local dataSource = RechargeFeedbackCache.getAllFeedbackFormatData()
	require "script/ui/rechargeActive/RechargeFeedbackCell"
	local function onSetTableParams(paramName,table,object1,object2)
		local ret = nil
		if paramName == "cellSize" then
			ret = CCSizeMake(583,194)
		elseif paramName == "cellAtIndex" then
			ret = RechargeFeedbackCell.createTableCell(dataSource[object1+1])
		elseif paramName == "numberOfCells" then
			ret = #dataSource
		else
		end
		return ret
	end
	local eventHandler = LuaEventHandler:create(onSetTableParams)
	local table = LuaTableView:createWithHandler(eventHandler,CCSizeMake(583,_visibleHeight - _offsetY - 111 - 28))
	table:setBounceable(true)
	table:setVerticalFillOrder(kCCTableViewFillTopDown)
	setFeedbackTableOffset(table,194)
	table:setPosition(10,10)
	table:setTouchPriority(-160)
	tableBg:addChild(table)

	-- 创建屏蔽层中非屏蔽区域精灵
	local notShieldArea = CCSprite:create()
	notShieldArea:setContentSize(table:getViewSize())
	notShieldArea:setPosition(10,10)
	tableBg:addChild(notShieldArea)

	-- -- 添加屏蔽层,避免在viewSize外触发预加载cell的事件
	-- --local shieldLayer = CCLayerColor:create(ccc4(0x00,0x00,0x00,0x80))
	-- local shieldLayer = CCLayer:create()
	-- shieldLayer:setTouchEnabled(true)
	-- shieldLayer:setTouchPriority(-170)
	-- layer:addChild(shieldLayer)
	-- require "script/ui/rechargeActive/RechargeActiveMain"
	-- local rect = getSpriteScreenRect(RechargeActiveMain.getTopBgSp())
	-- local function touchCb(eventType,touch)
	-- 	if eventType == "began" then
	-- 		local x = touch[1]
	-- 		local y = touch[2]
	-- 		--local tag = touch[3]
	-- 		local rect0 = getSpriteScreenRect(notShieldArea)
	-- 		if rect:containsPoint(ccp(x,y)) or rect0:containsPoint(ccp(x,y)) then
	-- 			print("yyyyyyy")
	-- 			return false
	-- 		end
	-- 		print("rrrrrrr")
	-- 		return true
	-- 	end
	-- end
	-- shieldLayer:registerScriptTouchHandler(touchCb,false,-170,true)

	return tableBg,notShieldArea
end

-- 设置充值回馈table的content偏移量
function setFeedbackTableOffset(table,cellHeight)
	local num = RechargeFeedbackCache.getFirstDiscontinousFeedbackIdHasReceived()
	local offset = table:getContentOffset()
	offset.y = offset.y + num * cellHeight
	table:setContentOffset(offset)
end

-- 是否开启活动 add by licong 2014.03.12
function isOpenRechargeBack( ... )
    local isOpen = false
    if(not table.isEmpty(ActivityConfigUtil.getDataByKey("topupFund"))) then
        isOpen = ActivityConfigUtil.isActivityOpen("topupFund")
    else
        isOpen = false
    end
    return isOpen
end
