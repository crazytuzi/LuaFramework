DressShopData = DressShopData or BaseClass()

function DressShopData:__init()
	if DressShopData.Instance then
		ErrorLog("[DressShopData] attempt to create singleton twice!")
		return
	end
	DressShopData.Instance =self
	self.need_cfg = nil
	self.type_cfg = nil
	self.type_num = 0
	self.old_day = 0
	self.num_list = {}
end

function DressShopData:__delete()
	DressShopData.Instance = nil
end

function DressShopData:SetNumTimeInfo(procotol)
	self.num_list = procotol.num_list or {}
end

function DressShopData:GetNumTimeInfo(type,index)
	if self.num_list and self.num_list[type] and self.num_list[type][index] then
		return self.num_list[type][index]
	end
	return 0
end

function DressShopData:GetDressShopCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().image_exchange_shop or {}
end

--获取对应天数类型配置
function DressShopData:GetCurShopCfg()
	TimeCtrl.Instance:SendTimeReq()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.old_day == cur_day and self.need_cfg ~= nil then
		return self.need_cfg, self.type_num, self.type_cfg
	end
	self.old_day = cur_day
	self.need_cfg = {}
	self.type_cfg = {}
	local all_cfg = self:GetDressShopCfg()
	self.type_num = 0
	for k,v in pairs(all_cfg) do
		if cur_day >= v.open_day and cur_day <= v.close_day then
			if self.need_cfg[v.type] == nil then
				self.need_cfg[v.type] = {}
				self.type_cfg[self.type_num] = v
				self.type_num = self.type_num + 1
			end
			self.need_cfg[v.type][v.index] =  v
		end
	end
	return self.need_cfg, self.type_num, self.type_cfg
end

-- 背包是有多少材料
function DressShopData:GetRedEquipIsYes(item_id)
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	local num = 0
	for k , v in pairs(bg_data_list) do
		if v ~= nil then
			if v.item_id == item_id then
				num = num + v.num
			end
		end
	end
	return num
end

-- 通过活动结束的天数获取时间差
function DressShopData:GetDifferTime(close_day)
	local cur_time = TimeCtrl.Instance:GetServerTimeFormat()
	local day = close_day - TimeCtrl.Instance:GetCurOpenServerDay()
	local server_time = TimeCtrl.Instance:GetServerTime()
	cur_time.day = cur_time.day + day
	cur_time.hour = 23
	cur_time.min = 59
	cur_time.sec = 59

	local differ_time = 0
	local cur_num = os.time(cur_time)
	if cur_num ~= nil and server_time ~= nil then
		differ_time = cur_num - server_time
	end
	
	return differ_time,day
end
