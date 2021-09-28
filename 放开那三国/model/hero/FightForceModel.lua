-- Filename: FightForceModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 战斗力计算模型

module("FightForceModel", package.seeall)

require "script/model/affix/HeroAffixModel"
require "script/model/affix/AffixDef"

local _heroAffix = {}
function getFightForce( ... )
	RecordTime("getFightForce", 0)
	local formation = DataCache.getFormationInfo()
	local fightForce = 0
	if formation == nil then
		return fightForce
	end
	for k,v in pairs(formation) do
		if tonumber(v) > 0 then
			RecordTime("getFightForce:" .. v, 0)
			fightForce = fightForce + getHeroFightForce(v)
			RecordTime("getFightForce:" .. v, 1)
		end
	end
	RecordTime("getFightForce", 1)
	printRecordTime()
	clearRecordTime()
	return fightForce
end

function getHeroFightForce( p_hid )
	local formationAffix = p_formationAffix or {}
	local heroAffix = HeroAffixModel.getAffixByHid(p_hid)

	local heroLevel = tonumber(HeroModel.getHeroByHid(p_hid).level)
	for i=1,200 do
		heroAffix[i] = heroAffix[i] or 0
	end
	--战斗力计算
	-- 统帅
	local command = math.floor(heroAffix[6] + heroAffix[6]*(heroAffix[16]/10000))/100
	-- 武力
	local strength = math.floor(heroAffix[7] + heroAffix[7]*(heroAffix[17]/10000))/100
	-- 智力
	local intelligence = math.floor(heroAffix[8] + heroAffix[8]*(heroAffix[18]/10000))/100
	-- 生命
	local life = math.floor((heroAffix[1] + heroAffix[1]*(heroAffix[11]/10000) + heroAffix[51]) * (1+(heroAffix[6]-5000)/10000))
	-- 通用攻击
	local generalAttack = math.floor(heroAffix[9] + heroAffix[9]*(heroAffix[19]/10000) + heroAffix[100])
	-- 法防
	local magicDefend = math.floor(heroAffix[5] + heroAffix[5]*(heroAffix[15]/10000) + heroAffix[55])
	-- 物防
	local physicalDefend = math.floor(heroAffix[4] + heroAffix[4]*(heroAffix[14]/10000) + heroAffix[54])
	-- 物攻
	local physicalAttack  = math.floor(heroAffix[2] + heroAffix[2]*(heroAffix[12]/10000))
	-- 法攻
	local magicAttack = math.floor(heroAffix[3] + heroAffix[3]*(heroAffix[13]/10000))
	--战斗力
	local heroFightForce = generalAttack + physicalAttack + magicAttack + physicalDefend + magicDefend + math.floor(life/5) + (command + strength + intelligence)*10 - 1500
	-- 新总战斗力=原总战斗力+int(人物等级*PvP属性系数*（PvP伤害增益+PvP免伤增益）/60000)
	-- PvP属性系数=5099
	heroFightForce = heroFightForce + math.floor(heroLevel*5099*(heroAffix[101] + heroAffix[102])/60000)
	--穿透属性 int(武将等级*穿透属性/4)
	heroFightForce = heroFightForce + math.floor(heroLevel*heroAffix[108]/4)
	--中毒和灼烧的战斗力
	heroFightForce = heroFightForce + math.floor((heroAffix[86] + heroAffix[87] + heroAffix[88] + heroAffix[89])*0.5)
	heroFightForce = heroFightForce + math.floor((heroAffix[96] + heroAffix[97] + heroAffix[98] + heroAffix[99])*heroLevel*500/10000)
	--士气战斗力
	heroFightForce = heroFightForce + math.floor(heroAffix[109]*heroLevel*3)
	--最终伤害，和最终免伤
	heroFightForce = heroFightForce + math.floor((heroAffix[29]+heroAffix[30])/2)
	print("getHeroFightForce:"..p_hid.."——", heroFightForce)
	return math.floor(heroFightForce)
end

