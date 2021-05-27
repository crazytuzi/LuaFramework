JiFenEquipmentData = JiFenEquipmentData or BaseClass()

function JiFenEquipmentData:__init()
	if JiFenEquipmentData.Instance then
		ErrorLog("[JiFenEquipmentData]:Attempt to create singleton twice!")
	end
	JiFenEquipmentData.Instance = self
	self.gonggao_list = {}
end

function JiFenEquipmentData:__delete()
end

--请求整个信息
function JiFenEquipmentData:SetExchangeInfo(protocol)
	self.gonggao_list = {}
	for k,v in pairs(protocol.info_list) do
		table.insert(self.gonggao_list, 1, v)
	end
	if #self.gonggao_list > 50 then
		table.remove(self.gonggao_list, #self.gonggao_list)
	end
end

--添加单个信息
function JiFenEquipmentData:SetAddExchangeInfo(protocol)
	if self.gonggao_list == nil then return end
	table.insert(self.gonggao_list, 1, protocol.info)
	if #self.gonggao_list > 50 then
		table.remove(self.gonggao_list, #self.gonggao_list)
	end
end

--得到全服公告信息
function JiFenEquipmentData:GetInfo()
	return self.gonggao_list 
end

