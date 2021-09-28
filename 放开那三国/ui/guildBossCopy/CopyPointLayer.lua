-- FileName: CopyPointLayer.lua
-- Author: bzx
-- Date: 15-04-02
-- Purpose: 军团副本据点

require "script/ui/guildBossCopy/CopyPointSprite"
require "script/ui/tip/RichAlertTip"
require "db/teamCXml/city"

module("CopyPointLayer", package.seeall)

local _layer
local _groupCopyId
local _touchPriority = -420
local _remainAttackTimes = nil
local _timeBg = nil
local _hpBar = nil
local _timeLabel = nil
local _curTipIndex = 1
local _tipScrollView = nil
local _pointCopySprites = {}


function show(p_groupCopyId)
	_layer = create(p_groupCopyId)
	MainScene.changeLayer(_layer, "CopyPointLayer")
end

function init( ... )
	_remainAttackTimes = nil
	_layer = nil
	_groupCopyId = 0
	_touchPriority = -420
	_remainAttackTimes = nil
	_timeBg = nil
	_hpBar = nil
	_timeLabel = nil
	_curTipIndex = 1
	_tipScrollView = nil
	_pointCopySprites = {}
end


function initData( p_groupCopyId )
	_groupCopyId = p_groupCopyId
end

function getGroupCopyId( ... )
	return _groupCopyId
end
function create( p_groupCopyId )
	init()
	initData(p_groupCopyId)
	_layer = CCLayer:create()
	loadBg()
	loadMenu()
	loadTimeBg()
	loadTitle()
	refreshHpBar()
	schedule(_timeBg, refreshTime, 1)
	refreshTime()
	refreshRemainAttackTimes()
	loadBuyAllAttackTip()
	playBgm()
	local getCopyInfoCallFunc = function ( ... )
		loadCopyPoints()
	end
	GuildBossCopyService.getCopyInfo(getCopyInfoCallFunc, p_groupCopyId)
	return _layer
end

function loadBg( ... )
	local bg = XMLSprite:create("images/guild_boss_copy/effect/juntuanzhanzheng/juntuanzhanzheng")
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccps(0.5, 0.5))
	bg:setScale(MainScene.bgScale)
end

function playBgm( ... )
	AudioUtil.playBgm("audio/bgm/music04.mp3")
end

function stopBgm( ... )
	AudioUtil.playBgm("audio/main.mp3")
end

function loadTitle( ... )
	local titleBg = CCScale9Sprite:create(CCRectMake(8, 16, 4, 8), "images/guild_boss_copy/title_bg.png")
	_timeBg:addChild(titleBg)
	titleBg:setAnchorPoint(ccp(0, 0))
	titleBg:setPosition(ccpsprite(-0.02, 1, _timeBg))
	titleBg:setContentSize(CCSizeMake(311, 42))
	local groupCopyDb = DB_GroupCopy.getDataById(_groupCopyId)
	local title = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10075"), _groupCopyId, groupCopyDb.des), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	titleBg:addChild(title)
	title:setAnchorPoint(ccp(0, 0.5))
	title:setPosition(ccp(80, titleBg:getContentSize().height * 0.5))
	title:setColor(ccc3(0xff, 0xf6, 0x00))
end

function loadTimeBg( ... )
	_timeBg = CCScale9Sprite:create("images/common/bg/di.png")
	_layer:addChild(_timeBg, 1000)
	_timeBg:setAnchorPoint(ccp(0, 1))
	_timeBg:setPosition(ccp(0, g_winSize.height - 42 * MainScene.elementScale))
	_timeBg:setContentSize(CCSizeMake(320, 88))
	_timeBg:setScale(MainScene.elementScale)
end

