-- FileName: CopyPointFormationLayer.lua 
-- Author: bzx
-- Date: 15-03-31 
-- Purpose: 副本据点阵容

module("CopyPointFormationLayer", package.seeall)

require "db/DB_Army"
require "db/DB_Team"
require "db/DB_Monsters"
require "script/battle/BattleCardUtil"

local _layer
local _touchPriority
local _zOrder
local _bg
local _groupCopyId
local _copyPointIndex

function show(p_groupCopyId, p_copyPointIndex, p_touchPriority, p_zOrder )
	_layer = create(p_groupCopyId, p_copyPointIndex, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create(p_groupCopyId, p_copyPointIndex, p_touchPriority, p_zOrder )
	init()
	initData(p_groupCopyId, p_copyPointIndex, p_touchPriority, p_zOrder)
	_layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 0xdd))
	_layer:registerScriptHandler(onNodeEvent)
	loadBg()
	loadMenu()
	loadFormation()
	loadAddition()
	loadBottomTip()
	return _layer
end

function init()
	-- body
end

function initData(p_groupCopyId, p_copyPointIndex, p_touchPriority, p_zOrder )
	_groupCopyId = p_groupCopyId
	_copyPointIndex = p_copyPointIndex
	_touchPriority = p_touchPriority or -700
	_zOrder = p_zOrder or 200
end

