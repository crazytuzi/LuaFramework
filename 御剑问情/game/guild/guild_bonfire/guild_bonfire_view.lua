
GuildBonfireView = GuildBonfireView or BaseClass(BaseView)

function GuildBonfireView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildBonfireView"}
	self.auto_pray = false
	self.last_gather_total_num = 0
	self.drink_num = 0
	self.not_first_open = false
	-- self.view_layer = UiLayer.MainUILow
end

function GuildBonfireView:__delete()

end

function GuildBonfireView:LoadCallBack()
	self.show_contribution = self:FindVariable("ShowContribution")
	self.pray_text = self:FindVariable("PrayText")
	self.contribution_text = self:FindVariable("ContriButionText")
	self.skill_cd_hejiu = self:FindVariable("Skill_cd_hejiu")
	self.skill_cd_jiacai = self:FindVariable("Skill_cd_jiacai")
	self.button_state_hejiu = self:FindVariable("button_state_hejiu")
	self.button_state_jiacai = self:FindVariable("button_state_jiacai")
	self.skill_time_hejiu = self:FindVariable("skill_time_hejiu")
	self.skill_time_jiacai = self:FindVariable("skill_time_jiacai")

	self.skill_time_hejiu:SetValue("")
	self.skill_time_jiacai:SetValue("")

	self:ListenEvent("Contribution",
		BindTool.Bind(self.OnContribution, self))
	self:ListenEvent("Pray",
		BindTool.Bind(self.OnPray, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.obj_create = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind1(self.OnObjDelete, self))
	self.day_count_change = GlobalEventSystem:Bind(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DaycountChange, self))
end

function GuildBonfireView:ReleaseCallBack()
	self.show_contribution = nil
	self.pray_text = nil
	self.contribution_text = nil
	self.skill_cd_hejiu = nil
	self.skill_cd_jiacai = nil
	self.button_state_hejiu = nil
	self.button_state_jiacai = nil
	self.skill_time_hejiu = nil
	self.skill_time_jiacai = nil

	self.target_obj = nil

	if self.obj_create then
		GlobalEventSystem:UnBind(self.obj_create)
		self.obj_create = nil
	end

	if self.day_count_change then
		GlobalEventSystem:UnBind(self.day_count_change)
		self.day_count_change = nil
	end
	for i = 1, 2 do
		self:RemoveCountDown(i)
	end
end

function GuildBonfireView:OpenCallBack()
	self.auto_pray = false
	self.last_gather_total_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_BONFIRE_TOTAl)
	self:Flush()
	self:StartSkillTime()
end

function GuildBonfireView:StartSkillTime()
	local hejiu_time, jiacai_time = GuildBonfireData.Instance:GetSkillTimeInfo()
	self:FlushSkillTime(hejiu_time, 1)
	self:FlushSkillTime(jiacai_time, 2)
end

function GuildBonfireView:CloseCallBack()
	self.auto_pray = false
end

function GuildBonfireView:OnObjDelete(del_obj)
	if del_obj:GetObjId() == self.target_obj:GetObjId() then
		self:Close()
	end
end

function GuildBonfireView:DaycountChange(day_counter_id)
	if day_counter_id == DAY_COUNT.DAYCOUNT_ID_GATHER_SELF_BONFIRE
		or day_counter_id == DAY_COUNT.DAYCOUNT_ID_BONFIRE_TOTAl
		or day_counter_id == DAY_COUNT.DAYCOUNT_ID_GUILD_BONFIRE_ADD_MUCAI then
		self:Flush()
	end
end

