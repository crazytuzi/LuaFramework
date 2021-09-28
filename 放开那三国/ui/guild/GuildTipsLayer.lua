-- Filename: GuildTipsLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-23
-- Purpose: 该文件用于: 提示

module ("GuildTipsLayer", package.seeall)

require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/ui/guild/MemberListLayer"

function init()
	_bgLayer = nil
    _kinds = nil
    _tipsString = nil
    _gid = nil
    _isVP = false
end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
    --MemberListLayer.refreshMemberTableView(true)
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

function quitReturn(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if (cbFlag == "guild.quitGuild") then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_1722"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            require "script/ui/guild/GuildImpl"
            GuildImpl.showLayer()
        elseif dictData.ret == "failed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_1177"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            require "script/ui/guild/GuildImpl"
            GuildImpl.showLayer()
        elseif(dictData.ret == "forbidden_citywar") then
            -- 城池争夺战报名结束前一小时至城池争夺战结束无法退出军团
            AnimationTip.showTip(GetLocalizeStringBy("key_2172"))
        elseif(dictData.ret == "forbidden_guildrob") then
            -- 粮草抢夺战期间无法退出军团
            AnimationTip.showTip(GetLocalizeStringBy("lic_1408"))
        elseif(dictData.ret == "forbidden_guildwar") then
            -- 军团争霸赛期间，不能使用此功能
            AnimationTip.showTip(GetLocalizeStringBy("lic_1488"))
        else
        end
    end
end

function goReturn(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if (cbFlag == "guild.kickMember")then
        if dictData.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_3072"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            require "script/ui/guild/GuildDataCache"
            GuildDataCache.addGuildMemberNum(-1)
            if _isVP == true then
                GuildDataCache.addGuildVPNum(-1)
            end
            MemberListLayer.refreshMemberTableView(true)
        elseif dictData.ret == "failed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2444"))
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            --require "script/ui/guild/GuildDataCache"
            --GuildDataCache.addGuildMemberNum(-1)
            MemberListLayer.refreshMemberTableView(true)
        elseif(dictData.ret == "forbidden_citywar") then
            -- 城池争夺战报名结束前一小时至城池争夺战结束无法将成员踢出军团
            AnimationTip.showTip(GetLocalizeStringBy("key_3020"))
        elseif(dictData.ret == "forbidden_guildrob") then
            -- 粮草抢夺战期间无法将成员踢出军团
            AnimationTip.showTip(GetLocalizeStringBy("lic_1409"))
        elseif(dictData.ret == "forbidden_guildwar") then
            -- 军团争霸赛期间，不能使用此功能
            AnimationTip.showTip(GetLocalizeStringBy("lic_1488"))
        else
        end
    end
end

function confirmCb()
    local returnValue
    --退出军团
    if _kinds == 1001 then
        returnValue = RequestCenter.guild_quitGuild(quitReturn,nil)
        print(returnValue)
    end
    if _kinds == 1002 then
        local createParams = CCArray:create()
        createParams:addObject(CCInteger:create(_gid))
        returnValue = RequestCenter.guild_kickMember(goReturn,createParams)
        print(returnValue)
    end
end

function showLayer(tipsString,kinds,gid,isVP)
	init()

    _kinds = kinds
    _tipsString = tipsString
    _gid = gid
    _isVP = isVP
	
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

	require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,350)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local guildTipsBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    guildTipsBg:setContentSize(mySize)
    guildTipsBg:setScale(myScale)
    guildTipsBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    guildTipsBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(guildTipsBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(guildTipsBg:getContentSize().width*0.5, guildTipsBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	guildTipsBg:addChild(titleBg)

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
    guildTipsBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local tips = CCRenderLabel:create(_tipsString, g_sFontPangWa,33,2,ccc3(0xff,0xff,0xff),type_stroke)
    tips:setAnchorPoint(ccp(0.5,0.5))
    tips:setColor(ccc3(0x78,0x25,0x00))
    tips:setPosition(ccp(guildTipsBg:getContentSize().width/2,guildTipsBg:getContentSize().height/2+50))
    guildTipsBg:addChild(tips)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(guildTipsBg:getContentSize().width*0.75,50))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(guildTipsBg:getContentSize().width*0.25,50))
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
