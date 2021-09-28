-- Filename：	ScoreShopLayer.lua
-- Author：		DJN
-- Date：		2015-3-3
-- Purpose：    积分商店主界面


module ("ScoreShopLayer", package.seeall)
require "script/ui/rechargeActive/scoreShop/ScoreShopTableView"
require "script/audio/AudioUtil"
require "script/libs/LuaCCLabel"
require "script/ui/rechargeActive/scoreShop/ScoreShopService"
require "script/ui/rechargeActive/scoreShop/ScoreShopData"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/utils/TimeUtil"

-- require "script/ui/tip/AnimationTip"

local _bgLayer               --整个背景layer
local _touchPriority         --触摸优先级
local _zOrder                --z轴
local _packBackground        --紫色背景
local _rewardTablView        --中间tableview
local _scoreLabel            --当前拥有积分数量

function init()
	_bgLayer = nil
	_touchPriority = nil
	_zOrder = nil
    _packBackground = nil
    _rewardTablView = nil
    _scoreLabel = nil
	
end
----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        -- return true
    elseif (eventType == "moved") then
        --print("moved")
    else
        --print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end
function explainButtonCallBack( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/rechargeActive/scoreShop/ScoreShopIntroduce"
    ScoreShopIntroduce.showLayer(_touchPriority-50,_zOrder+10)

end
function createLayer( ... )
    --紫色大背景
    _packBackground = CCScale9Sprite:create("images/recharge/mystery_merchant/bg.png")
    -- _layer:setScale(1/MainScene.elementScale)
    
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
    local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()-15*g_fScaleX

    _packBackground:setContentSize(CCSizeMake(g_winSize.width/g_fScaleX,height/g_fScaleX))
    _bgLayer:setContentSize(CCSizeMake(g_winSize.width,height))
    --_packBackground:setContentSize(CCSizeMake(640,960))
    _packBackground:setAnchorPoint(ccp(0,0))
    _packBackground:setScale(g_fScaleX)
    _packBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX+15*g_fScaleX))
    _bgLayer:addChild(_packBackground)

    local midHeight = height/g_fScaleX

    --上面花纹
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local _border_top = CCSprite:create(border_filename)
    _packBackground:addChild(_border_top)

    _border_top:setAnchorPoint(ccp(0.5,0))
    
    --_border_top:setScale(g_fScaleX)
    _border_top:setScaleY(-1)
   
    --local border_top_y = g_winSize.height - bulletinLayerSize.height * g_fScaleX - activeMainWidth
    _border_top:setPosition( _packBackground:getContentSize().width*0.5, _packBackground:getContentSize().height)

    --小铝孩
    local girl = CCSprite:create("images/recharge/score_shop/girl.png")
    girl:setAnchorPoint(ccp(0,0))
    girl:setPosition(ccp(0,5))
    _packBackground:addChild(girl)
    -- --描述说明
    -- local richInfo = {lineAlignment = 20,elements = {},alignment = 2,defaultType = "CCRenderLabel",}
    --     richInfo.elements[1] = {
    --             -- ["type"] = "CCRenderLabel",  
    --             text = GetLocalizeStringBy("djn_148"),
    --             font = g_sFontPangWa,
    --             size = 25,
    --             color = ccc3(0xff,0xf6,0x00)}
    --     richInfo.elements[2] = {
    --             -- ["type"] = "CCRenderLabel", 
    --             newLine = true, 
    --             text = GetLocalizeStringBy("djn_149",ScoreShopData.getPointTable()[1]),
    --             font = g_sFontPangWa,
    --             size = 20,
    --             color = ccc3(0xff,0xff,0xff)}
    --     richInfo.elements[3] = {
    --             -- ["type"] = "CCRenderLabel", 
    --             newLine = true, 
    --             text = GetLocalizeStringBy("djn_150",ScoreShopData.getPointTable()[2]),
    --             font = g_sFontPangWa,
    --             size = 20,
    --             color = ccc3(0xff,0xff,0xff)}
    --     richInfo.elements[4] = {
    --             -- ["type"] = "CCRenderLabel", 
    --             newLine = true, 
    --             text = GetLocalizeStringBy("djn_151",ScoreShopData.getPointTable()[3]),
    --             font = g_sFontPangWa,
    --             size = 20,
    --             color = ccc3(0xff,0xff,0xff)}
    
    -- local midSp = LuaCCLabel.createRichLabel(richInfo)
    -- midSp:setAnchorPoint(ccp(0,1))
    -- midSp:setPosition(ccp(10,_packBackground:getContentSize().height *0.95))
    -- _packBackground:addChild(midSp)
    local layerMenu = CCMenu:create()
    layerMenu:setAnchorPoint(ccp(0,0))
    layerMenu:setPosition(ccp(0,0))
    _packBackground:addChild(layerMenu)
    layerMenu:setTouchPriority(_touchPriority-1)

    local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
    explainButton:setAnchorPoint(ccp(0, 1))
    explainButton:registerScriptTapHandler(explainButtonCallBack)
    explainButton:setPosition(ccp(20,_packBackground:getContentSize().height*0.95))
    layerMenu:addChild(explainButton)


    --tableview二级背景
    local secondBg = CCScale9Sprite:create("images/recharge/score_shop/second_bg.png")
    secondBg:setContentSize(CCSizeMake(460,midHeight*0.8))
    secondBg:setAnchorPoint(ccp(1,1))
    secondBg:setPosition(ccp(_packBackground:getContentSize().width*0.95,midHeight*0.94))
    _packBackground:addChild(secondBg)

    --标题背景
    local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/dress_room/name_bg.png")
    secondBg:addChild(nameBg)
    nameBg:setPreferredSize(CCSizeMake(258, 68))
    nameBg:setAnchorPoint(ccp(0.5, 0.5))
    nameBg:setPosition(ccpsprite(0.5,0.995,secondBg))

    --标题
    local name = CCRenderLabel:create(GetLocalizeStringBy("djn_154"), g_sFontPangWa, 30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    nameBg:addChild(name)
    name:setAnchorPoint(ccp(0.5, 0.5))
    name:setPosition(ccpsprite(0.5, 0.5, nameBg))
    name:setColor(ccc3(0xff, 0xf6, 0x00))

    --创建中间奖励的tableview 高度为中间空闲高度的70% 
    local tableViewSize = CCSizeMake(440,midHeight*0.72)
    _rewardTablView = ScoreShopTableView.createTableView(tableViewSize)
    _rewardTablView:setBounceable(true)
    _rewardTablView:ignoreAnchorPointForPosition(false)
    _rewardTablView:setAnchorPoint(ccp(0.5, 0))
    _rewardTablView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _rewardTablView:setPosition(ccp(secondBg:getContentSize().width*0.5, 15))
    secondBg:addChild(_rewardTablView)
    _rewardTablView:setTouchPriority(_touchPriority - 10)

    --拥有积分
    local scoreString = CCRenderLabel:create(GetLocalizeStringBy("djn_152"),g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    scoreString:setColor(ccc3(0x00,0xe4,0xff))
    scoreString:setAnchorPoint(ccp(1,0))
    scoreString:setPosition(ccp(_packBackground:getContentSize().width*0.5,midHeight*0.08))
    _packBackground:addChild(scoreString)

    _scoreLabel = CCRenderLabel:create(ScoreShopData.getShopInfo().point,g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    _scoreLabel:setColor(ccc3(0xff,0xf6,0x00))
    _scoreLabel:setAnchorPoint(ccp(0,0))
    _scoreLabel:setPosition(ccp(_packBackground:getContentSize().width*0.51,midHeight*0.08))
    _packBackground:addChild(_scoreLabel)

    --活动时间
    --分段显示 如果在可得到积分的时间段 显示活动开始时间到配置的天数这段时间 如果过了可得积分的时间段 显示活动结束时间
    --if( ScoreShopData.getGainEndTime() > TimeUtil.getSvrTimeByOffset() )then
    if(ScoreShopData.ifInGain())then
        --当前是可得积分的阶段
        local startTimeString = CCRenderLabel:create(GetLocalizeStringBy("djn_156"),g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        startTimeString:setColor(ccc3(0x00,0xe4,0xff))
        startTimeString:setAnchorPoint(ccp(1,1))
        startTimeString:setPosition(ccp(_packBackground:getContentSize().width*0.5,midHeight*0.07))
        _packBackground:addChild(startTimeString)

        startTimeLabel = CCRenderLabel:create(TimeUtil.getTimeFormatYMDHMS(ActivityConfigUtil.getDataByKey("scoreShop").start_time),
                    g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        startTimeLabel:setColor(ccc3(0x00,0xff,0x18))
        startTimeLabel:setAnchorPoint(ccp(0,1))
        startTimeLabel:setPosition(ccp(_packBackground:getContentSize().width*0.51,midHeight*0.07))
        _packBackground:addChild(startTimeLabel)

        local endTimeString = CCRenderLabel:create(GetLocalizeStringBy("djn_157"),g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        endTimeString:setColor(ccc3(0x00,0xe4,0xff))
        endTimeString:setAnchorPoint(ccp(1,1))
        endTimeString:setPosition(ccp(_packBackground:getContentSize().width*0.5,midHeight*0.04))
        _packBackground:addChild(endTimeString)

        endTimeLabel = CCRenderLabel:create(TimeUtil.getTimeFormatYMDHMS(ScoreShopData.getGainEndTime())
                    ,g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        endTimeLabel:setColor(ccc3(0x00,0xff,0x18))
        endTimeLabel:setAnchorPoint(ccp(0,1))
        endTimeLabel:setPosition(ccp(_packBackground:getContentSize().width*0.51,midHeight*0.04))
        _packBackground:addChild(endTimeLabel)
    elseif(ActivityConfigUtil.getDataByKey("scoreShop").end_time >= TimeUtil.getSvrTimeByOffset())then
        local timeString = CCRenderLabel:create(GetLocalizeStringBy("djn_155",TimeUtil.getInternationalDateFormat(ActivityConfigUtil.getDataByKey("scoreShop").end_time)),
                           g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        timeString:setColor(ccc3(0xff,0xf6,0x00))
        timeString:setAnchorPoint(ccp(0,1))
        timeString:setPosition(ccp(_packBackground:getContentSize().width*0.1,midHeight*0.05))
        _packBackground:addChild(timeString)

    end
end
function refreshUI( ... )
    _scoreLabel:setString(ScoreShopData.getShopInfo().point)
    local offset = _rewardTablView:getContentOffset()
    _rewardTablView:reloadData()
    _rewardTablView:setContentOffset(offset)
end
function getTouchPriority( ... )
    return _touchPriority
end
function getZOrder( ... )
    return _zOrder
end
-----入口函数
function showLayer(p_touchPriority,p_zOrder)
	init()
	_touchPriority = p_touchPriority or -499
	_zOrder = p_zOrder or 999
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    -- _bgLayer:setScale(g_fScaleX)
    ScoreShopService.getShopInfo(createLayer)
    --createLayer()

	return _bgLayer

end



