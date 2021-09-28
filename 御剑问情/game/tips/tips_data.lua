TipsData = TipsData or BaseClass()
function TipsData:__init()
	if TipsData.Instance ~= nil then
		print_error("[TipsData] attempt to create singleton twice!")
		return
	end
	TipsData.Instance = self

	self.gongao_num = nil
end

function TipsData:__delete()
	TipsData.Instance = nil
end

function TipsData:SetGongGaoData(data)
	self.gonggao_data = data
end

function TipsData:GetGongGaoData()
	return self.gonggao_data
end

function TipsData:GetGongGaoDataNum()
	if nil == self.gonggao_data then
		return 0
	end

	return #self.gonggao_data
end