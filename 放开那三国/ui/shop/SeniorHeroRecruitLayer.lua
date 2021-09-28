-- Filename: SeniorHeroRecruitLayer.lua
-- Author: fang
-- Date: 2013-09-30
-- Purpose: 该文件用于: 神将招将功能

module("SeniorHeroRecruitLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/tip/LackGoldTip"
require "db/DB_Heroes"
require "db/DB_Hero_view"


local _tagPopupPanel=2001
local _tagCloseButton=2002
local _tagRecruitOne=2003
local _tagRecruitTen=2004
-------------add by DJN
local _tagPrewButton = 2005
----------------------------

-- 招将10次界面相关变量
local _tagPopupPanelOfRecruitTen=3001
local _tagQuit = 3002
-- 招将10次界面背景层
local _clRecruitTenBg
local _arrObjsRecruitText
local _arrObjsCardShow

-- 消耗金币
local _nCostGold

local _costGoldOfTen 		-- 十连抽消耗的金币
local _numOfTenRecuit		-- 十连抽抽的武将

local fnHandlerOfNetworkRecruitOne

local _btnRecruitOne
--------------------------add by DJN 2014/11/21
local _heroTable  = {}      -- 中间循环播放的武将们的信息
local _scrollView 
-- local _leftStar   = nil
-- local _curStar    = nil
-- local _rightStar  = nil
-- local _leftTag    = nil
-- local _curTag     = nil
-- local _rightTag   = nil
-- local _maxTag     = nil
-- local _tagTable   = {}
local _nextIndex  
--local _curTime    = nil
--local _starBg
local _starTable = {}
local _curIndex 
--local _starPositionTable = {}
------------------------------------------------
function init()
	
	_heroTable = getAll13QualityHero()
	_maxTag = table.count(_heroTable)
	--print_t(_heroTable)
	-- _leftTag = 11
	-- _curTag = 1
	-- _rightTag = 2
	-- _tagTable = {_maxTag,1,2}
	_nextIndex = 1 
	--_curTime   = nil
	--_starBg = nil
	_starTable = {}
	_curIndex = nil
	--_starPositionTable = {}
end

-- “关闭”按钮事件回调处理
local function fnHandlerOfSenionRecruit(tag, obj)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	----------------add by DJN 招将预览 -----------
	if(tag == _tagPrewButton)then
		require "script/ui/shop/PreRecruitLayer"
		PreRecruitLayer.createLayer()
		local layer = PreRecruitLayer.createLayer()
		local scene = CCDirector:sharedDirector():getRunningScene()
    	scene:addChild(layer,3001,2014)
		return
	end
	---------------------------------------------
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local seniorPanel = runningScene:getChildByTag(_tagPopupPanel)
	if seniorPanel then
		seniorPanel:removeFromParentAndCleanup(true)
	end
	if tag == _tagCloseButton then
		
	elseif tag == _tagRecruitOne then
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
				--AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
				LackGoldTip.showTip()
			end
		end
	elseif tag == _tagRecruitTen then
		local db_tavern = DB_Tavern.getDataById(3)

		if (UserModel.getGoldNumber() < _costGoldOfTen) then
			-- _nCostGold = db_tavern.gold_needed*10
			-- local args = Network.argsHandler(1, 10)
			-- RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitTen, args)
			--AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
			LackGoldTip.showTip()
			return			
		end

		local sureCallBack = function()
			require "script/ui/shop/TenHeroRecuitLayer"
			dealRecuitTen()
			--TenHeroRecuitLayer.createRecruitTenLayer()
		end

	--	createRecruitTenLayer()

		--弹购买花费的板子
		local tip_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1132") .. _costGoldOfTen,g_sFontName,25)
		tip_1:setColor(ccc3(0x78,0x25,0x00))
		local goldSprite = CCSprite:create("images/common/gold.png")
		local tip_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1133"),g_sFontName,25)
		tip_2:setColor(ccc3(0x78,0x25,0x00))

		local insertNode = BaseUI.createHorizontalNode({tip_1,goldSprite,tip_2})

		require "script/ui/tip/TipByNode"
		TipByNode.showLayer(insertNode,sureCallBack)
	end

end

local function fnFilterTouchEvent( ... )
	return true
end

-- 当本次招将免费时，用文字“本次招将免费”来替换 图文：金币280
local function createGoldFreeLabel( )
	local alertContent = {}

	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2511"), g_sFontPangWa, 22, 2, ccc3(0, 0, 0), type_stroke)
	alertContent[1]:setColor(ccc3(0x36, 0xff, 0x00))

	local alertNode = BaseUI.createHorizontalNode(alertContent)
	return alertNode
end



