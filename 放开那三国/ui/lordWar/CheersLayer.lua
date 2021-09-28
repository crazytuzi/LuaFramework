-- FileName: CheersLayer.lua
-- Author: llp
-- Date: 14-4-21
-- Purpose: 查看报名军团


module("CheersLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/guild/city/CityService"
require "script/ui/guild/GuildImpl"
require "script/model/utils/ActivityConfig"
require "db/DB_Kuafu_challengereward"
require "script/ui/lordWar/LordWarService"

local _bgLayer                  = nil
local _backGround 				= nil
local second_bg  				= nil
local _thisCityID 				= nil
local _listData 				= nil
local _selfData 				= nil
local secondSprite 				= nil
local _touchPriority 			= nil
local dbDataCache 				= nil
local dbDataArry 				= nil
local partDbDataArry 			= nil
local itemTag 					= 0
local cheerMenu 				= nil
local lordData 					= nil
-- local cheerTimes 				= 0

function init( ... )
	_bgLayer                    = nil
	_backGround 				= nil
	second_bg  					= nil
	_thisCityID 				= nil
	_listData 					= nil
	_selfData 					= nil
	secondSprite 				= nil
	_touchPriority 				= nil
	dbDataCache 				= nil
	dbDataArry 					= nil
	partDbDataArry 				= nil
	itemTag 					= 0
	cheerMenu 					= nil
	lordData 					= nil
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-453,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

local function dataCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		if(table.isEmpty(dictData.ret[1]))then
			return
		end
		require "script/ui/lordWar/LordWarData"

		LordWarData.setKingInfo(LordWarData._templeInfo)
		heroNameNode()
		heroBodyNode()
	else
		return
	end
end

-- 初始化界面
function show( p_priority , p_zOrder)
	init()
	lordData = LordWarData.getLordInfo()
	dbDataCache = ActivityConfig.ConfigCache.lordwar.data[1]

	dbDataArry = string.split(dbDataCache.wishCost,",")

	_zOrder = p_zOrder or 1000
	_touchPriority = p_priority or -459
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(620, 693))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_84"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority - 10)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

-- 二级背景
	secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondSprite:setContentSize(CCSizeMake(565,565))
	secondSprite:setAnchorPoint(ccp(0.5,1))
	secondSprite:setPosition(ccp(_backGround:getContentSize().width/2,_backGround:getContentSize().height - 60))
	_backGround:addChild(secondSprite)

	second_bg = CCSprite:create("images/lord_war/cheersdocument/cheersBg.jpg")--BaseUI.createContentBg(CCSizeMake(556,377))
 	second_bg:setAnchorPoint(ccp(0.5,0.5))
 	second_bg:setPosition(ccp(secondSprite:getContentSize().width*0.5,secondSprite:getContentSize().height*0.5))
 	second_bg:setScaleY(1.1)
 	secondSprite:addChild(second_bg)

 	-- heroNameNode()
 	cheersItem()
 	-- RequestCenter.getKingInfo(dataCallBack)
 	local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_85"),g_sFontPangWa,23)
 	secondSprite:addChild(desLabel)
 	desLabel:setAnchorPoint(ccp(0.5,1))
 	desLabel:setPosition(ccp(secondSprite:getContentSize().width*0.5,0))
 	desLabel:setColor(ccc3(0x78,0x25,0x00))

 	-- print("xixihahaxixihaha")
 	-- print_t(LordWarData._templeInfo)
 	-- print("xixihahaxixihaha")
 	LordWarData.setKingInfo(LordWarData.getTempleInfo())
	heroNameNode()
	heroBodyNode()
end

