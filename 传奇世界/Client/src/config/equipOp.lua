local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MColor = require "src/config/FontColor"
local Mconvertor = require "src/config/convertor"
local MpropOp = require "src/config/propOp"
-----------------------------------------------------------------------------------
-- 装备表
local tPropIdAsKey = getConfigItemByKey("equipCfg", "q_id")
--灵兽表
local tPropRideIdAsKey=getConfigItemByKey("MountDB", "mountId")
-- 获取一个装备的所有信息
local equipItem = function(id)
	--cclog("道具id " .. id)
	if MpropOp.category(id)==21 then
		return tPropRideIdAsKey[id]
	else
		return tPropIdAsKey[id]
	end	
	
end
--------------------------------------------------------------------------------------
-- 着装位置
--[[
佩戴部位:
武器：1  
戒指：2  
项链：3  
鞋子：4  
衣服：5  
手镯：6  
头盔：7  
腰带：8
--]]
kind = function(id)
	-- 没有默认值
	local record = equipItem(id)
	return record and tonumber(record.q_kind) or 1
end

local tCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(id)
		-- 默认值[0, 0]
		local record = equipItem(id)
		if record then
			return tonumber(record.q_attack_min or 0), tonumber(record.q_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(id)
		-- 默认值[0, 0]
		local record = equipItem(id)
		if record then
			return tonumber(record.q_magic_attack_min or 0), tonumber(record.q_magic_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(id)
		-- 默认值[0, 0]
		local record = equipItem(id)
		if record then
			return tonumber(record.q_sc_attack_min or 0), tonumber(record.q_sc_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(id)
		-- 默认值[0, 0]
		local record = equipItem(id)
		if record then
			return tonumber(record.q_defence_min or 0), tonumber(record.q_defence_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(id)
		-- 默认值[0, 0]
		local record = equipItem(id)
		if record then
			return tonumber(record.q_magic_defence_min or 0), tonumber(record.q_magic_defence_max or 0)
		else
			return 0, 0
		end
	end,
}

-- 基础战斗属性值
combatAttr = function(id, name)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tCombatAttrAction[name](id)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tCombatAttrAction[v](id)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end
--------------------------------------------------------
-- 增加HP上限
maxHP = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_max_hp) or 0)
end

-- 增加MP上限
maxMP = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_max_mp) or 0)
end

-- 增加幸运值
luck = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_luck) or 0)
end

-- 增加命中
hit = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_hit) or 0)
end

-- 增加闪避
dodge = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_dodge) or 0)
end

-- 增加暴击
strike = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_crit) or 0)
end

-- 增加韧性
tenacity = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_tenacity) or 0)
end

-- 护身穿透
huShenRift = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_projectDef) or 0)
end

-- 护身
huShen = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_project) or 0)
end

-- 冰冻
freeze = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_benumb) or 0)
end

-- 冰冻抵抗
freezeOppose = function(id)
	-- 默认值为0
	local record = equipItem(id)
	return tonumber((record and record.q_benumbDef) or 0)
end

-- 所属套装id
group = function(id)
	-- 没有默认值
	local record = equipItem(id)
	return record and tonumber(record.q_suidId)
end

-- 是否是套装
isSuit = function(id)
	-- 默认不是套装
	local record = equipItem(id)
	return record and tonumber(record.q_suidId) and tonumber(record.q_suidId) > 0
end

-- 升级后的装备的原型id
evolve = function(id)
	-- 占位值为不能升级
	local record = equipItem(id)
	if record then
		local ret = record.q_levelUpID
		if ret then
			return ret ~= 0 and tonumber(ret) or nil
		end
	end
end

-- 强化激活属性
qiangHuaJiHuo = function(protoId)
	local record = equipItem(protoId)
	return unserialize(record and record.jihuo)
end

-- 极品属性相关

-- 极品属性类型
specialAttrCate = function(protoId)
	local record = equipItem(protoId)
	return record and tonumber(record.q_equipSpecialPropType)
end

-- 极品属性最大层
specialAttrMaxLayer = function(protoId)
	local record = equipItem(protoId)
	return record and tonumber(record.q_equipSpecialNum) or 0
end

-- 极品属性每层增加值
specialAttrEachLayerValue = function(protoId)
	local record = equipItem(protoId)
	return record and tonumber(record.q_AddNumPre) or 0
end
-----------------------------------------------------------------------------------
-- 强化属性表
local tStrengthProp =  getConfigItemByKey("EuipStrengthPropDB", "q_id")
local strengthPropItem = function(id)
	--dump({id=id}, "strengthPropItem")
	return tStrengthProp[id]