function GuildBonfireView:OnFlush()
	if nil ~= self.target_obj and nil ~= self.target_obj:GetVo() and nil ~= self.target_obj:GetVo().param then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		self.show_contribution:SetValue(guild_id == self.target_obj:GetVo().param)
		local other = GuildBonfireData.Instance:GetBonfireOtherCfg()

		self.gather_total_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_BONFIRE_TOTAl)
		self.mucai_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_BONFIRE_ADD_MUCAI)

		if self.drink_num ~= self.gather_total_num and self.not_first_open then
			ViewManager.Instance:Open(ViewName.GuildHeJiuView)
			self.drink_num = self.gather_total_num
		end

		if not self.not_first_open then
			self.drink_num = self.gather_total_num
			self.not_first_open = true
		end

		local mucai_str = string.format(Language.Guild.CurWangShengDu, self.mucai_num, other.mucai_add_count_limit)
		self.contribution_text:SetValue(mucai_str)

		local gather_str = string.format(Language.Guild.GatherBonfire, self.gather_total_num, other.gathar_max)
		self.pray_text:SetValue(gather_str)

		self:StartSkillTime()

		if self.auto_pray then
			if self.gather_total_num < other.gathar_max and self.last_gather_total_num < self.gather_total_num then
				self.last_gather_total_num = self.gather_total_num
				self:OnPray()
			end
		end
	end
end

function GuildBonfireView:Open(target_obj)
	if nil == target_obj then return end

	self.target_obj = target_obj
	BaseView.Open(self)
end

function GuildBonfireView:OnContribution()
	local other = GuildBonfireData.Instance:GetBonfireOtherCfg()
	local item_id = other.mucai_itemid or 0
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	if self.mucai_num >= other.mucai_add_count_limit then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CurWangShengDuHasMax)
		return
	end

	if item_num <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantAddMuCai)
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	local part = main_role:GetDrawObj():GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj ~= nil and not IsNil(part_obj.gameObject) then
		local animator = part_obj.animator
		animator:SetTrigger("attack5")
	end

	GuildBonfireCtrl.Instance:SendGuildBonfireAddMucaiReq(GUILD_FIRE_ADD_TYPE.GUILD_FIRE_ADD_TYPE_MUCAI, 0)
end

function GuildBonfireView:OnPray()
	local other = GuildBonfireData.Instance:GetBonfireOtherCfg()

	if self.gather_total_num >= other.gathar_max then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CurHeJiuMax)
		return
	end

	local obj_id = self.target_obj:GetObjId()
	GuildBonfireCtrl.Instance:SendGuildBonfireAddMucaiReq(GUILD_FIRE_ADD_TYPE.GUILD_FIRE_ADD_TYPE_FAKER_GATHER, obj_id)
end

function GuildBonfireView:FlushSkillTime(time,index)
	local other = GuildBonfireData.Instance:GetBonfireOtherCfg()
	local svr_time = TimeCtrl.Instance:GetServerTime()
	local next_time = time - svr_time
	local gathar_time = other.gather_cd or 1
	self:RemoveCountDown(index)

	if index == 1 then
		local function diff_time_func1 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self.skill_cd_hejiu:SetValue(0)
				self.skill_time_hejiu:SetValue("")
				self.button_state_hejiu:SetValue(true)
				self:RemoveCountDown(1)
				return
			end

			self.button_state_hejiu:SetValue(false)

			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end

			self.skill_cd_hejiu:SetValue(left_time / gathar_time)
			self.skill_time_hejiu:SetValue(left_sec)

		end
		self.montser_count_down_list1 = CountDown.Instance:AddCountDown(next_time, 0.05, diff_time_func1)

	elseif index == 2 then
		local function diff_time_func2 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self.skill_cd_jiacai:SetValue(0)
				self.skill_time_jiacai:SetValue("")
				self.button_state_jiacai:SetValue(true)
				self:RemoveCountDown(2)
				return
			end

			self.button_state_jiacai:SetValue(false)

			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end

			self.skill_cd_jiacai:SetValue(left_time / gathar_time)
			self.skill_time_jiacai:SetValue(left_sec)

		end
		self.montser_count_down_list2 = CountDown.Instance:AddCountDown(next_time, 0.05, diff_time_func2)

	end
end

function GuildBonfireView:RemoveCountDown(index)
	if index == 1 then
		if self.montser_count_down_list1 then
			CountDown.Instance:RemoveCountDown(self.montser_count_down_list1)
			self.montser_count_down_list1 = nil
		end

	elseif index == 2 then
		if self.montser_count_down_list2 then
			CountDown.Instance:RemoveCountDown(self.montser_count_down_list2)
			self.montser_count_down_list2 = nil
		end
	end
end
