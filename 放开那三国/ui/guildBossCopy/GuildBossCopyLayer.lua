-- FileName: GuildBossCopyLayer.lua 
-- Author: bzx
-- Date: 15-03-31 
-- Purpose: 军团副本主界面

module("GuildBossCopyLayer", package.seeall)

require "script/ui/guildBossCopy/GuildBossCopyService"
require "db/DB_GroupCopy"
require "script/ui/guildBossCopy/BossCopyCitySprite"

local _layer
local _touchPriority = -420
local _timeNode = nil
local _mapData = nil
local _scrollView = nil
local _bgSprite = nil
local _timeLabel = nil
local _cost = 0

function show( ... )
	local guildLevel = GuildDataCache.getGuildHallLevel()
	local guildLevelLimit = GuildBossCopyData.getGuildLevelLimit()[1][2]
	if guildLevel < guildLevelLimit then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10115"), guildLevelLimit))
		return 
	end

	local getUserInfoCallFunc = function ( ... )
		GuildBossCopyService.rePushGuildcopyUpdateRefreshNum()
		GuildBossCopyService.rePushGuildcopyCurrCopyPass()
		_layer = create()
		MainScene.changeLayer(_layer, "GuildBossCopyLayer")
		if _timeNode == nil then
			_timeNode = CCNode:create()
			CCDirector:sharedDirector():getRunningScene():addChild(_timeNode)
			local curTime = TimeUtil.getSvrTimeByOffset()
			local refreshTime = TimeUtil.getIntervalByTime("240000")
			local remainTime = refreshTime - curTime
			local actions = CCArray:create()
	        actions:addObject(CCDelayTime:create(remainTime))
	        actions:addObject(CCCallFunc:create(refresh))
	        _timeNode:runAction(CCSequence:create(actions))
    	end
	end
	GuildBossCopyService.getUserInfo(getUserInfoCallFunc)
end

function freshBoss( ... )
	local getUserInfoCallFunc = function ( ... )
		GuildBossCopyService.rePushGuildcopyUpdateRefreshNum()
		GuildBossCopyService.rePushGuildcopyCurrCopyPass()
		_layer = create()
		MainScene.changeLayer(_layer, "GuildBossCopyLayer")
		if _timeNode == nil then
			_timeNode = CCNode:create()
			CCDirector:sharedDirector():getRunningScene():addChild(_timeNode)
			local curTime = TimeUtil.getSvrTimeByOffset()
			local refreshTime = TimeUtil.getIntervalByTime("240000")
			local remainTime = refreshTime - curTime
			local actions = CCArray:create()
	        actions:addObject(CCDelayTime:create(remainTime))
	        actions:addObject(CCCallFunc:create(refresh))
	        _timeNode:runAction(CCSequence:create(actions))
    	end
	end
	GuildBossCopyService.getUserInfo(getUserInfoCallFunc)
end

function init( ... )
	_layer = nil
	_scrollView = nil
	_bgSprite = nil
	_timeLabel = nil
	_cost = 0
end

function initData( ... )
	initMapData()
end

function create( ... )
	init()
	initData()
	_layer = CCLayer:create()
	loadTop()
	loadMap()
	loadCityAndPath()
	loadBottom()
	return _layer
end

function refresh( ... )
	require "script/ui/guildBossCopy/SetAttackTargetDialog"
	require "script/ui/guildBossCopy/CopyPointFormationLayer"
	require "script/ui/guildBossCopy/DamageRankListLayer"
	require "script/ui/guildBossCopy/GuildBossCopyFightResultLayer"
	require "script/ui/guildBossCopy/TreasureRoomPreviewLayer"
	require "script/ui/guildBossCopy/CopyPointLayer"
	SetAttackTargetDialog.close()
	CopyPointFormationLayer.close()
	CopyPointLayer.stopBgm()
	DamageRankListLayer.close()
	GuildBossCopyFightResultLayer.close()
	TreasureRoomPreviewLayer.close()
	AnimationTip.showTip(GetLocalizeStringBy("key_10116"))
	show()
end

