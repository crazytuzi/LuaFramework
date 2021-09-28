-- Filename: HeroFightSimple.lua
-- Author: fang
-- Date: 2013-10-18
-- Purpose: 该文件用于: 武将战斗力简单计算方式

module("HeroFightSimple", package.seeall)

-- 0: 打开武将原始数据模块
	require "script/model/hero/HeroModel"
-- 1: 打开武将属性数据表
	require "db/DB_Heroes"
-- 2: 打开连携属性数据表
	require "db/DB_Union_profit"
-- 3: 打开觉醒属性数据表
	require "db/DB_Awake_ability"
-- 4: 打开装备属性数据表
	require "db/DB_Item_arm"
-- 5: 打开名将属性数据表
	require "script/ui/star/StarUtil"
-- 6: 打开宠物属性数据表
	require "script/ui/pet/PetUtil"
-- 打开判断武将是否在阵上的方法库 HeroPublicLua
	require "script/ui/hero/HeroPublicLua"


local m_hp=1  				-- 生命
local m_physicalAttack=2 		-- 物理攻击(deprecated)
local m_magicAttack=3			-- 法术攻击(deprecated)
local m_physicalDefend=4		-- 物理防御
local m_magicDefend=5			-- 法术防御
local m_command=6				-- 统帅
local m_strength=7			-- 武力
local m_intelligence=8		-- 智力
local m_generalAttack=9		-- 通用攻击
-- 类型属性影射表
local _attributesMap = {
	{1, 11, "hp", "baseLife", "lifePL"},						
	{2, 12, "deprecated"},
	{3, 13, "deprecated"},
	{4, 14, "physical_defend", "basePhyDef", "phyDefPL"},	
	{5, 15, "magic_defend", "baseMagDef", "magDefPL"},	
	{6, 16, "command", "XXXXXX", "XXXXXX"},
	{7, 17, "strength", "XXXXXX", "XXXXXX"},
	{8, 18, "intelligence", "XXXXXX", "XXXXXX"},
	{9, 19, "general_attack", "baseGenAtt", "genAttPL"},
}

-- 武将本身基础值
function getHeroValue(tParam)
-- 返回值，初始化为0
	local nBaseValue=0
	local db_hero = tParam.db_hero
	-- 武将进阶次数
	local evolve_level = 0
	if tParam.evolve_level then
		evolve_level = tonumber(tParam.evolve_level)
	end
	local nHeroLevel = tonumber(tParam.level)
-- 进阶基础值系数 advanced_base_coefficient
-- 武将基础通用攻击 base_general_attack
-- 进阶初始等级 advanced_begin_lv
-- 进阶间隔等级 advanced_interval_lv
	local map=tParam.map
	local base = db_hero["base_"..map[3]]
	local grow=0
	if db_hero[map[3].."_grow"] then
		grow = db_hero[map[3].."_grow"]
	end
	nBaseValue = (base*(1+db_hero.advanced_base_coefficient*evolve_level/10000))
		+ grow*evolve_level/200*((db_hero.advanced_begin_lv-1)*2+ db_hero.advanced_interval_lv*(evolve_level-1))
		+ (nHeroLevel-1)*grow/100

	return nBaseValue
end

function getAllForceValuesByHid(hid)
	require "script/model/hero/HeroModel"
	local hero_data = HeroModel.getHeroByHid(hid)
	

	return getAllForceValues(hero_data)
end

function getAllForceValues(tParam)
	if not (tParam and tParam.htid) then
		return {}
	end

	local tArgs = {}
	tArgs = table.hcopy(tParam, tArgs)
	if not tArgs.db_hero then
		tArgs.db_hero = DB_Heroes.getDataById(tParam.htid)
	end
	-- 判断该武将是否在阵上
	local tRetValue={}
	-- 生命
	tArgs.map = _attributesMap[m_hp]
	tRetValue.life = getHeroValue(tArgs)
	-- 统帅
	tArgs.map = _attributesMap[m_command]
	tRetValue.command = getHeroValue(tArgs)/100
	-- 武力
	tArgs.map = _attributesMap[m_strength]
	tRetValue.strength = getHeroValue(tArgs)/100
	-- 智力
	tArgs.map = _attributesMap[m_intelligence]
	tRetValue.intelligence = getHeroValue(tArgs)/100
	-- 通用攻击
	tArgs.map = _attributesMap[m_generalAttack]
	tRetValue.generalAttack = getHeroValue(tArgs)
	-- 法防
	tArgs.map = _attributesMap[m_magicDefend]
	tRetValue.magicDefend = getHeroValue(tArgs)
	-- 物防
	tArgs.map = _attributesMap[m_physicalDefend]
	tRetValue.physicalDefend = getHeroValue(tArgs)

	tRetValue.life = tRetValue.life*(1+(tRetValue.command-50)/100)
-- 计算战斗力
	tRetValue.fightForce=tRetValue.generalAttack + tRetValue.magicDefend + tRetValue.physicalDefend
	tRetValue.fightForce=tRetValue.fightForce + tRetValue.life/5 
	local vitalSum = (tRetValue.command+tRetValue.strength+tRetValue.intelligence)-150
	if vitalSum < 0 then
		vitalSum = 0
	end
	tRetValue.fightForce=tRetValue.fightForce+ vitalSum*10

	if tRetValue.fightForce < 5 then
		tRetValue.fightForce = 5
	end
	tRetValue.fightForce = tRetValue.fightForce
	tRetValue.vitalStat = tRetValue.fightForce

	for k, v in pairs(tRetValue) do
		tRetValue[k] = math.floor(v)
	end

	return tRetValue
end
