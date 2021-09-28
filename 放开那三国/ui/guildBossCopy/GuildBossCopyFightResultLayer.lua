-- FileName: GuildBossCopyFightResultLayer.lua 
-- Author: bzx
-- Date: 15-04-02 
-- Purpose: 军团副本战斗结算面板

module("GuildBossCopyFightResultLayer", package.seeall)

local _layer 
local _dialog
local _fightInfo 
local _closeCallback 
local _touchPriority
local _groupCopyId
local _pointCopyIndex
local _groupCopyDb 

function create( p_fightInfo, p_groupCopyId, p_pointCopyIndex, p_closeCallback, p_touchPriority )
	initData(p_fightInfo, p_groupCopyId, p_pointCopyIndex, p_closeCallback, p_touchPriority)
	_layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 0xdd))
	local dialogInfo = {}
    dialogInfo.title = GetLocalizeStringBy("key_10109")
    dialogInfo.callbackClose = nil
    dialogInfo.size = CCSizeMake(540, 437)
    dialogInfo.priority = _touchPriority - 1
    dialogInfo.swallowTouch = true
    dialogInfo.close = false
    _layer = LuaCCSprite.createDialog_1(dialogInfo)
    _dialog = dialogInfo.dialog
    _dialog:setPosition(ccps(0.5, 0.6))
    loadTitle()
    loadDamage()
    loadExploits()
    loadKill()
    laodMenu()
	return _layer
end

function loadTitle( ... )
	local titleBg = CCSprite:create("images/common/line2.png")
    _dialog:addChild(titleBg)
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    titleBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 78))

    local name = parseField(_groupCopyDb.name, 1)[_pointCopyIndex]
    local titleLabel = CCRenderLabel:create(name, g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleBg:addChild(titleLabel)
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccpsprite(0.5, 0.5, titleBg))
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
end

function loadDamage( ... )
	local damageBg  = CCScale9Sprite:create("images/common/labelbg_white.png")
    _dialog:addChild(damageBg)
    damageBg:setContentSize(CCSizeMake(407, 48))
    damageBg:setAnchorPoint(ccp(0.5, 0.5))
    damageBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 145))

    local damageTitle = CCRenderLabel:create(GetLocalizeStringBy("key_10111"), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    damageBg:addChild(damageTitle)
    damageTitle:setAnchorPoint(ccp(0.5, 0.5))
    damageTitle:setPosition(ccp(126, damageBg:getContentSize().height * 0.5))
    damageTitle:setColor(ccc3(0xff, 0xf6, 0x00))

    local damageValueLabel = CCRenderLabel:create(_fightInfo.damage, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    damageBg:addChild(damageValueLabel)
    damageValueLabel:setAnchorPoint(ccp(0, 0.5))
    damageValueLabel:setPosition(ccp(251, damageBg:getContentSize().height * 0.5))
    damageValueLabel:setColor(ccc3(0xff, 0x3d, 0x01))
end

function loadExploits( ... )
	local exploitsBg = CCScale9Sprite:create("images/common/labelbg_white.png")
    _dialog:addChild(exploitsBg)
    exploitsBg:setContentSize(CCSizeMake(407, 48))
    exploitsBg:setAnchorPoint(ccp(0.5, 0.5))
    exploitsBg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 213))

	local exploitsTitle = CCRenderLabel:create(GetLocalizeStringBy("key_10112"), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    exploitsBg:addChild(exploitsTitle)
    exploitsTitle:setAnchorPoint(ccp(0.5, 0.5))
    exploitsTitle:setPosition(ccp(126, exploitsBg:getContentSize().height * 0.5))
    exploitsTitle:setColor(ccc3(0xff, 0xf6, 0x00))

    local exploitsIcon = CCSprite:create("images/guild_boss_copy/exploits_icon.png")
    exploitsBg:addChild(exploitsIcon)
    exploitsIcon:setAnchorPoint(ccp(0.5, 0.5))
    exploitsIcon:setPosition(ccp(251, exploitsBg:getContentSize().height * 0.5))

    local exploitsValueLabel = CCRenderLabel:create(GuildBossCopyData.getAttackReward()[3], g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    exploitsBg:addChild(exploitsValueLabel)
    exploitsValueLabel:setAnchorPoint(ccp(0, 0.5))
   	exploitsValueLabel:setPosition(ccp(270, exploitsBg:getContentSize().height * 0.5))
end

function loadKill( ... )
	if _fightInfo.kill == "0" then
		return
	end
	local richInfo = {
		labelDefaultSize = 18,
		lineAlignment = 2,
		labelDefaultColor = ccc3(0x78, 0x25, 0x00),
		defaultRenderType = type_shadow,
		elements = {
			{
				["type"] = "CCSprite",
				image = "images/guild_boss_copy/exploits_icon.png",
			},
			{	
				["type"] = "CCRenderLabel",
				text = GuildBossCopyData.getKillReward()[3],
				color = ccc3(0xff, 0xff, 0xff) 
			}
		}
	}
	local label = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10113"), richInfo)
	_dialog:addChild(label)
	label:setAnchorPoint(ccp(0.5, 0.5))
	label:setPosition(ccp(_dialog:getContentSize().width * 0.5, 141))
end

function laodMenu( ... )
    local menu = CCMenu:create()
    _dialog:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(_dialog:getContentSize())
    menu:setTouchPriority(_touchPriority - 5)

    local confirmItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(140,70), GetLocalizeStringBy("key_10114"), ccc3(255,222,0))
    menu:addChild(confirmItem)
    confirmItem:setAnchorPoint(ccp(0.5, 0.5))
    confirmItem:setPosition(ccp(_dialog:getContentSize().width * 0.5, 70))
    confirmItem:registerScriptTapHandler(closeCallback)
end

function initData( p_fightInfo, p_groupCopyId, p_pointCopyIndex, p_closeCallback, p_touchPriority )
	_fightInfo = p_fightInfo
	_closeCallback = p_closeCallback
    _pointCopyIndex = p_pointCopyIndex
    _groupCopyId = p_groupCopyId
	_touchPriority = p_touchPriority or -700
    _groupCopyDb = DB_GroupCopy.getDataById(p_groupCopyId)
end

function closeCallback( ... )
	if _closeCallback ~= nil then
		_closeCallback()
	end
	close()
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
end

function close( ... )
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end
