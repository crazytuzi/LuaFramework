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
require "script/ui/godweapon/godweaponshop/GodShopCell"
require "script/ui/godweapon/godweaponshop/GodShopService"
require "script/ui/godweapon/godweaponshop/GodShopData"

local _bgLayer
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

    end
end

--[[
    @des    :关闭界面回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil

    local mainLayer= GodWeaponCopyMainLayer.createLayer()
    MainScene.changeLayer(mainLayer, "godWeaponCopyMainLayer")

end

function refreshCb( ... )--点击刷新时的回调方法
   
   AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
   if(tonumber(GodShopData.getGoldTime()) >= DB_Overcomeshop.getDataById(1).refresh)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("djn_124"))--文字“今日刷新次数已达上限”
   else
       require "script/ui/godweapon/godweaponshop/GodShopAlertRefresh"

       local confirmCb = function ( ... )

            GodShopService.refreshShopInfo(refreshUI,-GodShopData.getRefreshCost(GodShopData.getGoldTime()+1),false) --刷新，false表示不是系统自动刷新
       end
   
       if(GodShopData.getNumberRef() <= 0)then  --免费次数用完时

            GodShopAlertRefresh.showLayer(GodShopData.getRefreshCost(GodShopData.getGoldTime()+1),confirmCb,_priority-50,_zOrder +10)--显示要扣除的金币
        else
            --confirmCb()
            GodShopService.refreshShopInfo(refreshUI,-0,false)
        end
   end
end
-- function startTimeAction( ... ) 
--     --离开时间倒计时
--     local updateTime = function ( ... )
--         --local curTime = TimeUtil.getSvrTimeByOffset()
--         local leftTime = tonumber(GodShopData.getRefreshCd())- tonumber(TimeUtil.getSvrTimeByOffset())
--         if leftTime <= 0 then
--             --重新拉数据，刷新UI
--             pauseTimeAction()
--             GodShopService.refreshShopInfo(refreshUI,0,true)--这个留下来
--         end

        -- require "script/utils/TimeUtil"
    --     local timeStr = TimeUtil.getTimeString(leftTime)
    --     _timeLabel:setString(timeStr)
    -- end
    -- --倒计时动作
    -- schedule(_timeNode, updateTime, 1)
-- end
-- function pauseTimeAction( ... )--这个不需要
--     _timeNode:stopAllActions()
-- end
----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建tableView
    @param  :参数table
    @return :创建好的tableView
--]]
function createTableView(p_param)

    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        --local shopInfo = GodShopData.getGoodList()
        local shopInfo,_ = GodShopData.getGoodListForCell()
        if fn == "cellSize" then
            r = CCSizeMake(605*g_fScaleX, 190*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = GodShopCell.createCell(shopInfo[a1+1],a1+1,p_table)
            a2:setScale(g_fScaleX)
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
    --背景
    _remainBgSprite = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
    _remainBgSprite:setContentSize(CCSizeMake(290,55))
    _remainBgSprite:setAnchorPoint(ccp(0.5,1))
    _remainBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*750/960))
    _remainBgSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_remainBgSprite)

    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
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

    --tableView背景
    local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/barn/view_bg.png")
    viewBgSprite:setContentSize(CCSizeMake(g_winSize.width*605/640,g_winSize.height*550/960))
    viewBgSprite:setAnchorPoint(ccp(0.5,1))
    viewBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*675/960))
    _bgLayer:addChild(viewBgSprite)

    -- --创建tableView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(viewBgSprite:getContentSize().width,viewBgSprite:getContentSize().height - 10)

    _exTableView = createTableView(paramTable)
    _exTableView:setAnchorPoint(ccp(0,0))
    _exTableView:setPosition(ccp(0,5))
    _exTableView:setTouchPriority(_priority - 2)
    viewBgSprite:addChild(_exTableView)


    ----刷新按钮
    refreshBtn = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png","images/common/btn/btn_purple2_h.png",CCSizeMake(250,73))
    refreshBtn:setAnchorPoint(ccp(1, 0.5))
    refreshBtn:setPosition(ccp(g_winSize.width,60*g_fScaleX))
    bgMenu:addChild(refreshBtn)
    refreshBtn:registerScriptTapHandler(refreshCb)
    refreshBtn:setScale(g_fScaleX)

    -----刷新“金币刷新”按钮上面的字
    refreshGoldCost()
    -----刷新闯关令数量
    refreshLabel()
    --刷新免费刷新label
   refreshFreeLabel()


end


function refreshFreeLabel( ... )
    if not tolua.isnull(_numberNode) then
        _numberNode:removeFromParentAndCleanup(true)
    end
    --添加”当日免费刷新次数“
  _numberNode = CCNode:create()
  local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_000"),g_sFontPangWa,22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
  numberLabel:setAnchorPoint(ccp(0,0.5))
  numberLabel:setColor(ccc3(0xff,0xff,0xff))
  _numberNode:addChild(numberLabel)

     _number = CCRenderLabel:create(GodShopData.getNumberRef(),g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)  
     _number:setColor(ccc3(0x00, 0xff, 0x18))
     _number:setPosition(numberLabel:getContentSize().width+2,numberLabel:getPositionY())
     _number:setAnchorPoint(ccp(0,0.5))

    _numberNode:addChild(_number)

    _numberNode:setContentSize(CCSizeMake(numberLabel:getContentSize().width+_number:getContentSize().width,numberLabel:getContentSize().height))
     _numberNode:ignoreAnchorPointForPosition(false)
    _bgLayer:addChild(_numberNode)
     _numberNode:setAnchorPoint(ccp(0,0.5))
     _numberNode:setPosition(ccp(10*g_fScaleX,70*g_fScaleX))
    _numberNode:setScale(g_fScaleX)