end
-----------------------------------------------------------------------------------
-- 强化增加的属性
local tUpStrengthCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(id)
		-- 默认值[0, 0]
		local record = strengthPropItem(id)
		if record then
			return tonumber(record.q_attack_min or 0), tonumber(record.q_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(id)
		-- 默认值[0, 0]
		local record = strengthPropItem(id)
		if record then
			return tonumber(record.q_magic_attack_min or 0), tonumber(record.q_magic_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(id)
		-- 默认值[0, 0]
		local record = strengthPropItem(id)
		if record then
			return tonumber(record.q_sc_attack_min or 0), tonumber(record.q_sc_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(id)
		-- 默认值[0, 0]
		local record = strengthPropItem(id)
		if record then
			return tonumber(record.q_defence_min or 0), tonumber(record.q_defence_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(id)
		-- 默认值[0, 0]
		local record = strengthPropItem(id)
		if record then
			return tonumber(record.q_magic_defence_min or 0), tonumber(record.q_magic_defence_max or 0)
		else
			return 0, 0
		end
	end,
}

-- 基础战斗属性值
upStrengthCombatAttr = function(name, id, strengthLevel)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tUpStrengthCombatAttrAction[name](id, strengthLevel)
		return { ["["] = lower * strengthLevel, ["]"] = upper * strengthLevel }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tUpStrengthCombatAttrAction[v](id, strengthLevel)
			ret[v] = { ["["] = lower * strengthLevel, ["]"] = upper * strengthLevel }
		end
		return ret
	end
end

--------------------------------------------------------
-- 增加HP上限
upStrengthMaxHP = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_max_hp) or 0) * strengthLevel
end

-- 增加MP上限
upStrengthMaxMP = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_max_mp) or 0) * strengthLevel
end

-- 增加幸运值
upStrengthLuck = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_luck) or 0) * strengthLevel
end

-- 增加命中
upStrengthHit = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_hit) or 0) * strengthLevel
end

-- 增加闪避
upStrengthDodge = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_dodge) or 0) * strengthLevel
end

-- 增加暴击
upStrengthStrike = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_crit) or 0) * strengthLevel
end

-- 增加韧性
upStrengthTenacity = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_tenacity) or 0) * strengthLevel
end

-- 护身穿透
upStrengthHuShenRift = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_projectDef) or 0) * strengthLevel
end

-- 护身
upStrengthHuShen = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_project) or 0) * strengthLevel
end

-- 冰冻
upStrengthFreeze = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_benumb) or 0) * strengthLevel
end

-- 冰冻抵抗
upStrengthFreezeOppose = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthPropItem(id)
	return tonumber((record and record.q_benumbDef) or 0) * strengthLevel
end
----------------------------------------------------------
-- 强化消耗表
local tStrengthCost =  getConfigItemByKeys("equipStrengthen", {
	"q_type",
	"q_level",
})
local strengthCostItem = function(id, strengthLevel)
	return tStrengthCost[kind(id)][strengthLevel]
end
-----------------------------------------------------------------------------------
-- 是否达到强化上限
-- RUL -- ReachUpperLimit
local tQuality2StrengthRUL = 
{
	[1] = 20, -- 白色
	[2] = 20, -- 绿色
	[3] = 20, -- 蓝色
	[4] = 20, -- 紫色
	[5] = 20, -- 橙色
}
isStrengthRUL = function(id, strengthLv, quality)
	if id >= 30004 and id <= 30006 then return true end -- 勋章
	return strengthLv >= (tQuality2StrengthRUL[quality] or 0)
end

-- 强化等级上限
upStrengthRUL = function(id, quality)
	return tQuality2StrengthRUL[quality] or 0
end

-- 强化所需金币
upStrengthCoinNeed = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	return record and tonumber(record.q_needMoney) or 0
end

-- 强化所需材料及其数量
upStrengthMaterialNeed = function(id, strengthLevel)
	local record = strengthCostItem(id, strengthLevel)
	--dump(record, "record")
	
	return record and tonumber(record.q_needMatID) or 0, record and tonumber(record.q_needMatNum) or 0
end

-- 强化成功概率
upStrengthPOS = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	local probability = tonumber(record.q_sucRate) or 0
	if probability < 30 then
		return probability, "很低", MColor.red
	elseif probability < 60 then
		return probability, "较低", MColor.orange
	elseif probability < 80 then
		return probability, "较高", MColor.blue
	elseif probability < 100 then
		return probability, "很高", MColor.green
	else
		return probability, "必成", MColor.green
	end
