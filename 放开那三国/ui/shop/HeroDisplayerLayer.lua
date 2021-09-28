-- Filename：	HeroDisplayerLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-22
-- Purpose：		招将展示信息

module ("HeroDisplayerLayer", package.seeall)


require "script/model/DataCache"

require "script/ui/main/MainScene"
require "script/ui/star/StarSprite"
require "script/model/user/UserModel"
require "script/ui/hero/HeroPublicLua"
require "script/ui/share/ShareLayer"
require "script/utils/BaseUI"
require "script/ui/rechargeActive/ActiveCache"

-- addby licong 2013.09.09
local didGetHero = nil
---------------------------
local didClickZhaoJiangCallback = nil

local _bgLayer	= nil
local _hid 		= nil
local _htid 	= nil
local _sid 		= nil
local _stid 	= nil
local closeBtn	= nil
local lookStarBtn = nil 		-- 继续找将按钮
local _pickUpBtn= nil
local _fiveStarBg = nil
-- 英雄
local heroSprite = nil

local _lowerRecuitBtn= nil 		-- 战将招将再招一次按钮

-- 判断招将的类型：1：战将，2：良将， 3：神将, 4:活动卡包招将 ,added by zhz
local _recuitType	

local _star_lv =0   -- 招到武将得星级


local heroDisplayerLayerCloseCallback = nil
-- 星星底
local starsBgSp = nil

local starIndexArr = {}
local starIndexForCur = 1

local _p_soul = 0 		--紫色魂玉个数

local _isActivity = false -- 活动专用 获得额外物品
local _flop_bg = nil 
local _dorpItemData = nil -- 抽神将额外掉落物品

-- 初始化
local function init( )
	_bgLayer 	= nil
	_hid 		= nil
	_htid 		= nil
	_sid 		= nil
	_stid 		= nil
	closeBtn	= nil
	_fiveStarBg = nil
	heroSprite 	= nil
	starsBgSp 	= nil
	lookStarBtn = nil
	_recuitType =0

	starIndexArr = {}
	starIndexForCur = 1
	_p_soul = 0 		--紫色魂玉个数
	_pickUpBtn= nil
	
	_isActivity = false
	_dorpItemData = nil
	_flop_bg = nil 
end 

local function createPaAnimation()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/jinbizhaojiangbao.mp3")
	-- 将领
	require "db/DB_Heroes"
	local heroLocalInfo = DB_Heroes.getDataById(tonumber(_htid))

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/jinbizhaojiangbao" ), -1,CCString:create(""));
	spellEffectSprite:setScale(MainScene.bgScale/MainScene.elementScale)
	spellEffectSprite:retain()
    
    spellEffectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
    spellEffectSprite:setAnchorPoint(ccp(0, 0));
    _bgLayer:addChild(spellEffectSprite,9999);

    -- 英雄
	heroSprite = CCSprite:create("images/base/hero/body_img/" .. heroLocalInfo.body_img_id)
	heroSprite:setAnchorPoint(ccp(0.5,0.5))
	heroSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(heroSprite)
	heroSprite:setScale(3)

	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(0.000001))
	actionArr:addObject(CCScaleBy:create(0.3, 1/3))
	heroSprite:runAction(CCSequence:create(actionArr))


     --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
        spellEffectSprite:removeFromParentAndCleanup(true)
        spellEffectSprite:autorelease()
        lookStarBtn:setEnabled(true)

        if(_pickUpBtn~= nil) then
        	_pickUpBtn:setEnabled(true)
        end
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    spellEffectSprite:setDelegate(delegate)
end

local function createAnimation()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/fazhenguangbao.mp3")
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/fazhengguang"), -1,CCString:create(""));
	spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	spellEffectSprite:setScale(MainScene.bgScale/MainScene.elementScale)
    spellEffectSprite:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5))
    _bgLayer:addChild(spellEffectSprite)

    local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/fazhenguangbao"), -1,CCString:create(""));
    spellEffectSprite_2:setAnchorPoint(ccp(0.5, 0.5))
    spellEffectSprite_2:setScale(MainScene.bgScale/MainScene.elementScale)
    spellEffectSprite_2:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5))
    _bgLayer:addChild(spellEffectSprite_2);

    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite_2:retain()
		spellEffectSprite_2:autorelease()
        spellEffectSprite_2:removeFromParentAndCleanup(true)
        createPaAnimation()
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite_2:setDelegate(delegate)
end

