-- Filename: RewardCenterView.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 奖励中心主view


require "script/ui/rewardCenter/AdaptTool"
require "script/libs/LuaCC"
require "script/libs/LuaCCSprite"
require "script/ui/rewardCenter/RewardCenterService"
require "script/ui/rewardCenter/RewardCenterData"
require "script/utils/LuaUtil"
require "script/audio/AudioUtil"

module("RewardCenterView", package.seeall)

local colorLayer = nil
local rewardTable = nil
local rewardList = nil
local rewardCountNum = nil
local pageLayer = nil
local updataTimerFunc = nil
local slideIcons = nil
local slideNode  = nil
----------------------------[[ ui创建 ]]----------------------------------

function init( )
	 colorLayer = nil
	 rewardTable = nil
	 rewardList = nil
	 rewardCountNum = nil
	 pageLayer = nil
	 updataTimerFunc = nil
	 slideIcons = {}
	 slideNode = nil
end

-- layerTouch 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

function create( )

	init()

	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	-- added by zhz
	colorLayer:registerScriptTouchHandler(layerToucCb,false,-551,true)
	colorLayer:setTouchEnabled(true)
	colorLayer:setAnchorPoint(ccp(0, 0))
	
	local g_winSize = CCDirector:sharedDirector():getWinSize()

	local background = CCScale9Sprite:create("images/common/viewbg1.png")
	background:setContentSize(CCSizeMake(630, 796))
	background:setAnchorPoint(ccp(0.5, 0.5))
	background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	colorLayer:addChild(background)
	AdaptTool.setAdaptNode(background)

	--标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
	background:addChild(titlePanel)

	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3087"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)

	--奖励一周内不领取会消失
	local rewardAlert = CCLabelTTF:create(GetLocalizeStringBy("key_2057"), g_sFontName, 21)
	rewardAlert:setPosition(ccp(30, background:getContentSize().height - 81))
	rewardAlert:setColor(ccc3(0x78, 0x25, 0x00))
	rewardAlert:setAnchorPoint(ccp(0, 0))
	background:addChild(rewardAlert)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	-- changed by zhz
	menu:setTouchPriority(-620)  -- -1000
	background:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setPosition(background:getContentSize().width * 0.95, background:getContentSize().height * 0.96)
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	--全部领取按钮
	local allReceive = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_1635"),ccc3(255,222,0))
    allReceive:setAnchorPoint(ccp(0.5, 0.5))
    allReceive:setPosition(background:getContentSize().width*0.5, background:getContentSize().height*0.075)
	menu:addChild(allReceive)
	allReceive:registerScriptTapHandler(allReceiveCallback)

	--拉数据
	RewardCenterService.getRewardList(0, 0, function ( ... )
		createTableView(background)
	end)
	
	return colorLayer
end
-- pageLayer 注册注册layer
function pageLayerCb(eventType, x, y)
	return true
end

function createTableView( layer )

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(575, 595))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(layer:getContentSize().width*0.5, 110))
	layer:addChild(tableBackground)

	rewardList = {}
	rewardTable= {}
	local tempList = RewardCenterData.getRewardList()
	local rowNum = 20
	for i=1,#tempList do
		if(rewardList[math.floor((i-1)/rowNum) + 1]  == nil) then
			rewardList[math.floor((i-1)/rowNum) + 1] = {}
		end
		table.insert(rewardList[math.floor((i-1)/rowNum) + 1], tempList[i])
	end
	pageLayer = BTPageLayer:createWithViewSize(CCSizeMake(567,572),#rewardList)
	pageLayer:setPosition(ccp(0,5))
	-- add by zhz
	-- pageLayer:registerScriptTouchHandler(pageLayerCb,false,-552,true)
	-- pageLayer:setTouchEnabled(true)
	
	tableBackground:addChild(pageLayer)
	pageLayer:setTouchPriority(-555)

	for i=1,#rewardList do
		--奖励列表回调事件
		local  function rewardTableCallback(fn, t_table, a1, a2)
			require "script/ui/rewardCenter/RewardTableCell"
			local r
			if fn == "cellSize" then
				r = CCSizeMake(568, 227)
			elseif fn == "cellAtIndex" then
				a2 = RewardTableCell:create(rewardList[i][a1 + 1], a1, receiveRewardCallback)
				r = a2
			elseif fn == "numberOfCells" then
				r = #rewardList[i]
				print("numberOfCells r = " ,r)
			elseif fn == "cellTouched" then
				
			end
			return r
		end
		rewardTable[i] = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), CCSizeMake(567,583))
		rewardTable[i]:setBounceable(true)
		rewardTable[i]:setAnchorPoint(ccp(0, 0))
		rewardTable[i]:setPosition(ccp(0, 0))
		pageLayer:addChildOfPage(rewardTable[i],i-1)
		rewardTable[i]:setTouchPriority(-660)  -- -6660

		print("crate reward table ", i)
	end
	--当前奖励数
	rewardCountNum = CCLabelTTF:create(GetLocalizeStringBy("key_2672") .. RewardCenterData.getRewardCount(), g_sFontName, 21)
	rewardCountNum:setPosition(ccp(415, layer:getContentSize().height - 81))
	rewardCountNum:setColor(ccc3(0x00, 0x6d, 0x2f))
	rewardCountNum:setAnchorPoint(ccp(0,0))
	layer:addChild(rewardCountNum)

	-- 越南版本
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
		rewardCountNum:setVisible(false)
	end

	updataTimerFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
	creataPageSlideIcon(layer)
