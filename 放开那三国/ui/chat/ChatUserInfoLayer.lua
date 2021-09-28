-- Filename: ChatUserInfoLayer.lua
-- Author: k
-- Date: 2013-08-06
-- Purpose: 占星说明


require "script/network/RequestCenter"
require "script/network/Network"
require "script/utils/extern"
require "script/ui/chat/ChatCache"
require "script/ui/tip/AlertTip"
require "script/ui/tip/SingleTip"
 
--require "amf3"
-- 主城场景模块声明
module("ChatUserInfoLayer", package.seeall)

local IMG_PATH = "images/battle/report/"				-- 图片主路径

local m_ChatUserInfoLayer
local talkEditBox
local m_uname
local m_ulevel
local m_uid
local _touchPriority

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function closeClick()
    --点击音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChildByTag(1251,true)
end

function addFriendClickCallback(cbFlag, dictData, bRet )
	
	if(dictData.err == "ok") then
		if(dictData.ret == "ok") then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_2558"))
            
        elseif(dictData.ret == "applied")then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_3373"))
            
        elseif(dictData.ret == "alreadyfriend")then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_1776"))
            
        elseif(dictData.ret == "reach_maxnum")then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_1735"))
        elseif(dictData.ret == "black")then
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("lic_1061")
            AnimationTip.showTip(str)
            return
        elseif(dictData.ret == "beblack")then
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("lic_1055")
            AnimationTip.showTip(str)
            return
		end
	end
end

