-- Filename: TenHeroRecuitLayer.lua
-- Author: zhz
-- Date: 2013-11-15
-- Purpose: 该文件用于: 十连抽的Layer

module ("TenHeroRecuitLayer", package.seeall)

require "script/libs/LuaCC"
require "script/ui/shop/SeniorHeroRecruitLayer"
require "script/utils/CardTurnView"
require "script/network/RequestCenter"
require "script/ui/share/ShareLayer"
require "script/utils/BaseUI"
require "script/ui/tip/LackGoldTip"

local _tagPopupPanel=2001
local _tagCloseButton=2002
local _tagRecruitOne=2003
local _tagRecruitTen=2004
local _tagRecuitShare = 2005
-- 招将10次界面相关变量
local _tagPopupPanelOfRecruitTen=3001
local _tagQuit = 3002
-- 法阵特效
local _tagFazheng = 4001

local _allHeroes = {}
-- 招将10次界面背景层
local _clRecruitTenBg
-- local _arrObjsRecruitText
local _arrObjsCardShow

local btnRecruitOne
local btnRecruitTen
local btnRecruitTen
local btnRecruitQuit
local btnRecuitShare

local _recuitNode
local _recuitThisNode

local _costGoldOfTen 		-- 十连抽消耗的金币
local _numOfTenRecuit		-- 十连抽抽的武将

local csConsTitle = nil
local _isActivity = false -- 活动专用 获得额外物品
local _flop_bg = nil 
local _dorpItemData = nil -- 抽神将额外掉落物品

local function fnInitOfRecruitTen( ... )
	_arrObjsRecruitText = {}
	_arrObjsCardShow={}
	_clRecruitTenBg = nil
	--_allHeroes ={}
	btnRecruitOne = nil
    btnRecruitTen= nil
	btnRecruitTen= nil
	_recuitNode= nil
	_recuitThisNode = nil

	_costGoldOfTen = nil
	_numOfTenRecuit = nil

	csConsTitle = nil
	_isActivity = false
	_flop_bg = nil 
	_dorpItemData = nil

end


function createRecruitTenLayer( )
	fnInitOfRecruitTen( )

	-- 是否开启活动 有额外掉落
	require "script/ui/rechargeActive/ActiveCache"
	_isActivity = ActiveCache.getIsExtraDropAcitive()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local clBg = CCLayer:create()
	_clRecruitTenBg = clBg
	clBg:setTouchEnabled(true)
	clBg:registerScriptTouchHandler(function ( ... )
		return true
	end, false, -768, true)

	local csBg = CCSprite:create("images/shop/pub/pubbg.jpg")
	csBg:setPosition(g_winSize.width/2, g_winSize.height/2)
	csBg:setAnchorPoint(ccp(0.5, 0.5))
	csBg:setScale(g_fBgScaleRatio)
	clBg:addChild(csBg)
	runningScene:addChild(clBg, 1001, _tagPopupPanelOfRecruitTen)

	csConsTitle = CCSprite:create("images/shop/pub/congratulations.png")
	csConsTitle:setScale(g_fElementScaleRatio)
	csConsTitle:setAnchorPoint(ccp(0.5, 0))
	csConsTitle:setPosition(g_winSize.width/2, g_winSize.height*0.85)
	clBg:addChild(csConsTitle)

	if(_isActivity)then
		csConsTitle:setPosition(g_winSize.width/2, g_winSize.height*0.87)
	end

	createRecruitBtn()

	-- 特效
	createFazhenEffect( ) 
	-- local item =   createTurnCardByHtid(10089) 
	-- item:setPosition(ccps(0.5,0.5))
	-- clBg:addChild(item)

end

 -- 增加卡牌形象显示
function addHeroCardShow(  )


	local x_start = g_winSize.width * 0.12
	local x = x_start
	local y = g_winSize.height * 0.72
	if(not table.isEmpty(_arrObjsCardShow)) then
		for i=1, #_arrObjsCardShow do
			_arrObjsCardShow[i]:removeFromParentAndCleanup(true)
			_arrObjsCardShow[i] = nil
		end
	end
	tHeroes = _allHeroes
	_arrObjsCardShow = {}

	if tHeroes then
		local x_offset = g_winSize.width*0.189
		for i=1, 10 do
			if i == 6 then
				x = x_start
				y = g_winSize.height * 0.5
			end
			local csItem =  createTurnCardByHtid(tHeroes[i])  
			csItem:setPosition(x, y)
			csItem:setVisible(false)
			_clRecruitTenBg:addChild(csItem,111)
			x = x + x_offset
			table.insert(_arrObjsCardShow, csItem)

			-- action
			local duration = 0.00001+ (i-1) *0.08
			createOppOCardAnimation(csItem,duration)

		end
	end