-- 活动卡包继续抽取得网络回调
function buyHeroCallback( cbFlag, dictData, bRet  )
	if (dictData.err == "ok") then
		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil
		h_tid = tonumber(dictData.ret.htid)
		h_id = tonumber(dictData.ret.hid)

		if(ActiveCache.getBuyHeroType() == 3 ) then
			UserModel.addGoldNumber(-ActiveCache.getGoldCost())
		end
		ActiveCache.setRankShopInfo(dictData.ret.shop_info)
		ActiveCache.setRankInfo(dictData.ret.rank_info )
		ActiveCache.setRankNum(dictData.ret.rank)
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, 0,4)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

-- 招将1次网络回调处理
local function fnHandlerOfNetworkRecruitOne(cbFlag, dictData, bRet)
	if bRet then
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
		if(_recuitType == 3) then
			DataCache.changeGoldRecruitSum(1)
		end
		-- 修改积分
        local addPoint = 0
		if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
			DataCache.addShopPoint(tonumber(dictData.ret.add_point))
            addPoint = tonumber(dictData.ret.add_point)
		end
	
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint, _recuitType,dictData.ret.item)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

-- 战将招将的网络回调
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
		
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint, 1)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end


local function menuAction(tag, itembtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 查看武将
	if( tag == 10001 )then
		require "script/ui/hero/HeroInfoLayer"
		require "script/ui/hero/HeroPublicLua"
		local data = HeroPublicLua.getHeroDataByHid(_hid)
		local tArgs = {}
		if(_recuitType == 4) then
			tArgs.sign = "cardLayer"
			require "script/ui/rechargeActive/RechargeActiveMain"
			tArgs.fnCreate = RechargeActiveMain.create -- RechargeActiveMain._tagCardActive
			tArgs.reserved = RechargeActiveMain._tagCardActive
		else	
			tArgs.sign = "shopLayer"
			tArgs.fnCreate = ShopLayer.createLayer
		end

		MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
	elseif( tag == 10002)then
		print("......................继续招将.....................")
		local shopInfo = DataCache.getShopCache()
		if (tonumber(shopInfo.gold_recruit_num) > 0) then
			local args = Network.argsHandler(0, 1)
			RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
		else
			require "db/DB_Tavern"
			local db_tavern = DB_Tavern.getDataById(3)
			if (UserModel.getGoldNumber() >= (db_tavern.gold_needed)) then
				_nCostGold = db_tavern.gold_needed
				-- 让继续找将不可点击  
				lookStarBtn:setEnabled(false)
				local args = Network.argsHandler(1, 1)
				RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
			else
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
				--AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
			end
		end
	elseif(tag == 10003) then

		if(heroDisplayerLayerCloseCallback ~= nil) then
			heroDisplayerLayerCloseCallback()
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

		---[==[副本箱子 新手引导屏蔽层
		---------------------新手引导---------------------------------
			--add by licong 2013.09.11
			require "script/guide/NewGuide"
			if(NewGuide.guideClass ==  ksGuideCopyBox) then
				require "script/guide/CopyBoxGuide"
				CopyBoxGuide.changLayer()
			end
		---------------------end-------------------------------------
		--]==]
		if( tonumber(_recuitType)== 4) then
			require "script/ui/rechargeActive/RechargeActiveMain"
			require "script/ui/rechargeActive/CardPackActiveLayer"
			local cardLayer = RechargeActiveMain.create(RechargeActiveMain._tagCardActive)
			MainScene.changeLayer(cardLayer,"cardLayer")
		else
			local  shopLayer = ShopLayer.createLayer()
			MainScene.changeLayer(shopLayer, "shopLayer", ShopLayer.layerWillDisappearDelegate)
		end


		-- added by zhz
		-- 刷新menuLayer 
		MenuLayer.refreshMenuItemTipSprite()

		---[==[ 等级礼包第9步 
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
	    require "script/guide/LevelGiftBagGuide"
		if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 8) then
	        local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(2)
	        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
	        LevelGiftBagGuide.show(9, touchRect)
	    end
	    ---------------------end-------------------------------------
		--]==]

		---[==[  副本箱子 第7步 副本
		---------------------新手引导---------------------------------
		    --add by licong 2013.09.11
		    require "script/guide/NewGuide"
			require "script/guide/CopyBoxGuide"
		    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 6) then
			   require "script/ui/main/MenuLayer"
	        	local copyBoxGuide_button = MenuLayer.getMenuItemNode(3)
			    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
			    CopyBoxGuide.show(7, touchRect)
		   	end
		 ---------------------end-------------------------------------
		--]==]
	elseif(tag == 10006 ) then 
		local shareImagePath = BaseUI.getScreenshots()
		ShareLayer.show("",shareImagePath, 6664, -4002)
	elseif(tag == 10007) then
		print(GetLocalizeStringBy("key_3362"))
		if( BTUtil:getSvrTimeInterval()< ActiveCache.getHeroShopStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getHeroShopEndTime() ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_3025"))
			return
		end
		local args= CCArray:create()
		if(ActiveCache.getFreeNum()<=0) then
			args:addObject(CCInteger:create(3))
			ActiveCache.setBuyHeroType(3)
			if(UserModel.getGoldNumber()< ActiveCache.getGoldCost() ) then
				-- AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
				return
			end

		else
			ActiveCache.setBuyHeroType(2)
			args:addObject(CCInteger:create(2))
		end

		if(_pickUpBtn~= nil) then
        	_pickUpBtn:setEnabled(false)
        end
		Network.rpc(buyHeroCallback, "heroshop.buyHero" , "heroshop.buyHero", args , true)
	elseif( tag == 10004) then

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
	end
end

-- 小星星的特效
local function showStarEffect( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhaojiangxingji.mp3")
	ccPosition = starIndexArr[starIndexForCur]
	starIndexForCur = starIndexForCur + 1
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/zhaojiangxingji"), -1,CCString:create(""));
	spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	spellEffectSprite:setScale(MainScene.bgScale/MainScene.elementScale)
	spellEffectSprite:setPosition(ccPosition)
    -- spellEffectSprite:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5))
    starsBgSp:addChild(spellEffectSprite,99999)

	-- 结束回调
    local animationEnd = function(actionName,xmlSprite)
        local effect =  xmlSprite:getParent()
        
        local starSp = CCSprite:create("images/formation/star.png")
		starSp:setAnchorPoint(ccp(0.5, 0.5))
		-- xScale = starsXPositions[starIndex]
		-- starSp:setPosition(ccp(starsBgSp:getContentSize().width * xScale, starsBgSp:getContentSize().height * starsYPositions[starIndex]))
		local pX, pY = effect:getPosition()
		starSp:setPosition(ccp(pX, pY))
		starsBgSp:addChild(starSp)
		effect:removeFromParentAndCleanup(true)
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)

