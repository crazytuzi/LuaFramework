GuildBossView = GuildBossView or BaseClass(BaseView)

function GuildBossView:__init()
	self.ui_config = {"uis/views/guildview","GuildBossView"}
	self:SetMaskBg()
end

function GuildBossView:__delete()

end

function GuildBossView:LoadCallBack()
	self.item_cells = {}
	for i = 1, 2 do
		self.item_cells[i] = {}
		self.item_cells[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cells[i].cell = ItemCell.New()
		self.item_cells[i].cell:SetInstanceParent(self.item_cells[i].obj)
	end

	self.putong_boss_item = {}
	for i = 1, 2 do
		self.putong_boss_item[i] = ItemCell.New(self:FindObj("PuTongBossItem" .. i))
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
	self.activity_time = self:FindVariable("ActivityTime")

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

	-- local config = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.GUILD_BOSS)
	-- if config then
	-- 	local str = Language.Common.Week
	-- 	local open_day_list = Split(config.open_day, ":")
	-- 	if open_day_list then
	-- 		for i = 1, #open_day_list do
	-- 			local day = tonumber(open_day_list[i])
	-- 			day = Language.Common.DayToChs[day]
	-- 			str = str .. day
	-- 			if i ~= #open_day_list then
	-- 				str = str .. "、"
	-- 			end
	-- 		end
	-- 		str = str .. config.open_time .. "-" .. config.end_time
	-- 	end
	-- 	-- self.activity_time:SetValue(string.format(Language.Guild.BossTime, str))
	-- end
	local time_str = GuildData.Instance:GetGuildActiveConfig()
	self.activity_time:SetValue(time_str.other[1].boss_call_explain)
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

	if self.item_cells then
		for k,v in pairs(self.item_cells) do
			if v.cell then
				v.cell:DeleteMe()
			end
		end
	end
	self.item_cells = {}

	if self.putong_boss_item then
		for k,v in pairs(self.putong_boss_item) do
			if v.cell then
				v.cell:DeleteMe()
			end
		end
	end
	self.putong_boss_item = {}

	-- 清理变量和对象
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
	self.activity_time = nil
end

function GuildBossView:OpenCallBack()
	GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
	self:Flush()
end

-- 刷新名字的接口
function GuildBossView:FlushName()
	local player_info = CheckData.Instance:GetRoleInfoChange()
	if player_info and self.player_name then
		self.player_name:SetValue(player_info.role_name)
	end
end

