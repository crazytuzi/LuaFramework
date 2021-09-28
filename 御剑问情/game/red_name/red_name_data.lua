RedNameData = RedNameData or BaseClass()

function RedNameData:__init()
	if RedNameData.Instance then
		ErrorLog("[RedNameData] attempt to create singleton twice!")
		return
	end
	RedNameData.Instance = self
	self.no_more_open = false 	--是否不再显示该面板对应的主界面Icon
end

function RedNameData:__delete()
	RedNameData.Instance = nil
end

function RedNameData:GetRedNameCfg()
	if self.red_name_cfg == nil then
		self.red_name_cfg = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").red_name_cfg
	end
	return self.red_name_cfg
end

function RedNameData:SetNoMoreOpen(value)
	self.no_more_open = value
end

function RedNameData:GetNoMoreOpen()
	return self.no_more_open;
end