--[[
	@des: 得到武将属性数据
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue
	}
--]]
function getHeroDisplayAffix( p_hid )
	
	local heroAffix = HeroAffixModel.getAffixByHid(p_hid)
	for i=1,200 do
		heroAffix[i] = heroAffix[i] or 0
	end
	heroAffix = getAffixDesPlayValue(heroAffix)
	--数值取整
	for i=1,200 do
		heroAffix[i] = math.floor(heroAffix[i]) or 0
	end

	return heroAffix
end

--[[
	@des: 得到武将属性数据
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue
	}
--]]
function getHeroDisplayAffixByHeroInfo( p_heroInfo )
	local heroAffix = HeroAffixModel.getHeroAllAffixByInfo(p_heroInfo)
	for i=1,200 do
		heroAffix[i] = heroAffix[i] or 0
	end
	heroAffix = getAffixDesPlayValue(heroAffix)
	--数值取整
	for i=1,200 do
		heroAffix[i] = math.floor(heroAffix[i]) or 0
	end
	return heroAffix
end

--[[
	@des: 得到武将的基础属性数据
	@parm: p_htid 武将模板id
	@ret:{
		affixId => affixValue
	}
--]]
function getHeroBaseDisplayAffix( p_htid )
	local heroAffix = HeroAffixModel.getHeroBaseAffixByHtid(p_htid)
	for i=1,200 do
		heroAffix[i] = heroAffix[i] or 0
	end
	heroAffix = getAffixDesPlayValue(heroAffix)
	--数值取整
	for i=1,200 do
		heroAffix[i] = math.floor(heroAffix[i]) or 0
	end

	return heroAffix
end

--[[
	@des:根据属性计算属性显示值
	@parm:{
		affixId => affixValue
	}
	@ret:{
		affixId => affixDesplayValue
	}
--]]
function getAffixDesPlayValue( p_affixValue )
	local heroAffix = {}
	table.hcopy(p_affixValue, heroAffix)
	-- 统帅
	heroAffix[6] = (heroAffix[6] + heroAffix[6]*(heroAffix[16]/10000))/100
	-- 武力
	heroAffix[7] = (heroAffix[7] + heroAffix[7]*(heroAffix[17]/10000))/100
	-- 智力
	heroAffix[8] = (heroAffix[8] + heroAffix[8]*(heroAffix[18]/10000))/100
	-- 生命
	heroAffix[1] = (heroAffix[1] + heroAffix[1]*(heroAffix[11]/10000) + heroAffix[51]) * (1+(heroAffix[6]-50)/100)
	-- 通用攻击
	heroAffix[9] = heroAffix[9] + heroAffix[9]*(heroAffix[19]/10000) + heroAffix[100]
	-- 法防
	heroAffix[5] = heroAffix[5] + heroAffix[5]*(heroAffix[15]/10000) + heroAffix[55]
	-- 物防
	heroAffix[4] = heroAffix[4] + heroAffix[4]*(heroAffix[14]/10000) + heroAffix[54]
	-- 物攻
	heroAffix[2]  = heroAffix[2] + heroAffix[2]*(heroAffix[12]/10000)
	-- 法攻
	heroAffix[3] = heroAffix[3] + heroAffix[3]*(heroAffix[13]/10000)

	return heroAffix
end

--[[
	@des 	:得到法防、物防、攻击、声明的改变值
	@param 	:武将hid
	@return :封装好的table
--]]
function dealParticularValues(p_hid)
	-- local overAllValues = getAllForceValuesByHid(tonumber(p_hid))
	local overAllValues = FightForceModel.getHeroDisplayAffix(p_hid)
	printTable("hero affixs info ".. p_hid, overAllValues)
	local returnTable = {}
	--生命
	returnTable.hp = tonumber(overAllValues[AffixDef.LIFE])
	--攻击
	returnTable.gen_att = tonumber(overAllValues[AffixDef.GENERAL_ATTACK])
	--物防
	returnTable.phy_def = tonumber(overAllValues[AffixDef.PHYSICAL_DEFEND])
	--法防
	returnTable.magic_def = tonumber(overAllValues[AffixDef.MAGIC_DEFEND])

	return returnTable
end
