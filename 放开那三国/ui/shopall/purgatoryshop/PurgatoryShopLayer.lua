-- Filename: PurgatoryShopLayer.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 炼狱商店显示层

module("PurgatoryShopLayer", package.seeall)

require "script/ui/purgatorychallenge/PurgatoryData"
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopData"
require "script/ui/shopall/purgatoryshop/PurgatoryShopCell"
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopService"
require "script/model/user/UserModel"
require "script/ui/purgatorychallenge/PurgatoryServes"
local _touchPrority = nil
local _zOrder       = nil
local _bgLayer      = nil
local wmTitle       = nil
function init()
    _priority = nil
    _zOrder   = nil
    wmTitle   = nil
     _bgLayer      = nil
end

function show(p_touchPriority, p_zOrder)
    AudioUtil.playBgm("audio/bgm/music17.mp3")
    local  bgLayer = create(p_touchPriority, p_zOrder)
    local curScene = MainScene:getOnRunningLayer()
    curScene:addChild(bgLayer, _zOrder)
end

function createCenterLayer(p_centerLayerSizse, p_touchPriority, p_zOrder, p_isShow)
   
    local zeroTime = TimeUtil.getCurDayZeroTime()
    local curServerTime = BTUtil:getSvrTimeInterval()

    _priority = p_touchPriority or -700
    _isShow = p_isShow or false
    _zOrder = p_zOrder or 10
    _centerSize = p_centerLayerSizse
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)

    local function callBackInfo( ... )
        loadBg()
        local actions1 = CCArray:create()
        actions1:addObject(CCDelayTime:create(0.1))
        actions1:addObject(CCCallFunc:create(function ( ... )
            curServerTime = BTUtil:getSvrTimeInterval()
            if(tonumber(curServerTime)==tonumber(zeroTime))then
                PurgatoryShopService.getInfo(function ( ... )
                    updateCell()
                end)
            end
        end))
        local sequence = CCSequence:create(actions1)
        local action = CCRepeatForever:create(sequence)
        _centerLayer:runAction(action)
        -- local function getShopInfo( ... )
        --     PurgatoryShopService.getInfo(loadTableView)
        -- end

        -- PurgatoryServes.getCopyInfo(getShopInfo)
        PurgatoryShopService.getInfo(function ( ... )
            loadTableView()
        end)
    end
    if _isShow then
        callBackInfo()
    else
        PurgatoryServes.getCopyInfo(callBackInfo)
    end


    return _centerLayer
end

function create(p_touchPriority, p_zOrder)
     init()
    _priority = p_touchPriority or -700
    _zOrder = p_zOrder or 10
    local zeroTime = TimeUtil.getCurDayZeroTime()
    local curServerTime = BTUtil:getSvrTimeInterval()
    require "script/ui/shopall/ShoponeLayer"
    _bgLayer = LuaCCSprite.createMaskLayer(ccc4(0, 0, 0, 200), p_touchPriority)
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), p_touchPriority, _zOrder, true)
    _bgLayer:addChild(centerLayer)
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    centerLayer:setPosition(ccpsprite(0.5, 0.5, _bgLayer))

    loadMenu()  --返回按钮
    return _bgLayer
end



function loadBg( ... )

    if not _isShow then
        --背景
        local underLayer = CCScale9Sprite:create("images/purgatory/buttonbg.png")
        underLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer)

        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
        up:setPosition(ccp(0, _centerSize.height))
        up:setScale(g_fScaleX)
        underLayer:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        underLayer:addChild(down)
    end


    -- 一个帅锅
    local boySprite = CCSprite:create("images/shop/shopall/lianyu.png")
    boySprite:setAnchorPoint(ccp(0,0.5))
    boySprite:setPosition(ccp(0,_centerSize.height*0.5))
    boySprite:setScale(g_fElementScaleRatio)
    _centerLayer:addChild(boySprite)

    --活动标题
    local titleSprite = CCSprite:create("images/purgatory/shopname.png")
    titleSprite:setAnchorPoint(ccp(0.5,1))
    _centerLayer:addChild(titleSprite)
    titleSprite:setScale(g_fElementScaleRatio)
    titleSprite:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))


    wmTitle = CCRenderLabel:create(GetLocalizeStringBy("llp_208"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    wmTitle:setColor(ccc3(0xff,0xf6,0x00))
    wmTitle:setScale(g_fElementScaleRatio)
    _centerLayer:addChild(wmTitle)
    wmTitle:setAnchorPoint(ccp(0,1))
    wmTitle:setPosition(ccp(g_winSize.width*0.5,titleSprite:getPositionY() - titleSprite:getContentSize().height*g_fElementScaleRatio))

    local wmIcon = CCSprite:create("images/purgatory/lianyulingsmall.png")
    wmTitle:addChild(wmIcon)
    wmIcon:setAnchorPoint(ccp(1, 0.5))
    wmIcon:setPosition(ccp(35+wmTitle:getContentSize().width,11))


    local pData = PurgatoryData.getCopyInfo()
    _wmLabel = CCRenderLabel:create(pData.hell_point, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    wmTitle:addChild(_wmLabel, 1)
    _wmLabel:setAnchorPoint(ccp(0, 0.5))
    _wmLabel:setPosition(ccp(77+wmIcon:getContentSize().width,15))
    _wmLabel:setColor(ccc3(0x00, 0xff, 0x18))
end

function loadMenu( ... )
    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0.5,0.5))
    -- bgMenu:setScale(g_fScaleX)
    bgMenu:setPosition(ccp(g_winSize.width*570/660,g_winSize.height*870/960))
    bgMenu:setTouchPriority(_priority - 10)
    _bgLayer:addChild(bgMenu)

    --返回按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(g_fElementScaleRatio)
    -- returnButton:setAnchorPoint(ccp(0.5,0.5))
    -- returnButton:setPosition(ccp(g_winSize.width*585/640,0))
    returnButton:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(returnButton)
end

function loadTableView()
    local height = wmTitle:getPositionY() - wmTitle:getContentSize().height*g_fElementScaleRatio - 30*g_fScaleX
    --tableView背景
    local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    viewBgSprite:setContentSize(CCSizeMake(460*g_fScaleX, height))
    viewBgSprite:setAnchorPoint(ccp(1,1))
    -- viewBgSprite:setScale(g_fElementScaleRatio)
    viewBgSprite:setPosition(ccp(g_winSize.width - 10*g_fScaleX,wmTitle:getPositionY() - wmTitle:getContentSize().height*g_fElementScaleRatio))
    _centerLayer:addChild(viewBgSprite)

    _shopInfo = PurgatoryShopData.getItemList()

    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(454*g_fScaleX, 182*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = PurgatoryShopCell.createCell(_shopInfo[a1 + 1], a1 + 1,_priority - 30)
            -- a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_shopInfo)
        else
        end
        return r
    end)

    _tableView = LuaTableView:createWithHandler(h, CCSizeMake(460*g_fScaleX, height - 10))
    viewBgSprite:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setAnchorPoint(ccp(0.5,0.5))
    _tableView:setPosition(ccpsprite(0.5, 0.5, viewBgSprite))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setTouchPriority(_priority - 10)
end

function updateCell( )
    _shopInfo = PurgatoryShopData.getItemList()
    local offset = _tableView:getContentOffset()
    _tableView:reloadData()
    _tableView:setContentOffsetInDuration(offset,0)

end

function updateWmLable( ... )
    local pData = PurgatoryData.getCopyInfo()
    _wmLabel:setString(tostring(pData.hell_point))
end


function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_bgLayer) then
        _bgLayer:removeFromParentAndCleanup(true)
    end
end