function heroBodyNode( ... )
	-- body
	local totalWinnerSprite = CCSprite:create("images/lord_war/cheersdocument/totalwinner.png")
 	secondSprite:addChild(totalWinnerSprite,1)
 	totalWinnerSprite:setAnchorPoint(ccp(0.5,1))
 	totalWinnerSprite:setPosition(ccp(secondSprite:getContentSize().width*0.5,secondSprite:getContentSize().height))

 	local baseChairSprite = CCSprite:create("images/olympic/kingChair.png")
 	secondSprite:addChild(baseChairSprite,1)
 	baseChairSprite:setAnchorPoint(ccp(0.5,0))
 	baseChairSprite:setPosition(ccp(secondSprite:getContentSize().width*0.5,secondSprite:getContentSize().height*0.4))

 	local redLightSprite = CCSprite:create("images/olympic/kingLight.png")
 	baseChairSprite:addChild(redLightSprite,1)
 	redLightSprite:setAnchorPoint(ccp(0.5,0))
 	redLightSprite:setPosition(ccp(baseChairSprite:getContentSize().width*0.5,baseChairSprite:getContentSize().height*0.5))

 	local dataCache = LordWarData.getKingInfo()
 	local sex = HeroModel.getSex(dataCache[1].htid)
 	local spriteStr = nil
 	if(table.isEmpty(dataCache[1].dress))then
 		spriteStr = HeroUtil.getHeroBodyImgByHTID(dataCache[1].htid)
 	else
 		spriteStr = HeroUtil.getHeroBodyImgByHTID(dataCache[1].htid,dataCache[1].dress["1"],sex)
 	end

 	local bodySprite = CCSprite:create(spriteStr)
 	bodySprite:setScale(0.5)
 	baseChairSprite:addChild(bodySprite,20)
 	bodySprite:setAnchorPoint(ccp(0.5,0))
 	bodySprite:setPosition(ccp(baseChairSprite:getContentSize().width*0.5,baseChairSprite:getContentSize().height*0.5))

 	-- 特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/jinpai/jinpai"), 1,CCString:create(""));
	-- spellEffectSprite:setScale(g_fBgScaleRatio/MainScene.elementScale*1.01)
	spellEffectSprite:setAnchorPoint(ccp(0.5,0.5))
    spellEffectSprite:setPosition(ccp( totalWinnerSprite:getContentSize().width*0.5,totalWinnerSprite:getContentSize().height*0.5) )
    totalWinnerSprite:addChild(spellEffectSprite,1);

    local animationEnd = function(actionName,xmlSprite)
        spellEffectSprite:cleanup()
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)

    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
end

function heroNameNode( ... )
	-- body
	-- 英雄的名字
	local dataCache = LordWarData.getKingInfo()
	local heroNameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	local nameLabel = CCLabelTTF:create(dataCache[1].uname, g_sFontPangWa, 22)
	require "script/ui/login/ServerList"
	local zoneStr = ServerList.getServerNumByGroupId(dataCache[1].serverId)
	local zoneLabel = CCLabelTTF:create("("..zoneStr..GetLocalizeStringBy("llp_86")..dataCache[1].serverName, g_sFontPangWa, 22)

	heroNameBg:setContentSize(CCSizeMake(240, nameLabel:getContentSize().height+zoneLabel:getContentSize().height))

	heroNameBg:setAnchorPoint(ccp(0.5,1))
	heroNameBg:setPosition(ccp(secondSprite:getContentSize().width*0.5, secondSprite:getContentSize().height*0.4))
	secondSprite:addChild(heroNameBg,2)


	nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	nameLabel:setAnchorPoint(ccp(0.5,0))
	nameLabel:setPosition(ccp(heroNameBg:getContentSize().width*0.5, heroNameBg:getContentSize().height*0.5))
	heroNameBg:addChild(nameLabel)


	zoneLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	zoneLabel:setAnchorPoint(ccp(0.5,1))
	zoneLabel:setPosition(ccp(heroNameBg:getContentSize().width*0.5, heroNameBg:getContentSize().height*0.5))
	heroNameBg:addChild(zoneLabel)
end

