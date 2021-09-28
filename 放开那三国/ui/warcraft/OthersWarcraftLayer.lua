-- Filename: OthersWarcraftLayer.lua
-- Author: bzx
-- Date: 2014-11-21
-- Purpose: 阵法

module("OthersWarcraftLayer", package.seeall)

require "script/ui/warcraft/WarcraftLayer"
require "script/ui/warcraft/WarcraftData"

local _layer
local _warcraftData
local _formationInfo
local _warcraftDatas

function init(warcraftData, formationInfo)
	_warcraftData = warcraftData or RivalInfoData.getUsedWarcraftData()
	_formationInfo = formationInfo or RivalInfoData.getFormationInfoMap()
	_warcraftDatas = WarcraftData.getWarcraftDatas()
end

function creaateByWarcraftData(warcraftData, formationInfo)
	init(warcraftData, formationInfo)
	_layer = CCLayer:create()--CCLayerColor:create(ccc4(255, 0, 0, 100))
	loadTip()
	loadWarcraftName()
	loadWarcraftInfo()
	return _layer
end

function loadTip( ... )
	local tip = CCRenderLabel:create(GetLocalizeStringBy("key_8408"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_layer:addChild(tip)
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setPosition(ccp(g_winSize.width / g_fScaleX * 0.5, 600))
end

function loadWarcraftName( ... )
	local bg = CCScale9Sprite:create(CCRectMake(16, 18, 4, 5), "images/warcraft/warcraft_bg.png")
	_layer:addChild(bg)
	bg:setPreferredSize(CCSizeMake(443, 88))
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccp(g_winSize.width / g_fScaleX * 0.5, 530))

	local warcraftIcon = WarcraftLayer.createWarcraftIcon(_warcraftData.id)
	bg:addChild(warcraftIcon)
	warcraftIcon:setAnchorPoint(ccp(0.5, 0.5))
	warcraftIcon:setPosition(ccp(82, bg:getContentSize().height * 0.5))

	local warcraftName = WarcraftLayer.createWarcraftName(_warcraftData.id)
	bg:addChild(warcraftName)
	warcraftName:setAnchorPoint(ccp(0.5, 0.5))
	warcraftName:setPosition(ccp(222, bg:getContentSize().height * 0.5))

	local level = CCSprite:create("images/boss/LV.png")
	bg:addChild(level)
	level:setAnchorPoint(ccp(0, 0.5))
	level:setPosition(ccp(321, bg:getContentSize().height * 0.5))

	local levelCount = CCRenderLabel:create(tostring(_warcraftData.level), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	bg:addChild(levelCount)
	levelCount:setAnchorPoint(ccp(0, 0.5))
	levelCount:setPosition(ccp(371, bg:getContentSize().height * 0.5))
	levelCount:setColor(ccc3(0xff, 0xf6, 0x00))

end

function loadWarcraftInfo( ... )
	local warcraftInfoBg = CCScale9Sprite:create("images/warcraft/warcraft_formation_bg.png")
	_layer:addChild(warcraftInfoBg)
	warcraftInfoBg:setPreferredSize(CCSizeMake(443, 441))
	warcraftInfoBg:setAnchorPoint(ccp(0.5, 0))
	warcraftInfoBg:setPosition(ccp(g_winSize.width / g_fScaleX * 0.5, 20))
	
	local warcraftDB = parseDB(DB_Method.getDataById(_warcraftData.id))
	local affixType = WarcraftData.getAffixType(_warcraftData.id)
	local affixValue = WarcraftData.getAffixValue(_warcraftData.id, _warcraftData.level)

	if warcraftDB.needmethodlv <= _warcraftData.level then
		local effect = WarcraftLayer.createWarcraftEffect(_warcraftData.id)
		warcraftInfoBg:addChild(effect)
		effect:setAnchorPoint(ccp(0.5, 0.5))
		effect:setPosition(ccpsprite(0.5, 0.5, warcraftInfoBg))
		effect:setScale(0.76)
	end
	
	for i=1, 6 do
		local light = CCSprite:create("images/warcraft/di.png")
		warcraftInfoBg:addChild(light)
		light:setAnchorPoint(ccp(0.5, 0))
		light:setPosition(ccp(65 + (i - 1) % 3 * 156, 260 - math.floor((i - 1) / 3) * 210))

		local box = CCSprite:create("images/forge/hero_bg.png")
		warcraftInfoBg:addChild(box)
		box:setAnchorPoint(ccp(0.5, 0.5))
		box:setPosition(ccp(65 + (i - 1) % 3 * 156, 360 - math.floor((i - 1) / 3) * 210))
		box:setScale(0.7)

		if warcraftDB.frame[i] ~= nil then
			local affixBgImages = {"atk_bg.png", "def_bg.png", "hp_bg.png"}
			local affixNameImages = {"atk_title.png", "def_title.png", "hp_title.png"}
			local affixBg = CCSprite:create("images/warcraft/" .. affixBgImages[affixType[i]])
			warcraftInfoBg:addChild(affixBg, 20)
			affixBg:setAnchorPoint(ccp(0.5, 0.5))
			affixBg:setPosition(ccp(70 + (i - 1) % 3 * 156, 240 - math.floor((i - 1) / 3) * 210))
			local richInfo = {}
			richInfo.lineAlignment = 2
			richInfo.elements = {
				{
			 		["type"] = "CCSprite",
			 		["image"] = "images/warcraft/" .. affixNameImages[affixType[i]]
				},
				{
					["type"] = "CCRenderLabel",
					["text"] = "+" .. tostring(affixValue[i]),
					["size"] = 18,
					["renderType"] = 2,
					["deltaPoint"] = ccp(-3, 0)
				}
			}
			local affix = LuaCCLabel.createRichLabel(richInfo)
			affixBg:addChild(affix)
			affix:setAnchorPoint(ccp(0.5, 0.5))
			affix:setPosition(ccpsprite(0.39, 0.5, affixBg))
		end

		local seat = CCNode:create()--CCLayerColor:create(ccc4(0xff, 0x00, 0x00, 0xff))
		warcraftInfoBg:addChild(seat, 24)
		seat:setContentSize(CCSizeMake(box:getContentSize().width * box:getScaleX(), box:getContentSize().height * box:getScaleY()))
		seat:setAnchorPoint(box:getAnchorPoint())
		seat:ignoreAnchorPointForPosition(false)
		seat:setPosition(box:getPosition())
		local heroData = _formationInfo[i] or _formationInfo[tostring(i - 1)]
		if heroData ~= nil then
			heroData.dress = heroData.dress or {}
			local hero = HeroSprite.createHeroSpriteByHeroData(heroData)
			warcraftInfoBg:addChild(hero)
			hero:setAnchorPoint(ccp(0.5, 0.5))
			hero:setPosition(ccp(box:getPositionX(), box:getPositionY() - 12))
			hero:setScale(0.7)
		end
	end
end
