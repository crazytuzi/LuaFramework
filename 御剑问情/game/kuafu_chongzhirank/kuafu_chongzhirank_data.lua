KuaFuChongZhiRankData = KuaFuChongZhiRankData or BaseClass()


local CEll_COUNT = 3
function KuaFuChongZhiRankData:__init()
	if KuaFuChongZhiRankData.Instance then
		print_error("[KuaFuChongZhiRankData] Attempt to create singleton twice!")
		return
	end
	KuaFuChongZhiRankData.Instance=self
	local kuafuvhongzhi_cfg = ConfigManager.Instance:GetAutoConfig("cross_randactivity_cfg_1_auto")
	self.kuafuvhongzhi_cfg_chongzhi_rank = kuafuvhongzhi_cfg.chongzhi_rank
	self.rank_list = {}
	self.total_chongzhi = 0
	self.rank_count = 0
	self.end_time = 0
	self.begin_time = 0

end

function KuaFuChongZhiRankData:__delete()
	KuaFuChongZhiRankData.Instance = nil
end

function KuaFuChongZhiRankData:GetChongZhiRank()
	return self.kuafuvhongzhi_cfg_chongzhi_rank
end

function KuaFuChongZhiRankData:SetChongZhiInfo(protocol)
	self.total_chongzhi = protocol.total_chongzhi
end

function KuaFuChongZhiRankData:GetChongZhiInfo()
	return self.total_chongzhi
end

function KuaFuChongZhiRankData:SetCrossRandActivityStatus(protocol)
	self.activity_type = protocol.activity_type
	self.status = protocol.status
	self.begin_time = protocol.begin_time
	self.end_time = protocol.end_time

end

function KuaFuChongZhiRankData:GetCrossActivityType()
	return self.activity_type
end

function KuaFuChongZhiRankData:GetCrossStatus()
	return self.status
end

function KuaFuChongZhiRankData:GetCrossBeginTime()
	return self.begin_time
end

function KuaFuChongZhiRankData:GetCrossEndTime()
	return self.end_time

end

function KuaFuChongZhiRankData:SetCrossRAChongzhiRankGetRankACK(protocol)
	self.rank_list = protocol.rank_list
	self.rank_count = protocol.rank_count
	if next(self.rank_list)	 == nil then
		return
	end
    table.sort(self.rank_list, SortTools.KeyUpperSorter("total_chongzhi"))
end

function KuaFuChongZhiRankData:GetCrossRankInfo()
	return self.rank_list
end

function KuaFuChongZhiRankData:GetRankCount()
	return self.rank_count
end

function KuaFuChongZhiRankData:GetGiftCfgById(item_id)
	if not item_id then
		return nil
	end

	local cfg = ItemData.Instance:GetItemConfig(item_id)

	if cfg then
		local list = {}

		for i = 1, CEll_COUNT do
			local item_data = {}
			item_data.item_id = cfg["item_".. i .."_id"] or 0
			item_data.num = cfg["item_".. i .."_num"] or 0
			item_data.is_bind = cfg["is_bind_".. i] or 0

			if item_data.item_id ~= 0 and item_data.num ~= 0 and item_data.is_bind ~= 0 then
				list[i] = item_data
			end
		end

		return #list > 0 and list or nil
	end

	return nil
end