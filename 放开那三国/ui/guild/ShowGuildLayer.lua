-- Filename: ShowGuildLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-20
-- Purpose: 该文件用于: 创建军团界面

module ("ShowGuildLayer", package.seeall)

require "script/model/user/UserModel"
require "script/ui/guild/GuildUtil"
require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/audio/AudioUtil"

function init()
	_bgLayer = nil
    nameEdit = nil
    method = nil
    zorder = nil
    priority = nil
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
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
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
    if cbFlag == "guild.createGuild" then
        if dictData.ret.ret == "ok" then
            AnimationTip.showTip(GetLocalizeStringBy("key_1522"))
            if method == 1 then
                UserModel.addGoldNumber(tonumber(-GuildUtil.getCreateNeedGold()))
            else
                UserModel.addSilverNumber(tonumber(-GuildUtil.getCreateNeedSilver()))
            end
            _bgLayer:removeFromParentAndCleanup(true)
            _bgLayer = nil
            require "script/ui/guild/GuildImpl"
            GuildImpl.showLayer()
        elseif dictData.ret.ret == "used" then
            AnimationTip.showTip(GetLocalizeStringBy("key_1515"))
        elseif dictData.ret.ret == "blank" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2917"))
        elseif dictData.ret.ret == "exceed" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2059"))
        elseif dictData.ret.ret == "harmony" then
            AnimationTip.showTip(GetLocalizeStringBy("key_3166"))
        end
        --local guildInfo = dictData.info
    end
end

function goldCreate()
    method = 1
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local userInfo = UserModel.getUserInfo()
	if tonumber(userInfo.gold_num) < tonumber(GuildUtil.getCreateNeedGold()) then
        --AnimationTip.showTip(GetLocalizeStringBy("key_1619"))
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
    else
        local guildName = nameEdit:getText()
        if guildName == "" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2103"))
        elseif getStringLength(guildName) > 6 then
            AnimationTip.showTip(GetLocalizeStringBy("key_1775"))
        elseif GuildUtil.checkSpace(guildName) then
            AnimationTip.showTip(GetLocalizeStringBy("key_2917"))
        else
            local createParams = CCArray:create()
            createParams:addObject(CCString:create(nameEdit:getText()))
            createParams:addObject(CCInteger:create(1))
            local createMes = RequestCenter.guild_createGuild(fnHandlerOfNetwork,createParams)
            print(createMes)
        end
    end
end

function silverCreate()
    method = 0
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local userInfo = UserModel.getUserInfo()
    if tonumber(userInfo.silver_num) < tonumber(GuildUtil.getCreateNeedSilver()) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1820"))
    else
        local guildName = nameEdit:getText()
        if guildName == "" then
            AnimationTip.showTip(GetLocalizeStringBy("key_2103"))
        elseif getStringLength(guildName) > 6 then
            print("wulala",getStringLength(guildName))
            AnimationTip.showTip(GetLocalizeStringBy("key_1775"))
        elseif GuildUtil.checkSpace(guildName) then
            AnimationTip.showTip(GetLocalizeStringBy("key_2917"))
        else
            local createParams = CCArray:create()
            createParams:addObject(CCString:create(nameEdit:getText()))
            createParams:addObject(CCInteger:create(0))
            local createMes = RequestCenter.guild_createGuild(fnHandlerOfNetwork,createParams)
            print(createMes)
        end
    end
end

