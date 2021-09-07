KillTipView = KillTipView or BaseClass(BaseView)

function KillTipView:__init()
	self.ui_config = {"uis/views/tips/killtips", "KillTips"}
	self.view_layer = UiLayer.MainUIHigh
	self.kill_role_count_quest = nil
	self.kill_role_chuanwen_quest = nil
	self.is_showing = false
	self.data_query = {}
end

function KillTipView:__delete()
end

function KillTipView:ReleaseCallBack()
	self:ClearTimer()

	self.tip_kill_1 = nil
	self.tip_kill_2 = nil
	self.tip_kill_3 = nil
	self.my_total_num = nil
	self.my_icon_1 = nil
	self.my_name_1 = nil
	self.other_icon_1 = nil
	self.other_name_1 = nil
	self.my_image_1 = nil
	self.other_image_1 = nil
	self.lianzhanNum = nil
	self.my_icon_2 = nil
	self.my_name_2 = nil
	self.other_icon_2 = nil
	self.other_name_2 = nil
	self.my_image_2 = nil
	self.other_image_2 = nil
end

function KillTipView:LoadCallBack()
	self.tip_kill_1 = self:FindVariable("kill_1")			-- 斩杀
	self.tip_kill_2 = self:FindVariable("kill_2")			-- 连杀
	self.tip_kill_3 = self:FindVariable("kill_3")			-- 破敌个数

	self.my_total_num = self:FindVariable("my_total_num")	-- 破敌数

	-- 斩杀
	self.my_icon_1 = self:FindVariable("my_icon_1")
	self.my_name_1 = self:FindVariable("my_name_1")
	self.other_icon_1 = self:FindVariable("other_icon_1")
	self.other_name_1 = self:FindVariable("other_name_1")

	self.my_image_1 = self:FindObj("my_image_1")
	self.other_image_1 = self:FindObj("other_image_1")


	-- 连斩
	self.lianzhanNum = self:FindVariable("lianzhanNum")
	self.my_icon_2 = self:FindVariable("my_icon_2")
	self.my_name_2 = self:FindVariable("my_name_2")
	self.other_icon_2 = self:FindVariable("other_icon_2")
	self.other_name_2 = self:FindVariable("other_name_2")

	self.my_image_2 = self:FindObj("my_image_2")
	self.other_image_2 = self:FindObj("other_image_2")
end

function KillTipView:OnCloseTip()
	self.tip_kill_1:SetValue(false)
	self.tip_kill_2:SetValue(false)
	self.tip_kill_3:SetValue(false)
	self.is_showing = false
end

function KillTipView:ClearTimer()
	if self.kill_role_count_quest then
		GlobalTimerQuest:CancelQuest(self.kill_role_count_quest)
		self.kill_role_count_quest = nil
	end

	if self.kill_role_chuanwen_quest then
		GlobalTimerQuest:CancelQuest(self.kill_role_chuanwen_quest)
		self.kill_role_chuanwen_quest = nil
	end
end

function KillTipView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "flush_kill_role_count_info" then
			local data = KillTipData.Instance:GetKRoleCountInfo()
			data.show_type = 0
			table.insert(self.data_query, data)
			self:FlushQueryInfo()
		elseif k == "flush_kill_role_chuanwen_info" then
			local data = KillTipData.Instance:GetKillRoleChuanwen()
			data.show_type = 1
			table.insert(self.data_query, data)
			self:FlushQueryInfo()
		end
	end
end

function KillTipView:CheckCallback()
	self:OnCloseTip()
	self:ClearTimer()
	if #self.data_query > 0  then
		self:FlushQueryInfo()
	end
end

function KillTipView:FlushQueryInfo()
	if not self.is_showing then 
		local data = table.remove(self.data_query, 1)
		if data == nil then
			self:OnCloseTip()
			self:ClearTimer()	
			return	
		end
		if data.show_type == 0 then
			if not self.is_showing then
				self:OnFlushRoleCountInfo(data)
				self.kill_role_count_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CheckCallback, self), KILL_ROLE_CHUANWEN.WAITING_TIME)
			end
		elseif data.show_type == 1 then
			if not self.is_showing then
				self:OnFlushRoleChuanwenInfo(data)
				self.kill_role_chuanwen_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CheckCallback, self), KILL_ROLE_CHUANWEN.WAITING_TIME)
			end
		end
	end
