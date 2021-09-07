GuildStationView = GuildStationView or BaseClass(BaseView)

local RewardCount = 3

function GuildStationView:__init()
	self.ui_config = {"uis/views/guildview","GuildStationView"}
	self.view_layer = UiLayer.MainUI

	self.last_chat_time = -10
	self.is_safe_area_adapter = true
end

function GuildStationView:__delete()

end

function GuildStationView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
	if self.show_or_hide_other_button then
        GlobalEventSystem:UnBind(self.show_or_hide_other_button)
        self.show_or_hide_other_button = nil
    end

    self.boss_name = nil
	self.show_reward = nil
	self.notice = nil
	self.hide = nil
	self.no_call = nil
	self.exp = nil
	self.value = nil
	self.precent = nil
	self.percent_text = nil
end

function GuildStationView:LoadCallBack()
	self.item_cell = {}
	for i = 1, RewardCount do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
		self.item_cell[i].cell:SetInteractable(false)
		if i > 1 then
			self.item_cell[i].obj:SetActive(false)
		end
	end
	self.boss_name = self:FindVariable("BossName")
	self.show_reward = self:FindVariable("ShowReward")
	self.notice = self:FindVariable("Notice")
	self.hide = self:FindVariable("Hide")
	self.no_call = self:FindVariable("NoCall")
	self.exp = self:FindVariable("Exp")
	self.value = self:FindVariable("Value")
	self.precent = self:FindVariable("Percent")
	self.percent_text = self:FindVariable("PercentText")
	self:ListenEvent("OnClickKill",
		BindTool.Bind(self.OnClickKill, self))
	self:ListenEvent("OnClickReminder",
		BindTool.Bind(self.OnClickReminder, self))
	self.precent:SetValue(1)
	self.percent_text:SetValue("100%")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
        BindTool.Bind(self.SwitchButtonState, self))
end

function GuildStationView:OpenCallBack()
	self:Flush()
	if MainUICtrl.Instance.view and MainUICtrl.Instance.view:IsLoaded() then
		local state = MainUICtrl.Instance.view.MenuIconToggle.isOn
		self.hide:SetValue(state or false)
	end
end

function GuildStationView:CloseCallBack()
    self:RemoveCountDown()
end

function GuildStationView:OnFlush()
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		self.exp:SetValue(boss_activity_info.totem_exp)
		local boss_info = GuildData.Instance:GetBossInfo()
		if boss_activity_info.boss_id == 0 then
			self.show_reward:SetValue(false)
			local notice = Language.Guild.BossDontCall
			self.no_call:SetValue(false)
			if boss_info then
				if boss_info.boss_normal_call_count > 0 then
					notice = Language.Guild.BossHasKilled
				else
					local post = GuildData.Instance:GetGuildPost()
					if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
						self.no_call:SetValue(true)
					end
				end
			end
			self.notice:SetValue(notice)
			self:RemoveCountDown()
		else
			self.show_reward:SetValue(true)
			local boss_name = Language.Guild.NormalBoss2
			local boss_res = GuildData.Instance:GetBossZhaoHuanRes()
			local boss_jiangli = ""
			local boss_jieshu = 0
			if boss_activity_info.is_surper_boss == 1 then
				boss_name = Language.Guild.SurperBoss2
				boss_jieshu = 1
				if boss_res then
					boss_jiangli = boss_res.super_item_reward
				end
			else
				if boss_res then
					boss_jiangli = boss_res.normal_item_reward
				end
			end
			self.item_cell[1].cell:SetData(boss_jiangli)
			self.item_cell[1].cell:SetInteractable(true)

			local guild_putong_boss_cfg =  GuildData.Instance:GetGuildBossRse(boss_jieshu)
			if guild_putong_boss_cfg then
				boss_name = string.format(boss_name, boss_jieshu, guild_putong_boss_cfg.boss_level)
			end

			self.boss_name:SetValue(boss_name)
			local boss_config = GuildData.Instance:GetGuildActiveConfig().boss_cfg
			if boss_config then
				local config = boss_config[boss_activity_info.boss_level]
				if config then
					-- self.item_cell[1].cell:SetData(config.normal_item_reward)
				end
			end
			if not self.count_down then
				self.count_down = CountDown.Instance:AddCountDown(999999, 0.5, BindTool.Bind(self.BossHpUpdate, self))
			end
		end
	end
end

-- Boss血量改变
function GuildStationView:BossHpUpdate()
	local boss_obj_id = -1
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		boss_obj_id = boss_activity_info.boss_obj_id
	end
	local boss_obj = Scene.Instance:GetObj(boss_obj_id)
	if not boss_obj then return end

	local value = boss_obj:GetAttr("hp") / boss_obj:GetAttr("max_hp")
	local cur_percent = math.ceil(value*100)
	self.precent:SetValue(value)
	self.percent_text:SetValue(cur_percent.."%")
	value = value * 100
	value = value - value % 0.1
	self.value:SetValue(value .. "%")
end

function GuildStationView:OnClickKill()
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		local config = GuildData.Instance:GetGuildBossInfo(boss_activity_info.boss_id)
		if config then
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), config.pos_x, config.pos_y)
		end
	end
end

function GuildStationView:SwitchButtonState(state)
    if state then
        state = false
    else
        state = true
    end
    self.hide:SetValue(state)
end

function GuildStationView:OnClickReminder()
	if self.last_chat_time + 10 >= Status.NowTime then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SpeackMax)
	else
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, Language.Guild.BossActivity)
		self.last_chat_time = Status.NowTime
	end
end

function GuildStationView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end