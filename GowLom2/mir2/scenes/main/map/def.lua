local def = {
	loadOutsideAreaBottom = 15,
	loadOutsideArea = 1,
	loadNum = 500,
	tile = {
		w = 48,
		h = 32
	},
	topTag = 7000000,
	ET_DIGOUTZOMBI = 1,
	ET_PILESTONES = 3,
	ET_HOLYCURTAIN = 4,
	ET_FIRE = 5,
	ET_SCULPEICE = 6,
	ET_DIGINZOMBI = 7,
	ET_CAKEFIRE = 8,
	ET_MAGICDOOR = 9,
	ET_SPRING = 14,
	ET_FIREDRAGONSTATUARY = 15,
	ET_FIREDRAG = 16,
	ET_MAGICGATE = 17,
	ET_ICESEAT = 18,
	ET_GetEXP = 19,
	ET_RELEASE_FIRE = 20,
	ET_BTFIRE = 21,
	ET_FootBallEvent = 22,
	ET_YanHuaTextEvent = 23,
	ET_YanChenEvent = 25,
	ET_Flood = 24,
	ET_Iceberg = 27,
	ET_DAMAGETRAP = 28,
	ET_CACHOT = 29,
	ET_BIRTHDAY_FIRE = 30,
	ET_SWMY = 31,
	ET_SWMY_PLUS = 32,
	ET_revIceberg = 33,
	ET_WORLDBOSS = 34,
	ET_FIVE_EARTH_ELEMENT = 36,
	ET_ASS_BZXJ = 37,
	ET_ASS_BZXJ_PLUS = 38,
	ET_TBDL_FIRE = 39,
	ET_MIRMATCH_RANDBUFF = 40,
	ET_YEARFIRE1 = 43,
	ET_YEARFIRE2 = 44,
	ET_Group5v5 = 45,
	ET_INTENTLY = 78,
	ET_SOULMATE = 79,
	ET_FLYINGFIREBALL = 80,
	ET_ROMANTICSTARRAIN = 81,
	ET_SWEETDREAMS = 82,
	ET_DANCEOFTHESKY = 83,
	ET_SUCHASFOGDREAM = 84,
	CAKEFIREBASE = 320,
	ET_STALL_EVENT = 41,
	ET_WATER = 42,
	ET_WARFLAG = 46
}

scheduler.performWithDelayGlobal(function ()
	local cfg = res.getfile("config/doorPoint.txt")
	local doorPoint = {}
	local datas = string.split(cfg, "\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ",")
			local id = data[1]
			doorPoint[id] = doorPoint[id] or {}
			doorPoint[id][#doorPoint[id] + 1] = {
				x = tonumber(data[2]),
				y = tonumber(data[3]),
				terminal = data[4]
			}
		end
	end

	def.doorPoint = doorPoint

	return 
end, 0)

return def
