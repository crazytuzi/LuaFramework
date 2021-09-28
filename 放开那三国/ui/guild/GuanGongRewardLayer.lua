-- Filename: GuanGongRewardLayer.lua
-- Author: zhang zihang
-- Date: 2013-12-24
-- Purpose: 该文件用于: 关公殿奖励

module ("GuanGongRewardLayer", package.seeall)

require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "db/DB_Legion_feast"
require "script/ui/guild/GuildDataCache"

function init()
	_myScale = nil
	_mySize = nil

	_bgLayer = nil

    nowLevel = 0
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		-- print("began")
	    return true
    elseif (eventType == "moved") then
  
    else
        -- print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -435, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then

		_bgLayer:unregisterScriptTouchHandler()
	end
end

function createBackGround()
	-- 背景

    local rewardNum = 0

	local guanGongInfo = DB_Legion_feast.getDataById(1)

	local userInfo = UserModel.getUserInfo()
	print_t(userInfo)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local guanGongGiftBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    guanGongGiftBg:setContentSize(_mySize)
    guanGongGiftBg:setScale(0.01*_myScale)
    guanGongGiftBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    guanGongGiftBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(guanGongGiftBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(guanGongGiftBg:getContentSize().width*0.5, guanGongGiftBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	guanGongGiftBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1809"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    guanGongGiftBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_mySize.width*1.03,_mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local explainLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1678"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
    explainLabel:setColor(ccc3(0xff,0xf0,0x00))
    explainLabel:setPosition(ccp(40,guanGongGiftBg:getContentSize().height-100))
    explainLabel:setAnchorPoint(ccp(0,0))
    guanGongGiftBg:addChild(explainLabel)

    local whiteBg1 = CCScale9Sprite:create("images/common/labelbg_white.png")
    whiteBg1:setContentSize(CCSizeMake(490,37))
    whiteBg1:setAnchorPoint(ccp(0.5,1))
    whiteBg1:setPosition(ccp(guanGongGiftBg:getContentSize().width/2,guanGongGiftBg:getContentSize().height-110))
    guanGongGiftBg:addChild(whiteBg1)

    local whiteBg2 = CCScale9Sprite:create("images/common/labelbg_white.png")
    whiteBg2:setContentSize(CCSizeMake(490,37))
    whiteBg2:setAnchorPoint(ccp(0.5,1))
    whiteBg2:setPosition(ccp(guanGongGiftBg:getContentSize().width/2,guanGongGiftBg:getContentSize().height-150))
    guanGongGiftBg:addChild(whiteBg2)

    local growTili = math.floor(guanGongInfo.baseExecution+guanGongInfo.growExecution*nowLevel/100)

    local tili = CCRenderLabel:create(GetLocalizeStringBy("key_1299"), g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_shadow)
    tili:setColor(ccc3(0xff,0xf0,0x00))
    tili:setAnchorPoint(ccp(0.5,0.5))
    tili:setPosition(ccp(160,whiteBg1:getContentSize().height/2))
    whiteBg1:addChild(tili)
    local yuanTili = CCRenderLabel:create(userInfo.execution-growTili, g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_shadow)
    yuanTili:setColor(ccc3(0xff,0xf6,0x00))
    yuanTili:setAnchorPoint(ccp(0.5,0.5))
    yuanTili:setPosition(ccp(220,whiteBg1:getContentSize().height/2))
    whiteBg1:addChild(yuanTili)
    local arrow1 = CCSprite:create("images/common/arrow.png")
    arrow1:setAnchorPoint(ccp(0.5,0.5))
    arrow1:setPosition(ccp(280,whiteBg1:getContentSize().height/2))
    whiteBg1:addChild(arrow1)

    --local growTili = math.floor(guanGongInfo.baseExecution+guanGongInfo.growExecution*nowLevel/100)

    print("###",growTili)

    local xinTili = CCRenderLabel:create(userInfo.execution, g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_shadow)
    xinTili:setColor(ccc3(0xff,0xf6,0x00))
    xinTili:setAnchorPoint(ccp(0.5,0.5))
    xinTili:setPosition(ccp(340,whiteBg1:getContentSize().height/2))
    whiteBg1:addChild(xinTili)

    --UserModel.addEnergyValue(growTili)

    --[[local aleteNode1 = BaseUI.createHorizontalNode({tili, yuanTili, arrow1,xinTili})
	aleteNode1:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode1:setPosition(ccp(whiteBg1:getContentSize().width/2, whiteBg1:getContentSize().height/2))
	whiteBg1:addChild(aleteNode1)]]

	local naili = CCRenderLabel:create(GetLocalizeStringBy("key_2268"), g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_shadow)
    naili:setColor(ccc3(0xff,0x24,0xc0))
    naili:setAnchorPoint(ccp(0.5,0.5))
    naili:setPosition(ccp(160,whiteBg2:getContentSize().height/2))
    whiteBg2:addChild(naili)
    local yuanNaili = CCRenderLabel:create(userInfo.stamina, g_sFontName,24,1,ccc3(0x00,0x00,0x00),type_shadow)
    yuanNaili:setColor(ccc3(0xff,0xf6,0x00))
    yuanNaili:setAnchorPoint(ccp(0.5,0.5))
    yuanNaili:setPosition(ccp(220,whiteBg2:getContentSize().height/2))
    whiteBg2:addChild(yuanNaili)
    local arrow2 = CCSprite:create("images/common/arrow.png")
    arrow2:setAnchorPoint(ccp(0.5,0.5))
    arrow2:setPosition(ccp(280,whiteBg2:getContentSize().height/2))
    whiteBg2:addChild(arrow2)

    local growNaili = math.floor(guanGongInfo.baseStamina+guanGongInfo.growStamina*nowLevel/100)

    print("###2",growNaili)

    local xinNaili = CCRenderLabel:create(userInfo.stamina+growNaili, g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_shadow)
    xinNaili:setColor(ccc3(0xff,0xf6,0x00))
    xinNaili:setAnchorPoint(ccp(0.5,0.5))
    xinNaili:setPosition(ccp(340,whiteBg2:getContentSize().height/2))
    whiteBg2:addChild(xinNaili)

    if math.floor(guanGongInfo.baseStamina+guanGongInfo.growStamina*nowLevel/100) == 0 then
        rewardNum = rewardNum+1
        whiteBg2:setVisible(false)
    end

    if math.floor(guanGongInfo.baseExecution+guanGongInfo.growExecution*nowLevel/100) == 0 then
        rewardNum = rewardNum+1
        whiteBg1:setVisible(false)

        whiteBg2:setPosition(ccp(guanGongGiftBg:getContentSize().width/2,guanGongGiftBg:getContentSize().height-110))
    end

    --UserModel.addStaminaNumber(growNaili)
    --[[local aleteNode2 = BaseUI.createHorizontalNode({naili, yuanNaili, arrow2,xinNaili})
	aleteNode2:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode2:setPosition(ccp(whiteBg2:getContentSize().width/2, whiteBg2:getContentSize().height/2))
	whiteBg2:addChild(aleteNode2)]]

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,150))
    itemInfoSpite:setPosition(ccp(_mySize.width*0.5,guanGongGiftBg:getContentSize().height-200+37*rewardNum))
    itemInfoSpite:setAnchorPoint(ccp(0.5,1))
    guanGongGiftBg:addChild(itemInfoSpite)

    require "script/ui/item/ItemSprite"
    local positionx = {0,itemInfoSpite:getContentSize().width*0.7/3,itemInfoSpite:getContentSize().width*0.7*2/3,itemInfoSpite:getContentSize().width*0.7}

    local i
    local j = 0
    for i = 1,4 do
        local finalNum
        if i == 1 then
            finalNum = math.floor(guanGongInfo.basePrestige+guanGongInfo.growPrestige*nowLevel/100)
        end
        if i == 2 then
            finalNum = math.floor(guanGongInfo.baseSoul+guanGongInfo.growSoul*nowLevel/100)
        end
        if i == 3 then
            finalNum = math.floor(guanGongInfo.baseSilver+guanGongInfo.growSilver*nowLevel/100)
        end
        if i == 4 then
            finalNum = math.floor(guanGongInfo.baseGold+guanGongInfo.growGold*nowLevel/100)
        end

        if tonumber(finalNum) ~= 0 then
            j = j+1

        	local reward
        	if i == 1 then
    	    	reward = ItemSprite.getPrestigeSprite()
    	    end
    	    if i == 2 then
    	    	reward = ItemSprite.getSoulIconSprite()
    	    end
    	    if i == 3 then
    	    	reward = ItemSprite.getSiliverIconSprite()
    	    end
    	    if i == 4 then
    	    	reward = ItemSprite.getGoldIconSprite()
    	    end
    	    reward:setAnchorPoint(ccp(0.5,0.4))
    	    reward:setPosition(ccp(itemInfoSpite:getContentSize().width*0.15+positionx[j],itemInfoSpite:getContentSize().height-75))
    	    itemInfoSpite:addChild(reward)

            require "script/ui/guild/GuangongTempleLayer"

    	    local num
    	    local itemNum
    	    if i == 1 then
    	    	itemNum = math.floor(guanGongInfo.basePrestige+guanGongInfo.growPrestige*nowLevel/100)
    	    	--UserModel.addPrestigeNum(tonumber(itemNum))
    	    end
    	    if i == 2 then
    	    	itemNum = math.floor(guanGongInfo.baseSoul+guanGongInfo.growSoul*nowLevel/100)
    	    	UserModel.addSoulNum(tonumber(itemNum))
    	    end
    	    if i == 3 then
    	    	itemNum = math.floor(guanGongInfo.baseSilver+guanGongInfo.growSilver*nowLevel/100)
    	    	--UserModel.addSilverNumber(tonumber(itemNum))
                GuangongTempleLayer.refreshSilver()
    	    end
    	    if i == 4 then
    	    	itemNum = math.floor(guanGongInfo.baseGold+guanGongInfo.growGold*nowLevel/100)
    	    	--UserModel.addGoldNumber(tonumber(itemNum))
                GuangongTempleLayer.refreshGold()
    	    end
    	    num = CCRenderLabel:create(tostring(itemNum), g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_shadow)
    	    num:setColor(ccc3(0x00,0xff,0x18))
    	    num:setPosition(ccp(reward:getContentSize().width,0))
    	    num:setAnchorPoint(ccp(1,0))
    	    reward:addChild(num)

    	    local descript
    	    if i == 1 then
    	    	descript = CCLabelTTF:create(GetLocalizeStringBy("key_2231"), g_sFontName , 21)
    	    end
    	    if i == 2 then
    	    	descript = CCLabelTTF:create(GetLocalizeStringBy("key_1616"), g_sFontName , 21)
    	    end
    	    if i == 3 then
    	    	descript = CCLabelTTF:create(GetLocalizeStringBy("key_1687"), g_sFontName , 21)
    	    end
    	    if i == 4 then
    	    	descript = CCLabelTTF:create(GetLocalizeStringBy("key_1491"), g_sFontName , 21)
    	    end
    	    descript:setColor(ccc3(0x78,0x25,0x00))
    	    descript:setPosition(ccp(itemInfoSpite:getContentSize().width*0.15+positionx[j],itemInfoSpite:getContentSize().height-115))
    	    descript:setAnchorPoint(ccp(0.5,1))
    	    itemInfoSpite:addChild(descript)
        end
    end

    local makeSureButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	makeSureButton:setAnchorPoint(ccp(0.5, 0.5))
    makeSureButton:setPosition(ccp(_mySize.width/2, 80))
    makeSureButton:registerScriptTapHandler(closeCb)
	menu:addChild(makeSureButton)

    local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*_myScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*_myScale)
    local scale3 = CCScaleTo:create(0.07,1*_myScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)

    guanGongGiftBg:runAction(seq)
end

function createLayer(gglv)
	init()
	
    nowLevel = gglv

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	require "script/ui/main/MainScene"
    _myScale = MainScene.elementScale
    _mySize = CCSizeMake(620,510)

    createBackGround()
	return _bgLayer
end