function initMapData( ... )
	if _mapData ~= nil then
		return
	end
	_mapData = {}
	_mapData.citys = {}
	_mapData.paths = {}
	_mapData.boss  = {}
	local pageIndex = 1
	while true do
		local modulePath = "db/teamCXml/world" .. pageIndex
		local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(modulePath .. ".lua")
		if not CCFileUtils:sharedFileUtils():isFileExist(fullPath) then
			pageIndex = pageIndex - 1
			break
		end
		_G[modulePath] = nil
		package.loaded[modulePath] = nil
		require (modulePath)

		for i = 1, table.count(TeamCity.models.normal) do
			local uiInfo = TeamCity.models.normal[i]
			
			uiInfo.y = 960 * pageIndex - tonumber(uiInfo.y)
			local tag = tonumber(uiInfo.looks.look.armyID)
			if tag < 1000 and tag<100 then
				table.insert(_mapData.citys, uiInfo)
			elseif(tag > 1000)then
				local pathIndex = math.floor(tag / 1000)
				_mapData.paths[pathIndex] = _mapData.paths[pathIndex] or {}
				table.insert(_mapData.paths[pathIndex], uiInfo)
			else
				local pathIndex = math.floor(tag/ 100)
				table.insert(_mapData.boss, uiInfo)
			end
		end
		pageIndex = pageIndex + 1
	end
	_mapData.pageCount = pageIndex
end

local function bodyClick( tag,item )
	-- body
	local userInfo = GuildBossCopyData.getUserInfo()
	if(tonumber(userInfo.boss_info.cd) > TimeUtil.getSvrTimeByOffset())then
		AnimationTip.showTip(GetLocalizeStringBy("llp_347"))
	else
		require "script/ui/guildBossCopy/GuildBossBattleLayer"
		GuildBossBattleLayer.showRewardWindow(tag)
	end
end

local function showTimeDown( ... )
	-- body
	local userInfo = GuildBossCopyData.getUserInfo()
	local timeStr = tonumber(userInfo.boss_info.cd) - TimeUtil.getSvrTimeByOffset()
	local time_str = TimeUtil.getTimeString(timeStr)
	_timeLabel:setString(time_str)
	if(tonumber(userInfo.boss_info.cd) == TimeUtil.getSvrTimeByOffset())then
		_timeLabel:stopAllActions()
		freshBoss()
	end
end

