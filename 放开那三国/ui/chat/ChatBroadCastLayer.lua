-- Filename: ChatBroadCastLayer.lua
-- Author: k
-- Date: 2013-08-06
-- Purpose: 广播

require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("ChatBroadCastLayer", package.seeall)

local IMG_PATH = "images/battle/report/"				-- 图片主路径

local m_ChatBroadCastLayer
local talkEditBox
local hornNumberLabel
local chatInterface
local chatItemId

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function closeClick()
    
    --点击音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChildByTag(1241,true)
    --print("==========closeClick===============")
end
function sendClickCallback(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
        print("dictData.ret",dictData.ret)
		if(dictData.ret == "") then
            
            --print("==========sendClickCallback dictData.ret===============")
            --require "script/utils/LuaUtil"
			--print_table("sendClickCallback",dictData)
            
            talkEditBox:setText("")
            
            local number = tonumber(hornNumberLabel:getString())
            print("number",number)
            if(nil==number)then
                
                hornNumberLabel:setString("0")
            else
                hornNumberLabel:setString("" .. number-1)
            end
            
            else
            
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_3395"), nil, false, nil)
		end
	end
    print("==========sendClickCallback===============")
end

function sendClick()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "db/DB_Chat_interface"
    require "script/model/user/UserModel"
    local chatInterface = DB_Chat_interface.getDataById(2)
    print("sendClick:",UserModel.getUserInfo().level,UserModel.getUserInfo().vip)
    if(chatInterface~=nil and (chatInterface.lv_require == nil or chatInterface.lv_require<=tonumber(UserModel.getUserInfo().level)) and (chatInterface.vip_lv_require == nil or chatInterface.vip_lv_require<=tonumber(UserModel.getUserInfo().vip)))then
        
        --判断物品是否够
        require "script/ui/item/ItemUtil"
        local itemInfo = ItemUtil.getCacheItemInfoBy(chatItemId)
        --print_table("itemInfo",itemInfo)
        if((itemInfo == nil or itemInfo.item_num == 0) and chatItemId ~= 0)then
            
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip( GetLocalizeStringBy("key_2764"))
            return
        end
        
        if(talkEditBox:getText()~=nil and talkEditBox:getText()~="" )then
            RequestCenter.chat_sendBroadCast(sendClickCallback,Network.argsHandler(talkEditBox:getText(),2))
            else
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_2349"), nil, false, nil)
        end
        else
        
        require "script/ui/tip/AlertTip"
        local myTip = ""
        if(chatInterface.lv_require~=nil)then
            myTip = myTip .. GetLocalizeStringBy("key_1399") .. chatInterface.lv_require
        end
        if(chatInterface.vip_lv_require~=nil)then
            myTip = myTip .. GetLocalizeStringBy("key_1199") .. chatInterface.vip_lv_require
        end
        AlertTip.showAlert(myTip, nil, false, nil)
        
        --AlertTip.showAlert( GetLocalizeStringBy("key_2805") .. chatInterface.lv_require .. GetLocalizeStringBy("key_1933") .. chatInterface.vip_lv_require, nil, false, nil)
    end
    print("==========sendClick===============")
end

-- 获得卡牌层
function showChatBroadCastLayer()
    require "script/ui/main/MainScene"
    
    local m_layerSize = CCSizeMake(420,250)
    
    local scale = MainScene.elementScale
    
    m_ChatBroadCastLayer = CCLayerColor:create(ccc4(11,11,11,166))
    local m_reportInfoLayer = CCLayer:create()
    m_reportInfoLayer:setScale(scale)
    m_reportInfoLayer:setPosition(ccp((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,CCDirector:sharedDirector():getWinSize().height*0.4))
    m_ChatBroadCastLayer:addChild(m_reportInfoLayer)
    
    
    local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/hero/bg_ng.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0,0))
    m_reportBg:setPosition(ccp(0,0))
    m_reportInfoLayer:addChild(m_reportBg)
    
    local inputLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2581"),g_sFontName,23)
    inputLabel:setAnchorPoint(ccp(0,0))
    inputLabel:setPosition(ccp(m_layerSize.width*0.1, m_layerSize.height*0.73))
    inputLabel:setColor(ccc3(0x00,0x6d,0x2f))
    m_reportBg:addChild(inputLabel)
    
    local cost1Label = CCLabelTTF:create(GetLocalizeStringBy("key_1508"),g_sFontName,23)
    cost1Label:setAnchorPoint(ccp(0,0))
    cost1Label:setPosition(ccp(m_layerSize.width*0.1, m_layerSize.height*0.34))
    cost1Label:setColor(ccc3(0x78,0x25,0x00))
    m_reportBg:addChild(cost1Label)
    
    local hornDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1564"),g_sFontName,20)
    hornDescLabel:setAnchorPoint(ccp(0,0))
    hornDescLabel:setPosition(ccp(m_layerSize.width*0.5, m_layerSize.height*0.35))
    hornDescLabel:setColor(ccc3(0x00,0x6d,0x2f))
    m_reportBg:addChild(hornDescLabel)
    
    require "db/DB_Chat_interface"
    chatInterface = DB_Chat_interface.getDataById(2)
    if(chatInterface ==nil or chatInterface.chat_cost_goods==nil or chatInterface.chat_cost_goods==nil)then
        chatItemId = 0
    else
        chatItemId = tonumber(lua_string_split(chatInterface.chat_cost_goods,"|")[1])
    end
    --chatItemId = tonumber(lua_string_split(chatInterface.chat_cost_goods,"|")[1])
    print("chatItemId",chatItemId)
    require "script/ui/item/ItemUtil"
    local itemInfo = ItemUtil.getCacheItemInfoBy(chatItemId)
    print_table("itemInfo",itemInfo)
    local hornNumber = 0
    if(itemInfo ~= nil and itemInfo.item_num ~= nil and tonumber(itemInfo.item_num) ~= 0)then
        hornNumber = itemInfo.item_num
    end
    
     hornNumberLabel = CCLabelTTF:create("" .. hornNumber,g_sFontName,20)
    hornNumberLabel:setAnchorPoint(ccp(0,0))
    hornNumberLabel:setPosition(ccp(m_layerSize.width*0.8, m_layerSize.height*0.35))
    hornNumberLabel:setColor(ccc3(0x00,0x6d,0x2f))
    m_reportBg:addChild(hornNumberLabel)
    
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-431)
    m_reportBg:addChild(menuBar)
    
    talkEditBox = CCEditBox:create (CCSizeMake(370,50), CCScale9Sprite:create("images/chat/input_bg.png"))
	talkEditBox:setPosition(ccp(m_layerSize.width*0.06, m_layerSize.height*0.6))
	talkEditBox:setAnchorPoint(ccp(0, 0.5))
	talkEditBox:setPlaceHolder(GetLocalizeStringBy("key_2499"))
	talkEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
	talkEditBox:setMaxLength(30)
	talkEditBox:setReturnType(kKeyboardReturnTypeDone)
	talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    talkEditBox:setTouchPriority(-432)
    
    m_reportBg:addChild(talkEditBox)
    
    require "script/libs/LuaCC"
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_1985"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.3,m_layerSize.height*0.2))
    sendButton:registerScriptTapHandler(sendClick)
    
    menuBar:addChild(sendButton)
    
    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_1202"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.2))
    sendButton:registerScriptTapHandler(closeClick)
    
    menuBar:addChild(sendButton)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(m_layerSize.width*1.04, m_layerSize.height*1.04))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeClick)
    
    --m_ChatBroadCastLayer:setScale(scale)
    m_ChatBroadCastLayer:setTouchEnabled(true)
    m_ChatBroadCastLayer:registerScriptTouchHandler(cardLayerTouch,false,-430,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(m_ChatBroadCastLayer,999,1241)
end

-- 退出场景，释放不必要资源
function release (...) 

end
