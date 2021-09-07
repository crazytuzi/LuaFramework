GuildFightTrackInfoView = GuildFightTrackInfoView or BaseClass(BaseRender)
-- 任务ID
local Task_Type = {
	gather = 0,
	kill = 1,
	hu_song = 2,
}
-- 护送物品ID
local Hu_Song_Goods_Color = {
	gold_box = 1,
	sliver_box = 2,
	wood_box = 3,
	ling_pai = 4,
}
-- 物品ID
local GUILD_FIGHT_BOX_LEVEL = {
	gold_box = 1,
	ling_pai = 2,
	sliver_box = 3,
	wood_box = 4,
}

local Guild_Fight_Rank_Num = 5

function GuildFightTrackInfoView:__init(instance)
	if instance == nil then
		return
	end

	self.ji_fen = self:FindVariable("JiFen")
	self.activity_time = self:FindVariable("ActivityTime")
	self.show_hudun = self:FindVariable("ShowHuDun")
	self.show_husong = self:FindVariable("ShowHuSong")
	self.gray = self:FindVariable("Gray")
	self.rank_panel = self:FindObj("RankPanel")
	self.boss_desc = self:FindVariable("boss_desc")

	self.gray:SetValue(false)
	
	self:InitTaskPanel()
	self:InitRankPanel()

	self:ListenEvent("AutoHuSong", BindTool.Bind(self.AutoHuSong, self))
	self:ListenEvent("ClickHuDun", BindTool.Bind(self.ClickHuDun, self))
	self:ListenEvent("ClickGoldBox", BindTool.Bind(self.ClickBox, self, GUILD_FIGHT_BOX_LEVEL.gold_box))
	self:ListenEvent("ClickBoss", BindTool.Bind(self.ClickBoss, self))
	self:ListenEvent("ClickFlushInfo", BindTool.Bind(self.ClickFlushInfo, self))

	self.obj_creat = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
	self.obj_delete = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
	self.main_role_dead = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_DEAD, BindTool.Bind(self.MainRoleDead, self))
	--self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	--self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
	self.click_skill = GlobalEventSystem:Bind(MainUIEventType.CLICK_SKILL_BUTTON, BindTool.Bind(self.OnClickSkill, self))

	self.auto_pick = false
	self.box_level = 0
	self.target_obj = nil
	local info = GuildFightData.Instance:GetRoleInfo()
	self.last_score = info.history_get_person_credit or 0
	self.last_husong_goods_color = 0
	self.cur_index = 0
end

function GuildFightTrackInfoView:__delete()
	self.auto_pick = false
	if self.obj_creat then
		GlobalEventSystem:UnBind(self.obj_creat)
		self.obj_creat = nil
	end
	if self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end
	if self.obj_delete then
		GlobalEventSystem:UnBind(self.obj_delete)
		self.obj_delete = nil
	end
	--if self.move_by_click then
		--GlobalEventSystem:UnBind(self.move_by_click)
		--self.move_by_click = nil
	--end
	if self.main_role_dead then
		GlobalEventSystem:UnBind(self.main_role_dead)
		self.main_role_dead = nil
	end
	--if self.main_role_revive then
		--GlobalEventSystem:UnBind(self.main_role_revive)
		--self.main_role_revive = nil
	--end
	if self.click_skill then
		GlobalEventSystem:UnBind(self.click_skill)
		self.click_skill = nil
	end
	
	if self.task_cell_list then
		for k, v in pairs(self.task_cell_list) do
			v:DeleteMe()
		end
		self.task_cell_list = {}
	end
	--self:RemoveDelayTime()
end

function GuildFightTrackInfoView:OnFlush()
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
				if self.auto_task_type == Task_Type.gather then
					self:ClickToggle(self.auto_task_type)
				end
			end
		end
	end
	self:FlushTaskPanel()
	self:FlushRankPanel()
end

function GuildFightTrackInfoView:ClickBoss()
	self:FindBattleOrPick(GuildFightData.Instance:GetBossPos())
end