end

--[[
    @des    :防走光UI
    @param  :
    @return :
--]]
function createBaseUI()
    --背景
    underLayer = CCScale9Sprite:create("images/barn/under_orange.png")
    underLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))
    underLayer:setAnchorPoint(ccp(0,0))
    underLayer:setPosition(ccp(0,0))
    _bgLayer:addChild(underLayer)

    --阳光
    local sunShineSprite = CCSprite:create("images/barn/sun_shine.png")
    sunShineSprite:setAnchorPoint(ccp(0.5,1))
    sunShineSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height))
    sunShineSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(sunShineSprite)

    --小镁铝
    local girlSprite = CCSprite:create("images/god_weapon/shop/girl.png")
    girlSprite:setAnchorPoint(ccp(0,1))
    girlSprite:setPosition(ccp(0,g_winSize.height))
    girlSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(girlSprite)

    --背景图
    local titleBgSprite = CCSprite:create("images/god_weapon/shop/title.png")
    titleBgSprite:setAnchorPoint(ccp(0.5,1))
    titleBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height))
    titleBgSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleBgSprite)

    --活动标题
    local titleSprite = CCSprite:create("images/god_weapon/shop/title_str.png")
    titleSprite:setAnchorPoint(ccp(0.5,0))
    titleSprite:setPosition(ccp(titleBgSprite:getContentSize().width/2,25))
    titleBgSprite:addChild(titleSprite)
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

    local richInfo = {lineAlignment = 2,elements = {}}
        richInfo.elements[1] = {
                ["type"] = "CCLabelTTF",
                newLine = false,
                text = GetLocalizeStringBy("djn_109"),  --当前神兵令
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[2] = {
                ["type"] = "CCSprite",
                newLine = false,
                image = "images/god_weapon/shop/token.png"}
        richInfo.elements[3] = {
                ["type"] = "CCLabelTTF",
                newLine = false,
                text = ":",
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[4] = {
                ["type"] = "CCLabelTTF",
                newLine = false,
                text = GodWeaponCopyData.getCopyInfo().coin,
                font = g_sFontPangWa,
                size = 25,
                color = ccc3(0x00,0xff,0x18)}
    _midSp = LuaCCLabel.createRichLabel(richInfo)
    _midSp:setAnchorPoint(ccp(0.5,0.5))
    _midSp:setPosition(ccp(_remainBgSprite:getContentSize().width/2,_remainBgSprite:getContentSize().height/2))
    _remainBgSprite:addChild(_midSp)
end
function refreshGoldCost( ... )
    if(_goldSp ~= nil)then
        _goldSp:removeFromParentAndCleanup(true)
        _goldSp = nil
    end
    local goldcostNum = 0
    print("GodShopData:")
    print(tonumber(GodShopData.getGoldTime()))
    print(DB_Overcomeshop.getDataById(1).refresh)

    if(tonumber(GodShopData.getGoldTime()) >= DB_Overcomeshop.getDataById(1).refresh)then
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
                end

    _goldSp = LuaCCLabel.createRichLabel(richInfo)
    _goldSp:setAnchorPoint(ccp(0.5,0.5))
    -- _goldSp:setScale(g_fScaleX)
    _goldSp:setPosition(ccp(refreshBtn:getContentSize().width *0.5,refreshBtn:getContentSize().height *0.5))
    refreshBtn:addChild(_goldSp)
end
function refreshUI( ... )
    --startTimeAction()
    refreshGoldCost()
    refreshLabel()  --神兵令
    refreshFreeLabel()  --免费刷新次数的显示
    _exTableView:reloadData()
end
function refreshUIByCell() --点击兑换之后的一个刷新
    refreshLabel()
    local offset = _exTableView:getContentOffset()
    _exTableView:reloadData()
    _exTableView:setContentOffset(offset)
    --_exTableView:updateCellAtIndex(GodShopCell.getSelectedTag()-1)

end

---------------------------------活动0点刷新--------------------------------------

--0点刷新
function refresh( ... )
    if tolua.isnull(_layer) then
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
function showLayer(p_touchPriority,p_zOrder)
    init()

    MainScene.setMainSceneViewsVisible(false,false,false)

    _priority = p_touchPriority or -499
    _zOrder = p_zOrder or 1009

    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    -- _bgLayer:setScale(g_fScaleX)

    MainScene.changeLayer(_bgLayer,"GodShopLayer")

    --创建背景UI
    createBaseUI()
    --创建UI
    GodShopService.getShopInfo(createUI)

end