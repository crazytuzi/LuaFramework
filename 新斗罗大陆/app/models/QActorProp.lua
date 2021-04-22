--
-- Author: wkwang
-- Date: 2015-09-18
--
local QActorProp = class("QActorProp")

local _trace = trace
local _logFunc = nil
local trace = function(param1, param2)
	_trace(param1, param2)

	if _logFunc then
		_logFunc(param1)
	end
end
function QActorProp.setLogFunc(logFunc)
	_logFunc = logFunc
end

local percentHanderFun = function (value)
	if value ~= nil then
		value = value * 100
		local _,pos1 = string.find(value,"[(0-9)]*.")
		local pos2 = string.len(tostring(value))
		pos1 = pos1 or 0
		pos2 = pos2 or 1
		local f = pos2-pos1
		if f < 1 then
			f = 1
		elseif f > 1 then
			f = 2
		end
		return string.format("%0."..f.."f%%", value)
	end
end


--[[
	@fieldName 属性字段
	@name 属性名称
	@handlerFun 处理属性数据字段 百分比处理
	@actor_prop ui表现对应魂师_totalProp属性字段
	@name_full 属性全称
]]--

QActorProp._uiFields = {}
table.insert(QActorProp._uiFields, {fieldName = "attack_percent", name = "攻击", handlerFun = percentHanderFun })
table.insert(QActorProp._uiFields, {fieldName = "hp_percent", name = "生命", handlerFun = percentHanderFun})
table.insert(QActorProp._uiFields, {fieldName = "armor_physical_percent", name = "物防", handlerFun = percentHanderFun})
table.insert(QActorProp._uiFields, {fieldName = "armor_magic_percent", name = "法防", handlerFun = percentHanderFun})
table.insert(QActorProp._uiFields, {fieldName = "attack_value", name = "攻击" ,actor_prop= "attack_total"})
table.insert(QActorProp._uiFields, {fieldName = "hp_value", name = "生命" , actor_prop ="hp_total"})
table.insert(QActorProp._uiFields, {fieldName = "armor_physical", name = "物防" ,actor_prop ="armor_physical_total" ,name_full = "物理防御"})
table.insert(QActorProp._uiFields, {fieldName = "armor_magic", name = "法防",actor_prop ="armor_magic_total" ,name_full = "法术防御"})
table.insert(QActorProp._uiFields, {fieldName = "physical_penetration_value", name = "物穿" , actor_prop = "physical_penetration" ,name_full = "物理穿透"})
table.insert(QActorProp._uiFields, {fieldName = "magic_penetration_value", name = "法穿" , actor_prop = "magic_penetration" ,name_full = "法术穿透"})
table.insert(QActorProp._uiFields, {fieldName = "hit_rating", name = "命中" , actor_prop ="hit_total"})
table.insert(QActorProp._uiFields, {fieldName = "dodge_rating", name = "闪避", actor_prop = "dodge_total"})
table.insert(QActorProp._uiFields, {fieldName = "block_rating", name = "格挡", actor_prop = "block_total"})
table.insert(QActorProp._uiFields, {fieldName = "critical_rating", name = "暴击", actor_prop = "critical_total"})
table.insert(QActorProp._uiFields, {fieldName = "critical_chance", name = "暴击"})
table.insert(QActorProp._uiFields, {fieldName = "cri_reduce_rating", name = "抗暴" , actor_prop = "cri_reduce_rating_total"})
table.insert(QActorProp._uiFields, {fieldName = "cri_reduce_chance", name = "抗暴"})
table.insert(QActorProp._uiFields, {fieldName = "haste_rating", name = "攻速" , actor_prop = "haste_total"})
table.insert(QActorProp._uiFields, {fieldName = "physical_damage_percent_attack", name = "物伤提升", handlerFun = percentHanderFun , actor_prop = "physical_damage_percent_attack_total" ,name_full = "物理加伤"})
table.insert(QActorProp._uiFields, {fieldName = "magic_damage_percent_attack", name = "法伤提升", handlerFun = percentHanderFun , actor_prop = "magic_damage_percent_attack_total", name_full = "法术加伤"})
table.insert(QActorProp._uiFields, {fieldName = "physical_damage_percent_beattack_reduce", name = "物理免伤", handlerFun = percentHanderFun , actor_prop = "physical_damage_percent_beattack_reduce_total", name_full = "物理减伤"})
table.insert(QActorProp._uiFields, {fieldName = "magic_damage_percent_beattack_reduce", name = "法术免伤", handlerFun = percentHanderFun , actor_prop = "magic_damage_percent_beattack_reduce_total", name_full = "法术减伤"})
table.insert(QActorProp._uiFields, {fieldName = "team_attack_value", name = "全队攻击" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_hp_value", name = "全队生命" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_armor_physical", name = "全队物防" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_armor_magic", name = "全队法防" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_physical_penetration_value", name = "全队物穿" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_magic_penetration_value", name = "全队法穿" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_hit_rating", name = "全队命中" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_dodge_rating", name = "全队闪避" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_block_rating", name = "全队格挡" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_critical_rating", name = "全队暴击" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_cri_reduce_rating", name = "全队抗暴" , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_hp_percent", name = "全队生命", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_attack_percent", name = "全队攻击", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_armor_physical_percent", name = "全队物防", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_armor_magic_percent", name = "全队法防", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_physical_damage_percent_beattack", name = "全队PVP物理易伤", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_physical_damage_percent_beattack_reduce", name = "全队PVP物理免伤", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_magic_damage_percent_beattack", name = "全队PVP法术易伤", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_magic_damage_percent_beattack_reduce", name = "全队PVP法术免伤", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_physical_damage_percent_attack", name = "全队物理伤害提升", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "team_magic_damage_percent_attack", name = "全队法术伤害提升", handlerFun = percentHanderFun , isAllTeam = true})
table.insert(QActorProp._uiFields, {fieldName = "magic_treat_percent_beattack", name = "受疗提升",actor_prop ="magic_treat_percent_beattack_total", handlerFun = percentHanderFun, name_full = "被治疗效果提升"})
table.insert(QActorProp._uiFields, {fieldName = "magic_treat_percent_attack", name = "治疗提升", actor_prop="magic_treat_percent_attack_total",handlerFun = percentHanderFun, name_full = "治疗效果提升"})
table.insert(QActorProp._uiFields, {fieldName = "wreck_rating", name = "破击" , actor_prop="wreck_total"})
table.insert(QActorProp._uiFields, {fieldName = "soul_damage_percent_attack", name = "魂灵伤害增加",actor_prop ="soul_damage_percent_attack", handlerFun = percentHanderFun})
table.insert(QActorProp._uiFields, {fieldName = "soul_damage_percent_beattack_reduce", name = "魂灵伤害减免",actor_prop ="soul_damage_percent_beattack_reduce", handlerFun = percentHanderFun})

--[[
	@name 属性字段
	@uiName 在UI上显示的name 如果不存在则读取name
	@value 数值
	@compose 组成部分 会全部叠加到属性值上
	@coefficient 乘以系数 系数不会叠加到属性值上
	@forceWord 战斗力计算字段
	@forceField 战斗力计算的属性字段 乘
	@showUI 是否在UI界面显示
	@isFinal 是否需要最终计算 basic
	@magicType 觉醒的计算属性 因为觉醒的数值是成长值乘以强化等级
    @isPercent 显示的时候是否以百分比显示
    @isAllTeam 是否是全队属性
]]--
QActorProp._field = {}
QActorProp._field["base_effect"] = {value = 0, name = "额外系数值"}
--生命
QActorProp._field["hp_total"] = {index = 101, value = 0, name = "生命", compose = {"hp_base_total"}, coefficient = {"hp_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["hp_base_total"] = {index = 102, value = 0, name = "生命", compose = {"hp_value","team_hp_value"}, isPercent = false}
QActorProp._field["hp_percent"] = {index = 103, value = 0, name = "生命百分比", uiName = "生命", uiMergeName = "攻防血", compose = {"team_hp_percent"}, isPercent = true}

QActorProp._field["hp_value"] = {index = 104, value = 0, name = "生命", archaeologyName = "全队生命", compose = {"hp_grow"}, isPercent = false}
QActorProp._field["hp_grow"] = {index = 105, value = 0, name = "生命成长", coefficient = {"level"}, magicType = "hp_value", isPercent = false}
QActorProp._field["team_hp_value"] = {index = 106, value = 0, name = "全队生命", isPercent = false, isAllTeam = true}
QActorProp._field["team_hp_percent"] = {index = 107, value = 0, name = "全队生命百分比", uiName = "全队生命", isPercent = true, isAllTeam = true}	

--攻击
QActorProp._field["attack_total"] = {index = 201, value = 0, name = "攻击", compose = {"attack_base_total"}, coefficient = {"attack_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["attack_base_total"] = {index = 202, value = 0, name = "攻击", compose = {"attack_value","team_attack_value"}, isPercent = false}
QActorProp._field["attack_percent"] = {index = 203, value = 0, name = "攻击百分比", uiName = "攻击", uiMergeName = "攻防血", compose = {"team_attack_percent"}, isPercent = true}

QActorProp._field["attack_value"] = {index = 204, value = 0, name = "攻击", archaeologyName = "全队攻击", compose = {"attack_grow"}, isPercent = false}
QActorProp._field["attack_grow"] = {index = 205, value = 0, name = "攻击成长", coefficient = {"level"}, magicType = "attack_value", isPercent = false}
QActorProp._field["team_attack_value"] = {index = 206, value = 0, name = "全队攻击", isPercent = false, isAllTeam = true}
QActorProp._field["team_attack_percent"] = {index = 207, value = 0, name = "全队攻击百分比", uiName = "全队攻击", isPercent = true, isAllTeam = true}

--物理防御 
QActorProp._field["armor_physical_total"] = {index = 301, value = 0, name = "物理防御", uiName = "物防", compose = {"armor_physical"}, coefficient = {"armor_physical_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["armor_physical_percent"] = {index = 302, value = 0, name = "物理防御百分比", uiName = "物防", uiMergeName = "攻防血", compose = {"team_armor_physical_percent"}, isPercent = true}

QActorProp._field["armor_physical"] = {index = 303, value = 0, name = "物理防御", uiName = "物防", archaeologyName = "全队物防", compose = {"armor_physical_grow","team_armor_physical"}, isPercent = false}
QActorProp._field["armor_physical_grow"] = {index = 304, value = 0, name = "物理防御成长", coefficient = {"level"}, magicType = "armor_physical", isPercent = false}
QActorProp._field["team_armor_physical"] = {index = 305, value = 0, name = "全队物防", isPercent = false, isAllTeam = true}
QActorProp._field["team_armor_physical_percent"] = {index = 306, value = 0, name = "全队物防百分比", uiName = "全队物防", isPercent = true, isAllTeam = true}

--魔法防御
QActorProp._field["armor_magic_total"] = {index = 401, value = 0, name = "法术防御", uiName = "法防", compose = {"armor_magic"}, coefficient = {"armor_magic_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["armor_magic_percent"] = {index = 402, value = 0, name = "法术防御百分比", uiName = "法防", uiMergeName = "攻防血", compose = {"team_armor_magic_percent"}, isPercent = true}

QActorProp._field["armor_magic"] = {index = 403, value = 0, name = "法术防御", uiName = "法防", archaeologyName = "全队法防", compose = {"armor_magic_grow","team_armor_magic"}, isPercent = false}
QActorProp._field["armor_magic_grow"] = {index = 404, value = 0, name = "法术防御成长", coefficient = {"level"}, magicType = "armor_magic", isPercent = false}
QActorProp._field["team_armor_magic"] = {index = 405, value = 0, name = "全队法防", isPercent = false, isAllTeam = true}
QActorProp._field["team_armor_magic_percent"] = {index = 406, value = 0, name = "全队法防百分比", uiName = "全队法防", isPercent = true, isAllTeam = true}

--物理穿透
QActorProp._field["physical_penetration"] = {index = 501, value = 0, name = "物理穿透", compose = {"physical_penetration_value"}, coefficient = {"physical_penetration_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["physical_penetration_value"] = {index = 502, value = 0, name = "物理穿透", uiName = "物穿", compose={"team_physical_penetration_value"}, isPercent = false}
QActorProp._field["physical_penetration_percent"] = {index = 503, value = 0, name = "物理穿透百分比", uiName = "物穿", isPercent = true}
QActorProp._field["team_physical_penetration_value"] = {index = 504, value = 0, name = "全队物穿", isPercent = false}

--法术穿透
QActorProp._field["magic_penetration"] = {index = 601, value = 0, name = "法术穿透", compose = {"magic_penetration_value"}, coefficient = {"magic_penetration_percent"}, showUI = true, isFinal = true, isPercent = true}
QActorProp._field["magic_penetration_value"] = {index = 602, value = 0, name = "法术穿透", uiName = "法穿", compose = {"team_magic_penetration_value"}, isPercent = false}
QActorProp._field["magic_penetration_percent"] = {index = 603, value = 0, name = "法术穿透百分比", uiName = "法穿", isPercent = true}
QActorProp._field["team_magic_penetration_value"] = {index = 604, value = 0, name = "全队法穿", isPercent = false}

--命中
QActorProp._field["hit_total"] = {index = 701, value = 0, name = "命中", compose = {"hit_rating"}, coefficient = {"hit_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["hit_percent"] = {index = 702, value = 0, name = "命中百分比", uiName = "命中", isPercent = true}

QActorProp._field["hit_rating"] = {index = 703, value = 0, name = "命中", compose = {"hit_grow","team_hit_rating"}, isPercent = false}
QActorProp._field["hit_grow"] = {index = 704, value = 0, name = "命中成长", coefficient = {"level"}, magicType = "hit_rating", isPercent = false}
QActorProp._field["team_hit_rating"] = {index = 705, value = 0, name = "全队命中", isPercent = false}

--闪避
QActorProp._field["dodge_total"] = {index = 801, value = 0, name = "闪避", compose = {"dodge_rating"}, coefficient = {"dodge_percent"}, showUI = true, isFinal = true, isPercent = true}
QActorProp._field["dodge_percent"] = {index = 802, value = 0, name = "闪避百分比", isPercent = false}

QActorProp._field["dodge_rating"] = {index = 803, value = 0, name = "闪避", compose = {"dodge_grow","team_dodge_rating"}, isPercent = false}
QActorProp._field["dodge_grow"] = {index = 804, value = 0, name = "闪避成长", coefficient = {"level"}, magicType = "dodge_rating", isPercent = false}
QActorProp._field["team_dodge_rating"] = {index = 805, value = 0, name = "全队命中", isPercent = false}

--格挡
QActorProp._field["block_total"] = {index = 901, value = 0, name = "格挡", compose = {"block_rating"}, coefficient = {"block_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["block_percent"] = {index = 902, value = 0, name = "格挡百分比", isPercent = true}

QActorProp._field["block_rating"] = {index = 903, value = 0, name = "格挡", compose = {"block_grow","team_block_rating"}, isPercent = false}
QActorProp._field["block_grow"] = {index = 904, value = 0, name = "格挡成长", coefficient = {"level"}, magicType = "block_rating", isPercent = false}
QActorProp._field["team_block_rating"] = {index = 905, value = 0, name = "全队格挡", isPercent = false}

--破击
QActorProp._field["wreck_total"] = {index = 1001, value = 0, name = "破击", compose = {"wreck_rating"}, coefficient = {"wreck_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["wreck_percent"] = {index = 1002, value = 0, name = "破击百分比", isPercent = true}

QActorProp._field["wreck_rating"] = {index = 1003, value = 0, name = "破击", compose = {"wreck_grow","team_wreck_rating"}, isPercent = false}
QActorProp._field["wreck_grow"] = {index = 1004, value = 0, name = "破击成长", coefficient = {"level"}, magicType = "wreck_rating", isPercent = false}
QActorProp._field["team_wreck_rating"] = {index = 1005, value = 0, name = "全队破击", isPercent = false}

--暴击
QActorProp._field["critical_total"] = {index = 1101, value = 0, name = "暴击等级", compose = {"critical_rating"}, coefficient = {"critical_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["critical_percent"] = {index = 1102, value = 0, name = "暴击等级百分比", isPercent = true}

QActorProp._field["critical_rating"] = {index = 1103, value = 0, name = "暴击等级", compose = {"critical_grow","team_critical_rating"}, isPercent = false}
QActorProp._field["critical_grow"] = {index = 1104, value = 0, name = "暴击等级成长", coefficient = {"level"}, magicType = "critical_rating", isPercent = false}
QActorProp._field["team_critical_rating"] = {index = 1105, value = 0, name = "全队暴击", isPercent = false}

--暴击率
QActorProp._field["critical_chance_total"] = {index = 1201, value = 0, name = "暴击率", compose = {"critical_chance"}, coefficient = {"critical_chance_percent"}, forceWord = "critical_chance", showUI = true, isFinal = true, isPercent = false}
QActorProp._field["critical_chance_percent"] = {index = 1202, value = 0, name = "暴击率百分比", isPercent = true}

QActorProp._field["critical_chance"] = {index = 1203, value = 0, name = "暴击率", compose = {"critical_chance_grow"}, isPercent = false}
QActorProp._field["critical_chance_grow"] = {index = 1204, value = 0, name = "暴击率成长", coefficient = {"level"}, magicType = "critical_chance", isPercent = false}

--抗暴等级
QActorProp._field["cri_reduce_rating_total"] = {index = 1301, value = 0, name = "抗暴等级", compose = {"cri_reduce_rating"}, coefficient = {"cri_reduce_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["cri_reduce_percent"] = {index = 1302, value = 0, name = "抗暴等级百分比", isPercent = true}

QActorProp._field["cri_reduce_rating"] = {index = 1303, value = 0, name = "抗暴等级", compose = {"cri_reduce_grow","team_cri_reduce_rating"}, isPercent = false}
QActorProp._field["cri_reduce_grow"] = {index = 1304, value = 0, name = "抗暴等级成长", coefficient = {"level"}, magicType = "cri_reduce_rating", isPercent = false}
QActorProp._field["team_cri_reduce_rating"] = {index = 1305, value = 0, name = "全队抗暴", isPercent = false}

--抗暴率
QActorProp._field["cri_reduce_chance_total"] = {index = 1401, value = 0, name = "抗暴击率", compose = {"cri_reduce_chance"}, coefficient = {"cri_reduce_chance_percent"}, forceWord = "cri_reduce_chance", showUI = true, isFinal = true, isPercent = false}
QActorProp._field["cri_reduce_chance_percent"] = {index = 1402, value = 0, name = "抗暴击率百分比", isPercent = true}

QActorProp._field["cri_reduce_chance"] = {index = 1403, value = 0, name = "抗暴击率", compose = {"cri_reduce_chance_grow"}, isPercent = false}
QActorProp._field["cri_reduce_chance_grow"] = {index = 1404, value = 0, name = "抗暴击率成长", coefficient = {"level"}, magicType = "cri_reduce_chance", isPercent = false}

--攻速
QActorProp._field["haste_total"] = {index = 1501, value = 0, name = "攻速", compose = {"haste_rating"}, coefficient = {"haste_percent"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["haste_percent"] = {index = 1502, value = 0, name = "攻速百分比", isPercent = true}

QActorProp._field["haste_rating"] = {index = 1503, value = 0, name = "攻速", refineName = "攻速等级", compose = {"haste_grow"}, isPercent = false}
QActorProp._field["haste_grow"] = {index = 1504, value = 0, name = "攻速成长", coefficient = {"level"}, magicType = "haste_rating", isPercent = false}

--PVP物攻加成
QActorProp._field["pvp_physical_damage_percent_attack_total"] = {index = 1601, value = 0, name = "玩家对战物伤", compose = {"pvp_physical_damage_percent_attack"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["pvp_physical_damage_percent_attack"] = {index = 1602, value = 0, name = "全队PVP物理加伤", archaeologyName = "主力PVP物理加伤", isPercent = true}

--PVP魔攻加成
QActorProp._field["pvp_magic_damage_percent_attack_total"] = {index = 1701, value = 0, name = "玩家对战法伤", compose = {"pvp_magic_damage_percent_attack"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["pvp_magic_damage_percent_attack"] = {index = 1702, value = 0, name = "全队PVP法术加伤", archaeologyName = "主力PVP法术加伤", isPercent = true}

--PVP物防加成
QActorProp._field["pvp_physical_damage_percent_beattack_reduce_total"] = {index = 1801, value = 0, name = "玩家对战物免", compose = {"pvp_physical_damage_percent_beattack_reduce"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["pvp_physical_damage_percent_beattack_reduce"] = {index = 1802, value = 0, name = "全队PVP物理减伤", archaeologyName = "主力PVP物理减伤", isPercent = true}

--PVP魔防加成
QActorProp._field["pvp_magic_damage_percent_beattack_reduce_total"] = {index = 1901, value = 0, name = "玩家对战法免", compose = {"pvp_magic_damage_percent_beattack_reduce"}, showUI = true, isFinal = true, isPercent = false}
QActorProp._field["pvp_magic_damage_percent_beattack_reduce"] = {index = 1902, value = 0, name = "全队PVP法术减伤", archaeologyName = "主力PVP法术减伤", isPercent = true}

--急速率
QActorProp._field["attackspeed_chance_total"] = {index = 2001, value = 0, name = "急速率总成", compose = {"attackspeed_chance"}, forceWord = "attackspeed_chance", showUI = false, isFinal = true, isPercent = false}
QActorProp._field["attackspeed_chance"] = {index = 2002, value = 0, name = "急速率", archaeologyName = "急速率", isPercent = false}

--命中率
QActorProp._field["hit_chance_total"] = {index = 2101, value = 0, name = "命中率总成", compose = {"hit_chance"}, forceWord = "hit_chance", showUI = false, isFinal = true, isPercent = false}
QActorProp._field["hit_chance"] = {index = 2102, value = 0, name = "命中率", archaeologyName = "命中率", isPercent = false}

--闪避率
QActorProp._field["dodge_chance_total"] = {index = 2201, value = 0, name = "闪避率总成", compose = {"dodge_chance"}, forceWord = "dodge_chance", showUI = false, isFinal = true, isPercent = false}
QActorProp._field["dodge_chance"] = {index = 2202, value = 0, name = "闪避率", archaeologyName = "闪避率", isPercent = false}

--格挡率
QActorProp._field["block_chance_total"] = {index = 2301, value = 0, name = "格挡率总成", compose = {"block_chance"}, forceWord = "block_chance", showUI = false, isFinal = true, isPercent = false}
QActorProp._field["block_chance"] = {index = 2302, value = 0, name = "格挡率", archaeologyName = "格挡率", isPercent = false}

--破击率
QActorProp._field["wreck_chance_total"] = {index = 2401, value = 0, name = "破击率总成", compose = {"wreck_chance"}, forceWord = "wreck_chance", showUI = false, isFinal = true, isPercent = false}
QActorProp._field["wreck_chance"] = {index = 2402, value = 0, name = "破击率", archaeologyName = "破击率", isPercent = false}

--物理伤害提升
QActorProp._field["physical_damage_percent_attack_total"] = {index = 2501, value = 0, name = "物理伤害提升总成", compose = {"physical_damage_percent_attack"}, forceField = "attack_total", forceWord = "physical_damage_percent_attack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["physical_damage_percent_attack"] = {index = 2502, value = 0, name = "物理伤害提升", uiName = "物伤提升", uiMergeName = "伤害提升", archaeologyName = "物理伤害提升", isPercent = true}

--法术伤害提升
QActorProp._field["magic_damage_percent_attack_total"] = {index = 2601, value = 0, name = "法术伤害提升总成", compose = {"magic_damage_percent_attack"}, forceField = "attack_total", forceWord = "magic_damage_percent_attack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["magic_damage_percent_attack"] = {index = 2602, value = 0, name = "法术伤害提升", uiName = "法伤提升", uiMergeName = "伤害提升", archaeologyName = "法术伤害提升", isPercent = true}

--治疗提升
QActorProp._field["magic_treat_percent_attack_total"] = {index = 2701, value = 0, name = "治疗提升总成", compose = {"magic_treat_percent_attack"}, forceWord = "magic_treat_percent_attack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["magic_treat_percent_attack"] = {index = 2702, value = 0, name = "治疗提升", archaeologyName = "治疗提升", isPercent = true}

--物理易伤
QActorProp._field["physical_damage_percent_beattack_total"] = {index = 2801, value = 0, name = "物理易伤总成", compose = {"physical_damage_percent_beattack"}, forceWord = "physical_damage_percent_beattack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["physical_damage_percent_beattack"] = {index = 2802, value = 0, name = "物理易伤", archaeologyName = "物理易伤", isPercent = true}

--物理免伤
QActorProp._field["physical_damage_percent_beattack_reduce_total"] = {index = 2901, value = 0, name = "物理免伤总成", compose = {"physical_damage_percent_beattack_reduce"}, forceField = "attack_total", forceWord = "physical_damage_percent_beattack_reduce", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["physical_damage_percent_beattack_reduce"] = {index = 2902, value = 0, name = "物理免伤", uiMergeName = "伤害减免", archaeologyName = "物理免伤", isPercent = true}

--法术易伤
QActorProp._field["magic_damage_percent_beattack_total"] = {index = 3001, value = 0, name = "法术易伤总成", compose = {"magic_damage_percent_beattack"}, forceWord = "magic_damage_percent_beattack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["magic_damage_percent_beattack"] = {index = 3002, value = 0, name = "法术易伤", archaeologyName = "法术易伤", isPercent = true}

--法术免伤
QActorProp._field["magic_damage_percent_beattack_reduce_total"] = {index = 3101, value = 0, name = "法术免伤总成", compose = {"magic_damage_percent_beattack_reduce"}, forceField = "attack_total", forceWord = "magic_damage_percent_beattack_reduce", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["magic_damage_percent_beattack_reduce"] = {index = 3102, value = 0, name = "法术免伤", uiMergeName = "伤害减免", archaeologyName = "法术免伤", isPercent = true}

--被治疗效果提升
QActorProp._field["magic_treat_percent_beattack_total"] = {index = 3201, value = 0, name = "被治疗效果提升总成", compose = {"magic_treat_percent_beattack"}, forceWord = "magic_treat_percent_beattack", showUI = false, isFinal = true, isPercent = true}
QActorProp._field["magic_treat_percent_beattack"] = {index = 3202, value = 0, name = "被治疗效果提升", uiName = "受疗提升", archaeologyName = "被治疗效果提升", isPercent = true}

--怒气
QActorProp._field["normal_skill_rage_gain"] = {index = 3301, value = 0, name = "普攻获得怒气加成", isFinal = true}
QActorProp._field["active_skill_rage_gain"] = {index = 3302, value = 0, name = "主动技能获得怒气加成", isFinal = true}
QActorProp._field["pve_enter_rage"] = {index = 3303, value = 0, name = "PVE进场怒气加成", isFinal = true}
QActorProp._field["pvp_enter_rage"] = {index = 3304, value = 0, name = "PVP进场怒气加成", isFinal = true}
QActorProp._field["pvp_kill_rage"] = {index = 3305, value = 0, name = "PVP杀死对手怒气加成", isFinal = true}
QActorProp._field["rage_per_five_second"] = {index = 3306, value = 0, name = "怒气每秒加成", isFinal = true}
QActorProp._field["rage_per_five_second_for_team"] = {index = 3307, value = 0, name = "战队怒气每秒加成", isFinal = true}
QActorProp._field["pvp_rage_on_enemy_killed"] = {index = 3308, value = 0, name = "对手挂了的怒气加成", isFinal = true}
QActorProp._field["pvp_rage_on_enemy_killed_for_team"] = {index = 3309, value = 0, name = "对手挂了给战队提供的怒气加成", isFinal = true}
QActorProp._field["enter_rage"] = {index = 3310, value = 0, name = "进场能量", isFinal = true}
QActorProp._field["bekill_rage"] = {index = 3311, value = 0, name = "被杀怒气", isFinal = true}
QActorProp._field["limit_rage_upper"] = {index = 3312, value = 0, name = "附加怒气上限", isFinal = true}

--可回复血量上限
QActorProp._field["recover_hp_limit"] = {index = 3401, value = 0, name = "可回复血量上限", isFinal = true}

--PVE伤害加深
QActorProp._field["pve_damage_percent_attack"] = {index = 3501, value = 0, name = "PVE伤害加深", handbookName = "主力PVE伤害加深", isPercent = true, isFinal = true}

--PVE伤害减免
QActorProp._field["pve_damage_percent_beattack"] = {index = 3601, value = 0, name = "PVE伤害减免", handbookName = "主力PVE伤害减免", isPercent = true, isFinal = true}

--魂灵伤害减免
QActorProp._field["soul_damage_percent_beattack_reduce"] = {index = 4101, value = 0, name = "全队魂灵减伤", isPercent = true, isFinal = true}

--魂灵伤害增加
QActorProp._field["soul_damage_percent_attack"] = {index = 4201, value = 0, name = "全队魂灵加伤", isPercent = true, isFinal = true}


local _equipment = nil
local function initHeroEquipment()
	_equipment = {}
	local breakthrough = db:getBreakthrough()
	for key,heroBreak in pairs(breakthrough) do
		_equipment[key] = {}
		for _,value in ipairs(heroBreak) do
			value = q.cloneShrinkedObject(value)
			for _,pos in pairs(EQUIPMENT_TYPE) do
				_equipment[key][value[pos]] = {pos = pos, breakInfo = value}
			end
		end
	end
end

function QActorProp:ctor(options)
	if _equipment == nil then
		initHeroEquipment()
	end

	self:initProp()
	if options ~= nil then
		self:setHeroInfo(options)
	end
end

function QActorProp:setPrint(isPrint)
	self._isPrint = isPrint
end

function QActorProp:setOnlyProp(isOnlyProp)
	self._isOnlyProp = isOnlyProp
end

function QActorProp:getLevel()
	return self._heroInfo.level
end

function QActorProp:getActorId()
	return self._heroInfo.actorId
end

function QActorProp:isHunter()
	return self._characterConfig.pet_id ~= nil
end

-- 进场怒气
function QActorProp:getEnterRage()
	return self._totalProp["enter_rage"]
end

-- 附加怒气上限
function QActorProp:getRageLimitUpper()
	return self._totalProp["limit_rage_upper"]
end

function QActorProp:getPVEDamagePercentAttack()
	return self._totalProp["pve_damage_percent_attack"]
end

function QActorProp:getPVEDamagePercentBeattack()
	return self._totalProp["pve_damage_percent_beattack"]
end

function QActorProp:getSoulDamagePercentBeattackReduce()
	return self._totalProp["soul_damage_percent_beattack_reduce"]
end

function QActorProp:getSoulDamagePercentAttack()
	return self._totalProp["soul_damage_percent_attack"]
end

function QActorProp:initProp()
	self._isPrint = false
	self._isOnlyProp = false
	self._logFile = nil
	self._totalProp = {}
	self._actorProp = {}
	self._equipmentProp = {}
	self._breakProp = {}
	self._gradeProp = {}
	self._trainingProp = {}
	self._skillProp = {}
    self._skillForce = 0
    self._masterProp = {}
    self._archaeologyProp = {}
    self._soulTrialProp = {}
    self._avatarProp = {}
    self._extendsProp = {}
    self._unionSkillProp = {}
    self._glyphProp = {}
    self._combinationProp = {}
    self._gemstoneProp = {}
    self._glyphTeamProp = {}
    self._badgeProp = {}
    self._mountCombinationProp = {}
    self._soulSpiritCombinationProp = {}
    self._godarmReformProp = {}
    self._mountProp = {}
    self._mountForce = 0
    self._refineProp = {}
    self._artifactProp = {}
    self._artifactForce = 0
    self._dragonTotemProp = {}
    self._dragonTotemForce = 0
    self._sparsProp = 0
    self._headProp = {}
    self._magicHerbsProp = {}
    self._soulSpiritProp = {}
    self._godSkillProp = {}
    self._gemstoneAdvancedSkillProp = {}
    self._gemstoneGodSkillProp = {}
	self._attrListProp = {}
	self._extraProp = {}
end

function QActorProp:setHeroInfo(heroInfo, extraProp)
	if self._heroInfo == nil then
		self._oldHeroInfo = {}
	else
		self._oldHeroInfo = self._heroInfo
	end
	self._heroInfo = heroInfo
    self._forceConfig = db:getForceConfigByLevel(self:getLevel())
    self._coConfig = db:getLevelCoefficientByLevel(tostring(self:getLevel()))

    --获取魂师自身的属性
    local needCount = false
	if self._heroInfo.actorId ~= self._oldHeroInfo.actorId then
		needCount = true
		self._characterConfig = db:getCharacterByID(self:getActorId())
    	self:_countActorProperties(self._heroInfo.actorId, self._heroInfo.data_difficulty, self._heroInfo.data_level) 
    end

    --获取魂师的装备属性
	if needCount or self._heroInfo.equipments ~= self._oldHeroInfo.equipments then
    	self:_countEquipmentProperties(self._heroInfo.equipments) 
    end

	--获取魂师的强化大师属性
	if needCount or self._heroInfo.equipments ~= self._oldHeroInfo.equipments then
    	self:_countEquipmentMasterProperties(self._heroInfo.actorId, self._heroInfo.equipments) 
    end

    --获取魂师的突破属性
	if needCount or self._heroInfo.breakthrough ~= self._oldHeroInfo.breakthrough then
   		self:_countBreakProperties(self._heroInfo.breakthrough or 0) 
    end

    --获取魂师的进阶属性
	if needCount or self._heroInfo.grade ~= self._oldHeroInfo.grade then
    	self:_countGradeProperties(self._heroInfo.grade or 0) 
    end

    --获取魂师的培养属性
	if needCount or self._heroInfo.trainAttr ~= self._oldHeroInfo.trainAttr then
    	self:_countTrainProperties(self._heroInfo.trainAttr or {}) 
    end

    --获取魂师的洗炼属性
	if needCount or self._heroInfo.refineAttrs ~= self._oldHeroInfo.refineAttrs then
    	self:_countRefineProperties(self._heroInfo.refineAttrs or {}) 
    end

    --获取魂师的仙品属性
	if needCount or self._heroInfo.magicHerbs ~= self._oldHeroInfo.magicHerbs then
    	self:_countMagicHerbsProperties(self._heroInfo.magicHerbs or {}) 
    end

    --获取魂师的组合属性
	if needCount or self._heroInfo.combinationProp ~= self._oldHeroInfo.combinationProp then
    	self:_countCombinationProperties(self._heroInfo.combinationProp or {}) 
    end

    --获取魂师的技能属性
    if needCount or self._heroInfo.slots ~= self._oldHeroInfo.slots or self._heroInfo.peripheralSkills ~= self._oldHeroInfo.peripheralSkills 
    	or self._heroInfo.glyphs ~= self._oldHeroInfo.glyphs then
    	-- 编辑器技能
	    local skills = (self._heroInfo and self._heroInfo.skills) or {}

	    if ENABLE_GLYPH then
		    -- 雕纹技能
		    for _, glyph in pairs(self._heroInfo.glyphs or {}) do
		    	local config = db:getGlyphSkillByIdAndLevel(glyph.glyphId, glyph.level)
		    	if config and config.skill_id then
		    		table.mergeForArray(skills, string.split(tostring(config.skill_id), ";"))
		    	end
		    end
	    end
	    -- 暗器技能
	    local zuoqiInfo = self._heroInfo.zuoqi
	    local actorInfo = self._heroInfo
	    if zuoqiInfo and actorInfo.isSupport ~= nil then
            local zuoqiInfo = actorInfo.zuoqi
            local zuoqiId = zuoqiInfo.zuoqiId
            local zuoqiGrade = zuoqiInfo.grade
            local isSupport = actorInfo.isSupport
            local gradeConfig = db:getGradeByHeroActorLevel(zuoqiId, zuoqiGrade)
            if gradeConfig then
                local skill_term = isSupport and gradeConfig.zuoqi_skill_yz or gradeConfig.zuoqi_skill1_sz
                local skillIds = {}
                if type(skill_term) == "string" then
                    skillIds = string.split(skill_term, ";")
                else
                    skillIds[#skillIds + 1] = tostring(skill_term)
                end
                table.mergeForArray(skills, skillIds)
            end
	    end
	  
        -- -- 晶石星级套装技能
        if self._heroInfo.spar ~= nil and #self._heroInfo.spar == 2 then
            local sparInfo = self._heroInfo.spar
            local itemId1 = sparInfo[1].itemId
            local itemId2 = sparInfo[2].itemId
            local index1 = db:getSparsIndexByItemId(sparInfo[1].itemId)
            local realItemId1 = index1 == 1 and itemId1 or itemId2
            local realItemId2 = index1 == 1 and itemId2 or itemId1
            local minGrade = math.min(sparInfo[1].grade or 0, sparInfo[2].grade or 0)
            local activeSuit = db:getActiveSparSuitInfoBySparId(realItemId1, realItemId2, minGrade+1)
            local isSupport = actorInfo.isSupport
            if activeSuit and next(activeSuit) ~= nil then
            	local skillStr = isSupport and activeSuit.skill_yz or activeSuit.skill_sz
            	if string.find(skillStr, ";") then
	            	local skillIds = string.split(skillStr, ";")
	            	for i,id in ipairs(skillIds or {}) do
	            		skills[#skills + 1] = tostring(id)..":"..tostring(activeSuit.skill_level)
	            	end
            	else
            		skills[#skills + 1] = tostring(skillStr)..":"..tostring(activeSuit.skill_level)
            	end
            end
        end

        -- 魂骨融合技能
        if self._heroInfo.gemstones ~= nil then
        	local skillIds = db:getGemstoneMixSuitSkillByGemstones(self._heroInfo.gemstones)
        	for i,id in ipairs(skillIds) do
				skills[#skills + 1] = tostring(id)..":"..tostring(1)
        	end
        end
        self:_countSkillProperties(self._heroInfo.slots or {}, self._heroInfo.peripheralSkills or {}, skills) 
    end

    --获取考古信息
    if needCount or self._heroInfo.archaeologyProp ~= self._oldHeroInfo.archaeologyProp then
        self:_countArchaeologyProp(self._heroInfo.archaeologyProp or {}) 
    end

    --获取魂力试炼信息
    if needCount or self._heroInfo.soulTrialProp ~= self._oldHeroInfo.soulTrialProp then
        self:_countSoulTrialProp(self._heroInfo.soulTrialProp or {}) 
    end
    --获取宗门技能信息
    if needCount or self._heroInfo.unionSkillProp ~= self._oldHeroInfo.unionSkillProp then
        self:_countUnionSkillProp(self._heroInfo.unionSkillProp or {}) 
    end

    --获取头像框信息
    if needCount or self._heroInfo.avatarProp ~= self._oldHeroInfo.avatarProp then
        self:_countAvatarProp(self._heroInfo.avatarProp or {}) 
    end

    --获取雕纹属性
    if needCount or self._heroInfo.glyphs ~= self._oldHeroInfo.glyphs then
    	self:_countGlyphProp(self._heroInfo.glyphs or {})
    end

    --获取雕纹全队属性
    if needCount or self._heroInfo.teamGlyphInfo ~= self._oldHeroInfo.teamGlyphInfo then
    	self:_countGlyphTeamProp(self._heroInfo.teamGlyphInfo or {})
    end

    --获取宝石属性
    if needCount or self._heroInfo.gemstones ~= self._oldHeroInfo.gemstones then
    	self:_countGemstoneProp(self._heroInfo.gemstones or {})    	
    end

    --获取徽章属性
    if needCount or self._heroInfo.badgeProp ~= self._oldHeroInfo.badgeProp then
    	self:_countBadgeProp(self._heroInfo.badgeProp or {})
    end

    --获取暗器属性
    if needCount or self._heroInfo.zuoqi ~= self._oldHeroInfo.zuoqi then
    	self:_countMountProp(self._heroInfo.zuoqi or {})
    end

    --获取暗器组合（图鉴）属性
    if needCount or self._heroInfo.mountCombinationProp ~= self._oldHeroInfo.mountCombinationProp then
    	self:_countMountCombinationProp(self._heroInfo.mountCombinationProp or {})
    end

    --计算武魂真身属性
    if needCount or self._heroInfo.artifact ~= self._oldHeroInfo.artifact then
    	self:_countArtifactProp(self._heroInfo.artifact or {})
    end

    if needCount or self._heroInfo.totemInfos ~= self._oldHeroInfo.totemInfos then
    	self:_countDragonTotemProp(self._heroInfo.totemInfos or {})
	end

    --获取晶石属性
    if needCount or self._heroInfo.spar ~= self._oldHeroInfo.spar then
    	self:_countSparsProp(self._heroInfo.spar or {})    	
    end

    --获取头像列表属性
    if needCount or self._heroInfo.headProp ~= self._oldHeroInfo.headProp then
    	self:_countHeadListProp(self._heroInfo.headProp or {})
    end

    --获取魂灵属性
    if needCount or self._heroInfo.soulSpirit ~= self._oldHeroInfo.soulSpirit then
    	self:_countSoulSpiritProp(self._heroInfo.soulSpirit or {})
    end

    --获取神技
    if needCount or self._heroInfo.godSkillGrade ~= self._oldHeroInfo.godSkillGrade then
    	self:_countGodSkillProp(self._heroInfo.godSkillGrade or 0)
    end

    --获取全局属性
    if needCount or self._heroInfo.attrListProp ~= self._oldHeroInfo.attrListProp then
    	self:_countAttrListPropp(self._heroInfo.attrListProp or {})
    end

    --获取魂灵图鉴
    if needCount or self._heroInfo.soulSpiritCombinationProp ~= self._oldHeroInfo.soulSpiritCombinationProp then
    	self:_countSoulSpiritCombinationProp(self._heroInfo.soulSpiritCombinationProp or {})
    end

    --获取神器属性
    if needCount or self._heroInfo.godarmReformProp ~= self._oldHeroInfo.godarmReformProp then
    	self:_countGodarmReformProp(self._heroInfo.godarmReformProp or {})
    end

    --xurui: 增加全局属性(extraProp 如果为空就默认为玩家自己的魂师计算属性)
    if extraProp == nil then
    	extraProp = app.extraProp:getSelfExtraProp()
    end
    self._extraProp = extraProp

    --计算所有的属性集合
	if self._isOnlyProp then
		self:_handleAllPropWithoutCount() 
    else
    	self:_countAllProp()
    end
end

--计算自身属性
function QActorProp:_countActorProperties(actorId, data_difficulty, data_level)
	self._actorProp = {}
    local properties = db:getCharacterByID(actorId)
    properties = db:getCharacterData(properties.id, properties.data_type, data_difficulty, data_level)
    self:_analysisProp(self._actorProp, properties)
    if self._isPrint == true then
    	printTable(properties,nil,"DEBUG_PROP")
    end
end

--计算装备属性
function QActorProp:_countEquipmentProperties(equipments)
	self._equipmentProp = {}
    if equipments ~= nil then
        local heroEquipments = equipments
        local itemInfo 
        local minStrengthLevel = nil
        for _,equipmentInfo in pairs(heroEquipments) do
            itemInfo = self:getItemAllPropByitemId(equipmentInfo.itemId, equipmentInfo.level or 0, equipmentInfo.enchants or 0, self._heroInfo.actorId)
            if itemInfo ~= nil then
                self:_analysisProp(self._equipmentProp, itemInfo, itemInfo.name)
            end
            if minStrengthLevel == nil then
                minStrengthLevel = equipmentInfo.level or 0
            else
                if (equipmentInfo.level or 0) < minStrengthLevel then
                    minStrengthLevel = equipmentInfo.level or 0
                end
            end
        end
    end
end

--计算装备强化大师属性
function QActorProp:_countEquipmentMasterProperties(actorId, equipments)
    if equipments == nil then return end
    self._masterProp = {}
    local equipMinLevel = 1000000
    local jewelryMinLevel = 1000000
    local equipEnchantMinLevel = 1000000
    local jewelryEnchantMinLevel = 1000000
    local jewelryBreakMinLevel = 1000000
    for i = 1 ,#equipments, 1 do
        local equipName = self:getEquipeName(actorId, equipments[i].itemId)
        if equipName then
	        local enchantLevel = equipments[i].enchants or 0

	        local breakInfo = self:getEquipeBreakInfo(actorId, equipments[i].itemId)
	        local breakLevel = breakInfo.breakthrough_level or 0

	        if (equipName == EQUIPMENT_TYPE.JEWELRY1 or equipName == EQUIPMENT_TYPE.JEWELRY2) and #equipments == 6 then
	            jewelryMinLevel = jewelryMinLevel > (equipments[i].level or 0) and (equipments[i].level or 0) or jewelryMinLevel
	            jewelryEnchantMinLevel = jewelryEnchantMinLevel > enchantLevel and enchantLevel or jewelryEnchantMinLevel
	            jewelryBreakMinLevel = jewelryBreakMinLevel > breakLevel and breakLevel or jewelryBreakMinLevel
	        elseif equipName ~= EQUIPMENT_TYPE.JEWELRY1 and equipName ~= EQUIPMENT_TYPE.JEWELRY2 then
	            equipMinLevel = equipMinLevel > (equipments[i].level or 0) and (equipments[i].level or 0) or equipMinLevel
	            equipEnchantMinLevel = equipEnchantMinLevel > enchantLevel and enchantLevel or equipEnchantMinLevel
	        end
	    end
    end

    equipMinLevel = equipMinLevel == 1000000 and 0 or equipMinLevel
    jewelryMinLevel = jewelryMinLevel == 1000000 and 0 or jewelryMinLevel
    equipEnchantMinLevel = equipEnchantMinLevel == 1000000 and 0 or equipEnchantMinLevel
    jewelryEnchantMinLevel = jewelryEnchantMinLevel == 1000000 and 0 or jewelryEnchantMinLevel
    jewelryBreakMinLevel = jewelryBreakMinLevel == 1000000 and 0 or jewelryBreakMinLevel

    local equipMasterLevel = db:getStrengthenMasterByLevel("enhance_master_", equipMinLevel)
    local jewelryMasterLevel = db:getStrengthenMasterByLevel("jewelry_master_", jewelryMinLevel)
    local jewelryBreakMastreLevel = db:getStrengthenMasterByLevel("shipingtupo_master_", jewelryBreakMinLevel)
	local equipMasterInfo = db:getStrengthenMasterByMasterLevel("enhance_master_", equipMasterLevel)
	local jewelryMasterInfo = db:getStrengthenMasterByMasterLevel("jewelry_master_", jewelryMasterLevel)
    local jewelryBreakMasterInfo = db:getStrengthenMasterByMasterLevel("shipingtupo_master_", jewelryBreakMastreLevel)

    local equipEnchantMastreLevel = 0
    local jewelryEnchantMastreLevel = 0
    local equipEnchantMasterInfo = {}
    local jewelryEnchantMasterInfo = {}
    local character = db:getCharacterByID(self._heroInfo.actorId)
	if character.aptitude == APTITUDE.SS then
		equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_ss_master_", equipEnchantMinLevel)
    	jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_ss_master_", jewelryEnchantMinLevel)
		equipEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("zhuangbeifumo_ss_master_", equipEnchantMastreLevel)
    	jewelryEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("shipingfumo_ss_master_", jewelryEnchantMastreLevel)
    elseif character.aptitude == APTITUDE.SSR then
		equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_ssr_master_", equipEnchantMinLevel)
    	jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_ssr_master_", jewelryEnchantMinLevel)
		equipEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("zhuangbeifumo_ssr_master_", equipEnchantMastreLevel)
    	jewelryEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("shipingfumo_ssr_master_", jewelryEnchantMastreLevel)
	else
		equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_master_", equipEnchantMinLevel)
    	jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_master_", jewelryEnchantMinLevel)
		equipEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("zhuangbeifumo_master_", equipEnchantMastreLevel)
    	jewelryEnchantMasterInfo = db:getStrengthenMasterByMasterLevel("shipingfumo_master_", jewelryEnchantMastreLevel)
	end

	equipMasterInfo = equipMasterInfo or {}
	jewelryMasterInfo = jewelryMasterInfo or {}
    equipEnchantMasterInfo = equipEnchantMasterInfo or {}
    jewelryEnchantMasterInfo = jewelryEnchantMasterInfo or {}
    jewelryBreakMasterInfo = jewelryBreakMasterInfo or {}

    self:_analysisProp(self._masterProp, equipMasterInfo, "equipMasterInfo")
    self:_analysisProp(self._masterProp, jewelryMasterInfo, "jewelryMasterInfo")
    self:_analysisProp(self._masterProp, equipEnchantMasterInfo, "equipEnchantMasterInfo")
    self:_analysisProp(self._masterProp, jewelryEnchantMasterInfo, "jewelryEnchantMasterInfo")
    self:_analysisProp(self._masterProp, jewelryBreakMasterInfo, "jewelryBreakMasterInfo")
end

--计算突破的属性
function QActorProp:_countBreakProperties(breakLevel)
	self._breakProp = {}
    local breakConfig = db:getBreakthroughHeroByHeroActorLevel(self._heroInfo.actorId, breakLevel)
    breakConfig = breakConfig or {}
    self:_analysisProp(self._breakProp, breakConfig)
end

--计算进阶的属性
function QActorProp:_countGradeProperties(gradeLevel)
	self._gradeProp = {}
    local gradeConfig = db:getGradeByHeroActorLevel(self._heroInfo.actorId, gradeLevel)
    gradeConfig = gradeConfig or {}
    self:_analysisProp(self._gradeProp, gradeConfig)
end

--计算培养的属性
function QActorProp:_countTrainProperties(trainProp)
	self._trainingProp = {}
	self._trainingProp["hp_value"] = trainProp.hp or 0
	self._trainingProp["attack_value"] = trainProp.attack or 0
	self._trainingProp["armor_physical"] = trainProp.armorPhysical or 0
	self._trainingProp["armor_magic"] = trainProp.armorMagic or 0

    local hpForce = db:getBattleForceBySingleAttribute("hp", trainProp.hp or 0, self:getLevel())
    local attackForce = db:getBattleForceBySingleAttribute("attack", trainProp.attack or 0, self:getLevel())
    local pdForce = db:getBattleForceBySingleAttribute("armor_physical", trainProp.armorPhysical or 0, self:getLevel())
    local mdForce = db:getBattleForceBySingleAttribute("armor_magic", trainProp.armorMagic or 0, self:getLevel())

    local total = math.floor(hpForce + attackForce + pdForce + mdForce)

    local bonus = db:getTrainingBonus(self:getActorId())
    for k, v in ipairs(bonus) do
        if total >= v.standard then
            self:_analysisProp(self._trainingProp, v)
        end
    end
end

-- 计算魂师洗炼属性
function QActorProp:_countRefineProperties( refineProp )
	self._refineProp = {}
	for _, value in pairs( refineProp ) do
		self._refineProp[value.attribute] = value.refineValue or 0
	end
end

-- 计算魂师仙品属性
function QActorProp:_countMagicHerbsProperties( magicHerbs )
	self._magicHerbsProp = {}
    local magicHerbConfigs = db:getMagicHerb()
    local enhanceConfigs = db:getMagicHerbEnhance()
    local gradeConfigs = db:getMagicHerbGrade()
    local magicHerbType = nil
    local minAptitude = 9999
    local minBreedLv = 9999
    local suitNum = 0
    local magicHerbCount = 0
    local masterAptitude
    local minLevelInWeared
	for _, magicHerb in pairs( magicHerbs ) do
		magicHerbCount = magicHerbCount + 1
		local levelProp = {}
		local gradeProp = {}
		local levelExtraProp = {}
		local magicConfig = magicHerbConfigs[tostring(magicHerb.itemId)] or {}
		if not masterAptitude or magicConfig.aptitude < masterAptitude then
			masterAptitude = magicConfig.aptitude
		end
		if not minLevelInWeared or  magicHerb.level < minLevelInWeared then
			minLevelInWeared = magicHerb.level
		end
		local enhanceTbl = enhanceConfigs[tostring(magicHerb.itemId)] or {}
		local gradeTbl = gradeConfigs[tostring(magicHerb.itemId)] or {}
	    for _, value in pairs(enhanceTbl) do
	        if value.level == magicHerb.level then
	            levelProp = value
	            break
	        end
	    end
	    for _, value in pairs(gradeTbl) do
	        if value.grade == magicHerb.grade then
	            gradeProp = value
	            break
	        end
	    end
	    --培养加强升级的属性 需要与升级属性匹配
	    local breedLv = magicHerb.breedLevel or 0
	    if breedLv > 0 then
	    	local extraConfig = db:getMagicHerbEnhanceExtraConfigByBreedLvAndId(magicHerb.level , breedLv)
	    	for key,v in pairs(levelProp or {}) do
	    		if extraConfig and extraConfig[key] then
	    			levelExtraProp[key] = extraConfig[key]
	    		end
	    	end
	    end
	    -- 基本属性
		self:_analysisProp(self._magicHerbsProp, levelProp, "levelProp")
	    self:_analysisProp(self._magicHerbsProp, gradeProp, "gradeProp")
	    self:_analysisProp(self._magicHerbsProp, levelExtraProp, "levelExtraProp")

	    -- 洗练
		local attributes = magicHerb.attributes or {}
		for i, value in pairs(attributes) do
			self._magicHerbsProp[value.attribute] = (self._magicHerbsProp[value.attribute] or 0) + (value.refineValue or 0)
		end

		-- 套装
		if not magicHerbType then
			magicHerbType = magicConfig.type
		end
		if magicConfig.type == magicHerbType then
			suitNum = suitNum + 1
			if magicConfig.aptitude < minAptitude then
				minAptitude = magicConfig.aptitude
			end
			if breedLv < minBreedLv then
				minBreedLv = breedLv
			end			
		end
	end
	
	-- 套装属性
	if suitNum == 3 then
		local skill = 0
		local magicHerbSuitConfigs = db:getMagicHerbSuitKill()
	    local tbl = magicHerbSuitConfigs[tostring(magicHerbType)] or {}
	    local curBreed = 0
	    for _, value in pairs(tbl) do
	        if value.aptitude == minAptitude and minBreedLv >= value.breed and curBreed <= value.breed then
	            skill = value.skill
	            curBreed = value.breed
	        end
	    end
	    local skillsProp = {}
	    if skill ~= 0 then
	    	local skillData = db:getSkillDataByIdAndLevel(skill, 1)
    		local count = 1
    		while true do
    			local key = skillData["addition_type_"..count]
    			local value = skillData["addition_value_"..count]
    			if key == nil then
    				break
    			end
    			if skillsProp[key] == nil then
    				skillsProp[key] = value
    			else
    				skillsProp[key] = skillsProp[key] + value
    			end
    			count = count + 1
    		end
	    end
		self:_analysisProp(self._magicHerbsProp, skillsProp, "skillsProp")
	end

	-- 大师
	if magicHerbCount == 3 then
		local masterConfigs = db:getStaticByName("magic_herb_master")
		local masterConfigList = masterConfigs[masterAptitude]
		if not masterConfigList or masterConfigList[1].aptitude ~= masterAptitude then
			masterConfigList = {}
			for _, masterConfig in pairs(masterConfigs) do
				for _, value in ipairs(masterConfig) do
					if value.aptitude == masterAptitude then
						table.insert(masterConfigList, value)
					end
				end
			end
			table.sort(masterConfigList, function(a, b)
					return a.master_level < b.master_level
				end)
		end

		local curMasterConfig = {}

		for _, config in ipairs(masterConfigList) do
			if config.condition <= minLevelInWeared then
				curMasterConfig = config
			end
		end
		-- local curMasterConfig = remote.magicHerb:getMasterConfigByAptitudeAndMagicHerbLevel(masterAptitude , minLevelInWeared) or {}
	    self:_analysisProp(self._magicHerbsProp, curMasterConfig, "magicHerbMaster")
    end
end

-- 计算魂师组合属性
function QActorProp:_countCombinationProperties( combinationProp )
	self._combinationProp = combinationProp
end

--计算技能的属性
function QActorProp:_countSkillProperties(slots, peripheralSkills, skills)
	self._skillProp = {}
    local skillIds = {}
    self._skillForce = 0
    for _, slotInfo in ipairs(slots) do
        local level = slotInfo.slotLevel
        local skillId = db:getSkillByActorAndSlot(self:getActorId(), slotInfo.slotId)
        if skillId and level then
		    if self._isPrint then
		        trace("slots skillId: "..skillId.." level:"..level,"DEBUG_PROP")
		    end
        	skillIds[skillId] = level
        end
    end
    for _,peripheralSkill in ipairs(peripheralSkills) do
	    if self._isPrint then
	        trace("peripheralSkills skillId: "..peripheralSkill.id.." level:"..peripheralSkill.level,"DEBUG_PROP")
	    end
    	skillIds[peripheralSkill.id] = peripheralSkill.level
    end
    for _,skill in ipairs(skills) do
    	if string.len(skill) > 0 then
	    	local words = string.split(skill, ",")
	    	if #words == 1 then
	    		words = string.split(skill, ":") --  有时候策划会用冒号分割id和level。。。
	    	end
	    	local id = tonumber(words[1])
	    	local level = words[2] and tonumber(words[2]) or 1
		    if self._isPrint then
		        trace("skills skillId: "..id.." level:"..level,"DEBUG_PROP")
		    end
	    	skillIds[id] = level
	    end
    end

    local skillsProp = {}
    for id, level in pairs(skillIds) do
        if id and level then
		    if self._isPrint then
		        trace("id: "..id.." level:"..level,"DEBUG_PROP")
		    end
        	local skillConfig = db:getSkillByID(id)
        	local skillData = db:getSkillDataByIdAndLevel(id, level)
        	self._skillForce = self._skillForce + (skillData.battle_force or 0)
        	if (self:isHunter() == false or not skillConfig.addition_for_pet) and not skillConfig.addition_for_main then
        		local count = 1
        		while true do
        			local key = skillData["addition_type_"..count]
        			local value = skillData["addition_value_"..count]
        			if key == nil then
        				break
        			end
				    if self._isPrint then
				        trace("key: "..key.." value:"..value,"DEBUG_PROP")
				    end
        			if skillsProp[key] == nil then
        				skillsProp[key] = value
        			else
        				skillsProp[key] = skillsProp[key] + value
        			end
        			count = count + 1
        		end
        	end
        end
    end
	self:_analysisProp(self._skillProp, skillsProp, "skillsProp")
    if self._isPrint then
        trace("skill force: "..self._skillForce,"DEBUG_PROP")
    end
end

--计算考古属性
function QActorProp:_countArchaeologyProp(archaeologyProp)
    self._archaeologyProp = archaeologyProp or {}
end

--计算魂力试炼属性
function QActorProp:_countSoulTrialProp(soulTrialProp)
    self._soulTrialProp = soulTrialProp or {}
end

function QActorProp:_countUnionSkillProp(unionSkillProp)
    self._unionSkillProp = unionSkillProp or {}
end

function QActorProp:_countAvatarProp(avatarProp)
    self._avatarProp = avatarProp or {}
end

--计算雕纹的属性
function QActorProp:_countGlyphProp(glyphs)
	self._glyphProp = {}
    local glyphProp = {}
    for _, glyph in pairs(glyphs) do
    	local config = db:getGlyphSkillByIdAndLevel(glyph.glyphId, glyph.level)
    	if config then
    		for key, value in pairs(config) do
    			if QActorProp._field[key] and QActorProp._field[key].isAllTeam ~= true then
	    			if glyphProp[key] == nil then
	    				glyphProp[key] = value
	    			else
	    				glyphProp[key] = glyphProp[key] + value
	    			end
    			end
    		end
    	end
    end
	self:_analysisProp(self._glyphProp, glyphProp)
end

--计算体技全队属性
function QActorProp:_countGlyphTeamProp(glyphs)
    local glyphTeamProp = {}
	if next(glyphs) ~= nil then
		glyphTeamProp = db:calculateGlyphTeamProp(glyphs)               
	end
	self._glyphTeamProp = glyphTeamProp
end

--计算宝石属性
function QActorProp:_countGemstoneProp(gemstones)
    self._gemstoneProp = {}
    local suit = {}
    local godSuit = {}
    local gemstoneCount = 0
    local masterLevel = nil
    local masterBreakLevel = nil
    local mixSuit = {}
    self._gemstoneAdvancedSkillProp = {}
    self._gemstoneGodSkillProp = {}
    for _,gemstone in ipairs(gemstones) do
	    --属性
		local gemstoneConfig = db:getItemByID(gemstone.itemId)


		suit[gemstoneConfig.gemstone_set_index] = (suit[gemstoneConfig.gemstone_set_index] or 0) + 1
	    --强化属性
	    local strnegthProp = db:getTotalEnhancePropByLevel(gemstoneConfig.enhance_data, gemstone.level or 1)
	    --突破属性
		local breakconfig = db:getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel or 0)

		--进阶属性
		local advancedInfo = db:getGemstoneEvolutionAllPropBygodLevel(gemstone.itemId,(gemstone.godLevel or 0))

	    for name,_ in pairs(QActorProp._field) do
	        if gemstoneConfig[name] ~= nil then
	        	self._gemstoneProp[name] = (self._gemstoneProp[name] or 0) + gemstoneConfig[name]
	        end
	        if strnegthProp[name] ~= nil then
	        	self._gemstoneProp[name] = (self._gemstoneProp[name] or 0) + strnegthProp[name]
	        end
	        if breakconfig[name] ~= nil then
	        	self._gemstoneProp[name] = (self._gemstoneProp[name] or 0) + breakconfig[name]
	        end
	        if advancedInfo then
		        for _,v in pairs(advancedInfo) do
					if v[name] ~= nil then
						self._gemstoneProp[name] = (self._gemstoneProp[name] or 0) + v[name]
					end
				end
			end	        
	    end

	    -- 技能属性
	    local advancedSkillId, godSkillId = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,(gemstone.godLevel or 0))
	    
	    self:_countGemstoneSkillProp(advancedSkillId)
	    self:_countGemstoneGodSkillProp(godSkillId)

	    -- 套装统计
		local godLevel = gemstone.godLevel or 0
		local mixLevel = gemstone.mix_level or 0
		if  mixLevel > 0 and godLevel < 25 then --只激活ss套装属性 不激活技能
			godLevel = 25 
		end

		local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,godLevel)
	    if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
	    	godSuit[gemstoneInfo_ss.gem_evolution_new_set] = (godSuit[gemstoneInfo_ss.gem_evolution_new_set] or 0) + 1
	    end


	    local mixConfig = db:getGemstoneMixConfigByIdAndLv(gemstone.itemId , gemstone.mix_level or 0)
	    if mixConfig and mixConfig.gem_suit and gemstone.mix_level then
	    	if not mixSuit[mixConfig.gem_suit] then
	    		mixSuit[mixConfig.gem_suit] = {}
	    		mixSuit[mixConfig.gem_suit].num  = 0
	    		mixSuit[mixConfig.gem_suit].minLevel  = 999
	    	end
	    	mixSuit[mixConfig.gem_suit].num = mixSuit[mixConfig.gem_suit].num + 1
	    	local mixLevel = mixSuit[mixConfig.gem_suit].minLevel
	    	mixSuit[mixConfig.gem_suit].minLevel = math.min(mixSuit[mixConfig.gem_suit].minLevel , gemstone.mix_level)
	    end

	    gemstoneCount = gemstoneCount + 1
	    masterLevel = masterLevel or gemstone.level
	    masterLevel = math.min(masterLevel, gemstone.level)
	    gemstone.craftLevel = gemstone.craftLevel or 0
	    masterBreakLevel = masterBreakLevel or gemstone.craftLevel
	    masterBreakLevel = math.min(masterBreakLevel, gemstone.craftLevel)
    end
    --计算套装属性
    for key,count in pairs(suit) do
    	local suitConfigs = db:getGemstoneSuitEffectBySuitId(key)
    	for _,config in ipairs(suitConfigs) do
    		if config.set_number <= count then
    			for key,value in pairs(config) do
    				if QActorProp._field[key] ~= nil then
	        			self._gemstoneProp[key] = (self._gemstoneProp[key] or 0) + value
    				end
    			end
    		end
    	end
    end

    --计算神骨套装属性
    for key,count in pairs(godSuit) do
    	local suitConfigs = db:getGemstoneSuitEffectBySuitId(key)
    	for _,config in ipairs(suitConfigs) do
    		if config.set_number <= count then
    			for key,value in pairs(config) do
    				if QActorProp._field[key] ~= nil then
	        			self._gemstoneProp[key] = (self._gemstoneProp[key] or 0) + value

    				end
    			end
    		end
    	end
    end
    --计算融合套装属性
    for key,value in pairs(mixSuit) do
    	local gem_suit = key
    	local suitNum = value.num
    	local minLevel = value.minLevel
    	for i=1,suitNum do
	    	local suitConfigs = db:getGemstoneMixSuitConfigByData(gem_suit ,i , minLevel ) 
	    	if suitConfigs then
				for key,value in pairs(suitConfigs) do
					if QActorProp._field[key] ~= nil and value > 0 then
		    			self._gemstoneProp[key] = (self._gemstoneProp[key] or 0) + value
					end
				end
	    	end
    	end
    end
    --计算大师属性
    if gemstoneCount == 4 then
    	local masterConfig = {}
    	masterLevel = db:getStrengthenMasterByLevel("enhance_master_", masterLevel)
    	if masterLevel > 0 then
    		masterConfig = db:getStrengthenMasterByMasterLevel("baoshiqianghua_master_", masterLevel)
    	end
    	masterConfig = masterConfig or {}

    	local masterBreakConfig = {}
    	masterBreakLevel = db:getStrengthenMasterByLevel("baoshitupo_master_", masterBreakLevel)
    	if masterBreakLevel > 0 then
    		masterBreakConfig = db:getStrengthenMasterByMasterLevel("baoshitupo_master_", masterBreakLevel)
    	end
    	masterBreakConfig = masterBreakConfig or {}

    self:_analysisProp(self._gemstoneProp, masterConfig, "gemstoneMaster")
    self:_analysisProp(self._gemstoneProp, masterBreakConfig, "gemstoneMasterBreak")
    end
end

--保存徽章属性
function QActorProp:_countBadgeProp(badgeProp)
    self._badgeProp = badgeProp or {}
end

--计算暗器属性
function QActorProp:_countMountProp(mountInfo)
	self._mountForce = 0
    local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
    if mountConfig ~= nil then
    	self._mountProp = {}
	    --基础属性
	    local baseProp = db:getCharacterData(mountInfo.zuoqiId, mountConfig.data_type) or {}
	    --强化属性
	    local levelProp = db:getMountStrengthenBylevel(mountConfig.aptitude, mountInfo.enhanceLevel) or {}
	    --升星属性
	    local gradeProp = db:getGradeByHeroActorLevel(mountInfo.zuoqiId, mountInfo.grade) or {}
	    --强化大师
	    local masterProps, masterLevel = db:getMountMasterInfo(mountConfig.aptitude, mountInfo.enhanceLevel)

	    self:_analysisProp(self._mountProp, baseProp, "baseProp")
	    self:_analysisProp(self._mountProp, levelProp, "levelProp")
	    -- self:_analysisProp(self._mountProp, gradeProp, "gradeProp")
	    for name,value in pairs(QActorProp._field) do
	        if gradeProp[name] ~= nil  and not value.isAllTeam  then --剔除升星SS+暗器带来的全队属性加成
	        	self._mountProp[name] = (self._mountProp[name] or 0) + gradeProp[name]
	        end
	    end	    

        for _, masterProp in ipairs(masterProps) do
	    	self:_analysisProp(self._mountProp, masterProp, "masterProp")
        end

        for _,skill_data in ipairs(string.split(gradeProp.zuoqi_skill1_sz, ";")) do
		   	local skillIds = string.split(skill_data,":")
		   	local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]), tonumber(skillIds[2])) or {}
		   	self._mountForce = self._mountForce + (skillData.battle_force or 0)
		end

		if mountInfo.wearZuoqiInfo then
	    	local gradeProp = db:getGradeByHeroActorLevel(mountInfo.zuoqiId, mountInfo.wearZuoqiInfo.grade) or {}
			if gradeProp.zuoqi_skill_pj then
				for _,skill_data in ipairs(string.split(gradeProp.zuoqi_skill_pj, ";")) do
				   	local skillIds = string.split(skill_data,":")
				   	local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]), tonumber(skillIds[2])) or {}
				   	self._mountForce = self._mountForce + (skillData.battle_force or 0)
				end
			end

			local mountConfig = db:getCharacterByID(mountInfo.wearZuoqiInfo.zuoqiId)
		    if mountConfig ~= nil then
			    --基础属性
			    local baseProp = db:getCharacterData(mountInfo.wearZuoqiInfo.zuoqiId, mountConfig.data_type) or {}
			    --强化属性
			    local levelProp = db:getMountStrengthenBylevel(mountConfig.aptitude, mountInfo.wearZuoqiInfo.enhanceLevel) or {}
			    --升星属性
			    local gradeProp = db:getGradeByHeroActorLevel(mountInfo.wearZuoqiInfo.zuoqiId, mountInfo.wearZuoqiInfo.grade) or {}
			    --强化大师
			    local masterProps, masterLevel = db:getMountMasterInfo(mountConfig.aptitude, mountInfo.wearZuoqiInfo.enhanceLevel)

			    self:_analysisProp(self._mountProp, baseProp, "wearProp")
			    self:_analysisProp(self._mountProp, levelProp, "wearProp")
			    self:_analysisProp(self._mountProp, gradeProp, "wearProp")
		        for _, masterProp in ipairs(masterProps) do
			    	self:_analysisProp(self._mountProp, masterProp, "masterProp")
		        end
			end
		end
	end
end

--保存暗器组合（图鉴）属性
function QActorProp:_countMountCombinationProp(mountCombinationProp)
	self._mountCombinationProp = mountCombinationProp
end

--保存组合（图鉴）属性
function QActorProp:_countSoulSpiritCombinationProp(soulSpiritCombinationProp)
	self._soulSpiritCombinationProp = soulSpiritCombinationProp
end

--保存神器属性
function QActorProp:_countGodarmReformProp(godarmReformProp)
	self._godarmReformProp = godarmReformProp
end

--计算魂灵属性
function QActorProp:_countSoulSpiritProp(soulSpiritInfo)
    self._soulSpiritProp = {}
    local characterConfig = db:getCharacterByID(soulSpiritInfo.id)
    if characterConfig ~= nil then
    	--基础属性
	    local baseProp = db:getCharacterData(characterConfig.id, characterConfig.data_type) or {}
	    self:_analysisProp(self._soulSpiritProp, baseProp, "soulSpiritBaseProp")

    	local allLevelConfigs = db:getStaticByName("soul_level")
	    local levelConfigs = allLevelConfigs[tostring(characterConfig.aptitude)] or {}
	    local levelConfig = {}
	    for _, config in pairs(levelConfigs) do
	        if config.chongwu_level == soulSpiritInfo.level then
	        	levelConfig = config
	        	break
	        end
	    end
	    self:_analysisProp(self._soulSpiritProp, levelConfig, "soulSpiritLevelProp")

	    local gradeConfig = db:getGradeByHeroActorLevel(soulSpiritInfo.id, soulSpiritInfo.grade)
	    self:_analysisProp(self._soulSpiritProp, gradeConfig, "soulSpiritGradeProp")
	    local allMasterConfigs = db:getStaticByName("soul_tianfu")
	    local masterConfigs = allMasterConfigs[tostring(characterConfig.aptitude)] or {}
	    for _, config in pairs(masterConfigs) do
	        if config.condition <= soulSpiritInfo.level then
	    		self:_analysisProp(self._soulSpiritProp, config, "soulSpiritMasterProp")
	        end
	    end
	    --SS魂灵传承属性
	    if soulSpiritInfo.devour_level and soulSpiritInfo.devour_level > 0 then
	    	local inheritConfig = db:getSoulSpiritInheritConfig(soulSpiritInfo.devour_level , soulSpiritInfo.id)
	    	if inheritConfig then
	    		self:_analysisProp(self._soulSpiritProp, inheritConfig, "soulSpiritInheritProp")
	    	end
	    end

	    if soulSpiritInfo.soulSpiritMapInfo then
	        for _,mapInfo in pairs(soulSpiritInfo.soulSpiritMapInfo) do
	            for _,detailInfo in pairs(mapInfo.detailInfo) do
	            	local childConfig = db:getChildSoulFireInfo(mapInfo.mapId,detailInfo.bigPointId,detailInfo.smallPointId)
	            	if childConfig then
	                	self:_analysisProp(self._soulSpiritProp, childConfig, "soulSpiritOccultProp")
	                end
	            end
	    	end	    	
	    end
	end
end

--计算武魂真身属性
function QActorProp:_countArtifactProp(artifactProp)
	self._artifactProp = {}
	self._artifactForce = 0
	local character= db:getCharacterByID(self._heroInfo.actorId)
	if character.artifact_id ~= nil and next(artifactProp) then
		local artifactId = character.artifact_id
		local itemConfig = db:getItemByID(artifactId)
	    self:_analysisProp(self._artifactProp, itemConfig, "artifactBaseProp")

	    -- 强化属性
	    local levelConfig = db:getArtifactLevelConfigBylevel(character.aptitude, artifactProp.artifactLevel) or {}
	    self:_analysisProp(self._artifactProp, levelConfig, "artifactLevelProp")

	    -- 强化大师属性
	    local masterProps = db:getArtifactMasterInfo(character.aptitude, artifactProp.artifactLevel)
	    for _, masterProp in pairs(masterProps) do
	        self:_analysisProp(self._artifactProp, masterProp, "artifactMasterProp")
	    end

	    -- 突破属性
	    local gradeConfig = db:getGradeByArtifactLevel(artifactId, artifactProp.artifactBreakthrough) or {}
	    self:_analysisProp(self._artifactProp, gradeConfig, "artifactGradeProp")

    	local skillsProp = {}
	    local artifactSkillList = artifactProp.artifactSkillList or {}
	    for _, artifactSkill in pairs(artifactSkillList) do
	    	local skillData = db:getSkillDataByIdAndLevel(artifactSkill.skillId, artifactSkill.skillLevel)
    		self._artifactForce = self._artifactForce + (skillData.battle_force or 0)
    		local count = 1
    		while true do
    			local key = skillData["addition_type_"..count]
    			local value = skillData["addition_value_"..count]
    			if key == nil then
    				break
    			end
			    if self._isPrint then
			        trace("key: "..key.." value:"..value,"DEBUG_PROP")
			    end
    			if skillsProp[key] == nil then
    				skillsProp[key] = value
    			else
    				skillsProp[key] = skillsProp[key] + value
    			end
    			count = count + 1
    		end
	    end
		self:_analysisProp(self._artifactProp, skillsProp, "artifactSkillsProp")
	    if self._isPrint then
	        trace("artifact skill force: "..self._artifactForce,"DEBUG_PROP")
	    end
	end
end

--计算ss神技属性
function QActorProp:_countGodSkillProp(godSkillGrade)
	self._godSkillProp = {}
	if godSkillGrade > 0 then
		local godSkillConfig = db:getGodSkillByIdAndGrade(self._heroInfo.actorId, godSkillGrade)
		if godSkillConfig then
	    	self:_analysisProp(self._godSkillProp, godSkillConfig, "godSkillProp")
	    end
	end
end

--全局属性
function QActorProp:_countAttrListPropp(attrListProp)
	self._attrListProp = attrListProp
end

function QActorProp:_countGemstoneGodSkillProp(godskill )
	if godskill then
		local skillData = db:getSkillDataByIdAndLevel(godskill,1)
		local skillsProp = {}
		local count = 1
		while true do
			local key = skillData["addition_type_"..count]
			local value = skillData["addition_value_"..count]
			if key == nil then
				break
			end
			if skillsProp[key] == nil then
				skillsProp[key] = value
			else
				skillsProp[key] = skillsProp[key] + value
			end
			count = count + 1
		end
		self:_analysisProp(self._gemstoneGodSkillProp, skillsProp, "gemstoneGodSkillProp")
	end
end
function QActorProp:_countGemstoneSkillProp(advancedSkill)
	if advancedSkill then
    	local skillData = db:getSkillDataByIdAndLevel(advancedSkill,1)
    	local skillsProp = {}
		local count = 1
		while true do
			local key = skillData["addition_type_"..count]
			local value = skillData["addition_value_"..count]
			if key == nil then
				break
			end
			if skillsProp[key] == nil then
				skillsProp[key] = value
			else
				skillsProp[key] = skillsProp[key] + value
			end
			count = count + 1
		end
		self:_analysisProp(self._gemstoneAdvancedSkillProp, skillsProp, "gemstoneSkillProp")
	end

end
--计算图腾属性
function QActorProp:_countDragonTotemProp(totemInfos)
	self._dragonTotemProp = {}
	self._dragonTotemForce = 0
	--计算龙纹属性
	local totemProp = {}
	local minLevel = nil
	for _,totemInfo in ipairs(totemInfos) do
		local config = db:getDragonTotemConfigByIdAndLevel(totemInfo.dragonDesignId, totemInfo.grade)
		for k,v in pairs(config) do
			if type(v) == "number" then
				totemProp[k] = v + (totemProp[k] or 0)
			end
		end
		if minLevel == nil or totemInfo.grade < minLevel then
			minLevel = totemInfo.grade
		end
	end
    self:_analysisProp(self._dragonTotemProp, totemProp, "totemProp")

    --计算天赋属性
    if minLevel ~= nil then
		local totemTalentProp = {}
	    local talentConfigs = db:getDragonTotemTalent()
		for _,talentConfig in pairs(talentConfigs) do
			if talentConfig.condition <= minLevel then
				for k,v in pairs(talentConfig) do
					if type(v) == "number" then
						totemTalentProp[k] = v + (totemTalentProp[k] or 0)
					end
				end
			end
		end
	    self:_analysisProp(self._dragonTotemProp, totemTalentProp, "totemTalentProp")
	end

    --计算图腾技能
    local totemInfo = totemInfos[7]
    if totemInfo ~= nil then
		local config = db:getDragonTotemConfigByIdAndLevel(totemInfo.dragonDesignId, totemInfo.grade)
		local skillData = db:getSkillDataByIdAndLevel(config.skill_id, config.level)
		if skillData ~= nil then
			self._dragonTotemForce = skillData.battle_force or 0
    		-- local count = 1
    		-- while true do
    		-- 	local key = skillData["addition_type_"..count]
    		-- 	local value = skillData["addition_value_"..count]
    		-- 	if key == nil then
    		-- 		break
    		-- 	end
			   --  if self._isPrint then
			   --      trace("key: "..key.." value:"..value,"DEBUG_PROP")
			   --  end
    		-- 	if self._dragonTotemProp[key] == nil then
    		-- 		self._dragonTotemProp[key] = value
    		-- 	else
    		-- 		self._dragonTotemProp[key] = self._dragonTotemProp[key] + value
    		-- 	end
    		-- 	count = count + 1
    		-- end
		end
    end
    if self._isPrint then
        trace("dragon totem skill force: "..self._dragonTotemForce,"DEBUG_PROP")
    end
end

--计算晶石属性
function QActorProp:_countSparsProp(spars)
	self._sparsProp = {}
    local suit = {}
    local sparsCount = 0
    local masterLevel = nil
    local masterBreakLevel = nil
    for _, spar in ipairs(spars) do
	    --属性
		local sparConfig = db:getItemByID(spar.itemId)
	    --强化属性
	    local strengthProp = db:getTotalEnhancePropByLevel(sparConfig.enhance_data, spar.level or 1)
	    --升星属性
		local gradeConfig = db:getGradeByHeroActorLevel(spar.itemId, spar.grade or 0)
	    --吸收属性
		local absorbConfig = db:getSparsAbsorbConfigBySparItemIdAndLv(spar.itemId, spar.inheritLv or 0)

	    for name,value in pairs(QActorProp._field) do
	        if sparConfig[name] ~= nil then
	        	self._sparsProp[name] = (self._sparsProp[name] or 0) + sparConfig[name]
	        end
	        if strengthProp[name] ~= nil then
	        	self._sparsProp[name] = (self._sparsProp[name] or 0) + strengthProp[name]
	        end
	        if gradeConfig[name] ~= nil  and not value.isAllTeam  then --剔除升星SS外骨带来的全队属性加成
	        	self._sparsProp[name] = (self._sparsProp[name] or 0) + gradeConfig[name]
	        end
	        if absorbConfig and absorbConfig[name] ~= nil  and not value.isAllTeam  then 
	        	self._sparsProp[name] = (self._sparsProp[name] or 0) + absorbConfig[name]
	        end

	    end
	    sparsCount = sparsCount + 1
	    masterLevel = masterLevel or spar.level
	    masterLevel = math.min(masterLevel, spar.level)
    end
    
    --计算大师属性
    if sparsCount == 2 then
    	local masterConfig = {}
    	masterLevel = db:getStrengthenMasterByLevel("jingshiqianghua_master_", masterLevel)
    	if masterLevel > 0 then
    		masterConfig = db:getStrengthenMasterByMasterLevel("jingshiqianghua_master_", masterLevel)
    	end
    	masterConfig = masterConfig or {}

	    self:_analysisProp(self._sparsProp, masterConfig, "sparMaster")
    end
end

function QActorProp:_countHeadListProp(headProp)
	self._headProp = headProp
end

--处理所有属性
function QActorProp:_handleAllPropWithoutCount()
	self._totalProp = {}
    local config = db:getConfiguration()
    self._totalProp["base_effect"] = config.BASE_ATTACK_HP_EFFECT.value or 0

    self:_analysisProp(self._totalProp, self._actorProp, "character", "基础属性")
    self:_analysisProp(self._totalProp, self._equipmentProp, "equipment", "装备属性")
    self:_analysisProp(self._totalProp, self._breakProp, "breakthrough", "突破属性")
    self:_analysisProp(self._totalProp, self._gradeProp, "grade", "升星属性")
    self:_analysisProp(self._totalProp, self._trainingProp, "training", "培养属性")
    self:_analysisProp(self._totalProp, self._skillProp, "skill", "技能属性")
    self:_analysisProp(self._totalProp, self._masterProp, "master", "成长大师属性")
    self:_analysisProp(self._totalProp, self._archaeologyProp, "archaeology", "考古属性")
    self:_analysisProp(self._totalProp, self._soulTrialProp, "soulTrial", "斗罗武魂属性")
    self:_analysisProp(self._totalProp, self._unionSkillProp, "unionSkill", "宗门魂技属性")
    self:_analysisProp(self._totalProp, self._avatarProp, "avatar", "头像框属性")
    self:_analysisProp(self._totalProp, self._gemstoneProp, "gemstone", "魂骨属性")
    self:_analysisProp(self._totalProp, self._glyphTeamProp, "glyphTeam", "体技全队属性")
    self:_analysisProp(self._totalProp, self._badgeProp, "badge")
    self:_analysisProp(self._totalProp, self._mountCombinationProp, "mountCombinationProp", "暗器图鉴属性")
    self:_analysisProp(self._totalProp, self._soulSpiritCombinationProp, "soulSpiritCombinationProp", "魂灵图鉴属性")
    self:_analysisProp(self._totalProp, self._godarmReformProp,"godarmReformProp", "神器图鉴属性")
    self:_analysisProp(self._totalProp, self._mountProp, "mountProp", "暗器属性")
    self:_analysisProp(self._totalProp, self._refineProp, "refineProp", "洗练属性")
    self:_analysisProp(self._totalProp, self._artifactProp, "artifactProp", "武魂真身属性")
    self:_analysisProp(self._totalProp, self._dragonTotemProp, "dragonTotemProp", "武魂之力属性")    
    self:_analysisProp(self._totalProp, self._sparsProp, "sparsProp", "外附魂骨属性")    
	self:_analysisProp(self._totalProp, self._headProp, "headProp", "头像属性")
	self:_analysisProp(self._totalProp, self._magicHerbsProp, "magicHerbsProp", "仙品属性")
    self:_analysisProp(self._totalProp, self._soulSpiritProp, "soulSpiritProp", "魂灵属性") 
    self:_analysisProp(self._totalProp, self._godSkillProp, "godSkillProp", "神技属性")
    self:_analysisProp(self._totalProp, self._gemstoneAdvancedSkillProp, "gemstoneSkillProp", "魂骨进阶技能属性")
    self:_analysisProp(self._totalProp, self._gemstoneGodSkillProp, "gemstoneGodSkillProp", "魂骨化神技能属性")
    self:_analysisProp(self._totalProp, self._attrListProp, "attrListProp", "魂导科技、暗器改造全队属性")

    if self._extraProp then
	    for key, value in pairs(self._extraProp) do
	    	if not app.extraProp:isBattleProp(key) then
		    	local propName = ""
		    	if app.extraProp and app.extraProp.EXTRAPROP_NAME then
		    		propName = app.extraProp.EXTRAPROP_NAME[key] or ""
		    	end
		    	self:_analysisProp(self._totalProp, value, "extraProp_"..tostring(key), propName)
		    end
	    end
	end

    if ENABLE_GLYPH then
    	self:_analysisProp(self._totalProp, self._glyphProp, "glyph", "体技属性")
    end
    if ENABLE_HERO_COMBINATION then
    	self:_analysisProp(self._totalProp, self._combinationProp, "combination", "魂师宿命属性")
    end
    --计算附加属性
    for key,props in pairs(self._extendsProp) do
    	self:_analysisProp(self._totalProp, props, key)
    end 
end


--计算所有属性
function QActorProp:_countAllProp()
	self:_handleAllPropWithoutCount()

	for name,filed in pairs(QActorProp._field) do
		if filed.isFinal == true then
    		self:_countSingleProp(self._totalProp, name)
		end
	end
end

--遍历属性计算到table中
function QActorProp:_analysisProp(propTbl, info, target, propName)
	if self._isPrint == true and target ~= nil then
		if propName then
			trace(propName..": ")
		end
		trace("{")
	end
	for name,filed in pairs(QActorProp._field) do
		if propTbl[name] == nil then
			propTbl[name] = filed.value
		end
		if info[name] ~= nil then
			propTbl[name] = info[name] + propTbl[name]		
		end
		if self._isPrint == true and target ~= nil then
			if info[name] ~= nil and info[name] > 0 then
				if propName then
					trace("	"..filed.name.."("..name..")".." + "..info[name], "DEBUG_PROP")
				else
					trace("	"..target..": "..name.." + "..info[name], "DEBUG_PROP")
				end
			end
		end
	end
	if self._isPrint == true and target ~= nil then
		trace("}")
	end
end

--计算指定的table单个属性
function QActorProp:_countSingleProp(tbl, propName)
	local config = QActorProp._field[propName]
	if config == nil then 
		printf(propName.." can't find in QActorProp table")
		return 0 
	end
	local composeStr = ""
	if config.compose ~= nil then
		if self._isPrint == true then
			composeStr = composeStr .. "("..propName..": "..tbl[propName].." + "
		end
		local composeFileds = config.compose
		for index,filedName in pairs(composeFileds) do
            local countValue = self:_countSingleProp(tbl, filedName)
			tbl[propName] = tbl[propName] + countValue
			if self._isPrint == true then
				composeStr = composeStr..filedName..": "..countValue
				if index < #composeFileds then
					composeStr = composeStr.." + "
				end
			end
		end
		if self._isPrint == true then
			composeStr = composeStr .. ")"
		end
	end
	local targetValue = tbl[propName]
	if config.coefficient ~= nil then
		if self._isPrint == true then
			if composeStr ~= "" then
				composeStr = composeStr.. " * "
	        else
	            composeStr = "("..propName..": "..tbl[propName]..") * "
			end
			composeStr = composeStr .. "("
		end
		local coefficientFileds = config.coefficient
        local coefficientValue = 0
		for index,filedName in pairs(coefficientFileds) do
			if filedName == "level" then
				coefficientValue = (self:getLevel() or 0) - 1
			else
                coefficientValue = coefficientValue + self:_countSingleProp(tbl, filedName)
			end
			if self._isPrint == true then
				if filedName == "level" then
					composeStr = composeStr.." level: "..(self:getLevel() or 0) - 1
				else
	                composeStr = composeStr.." "..filedName..": "..tbl[filedName]
				end
				if index < #coefficientFileds then
					composeStr = composeStr.." + "
				end
			end
		end
        targetValue = targetValue * (coefficientValue + 1)
		if self._isPrint == true then
	        composeStr = composeStr .. "+ 1) "
	    end
	end
	tbl[propName] = targetValue
	if self._isPrint == true then
		if composeStr ~= "" then
			composeStr = " = "..composeStr
		end
		trace(config.name..": "..targetValue..composeStr, "DEBUG_PROP")
	end
	return targetValue
end

--[[
	添加附加属性
]]
function QActorProp:addExtendsProp(prop, extendName)
	self._extendsProp[extendName] = prop
	self:_countAllProp()
end

--[[
	移除附加属性
]]
function QActorProp:removeExtendsProp(extendName)
	self._extendsProp[extendName] = nil
	self:_countAllProp()
end


--获取是否添加了特殊属性
function QActorProp:getIsHasExtendsProp(extendName)
	if extendName ~= nil then
		return self._extendsProp[extendName] ~= nil
	end
	for _,value in pairs(self._extendsProp) do
		return true
	end
end

--[[
	添加洗炼属性
]]
function QActorProp:addRefineProp()
	self:_countRefineProperties(self._heroInfo.refineAttrs or {}) 
	self:_countAllProp()
end

--[[
	移除洗炼方面的所有属性
]]
function QActorProp:removeRefineProp()
	self:_countRefineProperties({}) 
	self:_countAllProp()
end

--[[
	添加预备洗炼属性
]]
function QActorProp:addWillRefineProp( prop )
	self:_countRefineProperties(prop or {}) 
	self:_countAllProp()
end

--[[
	获取UI属性
]]
function QActorProp:getUIProp()
	local prop = {}
	for name,filed in pairs(QActorProp._field) do
		if filed.showUI == true then
			prop[name] = self._totalProp[name]
		end
	end
	return prop
end

--[[
    计算战斗力
]]
function QActorProp:getLocalBattleForceByProp(prop)
    if prop == nil then prop = self._totalProp end
    local force = 0
    for name,filed in pairs(QActorProp._field) do
        if filed.forceWord ~= nil and prop[name] ~= nil then
        	local rate = self._forceConfig[filed.forceWord] or 0
        	if filed.forceField ~= nil then
        		rate = rate * (prop[filed.forceField] or 0)
        	end
            force = force + prop[name] * rate
        end
    end
    force = math.floor(force + (self._skillForce or 0) + (self._mountForce or 0) + (self._artifactForce or 0) + (self._dragonTotemForce or 0))
    return force
end

function QActorProp:getLocalBattleForce()
	local forceConfig = db:getForceConfigByLevel(self:getLevel())

	--[===[
		修改了一下战斗力计算的代码
		以前的代码是
		local force = 0
		force = force + forceAttack
		force = force + forceHp
		因为战斗力的属性比较多，这样的话 战斗力的来源不是很清楚不方便查
		现在修改了一下 用了一个table来储存战斗力，重写了__newindex
		增加战斗力的时候只需要
		force.forceAttack = forceAttack
		值会自动加到 total_force 变量内
		如果键重复了 会把前一个的键的值从total_force减去再重新添加新值

		要查看战斗力的每个数值的来源只需要printTable(force)即可
	]===]
	local force = {}
	force.actorId = self:getActorId()--这行一定要放在setmetatable前面
	local total_force = 0
	local key_cache = {}
	setmetatable(force,{ __newindex = function(t,k,v)
										if type(v) ~= "number" then return end
										if key_cache[k] then
											total_force = total_force - rawget(t,k)
										else
											key_cache[k] = true
										end
										rawset(t,k,v)
										total_force = total_force + v
									end})

	local forceAttack = self:getMaxAttack() * forceConfig["attack"]
	local forceHp = self:getMaxHp() * forceConfig["hp"]
	local hit = self:getMaxHit()
	local forceHit = hit / (hit + self._coConfig.hit) * forceAttack * 3 / 4
	local dodge = self:getMaxDodge()
	local forceDodge = (dodge / (dodge + self._coConfig.dodge)) * forceHp
	local crit = self:getMaxCrit()
	local forceCrit = crit / (crit + self._coConfig.crit) * forceAttack * 3 / 4
	local critReduce = self:getMaxCriReduce()
	local forceCritReduce = (critReduce / (critReduce + self._coConfig.cri_reduce)) * forceHp
	local wreck = self:getMaxWreck()
	local forceWreck = wreck / (wreck + self._coConfig.wreck) * forceAttack * 3 / 8
	local block = self:getMaxBlock()
	local forceBlock = block / (block + self._coConfig.block) * forceHp / 2

	local hit_chance = self:getHitChance()
	local forceHitChance = hit_chance * forceAttack * 3 / 4
	local dodge_chance = self:getDodgeChance()
	local forceDodgeChance = dodge_chance * forceHp
	local critical_chance = self:getMaxCriticalChance()
	local forceCritChance = critical_chance * forceAttack * 3 / 4
	local cri_reduce_chance = self:getMaxCriReduceChance()
	local forceCritReduceChance = cri_reduce_chance * forceHp
	local wreck_chance = self:getWreckChance()
	local forceWreckChance = wreck_chance * forceAttack * 3 / 8
	local block_chance = self:getBlockChance()
	local forceBlockChance = block_chance * forceHp / 2

	local coConfig = db:getLevelCoefficientByLevel(tostring(self:getLevel()))
	if coConfig and coConfig.haste then
		-- BY Kumo 这里是攻速战斗力
		force.forceHist = (self:getMaxHaste() / coConfig.haste) / 100 * self:getMaxAttack() * forceConfig["attack"]
	end

	-- BY Kumo 攻击战斗力和生命战斗力，在最后合成总战斗力之前，添加物理加伤、法术加伤、治疗效果、受治疗效果，4属性的战斗力
	force.forceAttack = forceAttack * (1 + self:getPhysicalDamagePercentAttack()/2 + self:getMagicDamagePercentAttack()/2 + self:getMagicTreatPercentAttack())
	force.forceHp = forceHp * (1 + self:getPhysicalDamagePercentBeattackReduceTotal()/2 + self:getMagicDamagePercentBeattackReduceTotal()/2 + self:getMagicTreatPercentBeattackTotal())

	force.armor_physical = self:getMaxArmorPhysical() * forceConfig["armor_physical"]
	force.armor_magic = self:getMaxArmorMagic() * forceConfig["armor_magic"]
	force.physical_penetration = self:getMaxPhysicalPenetration() * forceConfig["physical_penetration"]
	force.magic_penetration  = self:getMaxMagicPenetration() * forceConfig["magic_penetration"]
	force.forceHit = forceHit
	force.forceDodge = forceDodge
	force.forceCrit = forceCrit
	force.forceCritReduce = forceCritReduce
	force.forceWreck = forceWreck
	force.forceBlock = forceBlock

	force.forceHitChance = forceHitChance
	force.forceDodgeChance = forceDodgeChance
	force.forceCritChance = forceCritChance
	force.forceCritReduceChance = forceCritReduceChance
	force.forceWreckChance = forceWreckChance
	force.forceBlockChance = forceBlockChance


	force.totalProp = self:getLocalBattleForceByProp(self._totalProp)

	return math.floor(total_force)
end

--[[
    获取战斗力
]]
function QActorProp:getBattleForce(islocal)
    if islocal == true then
        return self:getLocalBattleForce()
    end
    local force = 0
    if self._heroInfo ~= nil and self._heroInfo.force ~= nil then
        force = self._heroInfo.force
    end

    return force
end

--最大生命值
function QActorProp:getMaxHp()
	return self._totalProp["hp_total"]
end

function QActorProp:getHpGrow()
	return self._totalProp["hp_grow"]
end

function QActorProp:getHpDetail()
	return self._totalProp["hp_base_total"], self._totalProp["hp_percent"]
end

--最大攻击
function QActorProp:getMaxAttack()
	return self._totalProp["attack_total"]
end

function QActorProp:getAttackGrow()
	return self._totalProp["attack_grow"]
end

function QActorProp:getAttackDetail()
	return self._totalProp["attack_base_total"], self._totalProp["attack_percent"]
end

--最大物理防御
function QActorProp:getMaxArmorPhysical()
	return self._totalProp["armor_physical_total"]
end

function QActorProp:getArmorPhysicalGrow()
	return self._totalProp["armor_physical_grow"]
end

function QActorProp:getArmorPhysicalDetail()
	return self._totalProp["armor_physical"], self._totalProp["armor_physical_percent"]
end

--最大魔法防御
function QActorProp:getMaxArmorMagic()
	return self._totalProp["armor_magic_total"]
end

function QActorProp:getArmorMagicGrow()
	return self._totalProp["armor_magic_grow"]
end

function QActorProp:getArmorMagicDetail()
	return self._totalProp["armor_magic"], self._totalProp["armor_magic_percent"]
end

--最大物理穿透
function QActorProp:getMaxPhysicalPenetration()
	return self._totalProp["physical_penetration"]
end

function QActorProp:getPhysicalPenetrationDetail()
	return self._totalProp["physical_penetration_value"], self._totalProp["physical_penetration_percent"]
end

--最大法术穿透
function QActorProp:getMaxMagicPenetration()
	return self._totalProp["magic_penetration"]
end

function QActorProp:getMagicPenetrationDetail()
	return self._totalProp["magic_penetration_value"], self._totalProp["magic_penetration_percent"]
end

--最大命中
function QActorProp:getMaxHit()
	return self._totalProp["hit_total"]
end

function QActorProp:getHitGrow()
	return self._totalProp["hit_grow"]
end

function QActorProp:getHitDetail()
	return self._totalProp["hit_rating"], self._totalProp["hit_percent"]
end

--最大闪避
function QActorProp:getMaxDodge()
	return self._totalProp["dodge_total"]
end

function QActorProp:getDodgeGrow()
	return self._totalProp["dodge_grow"]
end

function QActorProp:getDodgeDetail()
	return self._totalProp["dodge_rating"], self._totalProp["dodge_percent"]
end

--最大格挡
function QActorProp:getMaxBlock()
	return self._totalProp["block_total"]
end

function QActorProp:getBlockGrow()
	return self._totalProp["block_grow"]
end

function QActorProp:getBlockDetail()
	return self._totalProp["block_rating"], self._totalProp["block_percent"]
end

--最大破击
function QActorProp:getMaxWreck()
	return self._totalProp["wreck_total"]
end

function QActorProp:getWreckGrow()
	return self._totalProp["block_grow"]
end

function QActorProp:getWreckDetail()
	return self._totalProp["wreck_rating"], self._totalProp["wreck_percent"]
end

--最大暴击
function QActorProp:getMaxCrit()
	return self._totalProp["critical_total"]
end

function QActorProp:getCritGrow()
	return self._totalProp["critical_grow"]
end

function QActorProp:getCritDetail()
	return self._totalProp["critical_rating"], self._totalProp["critical_percent"]
end

--最大暴击率
function QActorProp:getMaxCriticalChance()
	return self._totalProp["critical_chance_total"]
end

function QActorProp:getCriticalChanceGrow()
	return self._totalProp["critical_chance_grow"]
end

function QActorProp:getCriticalChanceDetail()
	return self._totalProp["critical_chance"], self._totalProp["critical_chance_percent"]
end

--最大抗暴等级
function QActorProp:getMaxCriReduce()
	return self._totalProp["cri_reduce_rating_total"]
end

function QActorProp:getCriReduceGrow()
	return self._totalProp["cri_reduce_grow"]
end

function QActorProp:getCriReduceDetail()
	return self._totalProp["cri_reduce_rating"], self._totalProp["cri_reduce_percent"]
end

--最大抗暴击率
function QActorProp:getMaxCriReduceChance()
	return self._totalProp["cri_reduce_chance_total"]
end

function QActorProp:getCriReduceChanceGrow()
	return self._totalProp["cri_reduce_chance_grow"]
end

function QActorProp:getCriReduceChanceDetail()
	return self._totalProp["cri_reduce_chance"], self._totalProp["cri_reduce_chance_percent"]
end

--最大攻速
function QActorProp:getMaxHaste()
	return self._totalProp["haste_total"]
end

function QActorProp:getHasteGrow()
	return self._totalProp["haste_grow"]
end

function QActorProp:getHasteDetail()
	return self._totalProp["haste_rating"], self._totalProp["haste_percent"]
end

--PVP物理伤害加成
function QActorProp:getPVPPhysicalAttackPercent()
    return self._totalProp["pvp_physical_damage_percent_attack_total"]
end

--考古PVP物理伤害加成
function QActorProp:getArchaeologyPVPPhysicalAttackPercent( ... )
	local key = "pvp_physical_damage_percent_attack"
	local archaeologyPVP = self._archaeologyProp[key] or 0
	local fashionPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.FASHION_TEAM_PROP] then
		fashionPVP = self._extraProp[app.extraProp.FASHION_TEAM_PROP][key] or 0
	end
	local handbookPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVP = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return  archaeologyPVP + fashionPVP + handbookPVP
end

--PVP魔法伤害加成
function QActorProp:getPVPMagicAttackPercent()
    return self._totalProp["pvp_magic_damage_percent_attack_total"]
end

--考古PVP魔法伤害加成
function QActorProp:getArchaeologyPVPMagicAttackPercent()
	local key = "pvp_magic_damage_percent_attack"
	local archaeologyPVP = self._archaeologyProp[key] or 0
	local fashionPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.FASHION_TEAM_PROP] then
		fashionPVP = self._extraProp[app.extraProp.FASHION_TEAM_PROP][key] or 0
	end
	local handbookPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVP = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return  archaeologyPVP + fashionPVP + handbookPVP
end

--PVP物理伤害减免
function QActorProp:getPVPPhysicalReducePercent()
    return self._totalProp["pvp_physical_damage_percent_beattack_reduce_total"]
end

--考古PVP物理伤害减免
function QActorProp:getArchaeologyPVPPhysicalReducePercent()
	local key = "pvp_physical_damage_percent_beattack_reduce"
	local archaeologyPVP = self._archaeologyProp[key] or 0
	local fashionPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.FASHION_TEAM_PROP] then
		fashionPVP = self._extraProp[app.extraProp.FASHION_TEAM_PROP][key] or 0
	end
	local handbookPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVP = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return  archaeologyPVP + fashionPVP + handbookPVP
end

--PVP魔法伤害减免
function QActorProp:getPVPMagicReducePercent()
    return self._totalProp["pvp_magic_damage_percent_beattack_reduce_total"]
end

--考古PVP魔法伤害减免
function QActorProp:getArchaeologyPVPMagicReducePercent()
	local key = "pvp_magic_damage_percent_beattack_reduce"
	local archaeologyPVP = self._archaeologyProp[key] or 0
	local fashionPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.FASHION_TEAM_PROP] then
		fashionPVP = self._extraProp[app.extraProp.FASHION_TEAM_PROP][key] or 0
	end
	local handbookPVP = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVP = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return  archaeologyPVP + fashionPVP + handbookPVP
end

--PVE主力物理伤害加成
function QActorProp:getPVEDamageAttackPercent( ... )
	local key = "pve_damage_percent_attack"
	local handbookPVE = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVE = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return handbookPVE
end

--PVE主力物理减伤加成
function QActorProp:getPVEDamageBeattackPercent( ... )
	local key = "pve_damage_percent_beattack"
	local handbookPVE = 0 
	if self._extraProp and self._extraProp[app.extraProp.HANDBOOK_PROP] then
		handbookPVE = self._extraProp[app.extraProp.HANDBOOK_PROP][key] or 0
	end
    return handbookPVE
end

--急速率
function QActorProp:getAttackSpeedChance()
    return self._totalProp["attackspeed_chance_total"]
end

--命中率
function QActorProp:getHitChance()
    return self._totalProp["hit_chance_total"]
end

--闪避率
function QActorProp:getDodgeChance()
    return self._totalProp["dodge_chance_total"]
end

--格挡率
function QActorProp:getBlockChance()
    return self._totalProp["block_chance_total"]
end

--破击率
function QActorProp:getWreckChance()
    return self._totalProp["wreck_chance_total"]
end

--物理伤害提升
function QActorProp:getPhysicalDamagePercentAttack()
    return self._totalProp["physical_damage_percent_attack_total"]
end

--法术伤害提升
function QActorProp:getMagicDamagePercentAttack()
    return self._totalProp["magic_damage_percent_attack_total"]
end

--治疗提升
function QActorProp:getMagicTreatPercentAttack()
    return self._totalProp["magic_treat_percent_attack_total"]
end

--物理易伤
function QActorProp:getPhysicalDamagePercentBeattackTotal()
    return self._totalProp["physical_damage_percent_beattack_total"]
end

--物理免伤
function QActorProp:getPhysicalDamagePercentBeattackReduceTotal()
    return self._totalProp["physical_damage_percent_beattack_reduce_total"]
end

--法术易伤
function QActorProp:getMagicDamagePercentBeattackTotal()
    return self._totalProp["magic_damage_percent_beattack_total"]
end

--法术免伤
function QActorProp:getMagicDamagePercentBeattackReduceTotal()
    return self._totalProp["magic_damage_percent_beattack_reduce_total"]
end

--被治疗效果提升
function QActorProp:getMagicTreatPercentBeattackTotal()
    return self._totalProp["magic_treat_percent_beattack_total"]
end

--魂灵伤害增加
function QActorProp:getSoulDamageAttackTotal()
	return self._totalProp["soul_damage_percent_attack"]
end

--魂灵伤害减免
function QActorProp:getSoulDamageBeattackReduceTotal()
	return self._totalProp["soul_damage_percent_beattack_reduce"]
end

function QActorProp:getOnlyBattleProp(key)
	local propDict = self._extraProp[app.extraProp.HANDBOOK_BATTLE_PROP]
	if propDict and propDict[key] then
		return propDict[key]
	end
	return 0
end

function QActorProp:getItemAllPropByitemId(itemId, streng, magic, actorId)
    local itemInfo = db:getItemByID(itemId)
    -- TOFIX: SHRINK
    itemInfo = q.cloneShrinkedObject(itemInfo)
    -- local itemConfig = db:getItemByID(itemId)
    -- assert(itemConfig ~= nil,"itemId: "..itemId.." is can't find in itemConfig")
    local enhance = db:getTotalEnhancePropByLevel(itemInfo.enhance_data, streng)
    local enchant = db:getTotalEnchantPropByLevel(itemId, magic, actorId)
    enchant = q.cloneShrinkedObject(enchant)
    for name,value in pairs(QActorProp._field) do
        if value.magicType ~= nil then
            if enchant[name] ~= nil then
                enchant[value.magicType] = enchant[name] * streng
                enchant[name] = 0
            end
        end
    end
    for prop, value in pairs(enhance) do 
        if itemInfo[prop] ~= nil and type(value) == "number" then
           	itemInfo[prop] = itemInfo[prop] + (enhance[prop] or 0)
        end
    end
    for prop, value in pairs(enchant) do 
        if type(value) == "number" then
        	itemInfo[prop] = (itemInfo[prop] or 0) + (enchant[prop] or 0)
        end
    end
    return itemInfo
end

function QActorProp:getEquipeName(actorId, itemId)
	local characterInfo = db:getCharacterByID(actorId)
	local item = _equipment[characterInfo.talent][itemId]
	if item then
		return item.pos
	end
end

--获取某个魂师某个装备的突破信息
function QActorProp:getEquipeBreakInfo(actorId, itemId)
	local characterInfo = db:getCharacterByID(actorId)
	return _equipment[characterInfo.talent][itemId].breakInfo
end

function QActorProp:getGlyphProp()
	return self._glyphProp or {}
end

function QActorProp:logFile(msg)
	appendToFile(self._logFile, msg.."\n")
end

function QActorProp:getPropValueByKey(propKey)
	return self._totalProp[propKey] or 0
end

function QActorProp:getRageTotal()
    return 1000
end

function QActorProp:getPropFields()
    return self._field
end

function QActorProp:getPropFieldByKey(propKey)
    return self._field[propKey]
end

--[[
	从配置里叠加属性，用于ui显示
	{
		"hp_value" = {
			name = "hp_value",
			value = 1000,
			isPercent = false,
		}
	}
]]--
function QActorProp:getPropUIByConfig(propConfig, propTbl)
	propTbl = propTbl or {}
    for key, value in pairs(propConfig or {}) do
        if self._field[key] ~= nil then
        	if not propTbl[key] then
        		propTbl[key] = {}
            	propTbl[key].value = 0
           		propTbl[key].name = self._field[key].name
           		propTbl[key].isPercent = self._field[key].isPercent
        	end
            propTbl[key].value = propTbl[key].value + value
        end
    end
    return propTbl
end

--[[
	从配置里叠加属性，用于实际属性
	{
		"hp_value" = 1000,
	}
]]--
function QActorProp:getPropByConfig(propConfig, propTbl)
	propTbl = propTbl or {}
    for key, value in pairs(propConfig or {}) do
        if self._field[key] ~= nil then
        	if propTbl[key] then
        		propTbl[key] = propTbl[key] + value
        	else
        		propTbl[key] = value
        	end
        end
    end
    return propTbl
end

function QActorProp:getPropIndexByKey(propKey)
	local index = 1

    if propKey == "attack_percent" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "hp_percent" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "armor_physical_percent" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "armor_magic_percent" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "attack_value" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "hp_value" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "armor_physical" then
    	return index
    else
    	index = index + 1
    end

    if propKey == "armor_magic" then
    	return index
    else
    	index = index + 1
    end

    return 9999999
end


return QActorProp