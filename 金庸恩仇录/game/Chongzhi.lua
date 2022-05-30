local data_chongzhi_chongzhi = require("data.data_chongzhi_chongzhi")
local data_chongzhi = {}
for k, v in pairs(data_chongzhi_chongzhi) do
	if data_chongzhi[v.payway] == nil then
		data_chongzhi[v.payway] = {}
	end
	data_chongzhi[v.payway][v.index] = v
end
return data_chongzhi