-- Filename: GuildImpeachmentLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-23
-- Purpose: 该文件用于: 弹劾军团长

module ("GuildImpeachmentLayer", package.seeall)

require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/audio/AudioUtil"
require "script/network/RequestCenter"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/MemberListLayer"

function init()
	_bgLayer = nil
end

function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function fnHandlerOfNetwork(cbFlag, dictData, bRet)
    if not bRet then
        return
    end
    if (cbFlag == "guild.impeach") and (dictData.ret == "ok") then
        local guildInfo = GuildDataCache.getGuildInfo()
        local guildName = guildInfo.guild_name
        AnimationTip.showTip(GetLocalizeStringBy("key_3351") .. guildName .. GetLocalizeStringBy("key_2375"))
        UserModel.addGoldNumber(tonumber(-GuildUtil.getCostForAccuse()))
        MemberListLayer.refreshMemberTableView(true)
        -- 关闭
        closeCb()
    end
end

function confirmCb()
    local userInfo = UserModel.getUserInfo()
    if UserModel.getGoldNumber() < tonumber(GuildUtil.getCostForAccuse()) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3288"))
    else
        local createMes = RequestCenter.guild_impeach(fnHandlerOfNetwork,nil)
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
	local mySize = CCSizeMake(605,300)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local accuseBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    accuseBg:setContentSize(mySize)
    accuseBg:setScale(myScale)
    accuseBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    accuseBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(accuseBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(accuseBg:getContentSize().width*0.5, accuseBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	accuseBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1740"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    accuseBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local plus = CCLabelTTF:create(GetLocalizeStringBy("key_1162"), g_sFontName,25)
    plus:setColor(ccc3(0x78,0x25,0x00))
    plus:setPosition(ccp(accuseBg:getContentSize().width/2,accuseBg:getContentSize().height-80))
    plus:setAnchorPoint(ccp(0.5,1))
    accuseBg:addChild(plus)

    require "script/ui/guild/GuildUtil"
    local plus1 = CCLabelTTF:create(GetLocalizeStringBy("key_1088"), g_sFontName,25)
    plus1:setColor(ccc3(0x78,0x25,0x00))
    local plus2 = CCRenderLabel:create(GuildUtil.getCostForAccuse(), g_sFontName,25,1,ccc3(0x00,0x00,0x0),type_stroke)
    plus2:setColor(ccc3(0xff,0xf6,0x00))
    local plus3 = CCLabelTTF:create(GetLocalizeStringBy("key_3251"), g_sFontName,25)
    plus3:setColor(ccc3(0x78,0x25,0x00))

    require "script/utils/BaseUI"
    local aleteNode = BaseUI.createHorizontalNode({plus1, plus2, plus3})
    aleteNode:setAnchorPoint(ccp(0.5, 1))
    aleteNode:setPosition(ccp(accuseBg:getContentSize().width/2, accuseBg:getContentSize().height-100-plus:getContentSize().height))
    accuseBg:addChild(aleteNode)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(accuseBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(accuseBg:getContentSize().width*0.25,35))
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
