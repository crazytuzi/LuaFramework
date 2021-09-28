-- Filename: FightResultLayer.lua
-- Author: bzx
-- Date: 2014-06-24
-- Purpose: 寻龙探宝战斗结算

module("FightResultLayer", package.seeall)

require "script/ui/forge/FindTreasureLayer"
require "script/ui/forge/FindTreasureData"

local mainLayer = nil
local menu = nil
local backAnimSprite = nil
local animSprite = nil
local winSize = nil
local bg_sprite = nil
-- 回调函数
local afterOKCallFun = nil

local _fightStr       =nil      -- added by zhz: 战斗串
local _ksTagTxt       = 101
local _addition_label
local _cur_addition
local _to_addition
local _refresh_addition_scheduler

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true
end

function onNodeEvent(event_type)
    if event_type == "enter" then
        if(file_exists("audio/effect/zhandoushibai.mp3")) then
            AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
        end
    elseif event_type == "exit" then
        if _refresh_addition_scheduler ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_refresh_addition_scheduler)
            _refresh_addition_scheduler = nil
         end
    end
end
-- 创建挑战结算面板
-- appraisal:战斗评价
-- enemyUid:对方的uid
function create(appraisal, CallFun, event_db)
	-- 点击确定按钮传入回调
	afterOKCallFun = CallFun

   	winSize = CCDirector:sharedDirector():getWinSize()
	mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:registerScriptHandler(onNodeEvent)
	mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)
    bg_sprite = BaseUI.createViewBg(CCSizeMake(520, 479))
    bg_sprite:setScale(MainScene.elementScale)
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.484))
    mainLayer:addChild(bg_sprite)
    
    local scale9 = CCScale9Sprite:create("images/recharge/desc_bg.png")
    bg_sprite:addChild(scale9)
    scale9:setContentSize(CCSizeMake(461, 294))
    scale9:setAnchorPoint(ccp(0.5, 0.5))
    scale9:setPosition(ccp(bg_sprite:getContentSize().width * 0.5, 256))
    local fight_level_datas = {
        SSS = {point = event_db.integralReward[1][2], file_name = "sss.png"},
        SS = {point = event_db.integralReward[2][2], file_name = "ss.png"},
        S = {point = event_db.integralReward[3][2], file_name = "s.png"},
        A = {point = event_db.integralReward[4][2], file_name = "a.png"},
        B = {point = event_db.integralReward[5][2], file_name = "b.png"},
        C = {point = event_db.integralReward[5][2], file_name = "b.png"},
        D = {point = event_db.integralReward[5][2], file_name = "b.png"},
        E = {point = event_db.integralReward[6][2]},
        F = {point = event_db.integralReward[6][2]},
    }
    -- 战斗胜负判断
    local isWin = nil
    local fight_level_data = fight_level_datas[appraisal]
    if appraisal ~= "F" and appraisal ~= "E" and fight_level_data ~= nil then
    	isWin = true
    	-- 创建胜利背景框
        local fight_level_title = CCSprite:create("images/forge/fight_result/fight_level.png")
        scale9:addChild(fight_level_title)
        fight_level_title:setAnchorPoint(ccp(0, 0.5))
        fight_level_title:setPosition(ccp(25, 238))
        local fight_level_bg = CCSprite:create("images/forge/fight_result/level_bg.png")
        scale9:addChild(fight_level_bg)
        fight_level_bg:setAnchorPoint(ccp(0.5, 0.5))
        fight_level_bg:setPosition(ccp(235, 222))
        local fight_level_sp = CCSprite:create("images/forge/fight_result/" .. fight_level_data.file_name)
        fight_level_bg:addChild(fight_level_sp)
        fight_level_sp:setAnchorPoint(ccp(0.5, 0.5))
        fight_level_sp:setPosition(ccp(fight_level_bg:getContentSize().width * 0.5, fight_level_bg:getContentSize().height * 0.5))
        local point_title = CCSprite:create("images/forge/fight_result/get_point.png")
        scale9:addChild(point_title)
        point_title:setAnchorPoint(ccp(0, 0.5))
        point_title:setPosition(ccp(25, 85))
        local point_label = CCLabelTTF:create("10", g_sFontName, 25)
        point_title:addChild(point_label)
        point_label:setAnchorPoint(ccp(0, 0.5))
        point_label:setPosition(ccp(point_title:getContentSize().width, point_title:getContentSize().height * 0.5 - 5))
        _cur_addition = 0
        _to_addition = fight_level_data.point - 10
        _addition_label = CCLabelTTF:create("+" .. _cur_addition, g_sFontName, 25)
        point_title:addChild(_addition_label)
        _addition_label:setColor(ccc3(0x00, 0xff, 0x18))
        _addition_label:setAnchorPoint(ccp(0, 0.5))
        _addition_label:setPosition(ccp(point_title:getContentSize().width + point_label:getContentSize().width, point_title:getContentSize().height * 0.5 - 5))
        _refresh_addition_scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleRefreshAddition, 0.2, false)
        
        local addition_sp = CCSprite:create("images/forge/fight_result/level_addition.png")
        scale9:addChild(addition_sp)
        addition_sp:setAnchorPoint(ccp(0.5, 0.5))
        addition_sp:setPosition(ccp(362, 84))
        local line_sp = CCSprite:create("images/common/line02.png")
        scale9:addChild(line_sp)
        line_sp:setAnchorPoint(ccp(0.5, 0.5))
        line_sp:setPosition(ccp(scale9:getContentSize().width * 0.5, scale9:getContentSize().height * 0.5))
        line_sp:setScaleX(4)
        FindTreasureData.addPoint(fight_level_data.point)
        FindTreasureLayer.refreshPoint()
    else
    	isWin = false
    	-- 创建失败背景框
        local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8098"), g_sFontPangWa, 25)
        scale9:addChild(tip)
        tip:setAnchorPoint(ccp(0.5, 0.5))
        tip:setPosition(ccp(scale9:getContentSize().width * 0.5, 207))
        local point_title = CCSprite:create("images/forge/fight_result/get_point.png")
        scale9:addChild(point_title)
        point_title:setAnchorPoint(ccp(0.5, 0.5))
        point_title:setPosition(ccp(211, 107))
        local point_label = CCLabelTTF:create(fight_level_datas["F"].point, g_sFontName, 25)
        point_title:addChild(point_label)
        point_label:setAnchorPoint(ccp(0, 0.5))
        point_label:setPosition(ccp(point_title:getContentSize().width, point_title:getContentSize().height * 0.5 - 5))
        FindTreasureData.addPoint(fight_level_datas["F"].point)
        FindTreasureLayer.refreshPoint()
    end

	-- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    bg_sprite:addChild(menu)


    -- 重播
    local replayItem = createButtonItem(GetLocalizeStringBy("key_2184"))
    replayItem:setAnchorPoint(ccp(0.5,0.5))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3, 63))
    -- 确定
    local okItem = createButtonItem(GetLocalizeStringBy("key_1985"))
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7, 63))
    --播放胜负动画
    animSprite = nil
    if(isWin) then
    	-- 胜利特效
        backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height)
        bg_sprite:addChild(backAnimSprite2,-1)
        backAnimSprite2:setVisible(false)
        
        local function showBg2()
            backAnimSprite2:setVisible(true)
        end
        
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.1))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite2:runAction(CCSequence:create(layerActionArray))
    
        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));
        
        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
        bg_sprite:addChild(backAnimSprite,0)
        
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
    else
        backAnimSprite = nil
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    end
    animSprite:retain()
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    -- require "script/ui/main/MainScene"
    -- animSprite:setScale(MainScene.elementScale)
    bg_sprite:addChild(animSprite)
    animSprite:release()
    
    delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    return mainLayer
end

function scheduleRefreshAddition(time)
    _cur_addition = _cur_addition + 1
    _addition_label:setString("+" .. _cur_addition)
    if _cur_addition >= _to_addition then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_refresh_addition_scheduler)
        _refresh_addition_scheduler = nil
    end
end

-- 特效播放结束后回调
function animationEnd( ... )
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    if(animSprite~=nil)then
        animSprite:cleanup()
    end
end


function animationFrameChanged( ... )
	-- body
end

-- 按钮item
function createButtonItem( str )
    
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disableSprite= CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite, disableSprite)
    -- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
   	item:addChild(item_font,1, _ksTagTxt)
   	return item
end

-- 重播回调
function replayItemFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_2460") .. tag )
    require "script/battle/BattleLayer"
    BattleLayer.replay()
end


-- 确定回调
function okItemFun( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_2060") .. tag )
	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
    	afterOKCallFun()
    end
end