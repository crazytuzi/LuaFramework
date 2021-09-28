-- FileName: GodShopLayer.lua
-- Author:  DJN
-- Date: 14-12-20
-- Purpose: 神兵商店页面

module("GodShopLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/tip/AnimationTip"
require "script/utils/TimeUtil"
require "script/libs/LuaCCLabel"
require "script/ui/shopall/godShop/GodShopService"
require "script/ui/shopall/godShop/GodShopData"
local _bgLayer
local _centerLayer          --中间显示
local _priority
local _zOrder
local _exTableView
-- local _meritNumLabel
local _visibleNum
local _midSp               --闯关令剩余数量label
local _remainBgSprite
-- local _closeCb            --返回按钮后回调
local _refreshBtn         --刷新按钮
local _goldSp             --刷新按钮上面金币数量+icon sprite
local _timeNode           --倒计时node 因为发网络请求的过程中要暂停action 所以定义为全局变量
local _timeLabel          --倒计时的文字
local  number

----------------------------------------初始化函数----------------------------------------
--[[
    @des    :初始化函数
    @param  :
    @return :
--]]
function init()
    _bgLayer = nil
    _priority = nil
    _zOrder = nil
    _cornNumLabel = nil
    _exTableView = nil
    -- _meritNumLabel = nil
    _visibleNum = nil
    _midSp = nil
    _remainBgSprite = nil
    -- _closeCb = nil
    _refreshBtn = nil
    _goldSp = nil
    _timeNode  = nil
    _timeLabel   = nil
    _centerLayer = nil
end

----------------------------------------事件函数----------------------------------------
--[[
    @des    :事件注册函数
    @param  :事件类型
    @return :
--]]
function onTouchesHandler(eventType)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
        _bgLayer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
    end
end

--[[
    @des    :关闭界面回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_bgLayer ~= nil)then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end

    local mainLayer= GodWeaponCopyMainLayer.createLayer()
    MainScene.changeLayer(mainLayer, "godWeaponCopyMainLayer")

end

function refreshCb( ... )--点击刷新时的回调方法

    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local num1 = tonumber(GodShopData.getGoldTime()) + GodShopData.getStonTime() 
    if(num1 >= DB_Overcomeshop.getDataById(1).refresh)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("djn_124"))--文字“今日刷新次数已达上限”
    else
        require "script/ui/shopall/godShop/GodShopAlertRefresh"
        local confirmCb = function ( ... )

            GodShopService.refreshShopInfo(refreshUI,-GodShopData.getRefreshCost(GodShopData.getGoldTime()+1),false) --刷新，false表示不是系统自动刷新
        end

        if(GodShopData.getNumberRef() <= 0)then  --免费次数用完时
            local id,num = GodShopData.getRfreshIdAndNum()
            local allNum = ItemUtil.getCacheItemNumBy(id)
            if(allNum > 0)then
                --刷新令未用完时
                GodShopService.refreshShopInfo(refreshUI,-0,false)
            else
               GodShopAlertRefresh.showLayer(GodShopData.getRefreshCost(GodShopData.getGoldTime()+1),confirmCb,_priority-50,_zOrder +10)--显示要扣除的金币  
            end
           
        else
            --confirmCb()
            GodShopService.refreshShopInfo(refreshUI,-0,false)
        end
    end
end

----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建tableView
    @param  :参数table
    @return :创建好的tableView
--]]
function createTableView(p_param)
    require "script/ui/shopall/godShop/GodShopCell"
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        --local shopInfo = GodShopData.getGoodList()
        local shopInfo,_ = GodShopData.getGoodListForCell()
        if fn == "cellSize" then
            --r = CCSizeMake(605*g_fScaleX, 190*g_fScaleX)
            r = CCSizeMake(454*g_fScaleX, 172*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = GodShopCell.createCell(shopInfo[a1+1],a1+1,p_table,_centerLayer:getContentSize().width)
            --a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            --r = BarnData.getItemNum()
            r = table.count(shopInfo)
        else
        -- print("other function")
        end

        return r
    end)

    local tableViewResult = LuaTableView:createWithHandler(h, p_param.bgSize)
    tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return(tableViewResult)
