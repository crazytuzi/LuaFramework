-- Filename: PracticeResultLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-08-15
-- Purpose: 武艺切磋战斗结算面板

module("PracticeResultLayer", package.seeall)

require "script/ui/replaceSkill/ReplaceSkillData"

local _backAnimSprite               --动画
local _animSprite                   --动画
local _totalScore                   --增加的总分数
local _addScore                     --加的分数
local _addLabel                     --增加分数label
local _refresh_addition_scheduler   --定时器
local _beginTimeer                  --开启定时器标识

local function init()
    _backAnimSprite = nil
    _animSprite = nil
    _addLabel = nil
    _refresh_addition_scheduler = nil
    _beginTimeer = false
    _totalScore = 0
    _addScore = 0
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true
end

local function onNodeEvent(event_type)
    if event_type == "enter" then
        _beginTimeer = true
        if(file_exists("audio/effect/zhandoushibai.mp3")) then
            AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
        end
    elseif event_type == "exit" then
        if _refresh_addition_scheduler ~= nil then
            _beginTimeer = false
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_refresh_addition_scheduler)
            _refresh_addition_scheduler = nil
        end
    end
end

--[[
	@des 	:创建战斗结算面板（借鉴神龙战斗结算面板，借鉴这个词用的很鸡贼）
	@param 	:战斗评价
	@return :
--]]
function create(p_appraisal)
    init()

	local winSize = CCDirector:sharedDirector():getWinSize()
	local mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:registerScriptHandler(onNodeEvent)
	mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)
    local bg_sprite = BaseUI.createViewBg(CCSizeMake(520, 479))
    bg_sprite:setScale(MainScene.elementScale)
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.484))
    mainLayer:addChild(bg_sprite)

    local scale9 = CCScale9Sprite:create("images/recharge/desc_bg.png")
    bg_sprite:addChild(scale9)
    scale9:setContentSize(CCSizeMake(461, 294))
    scale9:setAnchorPoint(ccp(0.5, 0.5))
    scale9:setPosition(ccp(bg_sprite:getContentSize().width * 0.5, 256))

    local file_name
    if p_appraisal == "SSS" then
        file_name = "sss.png"
    elseif p_appraisal == "SS" then
        file_name = "ss.png"
    elseif p_appraisal == "S" then
        file_name = "s.png"
    elseif p_appraisal == "A" then
        file_name = "a.png"
    else
        file_name = "b.png"
    end

    --分割线
    local line_sp = CCSprite:create("images/common/line02.png")
    scale9:addChild(line_sp)
    line_sp:setAnchorPoint(ccp(0.5, 0.5))
    line_sp:setScaleX(4)

    -- 战斗胜负判断
    local isWin = nil
    local gainNumLabel
   
    --获得修行值
    local gainMonkeryLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1090"),g_sFontPangWa,33)
    gainMonkeryLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    gainMonkeryLabel:setAnchorPoint(ccp(0,0))
    gainMonkeryLabel:setPosition(ccp(25,75))
    scale9:addChild(gainMonkeryLabel)
    
    if p_appraisal ~= "F" and p_appraisal ~= "E" then
        isWin = true
        -- 创建胜利背景框
        local fight_level_title = CCSprite:create("images/forge/fight_result/fight_level.png")
        scale9:addChild(fight_level_title)
        fight_level_title:setAnchorPoint(ccp(0, 0.5))
        fight_level_title:setPosition(ccp(25, 238))
        --战斗评价图
        local fight_level_sp = CCSprite:create("images/forge/fight_result/" .. file_name)
        scale9:addChild(fight_level_sp)
        fight_level_sp:setAnchorPoint(ccp(0.5, 0.5))
        fight_level_sp:setPosition(ccp(235,222))

        --胜利提示文字
        local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1089"), g_sFontPangWa, 25)
        scale9:addChild(tipLabel)
        tipLabel:setAnchorPoint(ccp(0.5, 0.5))
        tipLabel:setPosition(ccp(scale9:getContentSize().width * 0.5, 150))

        line_sp:setPosition(ccp(scale9:getContentSize().width * 0.5, scale9:getContentSize().height * 0.5 - 20))

        gainNumLabel = CCLabelTTF:create(ReplaceSkillData.getFightFeelValue("F"),g_sFontName,25)

        _addLabel = CCLabelTTF:create("+0",g_sFontName,25)
        _addLabel:setColor(ccc3(0x00,0xff,0x18))
        _addLabel:setAnchorPoint(ccp(0,0))
        _addLabel:setPosition(ccp(25 + gainMonkeryLabel:getContentSize().width + gainNumLabel:getContentSize().width,75))
        scale9:addChild(_addLabel)

        _totalScore = tonumber(ReplaceSkillData.getFightFeelValue(tostring(p_appraisal))) - tonumber(ReplaceSkillData.getFightFeelValue("F"))

        _refresh_addition_scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleRefreshAddition, 0.01, false)

        local addition_sp = CCSprite:create("images/forge/fight_result/level_addition.png")
        scale9:addChild(addition_sp)
        addition_sp:setAnchorPoint(ccp(0.5, 0.5))
        addition_sp:setPosition(ccp(380, 84))
    else
        isWin = false
        -- 创建失败背景框
        local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8098"), g_sFontPangWa, 25)
        scale9:addChild(tip)
        tip:setAnchorPoint(ccp(0.5, 0.5))
        tip:setPosition(ccp(scale9:getContentSize().width * 0.5, 210))

        line_sp:setPosition(ccp(scale9:getContentSize().width * 0.5, scale9:getContentSize().height * 0.5))

        gainNumLabel = CCLabelTTF:create(ReplaceSkillData.getFightFeelValue(tostring(p_appraisal)),g_sFontName,25)
    end

    gainNumLabel:setAnchorPoint(ccp(0,0))
    gainNumLabel:setPosition(ccp(25 + gainMonkeryLabel:getContentSize().width,75))
    scale9:addChild(gainNumLabel)

    local menu = CCMenu:create()
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

    if(isWin) then
        -- 胜利特效
        local backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
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
    
        _backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));
        
        _backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        _backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
        bg_sprite:addChild(_backAnimSprite,0)
        
        _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
    else
        _backAnimSprite = nil
        _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    end
    _animSprite:retain()
    _animSprite:setAnchorPoint(ccp(0.5, 0.5));
    _animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    -- require "script/ui/main/MainScene"
    -- animSprite:setScale(MainScene.elementScale)
    bg_sprite:addChild(_animSprite)
    _animSprite:release()
    
   local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    _animSprite:setDelegate(delegate)

    return mainLayer
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
    item:addChild(item_font)
    return item
end

-- 重播回调
function replayItemFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/battle/BattleLayer"
    BattleLayer.replay()
end

-- 确定回调
require "script/ui/replaceSkill/ReplaceSkillLayer"
function okItemFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
end

-- 特效播放结束后回调
function animationEnd()
    if(_backAnimSprite~=nil)then
        _backAnimSprite:cleanup()
    end
    if(_animSprite~=nil)then
        _animSprite:cleanup()
    end
end


function animationFrameChanged()
end

function scheduleRefreshAddition(p_time)
    if _beginTimeer then
        _addScore = _addScore + 1
        _addLabel:setString("+" .. _addScore)
        if _addScore >= _totalScore then
            _beginTimeer = false
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_refresh_addition_scheduler)
            _refresh_addition_scheduler = nil
        end
    end
end