function loadCityAndPath( ... )
	for i = 1, #_mapData.citys do
		local cityUiInfo = _mapData.citys[i]
		local groupCopyId = tonumber(cityUiInfo.looks.look.armyID)
		if DB_GroupCopy.getDataById(groupCopyId) and GuildBossCopyData.isOpenedGroupCopy(groupCopyId - 1) then

			local groupCopySprite = BossCopyCitySprite:createById(groupCopyId, _touchPriority, enterGroupCopyCallback)
			_scrollView:addChild(groupCopySprite, 2)
			groupCopySprite:setPosition(ccp(tonumber(cityUiInfo.x), tonumber(cityUiInfo.y)))
			groupCopySprite:setAnchorPoint(ccp(0.5, 0))
			if GuildBossCopyData.isTargetGroupCopy(groupCopyId) then
				
				local y = -cityUiInfo.y + _scrollView:getViewSize().height * 0.5
				if y < _scrollView:getViewSize().height - _scrollView:getContentSize().height then
					y = _scrollView:getViewSize().height - _scrollView:getContentSize().height
				elseif y > 0 then
					y = 0
				end
				_scrollView:setContentOffset(ccp(0, y))
				if cityUiInfo.y >= _scrollView:getViewSize().height * 0.5 then

				end
				if GuildBossCopyData.couldOpenBoxOrReceive() then
					local redTip = CCSprite:create("images/common/tip_2.png")
					groupCopySprite:addChild(redTip)
					redTip:setPosition(ccpsprite(0.6, 0.6, groupCopySprite))
				end
				
				local copyInfo = nil
				for k,v in pairs(_mapData.boss)do
					if(tonumber(v.looks.look.armyID)==100+groupCopyId)then
						copyInfo = v
						break
					end
				end
				local bodyMenu = CCMenu:create()
					  bodyMenu:setPosition(ccp(0,0))
				local Str = copyInfo.looks.look.modelURL
				local bossStr = string.sub(Str,0,string.len(Str)-4)
				local boosItem = nil
				local userInfo = GuildBossCopyData.getUserInfo()

				if(TimeUtil.getSvrTimeByOffset()<tonumber(userInfo.boss_info.cd))then
					local normalSprite = BTGraySprite:create("images/guild_boss_copy/boss_copy/" ..bossStr .. ".png")
					local selectSprite = BTGraySprite:create("images/guild_boss_copy/boss_copy/" ..bossStr .. ".png")
					local disableSprite = BTGraySprite:create("images/guild_boss_copy/boss_copy/" ..bossStr .. ".png")
					boosItem = CCMenuItemSprite:create(normalSprite,selectSprite,disableSprite)
				else
					boosItem = CCMenuItemImage:create("images/guild_boss_copy/boss_copy/" ..bossStr .. ".png", "images/guild_boss_copy/boss_copy/" ..bossStr .. ".png")
				end
				_scrollView:addChild(bodyMenu,10)
				bodyMenu:addChild(boosItem,2,tonumber(copyInfo.looks.look.armyID)-100)
				boosItem:setPosition(ccp(tonumber(copyInfo.x), tonumber(copyInfo.y)))
				boosItem:setAnchorPoint(ccp(1, 0))
				boosItem:registerScriptTapHandler(bodyClick)
				
				if(TimeUtil.getSvrTimeByOffset()<tonumber(userInfo.boss_info.cd))then
					local timeBg = CCScale9Sprite:create("images/common/bg/bg2.png")
						  timeBg:setContentSize(CCSizeMake(200,45))
						  timeBg:setAnchorPoint(ccp(0.5,1))
						  timeBg:setPosition(ccp(boosItem:getContentSize().width*0.5,0))
					boosItem:addChild(timeBg)
					local timeStr = tonumber(userInfo.boss_info.cd) - TimeUtil.getSvrTimeByOffset()
					local time_str = TimeUtil.getTimeString(timeStr)
					_timeLabel = CCLabelTTF:create(time_str,g_sFontName,28)
					_timeLabel:setAnchorPoint(ccp(0.5,0.5))
					_timeLabel:setPosition(ccp(timeBg:getContentSize().width*0.5,timeBg:getContentSize().height*0.5))
					timeBg:addChild(_timeLabel)

					-- if(TimeUtil.getSvrTimeByOffset()<tonumber(userInfo.boss_info.cd))then
						local actionArray = CCArray:create()
							  actionArray:addObject(CCDelayTime:create(1))
							  actionArray:addObject(CCCallFunc:create(showTimeDown))
						local repeatAction = CCRepeatForever:create(CCSequence:create(actionArray))
						_timeLabel:runAction(repeatAction)
					-- end
				else
					local nameBg = CCScale9Sprite:create("images/common/bg/9s_purple.png")
						  nameBg:setContentSize(CCSizeMake(200,45))
						  nameBg:setAnchorPoint(ccp(0.5,1))
						  nameBg:setPosition(ccp(boosItem:getContentSize().width*0.5,0))
					boosItem:addChild(nameBg)
					local battleData = DB_GroupCopy.getDataById(tonumber(copyInfo.looks.look.armyID)-100)
					local nameLabel = CCLabelTTF:create(battleData.bossName,g_sFontPangWa,23)
						  nameLabel:setAnchorPoint(ccp(0.5,0.5))
						  nameLabel:setPosition(ccp(nameBg:getContentSize().width * 0.5,nameBg:getContentSize().height * 0.5))
					nameBg:addChild(nameLabel)
				end
				
				if(TimeUtil.getSvrTimeByOffset()>=tonumber(userInfo.boss_info.cd) )then
					--血量背景
					local bloodBg = CCSprite:create("images/guild_boss_copy/red_bar.png")
					bloodBg:setAnchorPoint(ccp(0.5, 0.5))
					bloodBg:setPosition(ccpsprite(0.5 , 0.85, boosItem))
					boosItem:addChild(bloodBg)
					bloodBg:setScaleX(0.7)

					--血量
					local bloodSprite = CCSprite:create("images/guild_boss_copy/green_bar.png")
					bloodSprite:setPosition(ccpsprite(0 , 0.5, bloodBg))
					bloodSprite:setAnchorPoint(ccp(0, 0.5))
					bloodBg:addChild(bloodSprite, 1)
				    bloodSprite:setScaleX(tonumber(userInfo.boss_info.hp)/tonumber(userInfo.boss_info.max_hp))
				end
			end
		end
	end

	for i = 1, #_mapData.paths do
		local path = _mapData.paths[i]
		local groupCopyId = i
		if not GuildBossCopyData.isPassedGroupCopy(groupCopyId) then
			break
		end
		for j = 1, #path do
			local pointUiInfo = path[j]
			local point = CCSprite:create("images/guild_boss_copy/point.png")
			_scrollView:addChild(point)
			point:setAnchorPoint(ccp(0.5, 0))
			point:setPosition(ccp(tonumber(pointUiInfo.x), tonumber(pointUiInfo.y)))
		end
	end
