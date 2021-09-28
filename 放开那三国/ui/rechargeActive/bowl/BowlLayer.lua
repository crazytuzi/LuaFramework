-- Filename：	BowlLayer.lua
-- Author：		DJN
-- Date：		2015-1-5
-- Purpose：    聚宝盆主界面


module ("BowlLayer", package.seeall)

require "script/ui/rechargeActive/bowl/BowlService"
require "script/ui/rechargeActive/bowl/BowlData"
require "script/model/user/UserModel"
require "script/model/utils/ActivityConfigUtil"
require "script/audio/AudioUtil"
require "script/libs/LuaCCLabel"
require "script/ui/tip/AnimationTip"
require "script/ui/rechargeActive/bowl/BowlCell"

local _bgLayer               --整个背景layer
local _touchPriority         --触摸优先级
local _zOrder                --z轴
local _topBg                 --顶部UI背景
local _midBg                 --中部UI背景
local _bottomBg              --底部UI背景
local _selectedTag           -- 当前选中宝盆的的tag
local _tagCorper = 1       -- 铜宝盆     与后端及策划约定的 在表id及后端返回数据中 1.铜 2.银 3.金
local _tagSilver = 2       -- 银宝盆
local _tagGold   = 3       -- 金宝盆
local _bowlMenu            --宝盆menu
local _point                 --页签箭头
local _bowlInfo = {}        -- 后端获取的三个宝盆信息
local _buyTag  = nil        -- 购买的盆的tag
local _lastMenuItem        -- 上一次被点击的宝盆
local _strTable = {GetLocalizeStringBy("djn_127"),GetLocalizeStringBy("djn_128"),GetLocalizeStringBy("djn_129")}  --三个宝盆名字
local _colorTable = {ccc3(0x00,0xff,0x18),ccc3(0x00,0xe4,0xff),ccc3(249, 0, 254)}                                 --三个宝盆颜色




function init()
	_bgLayer = nil
	_touchPriority = nil
	_zOrder = nil
	_topBg = nil
	_midBg = nil
	_bottomBg = nil
    _selectedTag = nil
    _bowlMenu = nil
    _bowlInfo = {}
    _buyTag = nil
    _lastMenuItem = nil
	
end
----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    -- if (eventType == "began") then

    --     return true
    -- elseif (eventType == "moved") then
    --     print("moved")
    -- else
    --     print("end")
    -- end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end
--奖励预览回调
function showPreview( ... )
    require "script/ui/rechargeActive/bowl/BowlRewardPreviewLayer"
    BowlRewardPreviewLayer.showLayer(_strTable[_selectedTag],_selectedTag,_touchPriority-80,_ZOrder)
end
function bowlAction(tag,p_menuItem)
   print("点击的箱子",tag)
   _lastMenuItem:setEnabled(true)
   p_menuItem:setEnabled(false)
   _lastMenuItem = p_menuItem
   --_bowlMenu:getChildByTag(getSelectedTag()):setEnabled(true)
   setSelectedTag(tag)
   --_bowlMenu:getChildByTag(getSelectedTag()):setEnabled(false)
   --refreshPointPosition()
   _point:setPositionX((_bowlMenu:getChildByTag(getSelectedTag())):getPositionX())
   
   refreshMidUI()

