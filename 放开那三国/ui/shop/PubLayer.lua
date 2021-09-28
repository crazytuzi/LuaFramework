-- Filename：	PubLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-22
-- Purpose：		酒馆招将

module ("PubLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/model/DataCache"
require "script/utils/TimeUtil"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/tip/LackGoldTip"

-- addby licong 2013.09.09
local didCreatShop = nil
local didClickFun = nil
------------end-----------

local didClickRecruitingGeneralCallback = nil
local pubLayerDidLoadCallback = nil

local _bgLayer 				= nil
local _mediumTimeDownLabel	= nil
local _seniorTimeDownLabel	= nil

local  _updateTimeScheduler = nil	-- scheduler
local recruitBar			= nil
local seniorBtn				= nil
local lowerBtn 				= nil
local mediumBtn 			= nil

local function init()
	_bgLayer 				= nil
	_mediumTimeDownLabel	= nil
	_seniorTimeDownLabel	= nil
	_updateTimeScheduler 	= nil	-- scheduler
	recruitBar				= nil
	seniorBtn				= nil
	mediumBtn 				= nil
	stopScheduler()
end

-- 停止scheduler
function stopScheduler()
	if(_updateTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 启动scheduler
function startScheduler()
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
	end
end

-- scheduler 刷新
function updateTime( )
	local shopInfo = DataCache.getShopCache()

	local isNotUsed_S = true
	local isNotUsed_G = true

	if(MainScene.getOnRunningLayerSign() == "shopLayer") then
		if(tonumber(shopInfo.silver_recruit_num)<=0) then
			if(shopInfo.silverExpireTime - os.time() <= 0) then
				DataCache.addSiliverFreeNum(1)
				createRecruitMenu()
				
			else
				local time_str = TimeUtil.getTimeString(shopInfo.silverExpireTime - os.time())
				_mediumTimeDownLabel:setString(time_str)
				isNotUsed_S = false
			end
		end

		if(tonumber(shopInfo.gold_recruit_num)<=0) then
			if(shopInfo.goldExpireTime - os.time() <= 0) then
				DataCache.addGoldFreeNum(1)
				createRecruitMenu()
				
			else
				local time_str = TimeUtil.getTimeString(shopInfo.goldExpireTime - os.time())
				_seniorTimeDownLabel:setString(time_str)
				isNotUsed_G = false
			end
		end
		
		if(isNotUsed_G and isNotUsed_S) then
			stopScheduler()
		end
	else
		stopScheduler()
	end

end

-- 战将招将的网络回调函数
function lowerRecuitCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then

		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil

		local hero_t = dictData.ret.hero
		local star_t = dictData.ret.star
		if( not table.isEmpty(hero_t))then
			local h_keys = table.allKeys(hero_t)
			h_id = tonumber(h_keys[1])
			h_tid = tonumber(hero_t["" .. h_id])
		end
		if( not table.isEmpty(star_t))then
			local s_keys = table.allKeys(star_t)
			s_id = tonumber(s_keys[1])
			s_tid = tonumber(star_t["" .. s_id])
		end
		
		-- 修改积分
        local addPoint = 0
		if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
            addPoint = tonumber(dictData.ret.add_point)
			DataCache.addShopPoint(tonumber(dictData.ret.add_point))
		end
		-- createRecruitMenu()
		stopScheduler( )
		-- local drop = dictData.ret.item
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint, 1)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

function mediumRecuitCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		local shopInfo = DataCache.getShopCache()
		if( tonumber(shopInfo.silver_recruit_num ) > 0 )then
			DataCache.addSiliverFreeNum(-1)
		else
			require "db/DB_Tavern"
			local mediumDesc = DB_Tavern.getDataById(2)
			DataCache.changeSiliverFirstStatus()
			UserModel.addGoldNumber(-mediumDesc.gold_needed)
		end

		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil

		local hero_t = dictData.ret.hero
		local star_t = dictData.ret.star
		if( not table.isEmpty(hero_t))then
			local h_keys = table.allKeys(hero_t)
			h_id = tonumber(h_keys[1])
			h_tid = tonumber(hero_t["" .. h_id])
		end
		if( not table.isEmpty(star_t))then
			local s_keys = table.allKeys(star_t)
			s_id = tonumber(s_keys[1])
			s_tid = tonumber(star_t["" .. s_id])
		end
		-- 修改积分
        local addPoint = 0
		if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
			DataCache.addShopPoint(tonumber(dictData.ret.add_point))
            addPoint = tonumber(dictData.ret.add_point)
		end
		
		--在新手引导中保存招募状态
		require "script/guide/NewGuide"
		NewGuide.saveRecruitInfo()
		
		-- createRecruitMenu()
		stopScheduler( )
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint,2)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")

	end
