-- Filename：    WorldGroupLayer.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：    跨服团购主界面


module ("WorldGroupLayer", package.seeall)
require "script/ui/rechargeActive/worldGroupBuy/WorldGroupData"
require "script/ui/tip/AnimationTip"
require "script/libs/LuaCCLabel"
require "script/ui/rechargeActive/worldGroupBuy/WorldGroupControler"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/rechargeActive/RechargeActiveMain"

local _bgLayer               --整个背景layer
local _touchPriority         --触摸优先级
local _zOrder                --z轴
local _curStage              --当前所处阶段
local _lastStage             --刷新数据前所处的阶段 如果没发生阶段的改变 就只刷新UI上的数据 不重新创建UI了 
local _curGood               --当前选中的物品ID
local _curUserInfo           --当前玩家信息缓存
local _buyNode               --购买UI的大背景
local _rewardNode            --领奖UI的大背景
local _buyMidNode            --购买的UI中中间Node 供刷新时调用
local _buyBottomTableView    --购买的UI中底部tableview 供刷新时调用
local _todayList             --今日可购买的商品的ID列表
local _curGoodItem           --当前被选中的的 下方的tableview里面的item
local _isOver                --当前是否过了购买期间  涉及是否拉数据和是否定时刷新 
local _RefreshUIActionTag = 101--每5秒拉一次后端数据的schedule的返回action的tag
local _refreshUIScheduleAction
local _rewardTip             --积分奖励按钮上面的红点
-- local _buyMenu               --购买按钮的menu
-- local _recordMenu            --购买记录按钮的menu
local _listMenu              --下面tableView的menu
function init()
    _bgLayer = nil
    _touchPriority = nil
    _zOrder = nil    
    _curStage = nil
    _curGood = nil
    _lastStage = nil
    _curUserInfo = {}
    _buyNode = nil
    _rewardNode = nil
    _buyMidNode = nil
    _buyBottomTableView = nil
    _todayList = {}
    -- _buyMenu = nil
    -- _recordMenu = nil
    _listMenu = nil
    _curGoodItem = nil
    _isOver = nil
    _refreshUIScheduleAction = nil
    --_refreshUIScheduleAction = nil
    _rewardTip = nil
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
    -- if eventType == "began" then
    --     --print("onTouchesHandler,began")
    --     return true
    -- elseif eventType == "moved" then
    --     --print("onTouchesHandler,moved")
    -- else
    --     --print("onTouchesHandler,else")
    -- end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
    end
end
--------------------------------和controler交互数据----------
function getCurGoodItem( ... )
    return _curGoodItem
end
function setCurGoodItem(p_item )
    _curGoodItem = p_item
end
function setCurGoodId( p_id)
   _curGood = p_id
end
function getTouchPriority( ... )
    return _touchPriority
end
function getZorder( ... )
    return _zOrder