-- 创建神将招将面板
function createSeniorHeroRecruitPanel( ... )
	init()

	local runningScene = CCDirector:sharedDirector():getRunningScene()

	-- 创建灰色摭罩层
	local cclMask = CCLayerColor:create(ccc4(10,10,10, 180))
	cclMask:setTouchEnabled(true)
	cclMask:registerScriptTouchHandler(function ( ... )
		return true
	end, false, -4000, true)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local ccSpriteBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	ccSpriteBg:setPreferredSize(CCSizeMake(525, 665))
	ccSpriteBg:setScale(g_fElementScaleRatio)
	ccSpriteBg:setPosition(g_winSize.width/2, g_winSize.height/2)
	ccSpriteBg:setAnchorPoint(ccp(0.5, 0.5))
	cclMask:addChild(ccSpriteBg)

	local bg_size = ccSpriteBg:getContentSize()
    ------------------add by DJN 2014/11/21---------------------------------------
	local secondBg = CCSprite:create("images/shop/heroBg.png")
	secondBg:setAnchorPoint(ccp(0.5,0.5))
	secondBg:setPosition(ccp(bg_size.width*0.5,bg_size.height*0.5))
	ccSpriteBg:addChild(secondBg)

	--聚光灯
	local spotLightSp = CCSprite:create("images/formation/spotlight.png")
	spotLightSp:setAnchorPoint(ccp(0.5,1))
	spotLightSp:setPosition(ccp(secondBg:getContentSize().width/2, secondBg:getContentSize().height*0.98 ))
	secondBg:addChild(spotLightSp, 1)
	--星星底
	local starBg = CCSprite:create("images/shop/pub/star_bottom.png")
	starBg:setAnchorPoint(ccp(0.5,1))
	starBg:setPosition(ccp(secondBg:getContentSize().width *0.5,secondBg:getContentSize().height *0.95))
	secondBg:addChild(starBg,2)

	local starsXPositions = {0.16,0.31,0.452,0.592,0.74}
	local starsYPositions = {0.495,0.53,0.546,0.528,0.495}


	for i=1,5 do 
		_starTable[i] = CCSprite:create("images/formation/star.png")
	
		_starTable[i]:setPosition(ccp(starBg:getContentSize().width * starsXPositions[i], starBg:getContentSize().height * starsYPositions[i]))
		starBg:addChild(_starTable[i])
		_starTable[i]:setVisible(false)
	end


	_scrollView = CCScrollView:create()
    _scrollView:setViewSize(CCSizeMake(500, 400))
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setAnchorPoint(ccp(0.5,0))
    _scrollView:setPosition(ccp(secondBg:getContentSize().width *0.5,220))
    _scrollView:setTouchEnabled(false)
  	_scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setContentOffset(ccp(0,0))
    secondBg:addChild(_scrollView,2)

    addSprite(1, ccp(_scrollView:getViewSize().width, 30))
    ------------------------------------------------------------------------------
	local ccTitleBG = CCSprite:create("images/common/viewtitle1.png")
	ccTitleBG:setPosition(ccp(bg_size.width/2, bg_size.height-6))
	ccTitleBG:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteBg:addChild(ccTitleBG)
	-- 神将招将标题文本
	require "script/libs/LuaCCLabel"
	local ccLabelTitle = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2442"), g_sFontPangWa, 33)
	ccLabelTitle:setPosition(ccp(ccTitleBG:getContentSize().width/2, (ccTitleBG:getContentSize().height-1)/2))
	ccLabelTitle:setAnchorPoint(ccp(0.5, 0.5))
	ccLabelTitle:setColor(ccc3(0xff, 0xf0, 0x49))
	ccTitleBG:addChild(ccLabelTitle)
    
    local fullRect = CCRectMake(0, 0, 116, 124)
	local insetRect = CCRectMake(50, 50, 2, 3)
    local bottomBg = CCScale9Sprite:create("images/common/bg/change_bg.png", fullRect, insetRect)
    bottomBg:setPreferredSize(CCSizeMake(465,167))
    bottomBg:setAnchorPoint(ccp(0.5,0))
    bottomBg:setPosition(ccp(bg_size.width *0.5,25))
    ccSpriteBg:addChild(bottomBg)

	local menu = CCMenu:create()
	ccSpriteBg:addChild(menu)
	menu:setPosition(ccp(0,0))
    

	local ccButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	ccButtonClose:setAnchorPoint(ccp(1, 1))
	ccButtonClose:setPosition(ccp(bg_size.width+14, bg_size.height+14))
	ccButtonClose:registerScriptTapHandler(fnHandlerOfSenionRecruit)
	menu:addChild(ccButtonClose, 0, _tagCloseButton)
	menu:setPosition(0, 0)
	menu:setTouchPriority(-4002)

	---------------------add by DJN 增加招将预览--------------------------------------
	local ccButtonPrew = CCMenuItemImage:create("images/shop/pub/recruit_prew_n.png", "images/shop/pub/recruit_prew_h.png")
	ccButtonPrew:setScale(0.8)
	ccButtonPrew:setAnchorPoint(ccp(0, 1))
	ccButtonPrew:setPosition(ccp(20, bg_size.height*0.93))
	ccButtonPrew:registerScriptTapHandler(fnHandlerOfSenionRecruit)
	menu:addChild(ccButtonPrew, 0, _tagPrewButton)
	--menu:setPosition(0, 0)
	--menu:setTouchPriority(-4002)
	---------------------------------------------------------------------------------


	local bottomMenu = CCMenu:create()
	bottomBg:addChild(bottomMenu)
	bottomMenu:setPosition(ccp(0,0))
	bottomMenu:setTouchPriority(-4002)
    

