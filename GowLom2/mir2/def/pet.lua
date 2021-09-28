local pet = {}
local baseCfg = import("csv2cfg.PetBaseCfg")
local rareExtra = import("csv2cfg.PetRareQuaExtraCfg")
local aptBapWeightCfg = import("csv2cfg.PetAptBapWeightCfg")
local aptBapPropertyCfg = import("csv2cfg.PetAptPropertyCfg")
local skinCfg = import("csv2cfg.PetSkinBaseCfg")
local upCfg = import("csv2cfg.PetUpCfg")

for i, v in ipairs(baseCfg) do
	v.idx = i
end

for i, v in ipairs(upCfg) do
	v.idx = i
end

for i, v in ipairs(skinCfg) do
	v.idx = i
end

pet.level2str = function (wingLevel)
	if wingLevel <= 0 then
		return "一阶"
	end

	local level = wingLevel
	local n2s = {
		[0] = "零",
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十"
	}
	local num = level
	local l = math.floor(level/10)
	local r = level%10

	if 0 < r then
		l = l + 1
	elseif r == 0 then
		r = 10
	end

	return n2s[l] .. "阶" .. n2s[r] .. "星"
end
pet.getBaseCfg = function (self)
	return baseCfg
end
pet.getUpgradeCfg = function (self)
	return upCfg
end
pet.getBaseCfgByID = function (self, id)
	return baseCfg[id]
end
pet.getUpgradeCfgByLevel = function (self, level)
	return upCfg[level]
end
pet.getRareCfgByID = function (self, rarityid, quaid)
	local cfg = rareExtra[rarityid]

	if cfg then
		return cfg[quaid]
	end

	return nil
end
pet.getBaseSkinCfgByID = function (self, skinId)
	return skinCfg[skinId]
end
pet.getBaseSkin = function (self)
	return skinCfg
end
pet.getZizhiSuccessChance = function (self, level)
	local cfg = aptBapWeightCfg[level]
	local chance = 0

	if cfg then
		for i, v in ipairs(cfg) do
			if v.BapValue == 1 or v.BapValue == 2 or v.BapValue == 3 then
				chance = chance + v.Weight/100
			end
		end
	end

	return chance
end
pet.getZizhiProperty = function (self, level)
	return aptBapPropertyCfg[level]
end
pet.getRareColor = function (self, level)
	local colors = {
		cc.c3b(216, 231, 232),
		cc.c3b(50, 177, 108),
		cc.c3b(55, 148, 251),
		cc.c3b(194, 48, 255),
		cc.c3b(255, 138, 0)
	}

	return colors[level] or colors[1]
end
pet.getRareColorName = function (self, level)
	local colors = {
		"白",
		"绿",
		"蓝",
		"紫",
		"橙"
	}

	return colors[level] or colors[1]
end
pet.getJobPicName = function (self, qualityid)
	local pics = {
		[0] = "gong.png",
		"fa.png",
		"dao.png"
	}

	return pics[qualityid] or pics[1]
end
pet.getRarePicName = function (self, idx)
	local rare = {
		"white.png",
		"green.png",
		"blue.png",
		"purple.png",
		"orange.png"
	}

	return rare[idx]
end
pet.getHorseRare = function (self, idx)
	local rare = {
		"普通",
		"中级",
		"高级",
		"稀有",
		"极品"
	}

	return rare[idx]
end
pet.getJobName = function (self, idx)
	local job = {
		[0] = "攻击",
		"魔法",
		"道术"
	}

	return job[idx]
end
pet.computePetValue = function (prop, param, notNeedOrigin)
	if not prop then
		return prop
	end

	local origin = 1

	if notNeedOrigin then
		origin = 0
	end

	if type(param) == "number" then
		for i, strArr in pairs(prop) do
			for j = 2, #strArr, 1 do
				strArr[j] = origin*strArr[j] + strArr[j]*param
			end
		end
	elseif type(param) == "table" and param and 0 < #param then
		for i, strArr in ipairs(prop) do
			for k, strArr2 in ipairs(param) do
				if strArr[1] == strArr2[1] then
					for m = 2, #strArr, 1 do
						strArr[m] = strArr[m] + strArr2[m]
					end
				end
			end
		end
	end

	return prop
end

return pet
