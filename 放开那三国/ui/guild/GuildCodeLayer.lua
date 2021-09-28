-- Filename: GuildCodeLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-22
-- Purpose: 该文件用于: 军团密码

module ("GuildCodeLayer", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/audio/AudioUtil"

function init()
	_bgLayer = nil
	yuanCodeBox = nil
	newCodeBox = nil
	confirmCodeBox = nil
end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function codeReturn(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    if cbFlag == "guild.modifyPasswd" then
    	print("djy")
    	print_t(dictData)
    	if dictData.ret == "err_passwd" then
    		AnimationTip.showTip(GetLocalizeStringBy("key_1891"))
    	elseif dictData.ret == "ok" then
    		AnimationTip.showTip(GetLocalizeStringBy("key_1391"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
    	end
    end
end

function confirmCb()
	if newCodeBox:getText() ~= confirmCodeBox:getText() then
		AnimationTip.showTip(GetLocalizeStringBy("key_2753"))
	elseif yuanCodeBox:getText() == "" then
		AnimationTip.showTip(GetLocalizeStringBy("key_3155"))
	elseif newCodeBox:getText() == "" then
		AnimationTip.showTip(GetLocalizeStringBy("key_2471"))
	elseif string.len(newCodeBox:getText()) < 4 then
		AnimationTip.showTip(GetLocalizeStringBy("key_3312"))
	else
		local createParams = CCArray:create()
        createParams:addObject(CCString:create(yuanCodeBox:getText()))
        createParams:addObject(CCString:create(newCodeBox:getText()))
		local createMes = RequestCenter.guild_modifyPasswd(codeReturn,createParams)
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

function showLayer()
	init()

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

	require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,454)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local guildCodeBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    guildCodeBg:setContentSize(mySize)
    -- guildCodeBg:setScale(myScale)
    guildCodeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    guildCodeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(guildCodeBg)
    setAdaptNode(guildCodeBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(guildCodeBg:getContentSize().width*0.5, guildCodeBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	guildCodeBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3130"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    guildCodeBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,250))
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,114))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    guildCodeBg:addChild(itemInfoSpite)

    local tiShi = CCLabelTTF:create(GetLocalizeStringBy("key_2369"), g_sFontName,24)
    tiShi:setColor(ccc3(0x78,0x25,0x00))
    tiShi:setAnchorPoint(ccp(0.5,0))
    tiShi:setPosition(ccp(guildCodeBg:getContentSize().width/2,guildCodeBg:getContentSize().height-80))
    guildCodeBg:addChild(tiShi)

    local yuanCode = CCSprite:create("images/guild/guildcode/yuancode.png")
    yuanCode:setPosition(ccp(180,itemInfoSpite:getContentSize().height*3/4))
    yuanCode:setAnchorPoint(ccp(1,0.5))
    itemInfoSpite:addChild(yuanCode)

    yuanCodeBox = CCEditBox:create(CCSizeMake(250,50), CCScale9Sprite:create("images/guild/guildcode/codebg.png"))
    yuanCodeBox:setPosition(ccp(200,itemInfoSpite:getContentSize().height*3/4))
    yuanCodeBox:setAnchorPoint(ccp(0,0.5))
    yuanCodeBox:setTouchPriority(-551)
    yuanCodeBox:setPlaceHolder(GetLocalizeStringBy("key_1295"))
    yuanCodeBox:setFont(g_sFontName,24)
	yuanCodeBox:setFontColor(ccc3(0x78,0x25,0x00))
	yuanCodeBox:setPlaceholderFontColor(ccc3(0x78,0x25,0x00))
	yuanCodeBox:setMaxLength(8)
	yuanCodeBox:setInputFlag(kEditBoxInputFlagPassword)
    itemInfoSpite:addChild(yuanCodeBox)

    local newCode = CCSprite:create("images/guild/guildcode/newcode.png")
    newCode:setPosition(ccp(180,itemInfoSpite:getContentSize().height/2))
    newCode:setAnchorPoint(ccp(1,0.5))
    itemInfoSpite:addChild(newCode)

    newCodeBox = CCEditBox:create(CCSizeMake(250,50), CCScale9Sprite:create("images/guild/guildcode/codebg.png"))
    newCodeBox:setPosition(ccp(200,itemInfoSpite:getContentSize().height/2))
    newCodeBox:setAnchorPoint(ccp(0,0.5))
    newCodeBox:setTouchPriority(-551)
    newCodeBox:setPlaceHolder(GetLocalizeStringBy("key_3396"))
    newCodeBox:setFont(g_sFontName,24)
	newCodeBox:setFontColor(ccc3(0x3e,0x3e,0x3e))
	newCodeBox:setPlaceholderFontColor(ccc3(0x3e,0x3e,0x3e))
	newCodeBox:setMaxLength(8)
	newCodeBox:setInputFlag(kEditBoxInputFlagPassword)
    itemInfoSpite:addChild(newCodeBox)

    local confirmCode = CCSprite:create("images/guild/guildcode/confirmcode.png")
    confirmCode:setPosition(ccp(180,itemInfoSpite:getContentSize().height*1/4))
    confirmCode:setAnchorPoint(ccp(1,0.5))
    itemInfoSpite:addChild(confirmCode)

    confirmCodeBox = CCEditBox:create(CCSizeMake(250,50), CCScale9Sprite:create("images/guild/guildcode/codebg.png"))
    confirmCodeBox:setPosition(ccp(200,itemInfoSpite:getContentSize().height*1/4))
    confirmCodeBox:setAnchorPoint(ccp(0,0.5))
    confirmCodeBox:setTouchPriority(-551)
    confirmCodeBox:setPlaceHolder(GetLocalizeStringBy("key_1559"))
    confirmCodeBox:setFont(g_sFontName,24)
	confirmCodeBox:setFontColor(ccc3(0x3e,0x3e,0x3e))
	confirmCodeBox:setPlaceholderFontColor(ccc3(0x3e,0x3e,0x3e))
	confirmCodeBox:setMaxLength(8)
	confirmCodeBox:setInputFlag(kEditBoxInputFlagPassword)
    itemInfoSpite:addChild(confirmCodeBox)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(guildCodeBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(guildCodeBg:getContentSize().width*0.25,35))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(confirmBtn)
    local confirmLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    confirmLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (confirmBtn:getContentSize().width - confirmLabel:getContentSize().width)/2
    local height = confirmBtn:getContentSize().height/2
    confirmLabel:setPosition(width,54)
    confirmBtn:addChild(confirmLabel)
    confirmBtn:registerScriptTapHandler(confirmCb)
end