end
----------------------------------------------------------
--创建一个奖励icon（因为策划需要放一个礼包在上面 又不想在表里配很多礼包 所以将图片icon路径放在活动配置中）
function createBagIcon( p_id,p_ifName)
    -- -- 物品icon
    -- local iconBg = CCSprite:create("images/everyday/headBg1.png")
    -- iconBg:setAnchorPoint(ccp(0,0.5))
    -- iconBg:setPosition(ccp(13,_sellItemBg:getContentSize().height*0.56))
    -- _sellItemBg:addChild(iconBg)
    -- 图标底
    local activeData = WorldGroupData.getActiveDataByID(p_id)
    if(table.isEmpty(activeData))then
        return
    end
    -- print("activeData")
    -- print_t(activeData)
    local quality = tonumber(activeData.quality) or 2
    local iconSpriteBg = CCSprite:create("images/base/potential/props_" .. quality .. ".png")
    -- iconSpriteBg1:setAnchorPoint(ccp(0.5,0.5))
    -- iconSpriteBg1:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
    -- iconBg:addChild(iconSpriteBg1)

    -- -- icon按钮
    -- local iconMenu = CCMenu:create()
    -- iconMenu:setAnchorPoint(ccp(0,0))
    -- iconMenu:setPosition(ccp(0,0))
    -- iconSpriteBg1:addChild(iconMenu)
    -- iconMenu:setTouchPriority(-341)

    local iconSp_n = CCSprite:create("images/base/props/" .. activeData.pic)
    iconSp_n:setAnchorPoint(ccp(0.5,0.5))
    iconSp_n:setPosition(ccpsprite(0.5,0.5,iconSpriteBg))
    iconSpriteBg:addChild(iconSp_n)
    -- local iconSp_h = CCSprite:create("images/recharge/tuan/" .. _curMarkData.dbData.icon .. ".png")
    -- local iconItem = CCMenuItemSprite:create(iconSp_n,iconSp_h)
    -- iconItem:setAnchorPoint(ccp(0.5,0.5))
    -- iconItem:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
    -- iconMenu:addChild(iconItem,1,tonumber(_curMarkTag))
    -- iconItem:registerScriptTapHandler(sellIconItemFun)
    -- 物品名字
    if(p_ifName)then
        local nameColor = HeroPublicLua.getCCColorByStarLevel(tonumber(activeData.quality))
        local iconName = CCRenderLabel:create(activeData.good_name,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        iconName:setColor(nameColor)
        iconName:setAnchorPoint(ccp(0.5,1))
        iconName:setPosition(ccpsprite(0.5,-0.01,iconSpriteBg))
        iconSpriteBg:addChild(iconName)
    end
    return iconSpriteBg

end
--创建中间购买的UI
function createMidBuyNode( p_id )
   -- print("createMidBuyNode p_id",p_id)
     local nodeBg = CCScale9Sprite:create("images/common/bg/change_bg.png", CCRectMake(0,0,116,124), CCRectMake(52,44,6,4))
     nodeBg:setContentSize(CCSizeMake(620,270))

     --团购券    
     local couponLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_210").._curUserInfo.coupon,g_sFontName,20,1, ccc3( 0x00, 0x00, 0x00), type_shadow)
     couponLabel:setColor(ccc3(0xff,0xff,0xff))
     couponLabel:setAnchorPoint(ccp(0,0))
     couponLabel:setPosition(ccp(490,310))
     nodeBg:addChild(couponLabel)
     --积分
     local pointLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_211").._curUserInfo.point,g_sFontName,20,1, ccc3( 0x00, 0x00, 0x00), type_shadow)
     pointLabel:setColor(ccc3(0xff,0xff,0xff))
     pointLabel:setAnchorPoint(ccp(0,1))
     pointLabel:setPosition(ccp(490,305))
     nodeBg:addChild(pointLabel)
     local startX = 0.12
     local endX = 0.88

     local totalNum,curNum = WorldGroupData.getNumByID(p_id) --总共可买多少，当前买了多少
     --print("totalNum,curNum",totalNum,curNum)
     local bougtNum = WorldGroupData.getBoughtNumById(p_id) --线上总共买了多少
     local activeData = WorldGroupData.getActiveDataByID(p_id) --这一条活动配置
     -- print("activeData")
     -- print_t(activeData)
     if(table.isEmpty(activeData))then
        return nodeBg
    end
     local disCountArray = activeData["discount"]
     disCountArray = WorldGroupData.analysisDbStr(disCountArray)
     -- print("disCountArray")
     -- print_t(disCountArray)
     local disCountNum = table.count(disCountArray)
     --进度条背景
     local processBg = CCSprite:create("images/recharge/worldGroupBuy/jindu_bg.png")
     processBg:setAnchorPoint(ccp(0.5,1))
     processBg:setPosition(ccp(310,235))
     nodeBg:addChild(processBg)
     local scaleBeganNum = 0 --因为进度条的每一段拉伸倍率不是等比的，要在遍历的时候记录进度条具体从分段中的哪一段开始细化算比例
     for i=1,disCountNum do
        if(i < disCountNum and bougtNum >= tonumber(disCountArray[i][2]) 
            and bougtNum < tonumber(disCountArray[i+1][2]) )then
            scaleBeganNum = i
        end
        local posX = ((endX - startX)/(disCountNum-1) * (i-1)) + startX
        if(i ~= 1)then
            --print("disCountArray[i][2]",disCountArray[i][2])
            local numLabel = CCRenderLabel:create(disCountArray[i][2],g_sFontName,25,1, ccc3( 0x00, 0x00, 0x00), type_shadow)
            numLabel:setColor(ccc3(0xff,0xff,0xff))
            numLabel:setAnchorPoint(ccp(0.5,0))
            numLabel:setPosition(ccpsprite(posX,0.3,processBg))
            processBg:addChild(numLabel,3)
        end
        if(i~=1 and i~= disCountNum)then
            local sanjiaoSp = CCSprite:create("images/recharge/worldGroupBuy/sanjiao.png")
            sanjiaoSp:setAnchorPoint(ccp(0.5,0))
            sanjiaoSp:setPosition(ccpsprite(posX,0.3,processBg))
            processBg:addChild(sanjiaoSp,2)
        end
        local disLabel = CCRenderLabel:create(tonumber(disCountArray[i][1])/1000 .. GetLocalizeStringBy("djn_204"),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        disLabel:setColor(ccc3(0x00,0xe4,0xff))
        disLabel:setAnchorPoint(ccp(0.5,0))
        disLabel:setPosition(ccpsprite(posX,0.95,processBg))
        processBg:addChild(disLabel)
     end

     local processlineScale = 0
     if(scaleBeganNum == 0 )then
        if(bougtNum <= tonumber(disCountArray[1][2]))then
            processlineScale = 0
        elseif(bougtNum >= tonumber(disCountArray[disCountNum][2]))then
            processlineScale =  1
        end
     else
        local begainNum = tonumber(disCountArray[scaleBeganNum][2])

        local deltaNum =  bougtNum - begainNum 
        local tmpScale = deltaNum/(tonumber(disCountArray[scaleBeganNum+1][2]) - begainNum)      
        processlineScale = (scaleBeganNum-1)/(disCountNum-1) + tmpScale/(disCountNum-1)
        processlineScale = processlineScale > 1 and 1 or processlineScale
     end
     
     local  processline = CCSprite:create("images/recharge/worldGroupBuy/jindutiao.png")
     processline:setScaleX(processlineScale*1.1) --这里的1.1完全没有逻辑关系 是素材本身有点不够长
     processline:setAnchorPoint(ccp(0,0))
     processline:setPosition(ccpsprite(0.085,0.3,processBg))
     processBg:addChild(processline)
     --已购买**件
     local boughtrichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        boughtrichInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("key_1502"), 
                font = g_sFontName,
                size = 20,
                color = ccc3(0x00,0xff,0x18)
                }
        boughtrichInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                text = bougtNum, 
                font = g_sFontName,
                size = 20,
                color = ccc3(0xff,0xf6,0x00)
                }
        boughtrichInfo.elements[3] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("djn_206"), 
                font = g_sFontName,
                size = 20,
                color = ccc3(0x00,0xff,0x18)
                }
        
    local boughtLabel = LuaCCLabel.createRichLabel(boughtrichInfo)
    boughtLabel:setAnchorPoint(ccp(0,1))
    boughtLabel:setPosition(ccpsprite(0.1,-0.05,processBg))
    processBg:addChild(boughtLabel)

    --每日购买数量
     local todayrichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        todayrichInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("djn_207"), 
                font = g_sFontName,
                size = 20,
                color = ccc3(0xff,0x9c,0x00)
                }
        todayrichInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                newLine = true,
                text = "("..curNum.."/"..totalNum..")", 
                font = g_sFontName,
                size = 20,
                color = ccc3(0x00,0xff,0x18)
                }
        local todayLabel = LuaCCLabel.createRichLabel(todayrichInfo)
        todayLabel:setAnchorPoint(ccp(1,1))
        todayLabel:setPosition(ccpsprite(0.9,-0.05,processBg))
        processBg:addChild(todayLabel)

    --物品icon
     --local goodStr = ItemUtil.getItemsDataByStr(activeData["item"])
     
    local buyMenu = CCMenu:create()
    buyMenu:setPosition(ccp(0,0))
    buyMenu:setTouchPriority(_touchPriority-1)
    nodeBg:addChild(buyMenu)

    local goodSp = createBagIcon(p_id,true)
    local goodMenuItem = CCMenuItemSprite:create(goodSp,goodSp)
    goodMenuItem:setAnchorPoint(ccp(0,1))
    goodMenuItem:setPosition(ccp(20,145))
    goodMenuItem:registerScriptTapHandler(WorldGroupControler.goodIconAction)
    buyMenu:addChild(goodMenuItem,1,p_id)

    local priceBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    priceBg:setContentSize(CCSizeMake(300,100))
    priceBg:setAnchorPoint(ccp(0,1))
    priceBg:setPosition(ccp(125,150))
    nodeBg:addChild(priceBg)

    local oldSp = CCSprite:create("images/recharge/worldGroupBuy/oldPrice.png")
    oldSp:setAnchorPoint(ccp(0,0))
    oldSp:setPosition(ccpsprite(0.2,0.55,priceBg))
    priceBg:addChild(oldSp,2)

    local newSp = CCSprite:create("images/recharge/worldGroupBuy/nowPrice.png")
    newSp:setAnchorPoint(ccp(0,1))
    newSp:setPosition(ccpsprite(0.2,0.45,priceBg))
    priceBg:addChild(newSp)

    local oldPrice,nowPrice =WorldGroupData.getPriceByID(p_id)
    local oldrichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        oldrichInfo.elements[1] = {
                ["type"] = "CCSprite", 
                image = "images/common/gold.png" 
                }
        oldrichInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                text = oldPrice,
                font = g_sFontPangWa,
                size = 28,
                color = ccc3(0x00,0xe6,0xff)}
        
    local oldLabel = LuaCCLabel.createRichLabel(oldrichInfo)
    oldLabel:setAnchorPoint(ccp(0,0.5))
    oldLabel:setPosition(ccpsprite(0.45,0.7,priceBg))
    priceBg:addChild(oldLabel)

    local newrichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        newrichInfo.elements[1] = {
                ["type"] = "CCSprite", 
                image = "images/common/gold.png" 
                }
        newrichInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                text = nowPrice,
                font = g_sFontPangWa,
                size = 28,
                color = ccc3(0x00,0xe6,0xff)}
        
    local newLabel = LuaCCLabel.createRichLabel(newrichInfo)
    newLabel:setAnchorPoint(ccp(0,0.5))
    newLabel:setPosition(ccpsprite(0.4,0.5,newSp))
    newSp:addChild(newLabel)
    --优先使用**团购券
    local _,coupon = WorldGroupData.getCostByID(p_id)
    local pricerichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        pricerichInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("djn_205"), 
                font = g_sFontName,
                size = 18,
                color = ccc3(0x00,0xff,0x18)
                }
        pricerichInfo.elements[2] = {
                 ["type"] = "CCSprite", 
                image = "images/recharge/worldGroupBuy/coupon.png" 
                }
        pricerichInfo.elements[3] = {
                ["type"] = "CCRenderLabel", 
                text = coupon, 
                font = g_sFontName,
                size = 18,
                color = ccc3(0x00,0xff,0x18)
                }
        
    local priceLabel = LuaCCLabel.createRichLabel(pricerichInfo)
    priceLabel:setAnchorPoint(ccp(0,0))
    priceLabel:setPosition(ccp(130,20))
    nodeBg:addChild(priceLabel)

 
    --购买按钮
    local buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(140, 79),GetLocalizeStringBy("key_3420"),ccc3(0xff, 0xf6, 0x00),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    buyBtn:setAnchorPoint(ccp(0.5,0))
    buyBtn:setPosition(ccp(500,60))
    buyMenu:addChild(buyBtn,1,p_id) 
    buyBtn:registerScriptTapHandler(WorldGroupControler.buyAction)

    --购买记录按钮
    local recordBtn = CCMenuItemImage:create("images/recharge/worldGroupBuy/record_n.png","images/recharge/worldGroupBuy/record_h.png")
    recordBtn:setAnchorPoint(ccp(0.5,1))
    recordBtn:setPosition(ccp(500,60))
    buyMenu:addChild(recordBtn,1,p_id) 
    recordBtn:registerScriptTapHandler(WorldGroupControler.recordAction)
    local lastNum = WorldGroupData.getCanBuyTimeById(p_id)
    if(lastNum <=0)then
        buyBtn:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/showqing.png")
        hasReceiveItem:setAnchorPoint(ccp(0.5,0))
        hasReceiveItem:setPosition(ccp(500,75))
        nodeBg:addChild(hasReceiveItem)
    end

    return nodeBg
