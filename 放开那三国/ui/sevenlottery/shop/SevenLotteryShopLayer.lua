-- FileName: SevenLotteryShopLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-4
-- Purpose: 七星台商店Layer

module("SevenLotteryShopLayer",package.seeall)
require "script/ui/sevenlottery/shop/SevenLotteryShopController"
require "script/ui/sevenlottery/shop/SevenLotteryShopData"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/ui/sevenlottery/shop/SevenLotteryShopCell"
local _layer              = nil               -- 兑换layer
local _allGoods             = nil               -- 所有物品数据
local _myTableView          = nil               -- 列表
local _wmLabel           = nil
local _bigSp                = nil
local _tbContentSize        = nil               -- the contentsize of tableview

-- 初始化变量
function init()
    _layer                = nil               -- 兑换layer
    _allGoods               = nil               -- 所有物品数据
    _myTableView            = nil               -- 列表
    _wmLabel             = nil               -- 荣誉
    _bigSp                  = nil
    _tbContentSize          = nil
end


--事件注册
function onTouchesHandler( eventType )
    if(eventType == "began")then
        return true
    elseif(eventType == "moved")then
        print("moved")
    elseif(eventType == "end")then
        print("end")
    end
end

function onNodeEvent( event )
    if(event == "enter")then
        _layer:registerScriptTouchHandler(onTouchesHandler,false, _priority,true)
        _layer:setTouchEnabled(true)
    elseif(event == "exit")then
        _layer:unregisterScriptTouchHandler()
    end
end


--[[
    @des    : 创建tableview
    @param  : 
    @return : 
--]]
function createTableView( ... )
    local height = wmTitle:getPositionY() - wmTitle:getContentSize().height*g_fElementScaleRatio - 30*g_fScaleX
     --tableview的背景
    local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    viewBgSprite:setContentSize(CCSizeMake(460*g_fScaleX, height ))
    viewBgSprite:setAnchorPoint(ccp(1,1))
    viewBgSprite:setPosition(ccp(g_winSize.width - 10*g_fScaleX,height + 30*g_fScaleX))
    _centerLayer:addChild(viewBgSprite)
     _shopInfo = SevenLotteryShopData.getSevenLotteryAllShopInfo()
     print_t(_shopInfo)
    local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(454*g_fScaleX,182*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = SevenLotteryShopCell.createCell(_shopInfo[a1 + 1], a1 + 1,_priority - 30)
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_shopInfo)
                   
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h,CCSizeMake(460*g_fScaleX, height - 10))
    viewBgSprite:addChild(_myTableView)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableView:setAnchorPoint(ccp(0.5,0.5))
    _myTableView:setPosition(ccpsprite(0.5, 0.5, viewBgSprite))
    _myTableView:ignoreAnchorPointForPosition(false)
    _myTableView:setTouchPriority(_priority - 2)
end

-- 刷新荣誉
function refreshScoreNum( ... )
    -- 当前荣誉值
    local numData = SevenLotteryShopData.getScoreOfSevenLottery()
    _wmLabel:setString( numData )
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

--活动里面的入口
function show(p_touchPriority, p_zOrder)
    local layer = create(p_touchPriority, p_zOrder)
    local curScene = MainScene:getOnRunningLayer()
    curScene:addChild(layer, _zOrder)
end

--商店整合的入口
function createCenterLayer(p_centerLayerSizse, p_touchPriority, p_zOrder, p_isShow)
    _isShow = p_isShow or false
    if(_isShow == false)then
        init()
    end
    _priority = p_touchPriority or -600
    _zOrder = p_zOrder or 22
    _centerSize = p_centerLayerSizse
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    
    SevenLotteryShopController.getShopInfo(function ( ... )
        loadBg()
        createTableView()
     end)
    return _centerLayer
end

function create(p_touchPriority, p_zOrder)
    init()
    _priority = p_touchPriority or -600
    _zOrder = p_zOrder or 22
    require "script/ui/shopall/ShoponeLayer"
    _layer = LuaCCSprite.createMaskLayer(ccc4(0, 0, 0, 200), _priority)
    _layer:registerScriptHandler(onNodeEvent)
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), _priority, _zOrder, true)
    _layer:addChild(centerLayer)
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    centerLayer:setPosition(ccpsprite(0.5, 0.5, _layer))
    loadMenu() -- 返回按钮
    return _layer
end

--创建商店界面ui
function loadBg( ... )
    if not _isShow then

        --商店背景颜色

        local underLayer = CCScale9Sprite:create("images/sevenlottery/button.png")
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
    --商店的人物图片
    local girlSprite = CCSprite:create("images/sevenlottery/boysprite.png")
    girlSprite:setAnchorPoint(ccp(0,0.5))
    girlSprite:setPosition(ccp(0,_centerSize.height*0.55))
    girlSprite:setScale(g_fScaleX)
    _centerLayer:addChild(girlSprite)


    --商店名称
    local titleSprite = CCSprite:create("images/sevenlottery/shoptitle.png")
    titleSprite:setAnchorPoint(ccp(0.5,1))
    titleSprite:setScale(g_fElementScaleRatio)
    titleSprite:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))
    _centerLayer:addChild(titleSprite)

    --商店积分
    wmTitle = CCRenderLabel:create(GetLocalizeStringBy("fqq_130"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    wmTitle:setColor(ccc3(0xff,0xf6,0x00))
    wmTitle:setScale(g_fElementScaleRatio)
    _centerLayer:addChild(wmTitle)
    wmTitle:setAnchorPoint(ccp(0,1))
    wmTitle:setPosition(ccp(g_winSize.width*0.5,titleSprite:getPositionY() - titleSprite:getContentSize().height*g_fElementScaleRatio))

    --商店图标
    local wmIcon = CCSprite:create("images/common/star_point_small.png")
    -- wmIcon:setScale(0.4)
    wmTitle:addChild(wmIcon)
    wmIcon:setAnchorPoint(ccp(0,0))
    wmIcon:setPosition(ccp(wmTitle:getContentSize().width,0))

    _wmLabel = CCRenderLabel:create(SevenLotteryShopData.getScoreOfSevenLottery(), g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    wmTitle:addChild(_wmLabel, 1)
    _wmLabel:setAnchorPoint(ccp(0, 0.5))
    _wmLabel:setPosition(ccp(10+wmTitle:getContentSize().width+wmIcon:getContentSize().width,15))
    _wmLabel:setColor(ccc3(0x00, 0xff, 0x18))
end

function loadMenu( ... )
    --返回按钮
    local menubar = CCMenu:create()
    menubar:setAnchorPoint(ccp(0.5,0.5))
    menubar:setPosition(ccp(g_winSize.width*570/670,g_winSize.height*870/955))
    menubar:setTouchPriority(_priority-10)
    _layer:addChild(menubar)
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(g_fElementScaleRatio)
    returnButton:registerScriptTapHandler(closeBackCall)
    menubar:addChild(returnButton)

end


function closeBackCall( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_layer) then
        _layer:removeFromParentAndCleanup(true)
    end
end