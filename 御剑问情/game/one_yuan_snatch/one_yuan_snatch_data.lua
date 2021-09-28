OneYuanSnatchData = OneYuanSnatchData or BaseClass()

function OneYuanSnatchData:__init()
	if nil ~= OneYuanSnatchData.Instance then
		print_error("[OneYuanSnatchData] attempt to create singleton twice!")
		return
	end
	OneYuanSnatchData.Instance = self

	self.cfg = ConfigManager.Instance:GetAutoConfig("cloud_purchase_auto")
	self.greate_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto").greate_soldier

	self:InitData()
end
function OneYuanSnatchData:__delete()
	OneYuanSnatchData.Instance = nil
end

----------------------------------------------------------
------------------------ 配置内容 ------------------------
----------------------------------------------------------

function OneYuanSnatchData:InitData()
	local cfg = self:GetSnatchCfg()
	local num = 0 
	local count = #cfg
	if count > 0 then
		num = self:GetCfgGroupNum(count, 4)
	end
	self.snatch_num = num


	cfg = self:GetIntergralCfg()
	count = #cfg
	num = 0 
	if count > 0 then
		num = self:GetCfgGroupNum(count, 3)
	end
	self.intergral_num = num


	cfg = self:GetTicketCfg()
	count = #cfg
	num = 0
	if count > 0 then
		num = self:GetCfgGroupNum(count, 3)
	end
	self.ticket_num = num
end

-- 总数，一个组包含的数量
function OneYuanSnatchData:GetCfgGroupNum(count, group_contain_num)
	if count == nil or group_contain_num == nil then
		print_error("错误的传入值")
		return 0
	end

	local remainder = math.floor((count % group_contain_num))
	local divider = math.floor((count / group_contain_num))
	num = remainder == 0 and divider or (1 + divider)
	return num
end

function OneYuanSnatchData:GetSnatchCfg()
	return self.cfg.item_cfg
end

-- 获取夺宝面板的CellGroup数量
function OneYuanSnatchData:GetSnatchNum()
	return self.snatch_num or 0
end





function OneYuanSnatchData:GetSnatchGroupIndexCfg(index)
	if not index or index < 0 then return nil end

	local num = self:GetSnatchNum() or 0
	local cfg = self:GetSnatchCfg()
	local list = {}
	if num > 0 then
		
		local max_range = index * 4
		local min_range = (max_range - 3) > 0 and (max_range - 3) or 1

		for i = min_range, max_range do

			if cfg[i] then
				table.insert(list, cfg[i])
			else
				break
			end
		end	
	end

	return #list > 0 and list or nil
end

function OneYuanSnatchData:GetItemIdCfg(item_id)
	if not item_id then return nil end

	local cfg = FashionData.Instance:GetFashionCfg(item_id)

	if not cfg or #cfg == 0 then
		cfg = ItemData.Instance:GetItemConfig(item_id)
	end
	
	return cfg
end



-------------------兑换-------------------

function OneYuanSnatchData:GetIntergralCfg()
	return self.cfg.convert_cfg
end

function OneYuanSnatchData:GetIntergralNum()
	return self.intergral_num or 0
end


function OneYuanSnatchData:GetIntergralGroupIndexCfg(index)
	if not index or index < 0 then return nil end

	local num = self:GetIntergralNum() or 0
	local cfg = self:GetIntergralCfg()
	local list = {}
	if num > 0 and cfg then
		
		local max_range = index * 3
		local min_range = (max_range - 2) > 0 and (max_range - 2) or 1

		for i = min_range, max_range do

			if cfg[i] then
				table.insert(list, cfg[i])
			else
				break
			end
		end	
	end

	return #list > 0 and list or nil
end

function OneYuanSnatchData:ParseIntergralItemId(item_text)
	if not item_text then return nil end

	local list = Split(item_text, ":")

	local item_data = nil
	if list and list[1] and list[2] and list[3] then
		item_data = {} 
		item_data.item_id = tonumber(list[1])
		item_data.num = tonumber(list[2])
		item_data.is_bind = tonumber(list[3])
	end

	return item_data
end

function OneYuanSnatchData:GetMaxScoreCfg()
	local cfg = self:GetIntergralCfg()
	local list = nil	
	local max_score = 0
	
	for k, v in pairs(cfg) do
		if v.cost_score and max_score < v.cost_score then
			max_score = v.cost_score
			list = v
		end	
	end

	return list
end

function OneYuanSnatchData:GreateSoldierImagId(item_id)
	if not item_id then return 0 end

	for k, v in pairs(self.greate_soldier_cfg) do
		if v.item_id == item_id then
			return v.image_id or 0
		end
	end
	
	return 0
end


function OneYuanSnatchData:GetCopiesCfg()
	return self.cfg.copies_cfg
end


----------------奖券-------------------

function OneYuanSnatchData:GetTicketCfg()
	return self.cfg.ticket_type
end

function OneYuanSnatchData:GetTicketPageNum()
	return self.ticket_num or 0
end