-- 招将一次
	--local cmiiRecruitOne = CCMenuItemImage:create("images/shop/pub/one_n.png", "images/shop/pub/one_h.png")
	-----change by DJN 2014/11/21
	local cmiiRecruitOne = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(190, 73),
		                               GetLocalizeStringBy("djn_94"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	----------------------------
	_btnRecruitOne = cmiiRecruitOne
	cmiiRecruitOne:ignoreAnchorPointForPosition(false)
	cmiiRecruitOne:setPosition(bottomBg:getContentSize().width*0.25, 40)
	cmiiRecruitOne:setAnchorPoint(ccp(0.5, 0))
	cmiiRecruitOne:registerScriptTapHandler(fnHandlerOfSenionRecruit)
	bottomMenu:addChild(cmiiRecruitOne, 0, _tagRecruitOne)

	-- local recuitOneDesc= CCSprite:create("images/shop/pub/buy_one.png")
	-- recuitOneDesc:setPosition(cmiiRecruitOne:getContentSize().width/2, 13 )
	-- recuitOneDesc:setAnchorPoint(ccp(0.5,0))
	-- cmiiRecruitOne:addChild(recuitOneDesc)


-- 如果是首招则必得五星武将
--------change by DJN  2014/11/22
-- 原来fang写的是 首次招必得五星武将 这个图片放在抽一次的按钮上，现在策划改成把他放在屏幕中间，如果不是首次招，对应的位置显示“可招募蓝色紫色武将”。
	require "script/model/DataCache"
	local shopInfo = DataCache.getShopCache()
	local midSp = nil
	if( tonumber(shopInfo.gold_recruit_num) <= 0 and tonumber(shopInfo.gold_recruit_status) < 2 )then
		print("firstSpfirstSpfirstSpfirstSp")
		midSp = CCSprite:create("images/shop/pub/firstget_5.png")
	else
   		require "script/libs/LuaCCLabel"
    	local richInfo = {elements = {}}
	    richInfo.elements[1] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("key_1307"),
			    font = g_sFontPangWa, 
			    size = 21, 
			    color = ccc3(0xff, 0xff, 0xff), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[2] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("key_1087"),
			    font = g_sFontPangWa, 
			    size = 21, 
			    color = ccc3(0x00, 0xe4, 0xff), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("key_3374"),
			    font = g_sFontPangWa, 
			    size = 21, 
			    color = ccc3(0xe4, 0x00, 0xff), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[4] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = GetLocalizeStringBy("key_1453"),
			    font = g_sFontPangWa, 
			    size = 21, 
			    color = ccc3(0xff, 0xff, 0xff), 
			    strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}

    	midSp = LuaCCLabel.createRichLabel(richInfo)
	end
	midSp:setAnchorPoint(ccp(0.5,0))
	midSp:setPosition(ccp(bottomBg:getContentSize().width/2, bottomBg:getContentSize().height))
	bottomBg:addChild(midSp)
-----------------------------------------------------------------------------------------------------------------------------

