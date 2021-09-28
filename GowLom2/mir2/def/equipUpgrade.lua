local equipUpgrade = {}
local upAbility = import("csv2cfg.WeaponUpAbil")
local upChance = import("csv2cfg.WeaponUpChance")
local upStuff = import("csv2cfg.WeaponUpStuff")
local upProtect = import("csv2cfg.WeaponUpProtect")
local upTrans = import("csv2cfg.WeaponUpTrans")
local property_name = {
	"攻击",
	"魔法",
	"道术",
	"准确",
	"强攻概率",
	"暴击概率"
}
equipUpgrade.getUpAbility = function (self, itemLevel, abilityType, upLevel)
	for i, v in pairs(upAbility) do
		if v.AbilType == abilityType and v.UpLevel == upLevel and v.ItemLevel == itemLevel then
			local s = string.split(v.Abil, ";")
			local abilitys = {}

			for i, v in ipairs(s) do
				local ss = string.split(v, "=")

				if #ss == 2 then
					abilitys[ss[1]] = tonumber(ss[2])
				end
			end

			return abilitys
		end
	end

	return {}
end

local function attr2Text(text, key, abilitys)
	local front = abilitys[key .. "下限"] or 0
	local after = abilitys[key .. "上限"] or 0

	if 0 < front or 0 < after then
		return text .. front .. "-" .. after
	end

	return nil
end

local function attrText(text, key, abilitys)
	local value = abilitys[key] or 0

	if 0 < value then
		return text .. value
	end

	return nil
end

equipUpgrade.getAbilityDesc = function (self, abilitys)
	local desc = {}

	local function add(txt)
		if txt then
			table.insert(desc, txt)
		end

		return 
	end

	slot3(attr2Text("攻击: ", "攻击", abilitys))
	add(attr2Text("魔法: ", "魔法", abilitys))
	add(attr2Text("道术: ", "道术", abilitys))
	add(attrText("准确: +", "准确", abilitys))
	add(attrText("暴击概率: +", "暴击概率", abilitys))
	add(attrText("强攻概率: +", "强攻概率", abilitys))

	return desc
end
equipUpgrade.getMaxUpLevel = function (self, itemLevel)
	local max = 0

	for i, v in pairs(upAbility) do
		if v.ItemLevel == itemLevel and max < v.UpLevel then
			max = v.UpLevel
		end
	end

	return max
end
equipUpgrade.getUpgradeChance = function (self, level)
	for i, v in pairs(upChance) do
		if v.UpLevel == level then
			return v.SuccChance/100
		end
	end

	return nil
end
equipUpgrade.getUpgradeStuff = function (self, itemLevel, upLevel)
	for i, v in pairs(upStuff) do
		if v.UpLevel == upLevel and v.ItemLevel == itemLevel then
			local s = string.split(v.Stuff, ";")
			local abilitys = {}

			for i, v in ipairs(s) do
				local ss = string.split(v, "=")

				if #ss == 2 then
					abilitys[ss[1]] = tonumber(ss[2])
				end
			end

			return abilitys
		end
	end

	return nil
end
equipUpgrade.getUpgradeProtectCount = function (self, upLevel)
	for i, v in pairs(upProtect) do
		if v.UpLevel == upLevel then
			return v.NeedNum
		end
	end

	return nil
end
equipUpgrade.getUpgradeTransCount = function (self, itemLevel)
	for i, v in pairs(upTrans) do
		if v.ItemLevel == itemLevel then
			return v.NeedNum
		end
	end

	return nil
end

return equipUpgrade