end

function KillTipView:GetNewKillDataList(list)
	local kill_data = {}
	kill_data.id = list.killer_id
	kill_data.prof = list.killer_prof
	kill_data.sex = list.killer_sex
	kill_data.avatar_key_big = list.killer_avatar_key_big
	kill_data.avatar_key_small = list.killer_avatar_key_small
	kill_data.name = list.killer_name
	return kill_data
end

function KillTipView:GetNewDeadDataList(list)
	local dead_data = {}
	dead_data.id = list.dead_id
	dead_data.prof = list.dead_prof
	dead_data.sex = list.dead_sex
	dead_data.avatar_key_big = list.dead_avatar_key_big
	dead_data.avatar_key_small = list.dead_avatar_key_small
	dead_data.name = list.dead_name
	return dead_data
end

-- 自己斩杀传闻
function KillTipView:OnFlushRoleCountInfo(data)
	self.is_showing = true
	local role_count_data = data
	local my_total_count = role_count_data.liansha_count
	if 	role_count_data.is_enter_or_leave_fb == KILL_ROLE_CHUANWEN.GAMER_ENTER_FB and my_total_count > 0 then
		self.tip_kill_3:SetValue(true)
		self.my_total_num:SetValue(my_total_count)

		self.tip_kill_1:SetValue(true)

		local kill_data = self:GetNewKillDataList(role_count_data)
		self:LoadHeadIcon(kill_data, self.my_icon_1, self.my_image_1)
		self.my_name_1:SetValue(Language.Common.CampNameAbbr[role_count_data.killer_camp] .. "·" .. kill_data.name or "")

		local dead_data = self:GetNewDeadDataList(role_count_data)
		self:LoadHeadIcon(dead_data, self.other_icon_1, self.other_image_1)
		self.other_name_1:SetValue(Language.Common.CampNameAbbr[role_count_data.dead_camp] .. "·" .. dead_data.name or "")

	elseif role_count_data.is_enter_or_leave_fb == KILL_ROLE_CHUANWEN.GAMER_LEAVE_FB then
		self.tip_kill_3:SetValue(false)
	end
end

-- 连斩传闻
function KillTipView:OnFlushRoleChuanwenInfo(data)
	self.is_showing = true
	local chuanwen_data = data
	if chuanwen_data.liansha_count > 0 then
		self.tip_kill_2:SetValue(true)

		local kill_chuanwen_data = self:GetNewKillDataList(chuanwen_data)
		self:LoadHeadIcon(kill_chuanwen_data, self.my_icon_2, self.my_image_2)
		self.my_name_2:SetValue(Language.Common.CampNameAbbr[chuanwen_data.killer_camp] .. "·" .. kill_chuanwen_data.name or "")

		local dead_chuanwen_data = self:GetNewDeadDataList(chuanwen_data)
		self:LoadHeadIcon(dead_chuanwen_data, self.other_icon_2, self.other_image_2)
		self.other_name_2:SetValue(Language.Common.CampNameAbbr[chuanwen_data.dead_camp] .. "·" .. dead_chuanwen_data.name or "")
		self.lianzhanNum:SetValue(chuanwen_data.liansha_count)
	end
end

function KillTipView:LoadHeadIcon(data, def_icon, sp_icon)
	AvatarManager.Instance:SetAvatarKey(data.id, data.avatar_key_big, data.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(data.id)
	if AvatarManager.Instance:isDefaultImg(data.id) == 0 or avatar_path_small == 0 then
		sp_icon.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(data.prof, false, data.sex)
		def_icon:SetAsset(bundle, asset)
	else
		local function callback(path)
			if path == nil then
				path = AvatarManager.GetFilePath(data.id, false)
			end
			sp_icon.raw_image:LoadSprite(path, function ()
				def_icon:SetAsset("", "")
				sp_icon.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(data.id, false, callback)
	end
end