end

function getPointMaxHeight( ... )
	local maxHeight = 0
	for i = 1, #_mapData.citys do
		local cityUiInfo = _mapData.citys[i]
		local groupCopyId = tonumber(cityUiInfo.looks.look.armyID)
		if DB_GroupCopy.getDataById(groupCopyId) and GuildBossCopyData.isOpenedGroupCopy(groupCopyId - 1) then
			if maxHeight < tonumber(cityUiInfo.y) then
				maxHeight = tonumber(cityUiInfo.y)
			end
		end
	end
	return maxHeight
end

function loadMap( ... )
	_scrollView = CCScrollView:create()
	_layer:addChild(_scrollView)
	_scrollView:setDirection(kCCScrollViewDirectionVertical)
    _scrollView:setViewSize(CCSizeMake(640, g_winSize.height / g_fScaleX))
    _scrollView:setBounceable(false)
    _scrollView:setTouchPriority(_touchPriority - 5)
    _scrollView:setScale(g_fScaleX)
	local contentSizeHeight = getPointMaxHeight()
	contentSizeHeight = contentSizeHeight + 300
	if contentSizeHeight < _scrollView:getViewSize().height then
		contentSizeHeight = _scrollView:getViewSize().height
	end
	_scrollView:setContentSize(CCSizeMake(640, contentSizeHeight))
	local height = 0
	while true do
		local cellBg = CCSprite:create("images/guild_boss_copy/boss_copy_bg.jpg")
		_scrollView:addChild(cellBg)
		cellBg:setPosition(ccp(0, height))
		height = height + cellBg:getContentSize().height
		if height >= contentSizeHeight then
			break
		end
	end
end

function afterBuy( ... )
	-- body
	freshBoss()
end

function sureBuyAction()
	-- body
	GuildBossCopyService.buyBossTime(afterBuy,_cost)
end

function buyTimeAction( ... )
	local userInfo = GuildBossCopyData.getUserInfo()
	local curBuyNum = userInfo.boss_info.buy_boss_num+1
	local costData = DB_GroupCopy_rule.getDataById(1)
	local costArray = string.split(costData.price,",")
	if(curBuyNum>#costArray)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_350"))
		return
	end
	local costNumArray = string.split(costArray[curBuyNum],"|")
	-- 金币不足
	if(UserModel.getGoldNumber() < tonumber(costNumArray[2]) ) then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end
	_cost = tonumber(costNumArray[2])
	local tipFont = {}
    tipFont[1] = CCLabelTTF:create(GetLocalizeStringBy("lic_1280") ,g_sFontName,25)
    tipFont[1]:setColor(ccc3(0x78,0x25,0x00))
    tipFont[2] = CCSprite:create("images/common/gold.png")
	tipFont[3] = CCLabelTTF:create(costNumArray[2],g_sFontName,25)
	tipFont[3]:setColor(ccc3(0x78,0x25,0x00))
    tipFont[4] = CCLabelTTF:create(GetLocalizeStringBy("llp_351"),g_sFontName,25)
    tipFont[4]:setColor(ccc3(0x78,0x25,0x00))
	require "script/utils/BaseUI"
    local tipFontNode = BaseUI.createHorizontalNode(tipFont)
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipFontNode,sureBuyAction)
end