function OneYuanSnatchData:GetTicketPagIndexCfg(index)
	if not index or index < 0 then return nil end

	local num = self:GetTicketPageNum() or 0
	local cfg = self:GetTicketCfg()
	local list = {}
	if num > 0 and cfg then
		
		local max_range = index * 3
		local min_range = (max_range - 2) > 0 and (max_range - 2) or 1

		for i = min_range, max_range do

			if cfg[i] then
				table.insert(list, cfg[i])
			else
				break
			end
		end	
	end

	return #list > 0 and list or nil
end

function OneYuanSnatchData:GetOtherCfg()
	return self.cfg.other
end

----------------------------------------------------------
------------------------ 协议内容 ------------------------
----------------------------------------------------------

function OneYuanSnatchData:SetSCCloudPurchaseInfo(protocol)
	if not protocol then return end

	if not self.cloud_pur_chase_info then self.cloud_pur_chase_info = {} end

	self.cloud_pur_chase_info.can_buy_timestamp_list = protocol.can_buy_timestamp_list
	self.cloud_pur_chase_info.item_list = protocol.item_list
end

function OneYuanSnatchData:GetCloudPurchaseInfo()
	return self.cloud_pur_chase_info
end

function OneYuanSnatchData:GetCloudPurchaseInfoByIndex(index)
	if not index then return nil end

	local list = self:GetCloudPurchaseInfo()
	if list and list.item_list then
		return list.item_list[index]
	end
	return nil
end

function OneYuanSnatchData:GetCanBuyTimeStampByIndex(index)
	if not index then return nil end

	local list = self:GetCloudPurchaseInfo()
	if list and list.can_buy_timestamp_list then
		return list.can_buy_timestamp_list[index]
	end
	return nil
end

-----------------------------兑换-----------------------

function OneYuanSnatchData:SetSCCloudPurchaseConvertInfo(protocol)
	if not protocol then return end

	if not self.cloud_pur_chase_convert_info then self.cloud_pur_chase_convert_info = {} end

	self.cloud_pur_chase_convert_info.score = protocol.score
	self.cloud_pur_chase_convert_info.record_count = protocol.record_count 
	self.cloud_pur_chase_convert_info.convert_record_list = protocol.convert_record_list 
end

function OneYuanSnatchData:GetCloudPurchaseConvertInfo()
	return self.cloud_pur_chase_convert_info
end

function OneYuanSnatchData:PurchaseConvertInfoByItemId(item_id)
	if not item_id then return nil end 

	local info = self:GetCloudPurchaseConvertInfo()

	if info and info.record_count and info.convert_record_list then
		if info.record_count <= 0 then
			return nil
		end

		for k, v in pairs(info.convert_record_list) do
			if v.item_id == item_id then
				return v
			end
		end
	end

	return nil
end

-------------------个人购买记录---------------------------
function OneYuanSnatchData:SetSCCloudPurchaseBuyRecordInfo(protocol)
	if not protocol then return end

	if not self.cloud_pur_chase_buy_record_info then self.cloud_pur_chase_buy_record_info = {} end

	self.cloud_pur_chase_buy_record_info.record_count = protocol.record_count
	self.cloud_pur_chase_buy_record_info.buy_record_list = protocol.buy_record_list
end

function OneYuanSnatchData:GetSCCloudPurchaseBuyRecordInfo()
	return self.cloud_pur_chase_buy_record_info
end

function OneYuanSnatchData:GetSCCloudPurchaseBuyRecordInfoByIndex(index)
	if not index then return nil end

	local info = self:GetSCCloudPurchaseBuyRecordInfo()

	if info and info.record_count and info.record_count > 0 and info.buy_record_list then
		return info.buy_record_list[index]
	end

	return nil
end

------------------------中奖记录------------------------------
function OneYuanSnatchData:SetSCCloudPurchaseServerRecord(protocol)
	if not protocol then return end

	if not self.cloud_pur_chase_server_record_info then self.cloud_pur_chase_server_record_info = {} end

	self.cloud_pur_chase_server_record_info.count = protocol.count
	self.cloud_pur_chase_server_record_info.cloud_reward_record_list = protocol.cloud_reward_record_list
end

function OneYuanSnatchData:GetSCCloudPurchaseServerRecord()
	return self.cloud_pur_chase_server_record_info
end

function OneYuanSnatchData:GetSCCloudPurchaseServerRecordByIndex(index)
	if not index then return nil end

	local info = self:GetSCCloudPurchaseServerRecord()

	if info and info.count and info.count > 0  and info.cloud_reward_record_list then
		return info.cloud_reward_record_list[index]
	end

	return nil
end


------------------------用户一元夺宝的数据------------------------------

function OneYuanSnatchData:SetCloudPurchaseUserInfo(protocol)
	if not protocol then return end

	if not self.cloud_pur_chase_user_info then self.cloud_pur_chase_user_info = {} end

	self.cloud_pur_chase_user_info.score = protocol.score
	self.cloud_pur_chase_user_info.ticket_num = protocol.ticket_num
end

function OneYuanSnatchData:GetCloudPurchaseUserInfo()
	return self.cloud_pur_chase_user_info
end