end

function releaseHeroCard( )
	if(not table.isEmpty(_arrObjsCardShow)) then
		for i=1, #_arrObjsCardShow do
			_arrObjsCardShow[i]:removeFromParentAndCleanup(true)
			_arrObjsCardShow[i] = nil
		end
	end
	_arrObjsCardShow = {}
	
	-- 掉落物品背景
	if(_flop_bg)then
		_flop_bg:removeFromParentAndCleanup(true)
		_flop_bg = nil
	end
end

-- 3个按钮
function createRecruitBtn( )

	require "db/DB_Tavern"
	local db_senior = DB_Tavern.getDataById(3)

	_numOfTenRecuit = tonumber(lua_string_split(db_senior.gold_nums, "|")[1])
	_costGoldOfTen = tonumber(lua_string_split(db_senior.gold_nums, "|")[2])

	-- 按钮, 招将1次

	btnRecruitOne = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2893"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))

  	btnRecruitOne:registerScriptTapHandler(fnHandlerOfRecruitTenUI)
	btnRecruitOne:setScale(g_fElementScaleRatio)
	btnRecruitOne:setPosition(g_winSize.width*0.15, g_winSize.height*0.15)
	btnRecruitOne:setAnchorPoint(ccp(0, 0))
	-- 按钮, 招将10次

	btnRecruitTen = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210, 73),GetLocalizeStringBy("key_3420").. _numOfTenRecuit ..GetLocalizeStringBy("key_3421"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))

	btnRecruitTen:setScale(g_fElementScaleRatio)
	btnRecruitTen:registerScriptTapHandler(fnHandlerOfRecruitTenUI)
	btnRecruitTen:setPosition(g_winSize.width*0.55, g_winSize.height*0.15)
	btnRecruitTen:setAnchorPoint(ccp(0, 0))

	-- 按钮, 退出
	btnRecruitQuit = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3344"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
	btnRecruitQuit:setScale(g_fElementScaleRatio)
	-- btnRecruitQuit:setAnchorPoint(ccp(0.5, 0))
	if(Platform.getOS() == "wp")then
		btnRecruitQuit:setAnchorPoint(ccp(0.5, 0))
		btnRecruitQuit:setPosition(g_winSize.width*0.5, g_winSize.height*0.02)
	else
		btnRecruitQuit:setPosition(g_winSize.width*0.55, g_winSize.height*0.02)
	end
	
	btnRecruitQuit:registerScriptTapHandler(fnHandlerOfRecruitTenUI)

	-- 分享按钮
	btnRecuitShare = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2566"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
	btnRecuitShare:setScale(g_fElementScaleRatio)
	-- btnRecuitShare:setAnchorPoint(ccp(0.5, 0))
	btnRecuitShare:setScale(g_fElementScaleRatio)
	btnRecuitShare:setPosition(g_winSize.width*0.15, g_winSize.height*0.02)
	btnRecuitShare:registerScriptTapHandler(fnHandlerOfRecruitTenUI)

	-- 几个按钮菜单
	local cmRecruitHero = CCMenu:create()
	cmRecruitHero:setPosition(0, 0)
	cmRecruitHero:setTouchEnabled(true)
	cmRecruitHero:setTouchPriority(-769)
	cmRecruitHero:addChild(btnRecruitOne, 0, _tagRecruitOne)
	cmRecruitHero:addChild(btnRecruitTen, 0, _tagRecruitTen)
	cmRecruitHero:addChild(btnRecruitQuit, 0, _tagQuit)
	if(Platform.getOS()~= "wp")then
		cmRecruitHero:addChild(btnRecuitShare,0,_tagRecuitShare)
	end

	-- 开始先让3个按钮不可见
	btnRecruitOne:setVisible(false)
	btnRecruitTen:setVisible(false)
	btnRecruitQuit:setVisible(false)
	if(Platform.getOS()~= "wp")then
		btnRecuitShare:setVisible(false)
	end

	_clRecruitTenBg:addChild(cmRecruitHero,111)


	-- 金币消耗(招一次)
	local csGoldIconForOne = CCSprite:create("images/common/gold.png")
	local nGoldIconWidth = csGoldIconForOne:getContentSize().width
	local crlGoldNeedForOne = CCRenderLabel:create(db_senior.gold_needed, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
	crlGoldNeedForOne:setColor(ccc3(0xff, 0xf6, 0))
	crlGoldNeedForOne:setAnchorPoint(ccp(0, 0))
	crlGoldNeedForOne:setPosition(nGoldIconWidth+2, 0)
	csGoldIconForOne:addChild(crlGoldNeedForOne)
	local nChildWidth = nGoldIconWidth+2+crlGoldNeedForOne:getContentSize().width
	csGoldIconForOne:setPosition((btnRecruitOne:getContentSize().width-nChildWidth)/2, -4)
	csGoldIconForOne:setAnchorPoint(ccp(0, 1))
	btnRecruitOne:addChild(csGoldIconForOne)

	-- 金币消耗(招十次)
	local csGoldIconForTen = CCSprite:create("images/common/gold.png")
	local crlGoldNeedForTen = CCRenderLabel:create(_costGoldOfTen, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
	crlGoldNeedForTen:setColor(ccc3(0xff, 0xf6, 0))
	crlGoldNeedForTen:setAnchorPoint(ccp(0, 0))
	crlGoldNeedForTen:setPosition(csGoldIconForTen:getContentSize().width+2, 0)
	csGoldIconForTen:addChild(crlGoldNeedForTen)

	local nChildWidth = nGoldIconWidth+2+crlGoldNeedForTen:getContentSize().width

	csGoldIconForTen:setPosition((btnRecruitTen:getContentSize().width-nChildWidth)/2, -4)
	csGoldIconForTen:setAnchorPoint(ccp(0, 1))

	btnRecruitTen:addChild(csGoldIconForTen)

	-- 活动专用 额外掉落 坐标调整
	if(_isActivity)then
		-- 购买一次按钮
		btnRecruitOne:setPosition(g_winSize.width*0.15, g_winSize.height*0.15)
		-- 购买十次按钮
		btnRecruitTen:setPosition(g_winSize.width*0.55, g_winSize.height*0.15)
		if(Platform.getOS() == "wp")then
			-- 退出按钮
			btnRecruitQuit:setAnchorPoint(ccp(0.5, 0))
			btnRecruitQuit:setPosition(g_winSize.width*0.5, g_winSize.height*0.02)

		else
			-- 退出按钮
			btnRecruitQuit:setPosition(g_winSize.width*0.55, g_winSize.height*0.02)
			-- 分享按钮
			btnRecuitShare:setPosition(g_winSize.width*0.15, g_winSize.height*0.02)
		end
	end

	addRecruitLeftTimeText(_clRecruitTenBg)

end

-- 增加招将剩于次数文本显示
function addRecruitLeftTimeText(ccParent)
	if #_arrObjsRecruitText >= 1 then
		_arrObjsRecruitText[1]:removeFromParentAndCleanup(true)
	end
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
		nRecruitLeft = 0
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

    _recuitNode = BaseUI.createHorizontalNode(recuitContent)
 	_recuitNode:setPosition(g_winSize.width/2,g_winSize.height*0.24)
 	_recuitNode:setAnchorPoint(ccp(0.5,0))
 	_recuitNode:setVisible(false)
 	_recuitNode:setScale(g_fElementScaleRatio)
 	ccParent:addChild(_recuitNode,1111)

 	if(nRecruitLeft ==0 ) then
 		_recuitNode:setVisible(false)
 		_recuitThisNode = createRecruitThisNode()
 		_recuitThisNode:setPosition(g_winSize.width/2,g_winSize.height*0.24)
 		_recuitThisNode:setAnchorPoint(ccp(0.5,0))
 		_recuitThisNode:setScale(g_fElementScaleRatio)
 		_recuitThisNode:setVisible(false)
 		ccParent:addChild(_recuitThisNode,1111)

 	end

 	if(_isActivity)then
 		-- 活动专用 显示在最上方
 		_recuitNode:setPosition(g_winSize.width/2,csConsTitle:getPositionY()-_recuitNode:getContentSize().height*MainScene.elementScale)
 		if(nRecruitLeft == 0)then
 			_recuitThisNode:setPosition(g_winSize.width/2,csConsTitle:getPositionY()-_recuitThisNode:getContentSize().height*MainScene.elementScale)
 		end
 	end
end

-- 让3个按钮可见
function setBottomVisible( )

	btnRecruitOne:setVisible(true)
	btnRecruitTen:setVisible(true)
	btnRecruitQuit:setVisible(true)
	btnRecruitTen:setEnabled(true)
	btnRecruitOne:setEnabled(true)
	btnRecruitQuit:setEnabled(true)

	if(Platform.getOS()~= "wp")then
        btnRecuitShare:setVisible(true)
        btnRecuitShare:setEnabled(true)
    end

	_recuitNode:setVisible(true)
	if(_recuitThisNode~= nil) then
		_recuitNode:setVisible(false)
		_recuitThisNode:setVisible(true)
	end

    -- 展示额外获得的物品
	if(_isActivity)then
    	createGoodsTableView(_dorpItemData)
    end
end

function createRecruitThisNode( )
	local alertContent = {}
	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1171") , g_sFontPangWa, 24,2, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0x51, 0xfb, 255))
	alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_2224") , g_sFontPangWa, 39,2, ccc3(0x00,0,0),type_stroke)
	alertContent[2]:setColor(ccc3(255, 0, 0xe1))
	local alert = BaseUI.createHorizontalNode(alertContent)

	return alert
end

-- 创建法阵特效
function createFazhenEffect( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/fazhenguangbao.mp3")

    local orignEffect = _clRecruitTenBg:getChildByTag(_tagFazheng)
    if(orignEffect) then
    	orignEffect:removeFromParentAndCleanup(true)
    	orignEffect = nil
    end

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/fazhengguang"), -1,CCString:create(""));
	spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	spellEffectSprite:setScale(g_fBgScaleRatio)
    spellEffectSprite:setPosition(ccp(_clRecruitTenBg:getContentSize().width * 0.5, _clRecruitTenBg:getContentSize().height * 0.5))
    _clRecruitTenBg:addChild(spellEffectSprite, 1,_tagFazheng)

    local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/fazhenguangbao"), -1,CCString:create(""));
    spellEffectSprite_2:setAnchorPoint(ccp(0.5, 0.5))
    spellEffectSprite_2:retain()
    spellEffectSprite_2:setScale(g_fBgScaleRatio)
    spellEffectSprite_2:setPosition(ccp(_clRecruitTenBg:getContentSize().width * 0.5, _clRecruitTenBg:getContentSize().height * 0.5))
    _clRecruitTenBg:addChild(spellEffectSprite_2,2);

        -- 结束回调
    --  spellEffectSprite_2:registerAnimationEvent(function ( eventType,layerSprite )
    --     print("eventType = ",eventType)
    --     if(eventType == "Ended") then
    --         spellEffectSprite_2:removeFromParentAndCleanup(true)
    --         spellEffectSprite_2 = nil
    --       createPaAnimation()
    --     end
    -- end)

	local animationEnd = function(actionName,xmlSprite)
		spellEffectSprite_2:retain()
		spellEffectSprite_2:autorelease()
        spellEffectSprite_2:removeFromParentAndCleanup(true)
        spellEffectSprite_2 = nil
        createPaAnimation()
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
 	
    spellEffectSprite_2:setDelegate(delegate)

end


function createPaAnimation( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/jinbizhaojiangbao.mp3")

	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/jinbizhaojiangbao" ), -1,CCString:create(""));
	spellEffectSprite:setScale(MainScene.bgScale/MainScene.elementScale)
    spellEffectSprite:setPosition(ccp(_clRecruitTenBg:getContentSize().width*0.5, _clRecruitTenBg:getContentSize().height*0.5))
    spellEffectSprite:setAnchorPoint(ccp(0, 0));
    spellEffectSprite:retain()
    _clRecruitTenBg:addChild(spellEffectSprite,9999);

     --delegate
    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
		spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)

        addHeroCardShow()
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


-- 20张卡牌翻转
function allHeroesTurn(  )

	local delX = 0.09
	for i=1, #_arrObjsCardShow do
		local duration = 0.08
		local delayTime = 0.01

		local array = CCArray:create()
		array:addObject(CCDelayTime:create(delX))
		array:addObject(CCCallFunc:create(function ( ... )
			if(i == 10) then
				print("setBottomVisible :" , i)
				_arrObjsCardShow[i]:openCard(duration,delayTime,setBottomVisible)
			else
				_arrObjsCardShow[i]:openCard(duration,delayTime)
			end
		end))
		_arrObjsCardShow[i]:runAction(CCSequence:create(array))
		delX = delX + 0.09
	end
end

-- 创建卡牌由大缩小的特效
function createOppOCardAnimation( tCard,duration)
	local scale = tCard:getScale()
	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(duration))
	actionArr:addObject(CCCallFuncN:create(function ( ... )
	   tCard:setVisible(true)
	end))
	actionArr:addObject(CCScaleTo:create(0.01,scale * 2))
	actionArr:addObject(CCScaleTo:create(0.07,scale))

	if(#_arrObjsCardShow == 10 ) then
		actionArr:addObject(CCCallFuncN:create(function ( ... )
	  		 allHeroesTurn( )
		end))
	end
	tCard:runAction(CCSequence:create(actionArr))

end

--  通过英雄htid 创建可翻转的卡牌
function createTurnCardByHtid( htid)
	local inCard =  getHeroCardByHtid( htid)
	local outCard = getOppoCard()
	print("outCard is : ", outCard)
	local turnCard = CardTurnView:create(inCard , outCard)

	return turnCard

end

-- 获得背面的卡牌
function getOppoCard( )
	local csItem = CCSprite:create("images/shop/pub/card_opp.png")
	local fOppScale = 0.33*g_fElementScaleRatio
	csItem:setScale(fOppScale)
	return csItem
end

-- 通过英雄的htid获得的英雄卡牌
function getHeroCardByHtid( htid )
	require "script/battle/BattleCardUtil"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroPublicLua"

	local cardScale = 0.85*g_fElementScaleRatio

	local csItem = BattleCardUtil.getFormationPlayerCard(nil, nil, htid)
	csItem:setScale(cardScale)
	csItem:setAnchorPoint(ccp(0, 0))

	local db_hero = DB_Heroes.getDataById(htid)
	local color = HeroPublicLua.getCCColorByStarLevel(db_hero.star_lv)
	local crlName = CCRenderLabel:create(db_hero.name, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	crlName:setAnchorPoint(ccp(0.5, 1))
	crlName:setColor(color)
	crlName:setPosition(csItem:getContentSize().width/2, -10)
	csItem:addChild(crlName)

	local tElements = {}
	for i=1, db_hero.star_lv do
		table.insert(tElements, {ctype=LuaCC.m_ksTypeSprite, file="images/shop/pub/star.png"})
	end
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
	for i=1, #tObjs do
		tObjs[i]:setAnchorPoint(ccp(0, 0))
	end
	tObjs[1]:setPosition((csItem:getContentSize().width-tObjs[1]:getContentSize().width*db_hero.star_lv)/2, csItem:getContentSize().height+12)
	csItem:addChild(tObjs[1], 1000)
	return csItem
end




-------------------------------------------- 回调及网络函数函数 -----------------------------------------------
-- 保存所有武将的形象
function setAllHeroes( tHeroes)

	_allHeroes = tHeroes
	require "db/DB_Heroes"

	local function keySort ( hero_1, hero_2 )
		local heroData1 = DB_Heroes.getDataById(hero_1)
		local heroData2 = DB_Heroes.getDataById(hero_2)
	   	return tonumber(heroData1.star_lv) < tonumber(heroData2.star_lv)
	end
	table.sort( _allHeroes, keySort )
end

-- 保存招将十次额外掉落物品
function setAllItems( p_dropItems )
	_dorpItemData = p_dropItems
end

 -- 关闭按钮的回调函数
function fnMenuItemCb( )
	_clRecruitTenBg:removeFromParentAndCleanup(true)
	_clRecruitTenBg = nil
end


-- 招将1次网络回调处理
fnHandlerOfNetworkRecruitOne = function (cbFlag, dictData, bRet)
	if bRet then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local seniorPanel = runningScene:getChildByTag(_tagPopupPanelOfRecruitTen)
		if seniorPanel then
			seniorPanel:removeFromParentAndCleanup(true)
		end

		local shopInfo = DataCache.getShopCache()
		if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
			DataCache.addGoldFreeNum(-1)
		else
			require "db/DB_Tavern"
			local seniorDesc = DB_Tavern.getDataById(3)
			DataCache.changeFirstStatus()
			UserModel.addGoldNumber(-seniorDesc.gold_needed)
		end
		DataCache.changeGoldRecruitSum(1)
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
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint,3,dictData.ret.item)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

-- 招将10次网络回调处理
function fnHandlerOfNetworkRecruitTen(cbFlag, dictData, bRet)

	if bRet then
		-- 减去所消耗金币
		UserModel.addGoldNumber(-_costGoldOfTen )
		DataCache.changeFirstStatus()
		local arrHeroes={}
		for k, v in pairs(dictData.ret.hero) do
			table.insert(arrHeroes, v)
		end
		setAllHeroes( arrHeroes)
		-- 获得额外掉落的物品
		setAllItems(dictData.ret.item)
		releaseHeroCard()
		createFazhenEffect()
		--createPaAnimation()
		--addHeroCardShow(arrHeroes)
	end
end

-- 按钮处理函数
function fnHandlerOfRecruitTenUI(tag, obj)
	-- 招将1次按钮事件处理
	if tag == _tagRecruitOne then
		local shopInfo = DataCache.getShopCache()
		if (tonumber(shopInfo.gold_recruit_num) > 0) then
			local args = Network.argsHandler(0, 1)
			RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
		else
			require "db/DB_Tavern"
			local db_tavern = DB_Tavern.getDataById(3)
			if (UserModel.getGoldNumber() >= (db_tavern.gold_needed)) then
				_nCostGold = db_tavern.gold_needed
				local args = Network.argsHandler(1, 1)
				RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
			else
				-- AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
				LackGoldTip.showTip( )
			end
		end
	-- 招将10次按钮事件处理	
	elseif tag == _tagRecruitTen then
		require "db/DB_Tavern"
		local db_tavern = DB_Tavern.getDataById(3)
		if (UserModel.getGoldNumber() >= _costGoldOfTen) then
			local sureCallBack = function()
				btnRecruitTen:setEnabled(false)
				if(Platform.getOS()~= "wp")then
		 			btnRecuitShare:setEnabled(false)
		 		end
		 		btnRecruitOne:setEnabled(false)
				btnRecruitTen:setEnabled(false)
				btnRecruitQuit:setEnabled(false)
				local args = Network.argsHandler(1, _numOfTenRecuit)
				RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitTen, args)
			end

			--弹购买花费的板子
			local tip_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1132") .. _costGoldOfTen,g_sFontName,25)
			tip_1:setColor(ccc3(0x78,0x25,0x00))
			local goldSprite = CCSprite:create("images/common/gold.png")
			local tip_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1133"),g_sFontName,25)
			tip_2:setColor(ccc3(0x78,0x25,0x00))

			local insertNode = BaseUI.createHorizontalNode({tip_1,goldSprite,tip_2})

			require "script/ui/tip/TipByNode"
			TipByNode.showLayer(insertNode,sureCallBack)
		else
			-- AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
			LackGoldTip.showTip()
		end
	-- 退出按钮事件处理
	elseif tag == _tagQuit then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local seniorPanel = runningScene:getChildByTag(_tagPopupPanelOfRecruitTen)
		if seniorPanel then
			seniorPanel:removeFromParentAndCleanup(true)
		end

		require "script/ui/shop/ShopLayer"
		-- ShopLayer.refreshTopUI()
		local  shopLayer = ShopLayer.createLayer()
		MainScene.changeLayer(shopLayer, "shopLayer",  ShopLayer.layerWillDisappearDelegate)

	elseif tag == _tagRecuitShare then
		local shareImagePath = BaseUI.getScreenshots()
		ShareLayer.show("",shareImagePath, 6664, -4002)

	end
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
	_flop_bg:setPosition(ccp(_clRecruitTenBg:getContentSize().width*0.5, btnRecruitTen:getPositionY()+btnRecruitTen:getContentSize().height*MainScene.elementScale))
	_clRecruitTenBg:addChild(_flop_bg,10)
	_flop_bg:setScale(g_fElementScaleRatio)
	-- 掉落标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(250, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(_flop_bg:getContentSize().width*0.5, _flop_bg:getContentSize().height))
	_flop_bg:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10055"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
					local item_sprite = ItemUtil.createGoodsIcon(itemData[a1*3+i],-768, nil, -800)
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
	goodTableView:setTouchPriority(-769)
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
