-- FileName: PrestigeShop.lua 
-- Author: yangrui
-- Date: 15-09-22 
-- Purpose: function description of module 

module("PrestigeShop", package.seeall)

local _bgLayer 			    = nil               -- 兑换layer
local _allGoods				= nil				-- 所有物品数据
local _bigSp                = nil
local _myTableView			= nil				-- 列表
local _tbContentSize        = nil               -- the contentsize of tableview
local _prestigeLabel        = nil

-- 初始化变量
function init()
	_bgLayer 				= nil               -- 兑换layer
	_allGoods				= nil				-- 所有物品数据
	_bigSp                  = nil
	_myTableView			= nil				-- 列表
	_tbContentSize          = nil 				
	_prestigeLabel          = nil
end

--[[
    @des    : 创建tableview
    @param  : 
    @return : 
--]]
function createTableView( ... )
	require "script/ui/shopall/arena/PrestigeShopCell"
	local cellSize = CCSizeMake(435,178--[[340, 165--]])			--计算cell大小
	local h = LuaEventHandler:create( function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = PrestigeShopCell.createCell(_allGoods[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allGoods
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
		end
		return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_tbContentSize.width, _tbContentSize.height-4*g_fScaleY--[[438,470--]]))
	_myTableView:setBounceable(true)
	_myTableView:setPosition(ccp(10, 2))
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	_myTableView:setTouchPriority(-130)
end

-- 初始化声望商店层
function initPrestigeShopLayer( ... )
	-- 声望商店物品数据
	require "script/ui/arena/ArenaData"
	_allGoods = ArenaData.getArenaAllShopInfo()
    -- 黑框
    local blackNode = CCScale9Sprite:create(CCRectMake(50, 50, 6, 4), "images/common/bg/9s_1.png")
    blackNode:setContentSize(_tbContentSize)
    blackNode:setAnchorPoint(ccp(0, 0))
    blackNode:setPosition(ccp(_bigSp:getContentSize().width-_tbContentSize.width-6, 24))
    _bigSp:addChild(blackNode)
    -- create tableview
    createTableView()

    blackNode:addChild(_myTableView)
end

--[[
    @des    : 刷新声望
    @param  : 
    @return : 
--]]
function refreshPrestigeNum( ... )
    -- 当前声望
    local numData = UserModel.getPrestigeNum() or 0
    _prestigeLabel:setString( numData )
end

--[[
    @des    : 刷新tableView
    @param  : 
    @return : 
--]]
function reloadDataFunc( )
	if( _myTableView == nil ) then
		return
	end
	local lastHight = table.count(_allGoods)*210*g_fScaleX
	_allGoods = ArenaData.getArenaAllShopInfo()
	local newHight = table.count(_allGoods)*210*g_fScaleX
	local offset = _myTableView:getContentOffset()
	_myTableView:reloadData()
	if( lastHight > newHight ) then
		if( offset.y ~= 0 ) then
			_myTableView:setContentOffset(ccp(offset.x, offset.y+210*g_fScaleX))
		end
	else
		_myTableView:setContentOffset(offset)
	end
end

--[[
    @des    : 
    @param  : isNewEnter  是否从整合商店入口进去
    @return : 
--]]
function createUI( pSize, isNewEnter )
    -- 背景
    _bigSp = CCScale9Sprite:create(CCRectMake(50, 50, 6, 4), "images/arena/buttonBg.png")
    _bigSp:setAnchorPoint(ccp(0, 0))

    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    if isNewEnter then
        -- 新入口进入
        _bigSp:setContentSize(pSize)
    else
        -- 旧入口进入      +8 因为上方标签按钮背景有阴影部分
        _bigSp:setContentSize(CCSizeMake(pSize.width, pSize.height+8))
    end
    _bigSp:setPosition(ccp(0, 0))
    _bigSp:setScale(g_fScaleX)
    _bgLayer:addChild(_bigSp)
    -- 壮汉
    local man = CCSprite:create("images/shop/shopall/jingji.png")
    man:setAnchorPoint(ccp(0, 0.5))
    man:setPosition(ccp(0, _bigSp:getContentSize().height*0.5))
    _bigSp:addChild(man)
    -- 波浪 上
    local up = CCSprite:create("images/match/shang.png")
    up:setAnchorPoint(ccp(0.5, 1))
    up:setPosition(ccp(_bigSp:getContentSize().width*0.5, _bigSp:getContentSize().height))
    _bigSp:addChild(up)
    -- 波浪 下
    local down = CCSprite:create("images/match/xia.png")
    down:setAnchorPoint(ccp(0.5, 0))
    down:setPosition(ccp(_bigSp:getContentSize().width*0.5, 0))
    _bigSp:addChild(down)
    -- 竞技商店
    local honorTitle = CCSprite:create("images/arena/shoptitle.png")
    honorTitle:setAnchorPoint(ccp(0.5, 1))
    honorTitle:setPosition(ccp(_bigSp:getContentSize().width*0.5, _bigSp:getContentSize().height))
    _bigSp:addChild(honorTitle)
    -- 当前声望值
    local numData = UserModel.getPrestigeNum() or 0
    _prestigeLabel = CCRenderLabel:create(numData, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _prestigeLabel:setAnchorPoint(ccp(1, 1))
    _prestigeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    _prestigeLabel:setPosition(ccp(_bigSp:getContentSize().width-150, honorTitle:getPositionY()-honorTitle:getContentSize().height))
    _bigSp:addChild(_prestigeLabel)
    -- 声望图标
	local prestigeIcon = CCSprite:create("images/common/prestige.png")
	prestigeIcon:setAnchorPoint(ccp(1, 1))
	prestigeIcon:setPosition(ccp(_prestigeLabel:getPositionX()-_prestigeLabel:getContentSize().width, _prestigeLabel:getPositionY()))
	_bigSp:addChild(prestigeIcon)
    -- 声望
    local prestigeFont = CCRenderLabel:create(GetLocalizeStringBy("fqq_003"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    prestigeFont:setAnchorPoint(ccp(1, 1))
    prestigeFont:setColor(ccc3(0xff, 0xf6, 0x00))
    prestigeFont:setPosition(ccp(prestigeIcon:getPositionX()-prestigeIcon:getContentSize().width, prestigeIcon:getPositionY()))
    _bigSp:addChild(prestigeFont)
    -- calc contentsize of tableview
    local tableView_hight = prestigeFont:getPositionY()-prestigeFont:getContentSize().height-24
    _tbContentSize = CCSizeMake(448, tableView_hight)
end

-- 创建声望商店
function createPrestigeShopLayer( pSize, isNewEnter )
	-- 初始化
	init()
    local kMidRectSize = pSize
    if isNewEnter then
        require "script/ui/shopall/ShoponeLayer"
        local kAdaptSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
        kMidRectSize = CCSizeMake(640, kAdaptSize.height-MenuLayer.getLayerContentSize().height-ShoponeLayer.getTopGoldContentSize().height-ShoponeLayer.getTopBgHeight()/g_fScaleX)
    end
	--
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(function ( eventType,node )
        if (eventType == "enter") then
        end
        if (eventType == "exit") then
            init()
        end
    end)
    createUI( kMidRectSize, isNewEnter )
    if isNewEnter then  -- 新入口需要重新拉去数据，旧的入口是在竞技进入时拉去的数据
		require "script/ui/arena/ArenaService"
    	ArenaService.getArenaInfo( function( ... )
			-- 初始化声望商店层
			initPrestigeShopLayer()
    	end )
    else
		-- 初始化声望商店层
		initPrestigeShopLayer()
	end
	return _bgLayer
end
