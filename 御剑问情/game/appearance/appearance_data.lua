AppearanceData = AppearanceData or BaseClass(BaseEvent)

function AppearanceData:__init()
	if AppearanceData.Instance then
		print_error("[AppearanceData] Attempt to create singleton twice!")
		return
	end

	self.zizhi_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward, "type")

	AppearanceData.Instance = self
end

function AppearanceData:__delete()
	AppearanceData.Instance = nil
end

function AppearanceData:GetZiZhiCfgInfoByType(zizhi_type)
	return self.zizhi_cfg[zizhi_type]
end