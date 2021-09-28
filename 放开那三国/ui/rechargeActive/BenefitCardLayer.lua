-- Filename：	BenefitCardLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-3-13
-- Purpose：		福利活动翻牌界面

module("BenefitCardLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/utils/BaseUI"
require "script/network/Network"
require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/hero/HeroPublicLua"

local _bgLayer
local _myScale
local _mySize
local cardMenu
local basePic
local baseSize
local brownPic
local _cardNum
local tag
local menuItem

local _cardBackNO
local _cardFaceNO
local _cardShadowNO
local cardNum
local goonBtn

local function init()
	_bgLayer = nil
	_myScale = nil
	_mySize = nil
	cardMenu = nil
	basePic = nil
	baseSize = nil
	brownPic = nil
	tag = nil
	menuItem = nil
	cardNum = nil
	_cardNum = 0
	goonBtn = nil
	
	_cardBackNO = 1000
	_cardFaceNO = 2000
	_cardShadowNO = 3000
end

local function layerToucCb(eventType, x, y)
	return true
end

local function gotoQuit()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function addHighLight( parent )
    local lightAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/light/duobaoshanguang"), -1,CCString:create(""))
    lightAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    lightAnimSprite:setPosition(parent:getContentSize().width*0.5,parent:getContentSize().height*0.5)
    parent:addChild(lightAnimSprite,-1)
end

local function dealWithTheData(giftData)
	local returnTable = {}
	for i = 1,6 do
		local everyTable = {}
		for k,v in pairs(giftData[i]) do
			if tonumber(k) == 1 then
				everyTable.giftSprite = ItemSprite.getSiliverIconSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1687")
				everyTable.quality = 2
				if i == 1 then
					UserModel.addSilverNumber(tonumber(v))
				end
			elseif tonumber(k) == 2 then
				everyTable.giftSprite = ItemSprite.getSoulIconSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1616")
				everyTable.quality = 3
				if i == 1 then
					UserModel.addSoulNum(tonumber(v))
				end
			elseif tonumber(k) == 3 then
				everyTable.giftSprite = ItemSprite.getGoldIconSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1491")
				everyTable.quality = 5
				if i == 1 then
					UserModel.addGoldNumber(tonumber(v))
				end
			elseif tonumber(k) == 7 then
				for r,t in pairs(v) do
					everyTable.giftSprite = ItemSprite.getItemSpriteById(tonumber(r))
					everyTable.giftNum = tonumber(t)
					everyTable.giftName = tostring(ItemUtil.getItemById(r).name)
					everyTable.quality = tonumber(ItemUtil.getItemById(r).quality)
					break
				end
			elseif tonumber(k) == 11 then
				everyTable.giftSprite = ItemSprite.getJewelSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1510")
				everyTable.quality = 5
				if i == 1 then
					UserModel.addJewelNum(tonumber(v))
				end
			elseif tonumber(k) == 12 then
				everyTable.giftSprite = ItemSprite.getPrestigeSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_2231")
				everyTable.quality = 3
				if i == 1 then
					UserModel.addPrestigeNum(tonumber(v))
				end
			elseif tonumber(k) == 13 then
				for r,t in pairs(v) do
					require "db/DB_Heroes"
					local db_hero = DB_Heroes.getDataById(tonumber(r))
					everyTable.giftSprite = ItemSprite.getHeroIconItemByhtid(r)
					everyTable.giftNum = tonumber(t)
					everyTable.giftName = tostring(db_hero.name)
					everyTable.quality = tonumber(db_hero.quality)
					break
				end
			elseif tonumber(k) == 14 then
				for r,t in pairs(v) do
					everyTable.giftSprite = ItemSprite.getItemSpriteById(tonumber(r))
					everyTable.giftNum = tonumber(t)
					everyTable.giftName = tostring(ItemUtil.getItemById(r).name)
					everyTable.quality = tonumber(ItemUtil.getItemById(r).quality)
					break
				end
			elseif tonumber(k) == 4 then
				everyTable.giftSprite = ItemSprite.getExecutionSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1032")
				everyTable.quality = 3
				if i == 1 then
					UserModel.addEnergyValue(tonumber(v))
				end
			elseif tonumber(k) == 5 then
				everyTable.giftSprite = ItemSprite.getStaminaSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_2021")
				everyTable.quality = 3
				if i == 1 then
					UserModel.addStaminaNumber(tonumber(v))
				end

			--8和9是银币乘等级和将魂乘等级，单独拿出来是方便查错
			elseif tonumber(k) == 8 then
				everyTable.giftSprite = ItemSprite.getSiliverIconSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1687")
				everyTable.quality = 2
				if i == 1 then
					UserModel.addSilverNumber(tonumber(v))
				end
			elseif tonumber(k) == 9 then
				everyTable.giftSprite = ItemSprite.getSoulIconSprite()
				everyTable.giftNum = tonumber(v)
				everyTable.giftName = GetLocalizeStringBy("key_1616")
				everyTable.quality = 3
				if i == 1 then
					UserModel.addSoulNum(tonumber(v))
				end
			--方便查错使用
			else
				everyTable.giftSprite = CCSprite:create()
				everyTable.giftNum = 0
				everyTable.giftName = GetLocalizeStringBy("key_1572")
			end
		end
		everyTable.giftSprite:retain()
		-- everyTable.giftNum:retain()
		-- everyTable.giftName:retain()
		table.insert(returnTable,everyTable)
	end
	return returnTable
end

function refreshAllNum(cbFlag, dictData, bRet)
	if not bRet then
		return
	end
	if cbFlag == "weal.getKaInfo" then
		require "script/ui/rechargeActive/BenefitActiveLayer"

		local newPoint = dictData.ret.point_today
		local newAll = dictData.ret.point_add
		local newRate = BenefitActiveLayer.getRate()
		local newCard = math.floor(newPoint/newRate)
		_cardNum = tonumber(newCard)
		cardNum:setString(newCard)
		BenefitActiveLayer.toANewDay(newPoint,newAll)
	end
end

function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	print("lalal")
	print(cbFlag)
	print(bRet)
	-- if not bRet then
	-- 	return
	-- end
	print("dictData到底是个啥")
	print_t(dictData)

	if dictData.err ~= "ok" then
		AnimationTip.showTip(GetLocalizeStringBy("key_2197"))
		local arg = CCArray:create()
		Network.rpc(refreshAllNum, "weal.getKaInfo","weal.getKaInfo", arg, true)
	else
		if cbFlag == "weal.kaOnce" then
			goonBtn:setEnabled(true)
			print_t(dictData.ret)

			local giftTable = dealWithTheData(dictData.ret)
			print_t(giftTable)

			require "script/ui/rechargeActive/BenefitActiveLayer"
			
			_cardNum = _cardNum-1
			cardNum:setString(_cardNum)
			BenefitActiveLayer.refreshNum()

			local needSecond = 0.2
			local intervalSecond = 0.15
			cardMenu:stopAllActions()
		    cardMenu:setTouchEnabled(false)

		    local tagNum = tag - _cardBackNO

		    local faceCardItem = brownPic:getChildByTag(_cardFaceNO+tagNum)
		    local bottomItem = brownPic:getChildByTag(_cardShadowNO+tagNum)

		    local faceSize = faceCardItem:getContentSize()
		    local bottomSize = bottomItem:getContentSize()

		    --获得的物品***********************************************************************************************************
		    giftTable[1].giftSprite:setAnchorPoint(ccp(0.5,0.5))
		    giftTable[1].giftSprite:setPosition(ccp(faceSize.width/2,faceSize.height/2))
		    faceCardItem:addChild(giftTable[1].giftSprite)

		    local giftSize = giftTable[1].giftSprite:getContentSize()

		    local ownNum = CCRenderLabel:create(tostring(giftTable[1].giftNum),g_sFontPangWa,  18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			ownNum:setColor(ccc3(0x00,0xff,0x18))
			ownNum:setAnchorPoint(ccp(1,0))
			ownNum:setPosition(ccp(giftSize.width,0))
			giftTable[1].giftSprite:addChild(ownNum)

			local ownName = CCRenderLabel:create(tostring(giftTable[1].giftName),g_sFontPangWa,  18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			ownName:setColor(HeroPublicLua.getCCColorByStarLevel(giftTable[1].quality))
			ownName:setAnchorPoint(ccp(0.5,0.5))
			ownName:setPosition(ccp(bottomSize.width/2,bottomSize.height/2))
			bottomItem:addChild(ownName)

			--********************************************************************************************************************

		    local actionArr = CCArray:create()
		    actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
		    actionArr:addObject(CCCallFunc:create(function ()
		    	faceCardItem:setVisible(true)
		        local actions1 = CCArray:create()
		        actions1:addObject(CCDelayTime:create(0.08))
		        actions1:addObject(CCCallFunc:create(function ()
		            menuItem:setVisible(false)
		        end))
		        menuItem:runAction(CCSequence:create(actions1))

		        local actionArr = CCArray:create()
		        actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
		        actionArr:addObject(CCCallFunc:create(function ()
		            addHighLight(faceCardItem)
		            bottomItem:setVisible(true)
		        end))
		        faceCardItem:runAction(CCSequence:create(actionArr))
		    end))
		    actionArr:addObject(CCDelayTime:create(intervalSecond))
		    actionArr:addObject(CCCallFunc:create(function ()
		    	local k = 1
		    	for i = 1,6 do
		    		local otherMenuItem = cardMenu:getChildByTag(_cardBackNO+i)
		    		local nameItem = brownPic:getChildByTag(_cardShadowNO+i)
		    		local onFaceItem = brownPic:getChildByTag(_cardFaceNO+i)

		    		local onFaceSize = onFaceItem:getContentSize()
		    		local nameSize = nameItem:getContentSize()

		    		if tonumber(i) ~= tonumber(tagNum) then
		    			k = k+1
		    			giftTable[k].giftSprite:setAnchorPoint(ccp(0.5,0.5))
					    giftTable[k].giftSprite:setPosition(ccp(onFaceSize.width/2,onFaceSize.height/2))
					    onFaceItem:addChild(giftTable[k].giftSprite)

					    local giftSizeT = giftTable[k].giftSprite:getContentSize()

					    local ownNumT = CCRenderLabel:create(tostring(giftTable[k].giftNum),g_sFontPangWa,  18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
						ownNumT:setColor(ccc3(0x00,0xff,0x18))
						ownNumT:setAnchorPoint(ccp(1,0))
						ownNumT:setPosition(ccp(giftSizeT.width,0))
						giftTable[k].giftSprite:addChild(ownNumT)

						local ownNameT = CCRenderLabel:create(tostring(giftTable[k].giftName),g_sFontPangWa,  18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
						ownNameT:setColor(HeroPublicLua.getCCColorByStarLevel(giftTable[k].quality))
						ownNameT:setAnchorPoint(ccp(0.5,0.5))
						ownNameT:setPosition(ccp(nameSize.width/2,nameSize.height/2))
						nameItem:addChild(ownNameT)

						giftTable[k].giftSprite:release()
						-- giftTable[k].giftNum:release()
						-- giftTable[k].giftName:release()

		    			local actionArr = CCArray:create()
				        actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
				        actionArr:addObject(CCCallFunc:create(function ()
				            onFaceItem:setVisible(true)
				            local actions1 = CCArray:create()
				            actions1:addObject(CCDelayTime:create(0.08))
				            actions1:addObject(CCCallFunc:create(function ()
				                otherMenuItem:setVisible(false)
				            end))
				            otherMenuItem:runAction(CCSequence:create(actions1))
				            local actionArr = CCArray:create()
				            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
				            actionArr:addObject(CCCallFunc:create(function ()
				                nameItem:setVisible(true)
				            end))
				            onFaceItem:runAction(CCSequence:create(actionArr))
				        end))   
				        otherMenuItem:runAction(CCSequence:create(actionArr))
		    		end
		    	end
		    end))
			menuItem:runAction(CCSequence:create(actionArr))
		end
	end
end

local function cardMenuActionFun(_tag,_menuItem)
	require "script/ui/item/ItemUtil"
	require "script/ui/hero/HeroPublicUI"
	if HeroPublicUI.showHeroIsLimitedUI() then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	elseif ItemUtil.isBagFull() then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	else
		tag = _tag
		menuItem = _menuItem
		local arg = CCArray:create()
		Network.rpc(fnHandlerOfNetwork, "weal.kaOnce","weal.kaOnce", arg, true)
	end
end

local function createContent()
	brownPic = CCScale9Sprite:create("images/recharge/benefit_active/scroll.png")
	brownPic:setPreferredSize(CCSizeMake(555,435))
	brownPic:setAnchorPoint(ccp(0.5,1))
	brownPic:setPosition(ccp(baseSize.width/2,baseSize.height-20))
	basePic:addChild(brownPic)

	local brownSize = brownPic:getContentSize()

	local orangeLine = CCSprite:create("images/common/line2.png")
	orangeLine:setAnchorPoint(ccp(0.5,0.5))
	orangeLine:setPosition(ccp(brownSize.width/2,brownSize.height-30))
	brownPic:addChild(orangeLine)

	local orangeSize = orangeLine:getContentSize()

	local pleaseCard = CCRenderLabel:create(GetLocalizeStringBy("key_2084"), g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	pleaseCard:setColor(ccc3(0xff,0xe4,0x00))
	pleaseCard:setAnchorPoint(ccp(0.5,0.5))
	pleaseCard:setPosition(ccp(orangeSize.width/2,orangeSize.height/2))
	orangeLine:addChild(pleaseCard)

	cardMenu = CCMenu:create()
    cardMenu:setTouchPriority(-552)
    cardMenu:setPosition(ccp(0,0))
    brownPic:addChild(cardMenu)

    local cardPosX = {brownSize.width*3/4+40,brownSize.width/4-40,brownSize.width/2}
    local cardPosY = {brownSize.height*2/3+20,brownSize.height/3-20}

    local scaleSecond = 0.05
    local scaleDelay = 0.5

    local seqArray = CCArray:create()

    for i = 1,6 do
    	local posX = (i%3)+1
    	local posY = math.ceil(i/3)

    	local cardItem = CCMenuItemImage:create("images/arena/card_back.png","images/arena/card_back.png")
        cardItem:setAnchorPoint(ccp(0.5,0.5))
        cardItem:setPosition(ccp(cardPosX[posX],cardPosY[posY]))
        cardMenu:addChild(cardItem,1,_cardBackNO+i)
        cardItem:registerScriptTapHandler(cardMenuActionFun)

        local cardShow = CCSprite:create("images/arena/item_name_bg.png")
        cardShow:setAnchorPoint(ccp(0.5,0.5))
        cardShow:setPosition(ccp(cardPosX[posX],cardPosY[posY]-90))
        brownPic:addChild(cardShow,1,_cardShadowNO+i)
        cardShow:setVisible(false)

        seqArray:addObject(CCCallFunc:create(function ()
            local actionArray = CCArray:create()
            actionArray:addObject(CCScaleTo:create(scaleSecond, 1.2))
            actionArray:addObject(CCScaleTo:create(scaleSecond, 1.0))
            local cardAction = CCSequence:create(actionArray)
            cardItem:runAction(cardAction)            
        end))
        seqArray:addObject(CCDelayTime:create(scaleDelay))

        local faceItem = CCSprite:create("images/arena/card_face.png")
        faceItem:setAnchorPoint(ccp(0.5,0.5))
        faceItem:setPosition(ccp(cardItem:getPositionX(),cardItem:getPositionY()))
        brownPic:addChild(faceItem,2,_cardFaceNO+i)
        faceItem:setVisible(false)
    end

    local seq = CCSequence:create(seqArray)
    cardMenu:runAction(CCRepeatForever:create(seq))
end

local function gotoGoon()
	if tonumber(_cardNum) <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_2197"))
	else
		brownPic:removeAllChildrenWithCleanup(true)
		createContent()
		goonBtn:setEnabled(false)
	end
end

local function createBaseUI()
	basePic = CCScale9Sprite:create("images/recharge/benefit_active/cardbg.png")
	basePic:setPreferredSize(_mySize)
	--为弹出效果做准备
	basePic:setScale(0.01*_myScale)
	basePic:setAnchorPoint(ccp(0.5,0.5))
	basePic:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	_bgLayer:addChild(basePic)

	baseSize = basePic:getContentSize()

	local flower = CCSprite:create("images/recharge/benefit_active/caidai.png")
	flower:setAnchorPoint(ccp(0.5,0))
	flower:setPosition(ccp(baseSize.width/2,baseSize.height-20))
	basePic:addChild(flower)

	local flowerSize = flower:getContentSize()

	local con = CCSprite:create("images/recharge/benefit_active/congratulate.png")
	con:setAnchorPoint(ccp(0.5,0))
	con:setPosition(ccp(flowerSize.width/2,10))
	flower:addChild(con)

	local cardDes = CCRenderLabel:create(GetLocalizeStringBy("key_2329"),g_sFontPangWa,  21, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
	cardDes:setColor(ccc3(0x78,0x25,0x00))
	cardNum = CCRenderLabel:create(_cardNum,g_sFontPangWa,  21, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
	cardNum:setColor(ccc3(0x07,0x79,0x11))

	local carding = BaseUI.createHorizontalNode({cardDes, cardNum})
	carding:setAnchorPoint(ccp(0.5, 0.5))
	carding:setPosition(ccp(baseSize.width/2,110))
	basePic:addChild(carding)

	local menuBar_g = CCMenu:create()
	menuBar_g:setPosition(ccp(0,0))
	menuBar_g:setTouchPriority(-551)
	basePic:addChild(menuBar_g)

	local quitBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3344"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	quitBtn:setAnchorPoint(ccp(0.5 , 0))
    quitBtn:setPosition(ccp(baseSize.width/3-40,20))
    quitBtn:registerScriptTapHandler(gotoQuit)
	menuBar_g:addChild(quitBtn)

		--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		goonBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1201"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	else
		goonBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1201"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	end
	goonBtn:setAnchorPoint(ccp(0.5 , 0))
    goonBtn:setPosition(ccp(baseSize.width*2/3+40,20))
    goonBtn:registerScriptTapHandler(gotoGoon)
    goonBtn:setEnabled(false)
	menuBar_g:addChild(goonBtn)

	--弹出效果
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

    basePic:runAction(seq)
end

local function createUI()
	createBaseUI()
	createContent()
end

function  showLayer(reaminCard)
	init()

	_cardNum = reaminCard

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-550,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999)

    _myScale = MainScene.elementScale
	_mySize = CCSizeMake(575,575)

	createUI()
end
