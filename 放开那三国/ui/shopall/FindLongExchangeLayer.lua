--Filename: exchangeLayer.lua
--Author: FQQ
--Date: 2015-09-07
--Purpose: 创建寻龙积分兑换界面

module("FindLongExchangeLayer",package.seeall)
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/ui/shopall/FindLongExchangeCell"
require "script/ui/shopall/FindLongExchangeCache"
require "script/ui/forge/FindTreasureData"
require "script/ui/forge/FindTreasureService"
local _layer = nil
local _visibleWidth = nil
local _visibleHeight = nil
local _bulletinHeight = nil
local _bottomMenuHeight = nil
local _offsetY = nil
local _height
local _exchangeInfoLayer = nil
local _FindLongExchangeCellData = nil
local _exchangeTable = nil
local _findDrogonNum = nil
local _findDrogonNumLabel = nil
local jifenSprite    = nil
local _centerLayer   = nil
local maxScale = nil
local  number
local _touchPriority = nil
local _zOrder = nil
function onTouchesHandler(eventType,x,y)
    return true
end
function onNodeEvent(event)
    if event == "enter" then
        _layer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _layer:setTouchEnabled(true)

    elseif eventType == "exit" then

        _layer:unregisterScriptTouchHandler()
    end
end
function init( ... )
    number = nil
    _touchPriority = nil
    _zOrder = nil
    _layer = nil
    _centerLayer = nil
    _bulletinHeight = nil
    _bottomMenuHeight = nil
    _FindLongExchangeCellData = nil
    jifenSprite  = nil
    _exchangeTable = nil
    _height       = nil
end



-- 在原来进入的接口
function show(p_touchPriority, p_zOrder)
   local  layer = create(p_touchPriority, p_zOrder)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(layer, _zOrder)
end


--商店整合入口
function createCenterLayer(p_centerLayerSizse, p_touchPriority, p_zOrder, p_isShow)
   
    _touchPriority = p_touchPriority or -700
    _isShow = p_isShow or false
    _zOrder = p_zOrder or 10
    _centerSize = p_centerLayerSizse
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)

    if  not _isShow then
        local callfunc = function ( ... )
            --获取商店物品
            FindLongExchangeCache.getExchangeInfoFromSever(createUI)
        end
        FindTreasureService.dragonGetMap(callfunc)
    else
        FindLongExchangeCache.getExchangeInfoFromSever(createUI)
    end
    return _centerLayer
end

function create(p_touchPriority, p_zOrder)
     init()
    _priority = p_touchPriority or -700
    _zOrder = p_zOrder or 10
    require "script/ui/shopall/ShoponeLayer"
    _layer = LuaCCSprite.createMaskLayer(ccc4(0, 0, 0, 200), _priority)
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), _priority, _zOrder, true)
    _layer:addChild(centerLayer)
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    centerLayer:setPosition(ccpsprite(0.5, 0.5, _layer))
    return _layer
end


function backBtnCb(tag, itemBtn)
    print("_exchangeInfoLayer:")
    _layer:removeFromParentAndCleanup(true)
    _layer = nil
    _exchangeInfoLayer = nil
end


function createBaseUI( num )
    maxScale = g_fScaleX
    number = num
    if not _isShow then
        -- 设置背景
        local layerBg = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/buttonBg.png")
        layerBg:setContentSize(_centerSize)
        layerBg:setAnchorPoint(ccp(0,0))
        layerBg:setPosition(0,0)
        -- layerBg:setScale((g_fScaleX > g_fScaleY and g_fScaleX or g_fScaleY) / maxScale)
        _centerLayer:addChild(layerBg)

        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
        up:setScale(g_fScaleX)
        up:setPosition(ccp(0, _centerSize.height))
        layerBg:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        layerBg:addChild(down)
    end
    --妹纸
    local boySprite = CCSprite:create("images/shop/shopall/xunlong.png")
    boySprite:setAnchorPoint(ccp(0,0.5))
    boySprite:setPosition(ccp(0,_centerSize.height*0.5))
    boySprite:setScale(g_fScaleX)
    _centerLayer:addChild(boySprite)

    if _isShow then
        --顶部返回按钮
        local backMenu = CCMenu:create()
        backMenu:setTouchPriority(_touchPriority-10)
        backMenu:setAnchorPoint(ccp(0.5,0.5))
        -- backMenu:setScale(g_fScaleX)
        backMenu:setPosition(ccp(g_winSize.width*550/640,g_winSize.height*850/960))
        _layer:addChild(backMenu)

        local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
        backBtn:setScale(g_fElementScaleRatio)
        backMenu:addChild(backBtn)

        backBtn:registerScriptTapHandler(backBtnCb)
    end

    return _layer
