RankActivity.nLevelRankCount = 0

function RankActivity:ManagerPowerRankData(tbData)

	local tbManagerData = {}

	for nFaction = 1, Faction.MAX_FACTION_COUNT do
		if tbData[nFaction] then
			table.insert(tbManagerData,tbData[nFaction])
		end
	end
	
	return tbManagerData
end

function RankActivity:SynLevelRankData()
	RemoteServer.SynLevelRankData()
end

function RankActivity:OnSynLevelRankData(nLevelRankCount)
	RankActivity.nLevelRankCount = nLevelRankCount or 0
	UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_LEVEL_RANK)
end

function RankActivity:RemainLevelRankCount()
	return RankActivity.MAX_RANK_LEVEL_COUNT - RankActivity.nLevelRankCount
end

function RankActivity:LevelRankCount()
	return RankActivity.nLevelRankCount
end