-- 招将十次
	--local cmiiRecruitTen = CCMenuItemImage:create("images/shop/pub/ten_n.png", "images/shop/pub/ten_h.png")
	-----change by DJN 2014/11/21 图片素材换了 逻辑不变
	local cmiiRecruitTen = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(190, 73),
		                               GetLocalizeStringBy("djn_95"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-------------------------
	cmiiRecruitTen:setPosition(bottomBg:getContentSize().width*0.75, 40)
	cmiiRecruitTen:ignoreAnchorPointForPosition(false)
	cmiiRecruitTen:setAnchorPoint(ccp(0.5, 0))
	cmiiRecruitTen:registerScriptTapHandler(fnHandlerOfSenionRecruit)
	bottomMenu:addChild(cmiiRecruitTen, 0, _tagRecruitTen)

	-- local recuitTenDesc= CCSprite:create("images/shop/pub/buy_ten.png")
	-- recuitTenDesc:setPosition(cmiiRecruitTen:getContentSize().width/2, 14 )
	-- recuitTenDesc:setAnchorPoint(ccp(0.5,0))
	-- cmiiRecruitTen:addChild(recuitTenDesc)


	require "db/DB_Tavern"
	local db_senior = DB_Tavern.getDataById(3)
-- 金币消耗(招一次)
	local csGoldIconForOne = CCSprite:create("images/common/gold.png")
	csGoldIconForOne:setPosition(89, 40)
	csGoldIconForOne:setAnchorPoint(ccp(0, 0))
	ccSpriteBg:addChild(csGoldIconForOne)
	local crlGoldNeedForOne = CCRenderLabel:create(db_senior.gold_needed, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
	crlGoldNeedForOne:setColor(ccc3(0xff, 0xf6, 0))
	crlGoldNeedForOne:setAnchorPoint(ccp(0, 0))
	crlGoldNeedForOne:setPosition(csGoldIconForOne:getContentSize().width+2, 0)
	csGoldIconForOne:addChild(crlGoldNeedForOne)

	local shopInfo = DataCache.getShopCache()
	if( tonumber(shopInfo.gold_recruit_num ) > 0 )then
		csGoldIconForOne:setVisible(false)
		crlGoldNeedForOne:setVisible(false)

		local  goldFreeNode =createGoldFreeLabel()
		goldFreeNode:setPosition(ccSpriteBg:getContentSize().width*0.27 ,45)
		goldFreeNode:setAnchorPoint(ccp(0.5,0))
		ccSpriteBg:addChild(goldFreeNode)
	end

-- 金币消耗(招十次)
	_numOfTenRecuit = tonumber(lua_string_split(db_senior.gold_nums, "|")[1])
	_costGoldOfTen = tonumber(lua_string_split(db_senior.gold_nums, "|")[2])
	local csGoldIconForTen = CCSprite:create("images/common/gold.png")
	csGoldIconForTen:setPosition(330, 40)
	csGoldIconForTen:setAnchorPoint(ccp(0, 0))
	ccSpriteBg:addChild(csGoldIconForTen)
	local crlGoldNeedForTen = CCRenderLabel:create( _costGoldOfTen, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
	crlGoldNeedForTen:setColor(ccc3(0xff, 0xf6, 0))
	crlGoldNeedForTen:setAnchorPoint(ccp(0, 0))
	crlGoldNeedForTen:setPosition(csGoldIconForTen:getContentSize().width+2, 0)
	csGoldIconForTen:addChild(crlGoldNeedForTen)

-- 再招？次必得五星将提示
-- 再招9次后，下次招将必得一张五星武将!

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
	require "script/libs/LuaCC"
	local tElements = {
 		{ctype=3, text=GetLocalizeStringBy("key_1470"), color=ccc3(0x51, 0xfb, 255), fontname=g_sFontPangWa, strokeColor=ccc3(0, 0, 0), fontsize=20, strokeSize=2},
 		{ctype=3, text=tostring(nRecruitLeft), color=ccc3(255, 255, 255), fontsize=20, --[[vOffset=-10]]},
 		{ctype=3, text=GetLocalizeStringBy("key_3196"), color=ccc3(0x51, 0xfb, 255), --[[vOffset=10,]] fontsize=20},
 		{ctype=3, text=GetLocalizeStringBy("key_1258"), color=ccc3(255, 0, 0xe1), fontsize=21},
 	}
 	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
 	for i=1, #tObjs do
 		tObjs[i]:setAnchorPoint(ccp(0, 0))
 	end
 	-- tObjs[1]:setPosition(25, 410)
 	-- ccSpriteBg:addChild(tObjs[1])
 	tObjs[1]:setPosition(40, 115)
 	bottomBg:addChild(tObjs[1])

 	-- 当nRecruitLeft == 0 显示本次招将必得五星紫卡文本
 	if(nRecruitLeft == 0) then
 		tObjs[1]:setVisible(false)
 		local thisRecuitNode = createRecruitThisNode()
 		thisRecuitNode:setPosition(bottomBg:getContentSize().width/2, 115)
 		thisRecuitNode:setAnchorPoint(ccp(0.5,0))
 		-- ccSpriteBg:addChild(thisRecuitNode)
 		bottomBg:addChild(thisRecuitNode)
 	end


	-- 新手引导
	cclMask:registerScriptHandler(function (event)
		if event == "enter" then
			-- 新手修改跳过此步骤 2013.11.29
			-- addGuideLevelGiftBagGuide6()
		end
	end)
	-- cclMask add到父节点上
	runningScene:addChild(cclMask, 3000, _tagPopupPanel)
end

-- added by zhz ,显示：本次招将必得五星紫卡文本
function createRecruitThisNode( )
	local alertContent = {}
	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1171") , g_sFontPangWa, 20,2, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0x51, 0xfb, 255))
	alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_2224") , g_sFontPangWa, 21,2, ccc3(0x00,0,0),type_stroke)
	alertContent[2]:setColor(ccc3(255, 0, 0xe1))
	local alert = BaseUI.createHorizontalNode(alertContent)

	return alert
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
--		stopScheduler( )
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint,3,dictData.ret.item)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end
-- 招将10次网络回调处理
function fnHandlerOfNetworkRecruitTen(cbFlag, dictData, bRet)
	if bRet then
		-- 减去所消耗金币
		DataCache.changeFirstStatus()
		UserModel.addGoldNumber(-_costGoldOfTen)
		local arrHeroes={}
		for k, v in pairs(dictData.ret.hero) do
			table.insert(arrHeroes, v)
		end
		--TenHeroRecuitLayer.addHeroCardShow(arrHeroes)
		TenHeroRecuitLayer.setAllHeroes(arrHeroes)
		-- 招将十次额外物品掉落
		TenHeroRecuitLayer.setAllItems(dictData.ret.item)
		TenHeroRecuitLayer.createRecruitTenLayer()
	end
end

-- added by zhz
-- 招将10次事件处理
function dealRecuitTen( )
	require "db/DB_Tavern"
		local db_tavern = DB_Tavern.getDataById(3)
		-- local recuitNum = tonumber(lua_string_split(db_tavern.gold_nums, "|")[1])
		-- local costGoldOfTen = tonumber(lua_string_split(db_tavern.gold_nums, "|")[2])
		-- _costGoldOfTen
		-- _numOfTenRecuit
		if (UserModel.getGoldNumber() >=_costGoldOfTen ) then
			_nCostGold = costGoldOfTen --db_tavern.gold_needed*10
			local args = Network.argsHandler(1, _numOfTenRecuit)
			RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitTen, args)
		else
			-- AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
			LackGoldTip.showTip()
	end
end


-- function fnHandlerOfRecruitTenUI(tag, obj)
-- -- 招将1次按钮事件处理
-- 	if tag == _tagRecruitOne then
-- 		local shopInfo = DataCache.getShopCache()
-- 		if (tonumber(shopInfo.gold_recruit_num) > 0) then
-- 			local args = Network.argsHandler(0, 1)
-- 			RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
-- 		else
-- 			require "db/DB_Tavern"
-- 			local db_tavern = DB_Tavern.getDataById(3)
-- 			if (UserModel.getGoldNumber() >= (db_tavern.gold_needed)) then
-- 				_nCostGold = db_tavern.gold_needed
-- 				local args = Network.argsHandler(1, 1)
-- 				RequestCenter.shop_goldRecruit(fnHandlerOfNetworkRecruitOne, args)
-- 			else
-- 				AnimationTip.showTip(GetLocalizeStringBy("key_2601"))
-- 			end
-- 		end
-- -- 招将10次按钮事件处理	
-- 	elseif tag == _tagRecruitTen then
-- 		dealRecuitTen()
		
-- -- 退出按钮事件处理
-- 	elseif tag == _tagQuit then
-- 		local runningScene = CCDirector:sharedDirector():getRunningScene()
-- 		local seniorPanel = runningScene:getChildByTag(_tagPopupPanelOfRecruitTen)
-- 		if seniorPanel then
-- 			seniorPanel:removeFromParentAndCleanup(true)
-- 		end
-- 	end
-- end

-- local function fnInitOfRecruitTen( ... )
-- 	_arrObjsRecruitText = {}
-- 	_arrObjsCardShow={}
-- end

-- -- 创建神将十连抽界面
-- function createRecruitTenLayer( ... )
-- 	fnInitOfRecruitTen()
-- 	local runningScene = CCDirector:sharedDirector():getRunningScene()
-- 	local clBg = CCLayer:create()
-- 	_clRecruitTenBg = clBg
-- 	clBg:setTouchEnabled(true)
-- 	clBg:registerScriptTouchHandler(function ( ... )
-- 		return true
-- 	end, false, -4000, true)
-- 	local csBg = CCSprite:create("images/shop/pub/pubbg.jpg")
-- 	csBg:setPosition(g_winSize.width/2, g_winSize.height/2)
-- 	csBg:setAnchorPoint(ccp(0.5, 0.5))
-- 	csBg:setScale(g_fBgScaleRatio)
-- 	clBg:addChild(csBg)
-- 	runningScene:addChild(clBg, 3000, _tagPopupPanelOfRecruitTen)

-- 	local csConsTitle = CCSprite:create("images/shop/pub/congratulations.png")
-- 	csConsTitle:setScale(g_fElementScaleRatio)
-- 	csConsTitle:setAnchorPoint(ccp(0.5, 0))
-- 	csConsTitle:setPosition(g_winSize.width/2, g_winSize.height*0.85)
-- 	clBg:addChild(csConsTitle)

-- 	require "script/libs/LuaCC"
-- -- 按钮, 招将1次
-- 	local btnRecruitOne = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2893"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
-- 	btnRecruitOne:registerScriptTapHandler(fnHandlerOfRecruitTenUI)
-- 	btnRecruitOne:setScale(g_fElementScaleRatio)
-- 	btnRecruitOne:setPosition(g_winSize.width*0.15, g_winSize.height*0.15)
-- 	btnRecruitOne:setAnchorPoint(ccp(0, 0))
-- -- 按钮, 招将10次
-- 	local btnRecruitTen = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210, 73),GetLocalizeStringBy("key_1864"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
-- 	btnRecruitTen:setScale(g_fElementScaleRatio)
-- 	btnRecruitTen:registerScriptTapHandler(fnHandlerOfRecruitTenUI)
-- 	btnRecruitTen:setPosition(g_winSize.width*0.55, g_winSize.height*0.15)
-- 	btnRecruitTen:setAnchorPoint(ccp(0, 0))
-- -- 按钮, 退出
-- 	local btnRecruitQuit = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3344"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0, 0, 0))
-- 	btnRecruitQuit:setScale(g_fElementScaleRatio)
-- 	btnRecruitQuit:setAnchorPoint(ccp(0.5, 0))
-- 	btnRecruitQuit:setPosition(g_winSize.width/2, g_winSize.height*0.02)
-- 	btnRecruitQuit:registerScriptTapHandler(fnHandlerOfRecruitTenUI)
-- -- 几个按钮菜单
-- 	local cmRecruitHero = CCMenu:create()
-- 	cmRecruitHero:setPosition(0, 0)
-- 	cmRecruitHero:setTouchEnabled(true)
-- 	cmRecruitHero:setTouchPriority(-4002)
-- 	cmRecruitHero:addChild(btnRecruitOne, 0, _tagRecruitOne)
-- 	cmRecruitHero:addChild(btnRecruitTen, 0, _tagRecruitTen)
-- 	cmRecruitHero:addChild(btnRecruitQuit, 0, _tagQuit)
-- 	clBg:addChild(cmRecruitHero)
-- -- 显示卡牌
-- 	addCardShow()

--  	require "db/DB_Tavern"
-- 	local db_senior = DB_Tavern.getDataById(3)
-- -- 金币消耗(招一次)
-- 	local csGoldIconForOne = CCSprite:create("images/common/gold.png")
-- 	local nGoldIconWidth = csGoldIconForOne:getContentSize().width
-- 	local crlGoldNeedForOne = CCRenderLabel:create(db_senior.gold_needed, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
-- 	crlGoldNeedForOne:setColor(ccc3(0xff, 0xf6, 0))
-- 	crlGoldNeedForOne:setAnchorPoint(ccp(0, 0))
-- 	crlGoldNeedForOne:setPosition(nGoldIconWidth+2, 0)
-- 	csGoldIconForOne:addChild(crlGoldNeedForOne)
-- 	local nChildWidth = nGoldIconWidth+2+crlGoldNeedForOne:getContentSize().width
-- 	csGoldIconForOne:setPosition((btnRecruitOne:getContentSize().width-nChildWidth)/2, -4)
-- 	csGoldIconForOne:setAnchorPoint(ccp(0, 1))
-- 	btnRecruitOne:addChild(csGoldIconForOne)

-- -- 金币消耗(招十次)
-- 	local csGoldIconForTen = CCSprite:create("images/common/gold.png")
-- 	local crlGoldNeedForTen = CCRenderLabel:create(db_senior.gold_needed*10, g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
-- 	crlGoldNeedForTen:setColor(ccc3(0xff, 0xf6, 0))
-- 	crlGoldNeedForTen:setAnchorPoint(ccp(0, 0))
-- 	crlGoldNeedForTen:setPosition(csGoldIconForTen:getContentSize().width+2, 0)
-- 	csGoldIconForTen:addChild(crlGoldNeedForTen)

-- 	local nChildWidth = nGoldIconWidth+2+crlGoldNeedForTen:getContentSize().width

-- 	csGoldIconForTen:setPosition((btnRecruitTen:getContentSize().width-nChildWidth)/2, -4)
-- 	csGoldIconForTen:setAnchorPoint(ccp(0, 1))

-- 	btnRecruitTen:addChild(csGoldIconForTen)

-- 	addRecruitLeftTimeText(clBg)
-- end

-- -- 增加招将剩于次数文本显示
-- function addRecruitLeftTimeText(ccParent)
-- 	if #_arrObjsRecruitText >= 1 then
-- 		_arrObjsRecruitText[1]:removeFromParentAndCleanup(true)
-- 	end
-- 	-- 再招？次必得一张五星武将
-- 	local shopInfo = DataCache.getShopCache()
-- 	local nRecruitSum = tonumber(shopInfo.gold_recruit_sum)
-- 	local nRecruitLeft = 0
-- 	if nRecruitSum <= 5 then
-- 		nRecruitLeft = 5 - nRecruitSum - 1
-- 	else
-- 		nRecruitSum = (nRecruitSum - 5)%10
-- 		nRecruitLeft = 10 - nRecruitSum - 1
-- 	end
-- 	if nRecruitLeft <= 0 then
-- 		nRecruitLeft = 9
-- 	end
-- 	require "script/libs/LuaCC"
-- 	local tElements = {
--  		{ctype=3, text=GetLocalizeStringBy("key_1470"), color=ccc3(0x51, 0xfb, 255), fontname=g_sFontPangWa, strokeColor=ccc3(0, 0, 0), fontsize=24, strokeSize=2},
--  		{ctype=3, text=tostring(nRecruitLeft), color=ccc3(255, 255, 255), fontsize=39, vOffset=-10},
--  		{ctype=3, text=GetLocalizeStringBy("key_3196"), color=ccc3(0x51, 0xfb, 255), vOffset=10, fontsize=24},
--  		{ctype=3, text=GetLocalizeStringBy("key_1258"), color=ccc3(255, 0, 0xe1), fontsize=29},
--  		{ctype=3, text="！", color=ccc3(0x51, 0xfb, 255), fontsize=24},
--  	}
--  	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
--  	local nTotalWidth = 0
--  	for i=1, #tObjs do
--  		tObjs[i]:setAnchorPoint(ccp(0, 0))
--  		nTotalWidth = nTotalWidth + tObjs[i]:getContentSize().width
--  		tObjs[i]:setScale(g_fElementScaleRatio)
--  	end
--  	tObjs[1]:setPosition((g_winSize.width - nTotalWidth*g_fElementScaleRatio)/2, g_winSize.height*0.26)
--  	ccParent:addChild(tObjs[1])

--  	_arrObjsRecruitText = tObjs

-- end

-- -- 增加卡牌形象显示
-- function addCardShow(tHeroes)
-- 	local x_start = g_winSize.width * 0.0375
-- 	local x = x_start
-- 	local y = g_winSize.height * 0.396

-- 	for i=1, #_arrObjsCardShow do
-- 		_arrObjsCardShow[i]:removeFromParentAndCleanup(true)
-- 	end
-- 	_arrObjsCardShow = {}

-- 	if not tHeroes then
-- 		local x_offset = g_winSize.width*0.189
-- 		local fOppScale = 0.33*g_fElementScaleRatio

-- 		for i=1, 10 do
-- 			if i == 6 then
-- 				x = x_start
-- 				y = g_winSize.height * 0.65
-- 			end
-- 			local csItem = CCSprite:create("images/shop/pub/card_opp.png")
-- 			csItem:setScale(fOppScale)
-- 			csItem:setPosition(x, y)
-- 			csItem:setAnchorPoint(ccp(0, 0))

-- 			_clRecruitTenBg:addChild(csItem)
-- 			x = x + x_offset
-- 			table.insert(_arrObjsCardShow, csItem)
-- 		end
-- 	else
-- 		local x_offset = g_winSize.width*0.1875
-- -- 显示卡牌
-- 		require "script/battle/BattleCardUtil"
-- 		require "db/DB_Heroes"
-- 		require "script/ui/hero/HeroPublicLua"
-- 		-- local arrItemData = {10005, 10078, 10121, 10139, 10002, 10079, 10008, 10032, 10155, 10172}
		
-- 		local cardScale = 0.85*g_fElementScaleRatio
		
-- 		for i=1, #tHeroes do
-- 			if i == 6 then
-- 				x = x_start
-- 				y = g_winSize.height * 0.65
-- 			end
-- 			local csItem = BattleCardUtil.getFormationPlayerCard(nil, nil, tHeroes[i])
-- 			csItem:setScale(cardScale)
-- 			csItem:setPosition(x, y)
-- 			csItem:setAnchorPoint(ccp(0, 0))

-- 			local db_hero = DB_Heroes.getDataById(tHeroes[i])
-- 			local color = HeroPublicLua.getCCColorByStarLevel(db_hero.star_lv)
-- 			local crlName = CCRenderLabel:create(db_hero.name, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
-- 			crlName:setAnchorPoint(ccp(0.5, 1))
-- 			crlName:setColor(color)
-- 			crlName:setPosition(csItem:getContentSize().width/2, -10)
-- 			csItem:addChild(crlName)
-- 			_clRecruitTenBg:addChild(csItem)

-- 			local tElements = {}
-- 			for i=1, db_hero.star_lv do
-- 				table.insert(tElements, {ctype=LuaCC.m_ksTypeSprite, file="images/shop/pub/star.png"})
-- 			end
-- 			local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
-- 			for i=1, #tObjs do
-- 				tObjs[i]:setAnchorPoint(ccp(0, 0))
-- 			end
-- 			tObjs[1]:setPosition((csItem:getContentSize().width-tObjs[1]:getContentSize().width*db_hero.star_lv)/2, csItem:getContentSize().height+12)
-- 			csItem:addChild(tObjs[1], 1000)

-- 			x = x + x_offset

-- 			table.insert(_arrObjsCardShow, csItem)
-- 		end
-- 	end
-- end

-- 为新手引导提供按钮
function getRecruitOneBtn( ... )
	return _btnRecruitOne
end


-- 等级礼包第6步 点击招一次
function addGuideLevelGiftBagGuide6( ... )
    require "script/guide/NewGuide"
	-- print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 5) then
    	-- require "script/ui/shop/SeniorHeroRecruitLayer"
    	local levelGiftBagGuide_button = getRecruitOneBtn()
   	 	local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
    	LevelGiftBagGuide.show(6, touchRect)
        LevelGiftBagGuide.stepNum = 7
    end
end
--------------------------------add by DJN 2014/11/21 
--[[
    @des    :得到所有13资质的神将
    @param  :
    @return :
--]]
function getAll13QualityHero( ... )
    local allHero = DB_Hero_view.getDataById(3).Heroes
   	local heroData = {}
	local heroTab = string.split(allHero, ",")

	local tableCount = table.count(heroTab)
	for i = 1,tableCount do
	    local tab = heroTab[i]
	    table.insert(heroData,tab)
	end
    allHero = {}
    for k,v in pairs (heroData)do
    	-- print("k+++++++++++++",k,type(k))
    	-- print("v+++++++++++++",v,type(v))
    	if(DB_Heroes.getDataById(tonumber(v)).heroQuality == 13)then
		table.insert(allHero,v)
		end
	end
	return allHero
end

-- function refreshStarTag()
-- 	print("交换tag",_leftTag,_curTag,_rightTag)
-- 	if(_curTag == 1)then
-- 		_leftTag = _maxTag
-- 	else
-- 		_leftTag = _curTag
-- 	end
-- 	_curTag = _rightTag
-- 	if(_rightTag == _maxTag)then
-- 		_rightTag = 1
-- 	else
-- 		_rightTag = _rightTag +1
-- 	end
-- 	print("交换后tag",_leftTag,_curTag,_rightTag)
-- end
-- function refreshStarSprite()
-- 	if(_leftTag ~= nil)then
-- 		local starSprite = StarSprite.createStarSprite(_heroTable[_leftTag])
-- 		_leftStar:setDisplayFrame(starSprite:displayFrame())
-- 	end
-- 	if(_curTag ~= nil)then
-- 		local starSprite = StarSprite.createStarSprite(_heroTable[_curTag])
-- 		_curStar:setDisplayFrame(starSprite:displayFrame())
-- 		--_curStar:setPosition(ccp(_rightStar:getPositionX(),_rightStar:getPositionY()))
-- 	end
-- 	if(_rightTag ~= nil)then
-- 		local starSprite = StarSprite.createStarSprite(_heroTable[_rightTag])
-- 		_rightStar:setDisplayFrame(starSprite:displayFrame())
-- 	end
-- end
-- -- function resetPosition( )
-- -- 	_curStar:setPosition(ccp(100,0))
-- -- 	_leftStar:setPosition(_curStar:getPositionX() - 100 - _curStar:getContentSize().width*0.5,_curStar:getPositionY())
-- --     _rightStar:setPosition(_curStar:getPositionX() + 100 + _curStar:getContentSize().width*0.5,_curStar:getPositionY())
-- -- end
-- function refreshHeroPosition()
-- 	_curStarNode:setPosition(ccp(_curStar:getPositionX() -1,_curStar:getPositionY()))
-- 	_leftStarNode:setPosition(_curStar:getPositionX() - _curStar:getContentSize().width *0.5 -100,_curStar:getPositionY())
--     _rightStarNode:setPosition(_rightStar:getPositionX() + _curStar:getContentSize().width *0.5 +100,_curStar:getPositionY())
-- end
-- function updateTimeFunc()
-- 	if((_curStar:getPositionX() + _curStar:getContentSize().width*0.5) > 0)then
-- 		refreshHeroPosition()
-- 	else
-- 		refreshStarTag()
-- 		refreshStarSprite()
-- 		--resetPosition()
-- 	end

	
-- end
--[[
    @des    :创建一个英雄形象
    @param  :
    @return :
--]]
function addSprite(p_index, p_position)
	_nextIndex = p_index + 1
	_curIndex = p_index
    if(_nextIndex > _maxTag)then
    	_nextIndex = 1
    end
	local starSprite = StarSprite.createStarSprite(_heroTable[p_index])
	_scrollView:addChild(starSprite)
	starSprite:setScale(0.7)
	starSprite:ignoreAnchorPointForPosition(false)
	starSprite:setAnchorPoint(ccp(0,0))
    if(p_position == nil)then
    	p_position = ccp(_scrollView:getViewSize().width, 30)
    end
	starSprite:setPosition(p_position)
    
    local heroNameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	heroNameBg:setContentSize(CCSizeMake(240, 36))
	heroNameBg:setAnchorPoint(ccp(0.5,1))
	heroNameBg:setPosition(ccp(starSprite:getContentSize().width *0.5,-5))
	starSprite:addChild(heroNameBg)

    local nameStr = DB_Heroes.getDataById(_heroTable[p_index]).name or " "
	local name = CCRenderLabel:create(nameStr, g_sFontPangWa, 35, 1, ccc3(0, 0, 0), type_stroke)
	name:setColor(ccc3(0xe4,0x00,0xff))
	name:setAnchorPoint(ccp(0.5,0.5))
	name:setPosition(ccp(heroNameBg:getContentSize().width *0.25,heroNameBg:getContentSize().height *0.5))
	heroNameBg:addChild(name)

	
	--资质
	local sFightValue = DB_Heroes.getDataById(_heroTable[p_index]).heroQuality

	if(sFightValue ~= nil)then
	 	local ccSpriteFightValue = CCSprite:create("images/hero/potential.png")
	 	ccSpriteFightValue:setAnchorPoint(ccp(0,0.5))
	 	ccSpriteFightValue:setPosition(ccp(name:getContentSize().width +10,name:getContentSize().height *0.5))
	 	name:addChild(ccSpriteFightValue)

	 	local ccLabelFightValue = CCRenderLabel:create(sFightValue, g_sFontPangWa,30,1,ccc3(0, 0, 0),type_stroke)
	 	ccLabelFightValue:setColor(ccc3(0xff,0x00,0x00))
	 	ccLabelFightValue:setAnchorPoint(ccp(0,0.5))
	 	ccLabelFightValue:setPosition(ccp(ccSpriteFightValue:getContentSize().width,ccSpriteFightValue:getContentSize().height *0.5))
	 	ccSpriteFightValue:addChild(ccLabelFightValue)
    end

	local actionArray = CCArray:create()
    actionArray:addObject(CCMoveTo:create(2,ccp(_scrollView:getViewSize().width*0.5,30)))
	actionArray:addObject(CCCallFuncN:create(resetStar))
    actionArray:addObject(CCMoveTo:create(2,ccp(0,30)))
    actionArray:addObject(CCCallFuncN:create(createNext))
	--actionArray:addObject(CCCallFuncN:create(refreshStar))
	actionArray:addObject(CCMoveTo:create(2,ccp(-_scrollView:getViewSize().width*0.5,30)))
	-- actionArray:addObject(CCCallFuncN:create(createNext))
	actionArray:addObject(CCMoveTo:create(2,ccp(-_scrollView:getViewSize().width,30)))
	actionArray:addObject(CCCallFuncN:create(moveEnd))
	local seqAction =	CCSequence:create(actionArray)
	 
	starSprite:runAction(seqAction)
end
--[[
    @des    :创建下一个英雄形象
    @param  :
    @return :
--]]
function createNext( ... )
	cleanStar()
	addSprite(_nextIndex)
end
--[[
    @des    :移出屏幕后回调
    @param  :
    @return :
--]]
function moveEnd( p_node )
 	p_node:removeFromParentAndCleanup(true)
end
--[[
    @des    :前一个形象移出屏幕后做星星显示上的判断
    @param  :
    @return :
--]]
function cleanStar()
	local curStar = DB_Heroes.getDataById(_heroTable[_curIndex]).star_lv
    local nextStar = DB_Heroes.getDataById(_heroTable[_nextIndex]).star_lv
    print("curStar,nextStar",curStar,nextStar)
    if(curStar <= nextStar)then
       
    elseif(curStar > nextStar)then
		for i = tonumber(curStar - nextStar),curStar do
	       _starTable[i]:setVisible(false)
	    end
	end
end
--[[
    @des    :创建一个形象的同时刷新星星数量
    @param  :
    @return :
--]]
function resetStar( )
	local starNum = DB_Heroes.getDataById(_heroTable[_curIndex]).star_lv

	for i = 1,tonumber(starNum) do
       _starTable[i]:setVisible(true)
    end
end
--function updateStar()
	-- local curTime = os.clock()
	-- local deltaTime  = curTime - _curTime
	-- _curTime = curTime
	-- local length = 0.01 * deltaTime
	-- _curStar:setPosition(ccp(_curStar:getPositionX() -length,_curStar:getPositionY()))	
 --    _rightStar:setPosition(ccp(_rightStar:getPositionX() -length,_curStar:getPositionY()))
	-- if(_leftStar ~= nil)then
	-- 	_leftStar:setPosition(ccp(_leftStar:getPositionX() -length,_curStar:getPositionY()))
	-- else


	--end
	-- if(_rightStar:getPositionX() <= 200)then
	-- 	print("检测到边了")
 --        local index = _tagTable[3]
 --        if(index == _maxTag)then
 --       		index = 1
 --        else
 --       		index = index +1
 --       	end
 --       	table.remove(_tagTable,1)
 --       	table.insert(_tagTable,index)

       	
 --       	-- _rightStar = _curStar
 --       	-- _curStar = _leftStar
 --       	-- _leftStar = tempStar

 --       	local tempStar = _leftStar
 --       	_leftStar = _curStar
 --       	_curStar = _rightStar
 --       	_rightStar = tempStar

 --       	_rightStar:setPosition(ccp(480,0))


        
 --        -- local starSprite = StarSprite.createStarSprite(_heroTable[(_tagTable[1])])
 --       	-- _leftStar:setDisplayFrame(starSprite:displayFrame())
 --       	-- local starSprite = StarSprite.createStarSprite(_heroTable[(_tagTable[2])])
 --       	-- _curStar:setDisplayFrame(starSprite:displayFrame())
 --       	local starSprite = StarSprite.createStarSprite(_heroTable[(_tagTable[3])])
 --       	_rightStar:setDisplayFrame(starSprite:displayFrame())

	-- end
	
--end