end
function createUI( ... )
    createBaseUI()
    -- createExchangeInfoLayer()

    --商店名字 寻龙商店
    local shopName = CCSprite:create("images/common/bg/shopName.png")
    shopName:setAnchorPoint(ccp(0.5,1))
    shopName:setScale(g_fScaleX)
    shopName:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))
    _centerLayer:addChild(shopName)

    --寻龙积分：..”
    local titleStr = CCRenderLabel:create(GetLocalizeStringBy("fqq_004"),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    titleStr:setColor(ccc3(0xff,0xf6,0x00))
    titleStr:setScale(g_fScaleX)
    titleStr:setAnchorPoint(ccp(0,1))
    titleStr:setPosition(ccp(g_winSize.width*0.5,shopName:getPositionY() - shopName:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(titleStr)

    jifenSprite = CCSprite:create("images/forge/xunlongjifen_icon.png")
    jifenSprite:setAnchorPoint(ccp(1,0.5))
    jifenSprite:setPosition(ccp(35+titleStr:getContentSize().width,12))
    titleStr:addChild(jifenSprite)

    _findDrogonNum = FindTreasureData.getTotalPoint()
    local titleNum = CCRenderLabel:create(tostring(_findDrogonNum),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    titleNum:setColor(ccc3(0x00,0xff,0x18))
    titleNum:setAnchorPoint(ccp(0,0.5))
    titleNum:setPosition(ccp(99+jifenSprite:getContentSize().width,15))
    titleStr:addChild(titleNum)
    _findDrogonNumLabel = titleNum

    _height = titleStr:getPositionY() - titleStr:getContentSize().height*g_fScaleX - 30*g_fScaleX
    -- 创建人物滑动列表tabView
    local blackNode = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    blackNode:setContentSize(CCSizeMake(458*g_fScaleX, _height))
    -- blackNode:setScale(g_fElementScaleRatio)
    blackNode:setAnchorPoint(ccp(1,1))
    blackNode:setPosition(ccp(g_winSize.width-10*g_fScaleX,titleStr:getPositionY() - titleStr:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(blackNode)

    local paramTable = {}
    paramTable.bgSize = CCSizeMake(448*g_fScaleX,_height-10)
    _exchangeTable = createTableView(paramTable)
    _exchangeTable:setAnchorPoint(ccp(0,0))
    _exchangeTable:setPosition(8,8)
    _exchangeTable:setTouchPriority(_touchPriority -10)
    blackNode:addChild(_exchangeTable,1,100)
end



function createTableView( p_param)
    local p_param = p_param
    if(p_param == nil)then
        p_param = {}
        p_param.bgSize = CCSizeMake(448*g_fScaleX,_height-10) 
    end
    --创建兑换表
    _FindLongExchangeCellData = FindLongExchangeCache.filterExchangeDataTable()
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local ret = nil
        if fn == "cellSize" then
            ret = CCSizeMake(454*g_fScaleX, 182*g_fScaleX)
        elseif fn == "cellAtIndex" then

            ret = FindLongExchangeCell.create(_FindLongExchangeCellData[a1+1],_touchPriority-20,_centerSize.width)
        elseif fn == "numberOfCells" then
            ret = #_FindLongExchangeCellData
        else
        end
        return ret
    end)
    local tableViewResult = LuaTableView:createWithHandler(h, p_param.bgSize)
    tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return(tableViewResult)
end
--获得兑换表
function getExchangeInfoLayer()
    -- return _centerLayer
        return _exchangeInfoLayer
end

--获得本地寻龙积分
function getFindDrogonNum()
    return _findDrogonNum
end

--设置本地寻龙积分
function setFindDrogonNum(num)
    _findDrogonNum = num
    if not tolua.isnull(_findDrogonNumLabel) then
        _findDrogonNumLabel:setString(tostring(_findDrogonNum))
    end
end

--获取tableView
function getExchangeTable( ... )
    return _exchangeTable
end

--刷新数据，获得剩余次数大于零的数据
function freshFindLongExchangeCellData()
    local temp = {}
    -- 当剩余兑换次数大于0时才在table中显示出来
    for _,v in pairs(_FindLongExchangeCellData) do
        if v.remainExchangeNum > 0 then
            table.insert(temp,v)
        end
    end
    _FindLongExchangeCellData = temp
end

function updataTableView( ... )
    local offset = _exchangeTable:getContentOffset()
    _exchangeTable:reloadData()
    _exchangeTable:setContentOffset(offset)
end