local function rewardCallBack( ... )
	-- body
	require "script/ui/lordWar/reward/WishRewardLayer"
	local rewardLayer = WishRewardLayer.showLayer( _touchPriority-10, _zOrder + 10 )
end

local function animationCallBack(cbFlag, dictData, bRet)
	-- body
	-- 刷新金币ui
	require "script/ui/lordWar/ChampionLayer"
	ChampionLayer.updateTopUi()

	LordWarData.addCheerTimes()
	cheerMenu:setTouchEnabled(true)
	local img_path = CCString:create("images/pet/effect/chongwuweiyang/chongwuweiyang")
	local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	-- music
	if(file_exists("images/pet/effect/chongwuweiyang.mp3")) then
    	require "script/audio/AudioUtil"
    	AudioUtil.playEffect("images/pet/effect/chongwuweiyang.mp3")
	end
	addPetEffect:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
	addPetEffect:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(addPetEffect, 1000)

	require "db/DB_Achie_table"
	require "script/ui/item/ItemUtil"
	require "script/ui/item/ReceiveReward"

	local rewardCache = string.split(dbDataCache.wishReward,",")
	local oneRewardCache = DB_Kuafu_challengereward.getDataById(tonumber(rewardCache[itemTag]))
	local reward = ItemUtil.getItemsDataByStr( oneRewardCache.reward)
    ReceiveReward.showRewardWindow( reward, nil , 10008, -800 )
    ItemUtil.addRewardByTable(reward)
end

