-- FileName: CountryWarAfterLayer.lua 
-- Author: licong 
-- Date: 15/11/25 
-- Purpose: 国战战场结算


module("CountryWarAfterLayer", package.seeall)

require "script/ui/countryWar/war/CountryWarPlaceData"

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer = nil
local _touchPriority = nil
local _zOrder = nil
local _resultInfo = nil
function init( ... )
	_bgLayer = nil
	_touchPriority = nil
	_zOrder = nil
	_resultInfo = nil
end

-------------------------------[[ ui 创建方法 ]]---------------------------
--[[
	@des : 显示接口
--]]
function show( p_touchPriority, p_zOrder, p_info )
	local layer = createLayer(p_touchPriority, p_zOrder,p_info)
	local runningScene =  CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, _zOrder)
end

--[[
	@des : 创建层
--]]
function createLayer( p_touchPriority, p_zOrder, p_info )
	init()
	_touchPriority = p_touchPriority or -400
	_zOrder = p_zOrder or 400
	_bgLayer = BaseUI.createMaskLayer(_touchPriority - 10)
	_resultInfo = p_info
	print("_resultInfo")
	print_t(_resultInfo)
	createInfoPanel()
	return _bgLayer
end


function createInfoPanel( ... )
	local panelSprite = CCSprite:create("images/country_war/jiesuan.png")
	panelSprite:setAnchorPoint(ccp(0.5, 0.5))
	panelSprite:setPosition(ccps(0.5, 0.5))
	_bgLayer:addChild(panelSprite)
	panelSprite:setScale(g_fScaleX)

	local titleSprite = CCSprite:create("images/country_war/after_title.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(panelSprite:getContentSize().width*0.63,panelSprite:getContentSize().height-183)
	panelSprite:addChild(titleSprite)

	-- 初赛还是决赛
	local isAudition = true
	local curStage = CountryWarMainData.getCurStage()
	if( curStage <= CountryWarDef.SUPPORT )then
		isAudition = true
	else
		isAudition = false
	end

	local curPos = panelSprite:getContentSize().height - 230

	if(isAudition == false)then
		-- 决赛势力输赢
		local filePath = nil
		if(tonumber(_resultInfo.isSideWin) == 1)then
			filePath = "images/country_war/win_font.png"
		else
			filePath = "images/country_war/fail_font.png"
		end
		local resultSp = CCSprite:create(filePath)
		resultSp:setAnchorPoint(ccp(0, 0.5))
		resultSp:setPosition(270,curPos)
		panelSprite:addChild(resultSp)
		curPos = curPos - 40
	end
	
	local rankNum = tonumber(_resultInfo.rank)+1
	local str = nil
	if(isAudition)then
		str = GetLocalizeStringBy("lic_1750",tostring(rankNum)) 
	else 
		str = GetLocalizeStringBy("lic_1751",tostring(rankNum))
	end
	local rankLabel = CCRenderLabel:create(str, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	rankLabel:setAnchorPoint(ccp(0, 0.5))
	rankLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	rankLabel:setPosition(270, curPos)
	panelSprite:addChild(rankLabel)

	-- 是否进入决赛
	if(isAudition == true)then
		local jionRank = CountryWarPlaceData.getCanJoinFinalsRank()
		if(rankNum <= jionRank )then
			curPos = curPos - 50
			local tipSp = CCSprite:create("images/country_war/gongxin.png")
			tipSp:setAnchorPoint(ccp(0, 0.5))
			tipSp:setPosition(270,curPos)
			panelSprite:addChild(tipSp)
			tipSp:setScale(0.7)
		end
	end
	
	curPos = curPos - 40
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1752"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel:setAnchorPoint(ccp(0, 0.5))
	tipLabel:setColor(ccc3(0x00, 0xff, 0x18))
	tipLabel:setPosition(270, curPos)
	panelSprite:addChild(tipLabel)

	-- 奖励物品
	curPos = curPos - 70
	local rewardTab = nil
	if(isAudition)then
		rewardTab = CountryWarPlaceData.getRankReward(1,rankNum)
	else
		rewardTab = CountryWarPlaceData.getRankReward(2,rankNum)
	end
	local i = 1
	for k,v in pairs(rewardTab) do
		local iconSp = ItemUtil.createGoodsIcon(v, nil, nil, nil, nil ,nil,true)
		iconSp:setAnchorPoint(ccp(0, 0.5))
		iconSp:setPosition(270+(i-1)*(iconSp:getContentSize().width+10), curPos)
		panelSprite:addChild(iconSp)
		i = i+1
	end

	curPos = curPos - 100
	local fieldBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	fieldBg:setContentSize(CCSizeMake(270, 30))
	fieldBg:setAnchorPoint(ccp(0, 0.5))
	fieldBg:setPosition(ccp(270, curPos))
	panelSprite:addChild(fieldBg)
	
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1753"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setPosition(ccpsprite(0.08, 0.5, fieldBg))
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	fieldBg:addChild(titleLabel)

	local valueLabel = CCRenderLabel:create(_resultInfo.point, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	valueLabel:setPosition(ccpsprite(0.5, 0.5, fieldBg))
	valueLabel:setAnchorPoint(ccp(0, 0.5))
	valueLabel:setColor(ccc3(0x00, 0xff, 0x18))
	fieldBg:addChild(valueLabel)
	
	--退出按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 50)
	panelSprite:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccpsprite(0.65, 0.1, panelSprite))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)
	
	local closeBtnTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3344"), g_sFontPangWa, 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	closeBtnTitle:setPosition(ccpsprite(0.5, 0.5, closeButton))
	closeBtnTitle:setAnchorPoint(ccp(0.5, 0.5))
	closeBtnTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	closeButton:addChild(closeBtnTitle)


	local fireworkEffect1 =  XMLSprite:create("images/guild_rob/effect/firexing/firexing")
	fireworkEffect1:setPosition(ccpsprite(0.5, 0.5, panelSprite))
	panelSprite:addChild(fireworkEffect1, 100)

	local scene = CCDirector:sharedDirector():getRunningScene()
	local fireworkEffect =  XMLSprite:create("images/guild_rob/effect/firework/firework")
	fireworkEffect:setPosition(ccps(0.5, 0.5))
	scene:addChild(fireworkEffect, 1000)
    fireworkEffect:registerEndCallback(function ( ... )
    	fireworkEffect:removeFromParentAndCleanup(true)
    	fireworkEffect = nil
    end)
end

--[[
	@des : 关闭按钮
--]]
function closeButtonCallback( tag, sender )
	if _bgLayer  then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	CountryWarPlaceLayer.closeBattle()
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




