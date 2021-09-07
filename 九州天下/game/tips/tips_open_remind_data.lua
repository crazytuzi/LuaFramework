TipsRemindData = TipsRemindData or BaseClass()
function TipsRemindData:__init()
	if TipsRemindData.Instance then
		print_error("[TipsRemindData] Attemp to create a singleton twice !")
	end
	TipsRemindData.Instance = self
	self.remind_list = {}
end

function TipsRemindData:__delete()
	for k,v in pairs(self.remind_list) do
		v = nil
	end
	self.remind_list = {}
	TipsRemindData.Instance = nil
end

function TipsRemindData:CheckRemindTips()
	self.remind_list = {}
	local red_point_list= TableCopy(RemindGroud[RemindName.WenXinRemind])
	if red_point_list == nil then return end
	for k,v in pairs(red_point_list) do
		local open_cfg = TableCopy(RemindCfg[v])
		local is_open, _ = ViewManager.Instance:CheckShowUi(open_cfg.view_name, open_cfg.sub_name)
		if RemindManager.Instance:GetRemind(v) > 0 and is_open then
			self.remind_list[#self.remind_list + 1] = v
		end
	end
end

function TipsRemindData:GetRemindList()
	return self.remind_list
end