function loadTop( ... )
	MainScene.setMainSceneViewsVisible(false, false, false)

	local topBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	_layer:addChild(topBg, 10)
	topBg:setContentSize(CCSizeMake(640, 100))
	topBg:setAnchorPoint(ccp(0.5, 1))
	topBg:setPosition(ccps(0.5, 1))
	topBg:setScale(g_fScaleX)

	-- 标题
	local title = CCSprite:create("images/guild_boss_copy/title.png")
	topBg:addChild(title)
	title:setAnchorPoint(ccp(0, 0.5))
	title:setPosition(ccpsprite(0.07, 0.5, topBg))

	local menu = CCMenu:create()
	topBg:addChild(menu)
	menu:setContentSize(topBg:getContentSize())
	menu:setTouchPriority(_touchPriority - 10)
	menu:setPosition(ccp(0, 0))

	-- 战功兑换
	local exploitsExchangeItem = CCMenuItemImage:create("images/guild_boss_copy/exploits_n.png", "images/guild_boss_copy/exploits_h.png")
	menu:addChild(exploitsExchangeItem)
	exploitsExchangeItem:setAnchorPoint(ccp(0.5, 0.5))
	exploitsExchangeItem:setPosition(ccpsprite(0.75, 0.5, topBg))
	exploitsExchangeItem:registerScriptTapHandler(exploitsExchangeCallback)

	-- 返回
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setAnchorPoint(ccp(0.5, 0.5))
	backItem:setPosition(ccpsprite(0.9, 0.5, topBg))
	backItem:registerScriptTapHandler(backCallback)

	local alertBg = CCScale9Sprite:create("images/common/bg/9s_guild.png")
		  alertBg:setContentSize(CCSizeMake(360, 60))
		  alertBg:setPosition(ccp(-30,0))
		  alertBg:setScale(g_fScaleX)
	_layer:addChild(alertBg,4)

	local userInfo = GuildBossCopyData.getUserInfo()
	local tipData = DB_GroupCopy_rule.getDataById(1)
    local attactNum = tonumber(tipData.num)+tonumber(userInfo.boss_info.buy_boss_num)-tonumber(userInfo.boss_info.atk_boss_num)
	local buyTimeLable = CCRenderLabel:create( GetLocalizeStringBy("llp_349",attactNum) , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		  buyTimeLable:setColor(ccc3(255,255,0))
		  buyTimeLable:setAnchorPoint(ccp(0,0))
		  buyTimeLable:setPosition(ccp(40,10))
		  
	alertBg:addChild(buyTimeLable,4)
	local timeMenu = CCMenu:create()
		  timeMenu:setPosition(ccp(0,0))
		  timeMenu:setTouchPriority(_touchPriority - 10)
	buyTimeLable:addChild(timeMenu)
	local timeItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png","images/common/btn/btn_plus_n.png")
		  timeItem:setAnchorPoint(ccp(0,0.5))
		  timeItem:setPosition(ccp(buyTimeLable:getContentSize().width,buyTimeLable:getContentSize().height*0.6))
		  timeItem:registerScriptTapHandler(buyTimeAction)
	timeMenu:addChild(timeItem)
end

function loadBottom( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	-- 攻打目标
	local attackItem = CCMenuItemImage:create("images/guild_boss_copy/gongdamubiao_n.png", "images/guild_boss_copy/gongdamubiao_h.png")
	menu:addChild(attackItem)
	attackItem:setAnchorPoint(ccp(1, 0))
	attackItem:setPosition(ccps(1, 0.02))
	attackItem:registerScriptTapHandler(setAttackCallback)
	attackItem:setScale(g_fScaleX)
end

function exploitsExchangeCallback( ... )
	require "script/ui/shopall/ExploitsExchangeLayer"
	ExploitsExchangeLayer.show(_touchPriority - 20)
	-- require "script/ui/guildBossCopy/ExploitsExchangeLayer"
	-- ExploitsExchangeLayer.show()

end

function backCallback( ... )
	MainScene.setMainSceneViewsVisible(false, false, true)
	_timeNode:removeFromParentAndCleanup(true)
	_timeNode = nil
	local guildMainLayer = GuildMainLayer.createLayer(false)
    MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

function enterGroupCopyCallback(p_groupCopyId)
	local lastGroupCopyId = p_groupCopyId - 1
	if lastGroupCopyId >= 1 and not GuildBossCopyData.isPassedGroupCopy(lastGroupCopyId) then
		local groupCopyDb = DB_GroupCopy.getDataById(p_groupCopyId - 1)
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10117"), groupCopyDb.des))
		return
	end
	if not GuildBossCopyData.isTargetGroupCopy(p_groupCopyId) then
		AnimationTip.showTip(GetLocalizeStringBy("key_10118"))
		return
	end
	require "script/ui/guildBossCopy/CopyPointLayer"
	CopyPointLayer.show(p_groupCopyId)
end

function setAttackCallback( ... )
	require "script/ui/guildBossCopy/SetAttackTargetDialog"
	SetAttackTargetDialog.show(_touchPriority - 20, 100)
end