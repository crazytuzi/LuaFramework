-- Filename: IntroLayer.lua
-- Author: k
-- Date: 2013-08-06
-- Purpose: 占星说明



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("IntroLayer", package.seeall)

local IMG_PATH = "images/battle/report/"				-- 图片主路径

local m_IntroLayer
local m_callbackFunc
local m_swfNode

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function callbackLoop()
    if(m_swfNode:Runing()==true)then
        --print("callbackLoop not finish")
    else
        print("callbackLoop finish")
        m_IntroLayer:stopActionByTag(10004)
        if(m_callbackFunc~=nil)then
            m_callbackFunc()
        end
    end
end

-- 获得层
function getIntroLayer(isMan,callbackFunc)
    m_callbackFunc = callbackFunc
    require "script/ui/main/MainScene"
    
    m_IntroLayer = CCLayer:create()
    m_IntroLayer:setTouchEnabled(true)

    
    local standSize = CCSizeMake(640, 960);
    local winSize = CCDirector:sharedDirector():getWinSize();
    local bgScale = 1.0;
    local elementScale = 1.0;
    if(winSize.height/winSize.width>standSize.height/standSize.width)then
        bgScale = winSize.height/standSize.height;
        elementScale = winSize.width/standSize.width;
        else
        elementScale = winSize.height/standSize.height;
        bgScale = winSize.width/standSize.width;
    end
    
    local fontButton = CCMenuItemFont:create(" ");
    fontButton:setPosition(0,0);
    local pMenu = CCMenu:create();
    pMenu:addChild(fontButton)
    pMenu:setPosition(0,0);
    m_IntroLayer:addChild(pMenu, 200);
    
    require "script/utils/LuaUtil"
    local swfStr = isMan==true and "images/intro/intro.swf" or "images/intro/intro2.swf"
     m_swfNode = CCSWFNode:create(swfStr)
    m_swfNode:setPosition(ccp((winSize.width-640*elementScale)*0.5,winSize.height-(winSize.height-960*elementScale)*0.5));
    m_swfNode:setAnchorPoint(ccp(0, 0));
    m_swfNode:setScale(elementScale);
    m_swfNode:runAction();
    m_swfNode:setRepeat(false);
    m_IntroLayer:addChild(m_swfNode,9);
    
    local swfAction = schedule(m_IntroLayer,callbackLoop,0.5)
    swfAction:setTag(10004)
    

    local skipButton = CCMenuItemImage:create("images/intro/skip1.png","images/intro/skip2.png")
    skipButton:setAnchorPoint(ccp(1, 0))
    skipButton:setPosition(ccps(0.95, 0.05))
    skipButton:registerScriptTapHandler(skipButtonCallback)
    pMenu:addChild(skipButton)
    skipButton:setVisible(false)
    setAdaptNode(skipButton)

    m_IntroLayer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(skipButton:isVisible() == true) then
                skipButton:setVisible(false)
            else
                skipButton:setVisible(true)
            end
        elseif(eventType == "moved") then

        elseif(eventType == "ended") then

        end
    end)
    return m_IntroLayer
end

function skipButtonCallback( ... )
    -- body
    m_callbackFunc()
end


-- 退出场景，释放不必要资源
function release (...) 

end