end
--点击购买宝盆回调
function buyBowlCb( ... )
    if(UserModel.getGoldNumber() >= tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].BowlCost) )then
        --金币够，发请求
        _buyTag = _selectedTag 
        local richInfo = {lineAlignment = 2,elements = {},labelDefaultSize = 21}
        richInfo.elements[1] = { 
                text = GetLocalizeStringBy("djn_132"),
                color = ccc3(0x78, 0x25, 0x00)}
        richInfo.elements[2] = {
                ["type"] = "CCSprite",
                image = "images/common/gold.png"}
        richInfo.elements[3] = {
                ["type"] = "CCRenderLabel", 
                text = ActivityConfigUtil.getDataByKey("treasureBowl").data[_buyTag].BowlCost,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[4] = {
                text = GetLocalizeStringBy("key_3267"),
                color = ccc3(0x78, 0x25, 0x00)}
        richInfo.elements[5] = {
                text = _strTable[_buyTag],
                color = ccc3(0x78, 0x25, 0x00)}
        richInfo.elements[6] = {
                text = GetLocalizeStringBy("djn_133"),
                color = ccc3(0x78, 0x25, 0x00)}
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(richInfo, confirmCostCb, true)        
    else
        --提示当前金币不足
        AnimationTip.showTip(GetLocalizeStringBy("key_1255"))
    end
end
--确认花费金币聚宝后的回调
function confirmCostCb( p_confirm)
    if(p_confirm)then
        BowlService.buyBowl(_buyTag,buyedCb)
    end
end
--充值按钮回调
function chargeAction( ... )
    require "script/ui/shop/RechargeLayer"
    local chargeLayer = RechargeLayer.createLayer(_touchPriority-100)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(chargeLayer,_zOrder+1)

end
--完成购买宝箱后的回调
function buyedCb()
    --改宝盆缓存状态
    BowlData.changeBowlStatus(_buyTag)
    --扣金币
    BowlData.chargeByTag(_buyTag)
    --刷新UI
    --改宝盆奖励列表状态
    BowlData.changeBowlRewardList(_buyTag)
    --BowlService.getBowlInfo(refreshMidUI)
    refreshMidUI()
end
-- 设置selectedTag
function setSelectedTag(p_tag)
   _selectedTag = tonumber(p_tag)
end
-- 获取selectedTag
function getSelectedTag( ... )
    return _selectedTag
end
--返回当前页面touchpriority
function getTouchPriority( ... )
    return _touchPriority
end
--返回当前页面zorder
function getZOrder( ... )
    return _zOrder
end
function createTopUI( ... )

    require "script/ui/main/BulletinLayer"
    require "script/ui/main/MainScene"
    require "script/ui/main/MenuLayer"
    require "script/ui/rechargeActive/RechargeActiveMain"
    
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()-15*g_fScaleX
    
    --这个模块的适配方法为顶端的背景图永远保证在中间空白区域的0.72高度，顶端可能因为超出而显示不出来，所以title要加到_bgLayer上才能保证每个设备title都显示在顶端
    _topBg = CCSprite:create("images/recharge/bowl/topBg.png")
    _topBg:setAnchorPoint(ccp(0.5,0))
    _topBg:setPosition(ccp(g_winSize.width*0.5,
        (g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()-15*g_fScaleX)*0.72+ menuLayerSize.height*g_fScaleX)  )
    _bgLayer:addChild(_topBg,2)
    _topBg:setScale(g_fScaleX)
    
    local title = CCSprite:create("images/recharge/bowl/title.png")
    title:setAnchorPoint(ccp(0.5,1))
    title:setScale(g_fScaleX)
    title:setPosition(ccp(g_winSize.width*0.5,g_winSize.height - bulletinLayerSize.height*g_fScaleX - RechargeActiveMain.getBgWidth()))
    _bgLayer:addChild(title,3)

    local decStr = CCRenderLabel:create(GetLocalizeStringBy("djn_138"),g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    decStr:setColor(ccc3(0xff, 0xf6, 0x00))
    decStr:setAnchorPoint(ccp(0.5,0))
    decStr:setPosition(ccp(g_winSize.width*0.5,
                      (title:getPositionY() - title:getContentSize().height - _topBg:getPositionY() - 80)*0.5 + _topBg:getPositionY()+80) )
    decStr:setScale(g_fScaleX)
    _bgLayer:addChild(decStr,3)

    
    _bowlMenu = CCMenu:create()
    _bowlMenu:setPosition(ccp(0, 0))
    _bowlMenu:setAnchorPoint(ccp(0, 0))
    _bowlMenu:setTouchPriority(_touchPriority -10)
    _topBg:addChild(_bowlMenu)

    local line = CCScale9Sprite:create("images/recharge/bowl/line.png")
    line:setPreferredSize(CCSizeMake(g_winSize.width,23))
    line:setAnchorPoint(ccp(0.5,1))
    line:setPosition(ccp(g_winSize.width*0.5,10))
    _topBg:addChild(line)

    local corperBowl = CCMenuItemImage:create("images/recharge/bowl/copper_bowl_n.png","images/recharge/bowl/copper_bowl_h.png","images/recharge/bowl/copper_bowl_h.png")
    _bowlMenu:addChild(corperBowl)
    corperBowl:setAnchorPoint(ccp(0.5,0))
    corperBowl:setPositionY(5/g_fScaleX)
    corperBowl:registerScriptTapHandler(bowlAction)
    corperBowl:setTag(_tagCorper)
    corperBowl:setVisible(false)

    local silverBowl = CCMenuItemImage:create("images/recharge/bowl/silver_bowl_n.png","images/recharge/bowl/silver_bowl_h.png","images/recharge/bowl/silver_bowl_h.png")
    silverBowl:setScale(0.95)
    _bowlMenu:addChild(silverBowl)
    silverBowl:setAnchorPoint(ccp(0.5,0))
    silverBowl:setPositionY(5/g_fScaleX)
    silverBowl:registerScriptTapHandler(bowlAction)
    silverBowl:setTag(_tagSilver)
    silverBowl:setVisible(false)

    local goldBowl = CCMenuItemImage:create("images/recharge/bowl/gold_bowl_n.png","images/recharge/bowl/gold_bowl_h.png","images/recharge/bowl/gold_bowl_h.png")
    _bowlMenu:addChild(goldBowl)
    goldBowl:setAnchorPoint(ccp(0.5,0))
    goldBowl:setPositionY(1/g_fScaleX)
    goldBowl:registerScriptTapHandler(bowlAction)
    goldBowl:setTag(_tagGold)
    goldBowl:setVisible(false)

    --到了纯领奖期后，可能有1--3个箱子，所以设置不同的位置横坐标table
    local positionXTable = {{0.5},{0.35,0.65},{0.25,0.5,0.75}}
    local bowlList,_ = BowlData.getTodayBowl()

    local bowlTable = {}
    for i = 1 ,table.count(bowlList) do
        bowlTable[i] = tolua.cast(_bowlMenu:getChildByTag(bowlList[i]),"CCMenuItem")
        bowlTable[i]:setPositionX(640 * positionXTable[table.count(bowlList)][i])
        bowlTable[i]:setVisible(true)
    end
    print("bowlTable")
    print_t(bowlTable)
    setSelectedTag(bowlList[1])
    --_bowlMenu:getChildByTag(getSelectedTag()):setEnabled(false)
    _lastMenuItem = bowlTable[1]
    if(_lastMenuItem ~= nil)then
        _lastMenuItem:setEnabled(false)
    end
    --refreshPointPosition()
    --箭头
    --_point = CCSprite:create("images/common/arrow_down_h.png")
    _point = CCSprite:create("images/recharge/bowl/point.png")
    _point:setAnchorPoint(ccp(0.5,1))
    _point:setPosition(ccp(50,0))
    _topBg:addChild(_point,2)
    _point:setPositionX((_bowlMenu:getChildByTag(getSelectedTag())):getPositionX())
end

--刷新中部UI ，也作为创建方法
function refreshMidUI( ... )
    if(_midBg ~= nil)then
        _midBg:removeFromParentAndCleanup(true)
        _midBg = nil
    end
    _midBg = CCScale9Sprite:create("images/recharge/bowl/redBg.png")
    _midBg:setPreferredSize(CCSizeMake(g_winSize.width,_topBg:getPositionY() - _bottomBg:getPositionY()))
    -- print("高度")
    -- print(_midBg:getContentSize().height)
    _midBg:setAnchorPoint(ccp(0.5,1))
    _midBg:setPosition(ccp(g_winSize.width*0.5,_topBg:getPositionY()-10))
    _bgLayer:addChild(_midBg)

    local tag = tostring(getSelectedTag())
    local bowlState = tonumber( (BowlData.getBowlInfo().type)[tag].state) 
    if(bowlState == 1 or bowlState == 2 or (bowlState == 3 and  BowlData.haveRewardTodayByBowl(tag) == false) )then
        print("展示聚宝界面")
        --展示聚宝界面
        createBowlUI(_midBg,bowlState)
    elseif(bowlState == 3 and  BowlData.haveRewardTodayByBowl(tag) == true )then
        
        print("展示奖励列表")
        --展示奖励列表
        --createBowlUI(_midBg,bowlState)
        createTableViewUI(_midBg)       
    end

end
--创建中间宝盆UI ，贴在p_layer上
--p_state:1.充值未达到 2.可购买 3.已购买
function createBowlUI(p_layer,p_state)
    local fullRect = CCRectMake(0,0,132,123)
    local insetRect = CCRectMake(50,43,16,6)
    local secondBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    p_layer:addChild(secondBg)
    secondBg:setPreferredSize(CCSizeMake(640*0.95,p_layer:getContentSize().height*0.95/g_fScaleX))
    secondBg:setAnchorPoint(ccp(0.5,0.5))
    secondBg:setPosition(ccp(p_layer:getContentSize().width *0.5,p_layer:getContentSize().height*0.5))
    secondBg:setScale(g_fScaleX)

    local imgTable = {"copper_bigBowl_n.png","silver_bigBowl_n.png","gold_bigBowl_n.png"}
    local chargeColor = nil
    if(tonumber(BowlData.getBowlInfo().charge) >= tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].BowlRecharge))then
        --充值够了的时候是绿色
        chargeColor = ccc3(0x00,0xff,0x18)
    else
        --充值不够的时候是红色
        chargeColor = ccc3(0xe8,0x00,0x00)
    end
    local richInfo = {lineAlignment = 2,elements = {},alignment = 2}
        richInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                newLine = false, 
                text = GetLocalizeStringBy("djn_130"),
                font = g_sFontPangWa,
                size = 21,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                newLine = true, 
                text = GetLocalizeStringBy("key_1170")
                       ..ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].BowlRecharge..GetLocalizeStringBy("key_1491"),
                font = g_sFontPangWa,
                size = 21,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[3] = {
                ["type"] = "CCRenderLabel", 
                newLine = false, 
                text = "("..BowlData.getBowlInfo().charge.."/"
                       ..ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].BowlRecharge..")",
                font = g_sFontPangWa,
                size = 21,
                color = chargeColor}
        richInfo.elements[4] = {
                ["type"] = "CCRenderLabel", 
                newLine = true, 
                text = GetLocalizeStringBy("djn_131"),
                font = g_sFontPangWa,
                size = 21,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[5] = {
                ["type"] = "CCRenderLabel", 
                newLine = false, 
                text = _strTable[_selectedTag],
                font = g_sFontPangWa,
                size = 21,
                color = _colorTable[_selectedTag]}
        -- richInfo.elements[6] = {
        --         ["type"] = "CCRenderLabel", 
        --         newLine = true, 
        --         text = GetLocalizeStringBy("djn_138"),
        --         font = g_sFontPangWa,
        --         size = 21,
        --         color = ccc3(0xff,0xf6,0x00)}
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0,0))
    midSp:setPosition(ccp(10,secondBg:getContentSize().height *0.1))
    secondBg:addChild(midSp,3)

    local girl = CCSprite:create("images/recharge/bowl/bowl_girl.png")
    girl:setAnchorPoint(ccp(0,0.5))
    girl:setPosition(ccp(-32,secondBg:getContentSize().height *0.5))
    secondBg:addChild(girl,2)
    
   
    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority - 10)
    secondBg:addChild(bgMenu,2)

    --奖励预览
    local rewardMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
    rewardMenuItem:setAnchorPoint(ccp(1,1))
    rewardMenuItem:setPosition(ccp(secondBg:getContentSize().width,secondBg:getContentSize().height))
    bgMenu:addChild(rewardMenuItem,2)
    rewardMenuItem:registerScriptTapHandler(showPreview)


    local state = tonumber(p_state)
    print("state",state)
    local btnSprite = nil
    --根据不同的状态创建不同的btn
    if(state == 1)then
        --置灰的购买按钮
        btnSprite = BTGraySprite:create("images/recharge/bowl/buy_btn_n.png")
        secondBg:addChild(btnSprite)
    elseif(state == 2)then
        --购买按钮
        btnSprite = CCMenuItemImage:create("images/recharge/bowl/buy_btn_n.png","images/recharge/bowl/buy_btn_h.png")
        bgMenu:addChild(btnSprite)
        btnSprite:registerScriptTapHandler(buyBowlCb)
    elseif(state == 3)then
        --已经购买
        btnSprite = CCSprite:create("images/recharge/bowl/buyed.png")
        secondBg:addChild(btnSprite)
    end
    btnSprite:setAnchorPoint(ccp(0.5,1))
    btnSprite:setPosition(ccp(secondBg:getContentSize().width *0.7,secondBg:getContentSize().height *0.38))

    local bowlSprite = CCSprite:create("images/recharge/bowl/"..imgTable[_selectedTag])
    bowlSprite:setAnchorPoint(ccp(0.5,0))
    bowlSprite:setPosition(ccp(secondBg:getContentSize().width *0.7,btnSprite:getPositionY() + 10 ))
    secondBg:addChild(bowlSprite)
    
    local fullRect = CCRectMake(0,0,189,174)
    local insetRect = CCRectMake(50,43,16,6)
    local flowerBg = CCScale9Sprite:create("images/recharge/bowl/flower_box.png")
    --flowerBg:setPreferredSize(CCSizeMake(bowlSprite:getContentSize().width,bowlSprite:getContentSize().height + btnSprite:getContentSize().height+ 20))
    flowerBg:setPreferredSize(CCSizeMake(230,260))
    btnSprite:addChild(flowerBg)
    flowerBg:setAnchorPoint(ccp(0.5,0))
    flowerBg:setPosition(btnSprite:getContentSize().width *0.5,-10)

    --花费的金币
    
    local goldInfo = {lineAlignment = 2,elements = {}}
        goldInfo.elements[1] = {
                ["type"] = "CCSprite", 
                image = "images/common/gold.png"}
        goldInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                text = ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].BowlCost,
                font = g_sFontName,
                size = 23,
                color = ccc3(0xff,0xf6,0x00)}
    local goldSp = LuaCCLabel.createRichLabel(goldInfo)
    goldSp:setAnchorPoint(ccp(0.5,1))
    goldSp:setPosition(ccp(btnSprite:getPositionX(),btnSprite:getPositionY() - btnSprite:getContentSize().height))
    secondBg:addChild(goldSp) 


