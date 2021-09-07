BuffProgressData = BuffProgressData or BaseClass()
function BuffProgressData:__init()
	if BuffProgressData.Instance then
		print_error("[BuffProgressData] Attemp to create a singleton twice !")
	end
	BuffProgressData.Instance = self
	self.buff_info = {}
	self.cur_type_list = {}
end

function BuffProgressData:__delete()
	BuffProgressData.Instance = nil
	self.buff_info = {}
end

function BuffProgressData:SetBuffInfo(info)
	if self.cur_type_list[info.buff_type] then
		return
	end
	self.cur_type_list[info.buff_type] = true
	table.insert(self.buff_info, info)
end

function BuffProgressData:RemoveBuffInfo(buff_type)
	for k,v in pairs(self.buff_info) do
		if buff_type == v.buff_type then
			self.cur_type_list[v.buff_type] = nil
			table.remove(self.buff_info, k)
			return
		end
	end
end

function BuffProgressData:GetBuffList()
	return self.buff_info
end