-- Filename: ConfirmCodeLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-23
-- Purpose: 该文件用于: 转让军团长确认密码

module ("ConfirmCodeLayer", package.seeall)

require "script/network/RequestCenter"
require "script/audio/AudioUtil"
require "script/ui/tip/AnimationTip"
require "script/ui/guild/MemberListLayer"

function init()
	_bgLayer = nil
	newCodeBox = nil
	_uid = nil
    _fid = nil
end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
    --MemberListLayer.refreshMemberTableView(true)
end

function returnBack(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if cbFlag == "guild.transPresident" then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_3277"))
            GuildDataCache.changeMineMemberType(0)
        elseif dictData.ret == "err_passwd" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2947"))
        elseif dictData.ret == "failed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2868"))
        elseif(dictData.ret == "forbidden_guildwar") then
            -- 军团争霸赛期间，不能使用此功能
            AnimationTip.showTip(GetLocalizeStringBy("lic_1488"))
        else
        end
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
        MemberListLayer.refreshMemberTableView(true)
    end
end

function dissMiss(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if cbFlag == "guild.dismiss" then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_3109"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            require "script/ui/guild/GuildImpl"
            GuildImpl.showLayer()
        elseif dictData.ret == "err_passwd" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2947"))
        elseif(dictData.ret == "forbidden_citywar") then
            -- 城池争夺战报名结束前一小时至城池争夺战结束无法解散军团
            AnimationTip.showTip(GetLocalizeStringBy("key_2146"))
        elseif(dictData.ret == "forbidden_guildrob") then
            -- 粮草抢夺战期间无法解散军团！
            AnimationTip.showTip(GetLocalizeStringBy("lic_1407"))
        elseif(dictData.ret == "forbidden_guildwar") then
            -- 军团争霸赛期间，不能使用此功能
            AnimationTip.showTip(GetLocalizeStringBy("lic_1488"))
        else
        end
    end
end

function confirmCb()
    if string.len(newCodeBox:getText()) == 0 then
        AnimationTip.showTip(GetLocalizeStringBy("key_3215"))
        return
    end
    if tonumber(_fid) == 2001 then
        local createParams = CCArray:create()
        createParams:addObject(CCInteger:create(_uid))
        createParams:addObject(CCString:create(newCodeBox:getText()))
	    local result = RequestCenter.guild_transPresident(returnBack,createParams)
        print(result)
    end
    if tonumber(_fid) == 2002 then
        local createParams = CCArray:create()
        createParams:addObject(CCString:create(newCodeBox:getText()))
        local result = RequestCenter.guild_dissmissGuild(dissMiss,createParams)
        print(result)
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

function showLayer(uID,fromId)
	init()

	_uid = uID
    _fid = fromId

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

	require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,350)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local confirmCodeBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    confirmCodeBg:setContentSize(mySize)
    confirmCodeBg:setScale(myScale)
    confirmCodeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    confirmCodeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(confirmCodeBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(confirmCodeBg:getContentSize().width*0.5, confirmCodeBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	confirmCodeBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    confirmCodeBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local plus = CCLabelTTF:create(GetLocalizeStringBy("key_1806"), g_sFontName,25)
    plus:setColor(ccc3(0x78,0x25,0x00))
    plus:setAnchorPoint(ccp(0,0.5))
    plus:setPosition(ccp(80,confirmCodeBg:getContentSize().height-100))
    confirmCodeBg:addChild(plus)

    newCodeBox = CCEditBox:create(CCSizeMake(confirmCodeBg:getContentSize().width-160,50), CCScale9Sprite:create("images/guild/guildcode/codebg.png"))
    newCodeBox:setPosition(ccp(confirmCodeBg:getContentSize().width/2,confirmCodeBg:getContentSize().height/2))
    newCodeBox:setAnchorPoint(ccp(0.5,0.5))
    newCodeBox:setTouchPriority(-551)
    newCodeBox:setPlaceHolder(GetLocalizeStringBy("key_3233"))
    newCodeBox:setFont(g_sFontName,24)
	newCodeBox:setFontColor(ccc3(0x3e,0x3e,0x3e))
	newCodeBox:setPlaceholderFontColor(ccc3(0x3e,0x3e,0x3e))
	newCodeBox:setMaxLength(8)
	newCodeBox:setInputFlag(kEditBoxInputFlagPassword)
    confirmCodeBg:addChild(newCodeBox)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(confirmCodeBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(confirmCodeBg:getContentSize().width*0.25,35))
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
