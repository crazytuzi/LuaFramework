-- Filename: GuildWarWorshipDialog.lua
-- Author: lichenyang
-- Date: 2015-01-20
-- Purpose: 个人跨服赛数据层

module("GuildWarWorshipDialog", package.seeall)


require "script/utils/BaseUI"
require "db/DB_Kuafu_challengereward"
require "script/ui/lordWar/LordWarService"
require "script/ui/guildWar/worship/GuildWarWorshipController"

local _bgLayer                  = nil

local _thisCityId 				= nil
local _listData 				= nil
local _selfData 				= nil
local _secondSprite 			= nil
local _touchPriority 			= nil
local _zOrder					= nil

function init( ... )
	_bgLayer                    = nil
	_thisCityId 				= nil
	_listData 					= nil
	_selfData 					= nil
	_secondSprite 				= nil
	_touchPriority 				= nil
	_zOrder 					= nil
end

-- 初始化界面
function show( p_priority , p_zOrder)
	init()
	_zOrder = p_zOrder or 1000
	_touchPriority = p_priority or -600
	local layer = GuildWarWorshipDialog.create(_touchPriority,_zOrder)	
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder,1)
end

-- 节点事件
function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end
function getTouchPriority( ... )
	return _touchPriority
end
function getZOrder( ... )
	return _zOrder
end