function loadBg( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(_groupCopyId)
	_bg = CCScale9Sprite:create("images/forge/tip_bg.png")
    _layer:addChild(_bg)
    _bg:setPreferredSize(CCSizeMake(577, 649))
    _bg:setAnchorPoint(ccp(0.5, 0.5))
    _bg:setPosition(ccpsprite(0.476, 0.6, _layer))
    _bg:setScale(MainScene.elementScale)
    local titleSprite = CCSprite:create("images/guild_boss_copy/point_title/" .. parseField(groupCopyDb.name_picture, 1)[_copyPointIndex])
    _bg:addChild(titleSprite)
    titleSprite:setAnchorPoint(ccp(0.5, 0.5))
    titleSprite:setPosition(ccp(_bg:getContentSize().width * 0.535, _bg:getContentSize().height - 10))
end

function loadFormation( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(_groupCopyId)
	local armyId = parseField(groupCopyDb.copy_id, 1)[_copyPointIndex]
    local armyDb = DB_Army.getDataById(armyId)
    local teamDb = DB_Team.getDataById(armyDb.monster_group)
    local monsterIDs = parseField(teamDb.monsterID, 1)
    for i = 1, #monsterIDs do
    	local monsterId = monsterIDs[i]
    	if monsterId ~= 0 then
    		local monsterDb = DB_Monsters.getDataById(monsterId)
    		local hero = BattleCardUtil.getBattlePlayerCardImage(monsterDb.hid, false, monsterDb.htid, false)
    		_bg:addChild(hero)
    		hero:setAnchorPoint(ccp(0.5, 0.5))
    		hero:setPosition(ccp(105 + ((i - 1) % 3) * 190, _bg:getContentSize().height - 380 + 210 * math.floor((i - 1) / 3)))
    		local nameLabel = tolua.cast(hero:getChildByTag(BattleCardUtil.kHeroNameLabelTag), "CCRenderLabel")
    		nameLabel:setPositionY(nameLabel:getPositionY() + 30)
    		local total, curr = GuildBossCopyData.getHeroHpInfo(_copyPointIndex, monsterDb.hid)
    		BattleCardUtil.setCardHp(hero, curr / total)
    		if curr == 0 then
    			local deadTagSprite =  CCSprite:create("images/guild_boss_copy/dead.png")
    			hero:addChild(deadTagSprite, 1000)
    			deadTagSprite:setAnchorPoint(ccp(0.5, 0.5))
    			deadTagSprite:setPosition(ccpsprite(0.5, 0.5, hero))
    		end
    	end
    end
end

function loadAddition( ... )
	local leftLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    _bg:addChild(leftLine)
    leftLine:setAnchorPoint(ccp(1,0.5))
    leftLine:setPosition(ccp(_bg:getContentSize().width * 0.5 - 100, 160))
    

    local rightLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    _bg:addChild(rightLine)
    rightLine:setScaleX(-1)
    rightLine:setAnchorPoint(ccp(1, 0.5))
    rightLine:setPosition(ccp(_bg:getContentSize().width * 0.5 + 100, 160))


	local additionTitle = CCRenderLabel:create(GetLocalizeStringBy("key_10063"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	_bg:addChild(additionTitle)
	additionTitle:setAnchorPoint(ccp(0.5, 0.5))
	additionTitle:setPosition(ccp(_bg:getContentSize().width * 0.5, 160))
	additionTitle:setColor(ccc3(0xff, 0xf6, 0x00))
	local copyInfo = GuildBossCopyData.getCopyInfo()[tostring(_copyPointIndex)]
	local additionImages = {"wei.png", "shu.png", "wu.png", "qun.png"}
	for i=1, 2 do
		local additionType = copyInfo.type[i]
		local sprite = CCSprite:create("images/guild_boss_copy/" .. additionImages[tonumber(additionType)])
		_bg:addChild(sprite)
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		if i == 1 then
			sprite:setPosition(ccp(_bg:getContentSize().width * 0.3, 90))
		else
			sprite:setPosition(ccp(_bg:getContentSize().width * 0.7, 90))
		end
	end
	local additionNames = {GetLocalizeStringBy("key_10064"), GetLocalizeStringBy("key_10065"), GetLocalizeStringBy("key_10066"), GetLocalizeStringBy("key_10067")}
	local groupCopyRuleDb = DB_GroupCopy_rule.getDataById(1)
	local tipText = string.format(GetLocalizeStringBy("key_10068"), additionNames[tonumber(copyInfo.type[1])], additionNames[tonumber(copyInfo.type[2])], math.floor(parseField(groupCopyRuleDb.camp_add, 1)[2] / 100))
	local tipLabel = CCRenderLabel:create(tipText, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	_bg:addChild(tipLabel)
	tipLabel:setAnchorPoint(ccp(0.5, 0.5))
	tipLabel:setPosition(ccp(_bg:getContentSize().width * 0.5, 30))
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setTouchPriority(_touchPriority - 10)
	menu:setPosition(ccp(0, 0))

    local backItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(150,73), GetLocalizeStringBy("key_10069"), ccc3(255,222,0))
    menu:addChild(backItem)
    backItem:setAnchorPoint(ccp(0.5, 0.5))
    backItem:setPosition(ccps(0.3, 0.2))
    backItem:registerScriptTapHandler(backItemCallback)
    backItem:setScale(MainScene.elementScale)

    local fightItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png", "images/common/btn/btn_red_h.png", CCSizeMake(150,73), GetLocalizeStringBy("key_10070"), ccc3(255,222,0))
    menu:addChild(fightItem)
    fightItem:setAnchorPoint(ccp(0.5, 0.5))
    fightItem:setPosition(ccps(0.7, 0.2))
    fightItem:registerScriptTapHandler(fightCallback)
    fightItem:setScale(MainScene.elementScale)
end

function loadBottomTip( ... )
	local attackReward = GuildBossCopyData.getAttackReward()
	local killReward = GuildBossCopyData.getKillReward()
	local exploitsTip = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_10071"), attackReward[3], killReward[3]), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	_layer:addChild(exploitsTip)
	exploitsTip:setAnchorPoint(ccp(0.5, 0.5))
	exploitsTip:setPosition(ccps(0.5, 0.1))
	exploitsTip:setScale(MainScene.elementScale)

	local fightTip = CCRenderLabel:create(GetLocalizeStringBy("key_10072"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	_layer:addChild(fightTip)
	fightTip:setAnchorPoint(ccp(0.5, 0.5))
	fightTip:setPosition(ccps(0.5, 0.05))
	fightTip:setColor(ccc3(0x00, 0xff, 0x18))
	fightTip:setScale(MainScene.elementScale)
end

function onNodeEvent(p_event)
	if p_event == "enter" then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _layer:setTouchEnabled(true)
	elseif p_event == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler( p_eventType, x, y )
	if (p_eventType == "began") then
		return true
	end
end

function backItemCallback( ... )
	close()
end

function fightCallback( ... )
	if GuildBossCopyData.getAtkNum() == 0 then
		CopyPointLayer.addTimesCallback()
		--AnimationTip.showTip(GetLocalizeStringBy("key_10073"))
		return
	end
	GuildBossCopyService.attack(attackCallFunc, _groupCopyId, _copyPointIndex)
end

function attackCallFunc(p_ret)
	if p_ret.ret == "dead" then
		AnimationTip.showTip(GetLocalizeStringBy("key_10074"))
		CopyPointLayer.show(CopyPointLayer.getGroupCopyId())
		return
	end
	CopyPointLayer.show(_groupCopyId)
	require "script/ui/guildBossCopy/GuildBossCopyFightResultLayer"
    local resultLayer = GuildBossCopyFightResultLayer.create(p_ret, _groupCopyId, _copyPointIndex, battleResultCallback, -1100)
    local endCallFunc = function ( ... )
    	CopyPointLayer.playBgm()
    end
    require "script/battle/BattleLayer"
    BattleLayer.showBattleWithString(p_ret.fight_ret, endCallFunc, resultLayer, "tuanduifuben.jpg",nil,nil,nil,nil,false)
end

function battleResultCallback( ... )
	close()
end

function close( ... )
	if _layer ~= nil then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end