function GuildFightTrackInfoView:ClickBox(box_level)
	self.auto_pick = false
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
	if box_level == GUILD_FIGHT_BOX_LEVEL.wood_box then
		local pos_x, pos_y = GuildFightData.Instance:GetRandomWoodBoxPos()
		self:FindBattleOrPick(pos_x, pos_y, true)
	else
		local gold_box_count = GuildFightData.Instance:GetGlobalInfo().gold_box_total_count
		if gold_box_count >= 1 then
			local box_obj = nil
			local box_id = GuildFightData.Instance:GetBoxIdByLevel(GUILD_FIGHT_BOX_LEVEL.gold_box)
			if box_id then
				box_obj = Scene.Instance:GetGatherByGatherId(box_id)
			end
			if box_obj then
				self:FindBattleOrPick(box_obj.vo.pos_x, box_obj.vo.pos_y)
				MoveCache.param1 = box_id
				MoveCache.x = box_obj.vo.pos_x
				MoveCache.y = box_obj.vo.pos_y
				MoveCache.end_type = MoveEndType.GatherById
			else
				self:ApplyBoxPos()
			end
		else
			local boss_x, boss_y = GuildFightData.Instance:GetBossPos()
			self:FindBattleOrPick(boss_x, boss_y, true)
		end
	end
end

function GuildFightTrackInfoView:ApplyBoxPos()
	GuildFightCtrl.Instance:SendGoldboxPositionReq()
end

function GuildFightTrackInfoView:FindBoxPos()
	local pos_list = GuildFightData.Instance:GetGoldBoxPositionInfo() or nil
	if not pos_list or not next(pos_list) then return end

	local pos_list_num = #pos_list
	local distance = nil
	local pos_x = nil
	local pos_y = nil
	
	if pos_list_num == 1 then
		pos_x = pos_list[1].x
		pos_y = pos_list[1].y
	elseif pos_list_num > 1 then
		local main_role = Scene.Instance:GetMainRole()
		if not main_role then return end
		local role_pos_x, role_pos_y = main_role:GetLogicPos()
		for i = 1, pos_list_num do
			local pos_distance = GameMath.GetDistance(role_pos_x, role_pos_y, pos_list[i].x, pos_list[i].y, false)
			if distance == nil then
				distance = pos_distance
			end
			if pos_distance <= distance then
				distance = pos_distance
				pos_x = pos_list[i].x
				pos_y = pos_list[i].y
			end
		end
	end
	self:FindBattleOrPick(pos_x, pos_y)
end

function GuildFightTrackInfoView:FindBattleOrPick(x, y, state)
	local role_pos_x, role_pos_y = x, y
	if role_pos_x and role_pos_y then
		GuajiCtrl.Instance:CancelSelect()
		GuajiCtrl.Instance:ClearAllOperate()
		if state == nil then
			self.auto_pick = false
		else
			self.auto_pick = state
		end
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), role_pos_x, role_pos_y, 3, 1, nil, nil, false)
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
					GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), other_config.npc_x, other_config.npc_y, 1, 1, nil, nil, false)
				end
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoBox)
		end
	end
end

function GuildFightTrackInfoView:ClickHuDun()
	GuildFightCtrl.Instance:SendAddHuDunReq()
end

-- 初始化任务列表
function GuildFightTrackInfoView:InitTaskPanel()
	----------------------------------------------------
	-- 列表生成滚动条
	self.task_cell_list = {}		-- Item表
	self.task_listview_data = {}		-- 任务信息表
	self.task_list_view = self:FindObj("TaskListView")		--放置item的panel
	local task_list_delegate = self.task_list_view.list_simple_delegate
	--生成数量
	task_list_delegate.NumberOfCellsDel = function()
		return #self.task_listview_data or 0
	end
	--刷新函数
	task_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTaskListView, self)
end

function GuildFightTrackInfoView:FlushTaskPanel()
	local role_info = GuildFightData.Instance:GetRoleInfo()		--获取服务器数据的角色信息

	-- 设置list数据
	self.task_listview_data = role_info.task_list 				--获取服务器数据的任务列表的数据
	SortTools.SortAsc(self.task_listview_data, "is_complete", "task_type")	--根据 是否完成 任务类型 排序任务数据
	self:FlushTaskList()
end

function GuildFightTrackInfoView:FlushTaskList()
	if self.task_list_view.scroller.isActiveAndEnabled then
		--self.task_list_view.scroller:ReloadData(0)
		self.task_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--获取boss刷新时间
function GuildFightTrackInfoView:SetCountDownByTotalTime(total_time)
	if total_time <= 0 then
		return
	end
	if self.count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				self.boss_desc:SetValue(Language.GuildBattle.BossState)
				if self.count_down then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_time = math.floor(total_time2 - elapse_time + 0.5)
			local the_time_text = TimeUtil.FormatSecond(left_time, 2)
			self.boss_desc:SetValue(Language.GuildBattle.BossFlush .. "     " .. the_time_text)
		end
		diff_time_func(0, total_time)
		self.count_down = CountDown.Instance:AddCountDown(
			total_time, 0.5, diff_time_func)
	end