end

function creataPageSlideIcon(layer)
	local width = 43 * (pageLayer:getPageCount() -1)
	slideNode  = CCNode:create()
	slideNode:setAnchorPoint(ccp(0.5, 0.5))
	slideNode:setContentSize(CCSizeMake(width, 22))
	slideNode:setPosition(ccp( layer:getContentSize().width * 0.5, 90))
	layer:addChild(slideNode, 500)

	for i=1,pageLayer:getPageCount()do
		slideIcons[i] = CCMenuItemSprite:create(CCSprite:create("images/reward/slide_n.png"),CCSprite:create("images/reward/slide_h.png"))
		slideIcons[i]:setPosition(ccp( (i-1)*43, 11 ))
		slideNode:addChild(slideIcons[i])
		print("create slideIcons")
	end
end


----------------------------[[ 定时器 ]] --------------------------------

function updateTime( ... )
	local pageIndex = pageLayer:getSelectIndex() + 1
	for i,v in ipairs(slideIcons) do
		if(i == pageIndex) then
			v:selected()
		else
			v:unselected()
		end
	end
	local width = 43 * (pageLayer:getPageCount() -1)
	slideNode:setContentSize(CCSizeMake(width, 22))
	for i=1,pageLayer:getPageCount() do
		slideIcons[i]:setPosition(ccp( (i-1)*43, 11 ))
	end
end

function deleteSlideItem( _index )
	slideIcons[_index]:removeFromParentAndCleanup(true)
	table.remove(slideIcons, _index)
end



----------------------------[[ 回调事件 ]]----------------------------------
--领取单行
function receiveRewardCallback( rid, t_cellIndex )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local pageIndex = pageLayer:getSelectIndex() + 1
	local tempIndex = 0
	local tableIndex = 0
	for i=1,table.maxn(rewardList) do
		tableIndex = tableIndex + 1
		if(rewardList[i] ~= nil) then
			tempIndex = tempIndex + 1
		end
		if(tempIndex == pageIndex) then
			break
		end
	end
	local function requestCallback( ... )
		for i,v in ipairs(rewardList[tableIndex]) do
			if(tonumber(rid) == tonumber(v.rid)) then
				table.remove(rewardList[tableIndex], i)
			end
		end
		rewardCountNum:setString(GetLocalizeStringBy("key_2672") .. RewardCenterData.getRewardCount())
		if table.isEmpty(rewardList[tableIndex]) then
			pageLayer:removeLayerOfIndex(pageIndex - 1)
			-- table.remove(rewardList, tableIndex)
			rewardList[tableIndex] = nil
			deleteSlideItem(pageIndex)
			if table.isEmpty(rewardList) then
				closeLayer()
				return
			end
			return
		end
		rewardTable[tableIndex]:removeCellAtIndex(t_cellIndex)
		rewardTable[tableIndex]:reloadData()
	end
	RewardCenterService.receiveReward(rid, requestCallback)	
end

--全部领取
function allReceiveCallback( tag, sender )
	print("allReceiveCallback")
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local pageIndex = pageLayer:getSelectIndex() + 1
	print("pageIndex = ",pageIndex)
	local tempIndex = 0
	local tableIndex = 0
	for i=1,table.maxn(rewardList) do
		tableIndex = tableIndex + 1
		if(rewardList[i] ~= nil) then
			tempIndex = tempIndex + 1
		end
		if(tempIndex == pageIndex) then
			break
		end
	end
	local args = {}
	if not(rewardList and rewardList[tableIndex]) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2341"))
		return
	end

	for k,v in pairs(rewardList[tableIndex]) do
		print_t(v)
		table.insert(args, v.rid)
	end
	local function requestCallback()
		rewardCountNum:setString(GetLocalizeStringBy("key_2672") .. RewardCenterData.getRewardCount())
		pageLayer:removeLayerOfIndex(pageIndex - 1)
		-- table.remove(rewardList, pageIndex)
		rewardList[tableIndex] = nil
		deleteSlideItem(pageIndex)
		-- rewardTable[pageIndex]:reloadData()
		if table.isEmpty(rewardList) then
			closeLayer()
			return
		end
	end
	RewardCenterService.receiveByRidArr(args,requestCallback)
end

--关闭模块
function closeButtonCallback( tag, sender )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local menuItem = tolua.cast(sender, "CCMenuItem")
	closeLayer()
end

function closeLayer()
	colorLayer:removeFromParentAndCleanup(true)
	colorLayer = nil
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(updataTimerFunc)
	if table.isEmpty(rewardList) then
		DataCache.setRewardCenterStatus(false)
	end
	require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateTopButton()
end


