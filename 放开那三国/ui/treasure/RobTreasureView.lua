-- Filename: RobTreasureView..lua
-- Author: lichenyang,zhz
-- Date: 2013-11-2
-- Purpose: 夺宝界面

module("RobTreasureView", package.seeall)

require "script/model/user/UserModel"
require "script/ui/main/MenuLayer"
require "script/ui/main/MainScene"
require "script/ui/treasure/RobTreasureCell"
require "script/ui/treasure/TreasureMainView"
require "script/ui/treasure/TreasureService"
require "script/audio/AudioUtil"

local _bgLayer= nil				--
local _topBg					--顶部的背景
local _ksRobTag=nil
local _bottomSp                 -- 底的sprite
local _robTableView             -- 
local _robberData = {}
local _item_temple_id =nil      -- 要抢夺的模板id
local _stainAlerContent = nil   -- 耐力的label
local _powerLabel= nil
local _silverLabel = nil
local _goldLabel=nil

curUserLevel = UserModel.getHeroLevel()       -- 记录玩家当前的等级

local _updateTimer               -- 定时器
local _shieldLabel               -- 时间

local function init( )
	_bgLayer= nil
    _topBg = nil
    _ksRobTag = 1001
    _ksBackTag = 1002
    _bottomSp= nil
    _robTableView= nil
    _robberData={}
    _item_temple_id = nil
    _stainAlerContent= {}
    _powerLabel= nil
     _silverLabel = nil
     _goldLabel= nil
     _updateTimer= nil
     _shieldLabel= nil
     curUserLevel = UserModel.getHeroLevel()
end

-- 创建顶部的UI
function createTopUI( ... )
	-- 上标题栏 显示战斗力，银币，金币

	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	
	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_bgLayer:getContentSize().height)
    _topBg:setScale(g_fScaleX/MainScene.elementScale)
    _bgLayer:addChild(_topBg, 10)
    titleSize = _topBg:getContentSize()

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
   	_powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    --changed by DJN   原来的情况是银币数量后面会有一个小数点和5个0 挡住了金币 所以用了math.ceil
    -- modified by yangrui at 2015-12-03
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(math.ceil(userInfo.silver_num)),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create( userInfo.gold_num,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
    -- return _topBg
end

function refreshTopUi(  )

    _goldLabel= tolua.cast( _goldLabel ,"CCLabelTTF")
    if(_goldLabel~= nil and _goldLabel:getString() ) then
        local userInfo = UserModel.getUserInfo()
        _powerLabel:setString(UserModel.getFightForceValue())
        -- modified by yangrui at 2015-12-03
        _silverLabel:setString(string.convertSilverUtilByInternational(tonumber(userInfo.silver_num)))
        _goldLabel:setString("" .. userInfo.gold_num)
    end
end

function refreshUI( )
    refreshTopUi()
    refreshBottomUI()
end

-- 按钮的回调函数
local function menuCallBack( tag, item )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(tag == _ksRobTag) then
        item:selected()
    elseif(tag == _ksBackTag) then
      local layer=  TreasureMainView.create()
       MainScene.changeLayer(layer, "layer")
    end
end



--[[
    @des:       刷新免战时间定时器
]]
local function updateShieldTime( ... )
    local shieldTimeString = GetLocalizeStringBy("key_2670") .. TimeUtil.getTimeString(TreasureData.getHaveShieldTime())
    _shieldLabel:setString(shieldTimeString)
    if(TreasureData.getHaveShieldTime() <= 0) then
        _shieldLabel:setVisible(false)
    else
        _shieldLabel:setVisible(true)
    end
end

--创建夺宝按钮
local function createMenuSp(  )
    _btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
    _btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
    _btnFrameSp:setAnchorPoint(ccp(0.5, 1))
    _btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height- _topBg:getContentSize().height * g_fScaleX ))
    _btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
    _bgLayer:addChild(_btnFrameSp, 10)

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0, 0))
    menuBar:setTouchPriority(-210)
    _btnFrameSp:addChild(menuBar, 10)

    -- 夺宝的按钮
    local robButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_3089"), 30)
    robButton:setAnchorPoint(ccp(0, 0))
    robButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.05, _btnFrameSp:getContentSize().height*0.1))
    robButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(robButton,1, _ksRobTag)
    robButton:selected()

    -- 返回按钮的回调函数
    local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backBtn:setAnchorPoint(ccp(1,0.5))
    backBtn:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5+6))
    backBtn:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(backBtn,1,_ksBackTag)

    require "script/utils/TimeUtil"
    local shieldTimeString = GetLocalizeStringBy("key_2670") .. TimeUtil.getTimeString(TreasureData.getHaveShieldTime())
    _shieldLabel = CCLabelTTF:create(shieldTimeString, g_sFontName, 24)-- , 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _shieldLabel:setColor(ccc3(0x36, 0xff, 0x00))
    _shieldLabel:setAnchorPoint(ccp(0,0.5))
    _shieldLabel:setPosition(ccp( _btnFrameSp:getContentSize().width*0.367 , _btnFrameSp:getContentSize().height*0.4 ))
    _btnFrameSp:addChild(_shieldLabel)
    if(TreasureData.getHaveShieldTime() <= 0) then
        _shieldLabel:setVisible(false)
    else
        _shieldLabel:setVisible(true)
    end

   _updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)
    
