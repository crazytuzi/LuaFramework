GuildFightTrackInfoView = GuildFightTrackInfoView or BaseClass(BaseRender)

function GuildFightTrackInfoView:__init(instance)
	if instance == nil then
		return
	end

	self.box_count1 = self:FindVariable("BoxCount1")
	self.box_count2 = self:FindVariable("BoxCount2")
	self.reminding = self:FindVariable("Reminding")
	self.ji_fen = self:FindVariable("JiFen")
	self.reward = self:FindVariable("Reward")
	self.activity_time = self:FindVariable("ActivityTime")
	self.precent = self:FindVariable("Precent")
	self.show_button = self:FindVariable("ShowButton")
	self.gray = self:FindVariable("Gray")
	self.rank_panel = self:FindObj("RankPanel")
	self.auto_toggle = self:FindObj("AutoToggle").toggle

	self.gray:SetValue(false)
	self.item_cell = {}
	for i = 1, 3 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New(self.item_cell[i].obj)
	end

	self:InitRankPanel()

	self:ListenEvent("AutoHuSong",
		BindTool.Bind(self.AutoHuSong, self))
	self:ListenEvent("OpenGuildJiFen",
		BindTool.Bind(self.OpenGuildJiFen, self))
	self:ListenEvent("ClickHuDun",
		BindTool.Bind(self.ClickHuDun, self))
	self:ListenEvent("ClickGoldBox",
		BindTool.Bind(self.ClickBox, self, GUILD_FIGHT_BOX_LEVEL.gold_box))
	self:ListenEvent("ClickSliverBox",
		BindTool.Bind(self.ClickBox, self, GUILD_FIGHT_BOX_LEVEL.sliver_box))
	self:ListenEvent("ClickToggle",
		BindTool.Bind(self.ClickToggle, self))

	self.obj_creat = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
	self.obj_delete = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
	self.main_role_dead = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_DEAD, BindTool.Bind(self.MainRoleDead, self))
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK,
		BindTool.Bind(self.OnMoveByClick, self))
	self.click_skill = GlobalEventSystem:Bind(MainUIEventType.CLICK_SKILL_BUTTON,
		BindTool.Bind(self.OnClickSkill, self))

	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.ClickBoss, self))
	self.auto_pick = false
	self.box_level = 0
	self.target_obj = nil
	local info = GuildFightData.Instance:GetRoleInfo()
	self.last_score = info.history_get_person_credit or 0
	self.last_husong_goods_color = 0

	local boss_id = GuildFightData.Instance:GetBossId() or 0
	FuBenCtrl.Instance:SetMonsterInfo(boss_id)
end

function GuildFightTrackInfoView:__delete()
	self.auto_pick = false
	if self.obj_creat then
		GlobalEventSystem:UnBind(self.obj_creat)
		self.obj_creat = nil
	end
	if self.obj_delete then
		GlobalEventSystem:UnBind(self.obj_delete)
		self.obj_delete = nil
	end
	if self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end
	if self.main_role_dead then
		GlobalEventSystem:UnBind(self.main_role_dead)
		self.main_role_dead = nil
	end
	if self.main_role_revive then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end
	if self.click_skill then
		GlobalEventSystem:UnBind(self.click_skill)
		self.click_skill = nil
	end
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
	FuBenCtrl.Instance:ClearMonsterClickCallBack()
	self:RemoveDelayTime()
end

function GuildFightTrackInfoView:Flush()
	local role_info = GuildFightData.Instance:GetRoleInfo()
	if role_info then
		if role_info.is_add_hudun == 1 then
			self.gray:SetValue(true)
		else
			self.gray:SetValue(false)
		end
		if self.last_husong_goods_color ~= role_info.husong_goods_color then
			self.last_husong_goods_color = role_info.husong_goods_color
			if role_info.husong_goods_color > 0 then
				self:AutoHuSong()
			else
				if self.auto_pick_wood_box then
					self:FindBox(GUILD_FIGHT_BOX_LEVEL.wood_box)
				end
			end
		end
	end
	self:FlushRankPanel()
end

function GuildFightTrackInfoView:ClickBoss()
	-- local global_info = GuildFightData.Instance:GetGlobalInfo()
	-- if global_info then
	-- 	if global_info.is_boos_alive ~= 1 then
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.GuildBattle.BossDie)
	-- 		return
	-- 	end
	-- end
	local boss_x, boss_y = GuildFightData.Instance:GetBossPos()
	if boss_x and boss_y then
		GuajiCtrl.Instance:CancelSelect()
		GuajiCtrl.Instance:ClearAllOperate()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), boss_x, boss_y, 1, 1)
	end
