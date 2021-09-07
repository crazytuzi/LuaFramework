
GuildBonfireView = GuildBonfireView or BaseClass(BaseView)

function GuildBonfireView:__init()
	self.ui_config = {"uis/views/guildview","GuildBonfireView"}
	self.auto_pray = false
	self.last_gather_total_num = 0
	-- self.view_layer = UiLayer.MainUILow
end

function GuildBonfireView:__delete()

end

function GuildBonfireView:LoadCallBack()
	self.show_contribution = self:FindVariable("ShowContribution")
	self.pray_text = self:FindVariable("PrayText")
	self.contribution_text = self:FindVariable("ContriButionText")

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
	if self.obj_create then
		GlobalEventSystem:UnBind(self.obj_create)
		self.obj_create = nil
	end

	if self.day_count_change then
		GlobalEventSystem:UnBind(self.day_count_change)
		self.day_count_change = nil
	end
end

function GuildBonfireView:OpenCallBack()
	self.auto_pray = false
	self.last_gather_total_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_BONFIRE_TOTAl)
	self:Flush()
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


		local mucai_str = string.format(Language.Guild.CurWangShengDu, self.mucai_num, other.mucai_add_count_limit)
		self.contribution_text:SetValue(mucai_str)

		local gather_str = string.format(Language.Guild.GatherBonfire, self.gather_total_num, other.gathar_max)
		self.pray_text:SetValue(gather_str)

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
	if self.mucai_num >= other.mucai_add_count_limit then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CurWangShengDuHasMax)
		return
	end
	GuildBonfireCtrl.Instance:SendGuildBonfireAddMucaiReq()
end

function GuildBonfireView:OnPray()
	self.auto_pray = true
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = self.target_obj:GetGatherId()
	GuajiCache.target_obj_id = self.target_obj:GetGatherId()
	local x, y = self.target_obj:GetLogicPos()
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 1, 1)
end

