-- FileName: GuildAfterRobBattleLayer.lua
-- Author: lichenyang
-- Date: 14-1-8
-- Purpose: 扫荡界面
-- @module GuildAfterRobBattleLayer

module("GuildAfterRobBattleLayer",package.seeall)

require "script/ui/guild/guildrob/GuildRobBattleData"
require "script/ui/guild/guildrob/GuildRobBattleService"
require "script/battle/BattleUtil"

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer = nil
local _layerSize = nil
local _touchPriority = nil
local _reportScrollView = nil
local _reportInfos = nil
local _zOrder = nil
function init( ... )
	_bgLayer = nil
	_layerSize = nil
	_touchPriority = nil
	_reportInfos = nil
	_zOrder = nil
	_reportScrollView = nil
end

-------------------------------[[ ui 创建方法 ]]---------------------------
--[[
	@des : 显示接口
--]]
function show( p_touchPriority, p_zOrder )
	local layer = createLayer(p_touchPriority, p_zOrder)
	local runningScene =  CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, _zOrder)
end

--[[
	@des : 创建层
--]]
function createLayer( p_touchPriority, p_zOrder )
	init()
	_touchPriority = p_touchPriority or -400
	_zOrder = p_zOrder or 400
	_bgLayer = BaseUI.createMaskLayer(_touchPriority - 10)

	createInfoPanel()
	return _bgLayer
end


function createInfoPanel( ... )
	local panelSprite = CCSprite:create("images/guild_rob/report_info.png")
	panelSprite:setAnchorPoint(ccp(0.5, 0.5))
	panelSprite:setPosition(ccps(0.5, 0.5))
	_bgLayer:addChild(panelSprite)
	panelSprite:setScale(MainScene.elementScale)

	local titleSprite = CCSprite:create("images/guild_rob/report_title.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccpsprite(0.6, 0.9, panelSprite))
	panelSprite:addChild(titleSprite)

	local reportInfo = GuildRobBattleData.getAfterBattleInfo()
	local descriptionLabel = createReckonDescription(reportInfo.duration)
	descriptionLabel:setAnchorPoint(ccp(0, 0.5))
	descriptionLabel:setPosition(ccp(300, 285))
	panelSprite:addChild(descriptionLabel)

	local infoTable = {
		{key =GetLocalizeStringBy("lcyx_106"), value=reportInfo.guildGrain ..GetLocalizeStringBy("lcyx_110")},
		{key =GetLocalizeStringBy("lcyx_107"), value=reportInfo.userGrain .. GetLocalizeStringBy("lcyx_110")},
		{key =GetLocalizeStringBy("lcyx_108"), value=reportInfo.merit},
		{key =GetLocalizeStringBy("lcyx_109"), value=reportInfo.kill},
	}

	for i=1,4 do
		local fieldBg = CCScale9Sprite:create("images/guild_rob/field_bg.png")
		fieldBg:setContentSize(CCSizeMake(270, 30))
		fieldBg:setAnchorPoint(ccp(0, 1))
		fieldBg:setPosition(ccp(300, 250 - (i-1)*38))
		panelSprite:addChild(fieldBg)
		
		local titleLabel = CCRenderLabel:create(infoTable[i].key, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleLabel:setPosition(ccpsprite(0.08, 0.5, fieldBg))
		titleLabel:setAnchorPoint(ccp(0, 0.5))
		titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		fieldBg:addChild(titleLabel)

		local valueLabel = CCRenderLabel:create(infoTable[i].value, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		valueLabel:setPosition(ccpsprite(0.5, 0.5, fieldBg))
		valueLabel:setAnchorPoint(ccp(0, 0.5))
		valueLabel:setColor(ccc3(0x00, 0xff, 0x18))
		fieldBg:addChild(valueLabel)
	end

	--退出按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 50)
	panelSprite:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccpsprite(0.65, 0.17, panelSprite))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)
	
	local closeBtnTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3344"), g_sFontPangWa, 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	closeBtnTitle:setPosition(ccpsprite(0.5, 0.5, closeButton))
	closeBtnTitle:setAnchorPoint(ccp(0.5, 0.5))
	closeBtnTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	closeButton:addChild(closeBtnTitle)


	local fireworkEffect =  CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/firexing/firexing"), -1,CCString:create(""))
	fireworkEffect:setPosition(ccpsprite(0.5, 0.5, panelSprite))
	panelSprite:addChild(fireworkEffect, 100)

	local scene = CCDirector:sharedDirector():getRunningScene()
	local fireworkEffect =  CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/firework/firework"), -1,CCString:create(""))
	fireworkEffect:setPosition(ccps(0.5, 0.5))
	scene:addChild(fireworkEffect, 1000)

	local animationDelegate = BTAnimationEventDelegate:create()
    animationDelegate:registerLayerEndedHandler(function ( ... )
    	fireworkEffect:removeFromParentAndCleanup(true)
    	fireworkEffect = nil
    end)
    fireworkEffect:setDelegate(animationDelegate)
end

--[[
	@des : 关闭按钮
--]]
function closeButtonCallback( tag, sender )
	if _bgLayer  then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	GuildRobBattleLayer.closeBattle()
end

--[[
	@des: 创建结算说明文字说明
--]]
function createReckonDescription( p_duration )
	local duration = tonumber(p_duration) or 0
	local battletime = GuildRobBattleData.getBattleTime()
	local durationString = ""
	if duration >= battletime then
		--抢粮时间到结束
		durationString = GetLocalizeStringBy("lcyx_111")
	else
		--抢粮时间未到
		if GuildRobBattleData.isUserAttackerGuild() then
			durationString = GetLocalizeStringBy("lcyx_112")
		else
			durationString = GetLocalizeStringBy("lcyx_113")
		end
	end
	local label = CCRenderLabel:create(durationString, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	return label
end