end

function seniorRecuitCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		-- local shopInfo = DataCache.getShopCache()
		-- if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
		-- 	DataCache.addGoldFreeNum(-1)
		-- else
		-- 	require "db/DB_Tavern"
		-- 	local seniorDesc = DB_Tavern.getDataById(3)

		-- 	UserModel.addGoldNumber(-seniorDesc.gold_needed)
		-- 	DataCache.changeFirstStatus()
		-- end

		-- local gold_recruit = dictData.ret.gold_recruit
		-- if( not table.isEmpty(gold_recruit))then
		-- 	DataCache.changeSeniorHeros(gold_recruit, dictData.ret.gold_hero)
		-- 	stopScheduler( )

		-- 	-- 修改积分
		-- 	if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
		-- 		DataCache.addShopPoint(tonumber(dictData.ret.add_point))
		-- 	end

		-- 	---[==[等级礼包新手引导屏蔽层
		-- 	---------------------新手引导---------------------------------
		-- 	--add by licong 2013.09.09
		-- 	require "script/guide/NewGuide"
		-- 	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		-- 		require "script/guide/LevelGiftBagGuide"
		-- 		LevelGiftBagGuide.changLayer()
		-- 	end
		-- 	---------------------end-------------------------------------
		-- 	--]==]
		-- 	require "script/ui/shop/SeniorAnimationLayer"
		-- 	local  seniorAnimationLayer = SeniorAnimationLayer.createLayer(gold_recruit, dictData.ret.gold_hero)
		-- 	MainScene.changeLayer(seniorAnimationLayer, "seniorAnimationLayer")
		-- 	---------------------------

		-- end
		local shopInfo = DataCache.getShopCache()
		if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
			DataCache.addGoldFreeNum(-1)
		else
			require "db/DB_Tavern"
			local seniorDesc = DB_Tavern.getDataById(3)
			DataCache.changeFirstStatus()
			UserModel.addGoldNumber(-seniorDesc.gold_needed)
		end

		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil

		local hero_t = dictData.ret.hero
		local star_t = dictData.ret.star
		if( not table.isEmpty(hero_t))then
			local h_keys = table.allKeys(hero_t)
			h_id = tonumber(h_keys[1])
			h_tid = tonumber(hero_t["" .. h_id])
		end
		if( not table.isEmpty(star_t))then
			local s_keys = table.allKeys(star_t)
			s_id = tonumber(s_keys[1])
			s_tid = tonumber(star_t["" .. s_id])
		end
		-- 修改积分
        local addPoint = 0
		if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
			DataCache.addShopPoint(tonumber(dictData.ret.add_point))
            addPoint = tonumber(dictData.ret.add_point)
		end
		
		-- createRecruitMenu()
		stopScheduler( )
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint,3)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

