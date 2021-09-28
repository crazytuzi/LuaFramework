-- Filename: ExplainDialog.lua
-- Author: lichenyang
-- Date: 2014-07-14
-- Purpose: 擂台争霸4强场景

require "script/ui/olympic/OlympicData"
require "script/utils/BaseUI"
module("ExplainDialog",package.seeall)


local _touchPriority = nil

function init( ... )
	_touchPriority = nil
end

function show( p_touchPriority )
    local scene = CCDirector:sharedDirector():getRunningScene()
    local layer = create(p_touchPriority)
    scene:addChild(layer,999,1231)
end


local function cardLayerTouch(eventType, x, y) 
    return true
end

function create( p_touchPriority )
    init()
	_touchPriority = p_touchPriority or -1024
	local maskLayer = CCLayerColor:create(ccc4(11,11,11,166))--BaseUI.createMaskLayer(-_touchPriority)
    maskLayer:setTouchEnabled(true)
    maskLayer:registerScriptTouchHandler(cardLayerTouch,false,_touchPriority-10,true)
    m_layerSize = CCSizeMake(580, 650)
	local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0.5,0.5))
    m_reportBg:setPosition(ccps(0.5,0.5))
    maskLayer:addChild(m_reportBg)
    setAdaptNode(m_reportBg)
    
    local displayName = CCRenderLabel:create(GetLocalizeStringBy("key_3022"), g_sFontPangWa, 35, 3, ccc3( 255, 255, 255), type_stroke)
    displayName:setColor(ccc3( 0x78, 0x25, 0x00));
    displayName:setPosition(m_layerSize.width*0.42,m_layerSize.height*0.93)
    m_reportBg:addChild(displayName)
    
    local descLabel = CCLabelTTF:create(GetLocalizeStringBy("lcy_20039"),g_sFontName,24,CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.6),kCCTextAlignmentLeft)
    descLabel:setColor(ccc3( 0x78, 0x25, 0x00));
    descLabel:setAnchorPoint(ccp(0.5,0.5))
    descLabel:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.45)
    m_reportBg:addChild(descLabel)
    
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-10)
    m_reportBg:addChild(menuBar)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.02, m_layerSize.height*1.02))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(function( ... )
        maskLayer:removeFromParentAndCleanup(true)
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    end)
	return maskLayer
end

