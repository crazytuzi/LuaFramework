-- FileName: HonorShopLayer.lua
-- Author: yangrui
-- Date: 15-09-22
-- Purpose: 荣誉商店整合改版

module("HonorShop", package.seeall)
require "script/ui/match/MatchService"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"

local _bgLayer              = nil               -- 兑换layer
local _allGoods             = nil               -- 所有物品数据
local _myTableView          = nil               -- 列表
local _honorLabel           = nil
local _bigSp                = nil
local _tbContentSize        = nil               -- the contentsize of tableview

-- 初始化变量
function init()
    _bgLayer                = nil               -- 兑换layer
    _allGoods               = nil               -- 所有物品数据
    _myTableView            = nil               -- 列表
    _honorLabel             = nil               -- 荣誉
    _bigSp                  = nil
    _tbContentSize          = nil
end

--[[
    @des    : 创建tableview
    @param  : 
    @return : 
--]]
function createTableView( ... )
    require "script/ui/shopall/honor/HonorShopCell"
    local cellSize = CCSizeMake(435,178--[[340, 165--]])           --计算cell大小
    local h = LuaEventHandler:create( function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            -- if not a2 then
            a2 = HonorShopCell.createCell(_allGoods[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #_allGoods
        else
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

--[[
    @des    : 初始化声望商店层
    @param  : 
    @return : 
--]]
function initHonorShopLayer()
    -- 商店物品数据
    _allGoods = MatchData.getArenaAllShopInfo()
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

-- 刷新荣誉
function refreshHonorNum( ... )
    -- 当前荣誉值
    local numData = MatchData.getHonorNum()
    _honorLabel:setString( numData )
end

-- 刷新tableView
function reloadDataFunc( )
    if ( _myTableView == nil ) then
        return
    end
    local lastHight = table.count(_allGoods)*210*g_fScaleY
    _allGoods = MatchData.getArenaAllShopInfo()
    local newHight = table.count(_allGoods)*210*g_fScaleY
    local offset = _myTableView:getContentOffset()
    _myTableView:reloadData()
    if ( lastHight > newHight ) then
        if ( offset.y ~= 0 ) then
            _myTableView:setContentOffset(ccp(offset.x, offset.y+210*g_fScaleY))
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
    _bigSp = CCScale9Sprite:create(CCRectMake(50, 50, 6, 4), "images/match/buttonBg.png")
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
    local man = CCSprite:create("images/shop/shopall/biwushangdian.png")
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
    -- 比武商店
    local honorTitle = CCSprite:create("images/match/shopname.png")
    honorTitle:setAnchorPoint(ccp(0.5, 1))
    honorTitle:setPosition(ccp(_bigSp:getContentSize().width*0.5, _bigSp:getContentSize().height))
    _bigSp:addChild(honorTitle)
    -- 当前荣誉值
    local numData = MatchData.getHonorNum()
    _honorLabel = CCRenderLabel:create(numData, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    _honorLabel:setAnchorPoint(ccp(1, 1))
    _honorLabel:setColor(ccc3(0x00, 0xff, 0x18))
    _honorLabel:setPosition(ccp(_bigSp:getContentSize().width-150, honorTitle:getPositionY()-honorTitle:getContentSize().height))
    _bigSp:addChild(_honorLabel)
    -- 荣誉图标
    local honorIcon = CCSprite:create("images/common/s_honor.png")
    honorIcon:setAnchorPoint(ccp(1, 1))
    honorIcon:setPosition(ccp(_honorLabel:getPositionX()-_honorLabel:getContentSize().width, _honorLabel:getPositionY()))
    _bigSp:addChild(honorIcon)
    -- 荣誉
    local honorFont = CCRenderLabel:create(GetLocalizeStringBy("fqq_002"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_shadow)
    honorFont:setAnchorPoint(ccp(1, 1))
    honorFont:setColor(ccc3(0xff, 0xf6, 0x00))
    honorFont:setPosition(ccp(honorIcon:getPositionX()-honorIcon:getContentSize().width, honorIcon:getPositionY()))
    _bigSp:addChild(honorFont)
    -- calc contentsize of tableview
    local tableView_hight = honorFont:getPositionY()-honorFont:getContentSize().height-24
    _tbContentSize = CCSizeMake(448, tableView_hight)
end

--[[
    @des    : 创建声望商店
    @param  : isNewEnter  是否从整合商店入口进去
    @return : 
--]]
function createHonorShopLayer( pSize, isNewEnter )
    -- 初始化变量
    init()
    local kMidRectSize = pSize
    if isNewEnter then
        require "script/ui/shopall/ShoponeLayer"
        local kAdaptSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
        kMidRectSize = CCSizeMake(640, kAdaptSize.height-MenuLayer.getLayerContentSize().height-ShoponeLayer.getTopGoldContentSize().height-ShoponeLayer.getTopBgHeight()/g_fScaleX)
    end
    -- 
    _bgLayer = CCLayer:create()
    createUI( kMidRectSize, isNewEnter )
    -- 拉取数据
    MatchService.getShopInfo( function( ... )
        initHonorShopLayer()
    end )
    return _bgLayer
end
