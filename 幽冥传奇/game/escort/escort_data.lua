--护送押镖数据--
EscortData = EscortData or BaseClass()

EscortData.LEFT_TIMES_CHANGE = "left_times_change"

function EscortData:__init()
	if EscortData.Instance then
		ErrorLog("[EscortData] Attemp to create a singleton twice !")
	end
	EscortData.Instance = self
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.left_times = 0
	self.refre_data_t = {}
end

function EscortData:__delete()
	EscortData.Instance = nil
	
end

--获取护送押镖配置
function EscortData:GetEscortCfg()
	return StdActivityCfg[DAILY_ACTIVITY_TYPE.YA_SONG]
end

--获取不同品质标车配置
function EscortData:GetEscortCarCfg()
	local escortCarCfg = self:GetEscortCfg().tBiaoche
	local cfg = {
					escortCarCfg[1],
					escortCarCfg[2],
					escortCarCfg[3],
					escortCarCfg[4],
				}
	return cfg
end

--获取不同品质镖车奖励配置
function EscortData:GetAwardsCfg()
	local car_cfg = self:GetEscortCarCfg()
	local reward_cfg = {}
	for k,v in ipairs(car_cfg) do
		local list = {}
		if next(v.Awards) then
			for i1, v2 in ipairs(v.Awards) do
				list[i1] = ItemData.InitItemDataByCfg(v2)
			end

			reward_cfg[k] = list
		end 
	end

	return reward_cfg
end

--获取不同品质镖车额外奖励配置
function EscortData:GetOtherAwardsCfg()
	local car_cfg = self:GetEscortCarCfg()
	local reward_cfg = {}
	for k,v in ipairs(car_cfg) do
		local tab = {}
		if next(v.otherAwards) then
			for k2, v2 in ipairs(v.otherAwards) do
				local item = ItemData.InitItemDataByCfg(v2)
				item.name = v2.name
				tab[k2] = item
			end
			reward_cfg[k] = tab
		end 
	end
	return reward_cfg
end

--刷新品质结果数据
function EscortData:SetRefreQualityData(protocol)
	self.refre_data_t = {}
	self.refre_data_t.quality = protocol.quality
	self.refre_data_t.times = protocol.refr_time
end

function EscortData:GetRefreQualityData()
	return self.refre_data_t
end

function EscortData:SetEscortLeftTimes(protocol)
	self.left_times = protocol.left_times
    self:DispatchEvent(EscortData.LEFT_TIMES_CHANGE)
end

function EscortData:GetEscortLeftTimes()
 	return self.left_times
end