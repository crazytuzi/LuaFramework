local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------------
local MColor = require "src/config/FontColor"
-----------------------------------------------------------------------------------
-- 职业代号
eWhole = 0      -- 全系
eWarrior = 1    -- 战士
eEnchanter = 2  -- 魔法师
eTaoist = 3     -- 道士

tSchool = {
	[eWhole] = game.getStrByKey("general"),
	[eWarrior] = game.getStrByKey("zhanshi"),
	[eEnchanter] = game.getStrByKey("fashi"),
	[eTaoist] = game.getStrByKey("daoshi"),
}

school = function(self, id)
	return tSchool[id]
end
-----------------------------------------------------------------------------------
-- 性别代号
eSexWhole = 0
eMale = 1 -- 男性
eFemale = 2 -- 女性

tRoleHead = {
	[eWarrior] = {
		[eMale] = 1,
		[eFemale] = 4,
	},
	
	[eEnchanter] = {
		[eMale] = 2,
		[eFemale] = 5,
	},
	
	[eTaoist] = {
		[eMale] = 3,
		[eFemale] = 6,
	},
}

roleHead = function(self, school, sex)
	return "res/mainui/head/" .. tRoleHead[school][sex] .. ".png"
end

tSexName = {
	[eSexWhole] = game.getStrByKey("general"),
	[eMale] = game.getStrByKey("man"),
	[eFemale] = game.getStrByKey("female"),
}

sexName = function(self, sex)
	return tSexName[sex] or ""
end
-----------------------------------------------------------------------------------
-- 装备加成属性代号
eHP = 1 -- "生命"
eMP = 2 -- "魔法"
ePAttack = 3 -- "物理攻击"
eMAttack = 4 -- "魔法攻击"
eTAttack = 5 -- "道术攻击"
ePDefense = 6 -- "物理防御"
eMDefense = 7 -- "魔法防御"
eMingZhong = 8 -- "命中"
eShanBi = 9 -- "闪避"
eBaoji = 10 -- "暴击"
eRenXing = 11 -- "韧性"
eChuanTou = 12 -- "穿透"
eMianShang = 13 -- "免伤"
eLuck = 14 -- "幸运"
eMoveSpeed = 15 -- "移动速度"

local tAttrIdToName = 
{
	-- 属性代号
	[eHP] = game.getStrByKey("hp"),
	[eMP] = game.getStrByKey("mp"),
	[ePAttack] = game.getStrByKey("physical_attack_s"),
	[eMAttack] = game.getStrByKey("magic_attack_s"),
	[eTAttack] = game.getStrByKey("taoism_attack_s"),
	[ePDefense] = game.getStrByKey("physical_defense_s"),
	[eMDefense] = game.getStrByKey("magic_defense_s"),
	[eMingZhong] = game.getStrByKey("my_hit"),
	[eShanBi] = game.getStrByKey("dodge"),
	[eBaoji] = game.getStrByKey("strike"),
	[eRenXing] = game.getStrByKey("my_tenacity"),
	[eChuanTou] = game.getStrByKey("hu_shen_rift"),
	[eMianShang] = game.getStrByKey("hu_shen"),
	[eLuck] = game.getStrByKey("luck"),
	[eMoveSpeed] = game.getStrByKey("move") .. game.getStrByKey("speed"),
}

attrName = function(id)
	return tAttrIdToName[id] or ""
end

isRangeAttr = function(id)
	if id then
		return id >= ePAttack and id <= eMDefense
	end
end


eCombatAttrList = {
	ePAttack,
	eMAttack,
	eTAttack,
	ePDefense,
	eMDefense,
}

local tCombatAttr = {
	[ePAttack] = game.getStrByKey("physical_attack_s"),
	[eMAttack] = game.getStrByKey("magic_attack_s"),
	[eTAttack] = game.getStrByKey("taoism_attack_s"),
	[ePDefense] = game.getStrByKey("physical_defense_s"),
	[eMDefense] = game.getStrByKey("magic_defense_s"),
}

combatAttr = function(self, id)
	return tCombatAttr[id] or ""
end
-----------------------------------------------------------------------------------
local tSchoolAttack = {
	[eWarrior] = ePAttack,
	[eEnchanter] = eMAttack,
	[eTaoist] = eTAttack,
}
-- 职业攻击
schoolAttack = function(self, school)
	return tSchoolAttack[school]
end

local tSchoolDefense = {
	[eWarrior] = ePDefense,
	[eEnchanter] = eMDefense,
	[eTaoist] = eMDefense,
}
-- 职业防御
schoolDefense = function(self, school)
	return tSchoolDefense[school]
end
-----------------------------------------------------------------------------------
-- 装备代号
eWeapon = 1	    -- 武器
eRing = 2		-- 戒指
eNecklace = 3	-- 项链
eShoe = 4	    -- 鞋子
eClothing = 5	-- 衣服
eCuff = 6		-- 护腕
eHelmet = 7	    -- 头盔
eBelt = 8	    -- 腰带
eSuit = 9	    -- 时装
eMedal = 12	    -- 勋章

local tEquipName = {
	[eWeapon] = game.getStrByKey("weapon"),
	[eRing] = game.getStrByKey("goldRing"),
	[eNecklace] = game.getStrByKey("necklace"),
	[eShoe] = game.getStrByKey("shoe"),
	[eClothing] = game.getStrByKey("clothing"),
	[eCuff] = game.getStrByKey("cuff"),
	[eHelmet] = game.getStrByKey("helmet"),
	[eBelt] = game.getStrByKey("belt"),
	[eSuit] = game.getStrByKey("suit"),
	[eMedal] = game.getStrByKey("medal"),
}

equipName = function(self, id)
	return tEquipName[id]
end
-----------------------------------------------------------------------------------
_G.Mconvertor = M
-----------------------------------------------------------------------------------