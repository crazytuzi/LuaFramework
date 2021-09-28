-- FileName: HeroAffixFlush.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("HeroAffixFlush", package.seeall)
require "script/model/affix/EquipAffixModel"
require "script/model/affix/TreasAffixModel"
require "script/ui/item/GodWeaponItemUtil"
require "script/model/hero/HeroModel"
--[[
	@des:更换武将时属性刷新方法
--]]
function onChangeHero(p_hid)
	if p_hid then
		onChangeEquip(p_hid)
		onChangeTreas(p_hid)
		onChangeGodWeapon(p_hid)
		onChangeFightSoul(p_hid)
	end
end

--[[
	@des:更换装备时属性刷新方法
--]]
function onChangeEquip(p_hid)
	if p_hid then
		EquipAffixModel.getAffixByHid(p_hid, true)
	end
end

--[[
	@des:更换宝物时属性刷新
--]]
function onChangeTreas(p_hid)
	if p_hid then
		TreasAffixModel.getAffixByHid(p_hid, true)
	end
end

--[[
	@des:更换神兵时需要刷新的属性
--]]
function onChangeGodWeapon( p_hid )
	if p_hid then
		GodWeaponItemUtil.getGodWeaponFightScore(p_hid, true)
	end
end

--[[
	@:更换战魂时需要刷新的属性
--]]
function onChangeFightSoul( p_hid )
	if p_hid then
		HeroModel.getHeroFightSoulAffix( p_hid, true )
	end
end

