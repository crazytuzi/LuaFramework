-- Filename：	CardPackActiveLayer.lua
-- Author：		zhz
-- Date：		2013-12-27
-- Purpose：		创建活动卡包的Layer

module ("CardPackActiveLayer", package.seeall)


require "script/ui/rechargeActive/ActiveUtil"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/main/MainScene"
require "script/model/user/UserModel"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/audio/AudioUtil"
require "script/battle/BattleCardUtil"
require "script/utils/TimeUtil"
require "script/ui/tip/AnimationTip"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroPublicLua"
-- require "script/ui/activity/ActivityUtil"

local _ksTagRecharge =1001			-- 充值按钮得回调
local _ksTagActive=1002				-- 活动说明得按钮
local _ksTagFreeCharge= 1004		-- 免费抽取的按钮
local _ksTagGoldCharge= 1005		-- 金币抽取的按钮


local _bgLayer = nil						--
local _layerSize
local _cardPackBg					-- 卡牌背景
local _leftTimeLabel				-- 活动剩余时间的文本

local _descSp						-- 桌子
local _curtainTop					--

local _rankTitle					-- 活动积分排行的标题
local _rankScrollView				-- 活动排行的scrowView
local _rankBg
local _rankLabel					-- 当前积分排行文本

local _clockSp						-- 桌子的sprite

local _pointLabel = nil				-- 拥有积分
local _updateTimer               	-- 定时器
local _heroSrc
local _curHeroIndex=0
local _curHeroSize

local _heroTable					-- 武将的table
local _starsBgSp

local IMG_PATH= "images/recharge/card_active/"



function init(  )
	_bgLayer= nil
	_layerSize= nil
	_cardPackBg= nil
	_leftTimeLabel = nil
	_descSp= nil
	_curtainTop= nil
	_rankTitle= nil
	_rankScrollView= nil
	_rankBg= nil
	_pointLabel= nil
	_clockSp= nil
	_rankLabel= nil
	_heroSrc= nil
	_freeTimeLabel = nil
	_curHeroIndex=1
	_updateTimer= nil
	_heroTable=  ActiveCache.getShowHeroes()

	_starsBgSp= nil

	_curHeroSize= CCSizeMake(220, 300)
end


function onNodeEvent( eventType )

	if (eventType == "enter") then
		print("_bgLayer  enter")
 		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -124, true)
 		_bgLayer:setTouchEnabled(true)
    elseif(eventType == "exit") then
    	if(_updateTimer ~= nil)then
	       CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
	       _updateTimer = nil
	       Network.rpc(leaveShopCb, "heroshop.leaveShop" , "heroshop.leaveShop", nil , true)
	       _bgLayer:unregisterScriptTouchHandler()
	       _bgLayer= nil
	   end
    end
end
-- 
function createLayer( )
	init()

	_bgLayer  = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	require "script/ui/rechargeActive/RechargeActiveMain"
	MainScene.setMainSceneViewsVisible(true, false, false)
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local  activeMainWidth = RechargeActiveMain.getBgWidth()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX- activeMainWidth

	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	_cardPackBg= CCScale9Sprite:create(IMG_PATH .. "card_bg.png")
	_cardPackBg:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_cardPackBg:setScale(g_fBgScaleRatio)
	_cardPackBg:setAnchorPoint(ccp(0.5, 0))
	_cardPackBg:setPosition(ccp(_layerSize.width/2, 0))
	_bgLayer:addChild(_cardPackBg)

	Network.rpc(heroShopInfo, "heroshop.getMyShopInfo" , "heroshop.getMyShopInfo", nil , true)

	return _bgLayer
end

