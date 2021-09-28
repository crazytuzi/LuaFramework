local magic = {
	skillLvlEffect,
	skillLvlEffect = import("csv2cfg.MagicSpecEffectMgr"),
	getConfig = function (key)
		if not magic[key] then
			magic[key] = parseJson("config/" .. key .. ".json")
		end

		return magic[key]
	end,
	getEffctIdByLvl = function (magicid, lvl)
		for i, v in ipairs(magic.skillLvlEffect) do
			if v.Magicid == magicid and v.SkillLv == lvl then
				return v.Effect
			end
		end

		return nil
	end,
	getMagicConfig = function (effectID)
		for _, info in ipairs(magic.getConfig("skillMagic")) do
			if info.effectID == tonumber(effectID) then
				return info
			end
		end

		return 
	end,
	getMagicConfigByUid = function (magicId, magicLvl)
		magicLvl = magicLvl or 1
		local effectID = magic.getEffctIdByLvl(tonumber(magicId), tonumber(magicLvl))

		if not effectID then
			return 
		end

		for _, info in ipairs(magic.getConfig("skillMagic")) do
			if effectID == info.effectID and tonumber(magicId) == tonumber(info.uid) then
				return info
			end
		end

		return 
	end
}
local verString = "180"

local function valInTable(val, t)
	for i, v in ipairs(t) do
		if val == v then
			return true
		end
	end

	return false
end

magic.getMagicIds = function (job, isHero)
	local ret = {}

	for _, info in ipairs(magic.getConfig("skillMagic")) do
		local verAllow = true

		if info.version then
			verAllow = false

			for _, version in ipairs(info.version) do
				if tostring(version) == tostring(verString) then
					verAllow = true
				end
			end
		end

		if info.job and info.job == job and verAllow then
			table.insert(ret, info.uid)
		end
	end

	local tmp = {}

	for i, v in ipairs(ret) do
		if not valInTable(v, tmp) then
			table.insert(tmp, v)
		end
	end

	return tmp
end
magic.getMagicIdByName = function (name, job)
	local ret = -1

	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if name == info.name then
			if job then
				if info.job == job then
					ret = info.uid

					break
				end
			else
				ret = info.uid

				break
			end
		end
	end

	return ret
end
magic.getMagicJob = function (name)
	local ret = 99

	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if name == info.name then
			ret = info.job

			break
		end
	end

	return ret
end

return magic