function GuildBossView:OnFlush()
	local feed_id = GuildData.Instance:GetBossFeedItemId()
	local number = 0
	if feed_id then
		number = ItemData.Instance:GetItemNumInBagById(feed_id)
		self.feed_count:SetValue(string.format(Language.Guild.HasShouLingDan, number))
	end

	local boss_info = GuildData.Instance:GetBossInfo()
	if boss_info then
		if boss_info.boss_super_call_uid > 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(boss_info.boss_super_call_uid)
		end
		-- local boss_super_call_name = boss_info.boss_super_call_name
		if boss_info.boss_super_call_uid <= 0 then
			local boss_super_call_name = Language.Common.ZanWu
			self.player_name:SetValue(boss_super_call_name)
		end
		
		if boss_info.boss_normal_call_count > 0 then
			self.has_called:SetValue(true)
		else
			self.has_called:SetValue(false)
		end
		if boss_info.boss_super_call_count > 0 then
			self.has_surper_called:SetValue(true)
		else
			self.has_surper_called:SetValue(false)
		end
		local boss_config = GuildData.Instance:GetGuildActiveConfig()
		if boss_config then
			self.cost:SetValue(boss_config.other[1].boss_super_call_gold)
			boss_config = boss_config.boss_cfg
			self.cur_level:SetValue(string.format(Language.Guild.NormalBoss, CommonDataManager.GetDaXie(0)))
			self.show_feed_red:SetValue(false)
			-- local next_config = boss_config[boss_info.boss_level + 2]
			-- if next_config then
			-- 	if number > 0 and boss_info.boss_normal_call_count <= 0 then
			-- 		self.show_feed_red:SetValue(true)
			-- 	end
			-- 	self.max_level:SetValue(false)
			-- else
			-- 	self.max_level:SetValue(true)
			-- end
			self.max_level:SetValue(false)

			self.next_level:SetValue(string.format(Language.Guild.SurperBoss, CommonDataManager.GetDaXie(1)))
			-- local bundle, asset = ResPath.GetImages("Grade_Green")
			-- self.cur_title:SetAsset(bundle, asset)
			-- self.next_title:SetAsset(bundle, asset)
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
			local guild_putong_boss_cfg =  GuildData.Instance:GetGuildBossRse(0)
			local guild_chaoji_boss_cfg =  GuildData.Instance:GetGuildBossRse(1)

			local putong_item_list = ItemData.Instance:GetGiftItemList(guild_putong_boss_cfg.normal_item_reward.item_id)
			local chaoji_item_list = ItemData.Instance:GetGiftItemList(guild_chaoji_boss_cfg.super_item_reward.item_id)

			for i=1,#putong_item_list do
				self.putong_boss_item[i]:SetData({item_id = putong_item_list[i].item_id,num = putong_item_list[i].num})
			end
			for i=1,#chaoji_item_list do
				self.item_cells[i].cell:SetData({item_id = chaoji_item_list[i].item_id,num = chaoji_item_list[i].num})
			end

			-- self:FlushBossModel(guild_putong_boss_cfg.boss_id)
			-- self:FlushSurperBossModel(guild_chaoji_boss_cfg.boss_id)
			if monster_cfg then
				local temp_config = monster_cfg[guild_putong_boss_cfg.boss_id]
				local chaoji_config = monster_cfg[guild_chaoji_boss_cfg.boss_id]
				if temp_config then
					self:FlushBossModel(temp_config.resid)
				end
				if chaoji_config then
					-- self:FlushSurperBossModel(temp_config.resid)
				end
			end
			local config = boss_config[0]
			if config then
				self.exp:SetValue(boss_info.boss_exp .. "/" .. config.uplevel_exp)
				local value = boss_info.boss_exp / config.uplevel_exp
				value = value > 1 and 1 or value
				self.value:SetValue(value)
				-- self:FlushRewardIcon(6, config.normal_item_reward)
				-- self:FlushRewardIcon(5, {item_id = ResPath.CurrencyToIconId.bind_diamond, num = 1})
			end
			config = boss_config[1]
			if config then
				if monster_cfg then
					local temp_config = monster_cfg[guild_chaoji_boss_cfg.boss_id]
					if temp_config then
						self:FlushSurperBossModel(temp_config.resid)
					end
				end
				-- for i = 3, 4 do
				-- 	self.item_cells[i].obj:SetActive(false)
				-- end
				-- self.item_cells[1].cell:SetData({item_id = ResPath.CurrencyToIconId.bind_diamond, num = 1})
				-- local reward = config.super_call_item_reward
				-- if reward then
				-- 	if self.item_cells[2].cell then
				-- 		self.item_cells[2].cell:SetData(reward)
				-- 	end
				-- end
			end
		end
	end
end

function GuildBossView:FlushBossModel(resid)
	if not self.boss_model then
		self.boss_model = RoleModel.New()
	end
	if self.last_boss_resid ~= resid then
		self.boss_model:SetDisplay(self.boss_display.ui3d_display)
		self.boss_model:SetMainAsset(ResPath.GetMonsterModel(resid))
		self.boss_model:SetModelScale(Vector3(0.6, 0.6, 0.6))
		self.last_boss_resid = resid
	end
end

function GuildBossView:FlushSurperBossModel(resid)
	if not self.boss_model2 then
		self.boss_model2 = RoleModel.New()
	end
	if self.last_boss_resid2 ~= resid then
		self.boss_model2:SetDisplay(self.boss_display2.ui3d_display)
		self.boss_model2:SetMainAsset(ResPath.GetMonsterModel(resid))
		self.boss_model2:SetModelScale(Vector3(0.6, 0.6, 0.6))
		self.last_boss_resid2 = resid
	end
end

function GuildBossView:Call()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() ~= SceneType.GuildStation then
			GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
			return
		end
	end

	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPowerBoss)
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
		local yes_func = function() GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL)
		self:Close()
		GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ) end

		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildBossView:SurperCall()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() ~= SceneType.GuildStation then
			GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AutoReturn)
			return
		end
	end
	
	local boss_info = GuildData.Instance:GetBossInfo()
	local boss_other_cfg = GuildData:GetGuildActiveConfig().other
	if boss_info then
		local describe = string.format(Language.Guild.SurperCallBoss, boss_other_cfg[1].boss_super_call_gold)
		local yes_func = function() GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_CALL, 1)
		self:Close()
		GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ) end

		--TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
        TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func,nil,true,nil,nil,Language.Guild.SurperCallText)
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
	TipsCtrl.Instance:ShowHelpTipView(61)
end

function GuildBossView:OnClickClose()
	self:Close()
end