end
--创建中间领奖UI ，贴在p_layer上
function createTableViewUI(p_layer)
    local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(50,43,16,6)
    local secondBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    p_layer:addChild(secondBg)
    secondBg:setPreferredSize(CCSizeMake(640*0.95,p_layer:getContentSize().height*0.95/g_fScaleX))
    secondBg:setAnchorPoint(ccp(0.5,0.5))
    secondBg:setPosition(ccp(p_layer:getContentSize().width *0.5,p_layer:getContentSize().height*0.5))
    secondBg:setScale(g_fScaleX)

    -- local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    -- tableBackground:setContentSize(CCSizeMake(575, 595))
    -- tableBackground:setAnchorPoint(ccp(0.5, 0))
    -- tableBackground:setPosition(ccp(layer:getContentSize().width*0.5, 110))
    -- layer:addChild(tableBackground)

    local  function rewardTableCallback(fn, t_table, a1, a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(568, 215)
        elseif fn == "cellAtIndex" then
            a2 = BowlCell.create( ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag]["BowlReward"..(a1+1)],a1+1,true)
            r = a2
        elseif fn == "numberOfCells" then
            r = tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[_selectedTag].rewardtime)

            --print("numberOfCells r = " ,r)
        elseif fn == "cellTouched" then
                
        end
        return r
    end
    rewardTablView = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), CCSizeMake(568,
                                                                           secondBg:getContentSize().height-15))
    rewardTablView:setBounceable(true)
    rewardTablView:ignoreAnchorPointForPosition(false)
    rewardTablView:setAnchorPoint(ccp(0.5, 0))
    rewardTablView:setVerticalFillOrder(kCCTableViewFillTopDown)
    rewardTablView:setPosition(ccp(secondBg:getContentSize().width *0.5, 10))
    secondBg:addChild(rewardTablView)
    rewardTablView:setTouchPriority(_touchPriority - 20)