local function recruitAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == 100001) then
		require "db/DB_Tavern"
		local tavernDesc = DB_Tavern.getDataById(1)


		local itemArr = string.split(tavernDesc.cost_item, "|")
		local itemRemote = ItemUtil.getCacheItemInfoBy( tonumber(itemArr[1]) )
		local lowerItemNum = 0
		if(itemRemote)then
			lowerItemNum = tonumber(itemRemote.item_num)
		end
		if(lowerItemNum<=0)then
			AnimationTip.showTip(GetLocalizeStringBy("key_1823"))
		else
			RequestCenter.shop_bronzeRecruit(lowerRecuitCallback, nil)
		end
	elseif(tag == 100002) then
		local shopInfo = DataCache.getShopCache()
		if( tonumber(shopInfo.silver_recruit_num ) > 0 )then
			local args = Network.argsHandler(0)
			RequestCenter.shop_silverRecruit(mediumRecuitCallback, args)
		else
			require "db/DB_Tavern"
			local mediumDesc = DB_Tavern.getDataById(2)

			if(UserModel.getGoldNumber() >= (mediumDesc.gold_needed))then
				local args = Network.argsHandler(1)
				RequestCenter.shop_silverRecruit(mediumRecuitCallback, args)
			else
				-- AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
				LackGoldTip.showTip()
			end
		end

	elseif(tag == 100003) then
		--在新手引导中保存是否点击招募神将按钮状态
		require "script/guide/NewGuide"
		NewGuide.saveClickInfo()
		
		if(didClickRecruitingGeneralCallback ~= nil) then
			didClickRecruitingGeneralCallback()
		end
		---[==[等级礼包新手引导屏蔽层
			---------------------新手引导---------------------------------
			--add by licong 2013.09.09
			require "script/guide/NewGuide"
			if(NewGuide.guideClass == ksGuideFiveLevelGift) then
				require "script/guide/LevelGiftBagGuide"
				LevelGiftBagGuide.changLayer()
			end
			---------------------end-------------------------------------
		--]==]
		require "script/ui/shop/SeniorHeroRecruitLayer"
		SeniorHeroRecruitLayer.createSeniorHeroRecruitPanel()

		-- local shopInfo = DataCache.getShopCache()
		-- if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
		-- 	local args = Network.argsHandler(0)
		-- 	RequestCenter.shop_goldRecruit(seniorRecuitCallback, args)
		-- else
		-- 	require "db/DB_Tavern"
		-- 	local seniorDesc = DB_Tavern.getDataById(3)

		-- 	if(UserModel.getGoldNumber() >= (seniorDesc.gold_needed))then
		-- 		local args = Network.argsHandler(1)
		-- 		RequestCenter.shop_goldRecruit(seniorRecuitCallback, args)
		-- 	else
		-- 		AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
		-- 	end
		-- end
	end
end

-- 创建
function createRecruitMenu( )

	local layerSize = _bgLayer:getContentSize()


	if(recruitBar)then
		recruitBar:removeFromParentAndCleanup(true)
		recruitBar = nil
	end

	recruitBar = CCMenu:create()
	recruitBar:setPosition(ccp(0,0))
	_bgLayer:addChild(recruitBar)

	-- 招募背景
	local imageName = "images/common/bg/pub_9s.png"

--- 准备数据
	require "db/DB_Tavern"
	local tavernDesc = DB_Tavern.getDataById(1)

	local itemArr = string.split(tavernDesc.cost_item, "|")

	local itemRemote = ItemUtil.getCacheItemInfoBy( tonumber(itemArr[1]) )
	local lowerItemNum = 0
	if(itemRemote)then
		lowerItemNum = tonumber(itemRemote.item_num)
	end
	require "db/DB_Item_normal"
	local itemDesc = DB_Item_normal.getDataById(tonumber(itemArr[1]))


	local shopInfo = DataCache.getShopCache()

