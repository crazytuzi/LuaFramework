-- 装备属性加成
-------------------------------------------
HallowRuleData = HallowRuleData or BaseClass()

function HallowRuleData:__init()
	if HallowRuleData.Instance then
		ErrorLog("[HallowRuleData] Attemp to create a singleton twice !")
	end
	HallowRuleData.Instance = self
	self.config = {} 
end

function HallowRuleData:__delete()
	HallowRuleData.Instance = nil
end

function HallowRuleData:GetConfig(sex)
	if sex == 0 then	
		self.config = {
				{level = 1,items = {578,584}},
				{level = 2,items = {579,586}},
				-- {level = 3,items = {580,588}},
				-- {level = 4,items = {581,590}},
				-- {level = 5,items = {582,592}},
			}
	else
		self.config = {
				{level = 1,items = {578,585}},
				{level = 2,items = {579,587}},
				-- {level = 3,items = {580,589}},
				-- {level = 4,items = {581,591}},
				-- {level = 5,items = {582,593}},
			}
	end
	return self.config
end

function HallowRuleData:GetCount(level)
	local num = 0
	local level_num_list = EquipData.Instance:GetGodEquipData()
	for k,v in pairs(level_num_list) do
		if k >= level then
			num = num + v
		end
	end
	return num
end

function HallowRuleData:GetGodEquipPos(level)
	local suit_index_t = EquipData.Instance:GetEquipRuleData()
	local data = {}
	local z = 0
	for k,v in pairs(suit_index_t) do
		z = z + 1
	end
	for i = 1, 2 do
		if z ~= 0 then
			for k, v in pairs(suit_index_t) do
				if v >= level then
					data[(math.floor(k/10))] = 1
				end
			end
		else
			data[i] = 0
		end
	end 

	return data
end