end

--创建底部UI
function createBottomUI( ... )
	local menuLayerSize = MenuLayer.getLayerContentSize()
	_bottomBg = CCSprite:create("images/recharge/rechargeRaffle/bottom_bg.png")
	_bottomBg:setAnchorPoint(ccp(0.5,1))
	_bottomBg:setPosition(ccp(g_winSize.width*0.5,menuLayerSize.height*g_fScaleX + 90*g_fScaleX ))
    _bottomBg:setScale(g_fScaleX)
    _bgLayer:addChild(_bottomBg,2)

    local bowlTag = 1
    local rewardTag = 2
    local titleStrTable = {GetLocalizeStringBy("djn_135"),GetLocalizeStringBy("djn_136")}
    --倒计时模块
    local timeNode = CCNode:create()
    local bowlEndTime = TimeUtil.getCurDayZeroTime(tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").start_time))
                        + tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[1].bowltime)*86400 - 1
    --local rewardEndTime = tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").end_time)
    local rewardEndTime = TimeUtil.getCurDayZeroTime(tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").start_time))
                        + tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[1].endTime)*86400 - 1
    local timeForUse = nil
    local timeTag = nil
    local titleSp = nil --介绍是聚宝时间还是领奖时间的标题及时间段 那句话
    local timeAction = nil --保存倒计时动作 用于停止schedule

    if(BowlData.isInBowling())then
        --在聚宝阶段
        timeForUse = bowlEndTime 
        timeTag = bowlTag
    else
        --在领奖阶段
        timeForUse = rewardEndTime
        timeTag = rewardTag       
    end

    local refreshTitle = function ( ... )
        if(titleSp ~= nil)then
            titleSp:removeFromParentAndCleanup(true)
            titleSp = nil
        end
        local titleStr = nil
        if(timeTag == bowlTag)then
            titleStr = titleStrTable[1]
        elseif(timeTag == rewardTag)then
            titleStr = titleStrTable[2]
        end
        local timeInfo = {lineAlignment = 2,elements = {}}
        timeInfo.elements[1] = {
                ["type"] = "CCRenderLabel", 
                text = titleStr,
                font = g_sFontName,
                size = 20,
                color = ccc3(0x00,0xe4,0xff)}
        timeInfo.elements[2] = {
                ["type"] = "CCRenderLabel", 
                text = TimeUtil.getTimeForDayTwo(tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").start_time)).."--"..
                       TimeUtil.getTimeForDayTwo(timeForUse),
                font = g_sFontName,
                size = 20,
                color = ccc3(0x00, 0xff, 0x18)}
        titleSp = LuaCCLabel.createRichLabel(timeInfo)
        titleSp:setAnchorPoint(ccp(0,0))
        titleSp:setPosition(ccp(10,_bottomBg:getContentSize().height-40))
        _bottomBg:addChild(titleSp) 

    end
    --执行一次，当做第一次创建
    refreshTitle()
    --timeTag 用来标识当前在进行的时聚宝时间的倒计时还是领奖时间的倒计时，当用户在聚宝界面停留 到聚宝时间和领奖时间的 分界线的时候，用到这个标识
    local intervalTime = timeForUse - TimeUtil.getSvrTimeByOffset()
    if(intervalTime <= 0)then
        intervalTime = GetLocalizeStringBy("djn_145")
    else
        intervalTime = TimeUtil.getTimeDesByInterval(intervalTime)
    end

    local timeTitle = CCRenderLabel:create(GetLocalizeStringBy("djn_82"),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeTitle:setColor(ccc3(0x00, 0xe4, 0xff))
    timeTitle:setAnchorPoint(ccp(0,0.5))
    timeNode:addChild(timeTitle)

    local timeLabel = CCRenderLabel:create(intervalTime,g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    timeLabel:setPosition(timeTitle:getContentSize().width+2,timeTitle:getPositionY())
    timeLabel:setAnchorPoint(ccp(0,0.5))
    
    timeNode:addChild(timeLabel)

    timeNode:setContentSize(CCSizeMake(timeLabel:getContentSize().width+timeTitle:getContentSize().width,timeTitle:getContentSize().height))
    --timeNode:ignoreAnchorPointForPosition(false)

    timeNode:setAnchorPoint(ccp(0,1))
    timeNode:setPosition(ccp(10,_bottomBg:getContentSize().height - 40))
    _bottomBg:addChild(timeNode)

    --离开时间倒计时 
    local updateTime = function ( ... )
        --local curTime = TimeUtil.getSvrTimeByOffset()
        local leftTime = timeForUse - TimeUtil.getSvrTimeByOffset()
        leftTime = leftTime < 0 and 0 or leftTime
        if leftTime <= 0 then
            if(timeTag == bowlTag)then
                --如果之前是在对聚宝时间进行倒计时的话，现在要对领奖时间进行倒计时
                timeForUse = rewardEndTime
                timeTag = rewardTag
                --刷新上面显示的倒计时标题
                refreshTitle()
            elseif(timeTag == rewardTag)then
                timeLabel:setString(GetLocalizeStringBy("djn_145"))
                timeNode:stopAction(timeAction)
            end
        else
            local timeStr = TimeUtil.getTimeDesByInterval(leftTime)
            timeLabel:setString(timeStr)
        end
    end
    
    --倒计时动作
    timeAction = schedule(timeNode, updateTime, 1)

    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority - 10)
    _bottomBg:addChild(bgMenu)
    --充值按钮
    local buyBtn = CCMenuItemImage:create( "images/recharge/recharge_btn/recharge_btn_n.png","images/recharge/recharge_btn/recharge_btn_h.png")
    buyBtn:setAnchorPoint(ccp(1,1))
    buyBtn:setPosition(ccp(_bottomBg:getContentSize().width-20, _bottomBg:getContentSize().height - 10))
    buyBtn:registerScriptTapHandler(chargeAction)
    bgMenu:addChild(buyBtn)

end
--创建背景
-----------------------------
function createLayer( p_index )
   createTopUI()
   createBottomUI()
   refreshMidUI()
end

-----入口函数
function showLayer(p_touchPriority,p_zOrder)
	init()
	_touchPriority = p_touchPriority or -499
	_zOrder = p_zOrder or 999
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
   -- _bgLayer:setScale(g_fScaleX)
    BowlService.getBowlInfo(createLayer)
	return _bgLayer

end