---- 战将
	lowerBtn = CCMenuItemImage:create("images/shop/pub/btn_lower_n.png", "images/shop/pub/btn_lower_h.png")
	lowerBtn:setAnchorPoint(ccp(0.5, 0.5))
	lowerBtn:setPosition(ccp(layerSize.width*0.17, layerSize.height *0.62 ))
	lowerBtn:setScale(MainScene.elementScale)
	lowerBtn:registerScriptTapHandler(recruitAction)
	recruitBar:addChild(lowerBtn, 1, 100001)

	-- 说明
	local lowerDescBg = CCScale9Sprite:create(imageName)
	lowerDescBg:setContentSize(CCSizeMake(190, 75))
	lowerDescBg:setAnchorPoint(ccp(0.5,1))
	lowerDescBg:setPosition(ccp(lowerBtn:getContentSize().width*0.5,lowerBtn:getContentSize().height *0.01 ))
	lowerBtn:addChild(lowerDescBg)
	--
	local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3413") .. lowerItemNum , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numberLabel:setColor(ccc3(0x36, 0xff, 0x00))
    numberLabel:setPosition(30, 60)
    lowerDescBg:addChild(numberLabel)
    local consumLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1771") , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    consumLabel:setColor(ccc3(0xff, 0xff, 0xff))
    consumLabel:setPosition(30, 35)
    lowerDescBg:addChild(consumLabel)
    local nameLabel = CCRenderLabel:create(itemDesc.name .. "x" .. (itemArr[2]) , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    nameLabel:setPosition(72, 35)
    lowerDescBg:addChild(nameLabel)

---- 良将
	mediumBtn = CCMenuItemImage:create("images/shop/pub/btn_medium_n.png", "images/shop/pub/btn_medium_h.png")
	mediumBtn:setAnchorPoint(ccp(0.5, 0.5))
	mediumBtn:setScale(MainScene.elementScale)
	mediumBtn:setPosition(ccp(layerSize.width*0.5, layerSize.height*0.62))
	mediumBtn:registerScriptTapHandler(recruitAction)
	recruitBar:addChild(mediumBtn, 1, 100002)
	
	-- 说明
	local mediumDescBg = CCScale9Sprite:create(imageName)
	mediumDescBg:setContentSize(CCSizeMake(190, 75))
	mediumDescBg:setAnchorPoint(ccp(0.5,1))
	mediumDescBg:setPosition(ccp(mediumBtn:getContentSize().width*0.5,mediumBtn:getContentSize().height *0.01 ))
	mediumBtn:addChild(mediumDescBg)
	if( tonumber(shopInfo.silver_recruit_num ) > 0 )then
		local t_label = CCRenderLabel:create(GetLocalizeStringBy("key_1770") .. shopInfo.silver_recruit_num .. GetLocalizeStringBy("key_2286"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    t_label:setColor(ccc3(0x36, 0xff, 0x00))
	    t_label:setPosition(15, 45)
	    mediumDescBg:addChild(t_label)
	else
		local time_str = TimeUtil.getTimeString(shopInfo.silverExpireTime - os.time())
		_mediumTimeDownLabel = CCLabelTTF:create(time_str, g_sFontName, 20)
		_mediumTimeDownLabel:setColor(ccc3(0x36, 0xff, 0x00))
		_mediumTimeDownLabel:setAnchorPoint(ccp(0, 1))
		_mediumTimeDownLabel:setPosition(ccp(30, 55))
		mediumDescBg:addChild(_mediumTimeDownLabel)
		local freeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3112") , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    freeLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    freeLabel:setPosition(108, 58)
	    mediumDescBg:addChild(freeLabel)

		require "db/DB_Tavern"
		local mediumDesc = DB_Tavern.getDataById(2)


		local goldSp = CCSprite:create("images/common/gold.png")
		goldSp:setAnchorPoint(ccp(0,1))
		goldSp:setPosition(ccp(50,30))
		mediumDescBg:addChild(goldSp)

		local goldNumLabel = CCRenderLabel:create(mediumDesc.gold_needed, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    goldNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    goldNumLabel:setPosition(95, 28)
	    mediumDescBg:addChild(goldNumLabel)
	    startScheduler()

	    if( tonumber(shopInfo.silver_recruit_status) < 2)then
			local firstSp = CCSprite:create("images/shop/pub/firstget4.png")
			firstSp:setAnchorPoint(ccp(0.5,0))
			firstSp:setPosition(ccp(mediumBtn:getContentSize().width*0.5, mediumBtn:getContentSize().height*0.02))
			mediumBtn:addChild(firstSp)
		end

	end

---- 神将
	-- local norSprite = CCSprite:create("images/shop/pub/btn_senior_n.png")
	-- local selSprite = CCSprite:create("images/shop/pub/btn_senior_h.png")
	-- seniorBtn = CCMenuItemSprite:create(norSprite, selSprite)
	seniorBtn = CCMenuItemImage:create("images/shop/pub/btn_senior_n.png", "images/shop/pub/btn_senior_h.png")
	seniorBtn:setAnchorPoint(ccp(0.5, 0.5))
	seniorBtn:setPosition(ccp(layerSize.width*0.83, layerSize.height*0.62))
	seniorBtn:registerScriptTapHandler(recruitAction)

	
	seniorBtn:setScale(MainScene.elementScale)
	recruitBar:addChild(seniorBtn, 1, 100003)

	-- 说明
	local seniorDescBg = CCScale9Sprite:create(imageName)
	seniorDescBg:setContentSize(CCSizeMake(190, 75))
	seniorDescBg:setAnchorPoint(ccp(0.5,1))
	seniorDescBg:setPosition(ccp(seniorBtn:getContentSize().width*0.5,seniorBtn:getContentSize().height *0.01 ))
	seniorBtn:addChild(seniorDescBg)
	if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
		local t_label = CCRenderLabel:create(GetLocalizeStringBy("key_1770") .. shopInfo.gold_recruit_num .. GetLocalizeStringBy("key_2286"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    t_label:setColor(ccc3(0x36, 0xff, 0x00))
	    t_label:setPosition(15, 45)
	    seniorDescBg:addChild(t_label)
	else
		local time_str = TimeUtil.getTimeString(shopInfo.goldExpireTime - os.time())
		_seniorTimeDownLabel = CCLabelTTF:create(time_str, g_sFontName, 20)
		_seniorTimeDownLabel:setColor(ccc3(0x36, 0xff, 0x00))
		_seniorTimeDownLabel:setAnchorPoint(ccp(0, 1))
		_seniorTimeDownLabel:setPosition(ccp(30, 55))
		seniorDescBg:addChild(_seniorTimeDownLabel)
		local freeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3112") , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    freeLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    freeLabel:setPosition(108, 58)
	    seniorDescBg:addChild(freeLabel)

		require "db/DB_Tavern"
		local seniorDesc = DB_Tavern.getDataById(3)
		

		local goldSp = CCSprite:create("images/common/gold.png")
		goldSp:setAnchorPoint(ccp(0,1))
		goldSp:setPosition(ccp(50,30))
		seniorDescBg:addChild(goldSp)

		local goldNumLabel = CCRenderLabel:create(seniorDesc.gold_needed, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    goldNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    goldNumLabel:setPosition(95, 28)
	    seniorDescBg:addChild(goldNumLabel)
	    startScheduler()

	    if( tonumber(shopInfo.gold_recruit_status) < 2)then
			local firstSp = CCSprite:create("images/shop/pub/firstget.png")
			firstSp:setAnchorPoint(ccp(0.5,0))
			firstSp:setPosition(ccp(seniorBtn:getContentSize().width*0.5, seniorBtn:getContentSize().height*0.02))
			seniorBtn:addChild(firstSp)
		end
	end
	
	-- 积分兑换
	local o_menuBar =  CCMenu:create()
	o_menuBar:setPosition(ccp(0, 0))
	o_menuBar:setTouchPriority(-152)
	_bgLayer:addChild(o_menuBar)

	-- local exchangeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1310"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- exchangeBtn:setAnchorPoint(ccp(0.5, 0.5))
	-- exchangeBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.3, _bgLayer:getContentSize().height*0.07))
	-- exchangeBtn:registerScriptTapHandler(otherMenuAction)
	-- exchangeBtn:setScale(MainScene.elementScale)
	-- o_menuBar:addChild(exchangeBtn, 2, 10001)

	local displayBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3165"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	displayBtn:setAnchorPoint(ccp(0.5, 0.5))
	displayBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.07))
	displayBtn:registerScriptTapHandler(otherMenuAction)
	displayBtn:setScale(MainScene.elementScale)
	o_menuBar:addChild(displayBtn, 2, 10002)

	--test code

	-- function testAction( ... )
	-- 	-- body
	-- 	require "script/utils/BaseUI"
	-- 	local scene = CCDirector:sharedDirector():getRunningScene()
	-- 	local sprite = getGuideObject()
	-- 	local spriteRect = getSpriteScreenRect(sprite)
	-- 	local layer = BaseUI.createMaskLayer( -5000,spriteRect ,nil, 200)
	-- 	scene:addChild(layer,20000)
	-- end
	-- local seq = CCSequence:createWithTwoActions(CCDelayTime:create(2.3),CCCallFunc:create(function ( ... )
	-- 		testAction()
	-- end))
	-- _bgLayer:runAction(seq)


end

-- 
function otherMenuAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == 10001)then
		require "script/ui/shop/HeroExchange"
		local layer = HeroExchange.createHeroExchageLayer()
		local scene = CCDirector:sharedDirector():getRunningScene()
    	scene:addChild(layer,999,2013)
	elseif(tag == 10002)then
		require "script/ui/shop/PreHeroShowLayer"
		local layer = PreHeroShowLayer.createLayer()
		local scene = CCDirector:sharedDirector():getRunningScene()
    	scene:addChild(layer,999,2014)

	end
end

local function onNodeEvent(eventType )
	if(eventType == "enter") then
		startScheduler()
	elseif(eventType == "exit") then
		stopScheduler()
	end
end

function createLayerBySize( layerSize )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setContentSize(layerSize)
	createRecruitMenu()
	

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		-- addby licong 2013.09.09
		if(didCreatShop ~= nil )then
			didCreatShop()
		end
		---------------------------
		if(pubLayerDidLoadCallback ~= nil) then
			pubLayerDidLoadCallback()
		end
		---------------------------------------
		-- 副本箱子第5步
		-- addGuideCopyBoxGuide5()
		---------------------------------
		-- 签到第5步
		addGuideSignInGuide5()
	end))
	_bgLayer:runAction(seq)	
	return _bgLayer
end


-- 新手引导
function getGuideObject()
	 return mediumBtn
end

function getGuideObject1()
	return lowerBtn
end


--add by lichenyang

function registerDidClickRecruitingGeneralCallback( p_callback )
	didClickRecruitingGeneralCallback = p_callback
end

function registerPubLayerDidLoadCallback( p_callback )
	pubLayerDidLoadCallback = p_callback
end



-- addby licong 2013.09.09
function registerDidCreateShopCallBack( callBack )
	didCreatShop = callBack
end
---------------------------

-- add by licong 2013.09.09
function registerDidClickCallBack( callBack )
	didClickFun = callBack
end
-----------------------------

-- 副本箱子第5步
function addGuideCopyBoxGuide5( ... )
	---[==[  副本箱子 第5步 招将
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 4) then
        	local copyBoxGuide_button = getGuideObject1()
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(5, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]
end

-- 签到第5步 充值
function addGuideSignInGuide5( ... )
	require "script/guide/NewGuide"
	require "script/guide/SignInGuide"
    if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 4) then
       	require "script/ui/shop/ShopLayer"
        local button = ShopLayer.getRechargeBtnForGuide()
        local touchRect   = getSpriteScreenRect(button)
        SignInGuide.show(5, touchRect)
    end
end