end
--创建一个cell
function createlistCell( p_index)
    local cell = CCTableViewCell:create()
    local goodId = _todayList[p_index]
    --print("goodId",goodId)
    local goodInfo = WorldGroupData.getActiveDataByID(goodId)
    --print("goodInfo[tem]",goodInfo["item"])
    local goodStr = ItemUtil.getItemsDataByStr(goodInfo["item"])
    local listMenu = CCMenu:create()
    listMenu:setPosition(ccp(0,0))
    listMenu:setAnchorPoint(ccp(0,0))
    listMenu:setTouchPriority(_touchPriority-2)
    cell:addChild(listMenu)
  
    local goodSp =  createBagIcon(goodId,false)--ItemUtil.createGoodsIcon(goodStr[1],nil, nil, nil, nil ,nil,true)
    local normalSp = goodSp
    local selectSp = goodSp
    local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
    menuItem:setAnchorPoint(ccp(0.5,0.5))
    menuItem:setPosition(ccp(60,48))
    menuItem:registerScriptTapHandler(WorldGroupControler.listItemAction)
    listMenu:addChild(menuItem,1,goodId)

    -- if(goodId == _curGood)then
    --     _curGoodItem = menuItem
    --     _curGoodItem:setEnabled(false)
    -- end

    return cell    
