-- Filename: ReResourceCell.lua
-- Author: DJN
-- Date: 2014-12-12
-- Purpose: 资源追回的单元格

require "script/utils/extern"
require "script/utils/LuaUtil"
require "db/DB_Resourceback"
require "script/ui/recover/ReResourceService"
require "script/ui/item/ItemUtil"
require "script/ui/recover/AlertCost"
require "script/utils/TimeUtil"

module("ReResourceCell", package.seeall)

local _ONESILVER = 1003
local _ONEGOLD = 1004
local _rewardId = nil

--创建tableCell
function create( rewardInfo )
	local tableCell = CCTableViewCell:create()

    _rewardId = rewardInfo.type
  
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(568, 227))
	tableCell:addChild(cellBackground)

	local cellTitlePanel = CCSprite:create("images/reward/cell_title_panel.png")
	cellTitlePanel:setAnchorPoint(ccp(0, 1))
	cellTitlePanel:setPosition(ccp(0, cellBackground:getContentSize().height))
	cellBackground:addChild(cellTitlePanel)

	local nameStr = DB_Resourceback.getDataById(_rewardId).name or ""
	local title = CCRenderLabel:create(nameStr,g_sFontName,25,1, ccc3(0,0,0))
	title:setColor(ccc3(31, 196, 19))
	title:setAnchorPoint(ccp(0.5,0.5))
	title:setPosition(ccp(cellTitlePanel:getContentSize().width*0.5,cellTitlePanel:getContentSize().height*0.5))
	cellTitlePanel:addChild(title)

	--内容描述
	local content = DB_Resourceback.getDataById(_rewardId).desc or ""
	content = CCLabelTTF:create(content, g_sFontName, 20)
	content:setAnchorPoint(ccp(0, 1))
	content:setPosition(ccp(26, 165))
	content:setColor(ccc3(0x78, 0x25, 0x00))
	cellBackground:addChild(content)

	--创建奖励物品
	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	itemback:setContentSize(CCSizeMake(400, 125))
	itemback:setPosition(ccp(23, 14))
	cellBackground:addChild(itemback)

	-- 判断是否支持银币追回
	local canUseSilver = (DB_Resourceback.getDataById(_rewardId).silvercost ~= nil) and (DB_Resourceback.getDataById(_rewardId).silverreward ~= nil)
    
    local rewardTable = canUseSilver and ReResourceData.getAllRewardByType(_rewardId,"silver") or ReResourceData.getAllRewardByType(_rewardId,"gold")

	local function rewardItemTableCallback( fn, p_table, a1, a2 )
		--print(fn)
		local r
		local length = table.count(rewardTable)
		if fn == "cellSize" then
			r = CCSizeMake(110, 115)
			-- print("cellSize", a1, r)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = CCTableViewCell:create()
			local itemIconBg = nil
			local itemIcon   = nil

			itemIconBg = ItemUtil.createGoodsIcon(rewardTable[a1+1])
			a2:addChild(itemIconBg)				
			itemIconBg:setAnchorPoint(ccp(0, 0))
			itemIconBg:setPosition(ccp(10, 30))			
			r = a2
			-- print("cellAtIndex", a1, r)
		elseif fn == "numberOfCells" then			
			r = length
		elseif fn == "cellTouched" then
		end
		return r
	end

	local tableViewSize = CCSizeMake(397,118)

	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	itemback:addChild(rewardItemTable)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0, 0))
	rewardItemTable:setPosition(ccp(5, 0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-581)
	rewardItemTable:reloadData()
	

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-581) 
	cellBackground:addChild(menu)

	-- 如果是追回吃烧鸡，就不显示银币追回按钮
	local py = 0.4 -- 金币追回按钮位置
	if (canUseSilver) then
		local silverReciveButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png",
								"images/star/intimate/btn_blue_h.png",
								CCSizeMake(130,64),
								GetLocalizeStringBy("djn_101"),
								ccc3(255,222,0),20)
	    silverReciveButton:setAnchorPoint(ccp(0.5, 0.5))
	    silverReciveButton:setPosition(cellBackground:getContentSize().width * 0.85, cellBackground:getContentSize().height * 0.5)
		menu:addChild(silverReciveButton)
		silverReciveButton:registerScriptTapHandler(retriveSilverCb)
		silverReciveButton:setTag(rewardInfo.type)
		py = 0.2
	end

	--金币领取按钮
	local goldReciveButton = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png","images/common/btn/btn_violet_h.png",CCSizeMake(130,64))
    goldReciveButton:setAnchorPoint(ccp(0.5, 0.5))
    goldReciveButton:setPosition(cellBackground:getContentSize().width*0.85, cellBackground:getContentSize().height*py)
	menu:addChild(goldReciveButton)
	goldReciveButton:registerScriptTapHandler(retriveGoldCb)
	goldReciveButton:setTag(rewardInfo.type)
   

	local goldNum =DB_Resourceback.getDataById(_rewardId).goldcost

    local goldNode = CCNode:create()

    require "script/libs/LuaCCLabel"
    local richInfo = {lineAlignment = 2,elements = {}}
	    richInfo.elements[1] = {
			    ["type"] = "CCSprite", 
			    newLine = false, 
			    --text = GetLocalizeStringBy("key_1307"),
			    image = "images/common/gold.png"}
	    richInfo.elements[2] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = goldNum,
			    font = g_sFontPangWa, 
			    size = 20, 
			    color = ccc3(255,222,0), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_102"),
			    font = g_sFontPangWa, 
			    size = 20, 
			    color = ccc3(255,222,0), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}

    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,0.5))
    midSp:setPosition(ccp(goldReciveButton:getContentSize().width*0.5,goldReciveButton:getContentSize().height*0.5))
    goldReciveButton:addChild(midSp)

    -- 追回吃烧鸡 剩余次数
    if (rewardInfo.num and tonumber(rewardInfo.num) > 0) then
    	local leftTimes = GetLocalizeStringBy("syx_1003",tonumber(rewardInfo.num))
    	local timesLabel = CCLabelTTF:create(leftTimes, g_sFontName, 20)
		timesLabel:setAnchorPoint(ccp(0.5, 0.5))
		timesLabel:setPosition(ccp(cellBackground:getContentSize().width*0.85, cellBackground:getContentSize().height*0.2))
		timesLabel:setColor(ccc3(0x78, 0x25, 0x00))
		cellBackground:addChild(timesLabel)
    end

	local timeNode = CCNode:create()
    
	local intervalTime = tonumber(rewardInfo.endTime)- tonumber(TimeUtil.getSvrTimeByOffset())  
	if(intervalTime <= 0)then
		intervalTime = 0
	end
	intervalTime = TimeUtil.getTimeDesByInterval(intervalTime)
	local timeTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1124"),g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timeTitle:setColor(ccc3(0x00, 0xff, 0x18))
	timeTitle:setAnchorPoint(ccp(0,0.5))
	timeNode:addChild(timeTitle)

    local timeLabel = CCRenderLabel:create(intervalTime,g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    timeLabel:setPosition(timeTitle:getContentSize().width+2,timeTitle:getPositionY())
    timeLabel:setAnchorPoint(ccp(0,0.5))
    
    timeNode:addChild(timeLabel)

    timeNode:setContentSize(CCSizeMake(timeLabel:getContentSize().width+timeTitle:getContentSize().width,timeLabel:getContentSize().height))
    --timeNode:ignoreAnchorPointForPosition(false)

    timeNode:setAnchorPoint(ccp(0.5,1))
    timeNode:setPosition(ccp(cellBackground:getContentSize().width*0.7,cellBackground:getContentSize().height*0.95))
    cellBackground:addChild(timeNode)

    --离开时间倒计时 
	local updateTime = function ( ... )
		--local curTime = TimeUtil.getSvrTimeByOffset()
		local leftTime = tonumber(rewardInfo.endTime)- tonumber(TimeUtil.getSvrTimeByOffset()) 
		if leftTime <= 0 then
			--活动已经 结束
            --消灭cell
            ReResourceData.deleteTypeFromCache(rewardInfo.type)
            ReResourceLayer.refreshUi()
		end

		require "script/utils/TimeUtil"
		local timeStr = TimeUtil.getTimeDesByInterval(leftTime)
		timeLabel:setString(timeStr)
	end
	
	--倒计时动作
	schedule(timeNode, updateTime, 1)

	return tableCell
end

function retriveSilverCb (tag)
	
	AlertCost.showLayer("silver",ReResourceData.getSilverByParam(tag),tag,ReResourceLayer.refreshUi)

end
function retriveGoldCb (tag)
	
	AlertCost.showLayer("gold",ReResourceData.getGoldByParam(tag),tag,ReResourceLayer.refreshUi)
	
end