end

-- 刷新TableView 刷新TableView
local function refreshTableView(  )
    _robberData = TreasureData.getRobberList()
    _robTableView:reloadData()
end

-- 换一批对手的回调函数
function robCallBack( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    TreasureService.getRecRicher(function ( ... )
        refreshTableView()
    end, _item_temple_id)
end

-- 创建夺宝的底
local function createBottomUI( )
    _bottomSp = CCScale9Sprite:create("images/common/bg/bottom.png")
    _bottomSp:setPreferredSize(CCSizeMake(640,85))
    _bottomSp:setScale(g_fScaleX/MainScene.elementScale)
    _bottomSp:setPosition(_bgLayer:getContentSize().width/2,12*MainScene.elementScale)
    _bottomSp:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_bottomSp)

    -- 耐力
    _stainAlerContent = {}
    _stainAlerContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_2268") , g_sFontName, 24)
    _stainAlerContent[1]:setColor(ccc3(0xff,0xff,0xff))
    _stainAlerContent[2]= CCLabelTTF:create(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(),g_sFontName,24)
    _stainAlerContent[2]:setColor(ccc3(0x36,0xff,0x00))

    local alert = BaseUI.createHorizontalNode(_stainAlerContent)
    alert:setPosition(ccp(_bottomSp:getContentSize().width*0.1 ,_bottomSp:getContentSize().height*0.5))
    -- alert:setAnchorPoint(ccp(0,0.5))
    _bottomSp:addChild(alert)

    -- 夺宝消耗
    local  robContent={}
    robContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_1844") , g_sFontName, 24)
    robContent[1]:setColor(ccc3(0xff,0x27,0x27))
    robContent[2]= CCLabelTTF:create("" .. TreasureData.getEndurance() ,g_sFontName,24)
    robContent[2]:setColor(ccc3(0x36,0xff,0x00))

    local robNode = BaseUI.createHorizontalNode(robContent)
    robNode:setPosition(ccp(alert:getContentSize().width+ 10+_bottomSp:getContentSize().width*0.1 ,_bottomSp:getContentSize().height*0.5))
    -- robNode:setAnchorPoint(ccp(0,0.5))
    _bottomSp:addChild(robNode)

    -- 免战描述 每日从00：00 到 10：11，无法抢夺其他玩家
    local  freeWarContent={}
    local startTime , endTime = TreasureData.getShieldStartAndEndTime()
    freeWarContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_3268") .. startTime .. GetLocalizeStringBy("key_2358") .. endTime .. GetLocalizeStringBy("key_3336") , g_sFontName, 24)
    freeWarContent[1]:setColor(ccc3(0xff,0xff,0xff))
    local freeWarNode = BaseUI.createHorizontalNode(freeWarContent)
    freeWarNode:setPosition(ccp(_bottomSp:getContentSize().width*13/640 ,_bottomSp:getContentSize().height*0.08))
    -- robNode:setAnchorPoint(ccp(0,0.5))
    _bottomSp:addChild(freeWarNode)

    --换一批对手 按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-210)
    _bottomSp:addChild(menu)

    local robBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(190, 64),GetLocalizeStringBy("key_3335"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    robBtn:setAnchorPoint(ccp(0,0.5))
    robBtn:setPosition(ccp(_bottomSp:getContentSize().width*40/64, _bottomSp:getContentSize().height*0.4))
    robBtn:registerScriptTapHandler(robCallBack)
    menu:addChild(robBtn,1, 12)

end


function refreshBottomUI( )

    _stainAlerContent[2] =  tolua.cast( _stainAlerContent[2],"CCLabelTTF")
    if(_stainAlerContent[2]~= nil and _stainAlerContent[2]:getString() ) then
        _stainAlerContent[2]:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
    end
    
end

-- 创建TableView
function createTableView( )

    _robberData = TreasureData.getRobberList()
    print("_robberData is :")
    print_t(_robberData)
    
    local cellSize = CCSizeMake(640 * g_fScaleX, 200 *g_fScaleX)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
           a2 = RobTreasureCell.createCell(_robberData[a1+1],_item_temple_id)
           a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            -- print("length of _robberData is : ", #_robberData)
            local num = #_robberData
            r = num
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    local height = _bgLayer:getContentSize().height - (_topBg:getContentSize().height + _bottomSp:getContentSize().height+ _btnFrameSp:getContentSize().height) * g_fScaleX
    _robTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, height))
    _robTableView:setScale(_robTableView:getScale()/MainScene.elementScale)
    _robTableView:setBounceable(true)
    _robTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _robTableView:setPosition(ccp(0, _bottomSp:getContentSize().height*MainScene.elementScale + 12*MainScene.elementScale ))
    _bgLayer:addChild(_robTableView)
