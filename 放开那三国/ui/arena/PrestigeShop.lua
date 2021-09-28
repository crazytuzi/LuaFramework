-- FileName: PrestigeShop.lua 
-- Author: Li Cong 
-- Date: 13-11-27 
-- Purpose: function description of module 


module("PrestigeShop", package.seeall)

_bgLayer 					= nil               -- 兑换layer
local tableView_width		= nil				
local tableView_hight		= nil
local _allGoods				= nil				-- 所有物品数据
local myTableView			= nil				-- 列表
prestigeSprite				= nil
-- 初始化变量
function init()
	_bgLayer 				= nil               -- 兑换layer
	tableView_width			= nil				
	tableView_hight			= nil
	_allGoods				= nil				-- 所有物品数据
	myTableView				= nil				-- 列表
	prestigeSprite			= nil 				-- 声望
end


-- 初始化声望商店层
function initPrestigeShopLayer( ... )

	-- 当前声望
	prestigeSprite = CCSprite:create("images/common/cur_prestige.png")
	prestigeSprite:setAnchorPoint(ccp(0.5,1))
	prestigeSprite:setPosition(ccp(ArenaLayer.layerSize.width*0.5, ArenaLayer.menuBg:getPositionY()-ArenaLayer.menuBg:getContentSize().height*MainScene.elementScale-10*MainScene.elementScale))
	_bgLayer:addChild(prestigeSprite)
	prestigeSprite:setScale(g_fScaleX)
	-- 当前声望值
	local numData = UserModel.getPrestigeNum() or 0
	local m_prestigeLabel = CCRenderLabel:create( numData , g_sFontPangWa, 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	m_prestigeLabel:setAnchorPoint(ccp(0,0.5))
	m_prestigeLabel:setColor(ccc3(0xff,0xe4,0x00))
	m_prestigeLabel:setPosition(ccp(210, prestigeSprite:getContentSize().height*0.5+2))
	prestigeSprite:addChild(m_prestigeLabel,1,11111)
	-- 声望图标
	local prestigeIcon = CCSprite:create("images/common/prestige.png")
	prestigeIcon:setAnchorPoint(ccp(0,0.5))
	prestigeIcon:setPosition(ccp(170,prestigeSprite:getContentSize().height*0.5))
	prestigeSprite:addChild(prestigeIcon)

	-- 上分界线
	local topSeparator = CCSprite:create("images/common/separator_top.png")
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(ArenaLayer.layerSize.width*0.5,prestigeSprite:getPositionY()-prestigeSprite:getContentSize().height*MainScene.elementScale-15*MainScene.elementScale))
	_bgLayer:addChild(topSeparator,2)
	topSeparator:setScale(g_fScaleX)

	-- 创建人物滑动列表tabView
	tableView_width = ArenaLayer.layerSize.width
	tableView_hight = topSeparator:getPositionY()-15

	-- 声望商店物品数据
	_allGoods = ArenaData.getArenaAllShopInfo()
	require "script/ui/arena/PrestigeShopCell"
	local cellSize = CCSizeMake(640, 210)			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = PrestigeShopCell.createCell(_allGoods[a1+1])
			r = a2
			r:setScale(g_fScaleX)
		elseif fn == "numberOfCells" then
			r = #_allGoods
		elseif fn == "cellTouched" then
			print("cellTouched", a1:getIdx())

		elseif (fn == "scroll") then
			
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

--[[
    @des    : 刷新声望     modify by yangrui on 15-09-23
    @param  : 
    @return : 
--]]
function refreshPrestigeNum( ... )
	if(PrestigeShop._bgLayer ~= nil)then
		if(PrestigeShop.prestigeSprite ~= nil)then
			if(PrestigeShop.prestigeSprite:getChildByTag(11111) ~= nil)then
				PrestigeShop.prestigeSprite:getChildByTag(11111):removeFromParentAndCleanup(true)
				-- 当前声望值
			local numData = UserModel.getPrestigeNum() or 0
			local m_prestigeLabel = CCRenderLabel:create( numData , g_sFontPangWa, 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			m_prestigeLabel:setAnchorPoint(ccp(0,0.5))
			m_prestigeLabel:setColor(ccc3(0xff,0xe4,0x00))
			m_prestigeLabel:setPosition(ccp(210, PrestigeShop.prestigeSprite:getContentSize().height*0.5+2))
			PrestigeShop.prestigeSprite:addChild(m_prestigeLabel,1,11111)
			end
		end
	end
end

-- 刷新tableView
function reloadDataFunc( )
	if(myTableView == nil)then
		return
	end
	local lastHight = table.count(_allGoods) * 210*g_fScaleX
	_allGoods = ArenaData.getArenaAllShopInfo()
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
function createPrestigeShopLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            
        end
        if(eventType == "exit") then
            init()
        end
    end)
	-- 初始化声望商店层
	initPrestigeShopLayer()
	return _bgLayer
end


































