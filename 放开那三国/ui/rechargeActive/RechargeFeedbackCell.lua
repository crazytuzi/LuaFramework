-- Filename: RechargeFeedbackCell.lua
-- Author: ZQ
-- Date: 2014-01-09
-- Purpose: 创建充值回馈层的表格单元

module("RechargeFeedbackCell",package.seeall)
require "script/ui/rechargeActive/RechargeFeedbackCache"

function createTableCell(cellDataTable)
	local tableCell = CCTableViewCell:create()

	--表格单元背景
	local fullRect = CCRectMake(0,0,82,111)
	local insertRect = CCRectMake(10,10,62,91)
	local cellBg = CCScale9Sprite:create("images/common/bg/y_9s_bg.png",fullRect,insertRect)
	cellBg:setPreferredSize(CCSizeMake(583,194))
	tableCell:addChild(cellBg)

	--回馈奖励图标列表背景
	fullRect = CCRectMake(0,0,49,49)
	insertRect = CCRectMake(12,12,25,25)
	local itemListBg = CCScale9Sprite:create("images/common/bg/search_bg.png",fullRect,insertRect)
	itemListBg:setPreferredSize(CCSizeMake(419,132))
	itemListBg:setAnchorPoint(ccp(0,0))
	itemListBg:setPosition(15,15)
	cellBg:addChild(itemListBg)

	--表格单元标题
	local titleStr = GetLocalizeStringBy("key_3009") .. cellDataTable.expenseGold ..GetLocalizeStringBy("key_1186")
	local cellTitle = CCRenderLabel:create(titleStr,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	cellTitle:setColor(ccc3(0xff,0xf6,0x00))
	cellTitle:setAnchorPoint(ccp(0,0))
	cellTitle:setPosition(15,156)
	cellBg:addChild(cellTitle)

	local titleStr0 = "(" .. RechargeFeedbackCache.getTotalRechargeGoldNum() .. "/" .. cellDataTable.expenseGold .. ")"
	local cellTitle0 = CCRenderLabel:create(titleStr0,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	cellTitle0:setAnchorPoint(ccp(0,0))
	cellTitle0:setPosition(cellTitle:getContentSize().width,0)
	cellTitle:addChild(cellTitle0)
	local totalRechargeGoldNum = tonumber(RechargeFeedbackCache.getTotalRechargeGoldNum())
	if totalRechargeGoldNum >= cellDataTable.expenseGold then
		cellTitle0:setColor(ccc3(0x00,0xff,0x18))
	else
		cellTitle0:setColor(ccc3(0xff,0x00,0x00))
	end

	--领取按钮
	local receiveBtn = createReceiveBtn(tonumber(cellDataTable.id))
	receiveBtn:setPosition(445,56)
	cellBg:addChild(receiveBtn)

	--回馈奖励图标列表
	local feedbackList = createFeedbackList(cellDataTable, itemListBg)
	feedbackList:setTouchPriority(-155)
	local container = tolua.cast(feedbackList:getContainer(),"CCLayer")

	--创建屏蔽层中CCScrollView的viewSize精灵
	local feedbackListViewSprite = CCSprite:create()
	feedbackListViewSprite:setContentSize(feedbackList:getViewSize())
	feedbackListViewSprite:setPosition(feedbackList:getPosition())
	itemListBg:addChild(feedbackListViewSprite)

	--添加屏蔽层(方法3)
	local function touchCb(eventType, x, y)
		if eventType == "began" then
			local rectTemp0 = getSpriteScreenRect(cellBg)
			if not rectTemp0:containsPoint(ccp(x,y)) then
				return false
			end
			local rectTemp1 = getSpriteScreenRect(feedbackListViewSprite)
			local rectTemp2 = getSpriteScreenRect(receiveBtn)
			if rectTemp1:containsPoint(ccp(x,y)) then
				return false
			end
			if rectTemp2:containsPoint(ccp(x,y)) then
				if tolua.cast(receiveBtn:getChildByTag(cellDataTable.id),"CCMenuItemSprite"):isEnabled() then
					return false
				else
					return true
				end
			end
			return true
		end
	end
	container:registerScriptTouchHandler(touchCb,false,-150,true)
	container:setTouchPriority(-150)

	return tableCell
end

function createReceiveBtn(iId)
	local normalSprite = CCSprite:create("images/level_reward/receive_btn_n.png")
	local normalSpriteContentSize = normalSprite:getContentSize()
	local ableLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"),g_sFontPangWa,35,1,ccc3(0x00,0x00,0x00),type_shadow)
	ableLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	ableLabel:setAnchorPoint(ccp(0.5,0.5))
	ableLabel:setPosition(normalSpriteContentSize.width*0.5,normalSpriteContentSize.height*0.5)
	normalSprite:addChild(ableLabel)

	local selectedSprite = CCSprite:create("images/level_reward/receive_btn_h.png")
	local selectedSpriteContentSize = selectedSprite:getContentSize()
	local selectedLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	selectedLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	selectedLabel:setAnchorPoint(ccp(0.5,0.5))
	selectedLabel:setPosition(selectedSpriteContentSize.width*0.5,selectedSpriteContentSize.height*0.5)
	selectedSprite:addChild(selectedLabel)

	local cellDataTable = RechargeFeedbackCache.getFeedbackDataById(iId)
	local totalRechargeGoldNum = tonumber(RechargeFeedbackCache.getTotalRechargeGoldNum())
	local disableLabelStr = GetLocalizeStringBy("key_1715")
	if totalRechargeGoldNum >= cellDataTable.expenseGold then
		disableLabelStr = GetLocalizeStringBy("key_1369")
	end

	local disableSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
	local disableLabel = CCRenderLabel:create(disableLabelStr,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	disableLabel:setColor(ccc3(0xab,0xab,0xab))
	disableLabel:setAnchorPoint(ccp(0.5,0.5))
	disableLabel:setPosition(normalSpriteContentSize.width*0.5,normalSpriteContentSize.height*0.5)
	disableSprite:addChild(disableLabel)

	local menuItem = CCMenuItemSprite:create(normalSprite,selectedSprite,disableSprite)
	menuItem:setAnchorPoint(ccp(0,0))
	menuItem:setPosition(0,0)
	menuItem:registerScriptTapHandler(tapReceiveBtnCb)

	local bReceived = RechargeFeedbackCache.isFeedbackHasReceivedById(iId)
	if bReceived then
		menuItem:setEnabled(false)
	else
		if totalRechargeGoldNum < cellDataTable.expenseGold then
			menuItem:setEnabled(false)
		else
			menuItem:setEnabled(true)
		end
	end

	local menu = CCMenu:create()
	-- local function touchCb(eventType, x, y)
	-- 	if eventType == "began" then
	-- 		print("rrrrr:")
	-- 		local rect = getSpriteScreenRect(menuItem)
	-- 		if rect:containsPoint(ccp(x,y)) then
	-- 			return true
	-- 		end
	-- 		return false
	-- 	end
	-- end
	-- menu:registerScriptTouchHandler(touchCb,false,-145,true)
	-- print("hhhhhh:",menu:getTouchPriority()) --输出：128？
	menu:setTouchPriority(-145)
	menu:setTouchEnabled(true)
	menu:setContentSize(normalSpriteContentSize)
	menu:addChild(menuItem,0,iId)
	return menu
end

-- 点击领取按钮事件的处理方法
require "script/ui/tip/SingleTip"
function tapReceiveBtnCb(tagObjectTapped, objectTapped)
	if( BTUtil:getSvrTimeInterval()<RechargeFeedbackCache.getFeedbackStartTime() or BTUtil:getSvrTimeInterval() > RechargeFeedbackCache.getFeedbackEndTime()) then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_2397"))
		return
	end	

	local cellDataTable = RechargeFeedbackCache.getFeedbackDataById(tonumber(tagObjectTapped))
	local totalRechargeGoldNum = tonumber(RechargeFeedbackCache.getTotalRechargeGoldNum())

	if totalRechargeGoldNum < cellDataTable.expenseGold then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_3007"))
		return
	end
	SingleTip.showSingleTip(GetLocalizeStringBy("key_2334"))

	if not RechargeFeedbackCache.canBagReceiveFeedback(cellDataTable) then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_1432"))
		return
	end

	if not RechargeFeedbackCache.canCarryHero(cellDataTable) then
		--SingleTip.showSingleTip(GetLocalizeStringBy("key_1198"))
		return
	end

	-- 点击领取按钮事件处理方法中服务器数据返回后的回调函数
	local function addDataCb(cbFlag, dictData, bRet)
		if bRet == false then return end

		-- 使按钮无效
		objectTapped:setEnabled(false)

		-- 将正在领取的活动id加入本地的已领取活动id数组中
		RechargeFeedbackCache.addIdIntoIdArrayHaveReceived(tonumber(tagObjectTapped))

		-- 增加用户对应的本地数据
		RechargeFeedbackCache.addUserLocalData(cellDataTable)

		-- 展示已领取充值回馈奖励
		local feedbackFormatData = RechargeFeedbackCache.getShowFeedbackFormatData(cellDataTable)
		require "script/ui/item/ReceiveReward"
		ReceiveReward.showRewardWindow(feedbackFormatData,nil, 1010)
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(tagObjectTapped)))
	RechargeFeedbackCache.addUserServerData(addDataCb,args)
end

function createFeedbackList(cellDataTable, itemListBg)
	local feedbackList = CCScrollView:create()
	local viewWidth = itemListBg:getContentSize().width - 20
	local viewHeight = itemListBg:getContentSize().height - 10
	feedbackList:setViewSize(CCSizeMake(viewWidth,viewHeight))
	-- feedbackList:setContentSize(CCSizeMake(viewWidth,viewHeight))
	feedbackList:setDirection(kCCScrollViewDirectionHorizontal)
	feedbackList:setBounceable(true)
	feedbackList:setPosition(10,5)
	itemListBg:addChild(feedbackList)

	--print("wweerrtt:",tolua.type(CCLayer))
	local container = CCLayer:create()
	--Bug
	--此时获得的BTSensitiveMenu对象container的计数器已为1
	--临时做法
	if tolua.type(container) == "BTSensitiveMenu" then
		--print("hhhhhhhhhh...........",tolua.type(container),container:retainCount())
		container:retain()
		container:autorelease()
		container = CCLayer:create()
		--print("hhhhhhhhhh...........",tolua.type(container))
	end
	--print("123345:",tolua.type(container))
	container:setPosition(0,0)
	--print("wweerrtt:",tolua.type(container))
	container:setTouchEnabled(true)
	--print("sssssss:",tolua.type(container))
	feedbackList:setContainer(container)
	--print(tolua.type(container))

	local iconOffsetX = 0
	local iconIntervalX = 13
	for i = 1,tonumber(cellDataTable.feedback_total) do
		local icon = RechargeFeedbackCache.getIconByTypeAndId(tonumber(cellDataTable["feedback_type" .. i]),
			                                                  tonumber(cellDataTable["feedback_id" .. i]),
			                                                  tonumber(cellDataTable["feedback_num" .. i]))
		icon:setAnchorPoint(ccp(0,0))
		icon:setPosition(iconOffsetX,24)
		container:addChild(icon)

		iconOffsetX = iconOffsetX + icon:getContentSize().width + iconIntervalX
	end
	container:setContentSize(CCSizeMake(iconOffsetX - iconIntervalX, viewHeight))
	--print("oooooss:",feedbackList:getContentSize().width,feedbackList:getContentSize().height)

	return feedbackList
end
