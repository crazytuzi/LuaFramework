-- Filename：	GuildRobList.lua
-- Author：		bzx
-- Date：		2014-11-11
-- Purpose：		抢粮列表

module("GuildRobListLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/guild/guildRobList/GuildRobData"
require "script/ui/tip/SingleTip"
require "script/ui/guild/guildRobList/GuildRobSearchLayer"
require "script/ui/tip/RichAlertTip"
require "script/ui/guild/guildrob/GuildRobBattleService"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/RichAlertTip"
require "db/DB_Legion_granary"
require "script/ui/guild/liangcang/BarnData"
require "script/libs/LuaCCSprite"

local _layer
local _menu   						
local _timeLabel 				-- 抢夺时间
local _remainTimeLabel			-- 发起抢粮倒计时和抢粮结束倒计时
local _curPageItem				-- 当前页的按钮
local _page_scroll_view			-- 页码按钮
local _left_arrows   			-- 页码左边箭头
local _left_arrows_gray			-- 页码左边灰色箭头
local _right_arrows 			-- 页码右边箭头
local _right_arrows_gray		-- 页码右边灰色箭头
local _touchPriority = -500	 	-- 本层触摸优先级
local _timer_refresh_arrows		-- 刷新箭头的定时器
local _granaryItems				-- 当前页的粮仓按钮
local _guildRobList				-- 当前粮仓的数据
local _searchKey				-- 搜索军团粮仓时输入的军团名字
local _robInfoItem				-- 抢矿信息按钮
local _backItem					-- 返回按钮
local _robSceneItem				-- 进入战场按钮
local _searchItem 				-- 搜索粮仓按钮
local _endSearchItem			-- 退出搜索按钮
local _isClickPageItem			-- 是否点击了页码
local _pageMenuBg				-- 页码条背景
local _granaryMenu				-- 粮仓menu层
local _granaryTimeLabels		-- 粮仓保护时间
local _robCdLabel				-- 抢夺的CD
local _isRunning 				-- 当前层是否在舞台上
local _offlineTagSprite 		-- 离线抢粮的标记
local EFFECT_TAG = 12345		-- 特效TAG

function show( ... )
	local isOpen = GuildDataCache.getBarnIsOpen()
	require "script/ui/guild/liangcang/BarnData"
	local needLvTab = BarnData.getNeedGuildLvForBarn()
	if( isOpen == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1336",needLvTab[1],needLvTab[2],needLvTab[3],needLvTab[4],needLvTab[5]))
		return
	end

	local handleGetGuildRobInfo = function (  )
		if GuildRobData.getMyGuildRobInfo() ~= nil then
			_layer = create()
   			MainScene.changeLayer(_layer, "GuildRobList")
   		end
	end
	if GuildRobData.getMyGuildRobInfo() == nil then
		PreRequest.guildGetGuildRobInfo(handleGetGuildRobInfo)
	else
		handleGetGuildRobInfo()
	end
end

function init( ... )
	_curPageItem = nil
	_granaryItems = {}
	_searchKey = nil
	_timeLabel = nil
	_remainTimeLabel = nil
	_curPageIndex = 1
	_isClickPageItem = false
	_pageMenuBg = nil
	_robSceneItem = nil
	_robCdLabel = nil
	_granaryTimeLabels = {}
	_isRunning = false
	_offlineTagSprite = nil
end

function create( ... )
	init()
	MainScene.setMainSceneViewsVisible(false, false, false)
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	loadBg()
	loadTitle()
	loadBackMenu()
	loadFightBook()
	loadOfflineRob()
	local handleGetGuildRobAreaInfo = function ( ... )
		_guildRobList = GuildRobData.getRobList()
		loadFunctionMenu()
		refreshTimeTip()
		schedule(_layer, refreshTimeTip, 0.1)
		refreshGranariesAndPage()
		startTimerRefreshArrows()
		schedule(_layer, refreshGranaryTime, 0.05)
	end
	GuildRobData.getGuildRobAreaInfo(handleGetGuildRobAreaInfo, _curPageIndex, nil)
	return _layer
end

-- 战书
function loadFightBook( ... )
	require "script/ui/guild/liangcang/LiangCangMainLayer"
	local node = LiangCangMainLayer.createFightBookUi()
	_layer:addChild(node)
	node:setScale(MainScene.elementScale)
	node:setAnchorPoint(ccp(0, 0))
	node:setPosition(ccp(10 * MainScene.elementScale, 100 * MainScene.elementScale))
end

-- 设置离线抢粮
function loadOfflineRob( ... )
	local offlineBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	offlineBg:setContentSize(CCSizeMake(270, 38))
	offlineBg:setAnchorPoint(ccp(0, 0.5))
	offlineBg:setScale(MainScene.elementScale)
	offlineBg:setPosition(ccp(-20 * MainScene.elementScale, g_winSize.height - 165 * MainScene.elementScale))
	_layer:addChild(offlineBg)

	local offlineRobLabel = CCRenderLabel:create(GetLocalizeStringBy("keybu0_103"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	offlineBg:addChild(offlineRobLabel)
	offlineRobLabel:setAnchorPoint(ccp(0, 0.5))
	offlineRobLabel:setPosition(ccp(50, offlineBg:getContentSize().height * 0.5))

	local menu = CCMenu:create()
	offlineBg:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local selectOfflineRobItem = CCMenuItemImage:create("images/common/checkbg.png", "images/common/checkbg.png")
	menu:addChild(selectOfflineRobItem)
	selectOfflineRobItem:setAnchorPoint(ccp(0, 0.5))
    selectOfflineRobItem:registerScriptTapHandler(offlineRobCallback)
    selectOfflineRobItem:setPosition(ccp(offlineRobLabel:getContentSize().width + 55, offlineBg:getContentSize().height * 0.5))

    _offlineTagSprite = CCSprite:create("images/common/checked.png")
    selectOfflineRobItem:addChild(_offlineTagSprite)
    _offlineTagSprite:setAnchorPoint(ccp(0.5, 0.5))
    _offlineTagSprite:setPosition(ccpsprite(0.5, 0.5, selectOfflineRobItem))
    _offlineTagSprite:setVisible(false)

    GuildRobData.getInfo(refreshOfflineRob)
end

function refreshOfflineRob( ... )
	local offline = GuildRobData.getOffline()
	_offlineTagSprite:setVisible(offline ~= "0")
end

function offlineRobCallback( ... )
	local normalConfigDb = DB_Normal_config.getDataById(1)
	if UserModel.getHeroLevel() < normalConfigDb.robfood_offlineslv then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("keybu0_104"), normalConfigDb.robfood_offlineslv))
		return
	end
	local ret = 2
	local offline = GuildRobData.getOffline()
	if offline == "0" then
		ret = 1
	end
	GuildRobData.offline(function()
		refreshOfflineRob()
		if ret == 1 then
			if GuildRobData.isRobbing() then
				AnimationTip.showTip(GetLocalizeStringBy("keybu0_105"))
			else
				AnimationTip.showTip(GetLocalizeStringBy("keybu0_106"))
			end
		end
	end, ret)
end

-- 创建单个粮仓
function createGranaryItem(guildId, granaryItem)
	local granary = granaryItem or CCNode:create()
	local guildInfo = _guildRobList.guildInfo[guildId]
	print_t(guildInfo)
	local granaryLevel = math.ceil(guildInfo.barn_level / 5)
	if granaryLevel == 0 then
		granaryLevel = 1
	end
	local normal = CCSprite:create(string.format("images/guild_rob_list/granary_%d_n.png", granaryLevel))
	local selected = CCSprite:create(string.format("images/guild_rob_list/granary_%d_h.png", granaryLevel))
	granary:setContentSize(normal:getContentSize())

	local granaryItem = CCMenuItemSprite:create(normal, selected)
	granaryItem:setAnchorPoint(ccp(0.5, 0.5))
	granaryItem:setPosition(ccpsprite(0.5, 0.5, normal))

	local menu = CCMenu:create()
	granary:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setContentSize(granaryItem:getContentSize())

	menu:addChild(granaryItem)

	if guildInfo.robId == 0 then
		granaryItem:registerScriptTapHandler(robCallback)
	else
		local robing_n = CCNode:create()
		robing_n:setContentSize(normal:getContentSize())
		local robing_h = CCNode:create()
		robing_h:setContentSize(normal:getContentSize())

		normal:addChild(robing_n)
		robing_n:setAnchorPoint(ccp(0.5, 0.5))
		robing_n:setPosition(ccpsprite(0.5, 0.5, normal))
		selected:addChild(robing_h)
		robing_h:setAnchorPoint(ccp(0.5, 0.5))
		robing_h:setPosition(ccpsprite(0.5, 0.5, selected))
		granaryItem:registerScriptTapHandler(robingCallback)
		local effectCount = 0
		local children = granary:getChildren()
		for i = 0, children:count() - 1 do
	        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
	        if child:getTag() == EFFECT_TAG then
	        	effectCount = effectCount + 1
	        end
    	end
		if effectCount <= 1 then
			local effectInfos = {
				[1] = {
					{file = "liangcangfire", zOder = -1, position = ccp(0.9, 0.1)},
					{file = "liangcanghuo", zOder = 1, position = ccp(0, 0.1)},
					{file = "liangcangwuqi", zOder = 10, position = ccp(0.5, 0.5)},
					{file = guildInfo.robId == guildInfo.guildId and "zhengzaiqiangduo" or "zhengzaibeiqiang", zOder = 3, position = ccp(0.5, 0.2)}
				},
				[2] = {
					{file = "liangcangfire", zOder = 1, position = ccp(0.9, 0.1)},
					{file = "liangcanghuo", zOder = 1, position = ccp(0.1, 0.1)},
					{file = "liangcangwuqi", zOder = 10, position = ccp(0.5, 0.5)},
					{file = guildInfo.robId == guildInfo.guildId and "zhengzaiqiangduo" or "zhengzaibeiqiang", zOder = 3, position = ccp(0.5, 0.2)}
				},
				[3] = {
					{file = "liangcangfire", zOder = 1, position = ccp(0.9, 0.1)},
					{file = "liangcanghuo", zOder = 1, position = ccp(0.1, 0.1)},
					{file = "liangcangwuqi", zOder = 10, position = ccp(0.5, 0.5)},
					{file = guildInfo.robId == guildInfo.guildId and "zhengzaiqiangduo" or "zhengzaibeiqiang", zOder = 3, position = ccp(0.5, 0.2)}
				},
				[4] = {
					{file = "liangcangfire", zOder = 1, position = ccp(0.9, 0.1)},
					{file = "liangcanghuo", zOder = 1, position = ccp(0.1, 0.1)},
					{file = "liangcangwuqi", zOder = 10, position = ccp(0.5, 0.5)},
					{file = guildInfo.robId == guildInfo.guildId and "zhengzaiqiangduo" or "zhengzaibeiqiang", zOder = 3, position = ccp(0.5, 0.2)}
				}
			}
			for i = 1, #effectInfos do
				local effectInfo = effectInfos[granaryLevel][i]
				local effect = CCLayerSprite:layerSpriteWithName(CCString:create(string.format("images/guild_rob_list/effect/%s/%s", effectInfo.file, effectInfo.file)), -1, CCString:create(""))
				granary:addChild(effect, effectInfo.zOder)
				effect:setPosition(ccpsprite(effectInfo.position.x, effectInfo.position.y, granary))
				effect:setTag(EFFECT_TAG)
			end
		end
	end
	if guildId == GuildRobData.getMyGuildRobInfo().guildId and granaryItem == nil then
		addEffect(granary)
	end
	granaryItem:setTag(guildId)
	local guildNameColors = {ccc3(0xff, 0xff, 0xff), ccc3(0, 0xeb, 0x21), ccc3(0x51, 0xfb, 0xff), ccc3(255, 0, 0xe1)}
	local guildName = CCRenderLabel:create("[" .. guildInfo.name .. "]", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	granary:addChild(guildName)
	guildName:setColor(guildNameColors[granaryLevel])
	guildName:setAnchorPoint(ccp(0.5, 0.5))
	guildName:setPosition(ccpsprite(0.5, 1, granary))

	local remain = CCRenderLabel:create(GetLocalizeStringBy("key_8356"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	granary:addChild(remain)
	remain:setAnchorPoint(ccp(0.5, 0.5))
	remain:setPosition(ccp(granary:getContentSize().width * 0.3, -10))

	local remainCount = CCRenderLabel:create(tostring(guildInfo.grain), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	granary:addChild(remainCount)
	remainCount:setAnchorPoint(ccp(0, 0.5))
	remainCount:setPosition(ccp(granary:getContentSize().width * 0.3 + remain:getContentSize().width * 0.5, -10))
	remainCount:setColor(ccc3(0x00, 0xff, 0x18))


	local curTime = TimeUtil.getSvrTimeByOffset()
	local remainTime = guildInfo.shelterTime - curTime
	if remainTime > 0 then
		local remainTimeStr = TimeUtil.getTimeString(remainTime)
		local remainTime = CCRenderLabel:create(GetLocalizeStringBy("key_8357", remainTimeStr), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		granary:addChild(remainTime)
		remainTime:setAnchorPoint(ccp(0.5, 0.5))
		remainTime:setPosition(ccp(granary:getContentSize().width * 0.5 , -30))
		remainTime:setColor(ccc3(0x00, 0xe4, 0xff))
		_granaryTimeLabels[guildInfo.guildId] = remainTime
	end
	if guildId == GuildRobData.getMyGuildRobInfo().guildId then
		addEffect(granary)
	end

	return granary
end

-- 刷新单个粮仓
function refreshGranaryByGuildId(guildId, index)
	if _layer == nil then
		return
	end
	local granaryPositions = {
		ccp(g_winSize.width * 0.2, g_winSize.height * 0.65),
		ccp(g_winSize.width * 0.8, g_winSize.height * 0.75),
		ccp(g_winSize.width * 0.5, g_winSize.height * 0.5), 
		ccp(g_winSize.width * 0.2, g_winSize.height * 0.3),
		ccp(g_winSize.width * 0.8, g_winSize.height * 0.35)
	}
	local granaryIndex = index
	if granaryIndex == nil then
		granaryIndex = GuildRobData.getGranaryIndexByGuildId(guildId)
	end
	local guildInfo = _guildRobList.guildInfo[guildId]
	if _granaryItems[granaryIndex] ~= nil and guildInfo.robId ~= 0 then
		LuaCCSprite.reserveChildrenByTag(_granaryItems[granaryIndex], EFFECT_TAG)
	end
	if tolua.cast(_granaryTimeLabels[guildId], "CCNode") ~= nil then
		_granaryTimeLabels[guildId]:removeFromParentAndCleanup(true)
		_granaryTimeLabels[guildId] = nil
	end
	if guildInfo.robId == 0 and tolua.cast(_granaryItems[granaryIndex], "CCNode") ~= nil then
		_granaryItems[granaryIndex]:removeFromParentAndCleanup(true)
		_granaryItems[granaryIndex] = nil
	end
	local granary = createGranaryItem(guildId, _granaryItems[granaryIndex])
	granary:setScale(MainScene.elementScale)
	if _granaryItems[granaryIndex] == nil then
		_layer:addChild(granary)
	end
	granary:setAnchorPoint(ccp(0.5, 0.5))
	granary:setPosition(granaryPositions[granaryIndex])
	_granaryItems[granaryIndex] = granary

end

-- 刷新所有粮仓
function refreshGranaries( ... )
	_granaryTimeLabels = {}
	for i=1, #_granaryItems do
		_granaryItems[i]:removeFromParentAndCleanup(true)
		_granaryItems[i] = nil
	end
	for k, v in pairs(_guildRobList.guildInfo) do
		refreshGranaryByGuildId(k, GuildRobData.getGranaryIndexByGuildId(k))
	end
end

-- 加载背景
function loadBg( ... )
	local bg = CCSprite:create("images/guild_rob_list/map.jpg")
	_layer:addChild(bg)
	bg:setScale(g_fBgScaleRatio)
end

-- 加载反回按钮
function loadBackMenu( ... )
	_menu = CCMenu:create()
	_layer:addChild(_menu)
	_menu:setPosition(ccp(0, 0))

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	_menu:addChild(backItem)
	backItem:setScale(MainScene.elementScale)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setPosition(ccp(g_winSize.width - 100 * MainScene.elementScale, g_winSize.height - 90 * MainScene.elementScale))
    _backItem = backItem
end

-- 加载功能按钮
function loadFunctionMenu( ... )
	-- 抢夺信息
	local robInfoItem = CCMenuItemImage:create("images/guild_rob_list/rob_info_n.png", "images/guild_rob_list/rob_info_h.png")
	_menu:addChild(robInfoItem)
	robInfoItem:setScale(MainScene.elementScale)
    robInfoItem:registerScriptTapHandler(robInfoCallback)
    robInfoItem:setPosition(ccp(g_winSize.width - 330 * MainScene.elementScale, g_winSize.height - 98 * MainScene.elementScale))
    _robInfoItem = robInfoItem
    
    -- 搜索
    local searchItem = CCMenuItemImage:create("images/guild_rob_list/search_n.png", "images/guild_rob_list/search_h.png")
    _menu:addChild(searchItem)
    searchItem:setScale(MainScene.elementScale)
    searchItem:registerScriptTapHandler(searchCallback)
    searchItem:setPosition(ccp(g_winSize.width - 120 * MainScene.elementScale, 90 * g_fScaleX))
    _searchItem = searchItem

    -- 退出搜索
    _endSearchItem = CCMenuItemImage:create("images/guild_rob_list/end_search_n.png", "images/guild_rob_list/end_search_h.png")
    _menu:addChild(_endSearchItem)
    _endSearchItem:setScale(MainScene.elementScale)
    _endSearchItem:registerScriptTapHandler(endSearchCallback)
    _endSearchItem:setPosition(ccp(g_winSize.width - 120 * MainScene.elementScale, g_winSize.height - 90 * g_fScaleX))
    _endSearchItem:setVisible(false)

    -- 刷新进入战场按钮
    refreshRobSceneItem()
end

-- 刷新进入战场按钮
function refreshRobSceneItem( ... )
	if _layer == nil then
		return
	end
	if _robSceneItem ~= nil then
		_robSceneItem:removeFromParentAndCleanup(true)
	end
	local robSceneItem = CCMenuItemImage:create("images/guild_rob_list/rob_scene_n.png", "images/guild_rob_list/rob_scene_h.png")
	_menu:addChild(robSceneItem)
	robSceneItem:setScale(MainScene.elementScale)
    robSceneItem:registerScriptTapHandler(robSceneCallback)
    robSceneItem:setPosition(ccp(g_winSize.width - 220 * MainScene.elementScale, g_winSize.height - 100 * MainScene.elementScale))
    _robSceneItem = robSceneItem

    local myGuildRobInfo = GuildRobData.getMyGuildRobInfo()
    if myGuildRobInfo.robId ~= 0 and myGuildRobInfo.robId ~= nil then
    	local robingTagSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob_list/effect/qdzcButton/qdzcButton"), -1, CCString:create(""))
    	--local robingTagSprite = CCSprite:create("images/guild_rob_list/robing.png")
    	_robSceneItem:addChild(robingTagSprite)
    	robingTagSprite:setAnchorPoint(ccp(0.5, 0))
    	robingTagSprite:setPosition(ccpsprite(0.5, 0.5, _robSceneItem))
    end
end

-- 退出搜索
function endSearchCallback( ... )
	GuildRobData.getGuildRobAreaInfo(refreshGranariesAndPage, GuildRobData.getCurPageIndex(), nil)
	_robInfoItem:setVisible(true)
	_robSceneItem:setVisible(true)
	_backItem:setVisible(true)
	_endSearchItem:setVisible(false)
end

-- 刷新所有粮仓和页码
function refreshGranariesAndPage( ... )
	if _layer == nil then
		return
	end
	_isClickPageItem = false
	refreshGranaries()
	refreshPageMenu()
end

-- 刷新每个粮仓的保护时间
function refreshGranaryTime( ... )
	local curTime = TimeUtil.getSvrTimeByOffset()
	local endGuildIds = {}
	for guildId, granaryTimeLabel in pairs(_granaryTimeLabels) do
		local remainTime = _guildRobList.guildInfo[guildId].shelterTime - curTime
		if remainTime <= 0 then
			_guildRobList.guildInfo[guildId].shelterTime = 0
			if tolua.cast(granaryTimeLabel, "CCNode") ~= nil then
				granaryTimeLabel:removeFromParentAndCleanup(true)
			end
			table.insert(endGuildIds, guildId)
		else
			local timeStr = TimeUtil.getTimeString(remainTime)
			granaryTimeLabel:setString(GetLocalizeStringBy("key_8357", timeStr))
		end
	end

	for i=1, #endGuildIds do
		_granaryTimeLabels[endGuildIds[i]] = nil
	end
end

-- 抢夺信息
function robInfoCallback(tag, menuItem)
	require "script/ui/guild/guildRobList/GuildRobEnemyListLayer"
    GuildRobEnemyListLayer.showGuildRobEnemyListLayer()
end


 -- * 'defend_low_grain'				被抢夺军团粮草太少,无法抢夺
 -- * 'attack_too_much'    			抢夺的次数太多啦
 -- * 'lack fight book'				缺少战书
 -- * 'attacker_defending'				抢夺军团正在被另一个军团抢夺
 -- * 'attacker_attacking'				抢夺军团正在抢夺另一个军团
 -- * 'defender_defending'				防守军团正在被另一个军团抢夺
 -- * 'defender_attacking'				防守军团正在抢夺另一个军团
 -- 抢夺粮仓
function rob(granaryInfo)
	local myGuildRobInfo = GuildRobData.getMyGuildRobInfo()

	-- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
  	if( GuildDataCache.getMineMemberType() ~= 1 and GuildDataCache.getMineMemberType() ~= 2 )then  	
		AnimationTip.showTip(GetLocalizeStringBy("key_8359"))
		return
    end
    
    if _guildRobList.inRob == "0" then
		SingleTip.showTip(GetLocalizeStringBy("key_8358"))
		return
	end

	local timeInfo = GuildRobData.getTimeInfo()
	if timeInfo.endRemainTime <= 15 * 60 then
		AnimationTip.showTip(GetLocalizeStringBy("key_8424"))
		return
	end


    if myGuildRobInfo.robId ~= 0 and myGuildRobInfo.robId ~= nil then
		SingleTip.showTip(GetLocalizeStringBy("key_8360"))
		return
	end

    if myGuildRobInfo.guildId == tonumber(granaryInfo.guildId) then
    	AnimationTip.showTip(GetLocalizeStringBy("key_8361"))
    	return
    end

	local curTime = TimeUtil.getSvrTimeByOffset()
	if tonumber(granaryInfo.shelterTime) > curTime then
		AnimationTip.showTip(GetLocalizeStringBy("key_8362"))
		return
	end

	if GuildDataCache.getGuildFightBookNum() < 1 then
		showLackFightBookAlert()
		return
	end

	local robCdRemainTime = GuildRobData.getMyGuildRobInfo().cdTime - curTime
	if robCdRemainTime > 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_8363"))
		return
	end

	local robFoodDB = DB_Rob_food.getDataById(1)
	local confirmCBFunc = function(p_confirmed, arg)
		if p_confirmed == true then
			local guildRobCreateCallback = function (ret)
				local tipTexts = {
					["defend_low_grain"]	= GetLocalizeStringBy("key_8364"),
	 				["attack_too_much"]		= GetLocalizeStringBy("key_8365", robFoodDB.attackedlimit),
	 				["defend_too_much"]		= GetLocalizeStringBy("key_8366"),
	 				["lack_fight_book"]		= GetLocalizeStringBy("key_8367"),
	 				["attacker_defending"]	= GetLocalizeStringBy("key_8368"),
	 				["attacker_attacking"]	= GetLocalizeStringBy("key_8369"),
	 				["defender_defending"]	= GetLocalizeStringBy("key_8370"),
	 				["defender_attacking"]	= GetLocalizeStringBy("key_8371"),
	 				["defend_in_shelter"]	= GetLocalizeStringBy("key_8372"),
	 				["attack_barn_not_open"]= GetLocalizeStringBy("key_8373"),
	 				["defend_barn_not_open"]= GetLocalizeStringBy("key_8374"),
	 			}
				if tipTexts[ret] == nil then
					refreshRobSceneItem()
					local richInfo = {}
					richInfo.elements = {}
					local element = {}
					element.text = GetLocalizeStringBy("key_8375")
					table.insert(richInfo.elements, element)
					element = {}
					element.newLine = true
					element.type = "CCRenderLabel"
					element.text = GetLocalizeStringBy("key_8376")
					element.color = ccc3(0x00, 0xff, 0x18)
					table.insert(richInfo.elements, element)
					local goCallBack = function ( p_confirmed, arg )
						if p_confirmed == true then
							robSceneCallback()
							require "script/ui/guild/guildRobList/GuildRobEnemyListLayer"
							GuildRobEnemyListLayer.closeButtonCallback()
						end
					end
					RichAlertTip.showAlert(richInfo, goCallBack, false, args, GetLocalizeStringBy("key_8377"), nil, nil, true)
				else
					AnimationTip.showTip(tipTexts[ret])
				end
			end
			GuildRobData.guildRobCreate(granaryInfo.guildId, guildRobCreateCallback)
		end
	end
	showRobAlert(granaryInfo, confirmCBFunc)
end


-- 为自己的军团加特效
function addEffect(item_image)
    local spellEffectSprite = CCLayerSprite:layerSpriteWithName(
             CCString:create("images/base/effect/copy/fubenkegongji01"), -1,CCString:create(""));
    spellEffectSprite:retain()
    spellEffectSprite:setPosition(item_image:getContentSize().width * 0.5, 40)
    item_image:addChild(spellEffectSprite, -1, EFFECT_TAG);
    spellEffectSprite:release()
end

-- 抢夺粮仓
function robCallback(tag)
	local guildId = tag
	rob(_guildRobList.guildInfo[guildId])
end

-- 显示战书不足的对话框
function showLackFightBookAlert()
	local richInfo = {}
	richInfo.elements = {}
	richInfo.alignment = 2
	local element = {}
	element.type = "CCSprite"
	element.image = "images/common/gong.png"
	table.insert(richInfo.elements, element)
	element = {}
	local fightBookCost = BarnData.getZhanShuCost()
	element.text = string.format("%d", fightBookCost)
	table.insert(richInfo.elements, element)

	local confirmCBFunc = function(p_confirmed, arg)
		if p_confirmed == true then
			-- 建设度不足
			if(GuildDataCache.getGuildDonate() < fightBookCost ) then  
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("lic_1381"))
				return
			else
				local handleBuyFightBook = function ( ... )
					AnimationTip.showTip(GetLocalizeStringBy("key_8379"))
					LiangCangMainLayer.refreshFightBookNum()
				end
				BarnService.buyFightBook(handleBuyFightBook)
			end
		end
	end
	local newRichInfo = GetNewRichInfo("key_8378", richInfo)

	RichAlertTip.showAlert(newRichInfo, confirmCBFunc, true, args, GetLocalizeStringBy("key_8380"), GetLocalizeStringBy("key_8381"), nil, true)
end

-- 显示抢夺的对话框
function showRobAlert(granaryInfo, confirmCBFunc, args)
	local richInfo = {}
	richInfo.elements = {}
	local element = {}
	element.text = granaryInfo.name
	element.color = ccc3(0x00, 0xe4, 0xff)
	element.type = "CCRenderLabel"
	table.insert(richInfo.elements, element)
	element = {}
	element.newLine = true
	element.text = GetLocalizeStringBy("key_8353")
	table.insert(richInfo.elements, element)
	element = {}
	element.text = GetLocalizeStringBy("key_8354")
	element.color = ccc3(0xff, 0x00, 0xe1)
	table.insert(richInfo.elements, element)
	element = {}
	element.type = "CCSprite"
	element.image = "images/common/zhanshu.png"
	table.insert(richInfo.elements, element)
	element = {}
	element.newLine = true
	element.text = GetLocalizeStringBy("key_8355")
	table.insert(richInfo.elements, element)
	element = {}
	element.newLine = true
	element.type = "CCRenderLabel"
	element.text = GetLocalizeStringBy("key_8425")
	element.color = ccc3(0x00, 0xe4, 0xff)
	table.insert(richInfo.elements, element)
	local newRichInfo = GetNewRichInfo("key_8352", richInfo)
	RichAlertTip.showAlert(newRichInfo, confirmCBFunc, true, args, GetLocalizeStringBy("key_8380"), GetLocalizeStringBy("key_8381"), nil, true, 430)
end

-- 正在抢粮中
function robingCallback( ... )
	SingleTip.showTip(GetLocalizeStringBy("key_8382"))
end

-- 搜索军团粮仓
function searchCallback( ... )
	GuildRobSearchLayer.show()
end

-- 显示搜索结果
function enterSearchResultLayer( ... )
	refreshGranariesAndPage()
	_robInfoItem:setVisible(false)
	_robSceneItem:setVisible(false)
	_backItem:setVisible(false)
	_endSearchItem:setVisible(true)
end

-- 加载标题
function loadTitle( ... )
	local title = CCSprite:create("images/guild_rob_list/title.png")
	_layer:addChild(title)
	title:setAnchorPoint(ccp(0, 1))
	title:setPosition(ccp(0, g_winSize.height - 5))
	title:setScale(MainScene.elementScale)
end

-- 刷新时间提示
function refreshTimeTip( ... )
	if _layer == nil then
		return
	end
	local timeInfo = GuildRobData.getTimeInfo()
	local weekTexts = {"key_8383", "key_8384", "key_8385", "key_8386", "key_8387", "key_8388", "key_8389"}
	local nextWeekTexts = {"key_8390", "key_8391", "key_8392", "key_8393", "key_8394", "key_8395", "key_8396"}
	local beginTimeStr = TimeUtil.getTimeFormatAtDay(timeInfo.beginTime)
	local endTimeStr = TimeUtil.getTimeFormatAtDay(timeInfo.endTime)
	local weekText = nil
	if timeInfo.isNextWeek == true then
		weekText = GetLocalizeStringBy(nextWeekTexts[timeInfo.week + 1])
	else
		weekText = GetLocalizeStringBy(weekTexts[timeInfo.week + 1])
	end
	local timeText = GetLocalizeStringBy("key_8397", weekText, beginTimeStr, endTimeStr)
	if _timeLabel == nil then
		_timeLabel = CCRenderLabel:create(timeText, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		local node = CCNode:create()
		node:addChild(_timeLabel)
		_timeLabel:setAnchorPoint(ccp(0, 0))
		_timeLabel:setPosition(ccp(0, 0))
		node:setContentSize(_timeLabel:getContentSize())
		_timeLabel:setColor(ccc3(0x00, 0xff, 0x18))
		_layer:addChild(node)
		node:setAnchorPoint(ccp(0, 0.5))
		node:setPosition(ccp(0, g_winSize.height - 75 * MainScene.elementScale))
		node:setScale(MainScene.elementScale)
	else
		_timeLabel:setString(timeText)
	end
	if timeInfo.remainTime < 0 then
		timeInfo.remainTime = 0
	end

	local remainText = nil
	if timeInfo.remainTime == 0 then
		GuildRobData.robBegin()
		remainText = GetLocalizeStringBy("key_8398", TimeUtil.getTimeString(timeInfo.endRemainTime))
	else
		GuildRobData.robEnd()
		remainText = GetLocalizeStringBy("key_8399", TimeUtil.getTimeString(timeInfo.remainTime))
	end
	
	if _remainTimeLabel == nil then
		_remainTimeLabel = CCRenderLabel:create(remainText, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		local node = CCNode:create()
		node:addChild(_remainTimeLabel)
		_remainTimeLabel:setAnchorPoint(ccp(0, 0))
		_remainTimeLabel:setPosition(ccp(0, 0))
		_remainTimeLabel:setColor(ccc3(0x00, 0xe4, 0xff))
		node:setContentSize(_remainTimeLabel:getContentSize())

		_layer:addChild(node)
		node:setAnchorPoint(ccp(0, 0.5))
		node:setPosition(ccp(0, g_winSize.height - 105 * MainScene.elementScale))
		node:setScale(MainScene.elementScale)
	else
		_remainTimeLabel:setString(remainText)
	end

	local robCdRemainTime = GuildRobData.getMyGuildRobInfo().cdTime - timeInfo.curTime
	if robCdRemainTime <= 0 then
		if _robCdLabel ~= nil then
			_robCdLabel:removeFromParentAndCleanup(true)
			_robCdLabel = nil
		end
	else
		local robCdRemainTimeText = GetLocalizeStringBy("key_8400", TimeUtil.getTimeString(robCdRemainTime))
		if _robCdLabel == nil then
			_robCdLabel = CCRenderLabel:create(robCdRemainTimeText, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			local node = CCNode:create()
			node:addChild(_robCdLabel)
			_robCdLabel:setAnchorPoint(ccp(0, 0))
			_robCdLabel:setPosition(ccp(0, 0))
			_robCdLabel:setColor(ccc3(0x00, 0xe4, 0xff))
			_layer:addChild(node)
			node:setAnchorPoint(ccp(0, 0.5))
			node:setContentSize(_robCdLabel:getContentSize())
			node:setPosition(ccp(0, g_winSize.height - 135 * MainScene.elementScale))
			node:setScale(MainScene.elementScale)
		else
			_robCdLabel:setString(robCdRemainTimeText)
		end
	end
end

-- 进入战场
function robSceneCallback( ... )
	local myGuildRobInfo = GuildRobData.getMyGuildRobInfo()
	if myGuildRobInfo.robId ~= nil and myGuildRobInfo.robId ~= 0 then
		require "script/ui/guild/guildrob/GuildRobBattleLayer"
		GuildRobBattleLayer.show()
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_8401"))
	end
end

-- 返回
function backCallback( ... )
	local handleLeavelGuildRobArea = function ( ... )
		require "script/ui/guild/GuildImpl"
		GuildImpl.showLayer()	
	end
	GuildRobData.leavelGuildRobArea(handleLeavelGuildRobArea)
end

-- 刷新页码
function refreshPageMenu()
	if _layer == nil then
		return
	end
	if _pageMenuBg ~= nil then
		_pageMenuBg:removeFromParentAndCleanup(true)
	end
	local pageMenuBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	_layer:addChild(pageMenuBg)
	pageMenuBg:setContentSize(CCSizeMake(640, 73))
	pageMenuBg:setAnchorPoint(ccp(0.5, 0))
	pageMenuBg:setPosition(ccp(_layer:getContentSize().width * 0.5, 4))
	pageMenuBg:setScale(g_fScaleX)
	_pageMenuBg = pageMenuBg

    local pageMenuLayer = CCLayer:create()
    local curIndex = 1
    local indexMax = _guildRobList.areaNum
    pageMenuLayer:setContentSize(CCSizeMake(90 * indexMax, pageMenuBg:getContentSize().height))

    local menuItems = {}
    for i = 1, indexMax do
        local pageItem = CCMenuItemImage:create("images/guild_rob_list/page_n.png", "images/guild_rob_list/page_h.png", "images/guild_rob_list/page_h.png")
        pageItem:setAnchorPoint(ccp(1, 0.5))
        pageItem:setPosition(ccp(90 * i - 10, pageMenuBg:getContentSize().height * 0.5))
        pageItem:registerScriptTapHandler(pageCallback)
        pageItem:setTag(i)

        local pageLabel = CCLabelTTF:create(tostring(i), g_sFontPangWa, 28)
        pageLabel:setAnchorPoint(ccp(0.5, 0.5))
        pageLabel:setPosition(ccp(pageItem:getContentSize().width * 0.5, pageItem:getContentSize().height * 0.5))
        pageItem:addChild(pageLabel)

        if i == curIndex then
            pageItem:selected()
            _curPageItem = pageItem
        end
        table.insert(menuItems, pageItem)
    end
    
	local radio_data = {
	    touch_priority 	= _touchPriority,   -- 触摸优先级
	    space			= 18,               -- 按钮间距
	    callback        = pageCallback,    	-- 按钮回调
	    direction 		= 1, 		  		-- 方向 1为水平，2为竖直
	    defaultIndex 	= 1,        		-- 默认选择的index
	    items = menuItems
	}

 	local menu = LuaCCSprite.createRadioMenuWithItems(radio_data)
 	pageMenuLayer:addChild(menu)
 	menu:setAnchorPoint(ccp(0, 0.5))
   	menu:setPosition(ccpsprite(0, 0.5, pageMenuLayer))
    menu:setTouchPriority(_touchPriority)

    _page_scroll_view = CCScrollView:create()
    pageMenuBg:addChild(_page_scroll_view)
    _page_scroll_view:setDirection(kCCScrollViewDirectionHorizontal)
    _page_scroll_view:setViewSize(CCSizeMake(540, pageMenuBg:getContentSize().height))
    _page_scroll_view:setContentSize(CCSizeMake(pageMenuLayer:getContentSize().width, pageMenuBg:getContentSize().height))
    _page_scroll_view:setTouchPriority(menu:getTouchPriority() - 10)
    _page_scroll_view:setPosition(ccp((pageMenuBg:getContentSize().width - _page_scroll_view:getViewSize().width) * 0.5, 0))
    _page_scroll_view:setContainer(pageMenuLayer)
    --_page_scroll_view:setContentOffset(_page_menu_offset)

    _left_arrows = CCSprite:create("images/active/mineral/btn_left.png")
    _left_arrows:setAnchorPoint(ccp(0.5, 0.5))
    _left_arrows_gray = BTGraySprite:create("images/active/mineral/btn_left.png")
    _left_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    
    local leftArrowsPosition = ccp(28, pageMenuBg:getContentSize().height * 0.5)
    _left_arrows:setPosition(leftArrowsPosition)
    _left_arrows_gray:setPosition(leftArrowsPosition)
    pageMenuBg:addChild(_left_arrows)
    pageMenuBg:addChild(_left_arrows_gray)
    _right_arrows = CCSprite:create("images/active/mineral/btn_right.png")
    _right_arrows:setAnchorPoint(_left_arrows:getAnchorPoint())
    _right_arrows_gray = BTGraySprite:create("images/active/mineral/btn_right.png")
    _right_arrows_gray:setAnchorPoint(_left_arrows:getAnchorPoint())
    local rightArrowsPosition = ccp(610, pageMenuBg:getContentSize().height * 0.5)
    _right_arrows:setPosition(rightArrowsPosition)
    _right_arrows_gray:setPosition(rightArrowsPosition)
    pageMenuBg:addChild(_right_arrows_gray)
    pageMenuBg:addChild(_right_arrows)
end

-- 开始刷新箭头
function startTimerRefreshArrows()
    timerRefreshArrows()
    _timer_refresh_arrows = schedule(_layer, timerRefreshArrows, 0.1)
end

-- 刷新箭头
function timerRefreshArrows(time)
    local offset = _page_scroll_view:getContentOffset()
    if offset.x >= 0 then
        _left_arrows:setVisible(false)
        _left_arrows_gray:setVisible(true)
    else
        _left_arrows_gray:setVisible(false)
        _left_arrows:setVisible(true)
    end
    if offset.x <= -_page_scroll_view:getContentSize().width + _page_scroll_view:getViewSize().width then
        _right_arrows:setVisible(false)
        _right_arrows_gray:setVisible(true)
    else
        _right_arrows_gray:setVisible(false)
        _right_arrows:setVisible(true)
    end
end

-- 页码回调
function pageCallback(tag, menuItem)
	if _isClickPageItem == true then
		GuildRobData.getGuildRobAreaInfo(refreshGranaries, tag, GuildRobData:getSearchKey())
	end
	_isClickPageItem = true
end

function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
		_isRunning = true
	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
		_layer = nil
		_isRunning = false
	end
end

function isRunning( ... )
	return _isRunning
end