end

function GuildFightTrackInfoView:ClickBox(box_level)
	self.auto_pick = false
	self.auto_toggle.isOn = false
	self:FindBox(box_level)
end

function GuildFightTrackInfoView:FindBox(box_level)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		if main_role_vo.special_param > 0 then
			self:AutoHuSong()
			return
		end
	end
	self.box_level = box_level
	local gather_obj_list = Scene.Instance:GetObjListByType(SceneObjType.GatherObj)
	local temp_list = {}
	if gather_obj_list then
		for k,v in pairs(gather_obj_list) do
			local obj_id = v:GetGatherId()
			if obj_id then
				temp_list[GuildFightData.Instance:GetBoxLevelById(obj_id)] = v
			end
		end
	end

	local box_obj = nil
	for i = 1, 4 do
		if temp_list[i] then
			if GuildFightData.Instance:GetBoxLevelById(temp_list[i]:GetGatherId()) <= box_level then
				box_obj = temp_list[i]
			end
			break
		end
	end
	if box_obj then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		MoveCache.end_type = MoveEndType.Gather
		GuajiCtrl.Instance:MoveToObj(box_obj, 3, 1)
	else
		if box_level == GUILD_FIGHT_BOX_LEVEL.wood_box then
			local pos_x, pos_y = GuildFightData.Instance:GetRandomWoodBoxPos()
			if pos_x and pos_y then
				self.auto_pick = true
				GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_x, pos_y, 1, 1)
			end
		else
			local boss_x, boss_y = GuildFightData.Instance:GetBossPos()
			if boss_x and boss_y then
				GuajiCtrl.Instance:CancelSelect()
				GuajiCtrl.Instance:ClearAllOperate()
				self.auto_pick = true
				GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), boss_x, boss_y, 1, 1)
			end
		end
	end
end

function GuildFightTrackInfoView:AutoHuSong()
	local role_info = GuildFightData.Instance:GetRoleInfo()
	if role_info then
		if role_info.husong_goods_color > 0 then
			local config = GuildFightData.Instance:GetConfig()
			if config then
				local other_config = config.other[1]
				if other_config then
					MoveCache.end_type = MoveEndType.NpcTask
					MoveCache.param1 = other_config.npc_id
					GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
					GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), other_config.npc_x, other_config.npc_y, 1, 1)
				end
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoBox)
		end
	end
end

function GuildFightTrackInfoView:OpenGuildJiFen()
	self.rank_panel:SetActive(true)
	self:FlushRankPanel()
end

function GuildFightTrackInfoView:ClickHuDun()
	GuildFightCtrl.Instance:SendAddHuDunReq()
end

function GuildFightTrackInfoView:InitRankPanel()
	self.rank_info = {}
	local name_table = self.rank_panel:GetComponent(typeof(UINameTable))
	for i = 1, 10 do
		local variable_table = name_table:Find("Info" .. i):GetComponent(typeof(UIVariableTable))
		self.rank_info[i] = {}
		self.rank_info[i].name = variable_table:FindVariable("Name")
		self.rank_info[i].grade = variable_table:FindVariable("Grade")
	end
	local info = name_table:Find("MyInfo"):GetComponent(typeof(UIVariableTable))
	self.my_info = {}
	self.my_info.no1 = info:FindVariable("No1")
	self.my_info.no2 = info:FindVariable("No2")
	self.my_info.no3 = info:FindVariable("No3")
	self.my_info.rank = info:FindVariable("Rank")
	self.my_info.name = info:FindVariable("Name")
	self.my_info.grade = info:FindVariable("Grade")
end