function create( p_priority , p_zOrder )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)

	-- 创建背景
	local backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setContentSize(CCSizeMake(620, 693))
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(backGround)
    setAdaptNode(backGround)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(backGround:getContentSize().width/2, backGround:getContentSize().height-6.6 ))
	backGround:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_84"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority - 20)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)

	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(backGround:getContentSize().width * 0.955, backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 二级背景
	_secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondSprite:setContentSize(CCSizeMake(565,565))
	_secondSprite:setAnchorPoint(ccp(0.5,1))
	_secondSprite:setPosition(ccp(backGround:getContentSize().width/2,backGround:getContentSize().height - 60))
	backGround:addChild(_secondSprite)

	local secondBg = CCSprite:create("images/lord_war/cheersdocument/cheersBg.jpg")
 	secondBg:setAnchorPoint(ccp(0.5,0.5))
 	secondBg:setPosition(ccp(_secondSprite:getContentSize().width*0.5,_secondSprite:getContentSize().height*0.5))
 	secondBg:setScaleY(1.1)
 	_secondSprite:addChild(secondBg)

 	--标题特效
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/guanjunbiaoti/guanjunbiaoti"), -1,CCString:create(""))
    animSprite:setAnchorPoint(ccp(0.5, 0))
    animSprite:setPosition(ccpsprite(0.5,0.69,secondBg))
    secondBg:addChild(animSprite)

 	
 	local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_85"),g_sFontPangWa,23)
 	_secondSprite:addChild(desLabel)
 	desLabel:setAnchorPoint(ccp(0.5,1))
 	desLabel:setPosition(ccp(_secondSprite:getContentSize().width*0.5,0))
 	desLabel:setColor(ccc3(0x78,0x25,0x00))

 	createWorshipItem()
	--createHeroName()
	--createHeroBodyNode()
	createGuildName()
	return _bgLayer
end
function createGuildName( ... )

	local templeInfo = GuildWarWorshipData.getTempleInfo()  
    ---军团及服务器名字背景
    local guildNameBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    guildNameBg:setContentSize(CCSizeMake(315,130))
    guildNameBg:setAnchorPoint(ccp(0.5,1))
    _secondSprite:addChild(guildNameBg)
    guildNameBg:setPosition(ccpsprite(0.5,0.6,_secondSprite))

    --军旗
    require "script/ui/guild/GuildUtil"
    local guildFlag = GuildUtil.getGuildIcon(templeInfo.guild_badge)
    guildFlag:setAnchorPoint(ccp(0,0.5))
    guildNameBg:addChild(guildFlag)
    guildFlag:setPosition(ccpsprite(0.05,0.5,guildNameBg))

    --军团名
    local guildName = CCRenderLabel:create(templeInfo.guild_name,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    guildName:setColor(ccc3(0xff,0xf6,0x00))
    guildName:setAnchorPoint(ccp(0.5,0))
    guildNameBg:addChild(guildName)
    guildName:setPosition(ccpsprite(0.7,0.55,guildNameBg))

    --服务器名
    local serverName = CCRenderLabel:create(templeInfo.guild_server_name,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    serverName:setColor(ccc3(0xff,0xff,0xff))
    serverName:setAnchorPoint(ccp(0.5,1))
    guildNameBg:addChild(serverName)
    serverName:setPosition(ccpsprite(0.7,0.5,guildNameBg))
end

function createHeroBodyNode( ... )
	-- body
	local totalWinnerSprite = CCSprite:create("images/lord_war/cheersdocument/totalwinner.png")
 	_secondSprite:addChild(totalWinnerSprite,1)
 	totalWinnerSprite:setAnchorPoint(ccp(0.5,1))
 	totalWinnerSprite:setPosition(ccp(_secondSprite:getContentSize().width*0.5,_secondSprite:getContentSize().height))

 	local baseChairSprite = CCSprite:create("images/olympic/kingChair.png")
 	_secondSprite:addChild(baseChairSprite,1)
 	baseChairSprite:setAnchorPoint(ccp(0.5,0))
 	baseChairSprite:setPosition(ccp(_secondSprite:getContentSize().width*0.5,_secondSprite:getContentSize().height*0.4))

 	local redLightSprite = CCSprite:create("images/olympic/kingLight.png")
 	baseChairSprite:addChild(redLightSprite,1)
 	redLightSprite:setAnchorPoint(ccp(0.5,0))
 	redLightSprite:setPosition(ccp(baseChairSprite:getContentSize().width*0.5,baseChairSprite:getContentSize().height*0.5))

 	local dataCache = GuildWarWorshipData.getTempleInfo()
 	local sex = HeroModel.getSex(dataCache.president_htid)
 	local spriteStr = nil
 	if(table.isEmpty(dataCache.president_dress))then
 		spriteStr = HeroUtil.getHeroBodyImgByHTID(dataCache.president_htid)
 	else
 		spriteStr = HeroUtil.getHeroBodyImgByHTID(dataCache.president_htid,dataCache.president_dress["1"],sex)
 	end

 	local bodySprite = CCSprite:create(spriteStr)
 	bodySprite:setScale(0.5)
 	baseChairSprite:addChild(bodySprite,20)
 	bodySprite:setAnchorPoint(ccp(0.5,0))
 	bodySprite:setPosition(ccp(baseChairSprite:getContentSize().width*0.5,baseChairSprite:getContentSize().height*0.5))

 	-- 特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/jinpai/jinpai"), 1,CCString:create(""));
	spellEffectSprite:setScale(g_fBgScaleRatio/MainScene.elementScale*1.01)
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

function createHeroName( ... )
	-- body
	-- 英雄的名字
	local templeInfo = GuildWarWorshipData.getTempleInfo()
	local heroNameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	heroNameBg:setAnchorPoint(ccp(0.5,1))
	heroNameBg:setPosition(ccp(_secondSprite:getContentSize().width*0.5, _secondSprite:getContentSize().height*0.4))
	_secondSprite:addChild(heroNameBg,2)

	require "script/ui/login/ServerList"
	-- local zoneStr = ServerList.getServerNumByGroupId(templeInfo.president_serverid)
	local zoneLabel = CCLabelTTF:create("(".."game0001"..GetLocalizeStringBy("llp_86")..templeInfo.guild_server_name, g_sFontPangWa, 22)
	zoneLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	zoneLabel:setAnchorPoint(ccp(0.5,1))
	heroNameBg:addChild(zoneLabel)

	local nameLabel = CCLabelTTF:create(templeInfo.president_uname, g_sFontPangWa, 22)
	nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	nameLabel:setAnchorPoint(ccp(0.5,0))
	heroNameBg:addChild(nameLabel)

	heroNameBg:setContentSize(CCSizeMake(240, nameLabel:getContentSize().height+zoneLabel:getContentSize().height))
	zoneLabel:setPosition(ccp(heroNameBg:getContentSize().width*0.5, heroNameBg:getContentSize().height*0.5))
	nameLabel:setPosition(ccp(heroNameBg:getContentSize().width*0.5, heroNameBg:getContentSize().height*0.5))
end


function costNodeFunction( type,num )
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

function createWorshipItem( ... )
	-- body
	local _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bottomBg:setContentSize(CCSizeMake(561,160))
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_secondSprite:getContentSize().width*0.5, 5)
    _secondSprite:addChild(_bottomBg,11)

    local cheerMenu = CCMenu:create()
    cheerMenu:setTouchPriority(_touchPriority-30)
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

    easyWineItem:registerScriptTapHandler(GuildWarWorshipController.worshipCallback)
    normalWineItem:registerScriptTapHandler(GuildWarWorshipController.worshipCallback)
    hardWineItem:registerScriptTapHandler(GuildWarWorshipController.worshipCallback)

    local rewardItem = CCMenuItemImage:create("images/lord_war/cheersdocument/reward0.png","images/lord_war/cheersdocument/reward2.png")
    rewardItem:setAnchorPoint(ccp(1,0))
    cheerMenu:addChild(rewardItem)
    rewardItem:setPosition(ccp(_bottomBg:getContentSize().width,_secondSprite:getContentSize().height*0.7))
    rewardItem:registerScriptTapHandler(rewardCallBack)
end

function rewardCallBack( ... )
	-- body
	-- require "script/ui/lordWar/reward/WishRewardLayer"
	-- local rewardLayer = WishRewardLayer.showLayer( _touchPriority-10, _zOrder + 10 )
	require "script/ui/guildWar/reward/GuildWarWorshipRewardDialog"
	GuildWarWorshipRewardDialog.showLayer( _touchPriority-30, _zOrder + 10 )

end 

-- touch事件处理
function cardLayerTouch(eventType, x, y)
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


function dataCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		if(table.isEmpty(dictData.ret[1]))then
			return
		end
		require "script/ui/lordWar/LordWarData"

		LordWarData.setKingInfo(LordWarData._templeInfo)
		createHeroName()
		createHeroBodyNode()
	else
		return
	end
end

