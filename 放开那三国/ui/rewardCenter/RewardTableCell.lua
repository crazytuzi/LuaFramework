-- Filename: RewardTableCell.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 奖励列表的单元格

require "script/utils/extern"
require "script/utils/LuaUtil"

RewardTableCell = class("RewardTableCell", function ( ... )
	return CCTableViewCell:create()
end)

RewardTableCell.__index = RewardTableCell

RewardTableCell.time 						= nil			--发奖时间
RewardTableCell.title 						= nil			--奖励类型标题
RewardTableCell.content 					= nil			--奖励内容描述
RewardTableCell.rid							= nil			--物品id
RewardTableCell.receiveRewardCallback		= nil			--领取物品回调
RewardTableCell.haveTime					= nil			--剩余过期时间
--创建tableCell
function RewardTableCell:create( rewardInfo, cellIndex,t_reviceCallback )
	local tableCell = RewardTableCell.new()


	-- print("rewardInfo",rewardInfo)
	print_table("RewardTableCell:create", rewardInfo)
	tableCell.rid	= rewardInfo.rid
	tableCell.receiveRewardCallback = t_reviceCallback

	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(568, 227))
	tableCell:addChild(cellBackground)

	local cellTitlePanel = CCSprite:create("images/reward/cell_title_panel.png")
	cellTitlePanel:setAnchorPoint(ccp(0, 1))
	cellTitlePanel:setPosition(ccp(0, cellBackground:getContentSize().height))
	cellBackground:addChild(cellTitlePanel)

	--类型标题
	-- change title size by zhz 35=> 30
	tableCell.title = CCRenderLabel:create(rewardInfo.title, g_sFontName, 30, 1, ccc3(0x00,0x00,0x00))
	tableCell.title:setColor(ccc3(0xff, 0xfb, 0xd9))
	local x = (cellTitlePanel:getContentSize().width - tableCell.title:getContentSize().width)/2
	local y = cellTitlePanel:getContentSize().height - (cellTitlePanel:getContentSize().height - tableCell.title:getContentSize().height)/2
	tableCell.title:setPosition(ccp(x , y))
	cellTitlePanel:addChild(tableCell.title)

	--发奖时间
	local rewardTime = GetLocalizeStringBy("key_1931") .. tostring(rewardInfo.time)
	-- print(rewardTime)
	tableCell.time = CCRenderLabel:create(rewardTime, g_sFontName, 23, 1, ccc3(0,0,0))
	tableCell.time:setColor(ccc3(31, 196, 19))
	tableCell.time:setPosition(ccp(256, 205))
	cellBackground:addChild(tableCell.time)
	--内容描述
	tableCell.content = CCLabelTTF:create(rewardInfo.content, g_sFontName, 20)
	tableCell.content:setAnchorPoint(ccp(0, 1))
	tableCell.content:setPosition(ccp(26, 165))
	tableCell.content:setColor(ccc3(0x78, 0x25, 0x00))
	cellBackground:addChild(tableCell.content)

	--创建奖励物品
	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	itemback:setContentSize(CCSizeMake(406, 125))
	itemback:setPosition(ccp(23, 14))
	cellBackground:addChild(itemback)

	local function rewardItemTableCallback( fn, table, a1, a2 )
		print(fn)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110, 115)
			-- print("cellSize", a1, r)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
				a2 = CCTableViewCell:create()
				local itemIconBg = nil
				local itemIcon   = nil

				print("rewardInfo.items[a1+1].tid = " , rewardInfo.items[a1+1].tid)
				print()
				if(rewardInfo.items[a1+1].tid ~= nil) then
					require "script/ui/item/ItemSprite"
					itemIconBg = ItemSprite.getItemSpriteByItemId(rewardInfo.items[a1+1].tid)
					a2:addChild(itemIconBg)
				else
					itemIconBg = CCSprite:create(rewardInfo.items[a1+1].bgPath)
					a2:addChild(itemIconBg)

					itemIcon = CCSprite:create(rewardInfo.items[a1+1].iconPath)
					itemIcon:setAnchorPoint(ccp(0.5, 0.5))
					itemIcon:setPosition(ccp(itemIconBg:getContentSize().width*0.5, itemIconBg:getContentSize().height*0.5))
					itemIconBg:addChild(itemIcon)
				end
				itemIconBg:setAnchorPoint(ccp(0, 0))
				itemIconBg:setPosition(ccp(10, 30))

				if(rewardInfo.items[a1+1].tid ~= nil and tonumber(rewardInfo.items[a1+1].tid) >= 400001 and tonumber(rewardInfo.items[a1+1].tid) <= 500000) then
					local heroSealSp = CCSprite:create("images/common/soul_tag.png")
					heroSealSp:setAnchorPoint(ccp(0.5, 0.5))
					heroSealSp:setPosition(ccp(itemIconBg:getContentSize().width*0.25, itemIconBg:getContentSize().height*0.85))
					itemIconBg:addChild(heroSealSp,10)
				end
				local numLabel = CCRenderLabel:create(tostring(rewardInfo.items[a1+1].num),g_sFontName,18,1,ccc3(0,0,0))
				numLabel:setColor(ccc3(38,237,18))
				local x = itemIconBg:getContentSize().width - numLabel:getContentSize().width - 5 * getScaleParm()
				local y = numLabel:getContentSize().height + 2
				numLabel:setPosition(ccp(x, y))
				itemIconBg:addChild(numLabel)


				local nameLabel = CCLabelTTF:create(rewardInfo.items[a1+1].name, g_sFontName, 21)
				nameLabel:setColor(ccc3(0x78,0x25,0x00))
				nameLabel:setAnchorPoint(ccp(0.5, 0))
				local x = itemIconBg:getContentSize().width*0.5 - numLabel:getContentSize().width*0.5
				local y = numLabel:getContentSize().height + 2
				--兼容东南亚英文版
				if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
					nameLabel:setVisible(false)
				end
				nameLabel:setPosition(ccp(55, 4 * getScaleParm()))
				a2:addChild(nameLabel)
			-- end
			--updata table cell
			r = a2
			-- print("cellAtIndex", a1, r)
		elseif fn == "numberOfCells" then
			r = #rewardInfo.items
			-- print("numberOfCells", a1, r)
		elseif fn == "cellTouched" then

		end
		return r
	end

	local tableViewSize = CCSizeMake(397,118)

	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0, 0))
	rewardItemTable:setPosition(ccp(5, 0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-600)

	local function itemBackLayerTouch( eventType,x,y )
		-- body
		print("itemBackLayer touch:",x,y)
		local tableViewPoint = rewardItemTable:convertToNodeSpace(ccp(x,y))
		print("tableViewPoint:",tableViewPoint.x,tableViewPoint.y)
		if(tableViewPoint.x>=0 and tableViewPoint.x<=tableViewSize.width and tableViewPoint.y>=0 and tableViewPoint.y<=tableViewSize.height) then
			return true
		else
			return false
		end
	end
	local itemBackLayer = CCLayer:create()
	itemBackLayer:setAnchorPoint(ccp(0,0))
	--itemBackLayer:setPosition(0,0)
	itemBackLayer:registerScriptTouchHandler(itemBackLayerTouch,false,-600,true)
	itemBackLayer:setTouchEnabled(true)
	itemback:addChild(itemBackLayer)

	itemBackLayer:addChild(rewardItemTable)

	rewardItemTable:reloadData()


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	-- added by zhz
	menu:setTouchPriority(-553)
	cellBackground:addChild(menu)

	local reciveButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png",
							"images/star/intimate/btn_blue_h.png",
							CCSizeMake(119,70),
							GetLocalizeStringBy("key_2233"),
							ccc3(255,222,0))
    reciveButton:setAnchorPoint(ccp(0.5, 0.5))
    reciveButton:setPosition(cellBackground:getContentSize().width * 0.87, cellBackground:getContentSize().height * 0.4)
	menu:addChild(reciveButton)
	reciveButton:registerScriptTapHandler(function ( ... )
		--领取奖励
		tableCell.receiveRewardCallback(tableCell.rid, cellIndex)
	end)

	local updateTime = function (...)
		rewardInfo.haveTime = tonumber(rewardInfo.haveTime) - 1
		local timeString = TimeUtil.getTimeString(tonumber(rewardInfo.haveTime)) .. GetLocalizeStringBy("key_3170")
		tableCell.haveTime:setString(timeString)
		if(tonumber(rewardInfo.haveTime) > 3600 * 24) then
			tableCell.haveTime:setVisible(false)
		else
			tableCell.haveTime:setVisible(true)
		end
		if(tonumber(rewardInfo.haveTime) < 0) then
			tableCell.haveTime:setString(GetLocalizeStringBy("key_3361"))
		end
	end
	--剩余领奖时间
	require "script/utils/TimeUtil"
	local timeString = TimeUtil.getTimeString(tonumber(rewardInfo.haveTime)) .. GetLocalizeStringBy("key_3170")
	tableCell.haveTime = CCLabelTTF:create(timeString, g_sFontName, 18)
	tableCell.haveTime:setPosition(cellBackground:getContentSize().width * 0.78, cellBackground:getContentSize().height * 0.25)
	tableCell.haveTime:setColor(ccc3(200, 0, 0))
	tableCell.haveTime:setAnchorPoint(ccp(0, 1))
	cellBackground:addChild(tableCell.haveTime)
	tableCell.updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
	if(tonumber(rewardInfo.haveTime) > 3600 * 24) then
		tableCell.haveTime:setVisible(false)
	end
	-- -- print(rewardTime)
	-- tableCell.time = CCRenderLabel:create(rewardTime, g_sFontName, 23, 1, ccc3(0,0,0))
	-- tableCell.time:setColor(ccc3(31, 196, 19))
	-- tableCell.time:setPosition(ccp(256, 205))
	-- cellBackground:addChild(tableCell.time)

	tableCell:registerScriptHandler(function ( eventType,p_node )
		if(eventType == "exit") then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tableCell.updateTimeScheduler)
		end
	end)
	return tableCell
end




--更新tableCell
function RewardTableCell:updateCell( rewardInfo )

	self.time:setString(GetLocalizeStringBy("key_1931") .. tostring(rewardInfo.time)) 	--发奖时间
	self.title:setString(rewardInfo.title) 				--奖励类型标题
	self.content:setString(rewardInfo.content) 			--奖励内容描述

end


