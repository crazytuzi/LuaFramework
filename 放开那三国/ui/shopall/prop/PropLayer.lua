-- Filename：	PropLayer.lua
-- Author：		yangrui
-- Date：		2015-09-21
-- Purpose：		商店购买道具

module ("PropLayer", package.seeall)

require "script/ui/shopall/prop/PropCell"
require "script/ui/shop/ShopUtil"

local _bgLayer          = nil
local _bigSp            = nil
local _propTitle        = nil
local _myTableView      = nil
local _tbContentSize    = nil
local _allGoods         = {}

local function init()
	_bgLayer          = nil
	_bigSp            = nil
    _propTitle        = nil
	_myTableView      = nil
	_tbContentSize    = nil
	_allGoods         = {}
end

function createTableView( isNewEnter )

	local cellSize = CCSizeMake(435,178--[[340, 165--]])			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = PropCell.createCell(_allGoods[a1+1], isNewEnter)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allGoods
		elseif fn == "cellTouched" then
			print("cellTouched", a1:getIdx())
		elseif fn == "scroll" then
		end
		return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_tbContentSize.width, _tbContentSize.height-4*g_fScaleY))
	_myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(10, 2))
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _myTableView:setTouchPriority(-130)
end

function reloadDataFunc( )
	local offset = _myTableView:getContentOffset()
	_myTableView:reloadData()
	_myTableView:setContentOffset(offset)
end

--[[
    @des    : 
    @param  : isNewEnter  是否从整合商店入口进去
    @return : 
--]]
function cretaeUI( pSize, isNewEnter )
	-- 背景
    _bigSp = CCScale9Sprite:create(CCRectMake(50, 50, 6, 4), "images/shop/prop_big_bg.png")
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
    -- 人物
    local people = CCSprite:create("images/shop/shopall/daoju.png")
    people:setAnchorPoint(ccp(0, 0.5))
    people:setPosition(ccp(0, _bigSp:getContentSize().height*0.5))
    _bigSp:addChild(people)
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
    -- 道具商店
    _propTitle = CCSprite:create("images/shop/prop_logo.png")
    _propTitle:setAnchorPoint(ccp(0.5, 1))
    _propTitle:setPosition(ccp(_bigSp:getContentSize().width*0.5, _bigSp:getContentSize().height))
    _bigSp:addChild(_propTitle)
    -- calc contentsize of tableview
    local tableView_hight = _propTitle:getPositionY()-_propTitle:getContentSize().height-24
    _tbContentSize = CCSizeMake(448, tableView_hight)
end

--[[
    @des    : 初始化声望商店层
    @param  : isNewEnter  是否从整合商店入口进去
    @return : 
--]]
function createLayer( pSize, isNewEnter )
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
    cretaeUI(kMidRectSize, isNewEnter)
    -- 
	_allGoods = ShopUtil.getAllShopInfo()
	-- 黑框
    local blackNode = CCScale9Sprite:create(CCRectMake(50, 50, 6, 4), "images/common/bg/9s_1.png")
    blackNode:setContentSize(_tbContentSize)
    blackNode:setAnchorPoint(ccp(0, 0))
    blackNode:setPosition(ccp(_bigSp:getContentSize().width-_tbContentSize.width-6, 24))
    _bigSp:addChild(blackNode)
    
	createTableView(isNewEnter)
	blackNode:addChild(_myTableView)

    return _bgLayer
end