end

-- 列表listview
function GuildFightTrackInfoView:RefreshTaskListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_member_cell = self.task_cell_list[cell]
	if camp_member_cell == nil then
		camp_member_cell = GuildFightTaskItemRender.New(cell.gameObject)
		camp_member_cell:SetToggleGroup(self.task_list_view.toggle_group)
		self.task_cell_list[cell] = camp_member_cell
	end

	camp_member_cell:SetIndex(data_index)								--SerIndex() 将括号里的数据存在base_cell的index中
	camp_member_cell:SetData(self.task_listview_data[data_index])		--SetData() 将括号里的数据存在base_cell的data中
	camp_member_cell:FlushHl(self:GetCurIndex() or false)
end

function GuildFightTrackInfoView:InitRankPanel()
	self.rank_info = {}
	local name_table = self.rank_panel:GetComponent(typeof(UINameTable))
	for i = 1, Guild_Fight_Rank_Num do
		local variable_table = name_table:Find("Info" .. i):GetComponent(typeof(UIVariableTable))
		self.rank_info[i] = {}
		self.rank_info[i].name = variable_table:FindVariable("Name")
		self.rank_info[i].grade = variable_table:FindVariable("Grade")
	end
	local info = name_table:Find("MyInfo"):GetComponent(typeof(UIVariableTable))
	self.my_info = {}
	self.my_info.rank = info:FindVariable("Rank")
	self.my_info.name = info:FindVariable("Name")
	self.my_info.grade = info:FindVariable("Grade")
end

function GuildFightTrackInfoView:FlushRankPanel()
	self.my_info.rank:SetValue("")
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	if global_info then
		self.my_info.rank:SetValue(global_info.guild_rank > 0 and global_info.guild_rank or Language.Rank.NoRank)
		self.my_info.name:SetValue(GuildDataConst.GUILDVO.guild_name)
		self.my_info.grade:SetValue(global_info.guild_score)

		for i = 1, global_info.rank_count do
			local info = global_info.rank_list[i]
			if info and self.rank_info[i] ~= nil then
				self.rank_info[i].name:SetValue(info.guild_name)
				self.rank_info[i].grade:SetValue(info.score)
			end
		end
		for i = global_info.rank_count + 1, Guild_Fight_Rank_Num do
			if self.rank_info[i] ~= nil then
				self.rank_info[i].name:SetValue(Language.Common.ZanWu)
				self.rank_info[i].grade:SetValue(0)
			end
		end

		if global_info.husong_end_time > 0 then
			local rest_time = global_info.husong_end_time - TimeCtrl.Instance:GetServerTime()
			if rest_time > 0 then
				self:SetCountDownByTotalTime(rest_time)
			end
		end

		if global_info.is_boss_alive == 1 then
			self.boss_desc:SetValue(Language.GuildBattle.BossState)
		end
	end
	local role_info = GuildFightData.Instance:GetRoleInfo()
	if role_info then
		if role_info.history_get_person_credit - self.last_score > 0 then
			TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.GuildBattle.HuoDeJiFen, role_info.history_get_person_credit - self.last_score))
			self.last_score = role_info.history_get_person_credit
		end
		self.ji_fen:SetValue(role_info.history_get_person_credit)
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo then
		if main_role_vo.special_param > 0 then
			self.show_hudun:SetValue(role_info.husong_goods_color ~= Hu_Song_Goods_Color.ling_pai)
			self.auto_pick = false
		else
			self.show_hudun:SetValue(false)
		end
		self.show_husong:SetValue(main_role_vo.special_param > 0)
	end
end

--function GuildFightTrackInfoView:OnMoveByClick()
	--self.auto_pick = false
--end

function GuildFightTrackInfoView:OnGuajiTypeChange(guaji_type)
	if guaji_type ~= GuajiType.HalfAuto then
		self.auto_pick = false
		self.auto_task_type = nil
	end
end

function GuildFightTrackInfoView:OnObjCreate(obj)
	if self.auto_pick then
		if obj:GetType() == SceneObjType.GatherObj then
			if GuildFightData.Instance:GetBoxLevelById(obj:GetGatherId()) == self.box_level then
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
	if self.auto_task_type ~= state then
		self.auto_task_type = state
	end
	if state == Task_Type.gather then
		self:ClickBox(GUILD_FIGHT_BOX_LEVEL.wood_box)
	elseif state == Task_Type.kill then
		self: ClickBoss()
	elseif state == Task_Type.hu_song then
		self:ClickBox(GUILD_FIGHT_BOX_LEVEL.gold_box)
	end
end


