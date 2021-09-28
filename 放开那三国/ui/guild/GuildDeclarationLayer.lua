-- Filename: GuildDeclarationLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-22
-- Purpose: 该文件用于: 军团宣言，军团公告

module ("GuildDeclarationLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/ui/guild/GuildDataCache"

function init()
	_bgLayer = nil
	talkEditBox = nil
    _callType = nil
end

local function getStringLength( str)
    local strLen = 0
    local i =1
    while i<= #str do
        if(string.byte(str,i) > 127) then
            -- 汉字
            strLen = strLen + 1
            i= i+ 3
        else
            i =i+1
            strLen = strLen + 1
        end
    end
    return strLen
end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function sloganReturn(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    if cbFlag == "guild.modifySlogan" then
    	if dictData.ret.ret == "ok" then
    		AnimationTip.showTip(GetLocalizeStringBy("key_2793"))
    		GuildDataCache.setSlogan(dictData.ret.slogan)
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
    	end
    end
end

function postReturn(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if cbFlag == "guild.modifyPost" then
        if dictData.ret.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_1135"))
            GuildDataCache.setPost(dictData.ret.post)
            require "script/ui/guild/GuildMainLayer"
            GuildMainLayer.refreshNotice()
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
        end
    end
end

function confirmCb()
    if _callType == 1001 then  
        if tonumber(getStringLength(talkEditBox:getText())) > 20 then
            AnimationTip.showTip(GetLocalizeStringBy("key_1013"))
            return
        end  
    	local createParams = CCArray:create()
        if string.len(talkEditBox:getText()) == 0 then
            createParams:addObject(CCString:create(GetLocalizeStringBy("key_1593")))
        else
    	   createParams:addObject(CCString:create(talkEditBox:getText()))
        end
    	local createMes = RequestCenter.guild_modifySlogan(sloganReturn,createParams)
    	print(createMes)
    end
    if _callType == 1002 then
        if tonumber(getStringLength(talkEditBox:getText())) > 25 then
            AnimationTip.showTip(GetLocalizeStringBy("key_1225"))
            return
        end
        local createParams = CCArray:create()
        if string.len(talkEditBox:getText()) == 0 then
            createParams:addObject(CCString:create(GetLocalizeStringBy("key_1593")))
        else
           createParams:addObject(CCString:create(talkEditBox:getText()))
        end
        local createMes = RequestCenter.guild_modifyPost(postReturn,createParams)
        print(createMes)
    end
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
    else
        -- print("end")
	end
end

function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

function showLayer(callType)
	init()

    _callType = callType

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

	require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,454)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local guildDeclarationBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    guildDeclarationBg:setContentSize(mySize)
    guildDeclarationBg:setScale(myScale)
    guildDeclarationBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    guildDeclarationBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(guildDeclarationBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(guildDeclarationBg:getContentSize().width*0.5, guildDeclarationBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	guildDeclarationBg:addChild(titleBg)

	--奖励的标题文本
    local labelTitle
    if tonumber(callType) == 1001 then
	   labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2768"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
    end
    if tonumber(callType) == 1002 then
       labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1195"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
    end
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    guildDeclarationBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    talkEditBox = CCEditBox:create (CCSizeMake(450,270), CCScale9Sprite:create("images/guild/guildcode/codebg.png"))
    talkEditBox:setPosition(ccp(guildDeclarationBg:getContentSize().width/2, guildDeclarationBg:getContentSize().height-50))
	talkEditBox:setAnchorPoint(ccp(0.5, 1))
	
	local oldSlogan = GuildDataCache.getSlogan()
    local oldNotice = GuildDataCache.getPost()
	talkEditBox:setPlaceHolder(GetLocalizeStringBy("key_1593"))
    if tonumber(callType) == 1001 then
	   talkEditBox:setText(oldSlogan)
    end
    if tonumber(callType) == 1002 then
       talkEditBox:setText(oldNotice)
    end
	talkEditBox:setPlaceholderFontColor(ccc3(0x3e, 0x3e, 0x3e))
	talkEditBox:setMaxLength(200)
	talkEditBox:setReturnType(kKeyboardReturnTypeDone)
	talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    talkEditBox:setTouchPriority(-551)

    if(talkEditBox:getChildByTag(1001)~=nil)then
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setDimensions(CCSizeMake(440,250))
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
        tolua.cast(talkEditBox:getChildByTag(1001),"CCLabelTTF"):setColor(ccc3(0x3e,0x3e,0x3e))
    end
    
    if(talkEditBox:getChildByTag(1002)~=nil)then
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setDimensions(CCSizeMake(440,250))
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
        tolua.cast(talkEditBox:getChildByTag(1002),"CCLabelTTF"):setColor(ccc3(0x3e,0x3e,0x3e))
    end
    
    talkEditBox:setFont(g_sFontName,24)
    guildDeclarationBg:addChild(talkEditBox)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(guildDeclarationBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(guildDeclarationBg:getContentSize().width*0.25,35))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(confirmBtn)
    local confirmLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    confirmLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (confirmBtn:getContentSize().width - confirmLabel:getContentSize().width)/2
    local height = confirmBtn:getContentSize().height/2
    confirmLabel:setPosition(width,54)
    confirmBtn:addChild(confirmLabel)
    confirmBtn:registerScriptTapHandler(confirmCb)

    local wenzi
    if _callType == 1001 then
        wenzi = CCRenderLabel:create(GetLocalizeStringBy("key_2107"), g_sFontPangWa,20,2,ccc3(0x00,0x00,0x0),type_shadow)
    end
    if _callType == 1002 then
        wenzi = CCRenderLabel:create(GetLocalizeStringBy("key_3135"), g_sFontPangWa,20,2,ccc3(0x00,0x00,0x0),type_shadow)
    end
    wenzi:setColor(ccc3(0xff,0xe4,0x00))
    wenzi:setPosition(ccp(guildDeclarationBg:getContentSize().width*0.5,100))
    wenzi:setAnchorPoint(ccp(0.5,0))
    guildDeclarationBg:addChild(wenzi)
end
