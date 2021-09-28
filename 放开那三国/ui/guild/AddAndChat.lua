-- FileName: AddAndChat.lua 
-- Author: Li Cong 
-- Date: 13-12-31 
-- Purpose: function description of module 


module("AddAndChat", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/utils/extern"

local IMG_PATH = "images/battle/report/"				-- 图片主路径

local m_AddAndChatLayer
local talkEditBox
local m_uname
local m_ulevel
local m_uid

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function closeClick()
    
    --点击音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChildByTag(1251,true)
    --print("==========closeClick===============")
end

function addFriendClickCallback(cbFlag, dictData, bRet )
	
	if(dictData.err == "ok") then
        --print("addFriendClickCallback dictData.ret",dictData.ret)
        local dataRet = dictData.ret
        -- 等待确认
        require "script/ui/tip/AnimationTip"
        if(dataRet == "applied")then
            local str = GetLocalizeStringBy("key_3243")
            AnimationTip.showTip(str)
        elseif(dataRet == "reach_maxnum")then
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("key_2345")
            AnimationTip.showTip(str)
        elseif( dataRet == "alreadyfriend")then
            local str = GetLocalizeStringBy("key_3324")
            AnimationTip.showTip(str)
        elseif(dataRet == "ok")then
            AnimationTip.showTip( GetLocalizeStringBy("key_2558"))
        elseif(dataRet == "black")then
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("lic_1061")
            AnimationTip.showTip(str)
            return
        elseif(dataRet == "beblack")then
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("lic_1055")
            AnimationTip.showTip(str)
            return
        else
            return
        end
	end
end

function addFriendClick()
    
    RequestCenter.friend_applyFriend(addFriendClickCallback,Network.argsHandler(m_uid,""))
end

function talkInPm()
    require "script/ui/chat/ChatMainLayer"
    ChatMainLayer.showChatLayer(2)
    ChatMainLayer.setTargetName(m_uname)
    --ChatMainLayer.pmClick()
    closeClick()
end

-- 获得卡牌层
function showAddAndChatLayer(uname,ulevel,power,icon,uid,uGender,zOrderNum,info_layer_priority)
    local zorde = zOrderNum or 999
    local menu_priority = info_layer_priority or -431
    local layer_priority = info_layer_priority or -430
    -- 是自己的话 弹详细信息面板
    require "script/model/user/UserModel"
    if(tonumber(uid)==tonumber(UserModel.getUserInfo().uid))then
        require "script/ui/main/AvatarInfoLayer"
        if AvatarInfoLayer.getObject() == nil then
            local scene = CCDirector:sharedDirector():getRunningScene()
            local ccLayerAvatarInfo = AvatarInfoLayer.createLayer()
            scene:addChild(ccLayerAvatarInfo,zorde,3122)
        end
        return
    end

    -- 不是自己加好友
    m_uname = uname
    m_ulevel = ulevel
    m_uid = uid
    uGender = uGender==nil and 0 or uGender
    require "script/ui/main/MainScene"
    
    local m_layerSize = CCSizeMake(420,250)
    
    local scale = MainScene.elementScale
    
    m_AddAndChatLayer = CCLayerColor:create(ccc4(11,11,11,166))
    local m_reportInfoLayer = CCLayer:create()
    m_reportInfoLayer:setScale(scale)
    m_reportInfoLayer:setPosition((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,CCDirector:sharedDirector():getWinSize().height*0.4)
    m_AddAndChatLayer:addChild(m_reportInfoLayer)
    
    
    local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/hero/bg_ng.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0,0))
    m_reportBg:setPosition(0,0)
    m_reportInfoLayer:addChild(m_reportBg)
    
    local m_infoBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    m_infoBg:setContentSize(CCSizeMake(m_layerSize.width*0.9,m_layerSize.height*0.55))
    m_infoBg:setAnchorPoint(ccp(0,0))
    m_infoBg:setPosition(m_layerSize.width*0.05,m_layerSize.height*0.35)
    m_reportBg:addChild(m_infoBg)
    
    local splitSprite = CCScale9Sprite:create(CCRectMake(30, 1, 56, 2),"images/chat/spliter.png")
    splitSprite:setContentSize(CCSizeMake(380,4))
    splitSprite:setAnchorPoint(ccp(0.5,0))
    splitSprite:setPosition(m_layerSize.width*0.5, m_layerSize.height*0.72)
    m_reportBg:addChild(splitSprite)
    
    local nameLabel = CCRenderLabel:create(uname .. "", g_sFontName, 23, 2, ccc3( 0x0c, 0x00, 0x0a), type_stroke)
    
    local nameColor = ccc3(0,0xe4,0xff)
    if(tonumber(uGender)==0)then
        nameColor = ccc3(0xf9,0x59,0xff)
    end
    nameLabel:setColor(nameColor)
    --nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition((m_layerSize.width-nameLabel:getContentSize().width)/2,m_layerSize.height*0.85)
    m_reportBg:addChild(nameLabel)
    
    local lvSprite = CCSprite:create("images/common/lv.png")
    lvSprite:setAnchorPoint(ccp(0,1))
    lvSprite:setPosition(m_layerSize.width*0.1,m_layerSize.height*0.65)
    m_reportBg:addChild(lvSprite)
    
    local lvLabel = CCRenderLabel:create(ulevel .. GetLocalizeStringBy("key_2469"), g_sFontName, 21, 1.5, ccc3( 0x89, 0x00, 0x1a), type_stroke)
    lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    --lvLabel:setAnchorPoint(ccp(0,1))
    lvLabel:setPosition(m_layerSize.width*0.2,m_layerSize.height*0.66)
    m_reportBg:addChild(lvLabel)
    
    local powerSprite = CCSprite:create("images/common/fight_value.png")
    powerSprite:setAnchorPoint(ccp(0,1))
    powerSprite:setPosition(m_layerSize.width*0.1,m_layerSize.height*0.52)
    m_reportBg:addChild(powerSprite)
    
    local powerLabel = CCRenderLabel:create(math.floor(tonumber(power)) .. "", g_sFontName, 21, 1.5, ccc3( 0x89, 0x00, 0x1a), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    --powerLabel:setAnchorPoint(ccp(0,1))
    powerLabel:setPosition(m_layerSize.width*0.3,m_layerSize.height*0.5)
    m_reportBg:addChild(powerLabel)
    
    local imgSprite = icon
    imgSprite:setAnchorPoint(ccp(0,0))
    imgSprite:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.38))
    m_reportBg:addChild(imgSprite)
    
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    
    menuBar:setTouchPriority(menu_priority-1)
    m_reportBg:addChild(menuBar,1)
    
    require "script/libs/LuaCC"
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_1928"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.3,m_layerSize.height*0.2))
    sendButton:registerScriptTapHandler(addFriendClick)
    
    menuBar:addChild(sendButton)
    
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_2074"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.2))
    sendButton:registerScriptTapHandler(talkInPm)
    
    menuBar:addChild(sendButton)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.04, m_layerSize.height*1.04))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeClick)
    
    --m_AddAndChatLayer:setScale(scale)
    m_AddAndChatLayer:setTouchEnabled(true)
    m_AddAndChatLayer:registerScriptTouchHandler(cardLayerTouch,false,layer_priority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    
    scene:addChild(m_AddAndChatLayer,zorde,1251)
end

-- 退出场景，释放不必要资源
function release (...) 

end