end

-- 强化提升几率道具
upStrengthPPOSMaterialNeed = function(id, strengthLevel)
	local record = strengthCostItem(id, strengthLevel)
	return record and tonumber(record.q_needSpecailMatID) or 0, record and tonumber(record.q_needSpecailMatNum) or 0
end

-- 传承所需材料及其数量
upStrengthInheritMaterialNeed = function(id, strengthLevel)
	local record = strengthCostItem(id, strengthLevel)
	return record and tonumber(record.q_needInheritMatID) or 0, record and tonumber(record.q_needInheritMatNum) or 0
end

-- 传承所需金币
upStrengthInheritCoinNeed = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	return (record and record.q_inheritNeedMoney) or 0
end

-- 免费传承掉级
upStrengthInheritLoseLv = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	return (record and record.q_freeCostLevel) or 0
end

-- 强化过的装备分解返还金币
upStrengthCoinRet = function(id, strengthLevel)
	-- 默认值为0
	local ret = {}
	local record = strengthCostItem(id, strengthLevel)
	if record ~= nil then
		ret = unserialize(record.q_smelter)
	end
	return ret[999998] or 0
end

-- 强化返还的材料
upStrengthMaterialRet = function(id, strengthLevel)
	local ret = {}
	
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	if record ~= nil then
		ret = unserialize(record.q_smelter)
		ret[999998] = nil
	end
	return ret
end

-- 拍卖行寄售附加的价格上下限
upStrengthConsignPrice = function(id, strengthLevel)
	-- 默认值为0
	local record = strengthCostItem(id, strengthLevel)
	if record ~= nil then
		return tonumber(record.Min_price) or 0, tonumber(record.Max_price) or 0
	else
		return 0, 0
	end
end
----------------------------------------------------------
-- 升级表
local tPromotion = getConfigItemByKey("equipPromotion", "q_id")
local promotionItem = function(id)
	return tPromotion[id]
end
-----------------------------------------------------------------------------------
-- 是否达到等级上限
-- RUL -- ReachUpperLimit
isLevelRUL = function(id)
	--local MpropOp = require "src/config/propOp"
	--dump(evolve(id), "evolve(id)")
	return not evolve(id)
	--local equipLevel = MpropOp.levelLimits(id)
	--return equipLevel > 0 and not promotionItem(id, equipLevel)
end

-- 升级所需材料
upLevelMaterialNeed = function(id)
	local record = promotionItem(id)
	return record.q_needMatID, record.q_needMatNum
end

-- 升级所需金币
upLevelCoinNeed = function(id)
	-- 默认值为0
	local record = promotionItem(id)
	return (record and record.q_needMoney) or 0
end

-- 升级所需角色等级
upLevelRoleLvNeed = function(id)
	local record = promotionItem(id)
	return record and record.q_needLevel
end
--------------------------------------------------------------------------------------
-- 套装集表
local tSuitSet = getConfigItemByKeys("suitSet", {
	"q_sex",
	"q_groupID",
})
local suitSetItem = function(protoId)
	local MpropOp = require "src/config/propOp"
	local groupId = group(protoId)
	local my_sex = MRoleStruct:getAttr(PLAYER_SEX)
	local sex = MpropOp.sexLimits(protoId)
	local target_sex = sex == Mconvertor.eSexWhole and my_sex or sex
	
	--dump({ protoId=protoId, groupId=groupId, sex=sex, my_sex=my_sex, target_sex=target_sex })
	local record = tSuitSet[target_sex][groupId]
	return record
end

suitSet = function(protoId)
	local record = suitSetItem(protoId)
	return unserialize((record and record.q_set) or "{}")
end

suitName = function(protoId)
	local record = suitSetItem(protoId)
	return record and tostring(record.q_name2) or "神秘套装"
end

suitIcon = function(protoId)
	local record = suitSetItem(protoId)
	return record and tonumber(record.q_name) or 1005
end
-----------------------------------------------------------------------------------
-- 套装属性表
local tSuitProp = getConfigItemByKey("EquipSuitDB", {
	"q_suidId",
	"q_suitNum",
})

local suitPropItem = function(suit_id, suit_num)
	return tSuitProp[suit_id][suit_num]
