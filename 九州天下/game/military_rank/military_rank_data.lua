MilitaryRankData = MilitaryRankData or BaseClass()
function MilitaryRankData:__init()
	if MilitaryRankData.Instance then
		print_error("[MilitaryRankData] Attemp to create a singleton twice !")
	end
	MilitaryRankData.Instance = self

	self.all_cfg = nil
	self.level_cfg = nil
	self.star_cfg = nil

	self.jungong = 0
	self.jx_level = 0
	self.jx_star = 0
	self.active_timestamp = {}

	self.star_level_cfg = ListToMap(self:GetStarCfg(), "star_level")
end

function MilitaryRankData:__delete()
	MilitaryRankData.Instance = nil
end

function MilitaryRankData:GetCfg()
	if not self.all_cfg then
		self.all_cfg = ConfigManager.Instance:GetAutoConfig("junxian_auto")
	end
	return self.all_cfg
end

function MilitaryRankData:GetLevelCfg()
	if not self.level_cfg then
		self.level_cfg = TableCopy(self:GetCfg().jx_level)
	end
	return self.level_cfg
end

function MilitaryRankData:GetStarCfg()
	if not self.star_cfg then 
		self.star_cfg = TableCopy(self:GetCfg().jx_star)
	end
	return self.star_cfg
end

function MilitaryRankData:SetSCJunXianInfo(protocol)
	self.jungong = protocol.jungong
	self.jx_level = protocol.jx_level
	self.jx_star = protocol.jx_star
	self.active_timestamp = protocol.active_timestamp
end

function MilitaryRankData:SetSCJunXianUplevelResult(protocol)
	self.jx_level = protocol.jx_level
end

function MilitaryRankData:GetLevelSingleCfg(index)
	if nil == index then return end
	local level_cfg = self:GetLevelCfg()
	return level_cfg[index]
end

function MilitaryRankData:GetStarSingleCfg(star_level)
	if nil == star_level then return end
	return self.star_level_cfg[star_level]
end

function MilitaryRankData:GetCurLevel()
	return self.jx_level
end

function MilitaryRankData:GetCurStar()
	return self.jx_star
end

function MilitaryRankData:GetActiveTimeByIndex(index)
	if nil == index then return 0 end
	return self.active_timestamp[index] or 0
end

function MilitaryRankData:GetCurJunGong()
	return self.jungong
end