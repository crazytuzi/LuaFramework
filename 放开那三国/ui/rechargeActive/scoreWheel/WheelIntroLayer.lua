-- Filename: WheelIntroLayer.lua
-- Author: DJN
-- Date: 2014-11-11
-- Purpose: 积分轮盘玩法介绍

module("WheelIntroLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/model/utils/ActivityConfig"


local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层


----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
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


----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(620,650)
    local bgScale = MainScene.elementScale

    --主背景图
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)
    
    --标题
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2934"), g_sFontPangWa, 30)
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)
    
    --正文
    --local descLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_87"),g_sFontName,24,CCSizeMake(bgSize.width*0.9,bgSize.height*0.6),kCCTextAlignmentLeft)
    local descLabel = CCLabelTTF:create(string.gsub(ActivityConfig.ConfigCache.roulette.data[1]["ActivityDes"], "\\n", "\n"),g_sFontName,24,CCSizeMake(bgSize.width*0.9,bgSize.height*0.6),kCCTextAlignmentLeft)
    descLabel:setColor(ccc3( 0x78, 0x25, 0x00));
    descLabel:setAnchorPoint(ccp(0.5,0.5))
    descLabel:setPosition(bgSize.width*0.5,bgSize.height*0.55)
    bgSprite:addChild(descLabel)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png","images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

   
   
end
----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x2e,0x49,100))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()
  
end
