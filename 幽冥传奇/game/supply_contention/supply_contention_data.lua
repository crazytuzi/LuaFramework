SupplyContentionData = SupplyContentionData or BaseClass()

function SupplyContentionData:__init()
	if SupplyContentionData.Instance then
		ErrorLog("[SupplyContentionData] attempt to create singleton twice!")
		return
	end
	SupplyContentionData.Instance = self

	self.rank_data_list = {}
	self.my_data = {}
	self.role_pos_data = {}

end

function SupplyContentionData:UpdataRankData(data)
	self.rank_data_list = data
end


function SupplyContentionData:GetRankData()
	return self.rank_data_list
end


function SupplyContentionData:__delete()
end