local militaryRank = {}
local MilitaryRankCfg = import("csv2cfg.MilitaryRankCfg")
militaryRank.getMilitaryPropertyByRank = function (rank)
	if #MilitaryRankCfg - 1 < rank then
		rank = #MilitaryRankCfg - 1
	end

	for k, v in ipairs(MilitaryRankCfg) do
		if rank == v.MilitaryRankLv then
			return v
		end
	end

	return {}
end
militaryRank.getMilitaryPropertyByFilter = function (filter)
	local result = {}

	for k, v in ipairs(MilitaryRankCfg) do
		if string.find(v.MilitaryRankName, filter) then
			result[#result + 1] = v
		end
	end

	return result
end
local label_color = {
	cc.c3b(119, 241, 222),
	cc.c3b(51, 175, 254),
	cc.c3b(210, 20, 230),
	cc.c3b(255, 110, 55)
}
militaryRank.getColorByRank = function (rank)
	return label_color[math.ceil(rank/25)]
end

return militaryRank