local function itemCallBack( tag,obj )
	-- body
	if(tonumber(lordData.worship_num)>0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_87"))
		return
	end
	-- for i=1,#dbDataArry do
		partDbDataArry = string.split(dbDataArry[tag],"|")
	-- end

	if(tonumber(partDbDataArry[1])==1)then
		if(UserModel.getSilverNumber()<tonumber(partDbDataArry[3]))then
			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        	return
		end
	elseif(tonumber(partDbDataArry[1])==3)then
		if(UserModel.getGoldNumber()<tonumber(partDbDataArry[3]))then
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			return
		end
	end

	-- 宠物背包满了
	require "script/ui/pet/PetUtil"
	if PetUtil.isPetBagFull() == true then
		closeButtonCallback()
		return
	end

	-- 物品背包满了
	require "script/ui/item/ItemUtil"
	if(ItemUtil.isBagFull() == true )then
		closeButtonCallback()
		return
	end
	-- 武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	closeButtonCallback()
    	return
    end
    cheerMenu:setTouchEnabled(false)
	if(tag==1)then
		itemTag = 1
		LordWarService.worship(0,0,animationCallBack)
	elseif(tag==2)then
		itemTag = 2
		LordWarService.worship(0,1,animationCallBack)
	elseif(tag==3)then
		itemTag = 3
		LordWarService.worship(0,2,animationCallBack)
	end
end

local function costNodeFunction( type,num )
	-- body
	local node = CCNode:create()
	node:setAnchorPoint(ccp(0.5,1))
	local costLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_88"), g_sFontPangWa, 22)
    node:addChild(costLabel)
    local sliverSprite = CCSprite:create("images/common/coin.png")
    if(type==1)then
    	costLabel:addChild(sliverSprite)
    	sliverSprite:setAnchorPoint(ccp(0,0))
    	sliverSprite:setPosition(ccp(costLabel:getContentSize().width,0))
  	elseif(type==3 or type==2)then
  		local goldSprite = CCSprite:create("images/common/gold.png")
  		costLabel:addChild(goldSprite)
    	goldSprite:setAnchorPoint(ccp(0,0))
    	goldSprite:setPosition(ccp(costLabel:getContentSize().width,0))
  	end
  	local costNumLabel = CCLabelTTF:create(num,g_sFontName,22)
  	costNumLabel:setColor(ccc3(0xff,0xf6,0x00))
  	costNumLabel:setAnchorPoint(ccp(0,0))
  	costNumLabel:setPosition(ccp(costLabel:getContentSize().width+sliverSprite:getContentSize().width,0))
  	costLabel:addChild(costNumLabel)
  	node:setContentSize(CCSizeMake(costLabel:getContentSize().width+sliverSprite:getContentSize().width+costNumLabel:getContentSize().width,sliverSprite:getContentSize().height))
  	return node
end

function cheersItem( ... )
	-- body
	local _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bottomBg:setContentSize(CCSizeMake(561,160))
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(secondSprite:getContentSize().width*0.5, 5)
    secondSprite:addChild(_bottomBg,11)

    cheerMenu = CCMenu:create()
    cheerMenu:setTouchPriority(-459)
    cheerMenu:setAnchorPoint(ccp(0.5,0.5))
    cheerMenu:setPosition(ccp(0,0))
    _bottomBg:addChild(cheerMenu,2)
    local dbDataCacheCpy = DB_Kuafu_personchallenge.getDataById(1)

	local dbDataArryCpy = string.split(dbDataCacheCpy.wishCost,",")

    for i=1,3 do
    	local blackSprite = CCSprite:create("images/lord_war/cheersdocument/wineBg.png")
    	_bottomBg:addChild(blackSprite,1)
    	blackSprite:setAnchorPoint(ccp(0.5,0.5))
    	blackSprite:setPosition(ccp(_bottomBg:getContentSize().width*0.25*i,_bottomBg:getContentSize().height*0.6))
    	local partDbDataArryCpy = string.split(dbDataArryCpy[i],"|")
    	print(partDbDataArryCpy[3].."!!!!!!!!")
    	local node = costNodeFunction(tonumber(partDbDataArryCpy[1]),partDbDataArryCpy[3])
    	blackSprite:addChild(node)
    	node:setPosition(ccp(blackSprite:getContentSize().width*0.5,0))
    end
    local easyWineItem = CCMenuItemImage:create("images/lord_war/cheersdocument/wenjunhigh.png","images/lord_war/cheersdocument/wenjunnormal.png")
    local normalWineItem = CCMenuItemImage:create("images/lord_war/cheersdocument/dukanghigh.png","images/lord_war/cheersdocument/dukangnormal.png")
    local hardWineItem = CCMenuItemImage:create("images/lord_war/cheersdocument/qingshengnormal.png","images/lord_war/cheersdocument/qingshenghigh.png")
    cheerMenu:addChild(easyWineItem,2,1)
    cheerMenu:addChild(normalWineItem,2,2)
    cheerMenu:addChild(hardWineItem,2,3)
    easyWineItem:setAnchorPoint(ccp(0.5,0.5))
    normalWineItem:setAnchorPoint(ccp(0.5,0.5))
    hardWineItem:setAnchorPoint(ccp(0.5,0.5))
    easyWineItem:setPosition(ccp(_bottomBg:getContentSize().width*0.25,_bottomBg:getContentSize().height*0.6))
    normalWineItem:setPosition(ccp(_bottomBg:getContentSize().width*0.5,_bottomBg:getContentSize().height*0.6))
    hardWineItem:setPosition(ccp(_bottomBg:getContentSize().width*0.75,_bottomBg:getContentSize().height*0.6))

    easyWineItem:registerScriptTapHandler(itemCallBack)
    normalWineItem:registerScriptTapHandler(itemCallBack)
    hardWineItem:registerScriptTapHandler(itemCallBack)

    local rewardItem = CCMenuItemImage:create("images/lord_war/cheersdocument/reward0.png","images/lord_war/cheersdocument/reward2.png")
    rewardItem:setAnchorPoint(ccp(1,0))
    cheerMenu:addChild(rewardItem)
    rewardItem:setPosition(ccp(_bottomBg:getContentSize().width,secondSprite:getContentSize().height*0.7))
    rewardItem:registerScriptTapHandler(rewardCallBack)
end