-- 创建底部桌子的UI，
function createBottom( )
	_descSp= CCSprite:create(IMG_PATH .. "card_change/desk.png")
	_descSp:setPosition(ccp(_layerSize.width/2,0))
	_descSp:setAnchorPoint(ccp(0.5,0))
	_descSp:setScale(g_fScaleX)
	_bgLayer:addChild(_descSp)

	-- 活动积分排行
	_rankBg= CCScale9Sprite:create(IMG_PATH .. "card_change/rank_bg.png")
	_rankBg:setPreferredSize(CCSizeMake(250, 189))
	_rankBg:setPosition(3, 8)
	_descSp:addChild(_rankBg)

	createRankScrollView()
	-- 活动积分sprite
	if(  BTUtil:getSvrTimeInterval()< ActiveCache.getHeroShopStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getHeroShopEndTime() ) then
		_rankTitle = CCSprite:create(IMG_PATH .. "active_1.png")
	else
		_rankTitle= CCSprite:create(IMG_PATH .. "active.png")
	end

	_rankTitle:setPosition(_rankBg:getContentSize().width/2, _rankBg:getContentSize().height)
	_rankTitle:setAnchorPoint(ccp(0.5,0.9))
	_rankBg:addChild(_rankTitle)


	-- 按钮
	-- local menu= CCMenu:create()
	-- menu:setPosition(ccp(0,0))
	-- _descSp:addChild(menu)
	-- -- 充值按钮
	-- local rechargeBtn=  LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(142, 79), GetLocalizeStringBy("key_3177") ,ccc3(0xff, 0xe4, 0x00),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- rechargeBtn:setPosition(455, 35)
	-- rechargeBtn:registerScriptTapHandler(menuAction)
	-- menu:addChild(rechargeBtn,1, _ksTagRecharge)

	--第一名可获得***，第二名可获得***等等四级jiang'li的内容
	local firstRewardText= nil
	local secondRewardText= nil
	local thirdRewardText = nil
	local forthRewardText= nil

	if(type(ActiveUtil.getCardHeroDesc)=="function")then
		firstRewardText, secondRewardText, thirdRewardText, forthRewardText = ActiveUtil.getCardHeroDesc()
	end	
	if(firstRewardText == nil)then
		firstRewardText= ActiveCache.getFirstRewardText()
		secondRewardText= ActiveCache.getSecondRewardtext()
		thirdRewardText = ActiveCache.getThirdRewardtext()
		forthRewardText= ActiveCache.getForthRewardtext()
	end
	
	--兼容东南亚英文版
	local rewardTxt
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		rewardTxt = {
			{rankNum = forthRewardText[1], heroName= forthRewardText[2], rankTxt_1= " ", rankTxt_2= GetLocalizeStringBy("key_2187") },
			{rankNum = thirdRewardText[1], heroName= thirdRewardText[2], rankTxt_1= " ", rankTxt_2= GetLocalizeStringBy("key_2187") },
			{rankNum = secondRewardText[1], heroName= secondRewardText[2], rankTxt_1= " ", rankTxt_2= GetLocalizeStringBy("key_2187") },
			{rankNum = firstRewardText[1], heroName= firstRewardText[2], rankTxt_1= " ", rankTxt_2= "For:" },
		}
	else
		
		if( table.isEmpty(forthRewardText) == true )then
			rewardTxt = {
				{rankNum = thirdRewardText[1], heroName= thirdRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_2187") },
				{rankNum = secondRewardText[1], heroName= secondRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_2187") },
				{rankNum = firstRewardText[1], heroName= firstRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_1573") },
			}
		else
			rewardTxt = {
				{rankNum = forthRewardText[1], heroName= forthRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_2187") },
				{rankNum = thirdRewardText[1], heroName= thirdRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_2187") },
				{rankNum = secondRewardText[1], heroName= secondRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_2187") },
				{rankNum = firstRewardText[1], heroName= firstRewardText[2], rankTxt_1= GetLocalizeStringBy("key_2906"), rankTxt_2= GetLocalizeStringBy("key_1573") },
			}
		end
	end
	local height=15

	for i=1, #rewardTxt do
		local content_1= {}
		local width = 250
		local labelSize = 19
		local renderSize = 20
		content_1[1]= CCRenderLabel:create( rewardTxt[i].rankTxt_1 , g_sFontPangWa,labelSize,1,ccc3(0x00,0x00,0x0),type_stroke)
		content_1[1]:setColor(ccc3(0xff,0xf6,0x00))
		content_1[2]=CCLabelTTF:create("" .. rewardTxt[i].rankNum , g_sFontPangWa,labelSize)
		content_1[2]:setColor(ccc3(0x00,0xff,0x18))
		content_1[3]= CCLabelTTF:create(rewardTxt[i].rankTxt_2, g_sFontPangWa,labelSize)
		content_1[3]:setColor(ccc3(0xff,0xf6,0x00))

		rewardTxt[i].heroName = string.gsub(rewardTxt[i].heroName,"\13", "")

		content_1[4]=CCRenderLabel:create( rewardTxt[i].heroName, g_sFontPangWa,renderSize,1,ccc3(0xff,0xff,0xff), type_stroke)
		content_1[4]:setColor(ccc3(0xc7,0x18,0xdc))

		-- print("rewardTxt[i].heroName", rewardTxt[i].heroName,content_1[4]:getContentSize().height)

		local contentNode_1= BaseUI.createHorizontalNode(content_1)
		contentNode_1:setPosition(width, height)
		height= contentNode_1:getContentSize().height+height+3
		_descSp:addChild(contentNode_1)
	end

	-- 当前排行
	local titleHeight= 134
	local rankNumSp= CCSprite:create(IMG_PATH .. "card_change/rank_title.png")
	rankNumSp:setPosition(252,titleHeight)
	_descSp:addChild(rankNumSp)
	_rankLabel= CCLabelTTF:create("" .. ActiveCache.getRankNum(),g_sFontPangWa,18)--,1,ccc3(0x0,0x0,0x0), type_stroke)
	_rankLabel:setColor(ccc3(0x00,0xff,0x18))
	_rankLabel:setPosition(252+rankNumSp:getContentSize().width, titleHeight)
	_rankLabel:setAnchorPoint(ccp(0,0))
	_descSp:addChild(_rankLabel)

	-- 当前拥有积分
	local width = 366--60 +rankNumSp:getContentSize().width+ _rankLabel:getContentSize().width 
	local pointSp= CCSprite:create(IMG_PATH .. "card_change/point_title.png")
	-- pointSp:setScale(MainScene.elementScale)
	pointSp:setAnchorPoint(ccp(0,0))
	pointSp:setPosition(width , titleHeight)
	_descSp:addChild(pointSp,14)

	width = width + pointSp:getContentSize().width
	_pointLabel=  CCRenderLabel:create("" .. ActiveCache.getScoreNum() , g_sFontPangWa,18,1,ccc3(0x00,0x00,0x0),type_stroke)
	_pointLabel:setColor(ccc3(0xff,0xff,0xff))
	_pointLabel:setPosition(width, titleHeight)
	_pointLabel:setAnchorPoint(ccp(0,0))
	_descSp:addChild(_pointLabel)

	local curGoldSp= CCSprite:create(IMG_PATH .. "card_change/gold_title.png")
	curGoldSp:setPosition(498 , titleHeight)
	_descSp:addChild(curGoldSp,14)

	width= 498 + curGoldSp:getContentSize().width
	local hasGoldContent = {}
	-- hasGoldContent[1]=CCSprite:create("images/common/gold.png")
	hasGoldContent[1]= CCRenderLabel:create("" .. UserModel.getGoldNumber() , g_sFontPangWa,18,1,ccc3(0x00,0x00,0x0),type_stroke)
	hasGoldContent[1]:setColor(ccc3(0xff,0xff,0xff))
	local hasGoldNode = BaseUI.createHorizontalNode(hasGoldContent)
	hasGoldNode:setPosition(width,titleHeight)
	hasGoldNode:setAnchorPoint(ccp(0,0))
	_descSp:addChild(hasGoldNode)

	-- 再招x次就可获得  XXX
	local leftTimeNode= getRecruitLeftNode()
	leftTimeNode:setPosition(254, 168)
	leftTimeNode:setAnchorPoint(ccp(0,0))
	_descSp:addChild(leftTimeNode)

end

function getRecruitLeftNode()

	-- 再招？次必得一张五星武将
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
 	local recuitContent = {}

	recuitContent[1]=  CCRenderLabel:create(GetLocalizeStringBy("key_1470"), g_sFontPangWa, 21, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[1]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[2] = CCRenderLabel:create("" .. tostring(nRecruitLeft), g_sFontPangWa, 21, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[2]:setColor(ccc3(255,255,255))
 	recuitContent[3]=  CCRenderLabel:create(GetLocalizeStringBy("key_1772"), g_sFontPangWa, 21, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[3]:setColor(ccc3(0x51, 0xfb, 255))
 	recuitContent[4]=  CCRenderLabel:create(GetLocalizeStringBy("key_1258"), g_sFontPangWa, 21, 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[4]:setColor(ccc3(255, 0, 0xe1))
 	recuitContent[5]=  CCRenderLabel:create("!", g_sFontPangWa, 21 , 1, ccc3(0, 0, 0), type_stroke)
 	recuitContent[5]:setColor(ccc3(0x51, 0xfb, 255))

    local recuitNode = BaseUI.createHorizontalNode(recuitContent)

 	if(nRecruitLeft ==0 ) then
 		local  recuitThisNode = createRecruitThisNode()
 		
 		return recuitThisNode
 	end
 	return recuitNode

end

function createRecruitThisNode( )
	local alertContent = {}
	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1171") , g_sFontPangWa, 21,2, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0x51, 0xfb, 255))
	alertContent[2] = CCRenderLabel:create(GetLocalizeStringBy("key_2224") , g_sFontPangWa, 23,2, ccc3(0x00,0,0),type_stroke)
	alertContent[2]:setColor(ccc3(255, 0, 0xe1))
	local alert = BaseUI.createHorizontalNode(alertContent)

	return alert
end

-- 创建排名的scrowView
function createRankScrollView( )
	if(table.isEmpty(ActiveCache.getRankInfo()) or _bgLayer== nil) then
		return 
	end

	if(_rankScrollView~= nil) then
		_rankScrollView:removeFromParentAndCleanup(true)
		_rankScrollView= nil
	end

	local rank_info= ActiveCache.getRankInfo()

	_rankScrollView = CCScrollView:create()
	_rankScrollView:setViewSize(CCSizeMake(250,125))
	--added by Zhang Zihang
	--泰国版名字长，所以名字一行，得分一行
	local height
	if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
		height= 70*table.count(rank_info)
	else
		height= 35*table.count(rank_info)
	end
	_rankScrollView:setContentSize(CCSizeMake(230, height))
	-- 设置弹性属性
	_rankScrollView:setBounceable(true)
	_rankScrollView:setTouchPriority(-130)
	_rankScrollView:setDirection(kCCScrollViewDirectionVertical)
	_rankScrollView:setPosition(ccp(0,20))
	
	for i=1, table.count(rank_info) do 
		-- .. rank_info[i].name .. "	" .. rank_info[i].score  
		local rankLabel =  CCLabelTTF:create(rank_info[i].rank .. "." .. rank_info[i].uname , g_sFontName,21)
		rankLabel:setColor(ccc3(0x78,0x25,0x00))
		if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
			rankLabel:setPosition(ccp(20, _rankScrollView:getContentSize().height-(70)*(i)+45))
		else
			rankLabel:setPosition(ccp(20, _rankScrollView:getContentSize().height-(35)*(i)+10))
		end
		rankLabel:setAnchorPoint(ccp(0.5,1))
		_rankScrollView:addChild(rankLabel)
		local nameLabel
		if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
			nameLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyw_127") .. rank_info[i].score , g_sFontName,21)
			nameLabel:setAnchorPoint(ccp(0,0))
			nameLabel:setPosition( 40 ,_rankScrollView:getContentSize().height-(70)*(i)+10)
		else
			nameLabel = CCLabelTTF:create(rank_info[i].score , g_sFontName,21)
			nameLabel:setAnchorPoint(ccp(1,1))
			nameLabel:setPosition( 190 ,_rankScrollView:getContentSize().height-(35)*(i)+10)
		end
		nameLabel:setColor(ccc3(0x78,0x25,0x00))
		_rankScrollView:addChild(nameLabel)
		
	end
	_rankScrollView:setContentOffset(ccp(0, _rankScrollView:getViewSize().height - height))
	_rankScrollView:setPosition(0,24)
	-- _rankScrollView:setAnchorPoint(ccp(0.5,0))
	_rankBg:addChild(_rankScrollView)

end

-- 刷新底部UI
function refreshBottomUI(  )
	
	createRankScrollView()
	if(_rankLabel== nil or _bgLayer== nil) then
		return
	end
	local rank_info = ActiveCache.getRankInfo()
	if(table.isEmpty(rank_info)) then
		return
	end
	local uid= UserModel.getUserUid()

	-- 玩家是否在前20 中
	local ishas= true
	for i=1 ,#rank_info do
		if(tonumber(rank_info[i].uid)== uid) then
			_rankLabel:setString(rank_info[i].rank)
			ishas= false
			break
		end
	end

	if(tonumber(ActiveCache.getRankNum()) <=20 and ishas ) then
		Network.rpc(heroShopInfo_02, "heroshop.getMyShopInfo" , "heroshop.getMyShopInfo", nil , true)
	end

end

-- 创建顶部的UI
function createTopUI(  )

	_curtainTop= CCSprite:create(IMG_PATH .. "curtain_top.png")
	_curtainTop:setPosition(_layerSize.width/2,_layerSize.height+40*g_fScaleX)
	_curtainTop:setAnchorPoint(ccp(0.5,1))
	_curtainTop:setScale(g_fScaleX)
	_bgLayer:addChild(_curtainTop,12)

	-- 右边的窗帘
	local curtainRightSide = CCSprite:create(IMG_PATH .. "curtain_side.png")
	curtainRightSide:setPosition(_layerSize.width, _layerSize.height)
	curtainRightSide:setAnchorPoint(ccp(1,1))
	curtainRightSide:setScale(MainScene.elementScale)
	_bgLayer:addChild(curtainRightSide)

	--  左边的窗帘
	local curtainLeftSide= CCSprite:create(IMG_PATH .. "curtain_side.png")
	curtainLeftSide:setPosition(0,_layerSize.height)
	curtainLeftSide:setAnchorPoint(ccp(0,1))
	curtainLeftSide:setFlipX(true)
	curtainLeftSide:setScale(MainScene.elementScale)
	_bgLayer:addChild(curtainLeftSide)

	local cardTitle= CCSprite:create(IMG_PATH .. "title.png")
	cardTitle:setPosition(_curtainTop:getContentSize().width/2,15)
	cardTitle:setAnchorPoint(ccp(0.5,0))
	_curtainTop:addChild(cardTitle)

	-- 按钮
	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	_bgLayer:addChild(menu,111)

	-- -- 活动描述按钮
	local activeDescBtn= CCMenuItemImage:create(IMG_PATH .. "btn_desc/btn_desc_n.png", IMG_PATH .. "btn_desc/btn_desc_h.png")
	activeDescBtn:setPosition(_layerSize.width*527/640,_layerSize.height*518/658)
	activeDescBtn:setScale(MainScene.elementScale)
	activeDescBtn:registerScriptTapHandler(menuAction)
	menu:addChild(activeDescBtn,111, _ksTagActive)

	-- 活动时间
	local xWidth = 8/640*_layerSize.width 	
	local height = _layerSize.height - (_curtainTop:getContentSize().height-55)*g_fScaleX
	local timeContent= {}  
	timeContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2000") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	timeContent[1]:setColor(ccc3(0x00,0xff,0x18))
	timeContent[1]:setPosition(xWidth, height)
	timeContent[1]:setScale(MainScene.elementScale)
	-- timeContent[1]:setAnchorPoint(ccp(0.5,1))
	_bgLayer:addChild(timeContent[1],18)

	height = height - timeContent[1]:getContentSize().height*MainScene.elementScale -2*MainScene.elementScale
	timeContent[2]= CCRenderLabel:create( TimeUtil.getTimeToMin(ActiveCache.getHeroShopStartTime()) .. GetLocalizeStringBy("key_2358"),g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	timeContent[2]:setColor(ccc3(0xff,0xff,0xff))
	timeContent[2]:setPosition(xWidth , height)
	timeContent[2]:setScale(MainScene.elementScale)
	_bgLayer:addChild(timeContent[2],15)

	height =height -  timeContent[2]:getContentSize().height*MainScene.elementScale -2*MainScene.elementScale
	timeContent[3]= CCRenderLabel:create( "" .. TimeUtil.getTimeToMin(ActiveCache.getHeroShopEndTime()),g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	timeContent[3]:setColor(ccc3(0xff,0xff,0xff))
	timeContent[3]:setPosition(xWidth , height)
	timeContent[3]:setScale(MainScene.elementScale)
	_bgLayer:addChild(timeContent[3],15)

	--  显示活动倒计时
	height= height -  timeContent[3]:getContentSize().height*MainScene.elementScale -4*MainScene.elementScale
	local leftTimeTxt= CCRenderLabel:create(GetLocalizeStringBy("key_3201"),g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	leftTimeTxt:setColor(ccc3(0x00,0xff,0x18))
	leftTimeTxt:setPosition(xWidth,height )
	-- leftTimeTxt:setAnchorPoint(ccp(0,1))
	leftTimeTxt:setScale(MainScene.elementScale)
	_bgLayer:addChild(leftTimeTxt,18)
	_leftTimeLabel= CCLabelTTF:create(TimeUtil.getTimeString(ActiveCache.getHeroShopEndTime() - BTUtil:getSvrTimeInterval() ) , g_sFontName,21)
	_leftTimeLabel:setPosition(leftTimeTxt:getContentSize().width/2, -5)
	_leftTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	_leftTimeLabel:setAnchorPoint(ccp(0.5,1))
	leftTimeTxt:addChild(_leftTimeLabel,18)

end

function getFreeTimeNode(  )
	local freeContent = {}
	freeContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_1835") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	freeContent[1]:setColor(ccc3(0x00,0xff,0x18))
	freeContent[2]= CCRenderLabel:create("" .. 1, g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	freeContent[2]:setColor(ccc3(0xff,0xf6,0x00))
	freeContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_3010") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	freeContent[3]:setColor(ccc3(0x00,0xff,0x18))

	local freeNode = BaseUI.createHorizontalNode(freeContent)
	-- leftNode:setPosition(goldChargeItem:getContentSize().width/2,2)
	-- leftNode:setAnchorPoint(ccp(0.5,1))
	-- goldChargeItem:addChild(leftNode)
	return freeNode

end

-- 刷新顶部UI
function refreshTopUI(  )
	_pointLabel:setString("" .. ActiveCache.getScoreNum())
end

-- 中部的ui，闹钟和光 按钮
function createMiddleUI( )
	
	-- -- 创建
	local light= CCSprite:create(IMG_PATH .. "light.png")
	light:setPosition(_layerSize.width/2, _descSp:getContentSize().height*g_fScaleX)
	light:setAnchorPoint(ccp(0.5,0))
	light:setScale(MainScene.elementScale)
	_bgLayer:addChild(light)

	_carpetSp = CCSprite:create(IMG_PATH .. "card_change/carpet.png")
	_carpetSp:setPosition(ccp(_layerSize.width/2, _descSp:getContentSize().height*206/268*g_fScaleX))
	_carpetSp:setAnchorPoint(ccp(0.5,0))
	_carpetSp:setScale(MainScene.elementScale)
	_bgLayer:addChild(_carpetSp)

	-- 卡牌预览
	local cardShowSp= CCSprite:create(IMG_PATH .. "card_show.png")
	cardShowSp:setPosition(_carpetSp:getContentSize().width/2, 18)
	cardShowSp:setAnchorPoint(ccp(0.5,0))
	_carpetSp:addChild(cardShowSp)

	-- 英雄的背景
	_heroNameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	_heroNameBg:setContentSize(CCSizeMake(196, 31))
	_heroNameBg:setAnchorPoint(ccp(0.5,0))
	_heroNameBg:setScale(g_fScaleX)
	_heroNameBg:setPosition(ccp(_layerSize.width*0.5,_carpetSp:getPositionY()+ _carpetSp:getContentSize().height*1/2*g_fScaleX))
	_bgLayer:addChild(_heroNameBg,111)


	local heroData = DB_Heroes.getDataById(_heroTable[1])
	_heroNameLabel = CCRenderLabel:create("" ..heroData.name , g_sFontPangWa, 21,1,ccc3(0x00,0x00,0x00),type_stroke)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	_heroNameLabel:setColor(nameColor)
	_heroNameLabel:setPosition(_heroNameBg:getContentSize().width/2,_heroNameBg:getContentSize().height/2)
	_heroNameLabel:setAnchorPoint(ccp(0.5,0.5))
	_heroNameBg:addChild(_heroNameLabel,11)

	_starsBgSp = CCSprite:create("images/formation/stars_bg.png")
	_starsBgSp:setAnchorPoint(ccp(0.5, 1))
	_starsBgSp:setScale(MainScene.elementScale)
	_starsBgSp:setPosition(ccp(_layerSize.width/2, _curtainTop:getPositionY()-_curtainTop:getContentSize().height*g_fScaleX-4 ))
	_bgLayer:addChild(_starsBgSp, 2)

	starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
	starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}

	starArr_h={}
	for starIndex, xScale in pairs(starsXPositions) do
		local starSp = CCSprite:create("images/formation/star.png")
		starSp:setAnchorPoint(ccp(0.5, 0.5))
		starSp:setPosition(ccp(_starsBgSp:getContentSize().width * xScale, _starsBgSp:getContentSize().height * starsYPositions[starIndex]))
		_starsBgSp:addChild(starSp)
		table.insert(starArr_h, starSp)
	end

	-- 抽取按钮
	local menu= CCMenu:create()
	menu:setPosition(0,0)
	_bgLayer:addChild(menu,222)

	-- 免费抽取按钮
	local freeChargeItem = CCMenuItemImage:create(IMG_PATH .. "free_charge/free_charge_n.png", IMG_PATH .. "free_charge/free_charge_h.png")
	freeChargeItem:setPosition( _layerSize.width*0.04,  _descSp:getContentSize().height*g_fScaleX*233/268)
	freeChargeItem:registerScriptTapHandler(buyHeroAction)
	freeChargeItem:setScale(MainScene.elementScale)
	menu:addChild(freeChargeItem,111,_ksTagFreeCharge)

	-- CCLabelTTF:create( TimeUtil.getTimeString(12), g_sFontName, 21)
	_freeTimeLabel= CCLabelTTF:create(TimeUtil.getTimeString(ActiveCache.getFreeCdTime()),g_sFontName, 21)--,1, ccc3(0x00,0x00,0x00), type_stroke)
	_freeTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	_freeTimeLabel:setPosition(freeChargeItem:getContentSize().width/2,0)
	_freeTimeLabel:setAnchorPoint(ccp(0.5,1))
	freeChargeItem:addChild(_freeTimeLabel)

	_freeTimeNode = getFreeTimeNode()
	_freeTimeNode:setPosition(freeChargeItem:getContentSize().width/2,0)
	_freeTimeNode:setAnchorPoint(ccp(0.5,1))
	_freeTimeNode:setVisible(false)
	freeChargeItem:addChild(_freeTimeNode)

	if( tonumber(ActiveCache.getFreeCdTime())<=0 ) then
		_freeTimeNode:setVisible(true)
		_freeTimeLabel:setVisible(false)
	end

	-- 金币抽取的按钮
	local goldChargeItem = CCMenuItemImage:create(IMG_PATH .. "gold_charge/gold_charge_n.png", IMG_PATH .. "gold_charge/gold_charge_h.png")
	goldChargeItem:setPosition( _layerSize.width*615/640,  _descSp:getContentSize().height*g_fScaleX*233/268)
	goldChargeItem:registerScriptTapHandler(buyHeroAction)
	goldChargeItem:setAnchorPoint(ccp(1,0))
	goldChargeItem:setScale(MainScene.elementScale)
	menu:addChild(goldChargeItem,1, _ksTagGoldCharge)

	local goldContent= {}
	if(ActiveCache.getFreeNum() <=0) then
		goldContent[1]=CCSprite:create("images/common/gold.png")
		goldContent[2]= CCRenderLabel:create("" .. ActiveCache.getGoldCost() , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
		goldContent[2]:setColor(ccc3(0xff,0xf6,0x00))
	else
		goldContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_1723") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
		goldContent[1]:setColor(ccc3(0x00,0xff,0x18))
		goldContent[2]= CCRenderLabel:create("" .. ActiveCache.getFreeNum(), g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
		goldContent[2]:setColor(ccc3(0xff,0xf6,0x00))
		goldContent[3]= CCRenderLabel:create(GetLocalizeStringBy("key_3010") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
		goldContent[3]:setColor(ccc3(0x00,0xff,0x18))

	end
	local goldNode= BaseUI.createHorizontalNode(goldContent)
	goldNode:setPosition(goldChargeItem:getContentSize().width/2,2)
	goldNode:setAnchorPoint(ccp(0.5,1))
	goldChargeItem:addChild(goldNode)

	-- 定时器
	_updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)

	-- 创建闹钟的
	createHeroesScr()
	-- refreshMiddleUI()

	local arrowLeft= CCSprite:create("images/common/arrow_left.png")
	arrowLeft:setPosition( _heroSrc:getPositionX() ,(_descSp:getContentSize().height )*g_fScaleX + _heroSrc:getScale()*109 ) 
	arrowLeft:setAnchorPoint(ccp(0.2,0))
	_bgLayer:addChild(arrowLeft)

	local arrowRight = CCSprite:create("images/common/arrow_right.png")
	arrowRight:setPosition( _heroSrc:getPositionX()+ _heroSrc:getScale()*_heroSrc:getViewSize().width ,(_descSp:getContentSize().height )*g_fScaleX + _heroSrc:getScale()*109 ) 
	arrowRight:setAnchorPoint(ccp(0.8,0))
	_bgLayer:addChild(arrowRight)

	refreshMiddleUI()


end

-- 刷新MIddleUI
function refreshMiddleUI( )
	local heroData= DB_Heroes.getDataById(_heroTable[_curHeroIndex])
	_heroNameLabel:setString(heroData.name)

	
    local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
    local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}

	for k, h_starsp in pairs(starArr_h) do
		if ((heroData.potential%2) ~= 0) then
			h_starsp:setPosition(ccp(_starsBgSp:getContentSize().width * starsXPositions[k], _starsBgSp:getContentSize().height * starsYPositions[k]))
			if(k<= heroData.potential) then
				h_starsp:setVisible(true)
			else
				h_starsp:setVisible(false)
			end
		else
			h_starsp:setPosition(ccp(_starsBgSp:getContentSize().width * starsXPositionsDouble[k], _starsBgSp:getContentSize().height * starsYPositionsDouble[k]))
			if(k<= heroData.potential) then
				h_starsp:setVisible(true)
			else
				h_starsp:setVisible(false)
			end
		end
	end

end

-- 设置
local function endAction(  )
	
end

--[[
 @desc	 切换中间卡牌
 @para 		
 @return 
--]]
local function switchCard( xOffset )
	if (math.abs(xOffset) < 20) then
		local htid= _heroTable[_curHeroIndex]
		heroAction(htid)
		print("xOffset is : ", -(_curHeroIndex -1 )*_curHeroSize.width)
		_heroSrc:setContentOffset(ccp(-(_curHeroIndex -1 )*_curHeroSize.width , 0))
	else
		if(xOffset<0) then
			if(_curHeroIndex == table.count(ActiveCache.getShowHeroes())) then
				_curHeroIndex= _curHeroIndex
			else
				_curHeroIndex = _curHeroIndex+1
			end
		else
			if(_curHeroIndex== 1) then
				_curHeroIndex=_curHeroIndex
			else
				_curHeroIndex = _curHeroIndex-1
			end
		end
		refreshMiddleUI()
		print("_curHeroIndex  is : ", _curHeroIndex)
		print("xOffset is : 222222 ", -(_curHeroIndex -1 )*_curHeroSize.width)
		_heroSrc:setContentOffsetInDuration(ccp(-(_curHeroIndex -1 )*_curHeroSize.width , 0),0.2)
		
	end

end


-- 重写scrowllview 的touch 事件
function onTouchesHandler( eventType, x, y )
	if(eventType == "began") then
		print("began")
		touchBeganPoint = ccp(x, y)

		local vPosition = _heroSrc:convertToNodeSpace(touchBeganPoint)
	  
	 	local carpetPos = _carpetSp:convertToNodeSpace(touchBeganPoint)
	 	local curtaioPos= _curtainTop:convertToNodeSpace(touchBeganPoint)
	 	if ( vPosition.x >0 and vPosition.x <  _curHeroSize.width and vPosition.y > 0 and vPosition.y < _curHeroSize.height ) then
			return true
		end
	elseif(eventType == "moved") then
		
		print("moved")
		_heroSrc:setContentOffset(ccp(x - touchBeganPoint.x- (_curHeroIndex-1)*_curHeroSize.width , 0))
	else
		print("ended")
		local xOffset = x - touchBeganPoint.x
		switchCard(xOffset)
	end	
	
end

-- 创建英雄的scrowView
function createHeroesScr( )

	if(_heroSrc~= nil) then
		_heroSrc:removeFromParentAndCleanup(true)
		_heroSrc= nil
	end
	-- local xWidth = 340
	_curHeroSize.width= 360
	_curHeroSize.height= 300
	_heroTable= ActiveCache.getShowHeroes()
	_heroSrc= CCScrollView:create()
	_heroSrc:setViewSize(CCSizeMake(_curHeroSize.width,300))
	_heroSrc:setContentSize(CCSizeMake(_curHeroSize.width*(#_heroTable)*1, 300))
	_heroSrc:setContentOffset(ccp(0,0))
	_heroSrc:setDirection(kCCScrollViewDirectionHorizontal)
    -- _clockSp:addChild(_heroSrc,1,2000)
    _bgLayer:addChild(_heroSrc)
	local height_1=_curtainTop:getPositionY()- _curtainTop:getContentSize().height*(_curtainTop:getScale())
	local height_2= _descSp:getContentSize().height*(_descSp:getScale())+ _descSp:getPositionY()
	height = height_1- height_2+20*MainScene.elementScale
	_heroSrcScale= height/305
	_heroSrc:setScale(_heroSrcScale)
	_heroSrc:setPosition( (_layerSize.width - _curHeroSize.width*_heroSrcScale)/2, _descSp:getContentSize().height*g_fScaleX*300/320)

    _heroSrcLayer= CCLayer:create()
    _heroSrcLayer:setPosition(ccp(0,0))
    _heroSrcLayer:setContentSize( CCSizeMake( _curHeroSize.width*table.count(_heroTable), _curHeroSize.height ))
    _heroSrc:setContainer(_heroSrcLayer)

    for i=1, #_heroTable do
    	local htid= _heroTable[i]
    	local heroSpTable_1=  getHeroSoprite(htid)
    	heroSpTable_1:setAnchorPoint(ccp(0.5,0))
		-- heroSpTable_1:setPosition(ccp(xWidth*(i-1)+39 , 25)) (_curHeroSize.width- heroSpTable_1:getContentSize().width*0.6)/2
		heroSpTable_1:setPosition(ccp(_curHeroSize.width*(i-0.5) , 25))
		heroSpTable_1:setScale(0.6)
		_heroSrcLayer:addChild(heroSpTable_1,1, htid)
    end
end

function getHeroSoprite( htid )
	local heroLocalInfo = DB_Heroes.getDataById(tonumber(htid))		
	iconName = "images/base/hero/body_img/" .. heroLocalInfo.body_img_id
	local heroSprite = CCSprite:create(iconName)
	return heroSprite
end


function updateShieldTime(  )
	local shieldTime = "" .. TimeUtil.getTimeString(ActiveCache.getFreeCdTime())
	if(_bgLayer~= nil and _freeTimeLabel~= nil ) then
		_freeTimeLabel:setString(shieldTime)
		if( tonumber(ActiveCache.getFreeCdTime())<=0 ) then
			_freeTimeNode:setVisible(true)
			_freeTimeLabel:setVisible(false)
		end
	end

	local leftTime= TimeUtil.getTimeString(ActiveCache.getHeroShopEndTime() - BTUtil:getSvrTimeInterval() )
	if(_bgLayer~= nil and _leftTimeLabel ~= nil ) then
		_leftTimeLabel:setString(leftTime)
	end
end


------------------------------------------------  callBack -----------------------------------------------
-- 按钮的回调事件
function menuAction( tag, item )
	 AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(tag== _ksTagRecharge) then
		require "script/ui/shop/RechargeLayer"
		local layer = RechargeLayer.createLayer()
		local scene = CCDirector:sharedDirector():getRunningScene()
		scene:addChild(layer,1111)
	elseif(tag == _ksTagActive) then
		require "script/ui/rechargeActive/CardPackDescLayer"
		CardPackDescLayer.showDesc()
	end
end

function buyHeroAction( tag, item )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(  BTUtil:getSvrTimeInterval()< ActiveCache.getHeroShopStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getHeroShopEndTime() ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_3025"))
		return
	end

	local args= CCArray:create()

	if(tag== _ksTagFreeCharge) then
		print(GetLocalizeStringBy("key_1094"))
		if(ActiveCache.getFreeCdTime() <=0 ) then

			args:addObject(CCInteger:create(1))
			ActiveCache.setBuyHeroType(1)
			
		else 
			AnimationTip.showTip(GetLocalizeStringBy("key_3035"))
			return
		end 
	elseif(tag== _ksTagGoldCharge) then
		print(GetLocalizeStringBy("key_2769"))
		if(ActiveCache.getFreeNum()<=0) then
			args:addObject(CCInteger:create(3))
			ActiveCache.setBuyHeroType(3)
			if(UserModel.getGoldNumber()< ActiveCache.getGoldCost() ) then
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
				return
			end

		else
			ActiveCache.setBuyHeroType(2)
			args:addObject(CCInteger:create(2))
		end
	end

	Network.rpc(buyHeroCallback, "heroshop.buyHero" , "heroshop.buyHero", args , true)
end

-- 
function heroShopInfo( cbFlag, dictData, bRet  )
	if (dictData.err == "ok") then
		-- added by zhz
		-- 将数据缓存器起来数据
		ActiveCache.setCardInfo(dictData.ret)
		createBottom()
		createTopUI()
		createMiddleUI()
 		
    end
   
end

-- 购买英雄得callBack
function buyHeroCallback( cbFlag, dictData, bRet  )
	if (dictData.err == "ok") then
		require "script/ui/shop/HeroDisplayerLayer"
		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil
		print("dictData.shop_info  is :")
		print_t(dictData.ret.shop_info)
		ActiveCache.setRankShopInfo(dictData.ret.shop_info)
		ActiveCache.setRankNum(dictData.ret.rank)
		print("dictData.ret.rank is : ", dictData.ret.rank)
		print("ActiveCache.getRankNum()  is : ", ActiveCache.getRankNum())
		ActiveCache.setRankInfo(dictData.ret.rank_info )
		if(ActiveCache.getBuyHeroType() == 3 ) then
			UserModel.addGoldNumber(-ActiveCache.getGoldCost() )
		end

		h_tid = tonumber(dictData.ret.htid)
		h_id = tonumber(dictData.ret. hid)
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, addPoint,4)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end

-- 离开卡包活动, 
function leaveShopCb( cbFlag, dictData, bRet  )
 	if (dictData.err == "ok") then
		-- added by zhz
    end
 end 

-- 获得英雄的信息
local function getHeroData( htid)
	local value = {}

	value.htid = htid
	local db_hero = DB_Heroes.getDataById(htid)
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
	value.name = db_hero.name
	value.level = db_hero.lv
	value.star_lv = db_hero.star_lv
	value.hero_cb = menu_item_tap_handler
	value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
	value.quality_h = "images/hero/quality/highlighted.png"
	value.type = "HeroFragment"
	value.isRecruited = false
	value.evolve_level = 0

	return value
end

 function heroAction( tag)
 	require "script/ui/hero/HeroInfoLayer"
 	local data = getHeroData(tag)
	local tArgs = {}
	-- tArgs.sign = "HeroShowLayer"
	-- tArgs.fnCreate = HeroShowLayer.createLayer
	-- tArgs.reserved =  {index= 10001}
	HeroInfoLayer.createLayer(data, {isPanel=true},1000,-776)
 end


function heroShopInfo_02( cbFlag, dictData, bRet  )
	if (dictData.err == "ok") then
		-- added by zhz
		if(_rankLabel== nil or _bgLayer== nil) then
			return
		end
		_rankLabel:setString("" ..dictData.ret.rank)
    end
end

function heroShopInfo_03( cbFlag, dictData, bRet  )
	if (dictData.err == "ok") then
		ActiveCache.setCardInfo(dictData.ret)
		createRankScrollView()
		print(" ============== ============ =heroShopInfo_03  ")
		if(_rankLabel~= nil  and _bgLayer~= nil ) then
			print("ActiveCache.getRankNum()  is ", ActiveCache.getRankNum())
			_rankLabel:setString("".. ActiveCache.getRankNum())
		end
	end

end

function endactAction(  )
	Network.rpc(heroShopInfo_03, "heroshop.getMyShopInfo" , "heroshop.getMyShopInfo", nil , true)
end

