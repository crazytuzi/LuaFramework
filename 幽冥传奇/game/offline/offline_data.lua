OfflineData = OfflineData or BaseClass()

OfflineData.SHOP_DATA = {
	item_id = 506,
}

OfflineData.REQ_ID = {
	BEGIN = 1, 				--开始在线挂机, 
	OFFLINE_REWARD = 2, 	--领取离线挂机奖励, 
	INFO = 4, 				--挂机信息,
	STOP = 5, 				--停止在线挂机
}

OfflineData.OFFLINE_DATA_CHANGE = "offline_data_change"


function OfflineData:__init()
	if OfflineData.Instance then
		ErrorLog("[OfflineData] attempt to create singleton twice!")
		return
	end

	OfflineData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.map_index = -1

	self.data = {
		msg_id = 0,
		offline_time = 0,
		offline_index = 0,
		award = {},
		results = 0,
	}
end

function OfflineData:__delete()
end

function OfflineData:SetData(protocol)
	self.data = self.data or {}
	self.data.msg_id = protocol.msg_id or 0
	self.data.offline_time = protocol.offline_time or 0
	self.data.offline_index = protocol.offline_index or 0
	self.data.award = protocol.award or {}
	self.data.results = protocol.results or 0
	self:DispatchEvent(OfflineData.OFFLINE_DATA_CHANGE, self.data.msg_id)
end

function OfflineData:GetData()
	return self.data or {}
end

function OfflineData.GetMapDataList()
	return LogoutGuajiConfig.gjscene
end

function OfflineData:GetGuajiMapIndex()
	return self.map_index
end

function OfflineData:SetGuajiMapIndex(index)
	self.map_index = index
end

function OfflineData:IsInGuaji()
	return self.is_in_guaji
end

function OfflineData:SetGuaji(is_in_guaji)
	self.is_in_guaji = is_in_guaji
end

function OfflineData:GetAwardList()
	local list = {}
	local gjscene_cfg = LogoutGuajiConfig and LogoutGuajiConfig.gjscene and LogoutGuajiConfig.gjscene[self.data.offline_index] or {}
	for i = 1, 8 do
		local item = {}
		local num = self.data.award and self.data.award[i]
		if self.data.offline_time >= 60 and gjscene_cfg.award and gjscene_cfg.award[i] then
			item = ItemData.InitItemDataByCfg(gjscene_cfg.award[i], num)
		end
		list[i] = item
	end

	return list
end

function OfflineData.GetSuitableIndex()
	local index = 1
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.PROP_ACTOR_ONCE_MAX_LEVEL)
	local data = OfflineData.GetMapDataList()
	for i=#data, 1, -1 do
		if level >= data[i].level then
			index = i
			break
		end
	end
	return index
end