function addFriendClick()
    if tostring(UserModel.getUserUid()) == m_uid then
        SingleTip.showTip(GetLocalizeStringBy("key_10011"))
        return
    end
    if ChatCache.isShieldedPlayer(m_uid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8088"))
        return
    end
    RequestCenter.friend_applyFriend(addFriendClickCallback,Network.argsHandler(m_uid,""))
end

function talkInPm()
    if tostring(UserModel.getUserUid()) == m_uid then
        SingleTip.showTip(GetLocalizeStringBy("key_10012"))
        return
    end
    
    require "script/ui/chat/ChatMainLayer"
    ChatMainLayer.showChatLayer(2, _touchPriority - 10)
    ChatMainLayer.setTargetName(m_uname)
    --ChatMainLayer.pmClick()
    closeClick()
end

function showChatUserInfoLayer(uname,ulevel,power,img,uid,uGender,htid,dressInfo, touchPriority)
    _touchPriority = touchPriority or -410
    m_uname = uname
    m_ulevel = ulevel
    m_uid = uid
    uGender = uGender==nil and 0 or uGender
    require "script/ui/main/MainScene"
    
    local m_layerSize = CCSizeMake(420,410)
    
    local scale = MainScene.elementScale
    
    m_ChatUserInfoLayer = CCLayerColor:create(ccc4(11,11,11,166))
    
    
    local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/hero/bg_ng.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0.5, 0.5))
    m_reportBg:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    m_reportBg:setScale(scale)
    m_ChatUserInfoLayer:addChild(m_reportBg)
    
    local m_infoBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    m_infoBg:setContentSize(CCSizeMake(m_layerSize.width*0.9,250 * 0.55))
    m_infoBg:setAnchorPoint(ccp(0,0))
    m_infoBg:setPosition(ccp(m_layerSize.width*0.05,m_layerSize.height - 160))
    m_reportBg:addChild(m_infoBg)
    
    local splitSprite = CCScale9Sprite:create(CCRectMake(30, 1, 56, 2),"images/chat/spliter.png")
    splitSprite:setContentSize(CCSizeMake(380,4))
    splitSprite:setAnchorPoint(ccp(0.5,0))
    splitSprite:setPosition(ccp(m_infoBg:getContentSize().width * 0.5, 100))
    m_infoBg:addChild(splitSprite)
    
    local nameLabel = CCRenderLabel:create(uname .. "", g_sFontName, 23, 2, ccc3( 0x0c, 0x00, 0x0a), type_stroke)
    
    local nameColor = ccc3(0,0xe4,0xff)
    if(tonumber(uGender)==0)then
        nameColor = ccc3(0xf9,0x59,0xff)
    end
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccp(m_infoBg:getContentSize().width * 0.5, 120))
    m_infoBg:addChild(nameLabel)
    
    local lvSprite = CCSprite:create("images/common/lv.png")
    lvSprite:setAnchorPoint(ccp(0,1))
    lvSprite:setPosition(ccp(20, 85))
    m_infoBg:addChild(lvSprite)
    
    local lvLabel = CCRenderLabel:create(ulevel .. GetLocalizeStringBy("key_2469"), g_sFontName, 21, 1.5, ccc3( 0x89, 0x00, 0x1a), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    lvLabel:setPosition(ccp(60, 85))
    m_infoBg:addChild(lvLabel)
    
    local powerSprite = CCSprite:create("images/common/fight_value.png")
    powerSprite:setAnchorPoint(ccp(0, 0.5))
    powerSprite:setPosition(ccp(20, 25))
    m_infoBg:addChild(powerSprite)
    
    local powerLabel = CCRenderLabel:create(math.floor(tonumber(power)) .. "", g_sFontName, 21, 1.5, ccc3( 0x89, 0x00, 0x1a), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerLabel:setAnchorPoint(ccp(0, 0.5))
    powerLabel:setPosition(ccp(58, 25))
    m_infoBg:addChild(powerLabel)
    
    local dressId = nil
    if(dressInfo~=nil)then
        for key, value in pairs(dressInfo) do
            if(value~=nil and tonumber(value)~=nil)then
                dressId = tonumber(value)
            end
        end
    end
    local uGender = uGender==0 and 2 or uGender
    require "script/model/utils/HeroUtil"
    print("HeroUtil.getHeroIconByHTID:",htid, dressId, uGender)
    local imgSprite = HeroUtil.getHeroIconByHTID( htid, dressId, uGender )
    imgSprite:setAnchorPoint(ccp(0,0))
    imgSprite:setPosition(ccp(270, 2))
    m_infoBg:addChild(imgSprite)
    
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    touchPriority = touchPriority == nil and -431 or touchPriority
    menuBar:setTouchPriority(_touchPriority - 5)
    m_reportBg:addChild(menuBar,1)
    
    local image_n = "images/star/intimate/btn_blue_n.png"
    local image_h = "images/star/intimate/btn_blue_h.png"
    
    require "script/libs/LuaCC"
    local look_formation = LuaCC.create9ScaleMenuItem(image_n, image_h,CCSizeMake(170,64), GetLocalizeStringBy("key_8085"), ccc3(255,222,0))
    look_formation:setAnchorPoint(ccp(0.5,0.5))
    look_formation:setPosition(ccp(m_layerSize.width*0.26,200))
    look_formation:registerScriptTapHandler(lookFormation)
    menuBar:addChild(look_formation)

    
    local sendButton = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(170,64),GetLocalizeStringBy("key_1928"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.73,200))
    sendButton:registerScriptTapHandler(addFriendClick)
    
    menuBar:addChild(sendButton)
    
    local sendButton = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(170,64),GetLocalizeStringBy("key_2074"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.26,130))
    sendButton:registerScriptTapHandler(talkInPm)
    
    menuBar:addChild(sendButton)

    local shield_btn = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(170,64),GetLocalizeStringBy("key_8086"),ccc3(255,222,0))
    shield_btn:setAnchorPoint(ccp(0.5,0.5))
    shield_btn:setPosition(ccp(m_layerSize.width*0.73, 130))
    shield_btn:registerScriptTapHandler(callbackShield)
    
    menuBar:addChild(shield_btn)
    
    local leaveMessageButton = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(170,64), GetLocalizeStringBy("key_10013"),ccc3(255,222,0))
    leaveMessageButton:setAnchorPoint(ccp(0.5,0.5))
    leaveMessageButton:setPosition(ccp(m_layerSize.width*0.26,60))
    leaveMessageButton:registerScriptTapHandler(leaveMessageCallback)
    menuBar:addChild(leaveMessageButton)
    
    local back_btn = LuaCC.create9ScaleMenuItem(image_n,image_h,CCSizeMake(170,64),GetLocalizeStringBy("key_10014"),ccc3(255,222,0))
    back_btn:setAnchorPoint(ccp(0.5,0.5))
    back_btn:setPosition(ccp(m_layerSize.width*0.73, 60))
    back_btn:registerScriptTapHandler(closeClick)
    menuBar:addChild(back_btn)

    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.04, m_layerSize.height*1.04))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeClick)
    
    --m_ChatUserInfoLayer:setScale(scale)
    m_ChatUserInfoLayer:setTouchEnabled(true)
    m_ChatUserInfoLayer:registerScriptTouchHandler(cardLayerTouch,false, touchPriority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(m_ChatUserInfoLayer,2000,1251)
end

function leaveMessageCallback()
    if  tostring(UserModel.getUserUid()) == m_uid then
        SingleTip.showTip(GetLocalizeStringBy("key_10015"))
        return
    end
    if UserModel.getHeroLevel() >= 15 then
        require "script/ui/chat/LeaveMessageDialog"
        LeaveMessageDialog.show(m_uid, _touchPriority - 10, 2001)
    else
        SingleTip.showTip(GetLocalizeStringBy("key_10016"))
    end
end

function callbackShield()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if tostring(UserModel.getUserUid()) == m_uid then
        SingleTip.showTip(GetLocalizeStringBy("key_10017"))
        return
    end
    if ChatCache.isShieldedPlayer(m_uid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8087"))
        return
    end
    local tipText = GetLocalizeStringBy("key_8027")
    AlertTip.showAlert(tipText, shield, true, nil, GetLocalizeStringBy("key_8028"))
end

function shield(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    require "script/ui/friend/FriendService"
    local handleShield = function()
        
        SingleTip.showTip(GetLocalizeStringBy("key_8029"))
        m_ChatUserInfoLayer:removeFromParentAndCleanup(true)
    end
    FriendService.blackYou(m_uid, handleShield)
end

function lookFormation()
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(m_uid))
end

-- 退出场景，释放不必要资源
function release (...) 

end
