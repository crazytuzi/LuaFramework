GuildBossView = GuildBossView or BaseClass(BaseView)

local DISPLAYNAME = {
	[3012001] = "guild_boss_panel_special_1",
	[3007001] = "guild_boss_panel_special_1",
	[3005001] = "guild_boss_panel_special_7",
	[3002001] = "guild_boss_panel_special_2",
	[3003001] = "guild_boss_panel_special_8",
	[3001001] = "guild_boss_panel_special_3",
	[3026001] = "guild_boss_panel_special_4",
	[3013001] = "guild_boss_panel_special_5",
	[3037001] = "guild_boss_panel_special_6",
	[3036001] = "guild_boss_panel_special_6",
}

BOSS_GATHER_REWARD_ITEM_ID = 26909

function GuildBossView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildBossView"}
end

function GuildBossView:__delete()

end

function GuildBossView:LoadCallBack()
	self.item_cells = {}
	for i = 1, 6 do
		self.item_cells[i] = {}
		self.item_cells[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cells[i].cell = ItemCell.New()
		self.item_cells[i].cell:SetInstanceParent(self.item_cells[i].obj)
	end

	self.boss_display = self:FindObj("BossDisplay")
	self.boss_display2 = self:FindObj("BossDisplay2")

	self.cur_level = self:FindVariable("CurLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.exp = self:FindVariable("Exp")
	self.value = self:FindVariable("Value")
	-- self.cur_title = self:FindVariable("CurTitle")
	-- self.next_title = self:FindVariable("NextTitle")
	self.player_name = self:FindVariable("PlayerName")
	self.show_feed_red = self:FindVariable("ShowFeedRed")
	self.cost = self:FindVariable("Cost")
	self.feed_count = self:FindVariable("FeedCount")
	self.has_called = self:FindVariable("HasCalled")
	self.has_surper_called = self:FindVariable("HasSurperCalled")
	self.max_level = self:FindVariable("MaxLevel")
	self.max_level2 = self:FindVariable("MaxLevel2")
	self.activity_time = self:FindVariable("ActivityTime")
	self.prog_supertext = self:FindVariable("Prog_SuperCalled_Text")
	self.image_sunshine = self:FindVariable("ImageSunShine")
	self.image_item = self:FindVariable("ImageItem")
	self.btn_maxlevel = self:FindVariable("Btn_MaxLevel")
	self.btn_level = self:FindVariable("Btn_Level")
	self.normbar_bool = self:FindVariable("Bar_NormalCall")
	self.superboss_call = self:FindVariable("SuperBoss_Active")
	self.show_normal_kill = self:FindVariable("show_normal_kill")
	self.show_super_kill = self:FindVariable("show_super_kill")
	self.normalboss_call = self:FindVariable("NormalBoss_Active")


	self.superboss_call:SetValue(false)
	self.normalboss_call:SetValue(false)

	self:ListenEvent("Call",
		BindTool.Bind(self.Call, self))
	self:ListenEvent("SurperCall",
		BindTool.Bind(self.SurperCall, self))
	self:ListenEvent("Feed",
		BindTool.Bind(self.Feed, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self.last_boss_resid = 0
	self.last_boss_resid2 = 0

	local config = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILD_BOSS)
	if config then
		local str = Language.Common.Week
		local open_day_list = Split(config.open_day, ":")
		if open_day_list then
			for i = 1, #open_day_list do
				local day = tonumber(open_day_list[i])
				day = Language.Common.DayToChs[day]
				str = str .. day
				if i ~= #open_day_list then
					str = str .. "、"
				end
			end
			str = str .. config.open_time .. "-" .. config.end_time
		end
		self.activity_time:SetValue(string.format(Language.Guild.BossTime, str))
	end
end

function GuildBossView:FlushRewardIcon(index, item)
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	if item then
		if self.item_cells[index].cell then
			self.item_cells[index].cell:SetData(item)
		end
	end
end

function GuildBossView:ReleaseCallBack()
	if self.boss_model then
		self.boss_model:DeleteMe()
		self.boss_model = nil
	end
	if self.boss_model2 then
		self.boss_model2:DeleteMe()
		self.boss_model2 = nil
	end
	self.last_boss_resid = 0
	self.last_boss_resid2 = 0

	for k,v in pairs(self.item_cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.normalboss_call = nil
	self.show_super_kill = nil
	self.show_normal_kill = nil
	self.superboss_call = nil
	self.normbar_bool = nil
	self.btn_maxlevel = nil
	self.btn_level = nil
	self.image_item = nil
	self.image_sunshine = nil
	self.prog_supertext = nil
	self.boss_display = nil
	self.boss_display2 = nil
	self.cur_level = nil
	self.next_level = nil
	self.exp = nil
	self.value = nil
	self.player_name = nil
	self.show_feed_red = nil
	self.cost = nil
	self.feed_count = nil
	self.has_called = nil
	self.has_surper_called = nil
	self.max_level = nil
	self.max_level2 = nil
	self.activity_time = nil
end

function GuildBossView:OpenCallBack()
	self.is_first = true
	GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
	self:Flush()
end

function GuildBossView:OnFlush()
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	local number = 0
	if feed_id then
		number = ItemData.Instance:GetItemNumInBagById(feed_id)
		self.feed_count:SetValue(string.format(Language.Guild.HasShouLingDan, number))
	end

	local boss_info = GuildData.Instance:GetBossInfo()
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_info then
		local boss_super_call_name = boss_info.boss_super_call_name
		if boss_super_call_name == nil or boss_super_call_name == "" then
			boss_super_call_name = Language.Common.ZanWu
		end
		self.player_name:SetValue(boss_super_call_name)
		if boss_info.boss_normal_call_count == 1 then
			self.has_called:SetValue(true)
			self.normalboss_call:SetValue(true)
		else
			self.has_called:SetValue(false)
			self.normalboss_call:SetValue(false)
		end

		if boss_info.boss_super_call_count == 1  then
			self.has_surper_called:SetValue(true)
			self.superboss_call:SetValue(true)
			self.normalboss_call:SetValue(false)
		else
			self.has_surper_called:SetValue(false)
			self.superboss_call:SetValue(false)
		end
		local boss_config = GuildData.Instance:GetGuildActiveConfig()


		if boss_info.boss_level == 8 then
			self.image_item:SetValue(false)
			self.btn_level:SetValue(false)
			self.btn_maxlevel:SetValue(true)
			self.normbar_bool:SetValue(false)
		else
			self.image_item:SetValue(true)
			self.btn_level:SetValue(true)
			self.btn_maxlevel:SetValue(false)
			self.normbar_bool:SetValue(true)
		end

		if boss_activity_info then
			if boss_info.boss_normal_call_count > 0 and boss_activity_info.boss_id == 0   then
				self.show_normal_kill:SetValue(true)
				self.normalboss_call:SetValue(false)
			end

			if 	boss_info.boss_super_call_count > 0 and boss_activity_info.boss_id == 0 then
				self.show_super_kill:SetValue(true)
				self.superboss_call:SetValue(false)
				self.normalboss_call:SetValue(false)
			end
		end

		if boss_config then

			self.cost:SetValue(boss_config.other[1].boss_super_call_gold)
			boss_config = boss_config.boss_cfg
			self.show_feed_red:SetValue(false)
			local next_config = boss_config[boss_info.boss_level + 2]
			if next_config then
				if number > 0 and boss_info.boss_normal_call_count <= 0 then
					self.show_feed_red:SetValue(true)

				end
				self.max_level:SetValue(false)
			else
				self.max_level:SetValue(true)
			end

			if boss_info.boss_exp ~= 0 then
				self.image_sunshine:SetValue(true)
			else
				self.image_sunshine:SetValue(false)
			end


			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
			local config = boss_config[boss_info.boss_level]
			if config then
				self.prog_supertext:SetValue(boss_info.boss_exp .. " / " .. config.uplevel_exp)
				self.exp:SetValue(boss_info.boss_exp .. " / " .. config.uplevel_exp)
				local value = boss_info.boss_exp / config.uplevel_exp
				value = value > 1 and 1 or value
				if self.is_first then
					self.value:InitValue(value)
					self.is_first = false
				else
					self.value:SetValue(value)
				end
				self:FlushRewardIcon(6, config.normal_item_reward)
				self:FlushRewardIcon(5, {item_id = BOSS_GATHER_REWARD_ITEM_ID, num = 1})
				if monster_cfg then
					local temp_config = monster_cfg[config.boss_id]
					local temp_next_config = monster_cfg[config.boss_id + 1]
					if temp_next_config then
						self.next_level:SetValue(string.format(Language.Guild.SurperBoss, CommonDataManager.GetDaXie(boss_info.boss_level + 2), temp_next_config.name))
					end
					if temp_config then
						self:FlushBossModel(temp_config.resid)
						self.cur_level:SetValue(string.format(Language.Guild.NormalBoss, CommonDataManager.GetDaXie(boss_info.boss_level + 1), temp_config.name))
					end
				end
			end
			config = boss_config[boss_info.boss_level + 1]
			if config then
				if monster_cfg then
					local temp_config = monster_cfg[config.boss_id]
					if temp_config then
						self:FlushSurperBossModel(temp_config.resid)
					end
				end
				for i = 3, 4 do
					self.item_cells[i].obj:SetActive(false)
				end
				self.item_cells[1].cell:SetData({item_id = BOSS_GATHER_REWARD_ITEM_ID, num = 1})
				local reward = config.super_call_item_reward
				if reward then
					if self.item_cells[2].cell then
						self.item_cells[2].cell:SetData(reward)
					end
				end
			end
		end
	end
end

function GuildBossView:FlushBossModel(resid)
	if not self.boss_model then
		self.boss_model = RoleModel.New("guild_boss_panel")
	end
	if self.last_boss_resid ~= resid then
		self.boss_model:SetDisplay(self.boss_display.ui3d_display)
		self.boss_model:SetPanelName(self:SetSpecialModle(resid))
		self.boss_model:SetMainAsset(ResPath.GetMonsterModel(resid))
		self.last_boss_resid = resid
	end
end

function GuildBossView:FlushSurperBossModel(resid)
	if not self.boss_model2 then
		self.boss_model2 = RoleModel.New("guild_boss_panel")
	end
	if self.last_boss_resid2 ~= resid then
		self.boss_model2:SetDisplay(self.boss_display2.ui3d_display)
		self.boss_model2:SetPanelName(self:SetSpecialModle(resid))
		self.boss_model2:SetMainAsset(ResPath.GetMonsterModel(resid))
		self.last_boss_resid2 = resid
	end
end

function GuildBossView:Call()
	local flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
	if flag then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
				return
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
		return
	end
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
		return
	else
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotInGuildStation)
				return
			end
		end
	end

	local boss_info = GuildData.Instance:GetBossInfo()
	if boss_info then
		local describe = Language.Guild.CallBoss
		local yes_func =
			function()
				GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL)
				GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
			end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildBossView:SurperCall()
	local flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
	if flag then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() ~= SceneType.GuildStation then
				GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
				return
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
		return
	end
	local boss_info = GuildData.Instance:GetBossInfo()
	local boss_config = GuildData.Instance:GetGuildActiveConfig()
	if boss_config and boss_info then
		local need_gold = boss_config.other[1].boss_super_call_gold
		local describe = string.format(Language.Guild.SurperCallBoss, ToColorStr(need_gold, TEXT_COLOR.BLUE1))
		local yes_func = function() GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL, 1)
		GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ) end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end

end

function GuildBossView:Feed()
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	if feed_id then
		local number = ItemData.Instance:GetItemNumInBagById(feed_id)
		if number < 1 then
			TipsCtrl.Instance:ShowItemGetWayView(feed_id)
			return
		end
	end
	GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_UPLEVEL)
end

function GuildBossView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(272)
end

function GuildBossView:OnClickClose()
	self:Close()
end

function GuildBossView:CloseCallBack()
	GuildCtrl.Instance:FlushCell()
end

function GuildBossView:SetSpecialModle(modle_id)
	local display_name = "guild_boss_panel"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end