end


function onNodeEvent( eventType )

    if(eventType == "exit") then
        print(GetLocalizeStringBy("key_3085"))
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
    end
end


-- 通过item_temple_id常见layer
function createLayer( item_temple_id)
    init()
    _item_temple_id= item_temple_id
	_bgLayer= MainScene.createBaseLayer("images/main/module_bg.png",true,false,true)
    MainScene.changeLayer(_bgLayer, "TreasureLayer")
    _bgLayer:registerScriptHandler(onNodeEvent)
	createTopUI()
    createMenuSp()
    createBottomUI()
    -- 网络回调
    TreasureService.getRecRicher(function ( ... )
        createTableView()
        --添加新手引导
        local robTreasure = getGuideButton()
        addNewGuide()
    end, item_temple_id)
end


----------------------------[[ 新手引导 ]]----------------------------------
--[[
    @des:   得到新手引导的碎片图标
]]
function getGuideButton( ... )
    local robbData      = TreasureData.getRobberList()
    local firstRobUid   = tonumber(robbData[1].uid) 
    local firstCell     = _robTableView:cellAtIndex(0)
    print("_robTableView  is : ", _robTableView)
    print("firstCell  is : ", firstCell)
    local menu          = tolua.cast(firstCell:getChildByTag(101):getChildByTag(101), "CCMenu")
    local robtn         = menu:getChildByTag(firstRobUid)
    return robtn 
end

--[[
    @des:   添加引导层方法
]]
function addNewGuide( ... )
    local guideFunc = function ( ... )
        require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 3) then
            local robTreasure = getGuideButton()
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(4, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            guideFunc()
    end))
    _bgLayer:runAction(seq)
end



