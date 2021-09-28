GodTempleData = GodTempleData or BaseClass()

function GodTempleData:__init()
	if GodTempleData.Instance then
		print_error("[GodTempleData] Attempt to create singleton twice!")
		return
	end
	GodTempleData.Instance = self

	local cfg = ConfigManager.Instance:GetAutoConfig("patafbnewconfig_auto")
	self.layer_cfg = ListToMap(cfg.levelcfg, "level")
	self.shenqi_cfg = ListToMap(cfg.pata_shenqi, "shenqi_level")
end

function GodTempleData:__delete()
	GodTempleData.Instance = nil
end

--获取排行榜信息
function GodTempleData:GetRankList()
	local list = RankData.Instance:GetRankList(RANK_KIND.PERSON, PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE)
	return list
end

function GodTempleData:GetLayerCfg()
	return self.layer_cfg
end

function GodTempleData:GetShenQiCfg()
	return self.shenqi_cfg
end