function refreshHpBar( ... )
	local total, curr = GuildBossCopyData.getBossCopyHpInfo()
	local progress = curr / total
	if _hpBar == nil then
		-- local progressInfo = {
		-- 	{
		-- 		progress = 0.1, 
		-- 		progressSpriteImage = "images/common/red_hp.png"
		-- 	}
		-- }
		_hpBar = ProgressBar:create("images/common/exp_bg.png", "images/common/exp_progress.png", 200, progress, nil)
		_timeBg:addChild(_hpBar)
		_hpBar:setAnchorPoint(ccp(0.5, 0.5))
		_hpBar:setPosition(ccp(130, 60))	
	else
		_hpBar:setProgress(progress)
	end
	if curr == 0 then
		_hpBar:removeFromParentAndCleanup(true)
		local tip = CCRenderLabel:create(GetLocalizeStringBy("key_10076"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		_timeBg:addChild(tip)
		tip:setAnchorPoint(ccp(0.5, 0.5))
		tip:setPosition(ccp(130, 60))
		tip:setColor(ccc3(0x00, 0xff, 0x18))
	end
end

function refreshTime( ... )
	if _timeLabel ~= nil then
		_timeLabel:removeFromParentAndCleanup(true)
	end
	local time = TimeUtil.getIntervalByTime("240000")
	local curTime = TimeUtil.getSvrTimeByOffset()
	local remainTime = time - curTime
	local labelInfo = {
		labelDefaultSize = 21,
		defaultType = "CCRenderLabel",
		elements = {
			{
				text = TimeUtil.getTimeString(remainTime),
				color = ccc3(0x00, 0xff, 0x18)
			}
		}
	}
	_timeLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10077"), labelInfo)
	_timeBg:addChild(_timeLabel)
	_timeLabel:setAnchorPoint(ccp(0.5, 0.5))
	_timeLabel:setPosition(130, 25)
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu, 480)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 5)

	local damageRankItem = CCMenuItemImage:create("images/common/btn/btn_hurt_n.png", "images/common/btn/btn_hurt_h.png")
	menu:addChild(damageRankItem)
	damageRankItem:setAnchorPoint(ccp(0.5, 0.5))
	damageRankItem:setPosition(ccpsprite(0.75, 0.95, menu))
	damageRankItem:registerScriptTapHandler(damageRankCallback)
	damageRankItem:setScale(MainScene.elementScale)

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setAnchorPoint(ccp(0.5, 0.5))
	backItem:setPosition(ccpsprite(0.9, 0.95, menu))
	backItem:registerScriptTapHandler(backCallback)
	backItem:setScale(MainScene.elementScale)

	local allAttackItem = CCMenuItemImage:create("images/guild_boss_copy/all_attack_n.png","images/guild_boss_copy/all_attack_h.png")
	menu:addChild(allAttackItem)
	allAttackItem:setAnchorPoint(ccp(0.5, 0.1))
	allAttackItem:setPosition(ccpsprite(0.9, 0.015, menu))
	allAttackItem:registerScriptTapHandler(allAttackCallback)
	allAttackItem:setScale(MainScene.elementScale)

	local treasureRoomItem = CCMenuItemImage:create("images/guild_boss_copy/box_room_n.png", "images/guild_boss_copy/box_room_h.png")
	menu:addChild(treasureRoomItem)
	treasureRoomItem:setAnchorPoint(ccp(0.5, 0))
	treasureRoomItem:registerScriptTapHandler(treasureRoomCallback)
	treasureRoomItem:setScale(MainScene.elementScale)
	for  i = 1, #TeamCity.models.normal do
		local uiInfo = TeamCity.models.normal[i]
		local copyPointIndex = tonumber(uiInfo.looks.look.armyID)
		if copyPointIndex == 1000 then
			treasureRoomItem:setPosition(ccp(uiInfo.x * g_fScaleX, (960 - uiInfo.y) * g_fScaleY))
			break
		end
	end

	-- local light = CCSprite:create("images/guild_boss_copy/box_title_light.png")
	-- treasureRoomItem:addChild(light, -1)
	-- light:setAnchorPoint(ccp(0.5, 0))
	-- light:setPosition(ccpsprite(0.5, 0.3, treasureRoomItem))
	local treasureRoomNameBg = CCScale9Sprite:create("images/common/bg/bg2.png")
	treasureRoomItem:addChild(treasureRoomNameBg)
	-- treasureRoomNameBg:setContentSize(CCSizeMake(240, 49))
	treasureRoomNameBg:setAnchorPoint(ccp(0.5, 1))
	treasureRoomNameBg:setPosition(ccpsprite(0.5, 0, treasureRoomItem))
	local treasureRoomName = CCRenderLabel:create(GetLocalizeStringBy("key_10078"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	treasureRoomNameBg:addChild(treasureRoomName)
	treasureRoomName:setAnchorPoint(ccp(0.5, 0.5))
	treasureRoomName:setPosition(ccpsprite(0.5, 0.5, treasureRoomNameBg))
	treasureRoomName:setColor(ccc3(0xff, 0xf6, 0x00))
	local treasureRoomEffect = XMLSprite:create("images/guild_boss_copy/effect/baotaguangxiao/baotaguangxiao")
	treasureRoomItem:addChild(treasureRoomEffect)
	treasureRoomEffect:setPosition(ccpsprite(0.5, 0.5, treasureRoomItem))
	if GuildBossCopyData.couldOpenBoxOrReceive() then
		local rewardBoxNode = CCLayerColor:create(ccc4(0xff, 0x00, 0xff, 0x00), 100, 100)
		local rewardBox = XMLSprite:create("images/base/effect/xuanzhuanbaoxiang/xuanzhuanbaoxiang")
		rewardBoxNode:addChild(rewardBox)
		rewardBox:setPosition(ccpsprite(0.5, 0.5, rewardBoxNode))
		local rewardBoxItem = CCMenuItemSprite:create(rewardBoxNode, rewardBoxNode)
		menu:addChild(rewardBoxItem)
		local position = ccpsprite(0.47, 0.9, treasureRoomItem)
		position.x = treasureRoomItem:getPositionX() --+ position.x
		position.y = treasureRoomItem:getPositionY() + position.y
		rewardBoxItem:setAnchorPoint(ccp(0.5, 0))
		rewardBoxItem:setPosition(position)
		rewardBoxItem:setScale(MainScene.elementScale * 0.8)
		rewardBoxItem:registerScriptTapHandler(treasureRoomCallback)
	end
end

function loadCopyPoints( ... )
	for  i = 1, #TeamCity.models.normal do
		local uiInfo = TeamCity.models.normal[i]
		local copyPointIndex = tonumber(uiInfo.looks.look.armyID)
		if copyPointIndex < 1000 then
			local copyPointSprite = CopyPointSprite:createById(_groupCopyId, copyPointIndex, _touchPriority - 5, clickCopyPointCallback)
			_layer:addChild(copyPointSprite, uiInfo.y)
			copyPointSprite:setPosition(ccp(uiInfo.x * g_fScaleX, (960 - uiInfo.y) * g_fScaleY))
			copyPointSprite:setAnchorPoint(ccp(0.5, 0))
			copyPointSprite:setScale(MainScene.elementScale)
			_pointCopySprites[copyPointIndex] = copyPointSprite
		end
	end
end

function refreshPointSpriteByIndex( p_copyPointIndex )
	local copyPointSprite = _pointCopySprites[p_copyPointIndex]
	copyPointSprite:refresh()
end

function refreAllPointSprite( ... )
	if not tolua.cast(_layer, "CCLayer") then
		return
	end
	for i = 1, #_pointCopySprites do
		local copyPointSprite = _pointCopySprites[i]
		copyPointSprite:refresh()
	end
end

function refreshRemainAttackTimes( ... )
	if not tolua.cast(_layer, "CCLayer") then
		return
	end
	if _remainAttackTimes == nil then
		local remainBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
		_layer:addChild(remainBg)
		remainBg:setAnchorPoint(ccp(0.5, 0))
		remainBg:setPosition(ccps(0.5, 0.01))
		remainBg:setContentSize(CCSizeMake(262, 51))
		remainBg:setScale(MainScene.elementScale)
		local remainLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10079"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		remainBg:addChild(remainLabel)
		remainLabel:setAnchorPoint(ccp(0, 0.5))
		remainLabel:setPosition(ccp(10, remainBg:getContentSize().height * 0.5))
		_remainAttackTimes = CCRenderLabel:create("", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		remainLabel:addChild(_remainAttackTimes)
		_remainAttackTimes:setAnchorPoint(ccp(0, 0.5))
		_remainAttackTimes:setPosition(ccpsprite(1, 0.5, remainLabel))
		_remainAttackTimes:setColor(ccc3(0x00, 0xff, 0x18))

		local menu = CCMenu:create()
		remainBg:addChild(menu)
		menu:setPosition(ccp(0, 0))
		menu:setContentSize(remainBg:getContentSize())
		menu:setTouchPriority(_touchPriority - 5)
		local addTimesItem = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png")
		menu:addChild(addTimesItem)
		addTimesItem:setAnchorPoint(ccp(0.5, 0.5))
		addTimesItem:setPosition(ccp(remainBg:getContentSize().width - 30, remainBg:getContentSize().height * 0.5))
		addTimesItem:registerScriptTapHandler(addTimesCallback)
	end
	local remainTimes = tostring(GuildBossCopyData.getUserInfo().atk_num)
	_remainAttackTimes:setString(remainTimes)

end

function clickCopyPointCallback(p_tag, p_menuItem )
	local copyPointIndex = p_tag
	require "script/ui/guildBossCopy/CopyPointFormationLayer"
	CopyPointFormationLayer.show(_groupCopyId, copyPointIndex, _touchPriority - 10, 10)
end

function damageRankCallback( ... )
	require "script/ui/guildBossCopy/DamageRankListLayer"
	DamageRankListLayer.show(_touchPriority - 10, 10)
end

function backCallback( ... )
	GuildBossCopyLayer.show()
	stopBgm()
end

function addTimesCallback( ... )
	local currBuyNum = tonumber(GuildBossCopyData.getUserInfo().buy_num)
	local groupCopyRuleDb = DB_GroupCopy_rule.getDataById(1)
	if currBuyNum >= groupCopyRuleDb.buy_num then
		AnimationTip.showTip(GetLocalizeStringBy("key_10080"))
		return
	end
	local _, curHp = GuildBossCopyData.getBossCopyHpInfo()
	if curHp == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10144"))
		return
	end
	local cost = GuildBossCopyData.getBuyAttackCost()
	local richInfo = {
		elements = {
			{
				["type"] = "CCSprite",
                image = "images/common/gold.png"
			},
			{
				text = cost
			},
			{
				text = 1
			}
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10081"), richInfo)
	local alertCallback = function ( isConfirm, _argsCB )
		if not isConfirm then
			return
		end
		if cost > UserModel.getGoldNumber() then
    		require "script/ui/tip/LackGoldTip"
    		LackGoldTip.showTip()
    		return
    	end
		local addAtkNumCallFunc = function (p_ret)
			if p_ret == "already_pass" then
				AnimationTip.showTip(GetLocalizeStringBy("key_10082"))
				return
			end
			refreshRemainAttackTimes()
		end
		GuildBossCopyService.addAtkNum(addAtkNumCallFunc)
	end
	RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"))
end

function allAttackCallback( ... )
	local _, curHp = GuildBossCopyData.getBossCopyHpInfo()
	if curHp == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10144"))
		return
	end
	local vipLimit = getNecessaryVipLevel("groupcopyfresh", 0)
	if UserModel.getVipLevel() < vipLimit then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10083"), vipLimit))
		return
	end

	if GuildBossCopyData.getUserInfo().refresh_time ~= "0" then
		AnimationTip.showTip(GetLocalizeStringBy("key_10084"))
		return
	end
	local buyAllAttackInfo = GuildBossCopyData.getBuyAllAttackCostInfo()
	if buyAllAttackInfo[1] == tonumber(GuildBossCopyData.getUserInfo().refresh_num) then
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10085"), buyAllAttackInfo[1]))
		return
	end
	local richInfo = {
		labelDefaultColor = ccc3(0xff, 0xff, 0xff),
		labelDefaultSize = 21,
		defaultType = "CCRenderLabel",
		width = 376,
		linespace = 16,
		elements = {
			{
				["type"] = "CCSprite",
                image = "images/common/gold.png"
			},
			{
				text = buyAllAttackInfo[2]
			},
			{
				text = GetLocalizeStringBy("key_10086"),
				color = ccc3(0xe4, 0x00, 0xff),
			},
			{
				text = GetLocalizeStringBy("key_10086"),
				color = ccc3(0xe4, 0x00, 0xff),
			},
			{
				text = string.format(GetLocalizeStringBy("key_10087"), buyAllAttackInfo[3]),
				color = ccc3(0xff, 0xf6, 0x00)
			},
			{
				newLine =true,
				text = string.format(GetLocalizeStringBy("key_10088"), buyAllAttackInfo[1] - tonumber(GuildBossCopyData.getUserInfo().refresh_num)),
				color = ccc3(0x00, 0xff, 0x18),
			}
		}
	}
	
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10089"), richInfo)
    RichAlertTip.showAlert(newRichInfo, allAttack, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, 480, true)
end

function allAttack(isConfirm, _argsCB)
    if isConfirm == false then
        return
    end
    local buyAllAttackInfo = GuildBossCopyData.getBuyAllAttackCostInfo()
    local cost = buyAllAttackInfo[2]
    if cost > UserModel.getGoldNumber() then
    	require "script/ui/tip/LackGoldTip"
    	LackGoldTip.showTip()
    	return
    end
    local refreshCallFunc = function ( p_ret )
    	if p_ret == "already_pass" then
    		AnimationTip.showTip(GetLocalizeStringBy("key_10082"))
    		return
    	elseif p_ret == "lack" then
    		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10085"), buyAllAttackInfo[1]))
    		return
    	end
    	refreshRemainAttackTimes()
    end
    GuildBossCopyService.refresh(refreshCallFunc)
end

function treasureRoomCallback( ... )
	require "script/ui/guildBossCopy/TreasureRoomLayer"
	TreasureRoomLayer.show()
end

function loadBuyAllAttackTip()
	if not tolua.cast(_layer, "CCLayer") then
		return
	end
	if table.isEmpty(GuildBossCopyData.getUserInfo().refresher) then
		return
	end
	if _tipScrollView ~= nil then
		return
	end
	local fullRect = CCRectMake(0, 0, 209, 49)
	local insetRect = CCRectMake(86, 14, 45, 20)
 	local tipBg = CCScale9Sprite:create("images/guild/liangcang/gonggao.png", fullRect, insetRect)
 	_layer:addChild(tipBg, 1000)
 	tipBg:setAnchorPoint(ccp(0.5, 1))
 	tipBg:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 130 * MainScene.elementScale))
 	tipBg:setContentSize(CCSizeMake(640, 40))
 	tipBg:setScale(g_fScaleX)

 	local exploitsIcon = CCSprite:create("images/guild_boss_copy/exploits_icon.png")
 	tipBg:addChild(exploitsIcon)
 	exploitsIcon:setAnchorPoint(ccp(0, 0.5))
 	exploitsIcon:setPosition(ccp(20, tipBg:getContentSize().height * 0.5))

 	_tipScrollView = CCScrollView:create()
 	tipBg:addChild(_tipScrollView)
	_tipScrollView:setTouchEnabled(false)
	_tipScrollView:setViewSize(CCSizeMake(510, tipBg:getContentSize().height))
	_tipScrollView:setContentSize(CCSizeMake(510, tipBg:getContentSize().height))
	_tipScrollView:setPosition(ccp(exploitsIcon:getPositionX() + exploitsIcon:getContentSize().width, 0))
	showTip()
end

function showTip( ... )
	local buyAllAttackInfo = GuildBossCopyData.getBuyAllAttackCostInfo()
	local richInfo = {
		alignment = 1,
		labelDefaultSize = 20,
		defaultType = "CCRenderLabel",
		elements = {
			{
				text = string.format("【%s】", GuildBossCopyData.getUserInfo().refresher[_curTipIndex]),
				color = ccc3(0x00, 0xe4, 0xff),
			},
			{
				text = GetLocalizeStringBy("key_10086"),
				color = ccc3(0xe4, 0x00, 0xff),
			},
			{
				text = buyAllAttackInfo[3]
			}
		}
	}
 	local tipLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10090"), richInfo)
	_tipScrollView:addChild(tipLabel)
	tipLabel:setAnchorPoint(ccp(0, 0.5))
	tipLabel:setPosition(ccpsprite(1, 0.5, _tipScrollView))
	local actionArr = CCArray:create()
	local move = CCMoveTo:create(25, ccp(-tipLabel:getContentSize().width, _tipScrollView:getViewSize().height * 0.5))
	actionArr:addObject(move)
	local moveEnd = CCCallFuncN:create(function (p_tipLabel)
		p_tipLabel:removeFromParentAndCleanup(true)
		local tipCount = #GuildBossCopyData.getUserInfo().refresher
		_curTipIndex = _curTipIndex % tipCount + 1
		showTip()
	end)
	actionArr:addObject(moveEnd)
	local seq = CCSequence:create(actionArr)
	tipLabel:runAction(seq)
end


