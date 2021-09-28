local allUpCfg = import("csv2cfg.GodWeapon")
local solider = {}
local UPGRADE_MATERIAL1 = "玄铁石"
local UPGRADE_MATERIAL2 = "技能石"
local KEY_NEED_SERVER_STEP = "服务器阶段"
local KEY_NEED_PLAYER_LEVEL = "人物等级"
local KEY_NEED_GOLD = "金币"
solider.nameCfg = {
	"神舞",
	"太虚",
	"凤凰",
	"天晶"
}
solider.imgCfg = {
	"sw",
	"tx",
	"fh",
	"tj"
}
solider.allUpCfg = allUpCfg
local BASIC_SKILL_LIST = {
	"基本剑术",
	"刺杀剑术",
	"半月弯刀",
	"烈火剑法",
	"逐日剑法",
	"追心刺",
	"灭天火",
	"雷电术",
	"流星火雨",
	"冰咆哮",
	"冰天雪地",
	"召唤神兽",
	"噬血术",
	"灵魂火符",
	"万剑归宗"
}
local job_skill_prop = {
	召唤神兽怒之伤害 = 2,
	怒之烈火几率 = 0,
	雷电术怒之伤害 = 1,
	烈火剑法怒之伤害 = 0,
	怒之火雨几率 = 1,
	怒之烈火额外伤害 = 0,
	冰咆哮怒之伤害 = 1,
	噬血术怒之伤害 = 2,
	灵魂火符怒之伤害 = 2,
	怒之噬血几率 = 2,
	怒之噬血额外伤害 = 2,
	基本剑术怒之伤害 = 0,
	冰天雪地怒之伤害 = 1,
	追心刺怒之伤害 = 0,
	刺杀剑术怒之伤害 = 0,
	流星火雨怒之伤害 = 1,
	怒之火雨额外伤害 = 1,
	半月弯刀怒之伤害 = 0,
	万剑归宗怒之伤害 = 2,
	灭天火怒之伤害 = 1,
	逐日剑法怒之伤害 = 0
}
local PROP_ALIAS = {
	天晶 = "天晶",
	基本剑术怒之伤害 = "基本剑术伤害",
	魔法上限 = "魔法上限",
	刺杀剑术怒之伤害 = "刺杀剑术伤害",
	雷电术怒之伤害 = "雷电术伤害",
	万剑归宗等级 = "万剑归宗等级",
	道术下限 = "道术下限",
	半月弯刀怒之伤害 = "半月弯刀伤害",
	服务器阶段 = "服务器阶段",
	法师生命值 = "生命值",
	神兵 = "神兵",
	烈火剑法等级 = "烈火剑法等级",
	冰咆哮等级 = "冰咆哮等级",
	逐日剑法怒之伤害 = "逐日剑法伤害",
	流星火雨怒之伤害 = "流星火雨伤害",
	烈火剑法怒之伤害 = "烈火剑法伤害",
	召唤神兽等级 = "召唤神兽等级",
	噬血术怒之伤害 = "噬血术伤害",
	道士生命值 = "生命值",
	凤凰 = "凤凰",
	灵魂火符怒之伤害 = "灵魂火符伤害",
	道术上限 = "道术上限",
	怒之火雨几率 = "怒之火雨几率",
	战士生命值 = "生命值",
	玄铁石 = "玄铁石",
	怒之烈火额外伤害 = "怒之烈火伤害",
	灭天火怒之伤害 = "灭天火伤害",
	神兽形象改变 = "召唤怒之圣兽",
	怒之噬血额外伤害 = "怒之噬血伤害",
	追心刺怒之伤害 = "追心刺伤害",
	冰天雪地等级 = "冰天雪地等级",
	太虚 = "太虚",
	召唤神兽怒之伤害 = "召唤神兽伤害",
	攻击上限 = "攻击上限",
	怒之烈火几率 = "怒之烈火几率",
	冰咆哮怒之伤害 = "冰咆哮伤害",
	人物等级 = "人物等级",
	追心刺等级 = "追心刺等级",
	冰天雪地怒之伤害 = "冰天雪地伤害",
	技能石 = "技能石",
	怒之噬血几率 = "怒之噬血几率",
	魔法下限 = "魔法下限",
	神舞 = "神舞",
	怒之火雨额外伤害 = "怒之火雨伤害",
	万剑归宗怒之伤害 = "万剑归宗伤害",
	攻击下限 = "攻击下限"
}

local function nameInSolider(name)
	for i, v in pairs(def.solider.nameCfg) do
		if v == name then
			return true, i
		end
	end

	return false
end

local function nameInSkill(name)
	for i, v in ipairs(BASIC_SKILL_LIST) do
		if v .. "等级" == name then
			return true
		end
	end

	return false
end

solider.getCfg = function (self, id, level)
	for i, v in ipairs(allUpCfg) do
		if v.ID == id and v.GodWeaponLevel == level then
			return v
		end
	end

	return nil
end
solider.getNeedCfg = function (self, id, level, job)
	local cfg = self.getCfg(self, id, level)

	if not cfg then
		return nil
	end

	local ret = {
		upNeedstffCount = "",
		upNeedGold = 0,
		upNeedstff = "",
		upNeedLevel = 0,
		upNeedServerStep = 0,
		upProps = {},
		upNeedSolider = {},
		upNeedSkillLevel = {}
	}
	local prop = def.property.dumpPropertyStr(cfg.Request)

	if prop.get(prop, UPGRADE_MATERIAL1) then
		ret.upNeedstff = UPGRADE_MATERIAL1
	elseif prop.get(prop, UPGRADE_MATERIAL2) then
		ret.upNeedstff = UPGRADE_MATERIAL2
	end

	ret.upNeedstffCount = prop.get(prop, ret.upNeedstff)
	ret.upNeedLevel = prop.get(prop, KEY_NEED_PLAYER_LEVEL) or 0
	ret.upNeedServerStep = prop.get(prop, KEY_NEED_SERVER_STEP) or 0
	ret.upNeedGold = prop.get(prop, KEY_NEED_GOLD) or 0

	for i, v in ipairs(prop.props) do
		local name = v[1]
		local value = v[2]
		local inSolider, soliderIdx = nameInSolider(name)

		if inSolider then
			ret.upNeedSolider[soliderIdx] = value
		elseif nameInSkill(name) then
			local len = string.utf8len(name)
			local skillname = string.utf8sub(name, 1, len - 2)

			if job then
				if job == def.magic.getMagicJob(skillname) then
					ret.upNeedSkillLevel[skillname] = value
				end
			else
				ret.upNeedSkillLevel[skillname] = value
			end
		end
	end

	return ret
end
solider.getProps = function (self, id, level, job)
	local cfg = self.getCfg(self, id, level)

	if not cfg then
		return nil
	end

	local prop = def.property.dumpPropertyStr(cfg.GodWeaponProperty):clearZero():toStdProp()

	if job then
		prop.grepJob(prop, job)
	end

	local i = 1

	while i <= #prop.props do
		local v = prop.props[i]
		local j = job_skill_prop[v[1]]

		if j ~= nil and j ~= job then
			prop.del(prop, v[1])
		else
			i = i + 1
		end
	end

	return prop
end
solider.convertPropName = function (self, name)
	return PROP_ALIAS[name] or name
end

return solider
