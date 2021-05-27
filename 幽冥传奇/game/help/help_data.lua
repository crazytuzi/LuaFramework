HelpData = HelpData or BaseClass()

function HelpData:__init()
	if HelpData.Instance then
		ErrorLog("[HelpData] Attemp to create a singleton twice !")
	end
	
	HelpData.Instance = self
	self.open_server_info = {
		logic_short_time = "",
		open_server_time = 0,
		gm_level = 0,
		combined_day = 0,
	}
end

function HelpData:__delete()
	HelpData.Instance = nil
end

function HelpData.GetHelpNameList()
	local helper_type_cfg = ConfigManager.Instance:GetAutoConfig("helper_auto").helper_type
	local list = {}
	for i,v in ipairs(helper_type_cfg) do
		table.insert(list, v.type_name)
	end
	return list
end

function HelpData.GetHelpListByType(helper_type)
	local helper_list_cfg = ConfigManager.Instance:GetAutoConfig("helper_auto").helper_list
	local list = {}
	for i,v in ipairs(helper_list_cfg) do
		if v.type == helper_type then
			table.insert(list, v)
		end
	end
	return list
end

function HelpData:SetOpenServerInfo(info)
	self.open_server_info.logic_short_time = info.logic_short_time
	self.open_server_info.open_server_time = info.open_server_time
	self.open_server_info.gm_level = info.gm_level
	self.open_server_info.combined_day = info.combined_day
end

function HelpData:GetOpenServerInfo()
	return self.open_server_info
end