end
--创建底下的tableview
function createGoodTableView( ... )
    --print("_todayList_todayList_todayList",#_todayList)
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = CCSizeMake(120,95)
        elseif (fn == "cellAtIndex") then
            a2 = createlistCell(a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            r = #_todayList
        elseif (fn == "cellTouched") then
        
        elseif (fn == "scroll") then
            
        else
        
        end
        return r
    end)
    local listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(475,95))
    listTableView:setTouchPriority(_touchPriority-3)
    listTableView:setDirection(kCCScrollViewDirectionHorizontal)
    listTableView:reloadData()
    return listTableView
end
--创建整个购买的UI
function createBuyUI( ... )
    if(_buyNode ~= nil)then
        _buyNode:removeFromParentAndCleanup(true)
        _buyNode = nil
    end    
    local bulletHeight = RechargeActiveMain.getTopSize().height
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local height = g_winSize.height/g_fScaleX - (menuLayerSize.height + bulletHeight ) - RechargeActiveMain.getBgWidth()/g_fScaleX 
    _buyNode = CCNode:create()
   -- _buyNode = CCLayerColor:create(ccc4(0,0,0,155))
    _buyNode:setContentSize(CCSizeMake(640,height))
    _buyNode:setAnchorPoint(ccp(0,0))
    _buyNode:setScale(g_fScaleX)
    _buyNode:setPosition(ccp(0,menuLayerSize.height*g_fScaleX))
    _bgLayer:addChild(_buyNode)

    local topBg = CCSprite:create("images/recharge/worldGroupBuy/front_bg.png")
    topBg:setAnchorPoint(ccp(0.5,1))
    topBg:setPosition(ccpsprite(0.5,1.01,_buyNode))
    _buyNode:addChild(topBg)
    local desSp = CCSprite:create("images/recharge/worldGroupBuy/bigTitle.png")
    desSp:setAnchorPoint(ccp(0,1))
    desSp:setPosition(ccpsprite(0.05,0.95,topBg))
    topBg:addChild(desSp)
    --剩余时间
    local leftTimeStr = CCRenderLabel:create(GetLocalizeStringBy("lcy_10030"),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leftTimeStr:setColor(ccc3(0x00, 0xe4, 0xff))
    leftTimeStr:setPosition(130,60)
    leftTimeStr:setAnchorPoint(ccp(1,0.5))
    topBg:addChild(leftTimeStr)

    local buyEndTime = WorldGroupData.getBuyEndTime()

   -- local leftTime = buyEndTime - TimeUtil.getSvrTimeByOffset()
    local buyLeftTimeLabel = CCRenderLabel:create(TimeUtil.getRemainTimeHMS(buyEndTime),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    buyLeftTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    buyLeftTimeLabel:setPosition(135,60)
    buyLeftTimeLabel:setAnchorPoint(ccp(0,0.5))
    topBg:addChild(buyLeftTimeLabel)
    --时间倒计时 
    local updateTime = function ( ... ) 
    -- print("TimeUtil.getSvrTimeByOffset()",TimeUtil.getSvrTimeByOffset())
    -- print("当前时间",TimeUtil.getRemainTimeHMS( TimeUtil.getSvrTimeByOffset()))
        local timeStr = TimeUtil.getRemainTimeHMS(buyEndTime)
        buyLeftTimeLabel:setString(timeStr)
    end   
    --倒计时动作
    schedule(topBg, updateTime, 1)
    --活动结束时间
    local endTimeStr = CCRenderLabel:create(GetLocalizeStringBy("djn_212"),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    endTimeStr:setColor(ccc3(0x00, 0xe4, 0xff))
    endTimeStr:setPosition(130,40)
    endTimeStr:setAnchorPoint(ccp(1,0.5))
    topBg:addChild(endTimeStr)

    local endTimeLabel = CCRenderLabel:create(TimeUtil.getTimeToMin(buyEndTime),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    endTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    endTimeLabel:setPosition(135,40)
    endTimeLabel:setAnchorPoint(ccp(0,0.5))
    topBg:addChild(endTimeLabel)

    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    topBg:addChild(bgMenu)
   
    --说明按钮
    local noteMenuItem = CCMenuItemImage:create("images/recharge/worldGroupBuy/note_n.png","images/recharge/worldGroupBuy/note_h.png")
    noteMenuItem:setAnchorPoint(ccp(1,0.5))
    noteMenuItem:setPosition(ccp(topBg:getContentSize().width*0.8,130))
    noteMenuItem:registerScriptTapHandler(WorldGroupControler.noteMenuCallBack)
    bgMenu:addChild(noteMenuItem)

    --积分奖励按钮
    local rewardMenuItem = CCMenuItemImage:create("images/recharge/worldGroupBuy/pointReward_n.png","images/recharge/worldGroupBuy/pointReward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(0,0.5))
    rewardMenuItem:setPosition(ccp(topBg:getContentSize().width*0.8,130))
    rewardMenuItem:registerScriptTapHandler(WorldGroupControler.rewardMenuCallBack)
    bgMenu:addChild(rewardMenuItem)

    _rewardTip = CCSprite:create("images/common/tip_2.png")
    _rewardTip:setAnchorPoint(ccp(1,1))
    _rewardTip:setPosition(ccpsprite(1,1,rewardMenuItem))
    rewardMenuItem:addChild(_rewardTip)
    if(WorldGroupData.ifPointReward())then
        _rewardTip:setVisible(true)
    else
        _rewardTip:setVisible(false)
    end

    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(55,60,1,1)
    _bottomBg = CCScale9Sprite:create("images/recharge/worldGroupBuy/mid_bg.png",fullRect,insetRect)
    _bottomBg:setPreferredSize(CCSizeMake(640,height-145))
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(ccpsprite(0.5,0,_buyNode))
    _buyNode:addChild(_bottomBg)

    _buyMidNode =  createMidBuyNode(_curGood)
    _buyMidNode:setAnchorPoint(ccp(0.5,1))
    _buyMidNode:setPosition(ccpsprite(0.5,0.99,_bottomBg))
    _bottomBg:addChild(_buyMidNode)

    local tableViewBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")
    tableViewBg:setContentSize(CCSizeMake(600,115))
    tableViewBg:setAnchorPoint(ccp(0.5,0))
    tableViewBg:setPosition(ccpsprite(0.5,0.03,_bottomBg))
    _bottomBg:addChild(tableViewBg)

    local tableTitle =  CCScale9Sprite:create("images/recharge/worldGroupBuy/title_bg.png")
    tableTitle:setContentSize(CCSizeMake(170,35))
    tableTitle:setAnchorPoint(ccp(0.5,0.5))
    tableTitle:setPosition(ccpsprite(0.5,1,tableViewBg))
    tableViewBg:addChild(tableTitle)

    local titleStr = CCLabelTTF:create(GetLocalizeStringBy("djn_216"),g_sFontPangWa, 20)
    titleStr:setColor(ccc3(0xff, 0xf6, 0x00))
    titleStr:setPosition(ccpsprite(0.5,0.5,tableTitle))
    titleStr:setAnchorPoint(ccp(0.5,0.5))
    tableTitle:addChild(titleStr)

     --左右箭头
    local leftArrowSprite = CCSprite:create("images/common/left_big.png")
    leftArrowSprite:setAnchorPoint(ccp(0.02,0.5))
    leftArrowSprite:setPosition(ccpsprite(0,0.5,tableViewBg))
    tableViewBg:addChild(leftArrowSprite)

    local rightArrowSprite = CCSprite:create("images/common/right_big.png")
    rightArrowSprite:setAnchorPoint(ccp(0.98,0.5))
    rightArrowSprite:setPosition(ccpsprite(1,0.5,tableViewBg))
    tableViewBg:addChild(rightArrowSprite)  

    _buyBottomTableView = createGoodTableView()
    _buyBottomTableView:ignoreAnchorPointForPosition(false)
    _buyBottomTableView:setAnchorPoint(ccp(0.5,0.5))
    _buyBottomTableView:setPosition(ccpsprite(0.5,0.45,tableViewBg))
    tableViewBg:addChild(_buyBottomTableView)
    -- body

    --五秒一刷新的时间倒计时 
    local refreshUISchedule = function ( ... ) 
       WorldGroupService.getInfo(1,refreshUI)
    end   
    --倒计时动作
    local refreshUIScheduleAction = schedule(_bgLayer, refreshUISchedule,5)
    refreshUIScheduleAction:setTag(_RefreshUIActionTag)
end
--刷新购买UI
function refreshBuyUI(p_offset)
    if(_buyNode == nil)then
        --防止没有创建出来的问题  
        createBuyUI()
    else
        --刷新中间节点
        local oldPosition = ccp(_buyMidNode:getPositionX(),_buyMidNode:getPositionY())
        local oldAnchor = _buyMidNode:getAnchorPoint()
        local oldParent = _buyMidNode:getParent()
        _buyMidNode:removeFromParentAndCleanup(true)
        _buyMidNode = nil
        _buyMidNode = createMidBuyNode(_curGood)
        --TODO  刷新label
        _buyMidNode:setAnchorPoint(oldAnchor)
        _buyMidNode:setPosition(oldPosition)
        oldParent:addChild(_buyMidNode)
        --刷新底部tableview 
        if(p_offset == true)then
            --针对12点的刷新 
            _buyBottomTableView:reloadData()           
        else
            --针对平时的刷新
            local bottomOffset = _buyBottomTableView:getContentOffset()       
            _buyBottomTableView:reloadData()
            _buyBottomTableView:setContentOffset(bottomOffset)
        end
        --刷新奖励按钮红点
        setRewardTip(WorldGroupData.ifPointReward())
    end

end
--消灭购买期间的UI 因逻辑时序 在创建发奖期UI之前调用
function clearBuyUI( ... )
    if(_buyNode ~= nil)then
        _buyNode:removeFromParentAndCleanup(true)
        _buyNode = nil
    end
    _bgLayer:stopActionByTag(_RefreshUIActionTag)
end
--创建发奖期倒计时UI
function createRewardUI( ... )
    print("createRewardUI=======")
    print(debug.traceback())
    if(_rewardNode ~= nil)then
        print("======== remove createRewardUI=======")
        _rewardNode:removeFromParentAndCleanup(true)
        _rewardNode = nil
    end

    local bulletHeight = RechargeActiveMain.getTopSize().height
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local height = g_winSize.height/g_fScaleX - (menuLayerSize.height + bulletHeight ) - RechargeActiveMain.getBgWidth()/g_fScaleX 
    local rewardSp = CCSprite:create("images/recharge/worldGroupBuy/rewardBg.jpg")--CCNode:create()
    rewardSp:setAnchorPoint(ccp(0.5,0.5))
    
    rewardSp:setPosition(ccpsprite(0.5,0.5,_bgLayer))
    _bgLayer:addChild(rewardSp)
    rewardSp:setScale(g_fScaleX)

    _rewardNode = CCNode:create()
    --_rewardNode_buyNode = CCLayerColor:create(ccc4(0,0,0,155))
    _rewardNode:setContentSize(CCSizeMake(640,height))
    _rewardNode:setAnchorPoint(ccp(0,0))
    _rewardNode:setScale(g_fScaleX)
    _rewardNode:setPosition(ccp(0,menuLayerSize.height*g_fScaleX))
    _bgLayer:addChild(_rewardNode)

    local titleSp = CCSprite:create("images/recharge/worldGroupBuy/title.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccpsprite(0.5,0.95,_rewardNode))
    _rewardNode:addChild(titleSp)

    local girlSp = CCSprite:create("images/recharge/worldGroupBuy/girl.png")
    girlSp:setAnchorPoint(ccp(0,0))
    girlSp:setPosition(ccpsprite(0,0.1,_rewardNode))
    _rewardNode:addChild(girlSp)

    local flower = CCSprite:create("images/recharge/worldGroupBuy/flower.png")
    flower:setAnchorPoint(ccp(1,0))
    flower:setPosition(ccpsprite(1,0.1,_rewardNode))
    _rewardNode:addChild(flower)

    local rewardRichInfo = {lineAlignment = 2,elements = {},alignment = 2}
        rewardRichInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("djn_213"), 
                font = g_sFontPangWa,
                size = 30,
                color = ccc3(0xff,0xf6,0x00)
                }
        rewardRichInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                newLine = true,
                text = GetLocalizeStringBy("djn_214"), 
                font = g_sFontPangWa,
                size = 30,
                color = ccc3(0xff,0xf6,0x00)
                }
        rewardRichInfo.elements[3] = {
                ["type"] = "CCRenderLabel", 
                text = GetLocalizeStringBy("djn_215"), 
                font = g_sFontPangWa,
                size = 30,
                color = ccc3(0x00,0xe4,0xff)
                }
        
    local rewardRichLabel = LuaCCLabel.createRichLabel(rewardRichInfo)
    rewardRichLabel:setAnchorPoint(ccp(1,0))
    rewardRichLabel:setPosition(ccpsprite(0.95,0.6,_rewardNode))
    _rewardNode:addChild(rewardRichLabel)

     --剩余时间
    local leftTimeStr = CCRenderLabel:create(GetLocalizeStringBy("lcy_10030"),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leftTimeStr:setColor(ccc3(0x00, 0xe4, 0xff))
    leftTimeStr:setPosition(ccpsprite(0.8,0.8,_rewardNode))
    leftTimeStr:setAnchorPoint(ccp(1,0.5))
    _rewardNode:addChild(leftTimeStr)

    local endTime = tonumber(ActivityConfigUtil.getDataByKey("worldgroupon").end_time)

   
    local leftTimeLabel = CCRenderLabel:create(TimeUtil.getRemainTimeHMS(endTime),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leftTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    leftTimeLabel:setPosition(ccpsprite(0.81,0.8,_rewardNode))
    leftTimeLabel:setAnchorPoint(ccp(0,0.5))
    _rewardNode:addChild(leftTimeLabel)
    --时间倒计时 
    local updateEndTime = function ( ... ) 
        local timeStr = TimeUtil.getRemainTimeHMS(endTime)
        leftTimeLabel:setString(timeStr)
    end   
    --倒计时动作
    schedule(_rewardNode, updateEndTime, 1)
end
--清除奖励按钮上面的红点
function setRewardTip(p_param)
    _rewardTip:setVisible(p_param)
end
----刷新UI 供外部调用 笼统的刷新
function refreshUI( p_offset)
    --首先获取当前是分组期 买物品期 发奖期
    --TODO 判断_bglyer
    _curUserInfo = WorldGroupData.getUserInfo()

    -- if(table.isEmpty(_curUserInfo))then
    --     return
    -- end
    if(_lastStage == nil)then
        _lastStage = WorldGroupData.getStage()
    end
    _curStage = WorldGroupData.getStage()

    if(_lastStage ~= _curStage)then
        --产生了阶段的跳转
        if(_curStage == "buy")then
            --之前是分组期，现在变成了购买期 按说不会出现这种情况 因为在分组期已经屏蔽掉入口了 防备后端分组过程中产生延时
            createBuyUI()
        elseif(_curStage == "reward")then
            clearBuyUI()
            createRewardUI()
            --停止拉数据刷新UI的schedule         
        end
    else
        --没有阶段的跳转
        if(_curStage == "buy")then          
            refreshBuyUI(p_offset)
        elseif(_curStage == "reward")then
            
            clearBuyUI()
            createRewardUI()
            --停止拉数据刷新UI的schedule
            
        elseif(_curStage == "team")then
            --还在分组期 会出现白板 这是一种异常情况 因为分组期已经屏蔽了UI入口了 如果出现 是后端出错了
            AnimationTip.showTip(GetLocalizeStringBy("djn_203"))
            return 
        end
    end
    _lastStage = _curStage
end
--创建UI的入口
function UIEnter( ... )
    -- 购买阶段是否结束
    local endTime = tonumber(WorldGroupData.getBuyEndTime())
    local curTime = TimeUtil.getSvrTimeByOffset(0)
   
    if(curTime >= endTime)then
        _isOver = true
    else
        _isOver = false

        local endFreshFun = function ( ... )
            -- 购买活动结束 换UI
            refreshUI()
        end
        performWithDelay(_bgLayer, endFreshFun, endTime-TimeUtil.getSvrTimeByOffset(0) )
    end
    refreshUI()
end

function getByLayer( ... )
    return _bgLayer
end
--凌晨12点刷新调用
function refreshAtTwelve( ... )
    _todayList = WorldGroupData.getTodayGoods()
    _curGood = _todayList[1]
    refreshUI(true)
    setRewardTip(WorldGroupData.ifPointReward())
    WorldGroupPointRewardLayer.refreshTableView()
end
-----入口函数
function showLayer(p_touchPriority,p_zOrder)
    init()
    _touchPriority = p_touchPriority or -499
    _zOrder = p_zOrder or 999
    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    print("worldgrouplayer _todayList")
    _todayList = WorldGroupData.getTodayGoods()
    print_t(_todayList)
    if(table.isEmpty(_todayList))then
        AnimationTip.showTip(GetLocalizeStringBy("key_10291"))
    end
    _curGood = _todayList[1]

   WorldGroupService.getInfo(0,UIEnter)
    return _bgLayer

end