end

--[[
    @des    :创建UI
    @param  :
    @return :
--]]
function createUI()

    -----刷新闯关令数量
    refreshLabel()

    -- 刷新用的
    local bgMenu1 = CCMenu:create()
    bgMenu1:setAnchorPoint(ccp(0,0))
    bgMenu1:setPosition(ccp(0,0))
    bgMenu1:setTouchPriority(_priority - 40)
    _centerLayer:addChild(bgMenu1)
    local height = _midSp:getPositionY() - _midSp:getContentSize().height*g_fScaleX - 50*g_fScaleX
    --tableView背景
    local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    --viewBgSprite:setContentSize(CCSizeMake(g_winSize.width*0.66,g_winSize.height*0.7))
    -- viewBgSprite:setScale(g_fScaleX)
    viewBgSprite:setContentSize(CCSizeMake(470*g_fScaleX,height-30))
    -- viewBgSprite:setScale(g_fElementScaleRatio)

    viewBgSprite:setAnchorPoint(ccp(1,1))
    viewBgSprite:setPosition(ccp(g_winSize.width-10*g_fScaleX,_midSp:getPositionY() - _midSp:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(viewBgSprite)

    -- --创建tableView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(460*g_fScaleX,height-40)

    _exTableView = createTableView(paramTable)
    _exTableView:setAnchorPoint(ccp(0,0))
    _exTableView:setPosition(ccp(8,8))
    _exTableView:setTouchPriority(_priority - 2)
    viewBgSprite:addChild(_exTableView)

    -- local strLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_139"),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    -- strLable:setColor(ccc3(0xff,0xe4,0x00))
    -- strLable:setAnchorPoint(ccp(0,0.5))
    -- strLable:setPosition(ccp(10*g_fScaleX,40*g_fScaleX))
    -- _centerLayer:addChild(strLable)
    ----刷新按钮
    refreshBtn = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png","images/common/btn/btn_purple2_h.png",CCSizeMake(180,73))
    refreshBtn:setAnchorPoint(ccp(0,1))
    refreshBtn:setScale(g_fElementScaleRatio)
    refreshBtn:setPosition(ccp(g_winSize.width-220*g_fElementScaleRatio,80*g_fScaleX))
    bgMenu1:addChild(refreshBtn)
    refreshBtn:registerScriptTapHandler(refreshCb)
    --refreshBtn:setScale(g_fScaleX)

    -----刷新“金币刷新”按钮上面的字
    refreshGoldCost()

    --刷新免费刷新label
    refreshFreeLabel()


end


function refreshFreeLabel( ... )
    if not tolua.isnull(_numberNode) then
        _numberNode:removeFromParentAndCleanup(true)
    end
    --添加”当日免费刷新次数“
    _numberNode = CCNode:create()
    if(GodShopData.getNumberRef() <= 0)then
        --如果免费次数用完，开始用刷新令
        -- local callback = function ( ... )
             local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_140"),g_sFontPangWa,22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            numberLabel:setAnchorPoint(ccp(0,0.5))
            numberLabel:setColor(ccc3(0xff,0xff,0xff))
            _numberNode:addChild(numberLabel)
            local id,num = GodShopData.getRfreshIdAndNum()
            local allNum = ItemUtil.getCacheItemNumBy(id)
            _number = CCRenderLabel:create(allNum,g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            _number:setColor(ccc3(0x00, 0xff, 0x18))
            _number:setPosition(numberLabel:getContentSize().width+2,numberLabel:getPositionY())
            _number:setAnchorPoint(ccp(0,0.5))
            _numberNode:addChild(_number)
            _numberNode:setContentSize(CCSizeMake(numberLabel:getContentSize().width+_number:getContentSize().width,numberLabel:getContentSize().height))
            _numberNode:ignoreAnchorPointForPosition(false)
            _centerLayer:addChild(_numberNode)
            _numberNode:setAnchorPoint(ccp(0,0.5))
            _numberNode:setPosition(ccp(g_winSize.width*0.26,53*g_fScaleX))
            _numberNode:setScale(g_fScaleX)
            if(allNum == 0)then
                refreshGoldCost()
            end
       
    else
        local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_000"),g_sFontPangWa,22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        numberLabel:setAnchorPoint(ccp(0,0.5))
        numberLabel:setColor(ccc3(0xff,0xff,0xff))
        _numberNode:addChild(numberLabel)

        _number = CCRenderLabel:create(GodShopData.getNumberRef(),g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        _number:setColor(ccc3(0x00, 0xff, 0x18))
        _number:setPosition(numberLabel:getContentSize().width+2,numberLabel:getPositionY())
        _number:setAnchorPoint(ccp(0,0.5))

        _numberNode:addChild(_number)

        _numberNode:setContentSize(CCSizeMake(numberLabel:getContentSize().width+_number:getContentSize().width,numberLabel:getContentSize().height))
        _numberNode:ignoreAnchorPointForPosition(false)
        _centerLayer:addChild(_numberNode)
        _numberNode:setAnchorPoint(ccp(0,0.5))
        _numberNode:setPosition(ccp(g_winSize.width*0.26,53*g_fScaleX))
        _numberNode:setScale(g_fScaleX)
    end
   
end

--[[
    @des    :防走光UI
    @param  :
    @return :
--]]
function createBaseUI(num)
    --背景，若num为nil，则没有这个背景，若不为Nil,则是从整合里面调的
    number = num
    if(number ~= nil)then
        underLayer = CCScale9Sprite:create("images/barn/under_blue.png")
        underLayer:setContentSize(CCSizeMake(_centerLayer:getContentSize().width,_centerLayer:getContentSize().height))
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer)

        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
         up:setScale(g_fScaleX)
        up:setPosition(ccp(0,underLayer:getContentSize().height))
        underLayer:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        underLayer:addChild(down)

    end
    --小镁铝，换成一个帅锅
    local boySprite = CCSprite:create("images/shop/shopall/shenbing.png")
    boySprite:setAnchorPoint(ccp(0,0.5))
    boySprite:setPosition(ccp(0,_centerLayer:getContentSize().height*0.5))
    boySprite:setScale(g_fElementScaleRatio)
    _centerLayer:addChild(boySprite)

    if(number == nil)then  --若为nil,则是在活动里面进入的商店
        --menu层，返回  ,这个是在_bglayer上的
        local bgMenu = CCMenu:create()
        bgMenu:setAnchorPoint(ccp(0,0))
        -- bgMenu:setScale(g_fScaleX)
        bgMenu:setPosition(ccp(0,0))
        bgMenu:setTouchPriority(_priority - 40)
        _bgLayer:addChild(bgMenu)
        --返回按钮
        local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
        returnButton:setScale(g_fElementScaleRatio)
        returnButton:setAnchorPoint(ccp(0.5,0.5))
        returnButton:setPosition(ccp(g_winSize.width*585/640,g_winSize.height*905/960))
        returnButton:registerScriptTapHandler(closeCallBack)
        bgMenu:addChild(returnButton)
    end

    --活动标题，神兵商店
    local titleSprite = CCSprite:create("images/god_weapon/shop/shopName.png")
    titleSprite:setAnchorPoint(ccp(0.5,1))
    titleSprite:setScale(g_fScaleX)
    titleSprite:setPosition(ccp(_centerLayer:getContentSize().width/2,_centerLayer:getContentSize().height))
    _centerLayer:addChild(titleSprite)
end
function getTouchPriority( ... )
    return _priority

end
function getZOrder( ... )
    return _zOrder
end
-----------------------UI刷新模块 --------------------------
function  refreshLabel( ... )
    if(_midSp ~= nil)then
        _midSp:removeFromParentAndCleanup(true)
        _midSp = nil
    end
    local godCoinNum = GodShopData.getGodCoinNum()
    local richInfo = {lineAlignment = 2,elements = {}}
    richInfo.elements[1] = {
        ["type"] = "CCLabelTTF",
        newLine = false,
        text = GetLocalizeStringBy("fqq_005"),  --当前神兵令
        font = g_sFontPangWa,
        size = 24,
        color = ccc3(0xff,0xf6,0x00)}
    richInfo.elements[2] = {
        ["type"] = "CCSprite",
        newLine = false,
        image = "images/god_weapon/shop/token.png"}
    richInfo.elements[3] = {
        ["type"] = "CCLabelTTF",
        newLine = false,
        text = ":",
        font = g_sFontPangWa,
        size = 24,
        color = ccc3(0x00,0xff,0x00)}
    richInfo.elements[4] = {
        ["type"] = "CCLabelTTF",
        newLine = false,
        text = godCoinNum,
        font = g_sFontPangWa,
        size = 24,
        color = ccc3(0x00,0xff,0x18)}
    _midSp = LuaCCLabel.createRichLabel(richInfo)
    _midSp:setScale(g_fScaleX)
    _midSp:setAnchorPoint(ccp(0.5,1))
    _midSp:setPosition(ccp(_centerLayer:getContentSize().width*0.75,_centerLayer:getContentSize().height-58*g_fScaleX))
    _centerLayer:addChild(_midSp)
end
function refreshGoldCost( ... )
    if(_goldSp ~= nil)then
        _goldSp:removeFromParentAndCleanup(true)
        _goldSp = nil
    end
    local goldcostNum = 0
    -- print("GodShopData:")
    -- print(tonumber(GodShopData.getGoldTime()))
    -- print(DB_Overcomeshop.getDataById(1).refresh)
    local num1 = tonumber(GodShopData.getGoldTime()) + GodShopData.getStonTime() 
    if (num1  >= DB_Overcomeshop.getDataById(1).refresh) then
        --已经到达今日刷新上限，就显示最后一次刷新的金币数
        --goldcostNum = GodShopData.getRefreshCost(GodShopData.getGoldTime())--下次刷新倒计时
        print("1")
    else
        goldcostNum = GodShopData.getRefreshCost(GodShopData.getGoldTime()+1)
    end



    local richInfo = {lineAlignment = 2,elements = {}}
    richInfo.elements[1] = {
        ["type"] = "CCRenderLabel",
        newLine = false,
        text = GetLocalizeStringBy("key_1002"),  --刷新按钮上面的“刷新”两个字
        font = g_sFontPangWa,
        size = 30,
        color = ccc3(255,222,0),
        strokeSize = 1,
        strokeColor = ccc3(0x00, 0x00, 0x00),
        renderType = 1}

    --添加一个判断条件,免费刷新次数用完之后，金币图片和金币数量显示出来
    print(GodShopData.getNumberRef())
    if(GodShopData.getNumberRef() <= 0)then
        local id,num = GodShopData.getRfreshIdAndNum()
        local allNum = ItemUtil.getCacheItemNumBy(id)
        if(allNum <= 0)then
            richInfo.elements[2] = {
                ["type"] = "CCSprite",
                newLine = false,
                --text = GetLocalizeStringBy("key_1307"),
                image = "images/common/gold.png"}   --金币图片
                 richInfo.elements[3] = {
                ["type"] = "CCRenderLabel",
                newLine = false,
                text = goldcostNum,   --金币数量
                font = g_sFontPangWa,
                size = 30,
                color = ccc3(255,222,0),
                strokeSize = 1,
                strokeColor = ccc3(0x00, 0x00, 0x00),
                renderType = 1}
        else
             richInfo.elements[2] = {
                ["type"] = "CCSprite",
                newLine = false,
                --text = GetLocalizeStringBy("key_1307"),
                image = "images/common/shuaxinshi.png"}   --刷新石
                 richInfo.elements[3] = {
                ["type"] = "CCRenderLabel",
                newLine = false,
                text = num,   --刷新石数量
                font = g_sFontPangWa,
                size = 30,
                color = ccc3(255,222,0),
                strokeSize = 1,
                strokeColor = ccc3(0x00, 0x00, 0x00),
                renderType = 1}

        end
      
    end
        _goldSp = LuaCCLabel.createRichLabel(richInfo)
        _goldSp:setAnchorPoint(ccp(0.5,0.5))
        _goldSp:setPosition(ccp(refreshBtn:getContentSize().width *0.5,refreshBtn:getContentSize().height *0.5))
        refreshBtn:addChild(_goldSp)
   
end
function refreshUI( ... )
  
    refreshLabel()  --神兵令

    local callback = function ( ... )
        refreshFreeLabel()  --免费刷新次数的显示
    end
 
    local delayAction = function ( ... )
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        performWithDelay(runningScene,callback,0.5)
    end
    if(GodShopData.getNumberRef() <= 0)then
        local id,num = GodShopData.getRfreshIdAndNum()
        local allNum = ItemUtil.getCacheItemNumBy(id)
        if(allNum > 0)then
            delayAction()
        else
            callback()
        end
    else
        callback()
    end
    refreshGoldCost()
    _exTableView:reloadData()
end
function refreshUIByCell() --点击兑换之后的一个刷新
    refreshLabel()
    local offset = _exTableView:getContentOffset()
    _exTableView:reloadData()
    _exTableView:setContentOffset(offset)

end

---------------------------------活动0点刷新--------------------------------------

--0点刷新
function refresh( ... )
    if tolua.isnull(_bgLayer) then
        return
    end
    print("getShopInfo(refreshUI)")
    GodShopService.getShopInfo(refreshUI)
end



----------------------------------------入口函数----------------------------------------
--[[
    @des    :入口函数
    @param  :
    @return :
--]]
function showLayer(p_touchPriority,p_zOrder,num) --Num为nil
    init()
    number = num
    MainScene.setMainSceneViewsVisible(false,false,false)

    _priority = p_touchPriority or -599
    _zOrder = p_zOrder or 10
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,200))

    _bgLayer:registerScriptHandler(onNodeEvent)
    local centerLayer = show(-599,10,nil)
    _bgLayer:addChild(centerLayer)
    local curScene = MainScene:getOnRunningLayer()
    curScene:addChild(_bgLayer,_zOrder)
end

function show( p_touchPriority,p_zOrder,num)
    number = num
    _priority = p_touchPriority or -599
    _zOrder = p_zOrder or 10
    require "script/ui/shopall/ShoponeLayer"
    local _bulletinHeight = ShoponeLayer.getTopGoldContentSize().height*g_fScaleX
    local _bottomMenuHeight = MenuLayer.getLayerFactSize().height
    local scrollviewHeight = ShoponeLayer.getTopBgHeight()
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height-_bulletinHeight-_bottomMenuHeight-scrollviewHeight))
    -- _centerLayer:setScale(g_fScaleX)
    _centerLayer:setPosition(ccp(0,_bottomMenuHeight))
    --创建背景UI
    createBaseUI(number)
    --创建UI
    GodShopService.getShopInfo(createUI)
    return _centerLayer
end

function entry(p_touchPriority,p_zOrder,num )--从整合中调,num不为nil
    init()
    _bgLayer= show( p_touchPriority,p_zOrder,num)
    return _bgLayer
end

function isShopOpen( ... )  -- 判断商店是否开启

end