end

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()

	-- 将领
	require "db/DB_Heroes"
	local heroLocalInfo = DB_Heroes.getDataById(tonumber(_htid))
	
	-- 恭喜
	local c_sprite = CCSprite:create("images/shop/pub/text.png")
	c_sprite:setAnchorPoint(ccp(0.5,0.5))
	c_sprite:setPosition(ccp(bgLayerSize.width*0.5, bgLayerSize.height*0.9))
	_bgLayer:addChild(c_sprite)

	-- 星星
	-- 星星底
	starsBgSp = CCSprite:create("images/formation/stars_bg.png")
	starsBgSp:setAnchorPoint(ccp(0.5, 1))
	starsBgSp:setPosition(ccp(bgLayerSize.width/2, bgLayerSize.height*0.85))
	_bgLayer:addChild(starsBgSp, 2)
	
	-- 星星们
	local starsXPositions = {0.2,0.3,0.4,0.5,0.6,0.7,0.8}
	local starsYPositions = {0.68,0.71,0.74,0.75,0.74,0.71,0.68}

	--对于偶数星星用以下坐标
	--add by zhang zihang
	local starsXPositionsForDouble = {0.25,0.35,0.45,0.55,0.65,0.75}
	local starsYPositionsForDouble = {0.7,0.72,0.745,0.745,0.72,0.7}

	-- local starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.8}
	-- local starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}

	-- if(math.floor(heroLocalInfo.potential, 2) == 0)then
	-- 	starsXPositions = {0.2,0.3,0.4,0.5,0.6,0.7,0.8}
	-- 	starsYPositions = {0.68,0.71,0.74,0.75,0.74,0.71,0.68}
	-- end

	
	starIndexArr = {}
	print("heroLocalInfo.potential==", heroLocalInfo.potential)
	local s_starIndex =  math.floor( ((7-heroLocalInfo.potential)/2.0) ) + 1
	print("s_starIndex==", s_starIndex)

	for starIndex=s_starIndex, ( heroLocalInfo.potential + s_starIndex - 1 )do
		--对于2星，4星用以上位置不能完全居中
		--position changed by zhang zihang
		local position
		if (heroLocalInfo.potential%2) == 0 then
			position = ccp(starsBgSp:getContentSize().width * starsXPositionsForDouble[starIndex], starsBgSp:getContentSize().height * starsYPositionsForDouble[starIndex])
		else
			position = ccp(starsBgSp:getContentSize().width * starsXPositions[starIndex], starsBgSp:getContentSize().height * starsYPositions[starIndex])
		end
		table.insert(starIndexArr, position)
	end

	for starIndex=s_starIndex, ( heroLocalInfo.potential + s_starIndex - 1 ) do
		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(0.5*starIndex))
		actionArr:addObject(CCCallFuncN:create(showStarEffect))
		starsBgSp:runAction(CCSequence:create(actionArr))
	end
	
	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-402)
	_bgLayer:addChild(menuBar,3)

	-- 查看武将的按钮
	local lookHeroBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3136"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	lookHeroBtn:setAnchorPoint(ccp(0.5, 0.5))
	lookHeroBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.5, bgLayerSize.height*0.2))
	lookHeroBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(lookHeroBtn, 2, 10001)

	closeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1324"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
	closeBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.5, bgLayerSize.height*0.08))
	closeBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(closeBtn, 1, 10003)

	-- 分享按钮
	local btnRecuitShare = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2566"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
	-- btnRecuitShare:setScale(g_fElementScaleRatio)
	btnRecuitShare:setAnchorPoint(ccp(0.5, 0.5))
	btnRecuitShare:setVisible(false)
	btnRecuitShare:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.2))
	btnRecuitShare:registerScriptTapHandler(menuAction)
	if(Platform.getOS()~= "wp")then
        menuBar:addChild(btnRecuitShare,1,10006)
    end

	-- 金币消耗(招一次) 
	lookStarBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1157"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	lookStarBtn:setAnchorPoint(ccp(0.5, 0.5))
	lookStarBtn:setVisible(false)
	lookStarBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.2))
	lookStarBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(lookStarBtn, 1, 10002)


	-- 战将招将按钮
	-- 继续招将的按钮
	_lowerRecuitBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1157"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))

	_lowerRecuitBtn:setAnchorPoint(ccp(0.5, 0.5))
	_lowerRecuitBtn:setVisible(false)
	_lowerRecuitBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.2))
	_lowerRecuitBtn:registerScriptTapHandler(menuAction)
	_lowerRecuitBtn:setVisible(false)
	menuBar:addChild(_lowerRecuitBtn,1, 10004)


	-- 分享
	print("recuitType is :  ", _recuitType)	
	if(tonumber(_recuitType) == 3) then
	
		-- 调整查看按钮
		lookHeroBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.2))
		lookStarBtn:setVisible(true)
		require "db/DB_Tavern"
		local db_senior = DB_Tavern.getDataById(3)
		local csGoldIconForOne = CCSprite:create("images/common/gold.png")
		local crlGoldNeedForOne = CCRenderLabel:create(db_senior.gold_needed, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
		crlGoldNeedForOne:setColor(ccc3(0xff, 0xf6, 0))
		crlGoldNeedForOne:setAnchorPoint(ccp(0, 0))
		crlGoldNeedForOne:setPosition(csGoldIconForOne:getContentSize().width+2, 0)
		csGoldIconForOne:addChild(crlGoldNeedForOne)
		local nChildWidth = crlGoldNeedForOne:getContentSize().width+csGoldIconForOne:getContentSize().width
		csGoldIconForOne:setPosition((lookStarBtn:getContentSize().width-nChildWidth)/2, 4)
		csGoldIconForOne:setAnchorPoint(ccp(0, 1))
		lookStarBtn:addChild(csGoldIconForOne)
		addRecruitLeftTimeText()

		-- 微博分享
		if(_star_lv == 5 and Platform.getOS()~= "wp") then
			closeBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.09))
			btnRecuitShare:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.09))
			btnRecuitShare:setVisible(true)
		end

		-- 活动专用 额外掉落 坐标调整
		if(_isActivity and tonumber(_recuitType) == 3)then
			-- 查看武将按钮
			lookHeroBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.14))
			-- 继续购买按钮
			lookStarBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.14))
			-- 退出按钮
			closeBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.5, bgLayerSize.height*0.04))
			if(_star_lv == 5 and Platform.getOS()~= "wp" ) then
				closeBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.04))
				-- 分享按钮
				btnRecuitShare:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.04))
				btnRecuitShare:setVisible(true)
			end
		end
	elseif(tonumber(_recuitType)== 4) then
		createActiveCardUI() 
		lookHeroBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.16))
		if(_star_lv == 5 and Platform.getOS()~= "wp") then
			closeBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.05))
			btnRecuitShare:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.05))
			btnRecuitShare:setVisible(true)
		end
	elseif(tonumber(_recuitType)==1) then
		_lowerRecuitBtn:setVisible(true)
		createLowerRecuitDesc()
		lookHeroBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.25, bgLayerSize.height*0.2))
	end
	
	-- 名称背景
	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBg:setContentSize(CCSizeMake(240, 37))
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(ccp(bgLayerSize.width*0.5, bgLayerSize.height*0.3))
	_bgLayer:addChild(nameBg,2)
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroLocalInfo.potential)
	local nameLabel = CCRenderLabel:create(heroLocalInfo.name, g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setPosition(ccp(nameBg:getContentSize().width/2-nameLabel:getContentSize().width/2, nameBg:getContentSize().height*0.5+nameLabel:getContentSize().height*0.5))
    nameBg:addChild(nameLabel)

    if(_isActivity and tonumber(_recuitType) == 3)then
    	-- 额外获得
    	createGoodsTableView(_dorpItemData)

    	-- 活动专用
    	nameBg:setPosition(ccp(bgLayerSize.width*0.5, _flop_bg:getPositionY()+_flop_bg:getContentSize().height*MainScene.elementScale+nameBg:getContentSize().height*MainScene.elementScale+5*MainScene.elementScale))
    	nameLabel:setPosition(ccp(nameBg:getContentSize().width/2-nameLabel:getContentSize().width/2, nameBg:getContentSize().height*0.5+nameLabel:getContentSize().height*0.5))
    end

end


-- 创建战将招将的描述UI
function createLowerRecuitDesc( )

	require "db/DB_Tavern"
	local tavernDesc = DB_Tavern.getDataById(1)
	local itemArr = string.split(tavernDesc.cost_item, "|")
	local itemRemote = ItemUtil.getCacheItemInfoBy( tonumber(itemArr[1]) )
	local lowerItemNum = 0
	if(itemRemote)then
		lowerItemNum = tonumber(itemRemote.item_num)-1
	end
	require "db/DB_Item_normal"
	local itemDesc = DB_Item_normal.getDataById(tonumber(itemArr[1]))
	local shopInfo = DataCache.getShopCache()


	local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3413") .. lowerItemNum , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numberLabel:setColor(ccc3(0x36, 0xff, 0x00))
    numberLabel:setPosition(_lowerRecuitBtn:getContentSize().width/2, -3)
    numberLabel:setAnchorPoint(ccp(0.5,1))
    _lowerRecuitBtn:addChild(numberLabel)


    local consumLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1771") , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    consumLabel:setColor(ccc3(0xff, 0xff, 0xff))
    local nameLabel = CCRenderLabel:create(itemDesc.name .. "x" .. (itemArr[2]) , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    local contentNode = BaseUI.createHorizontalNode( { consumLabel,nameLabel })
    contentNode:setPosition(_lowerRecuitBtn:getContentSize().width/2, -10-consumLabel:getContentSize().height )
    contentNode:setAnchorPoint(ccp(0.5 ,1))
    _lowerRecuitBtn:addChild(contentNode)

end


-- 创建活动卡包部分的UI
function createActiveCardUI( )
	
	local bgLayerSize = _bgLayer:getContentSize()

	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	_bgLayer:addChild(menu,3)

	_pickUpBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2773"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))

	_pickUpBtn:setAnchorPoint(ccp(0.5, 0.5))
	_pickUpBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.75, bgLayerSize.height*0.16))
	_pickUpBtn:registerScriptTapHandler(menuAction)
	-- pickUpBtn:setVisible(false)
	menu:addChild(_pickUpBtn,1,10007)

	local csGoldIconForOne = CCSprite:create("images/common/gold.png")
	local crlGoldNeedForOne = CCRenderLabel:create(ActiveCache.getGoldCost() , g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
	crlGoldNeedForOne:setColor(ccc3(0xff, 0xf6, 0))
	crlGoldNeedForOne:setAnchorPoint(ccp(0, 0))
	crlGoldNeedForOne:setPosition(csGoldIconForOne:getContentSize().width+2, 0)
	csGoldIconForOne:addChild(crlGoldNeedForOne)
	local nChildWidth = crlGoldNeedForOne:getContentSize().width+csGoldIconForOne:getContentSize().width
	csGoldIconForOne:setPosition((_pickUpBtn:getContentSize().width-nChildWidth)/2, -2)
	csGoldIconForOne:setAnchorPoint(ccp(0, 1))
	_pickUpBtn:addChild(csGoldIconForOne)

	-- 当前的积分
	local hasPointContent= {}
	hasPointContent[1]= CCSprite:create("images/recharge/card_active/has_point.png")
	hasPointContent[2]= CCRenderLabel:create("" .. ActiveCache.getScoreNum(),g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	hasPointContent[2]:setColor(ccc3(0x00,0xff,0x18))
	local hasPointNode = BaseUI.createHorizontalNode(hasPointContent)
	hasPointNode:setPosition(g_winSize.width/2,g_winSize.height*0.24)
	hasPointNode:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(hasPointNode,12)

	-- 获得积分
	local getPointContent = {}
	getPointContent[1]= CCSprite:create("images/recharge/card_active/get_point.png")
	getPointContent[2]= CCRenderLabel:create("" .. ActiveCache.getAddScore() , g_sFontPangWa, 23, 1,ccc3(0x00,0x00,0x00), type_stroke)
	getPointContent[2]:setColor(ccc3(0xff,0x59,0xff))
	local getPointNode = BaseUI.createHorizontalNode(getPointContent)
	getPointNode:setPosition(21,g_winSize.height*0.24)
	getPointNode:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(getPointNode, 12)

	--积分排行
	local rankContent= {}
	rankContent[1]= CCSprite:create("images/recharge/card_active/point_rank.png")
	print("ActiveCache.getRankNum()  is : ", ActiveCache.getRankNum())
	rankContent[2]= CCRenderLabel:create("" .. ActiveCache.getRankNum() , g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00), type_stroke)
	rankContent[2]:setColor(ccc3(0xf9,0x59,0xff))
	local rankNode = BaseUI.createHorizontalNode(rankContent)
	rankNode:setPosition(g_winSize.width*0.7187, g_winSize.height*0.24)
	_bgLayer:addChild(rankNode,12)

	local height = g_winSize.height*0.24-3
	local cardRecuitNode = getRecuitNodeByTime( calCardLeftTime() )
	cardRecuitNode:setPosition(g_winSize.width/2,height)
	cardRecuitNode:setAnchorPoint(ccp(0.5,1))
	_bgLayer:addChild(cardRecuitNode)

end

-- 计算卡包招将剩余次数
function calCardLeftTime()

	local firstTime, afterTime= ActiveCache.getChangeTimes()
	print("firstTime  is : ", firstTime)
	local nRecruitSum = tonumber(ActiveCache.getGoldBuyNum() )
	local nRecruitLeft = 0
	if nRecruitSum <= firstTime then
		nRecruitLeft = firstTime - nRecruitSum - 1
	else
		nRecruitSum = (nRecruitSum - firstTime)%afterTime
		nRecruitLeft = afterTime - nRecruitSum - 1
	end
	if nRecruitLeft < 0 then
		nRecruitLeft = afterTime-1
	end
	return nRecruitLeft
end

function getRecuitNodeByTime( nRecruitLeft )

	local recuitContent = {}

 	recuitContent[1]=  CCRenderLabel:create(GetLocalizeStringBy("key_1470"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[1]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[2] = CCRenderLabel:create("" .. tostring(nRecruitLeft), g_sFontPangWa, 39, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[2]:setColor(ccc3(255,255,255))


 	recuitContent[3]=  CCRenderLabel:create(GetLocalizeStringBy("key_3196"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)

 	recuitContent[3]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[4]=  CCRenderLabel:create(GetLocalizeStringBy("key_1258"), g_sFontPangWa, 29, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[4]:setColor(ccc3(255, 0, 0xe1))
 	recuitContent[5]=  CCRenderLabel:create("!", g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[5]:setColor(ccc3(0x51, 0xfb, 255))

    local recuitNode = BaseUI.createHorizontalNode(recuitContent)
 	if(nRecruitLeft ==0 ) then
 		local recuitThisNode = createRecruitThisNode()
 		return recuitThisNode
 	end
 	return recuitNode

end

-- 增加招将剩于次数文本显示
function addRecruitLeftTimeText()

	-- 再招？次必得一张五星武将
	local shopInfo = DataCache.getShopCache()
	local nRecruitSum = tonumber(shopInfo.gold_recruit_sum)
	local nRecruitLeft = 0
	if nRecruitSum <= 5 then
		nRecruitLeft = 5 - nRecruitSum - 1
	else
		nRecruitSum = (nRecruitSum - 5)%10
		nRecruitLeft = 10 - nRecruitSum - 1
	end
	if nRecruitLeft < 0 then
		nRecruitLeft = 9
	end
 	local recuitContent = {}

 	recuitContent[1]=  CCRenderLabel:create(GetLocalizeStringBy("key_1470"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)

 	recuitContent[1]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[2] = CCRenderLabel:create("" .. tostring(nRecruitLeft), g_sFontPangWa, 39, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[2]:setColor(ccc3(255,255,255))

 	recuitContent[3]=  CCRenderLabel:create(GetLocalizeStringBy("key_3196"), g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[3]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[4]=  CCRenderLabel:create(GetLocalizeStringBy("key_1258"), g_sFontPangWa, 29, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[4]:setColor(ccc3(255, 0, 0xe1))
 	recuitContent[5]=  CCRenderLabel:create("!", g_sFontPangWa, 24, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[5]:setColor(ccc3(0x51, 0xfb, 255))

    local _recuitNode = BaseUI.createHorizontalNode(recuitContent)
 	_recuitNode:setPosition(g_winSize.width/2,g_winSize.height*0.238)
 	_recuitNode:setAnchorPoint(ccp(0.5,0))
 	-- local _recuitNode:setScale(g_fElementScaleRatio)
 	_bgLayer:addChild(_recuitNode,1111)

 	if(nRecruitLeft ==0 ) then
 		_recuitNode:setVisible(false)
 		_recuitThisNode = createRecruitThisNode()
 		_recuitThisNode:setPosition(g_winSize.width/2,g_winSize.height*0.238)
 		_recuitThisNode:setAnchorPoint(ccp(0.5,0))
 		-- _recuitThisNode:setScale(g_fElementScaleRatio)
 		_bgLayer:addChild(_recuitThisNode,1111)

 	end

 	if(_isActivity and tonumber(_recuitType) == 3)then
 		-- 活动专用 显示在最上方
 		_recuitNode:setPosition(g_winSize.width/2,starsBgSp:getPositionY()-starsBgSp:getContentSize().height*MainScene.elementScale-_recuitNode:getContentSize().height*MainScene.elementScale)
 		if(nRecruitLeft == 0)then
 			_recuitThisNode:setPosition(g_winSize.width/2,starsBgSp:getPositionY()-starsBgSp:getContentSize().height*MainScene.elementScale-_recuitThisNode:getContentSize().height*MainScene.elementScale)
 		end
 	end
end

function createRecruitThisNode( )
	local alertContent = {}
	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1019") , g_sFontPangWa, 24,2, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0x51, 0xfb, 255))
	alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_2224") , g_sFontPangWa, 39,2, ccc3(0x00,0,0),type_stroke)
	alertContent[2]:setColor(ccc3(255, 0, 0xe1))
	local alert = BaseUI.createHorizontalNode(alertContent)

	return alert
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		print("began")
		

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -127, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- p_dorpItem:抽将额外掉落物品
function createLayer( hid, htid, sid, stid, p_soul, recuitType, p_dorpItem )

	---[==[等级礼包新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	require "script/guide/LevelGiftBagGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		require "script/guide/LevelGiftBagGuide"
		LevelGiftBagGuide.changLayer()
		print("LevelGiftBagGuide changeLayer")
	end
	---------------------end-------------------------------------
	--]==]
	
	init()
	_hid = hid
	_htid = htid
	_sid = sid
	_stid = stid
	_recuitType = recuitType

	require "script/ui/rechargeActive/ActiveCache"
	_isActivity = ActiveCache.getIsExtraDropAcitive()
	_dorpItemData = p_dorpItem

	require "db/DB_Heroes"
	_star_lv = tonumber( DB_Heroes.getDataById(_htid).star_lv)
	
	_bgLayer = MainScene.createBaseLayer("images/shop/pub/pubbg.jpg", false, false, false)
	_bgLayer:registerScriptHandler(onNodeEvent)
	_p_soul = p_soul or 0
	if(_stid == nil)then
		require "db/DB_Star"
		local star_info = DB_Star.getArrDataByField("pre_hid", tonumber(_htid))
		if(not table.isEmpty(star_info))then
			local allStar = DataCache.getStarArr()
			local t_htid = star_info[1].id
			if( not table.isEmpty(allStar) )then
				for k,v in pairs(allStar) do
					if(tonumber(v.star_tid) == tonumber(t_htid))then
						_sid = tonumber(v.star_id)
						_stid = tonumber(t_htid)
						break
					end
				end
			end
		end
	end

	-- 法阵
	-- _fiveStarBg = CCSprite:create("images/shop/pub/fivestarbg.png")
	-- _fiveStarBg:setAnchorPoint(ccp(0.5,0.5))
	-- _fiveStarBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	-- _bgLayer:addChild(_fiveStarBg, 1)

	createAnimation()

	create()
	
	-- addby licong 2013.09.09
	if(didGetHero ~= nil)then
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			didGetHero()

		end))
		_bgLayer:runAction(seq)
	end
	---------------------------
	if(didClickZhaoJiangCallback ~= nil)then
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			didClickZhaoJiangCallback()

		end))
		_bgLayer:runAction(seq)
	end

	local seq2 = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addCopyBoxGuide()
	end))
	_bgLayer:runAction(seq2)

	return _bgLayer
end

-- 新手引导
function getGuideObject( )
	return closeBtn
end


--add By lichenyang

function registerHeroDisplayerLayerCloseCallback( p_callback )
	heroDisplayerLayerCloseCallback = p_callback
end

function registerDidClickZhaoJiangCallback( p_callback )
	didClickZhaoJiangCallback = p_callback
end

-- add by licong 2013.09.09
function registerDidGetHeroCallBack( callBack )
	didGetHero = callBack
end
-----------------------------

function addCopyBoxGuide( ... )
	---[==[  副本箱子 第6步 退出招将
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 5) then
		    local copyBoxGuide_button = HeroDisplayerLayer.getGuideObject()
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(6, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]
end


--- 创建额外掉落tableView
function createGoodsTableView( p_flopData )
	-- 掉落物品背景
	if(_flop_bg)then
		_flop_bg:removeFromParentAndCleanup(true)
		_flop_bg = nil
	end
	_flop_bg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_flop_bg:setContentSize(CCSizeMake(450, 140))
	_flop_bg:setAnchorPoint(ccp(0.5, 0))
	_flop_bg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, lookStarBtn:getPositionY()*MainScene.elementScale+lookStarBtn:getContentSize().height*0.5*MainScene.elementScale))
	_bgLayer:addChild(_flop_bg,10)
	-- 掉落标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(250, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(_flop_bg:getContentSize().width*0.5, _flop_bg:getContentSize().height))
	_flop_bg:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10053"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
    titleSprite:addChild(titleLabel)

	local itemData = getDropItem(p_flopData) 
	local cellSize = CCSizeMake(450, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.2,0.5,0.8}
			for i=1,3 do
				if(itemData[a1*3+i] ~= nil)then
					local item_sprite = ItemUtil.createGoodsIcon(itemData[a1*3+i],-390, nil, -450)
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(450*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #itemData
			r = math.ceil(num/3)
		else
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(450, 120))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(-400)
	-- 上下滑动
	goodTableView:setDirection(kCCScrollViewDirectionVertical)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	goodTableView:setPosition(ccp(0,2))
	_flop_bg:addChild(goodTableView)
end


-- 整理额外掉落物品
function getDropItem( p_drop  )
	local items = {}
	if( not table.isEmpty(p_drop)) then
	 	for k,v in  pairs(p_drop) do
			local item = {}
			item.tid  = k
			item.num = v
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items, item)
		end
	end
	return items
end