function GuildFightTrackInfoView:MainRoleDead()
	GuildFightData.Instance:SetGoodsColor(0)
	self:Flush()
end

--function GuildFightTrackInfoView:MainRoleRevive()
	--if self.auto_pick_wood_box then
		--self:RemoveDelayTime()
		-- 延迟是因为主角复活后有可能坐标还没有reset
		--self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:FindBox(GUILD_FIGHT_BOX_LEVEL.wood_box) end, 0.5)
	--end
--end

function GuildFightTrackInfoView:OnClickSkill()
	self.auto_pick = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

--function GuildFightTrackInfoView:RemoveDelayTime()
	--if self.delay_time then
	--	GlobalTimerQuest:CancelQuest(self.delay_time)
	--	self.delay_time = nil
--	end
--end

function GuildFightTrackInfoView:SetCurIndex(index)
	self.cur_index = index
end

function GuildFightTrackInfoView:GetCurIndex()
	return self.cur_index
end

function GuildFightTrackInfoView:ClickFlushInfo()
	self:Flush()
end

----------------------------------------------------------------------------
--GuildFightTaskItemRender	任务item
----------------------------------------------------------------------------
GuildFightTaskItemRender = GuildFightTaskItemRender or BaseClass(BaseCell)

function GuildFightTaskItemRender:__init()
	self.lbl_task_name = self:FindVariable("TaskName")
	self.task_progress = self:FindVariable("TaskProgress")
	self.cur_progress = self:FindVariable("CurProgress")
	self.show_hl = self:FindVariable("ShowHL")
	-- self.is_mask_show = self:FindVariable("IsMaskShow")
	-- self.is_mask_show:SetValue(false)

	self.item_list = ItemCell.New()
	self.item_list:SetInstanceParent(self:FindObj("Item"))

	self.jifen_item = ItemCell.New()
	self.jifen_item:SetInstanceParent(self:FindObj("JiFen_Item"))
	
	self:ListenEvent("OnItemClick", BindTool.Bind(self.OnItemClickHandler, self))
end

function GuildFightTaskItemRender:__delete()
	-- for k,v in pairs(self.item_list) do
	-- 	if v.cell then
	-- 		v.cell:DeleteMe()
	-- 	end
	-- end
	-- self.item_list = {}
	if self.item_list then
		self.item_list:DeleteMe()
		self.item_list = nil
	end
		if self.jifen_item then
		self.jifen_item:DeleteMe()
		self.jifen_item = nil
	end
end

function GuildFightTaskItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	local config = GuildFightData.Instance:GetConfig() 		-- 得到guildbattle_auto信息
	if config and config.task then
		for k, v in pairs(config.task) do
			if v.task_type == self.data.task_type then
				self.lbl_task_name:SetValue(v.task_description)
				if self.data.is_complete == 1 then
					-- self.is_mask_show:SetValue(true)
					self.cur_progress:SetValue(v["condition_phase_" .. self.data.cur_phase] or v["condition_phase_" .. self.data.cur_phase - 1] )
				else
					self.cur_progress:SetValue(self.data.progress)
				end
				self.task_progress:SetValue(v["condition_phase_" .. self.data.cur_phase] or v["condition_phase_" .. self.data.cur_phase - 1])
				self:SetItemListInfo(v["reward_phase_" .. self.data.cur_phase] or v["reward_phase_" .. self.data.cur_phase - 1])
				self.jifen_item:SetData({item_id = ResPath.CurrencyToIconId.jifen,num = v["reward_credit_" .. self.data.cur_phase]})
			end
		end
	end
	self:FlushHl(GuildFightCtrl.Instance.view.track_info_view:GetCurIndex())
end

function GuildFightTaskItemRender:SetItemListInfo(data)
	if data then
		self.item_list.root_node.transform.parent.gameObject:SetActive(true)
		self.item_list:SetData(data)
	else
		self.item_list:SetData(nil)
		self.item_list.root_node.transform.parent.gameObject:SetActive(false)
	end
end

function GuildFightTaskItemRender:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function GuildFightTaskItemRender:OnItemClickHandler()
	if nil == self.data or nil == next(self.data) then return end
	GuildFightCtrl.Instance.view.track_info_view:SetCurIndex(self.index)
	GuildFightCtrl.Instance.view.track_info_view:ClickToggle(self.data.task_type)
	GuildFightCtrl.Instance.view.track_info_view:FlushTaskList()
end

function GuildFightTaskItemRender:FlushHl(index)
	if self.show_hl and index then
		self.show_hl:SetValue(index == self.index)
	end
end