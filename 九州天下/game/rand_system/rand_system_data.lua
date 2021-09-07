RandSystemData = RandSystemData or BaseClass()

function RandSystemData:__init()
	if RandSystemData.Instance then
		print_error("[RandSystemData] Attempt to create singleton twice!")
		return
	end
	RandSystemData.Instance = self

	self.notice_cfg = ConfigManager.Instance:GetAutoConfig("system_notice_auto").notice_list or {}

	self.last_show_index = 1
end

function RandSystemData:__delete()
	RandSystemData.Instance = nil
end

--设置最后展示的文本index
function RandSystemData:SetLastShowIndex(index)
	self.last_show_index = index
end

function RandSystemData:GetLastShowIndex()
	return self.last_show_index
end

--获取展示的文本
function RandSystemData:GetNoticeInfoByIndex(index)
	return self.notice_cfg[index]
end

function RandSystemData:GetMaxNoticeCount()
	return #self.notice_cfg
end