end
--------------------------------------------------------------------------------------
local tSuitCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(suit_id, suit_num)
		-- 默认值[0, 0]
		local record = suitPropItem(suit_id, suit_num)
		if record then
			return tonumber(record.q_attack_min or 0), tonumber(record.q_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(suit_id, suit_num)
		-- 默认值[0, 0]
		local record = suitPropItem(suit_id, suit_num)
		if record then
			return tonumber(record.q_magic_attack_min or 0), tonumber(record.q_magic_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(suit_id, suit_num)
		-- 默认值[0, 0]
		local record = suitPropItem(suit_id, suit_num)
		if record then
			return tonumber(record.q_sc_attack_min or 0), tonumber(record.q_sc_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(suit_id, suit_num)
		-- 默认值[0, 0]
		local record = suitPropItem(suit_id, suit_num)
		if record then
			return tonumber(record.q_defence_min or 0), tonumber(record.q_defence_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(suit_id, suit_num)
		-- 默认值[0, 0]
		local record = suitPropItem(suit_id, suit_num)
		if record then
			return tonumber(record.q_magic_defence_min or 0), tonumber(record.q_magic_defence_max or 0)
		else
			return 0, 0
		end
	end,
}

-- 基础战斗属性值
suitCombatAttr = function(name, suit_id, suit_num)
	local lower, upper
	if type(name) == "number" then
		local record = suitPropItem(suit_id, suit_num)
		lower, upper = tSuitCombatAttrAction[name](suit_id, suit_num)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tSuitCombatAttrAction[name](suit_id, suit_num)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end

-- 增加HP上限
suitMaxHP = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_max_hp) or 0)
end

-- 增加MP上限
suitMaxMP = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_max_mp) or 0)
end

-- 增加幸运值
suitLuck = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_luck) or 0)
end

-- 增加命中
suitHit = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_hit) or 0)
end

-- 增加闪避
suitDodge = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_dodge) or 0)
end

-- 增加暴击
suitStrike = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_crit) or 0)
end

-- 增加韧性
suitTenacity = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_tenacity) or 0)
end

-- 护身穿透
suitHuShenRift = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_projectDef) or 0)
end

-- 护身
suitHuShen = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_project) or 0)
end

-- 冰冻
suitFreeze = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_benumb) or 0)
end

-- 冰冻抵抗
suitFreezeOppose = function(suit_id, suit_num)
	-- 默认值为0
	local record = suitPropItem(suit_id, suit_num)
	return tonumber((record and record.q_benumbDef) or 0)
end
-----------------------------------------------------------------------------------
-- 极品属性表
local tSpecial = getConfigItemByKeys("EquipSpecialPropDB", {"q_job", "__"})
local tSpecialMap = 
{
	[Mconvertor.eHP] = {"q_max_hp_min", "q_max_hp_max"},
	[Mconvertor.ePAttack] = {"q_attack_min", "q_attack_max"},
	[Mconvertor.eMAttack] = {"q_magic_attack_min", "q_magic_attack_max"},
	[Mconvertor.eTAttack] = {"q_sc_attack_min", "q_sc_attack_max"},
	[Mconvertor.ePDefense] = {"q_defence_min", "q_defence_max"},
	[Mconvertor.eMDefense] = {"q_magic_defence_min", "q_magic_defence_max"},
	[Mconvertor.eMingZhong] = {"q_hit_min", "q_hit_max"},
	[Mconvertor.eShanBi] = {"q_dodge_min", "q_dodge_max"},
	[Mconvertor.eBaoji] = {"q_crit_min", "q_crit_max"},
	[Mconvertor.eRenXing] = {"q_tenacity_min", "q_tenacity_max"},
}

specialCfgKey = function(attrID)
	return tSpecialMap[attrID]
end

-- 获取一条记录
specialItem = function(id, attrID, attrValue)
	local attrValue = tonumber(attrValue)
	if attrValue == nil then return end
	
	local MpropOp = require "src/config/propOp"
	local school = MpropOp.schoolLimits(id)
	local cate = tSpecial[school]
	if type(cate) ~= "table" then return end
	
	if attrID == nil then return end
	
	local keys = specialCfgKey(attrID)
	if keys == nil then return end
	
	for k, v in pairs(cate) do
		local min, max = tonumber(v[keys[1]]), tonumber(v[keys[2]])
		if min ~= nil and attrValue >= min and max ~= nil and attrValue <= max then
			return v
		end
	end
end

local tSpecialColor = 
{
	[1] = MColor.green,
	[2] = MColor.blue,
	[3] = MColor.purple,
	[4] = MColor.orange,
	
}
-- 极品属性颜色
specialColor = function(record)
	if record ~= nil then
		local qulity = tonumber(record.q_qulity)
		if qulity ~= nil then
			return tSpecialColor[qulity] or MColor.red
		end
	end
	
	return MColor.red
end
-----------------------------------------------------------------------------------