function showLayer(tZorder,tPriority)
	init()

    if tZorder == nil then
        zorder = 1500
    else
        zorder = tZorder
    end
    if tPriority == nil then
        priority = -550
    else
        priority = tPriority
    end
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,zorder)

	require "script/ui/main/MainScene"
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,454)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local createGuildBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    createGuildBg:setContentSize(mySize)
    createGuildBg:setScale(myScale)
    createGuildBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    createGuildBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(createGuildBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(createGuildBg:getContentSize().width*0.5, createGuildBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	createGuildBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2941"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	   -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(priority-1)
    createGuildBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,215))
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,184))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    createGuildBg:addChild(itemInfoSpite)

    local explainLabel = CCSprite:create("images/guild/createGuild/wenzi.png")
    explainLabel:setPosition(ccp(mySize.width*0.5,324))
    explainLabel:setAnchorPoint(ccp(0.5,0))
    createGuildBg:addChild(explainLabel)

    nameEdit = CCEditBox:create(CCSizeMake(278,46),CCScale9Sprite:create("images/guild/createGuild/shurukuang.png"))
    nameEdit:setPosition(ccp(mySize.width*0.5,270))
    nameEdit:setAnchorPoint(ccp(0.5,1))
    nameEdit:setTouchPriority(priority-1)
    nameEdit:setPlaceHolder(GetLocalizeStringBy("key_1213"))
	nameEdit:setFontColor(ccc3(0x3e,0x3e,0x3e))
	nameEdit:setPlaceholderFontColor(ccc3(0x3e,0x3e,0x3e))
	nameEdit:setMaxLength(20)
    nameEdit:setFont(g_sFontName,24)
    nameEdit:setReturnType(kKeyboardReturnTypeDone)
    nameEdit:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    createGuildBg:addChild(nameEdit)

	local buttomN = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	buttomN:setContentSize(CCSizeMake(200,64))

	local buttomH = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	buttomH:setContentSize(CCSizeMake(200,64))

	local goldBtn = CCMenuItemSprite:create(buttomN, buttomH)
    goldBtn:setPosition(ccp(createGuildBg:getContentSize().width*0.3,90))
    goldBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(goldBtn)
    local goldBtnLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3163"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    goldBtnLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (goldBtn:getContentSize().width - goldBtnLabel:getContentSize().width)/2
    local height = goldBtn:getContentSize().height/2
    goldBtnLabel:setPosition(width,54)
    goldBtn:addChild(goldBtnLabel)
    goldBtn:registerScriptTapHandler(goldCreate)

    local buttomN1 = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	buttomN1:setContentSize(CCSizeMake(200,64))

	local buttomH1 = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	buttomH1:setContentSize(CCSizeMake(200,64))

    local silverBtn = CCMenuItemSprite:create(buttomN1, buttomH1)
    silverBtn:setPosition(ccp(createGuildBg:getContentSize().width*0.7,90))
    silverBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(silverBtn)
    local silverBtnLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1959"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    silverBtnLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (silverBtn:getContentSize().width - silverBtnLabel:getContentSize().width)/2
    local height = silverBtn:getContentSize().height/2
    silverBtnLabel:setPosition(width,54)
    silverBtn:addChild(silverBtnLabel)
    silverBtn:registerScriptTapHandler(silverCreate)

    local goldSprite = CCSprite:create("images/common/gold.png")
    local goldNum = CCRenderLabel:create(" " .. GuildUtil.getCreateNeedGold(), g_sFontName,25,2,ccc3(0x00,0x00,0x00),type_shadow)
    goldNum:setColor(ccc3(0xff,0xf6,0x00))
    local goldWenZi = CCRenderLabel:create(GetLocalizeStringBy("key_2876"), g_sFontName,25,2,ccc3(0x00,0x00,0x00),type_shadow)
    goldWenZi:setColor(ccc3(0xff,0xff,0xff))

    require "script/utils/BaseUI"
    local aleteNode1 = BaseUI.createHorizontalNode({goldSprite, goldNum, goldWenZi})
	aleteNode1:setAnchorPoint(ccp(0.5, 0))
	aleteNode1:setPosition(ccp(createGuildBg:getContentSize().width*0.3, 50))
	createGuildBg:addChild(aleteNode1)

	local silverSprite = CCSprite:create("images/common/coin.png")
    local silverNum = CCRenderLabel:create(" " .. GuildUtil.getCreateNeedSilver(), g_sFontName,25,2,ccc3(0x00,0x00,0x00),type_shadow)
    silverNum:setColor(ccc3(0xff,0xf6,0x00))
    local silverWenZi = CCRenderLabel:create(GetLocalizeStringBy("key_2019"), g_sFontName,25,2,ccc3(0x00,0x00,0x00),type_shadow)
    silverWenZi:setColor(ccc3(0xff,0xff,0xff))

    local aleteNode2 = BaseUI.createHorizontalNode({silverSprite, silverNum, silverWenZi})
	aleteNode2:setAnchorPoint(ccp(0.5, 0))
	aleteNode2:setPosition(ccp(createGuildBg:getContentSize().width*0.7, 50))
	createGuildBg:addChild(aleteNode2)
end