function GuildFightTrackInfoView:FlushRankPanel()
	self.my_info.no1:SetValue(false)
	self.my_info.no2:SetValue(false)
	self.my_info.no3:SetValue(false)
	self.my_info.rank:SetValue("")
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	if global_info then
		if global_info.guild_rank == 1 then
			self.my_info.no1:SetValue(true)
		elseif global_info.guild_rank == 2 then
			self.my_info.no2:SetValue(true)
		elseif global_info.guild_rank == 3 then
			self.my_info.no3:SetValue(true)
		else
			self.my_info.rank:SetValue(global_info.guild_rank)
		end
		self.my_info.name:SetValue(GuildDataConst.GUILDVO.guild_name)
		self.my_info.grade:SetValue(global_info.guild_score)

		for i = 1, global_info.rank_count do
			local info = global_info.rank_list[i]
			if info then
				self.rank_info[i].name:SetValue(info.guild_name)
				self.rank_info[i].grade:SetValue(info.score)
			end
		end

		for i = global_info.rank_count + 1, 10 do
			self.rank_info[i].name:SetValue(Language.Common.ZanWu)
			self.rank_info[i].grade:SetValue(0)
		end

		self.box_count1:SetValue(global_info.gold_box_total_count .. Language.Common.UnitName[1])
		self.box_count2:SetValue(global_info.sliver_box_total_count .. Language.Common.UnitName[1])

		if global_info.husong_end_time > 0 then
			local rest_time = global_info.husong_end_time - TimeCtrl.Instance:GetServerTime()
			if rest_time > 0 then
				FuBenCtrl.Instance:SetMonsterDiffTime(rest_time)
			end
		end

		if global_info.is_boos_alive == 1 then
			self.reminding:SetValue(Language.Guild.BossZhan)
			FuBenCtrl.Instance:ShowMonsterHadFlush(true)
		else
			FuBenCtrl.Instance:ShowMonsterHadFlush(false)
			self.reminding:SetValue(Language.Guild.ZhengDuoBaoXiang)
		end
	end
	local role_info = GuildFightData.Instance:GetRoleInfo()
	if role_info then
		if role_info.history_get_person_credit - self.last_score > 0 then
			TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.GuildBattle.HuoDeJiFen, role_info.history_get_person_credit - self.last_score))
			self.last_score = role_info.history_get_person_credit
		end
		self.ji_fen:SetValue(role_info.history_get_person_credit)
		local config, next_config = GuildFightData.Instance:GetRewardInfoByScore(role_info.history_get_person_credit)
		if not next_config then
			self.reward:SetValue(Language.Guild.QuanBuLingQi)
			next_config = config
		else
			self.reward:SetValue(string.format(Language.Guild.DaDaoJiFen, ToColorStr(next_config.reward_credit_min, TEXT_COLOR.GREEN_3)))
		end
		if next_config then
			for i = 1, 3 do
				local item_info = next_config.reward_item[i - 1]
				if item_info then
					self.item_cell[i].obj:SetActive(true)
					self.item_cell[i].cell:SetData(item_info)
				else
					self.item_cell[i].obj:SetActive(false)
				end
			end
		end
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		if main_role_vo.special_param > 0 then
			self.show_button:SetValue(true)
			self.auto_pick = false
		else
			self.show_button:SetValue(false)
		end
	end
end

function GuildFightTrackInfoView:OnMoveByClick()
	self.auto_pick = false
	self.auto_toggle.isOn = false
end

function GuildFightTrackInfoView:OnObjCreate(obj)
	if self.auto_pick then
		if obj:GetType() == SceneObjType.GatherObj then
			if GuildFightData.Instance:GetBoxLevelById(obj:GetGatherId()) <= self.box_level then
				self.auto_pick = false
				self.target_obj = obj
				MoveCache.end_type = MoveEndType.Gather
				GuajiCtrl.Instance:MoveToObj(obj, 3, 1)
			end
		end
	end
end

function GuildFightTrackInfoView:OnObjDelete(obj)
	if self.target_obj == obj then
		local role_info = GuildFightData.Instance:GetRoleInfo()
		if role_info then
			if role_info.husong_goods_color <= 0 then
				if self.auto_pick_wood_box then
					self:FindBox(GUILD_FIGHT_BOX_LEVEL.wood_box)
				end
			end
		end
		self.target_obj = nil
	end
end

function GuildFightTrackInfoView:ClickToggle(state)
	self.auto_pick_wood_box = state
	if state then
		self:FindBox(GUILD_FIGHT_BOX_LEVEL.wood_box)
	else
		self.target_obj = nil
	end
end

function GuildFightTrackInfoView:MainRoleDead()
	GuildFightData.Instance:SetGoodsColor(0)
	self:Flush()
end

function GuildFightTrackInfoView:MainRoleRevive()
	if self.auto_pick_wood_box then
		self:RemoveDelayTime()
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:FindBox(GUILD_FIGHT_BOX_LEVEL.wood_box) end, 0.5)
	end
end

function GuildFightTrackInfoView:OnClickSkill()
	self.auto_pick = false
	self.auto_toggle.isOn = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function GuildFightTrackInfoView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end