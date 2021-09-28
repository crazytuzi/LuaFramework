local horse = {
	openDay = 18
}
local baseCfg = import("...csv2cfg.HorseBaseCfg")
local quaExtra = import("...csv2cfg.HorseQuaExtra")
local upCfg = import("...csv2cfg.HorseUpCfg")

for i, v in ipairs(baseCfg) do
	v.idx = i
end

for i, v in ipairs(quaExtra) do
	v.idx = i
end

for i, v in ipairs(upCfg) do
	v.idx = i
end

horse.level2str = function (wingLevel)
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
horse.getBaseCfg = function (self)
	return baseCfg
end
horse.getQualityCfg = function (self)
	return quaExtra
end
horse.getUpgradeCfg = function (self)
	return upCfg
end
horse.getBaseCfgByID = function (self, horseid)
	return baseCfg[horseid]
end
horse.getUpgradeCfgByLevel = function (self, level)
	return upCfg[level]
end
horse.getRareColor = function (self, level)
	local colors = {
		cc.c3b(216, 231, 232),
		cc.c3b(50, 177, 108),
		cc.c3b(55, 148, 251),
		cc.c3b(194, 48, 255),
		cc.c3b(255, 138, 0)
	}

	return colors[level] or colors[1]
end
horse.getJobPicName = function (self, qualityid)
	local pics = {
		[0] = "gong.png",
		"fa.png",
		"dao.png"
	}

	return pics[qualityid]
end
horse.getRarePicName = function (self, idx)
	local rare = {
		"white.png",
		"green.png",
		"blue.png",
		"purple.png",
		"orange.png"
	}

	return rare[idx]
end
horse.getHorseRare = function (self, idx)
	local rare = {
		"普通",
		"中级",
		"高级",
		"稀有",
		"极品"
	}

	return rare[idx]
end

return horse
