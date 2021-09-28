-- FileName: HonorShop.lua 
-- Author: licong 
-- Date: 14-6-19 
-- Purpose: function description of module 


module("HonorShop", package.seeall)

local _bgLayer 				= nil               -- 兑换layer
local tableView_width		= nil				
local tableView_hight		= nil
local _allGoods				= nil				-- 所有物品数据
local myTableView			= nil				-- 列表
local _honorLabel			= nil
-- 初始化变量
function init()
	_bgLayer 				= nil               -- 兑换layer
	tableView_width			= nil				
	tableView_hight			= nil
	_allGoods				= nil				-- 所有物品数据
	myTableView				= nil				-- 列表
	_honorLabel				= nil 				-- 荣誉
end


-- 初始化声望商店层
function initHonorShopLayer( ... )
	-- 当前荣誉
	local honorFont = CCSprite:create("images/match/cur_honor.png")
	honorFont:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(honorFont)
	honorFont:setScale(MainScene.elementScale)
	-- 荣誉图标
	local honorIcon = CCSprite:create("images/common/s_honor.png")
	honorIcon:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(honorIcon,3)
	honorIcon:setScale(MainScene.elementScale)

	-- 当前荣誉值
	local numData = MatchData.getHonorNum()
	_honorLabel = CCLabelTTF:create( numData , g_sFontPangWa, 36)
	_honorLabel:setAnchorPoint(ccp(0,0.5))
	_honorLabel:setColor(ccc3(0xff,0xe4,0x00))
	_bgLayer:addChild(_honorLabel,3)
	_honorLabel:setScale(MainScene.elementScale)

	local posX = (_bgLayer:getContentSize().width-honorFont:getContentSize().width*MainScene.elementScale -honorIcon:getContentSize().width*MainScene.elementScale-_honorLabel:getContentSize().width*MainScene.elementScale)/2
	honorFont:setPosition(ccp(posX,_bgLayer:getContentSize().height-honorFont:getContentSize().height/2*g_fScaleX-10*g_fScaleX))
	honorIcon:setPosition(ccp(honorFont:getPositionX()+honorFont:getContentSize().width*g_fScaleX+7*g_fScaleX,honorFont:getPositionY()))
	_honorLabel:setPosition(ccp(honorIcon:getPositionX()+honorIcon:getContentSize().width*g_fScaleX+7*g_fScaleX,honorFont:getPositionY()))

	-- 蓝色底
	local lanBg = CCSprite:create("images/common/namebg.png")
	lanBg:setAnchorPoint(ccp(0,0.5))
	lanBg:setPosition(ccp(honorFont:getContentSize().width*0.5,honorFont:getContentSize().height*0.5))
	honorFont:addChild(lanBg,-1)

	-- 上分界线
	local topSeparator = CCSprite:create("images/common/separator_top.png")
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(_bgLayer:getContentSize().width*0.5,honorFont:getPositionY()-honorFont:getContentSize().height/2*g_fScaleX-15*g_fScaleX))
	_bgLayer:addChild(topSeparator,2)
	topSeparator:setScale(g_fScaleX)

	-- 创建人物滑动列表tabView
	tableView_width = _bgLayer:getContentSize().width
	tableView_hight = topSeparator:getPositionY()-15*g_fScaleX

	-- 声望商店物品数据
	_allGoods = MatchData.getArenaAllShopInfo()
	require "script/ui/match/HonorShopCell"
	local cellSize = CCSizeMake(640, 210)			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = HonorShopCell.createCell(_allGoods[a1+1])
			r = a2
			r:setScale(g_fScaleX)
		elseif fn == "numberOfCells" then
			r = #_allGoods
		else
		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(tableView_width,tableView_hight))
	myTableView:setBounceable(true)
	myTableView:setAnchorPoint(ccp(0, 0))
	myTableView:setPosition(ccp(0, 4))
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(myTableView)
	-- 设置滑动列表的优先级
	myTableView:setTouchPriority(-130)

end

-- 刷新荣誉
function refreshHonorNum( ... )
	-- 当前荣誉值
	local numData = MatchData.getHonorNum()
	_honorLabel:setString( numData )
end

-- 刷新tableView
function reloadDataFunc( )
	if(myTableView == nil)then
		return
	end
	local lastHight = table.count(_allGoods) * 210*g_fScaleX
	_allGoods = MatchData.getArenaAllShopInfo()
	local newHight = table.count(_allGoods) * 210*g_fScaleX
	local offset = myTableView:getContentOffset()
	myTableView:reloadData()
	print("offset -- ", offset.y)
	if(lastHight > newHight)then
		if( offset.y ~= 0)then
			myTableView:setContentOffset(ccp(offset.x,offset.y+210*g_fScaleX))
		end
	else
		myTableView:setContentOffset(offset)
	end
end


-- 创建声望商店
function createHonorShopLayer( layerSize )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(layerSize)
	-- 背景
	local bigSp = CCSprite:create("images/main/module_bg.png")
	bigSp:setAnchorPoint(ccp(0.5,0.5))
	bigSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(bigSp)
	bigSp:setScale(g_fBgScaleRatio)

	local function nextCallFun( ... )
		-- 初始化声望商店层
		initHonorShopLayer()
	end
	MatchService.getShopInfo( nextCallFun )
	return _bgLayer
end


































