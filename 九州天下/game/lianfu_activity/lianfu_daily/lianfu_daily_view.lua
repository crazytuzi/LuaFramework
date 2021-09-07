LianFuDailyView = LianFuDailyView or BaseClass(BaseView)
LianFuDailyView.GatherId = 0

function LianFuDailyView:__init()
	self.ui_config = {"uis/views/lianfuactivity/lianfudaily", "LianFuDailyView"}
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false
	self.select_task_index = 1
	self.select_boss_index = 1
end

function LianFuDailyView:__delete()
end

function LianFuDailyView:ReleaseCallBack()
	self.gold_list = {}
	self.male_num = {}
	self.female_num = {}
	self.cell = {}
	self.sizu_cell = {}
	self.gongzu_cell = {}
	self.judian_num = {}
	self.gold_out_put_list = {}
	self.show_progress = nil
	self.progress = nil
	self.belong_server = nil
	self.help_des = nil
	self.show_attribute = nil
	self.task_list = nil
	self.boss_list = nil
	self.captive_num = nil
	self.midao_status = nil
	self.show_task = nil
	self.show_toggle = nil
	self.btn_task = nil
	self.btn_judian = nil

	for _,v in pairs(self.task_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.task_cell_list = {}

	for _,v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = {}

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.start_gather_event)
		self.start_gather_event = nil
	end
end

function LianFuDailyView:LoadCallBack()
	self.gold_list = {}
	self.male_num = {}
	self.female_num = {}
	self.cell = {}
	self.sizu_cell = {}
	self.gongzu_cell = {}
	self.judian_num = {}
	self.gold_out_put_list = {}
	self.task_cell_list = {}
	self.boss_cell_list = {}

	for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
		self.gold_list[i] = self:FindVariable("gold" .. i)
		self.male_num[i] = self:FindVariable("male_num" .. i)
		self.female_num[i] = self:FindVariable("female_num" .. i)
		self.judian_num[i] = self:FindVariable("judian_num" .. i)
		self.gold_out_put_list[i] = self:FindVariable("GoldOutPut" .. i)
		self.cell[i] = self:FindObj("Cell" .. i)
		self:ListenEvent("OnClickCaptive" .. i, BindTool.Bind(self.OnClickCaptive, self, i))
	end
	self.show_progress = self:FindVariable("ShowProgress")
	self.progress = self:FindVariable("Progress")
	self.belong_server = self:FindVariable("BelongServer")
	self.help_des = self:FindVariable("HelpDes")
	self.show_attribute = self:FindVariable("ShowAttribute")
	self.captive_num = self:FindVariable("captive_num")
	self.midao_status = self:FindVariable("midao_status")
	self.show_task = self:FindVariable("show_task")
	self.show_toggle = self:FindVariable("show_toggle")
	self.btn_task = self:FindObj("BtnTask")
	self.btn_judian = self:FindObj("BtnJuDian")

	self.task_list = self:FindObj("TaskList")
	local list_view_delegate = self.task_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTaskNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTaskView, self)

	self.boss_list = self:FindObj("BossList")
	local list_view_delegate = self.boss_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossView, self)

	self:ListenEvent("OnClickToggleJuDian", BindTool.Bind(self.OnClickToggleJuDian, self))
	self:ListenEvent("OnClickToggleTask", BindTool.Bind(self.OnClickToggleTask, self))
	self:ListenEvent("OnClickCloseJuDian", BindTool.Bind(self.OnClickCloseJuDian, self))
	self:ListenEvent("OnClickCloseTask", BindTool.Bind(self.OnClickCloseTask, self))
	self:ListenEvent("OnGoToCaptive", BindTool.Bind(self.OnGoToCaptive, self))
	self:ListenEvent("OnGoToMiDao", BindTool.Bind(self.OnGoToMiDao, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.OnClose, self))

	self:CreateJuDianCell()
	self:Flush("midao_info")

	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER, BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER, BindTool.Bind(self.OnStartGather, self))
end

function LianFuDailyView:OpenCallBack()
	self:FlushTaskView()
end

function LianFuDailyView:GetTaskNumberOfCells()
	return #KuafuGuildBattleData.Instance:GetNewTaskCfg()
end

function LianFuDailyView:RefreshTaskView(cell, data_index)
	data_index = data_index + 1

	local task_cell = self.task_cell_list[cell]
	if task_cell == nil then
		task_cell = LianFuTaskItemCell.New(cell.gameObject)
		task_cell.parent_view = self
		self.task_cell_list[cell] = task_cell
	end
	task_cell:SetIndex(data_index)
	local data = KuafuGuildBattleData.Instance:GetNewTaskCfg()
	task_cell:SetData(data[data_index])
end

function LianFuDailyView:GetBossNumberOfCells()
	return #KuafuGuildBattleData.Instance:GetBossList()
end

function LianFuDailyView:RefreshBossView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = LianFuBossItemCell.New(cell.gameObject)
		boss_cell.parent_view = self
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	local data = KuafuGuildBattleData.Instance:GetBossList()
	boss_cell:SetData(data[data_index])
end

function LianFuDailyView:CreateJuDianCell()
	PrefabPool.Instance:Load(AssetID("uis/views/lianfuactivity/lianfudaily_prefab", "JuDianCell"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 0, 8 do
	       	local judian_cfg = LianFuDailyData.Instance:GetJuDianGroupCfg(1)
	        local obj = U3DObject(GameObject.Instantiate(prefab))
	        local obj_transform = obj.transform
	        obj_transform:SetParent(self.cell[1].transform, false)
            obj_transform.localPosition = Vector3(-math.floor(i % 3) * 120, -math.floor(i / 3) * 120, 0)
            obj:GetComponent(typeof(UIVariableTable)):FindVariable("judian_name"):SetValue(judian_cfg[i + 1].name) 
	 		obj:GetComponent(typeof(UIEventTable)):ListenEvent("OnClickCell", BindTool.Bind(self.OnClickCell, self, 1, i + 9))
	 		self.sizu_cell[i] = obj

	       	local judian_cfg = LianFuDailyData.Instance:GetJuDianGroupCfg(0)
            local obj = U3DObject(GameObject.Instantiate(prefab))
	        local obj_transform = obj.transform
	        obj_transform:SetParent(self.cell[2].transform, false)
            obj_transform.localPosition = Vector3(math.floor(i % 3) * 120, -math.floor(i / 3) * 120, 0)
            obj:GetComponent(typeof(UIVariableTable)):FindVariable("judian_name"):SetValue(judian_cfg[i + 1].name) 
	 		obj:GetComponent(typeof(UIEventTable)):ListenEvent("OnClickCell", BindTool.Bind(self.OnClickCell, self, 0, i))
	 		self.gongzu_cell[i] = obj
        end

        PrefabPool.Instance:Free(prefab)

        self:Flush("score_info")
    end)
end

function LianFuDailyView:OnClickCell(judian_type, judian_id)
	local cfg = LianFuDailyData.Instance:GetSignleJuDianCfg(judian_id, judian_type)
	local pos_list = Split(cfg.center_pos, ",")
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_list[1], pos_list[2])
end

function LianFuDailyView:OnClickToggleJuDian()
	self.show_attribute:SetValue(true)
	self.show_task:SetValue(false)
end

function LianFuDailyView:OnClickToggleTask()
	self.show_task:SetValue(true)
	self.show_attribute:SetValue(false)
end

function LianFuDailyView:OnClickCloseJuDian()
	self.show_attribute:SetValue(true)
	self.show_attribute:SetValue(false)
end

function LianFuDailyView:OnClickCloseTask()
	self.show_task:SetValue(true)
	self.show_task:SetValue(false)
end

function LianFuDailyView:OnGoToCaptive()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local server_group = main_role_vo.server_group == 1 and 0 or 1
	local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(server_group)
	if cfg and next(cfg) then
		local pos_list = Split(cfg.captive_born_pos, ",")
		if pos_list and next(pos_list) then
			GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, pos_list[1], pos_list[2])
		end
	end
end

function LianFuDailyView:OnGoToMiDao()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(main_role_vo.server_group)
	if cfg and next(cfg) then
		local pos_list = Split(cfg.midao_transport_pos, ",")
		if pos_list and next(pos_list) then
			GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, pos_list[1], pos_list[2])
		end
	end
end

function LianFuDailyView:OnClose()
	self:OnClickCloseJuDian()
	self:OnClickCloseTask()
end

function LianFuDailyView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "score_info" then
			local source_item_list = LianFuDailyData.Instance:GetSourceItemList()
			local judian_num_list = LianFuDailyData.Instance:GetJuDianNum()
			for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
				self.gold_list[i]:SetValue(CommonDataManager.ConverNum(source_item_list[i].server_gold))
				self.male_num[i]:SetValue(source_item_list[i].male_captive_num)
				self.female_num[i]:SetValue(source_item_list[i].female_captive_num)
				self.judian_num[i]:SetValue(judian_num_list[i])
			end

			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			local server_group = role_vo.server_group == 1 and 0 or 1
			local captive_num = source_item_list[server_group + 1].male_captive_num + source_item_list[server_group + 1].female_captive_num
			self.captive_num:SetValue(string.format(Language.LianFuDaily.CaptiveNum, captive_num))

			local judian_info_list = LianFuDailyData.Instance:GetOwnJuDianInfoList()
			for i = 0, 8 do
				if self.gongzu_cell[i] then
			        self.gongzu_cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("cell_bg"):SetAsset(ResPath.GetLianFuDailyImage("img_judian_" .. judian_info_list[i + 1]))
				end
				if self.sizu_cell[i] then
			        self.sizu_cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("cell_bg"):SetAsset(ResPath.GetLianFuDailyImage("img_judian_" .. judian_info_list[i + 10]))
		    	end 
		    end

		    local judian_cfg = LianFuDailyData.Instance:GetCrossXYJDCfg()
		    if judian_cfg and judian_cfg.other[1] then
		    	local add_gold_time_s = judian_cfg.other[1].add_gold_interval_s / 60
		    	local activity_cfg = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_XYJD)
		    	local activity_state = activity_cfg ~= nil and activity_cfg.status or ACTIVITY_STATUS.CLOSE
		    	local gongzu_add_gold = 0
		    	local shizu_add_gold = 0
			    for m, n in pairs(judian_info_list) do
			    	local info = LianFuDailyData.Instance:GetJuDianIdCfg(m - 1)[1]
			    	local add_gold = activity_state == ACTIVITY_STATUS.OPEN and info.open_status_add_gold or info.close_status_add_gold
			    	if n == 0 then
			    		gongzu_add_gold = gongzu_add_gold + (add_gold / add_gold_time_s)
			    	else
			    		shizu_add_gold = shizu_add_gold + (add_gold / add_gold_time_s)
			    	end
			    end
			    self.gold_out_put_list[1]:SetValue(gongzu_add_gold)
			    self.gold_out_put_list[2]:SetValue(shizu_add_gold)
			    self.help_des:SetValue(judian_cfg.other[1].judian_introduction)
			end
		elseif k == "judian_info" then
			local info = LianFuDailyData.Instance:GetCrossXYJDJudianInfo()
			local cfg = LianFuDailyData.Instance:GetJuDianIdCfg(info.id)
			self.progress:SetValue(info.progress / cfg[1].judian_max_progress)
		elseif k == "belong_server" then
			local info = LianFuDailyData.Instance:GetCrossXYJDJudianInfo()
			local judian_info_list = LianFuDailyData.Instance:GetOwnJuDianInfoList()
			local judian_belong = judian_info_list[info.id + 1] or 0
			self.belong_server:SetValue(string.format(Language.LianFuDaily.BelongServe, Language.Convene.ServerGroup[judian_belong]))
		elseif k == "midao_info" then
			local is_open = LianFuDailyData.Instance:GetMiDaoIsOpen()
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			local open_status = is_open[role_vo.server_group + 1] or 0
			self.midao_status:SetValue(string.format(Language.LianFuDaily.MiDaoStatus, Language.LianFuDaily.MiDaoIsOpen[open_status]))
		elseif k == "task_view" then
			if self.show_attribute then
				self.show_attribute:SetValue(v.is_show)
			end
			if self.show_task then
				self.show_task:SetValue(v.is_show)
			end
		end
	end

	self:FlushTaskView()
end

function LianFuDailyView:FlushTaskList()
	if self.task_list then
		self.task_list.scroller:ReloadData(0)
	end
end

function LianFuDailyView:FlushBossList()
	if self.boss_list then
		self.boss_list.scroller:ReloadData(0)
	end
end

function LianFuDailyView:FlushTaskView()
	local scene_type = Scene.Instance:GetSceneType()
	if self.show_toggle then
		self.show_toggle:SetValue(scene_type ~= SceneType.XianYangCheng)
	end
	if scene_type == SceneType.XianYangCheng then
		if self.btn_task then
			self.btn_task.toggle.isOn = false
		end
		if self.btn_judian then
			self.btn_judian.toggle.isOn = false
		end
	end
end

function LianFuDailyView:ShowProgress(value)
	if self.show_progress then
		self.show_progress:SetValue(value)
	end
end

function LianFuDailyView:OnClickCaptive(group)
	local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(group - 1)
	if cfg and next(cfg) then
		local pos_list = Split(cfg.captive_born_pos, ",")
		if pos_list and next(pos_list) then
			GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, pos_list[1], pos_list[2])
		end
	end
end

function LianFuDailyView:SetSelectTaskIndex(select_task_index)
	self.select_task_index = select_task_index
end

function LianFuDailyView:GetSelectTaskIndex()
	return self.select_task_index or 1
end

function LianFuDailyView:FlushAllTaskHL()
	for k,v in pairs(self.task_cell_list) do
		v:FlushHL()
	end
end

function LianFuDailyView:SetSelectBossIndex(select_boss_index)
	self.select_boss_index = select_boss_index
end

function LianFuDailyView:GetSelectBossIndex()
	return self.select_boss_index or 1
end

function LianFuDailyView:FlushAllBossHL()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL()
	end
end

---------------------------------- copy -------------------------------------------------------
function LianFuDailyView:OnStopGather()
	self.is_gather = false
	if LianFuDailyView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function LianFuDailyView:OnStartGather()
	self.is_gather = true
end

local old_select_id = 0
function LianFuDailyView:TaskClick(scene_id, task_id, is_auto)
	self.target_scene_id = scene_id

	local data = self:GetTaskDataByID(task_id)
	GuajiCtrl.Instance:StopGuaji()
	if data == nil or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		return
	end

	self.auto_task_id = task_id
	old_select_id = 0
	KuafuGuildBattleData.Instance:NotifyTaskProcessChange(task_id, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()
end

function LianFuDailyView:StopAutoTask()
	KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
	self:FlushAllTaskHL()
end

function LianFuDailyView:GetTaskDataByID(task_id)
	local index = KuafuLiuJieSceneId[self.target_scene_id]
	local data = KuafuGuildBattleData.Instance:GetTaskCfgInfo(index) or {}
	local s_data = data.list or {}
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function LianFuDailyView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == LianFuDailyView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function LianFuDailyView:AutoDoTask()
	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local scene_index = KuafuLiuJieSceneId[self.target_scene_id]
		local task_info = KuafuGuildBattleData.Instance:GetTaskCfgInfo(scene_index).list

		if task_info then
			local info = task_info[1]
			if info then
				if not info.statu == 1 then
					self.auto_task_id = info.cfg.task_id
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.target_scene_id, self.auto_task_id, true)
		else
			LianFuDailyView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
			-- self:ClearToggle()
		end
		return
	end
	local scene_id = self.target_scene_id
	local list = nil
	local end_type = nil
	local target = nil

	if data.cfg.task_type == 0 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.task_param)
		LianFuDailyView.GatherId = data.cfg.task_param
	else
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.task_param)
		LianFuDailyView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = data.cfg.task_param
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == data.cfg.task_param  then
				if not AStarFindWay:IsBlock(v.x, v.y) then
					local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
					if distance < target_distance then
						target_distance = distance
						x = v.x
						y = v.y
						id = v.id
					end
				end
			end
		end
	end
	MoveCache.end_type = end_type
	MoveCache.param1 = id
	MoveCache.task_id = 0
	GuajiCache.target_obj_id = id
	if scene_id == Scene.Instance:GetSceneId() then
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 4, 2)
	else
		GuajiCtrl.Instance:MoveToScenePos(scene_id, x, y, 4, 2)
	end
end
----------------------------------------------------------------------------------------

------------------------LianFuTaskItemCell------------------------------
LianFuTaskItemCell = LianFuTaskItemCell or BaseClass(BaseCell)

function LianFuTaskItemCell:__init()
	self.task_name = self:FindVariable("TaskName")
	self.zhangong = self:FindVariable("ZhanGong")
	self.exp = self:FindVariable("Exp")
	self.show_hl = self:FindVariable("ShowHL")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function LianFuTaskItemCell:__delete()
	self.parent_view = nil
end

function LianFuTaskItemCell:ClickItem()
	self.parent_view:SetSelectTaskIndex(self.index)
	self.parent_view:FlushAllTaskHL()
	self.parent_view:TaskClick(self.data.cfg.scene_id, self.data.cfg.task_id)
end

function LianFuTaskItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local target_text = "(" ..self.data.record .. "/" .. self.data.cfg.task_count .. ")"
	if self.data.record < self.data.cfg.task_count then
		local color_str = ToColorStr(target_text,TEXT_COLOR.RED)
		self.task_name:SetValue("<color=#ffffff>" .. self.data.cfg.task_content .. "</color>" .. color_str)
	else
		local color_str = ToColorStr(target_text,TEXT_COLOR.GREEN)
		self.task_name:SetValue("<color=#ffffff>" .. self.data.cfg.task_content .. "</color>" .. color_str)
	end

	self.zhangong:SetValue(self.data.cfg.reward_credit)
	if self.data.cfg.reward_item and self.data.cfg.reward_item.item_id then
		local item_name = ItemData.Instance:GetItemName(self.data.cfg.reward_item.item_id)
		self.exp:SetValue("x" .. self.data.cfg.reward_item.num)
	end
end

function LianFuTaskItemCell:FlushHL()
	local select_task_index = self.parent_view:GetSelectTaskIndex()
	self.show_hl:SetValue(select_task_index == self.index)
end

------------------------LianFuBossItemCell------------------------------
LianFuBossItemCell = LianFuBossItemCell or BaseClass(BaseCell)

function LianFuBossItemCell:__init()
	self.boss_name = self:FindVariable("BossName")
	self.boss_level = self:FindVariable("BossLevel")
	self.status = self:FindVariable("Status")
	self.show_hl = self:FindVariable("ShowHL")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function LianFuBossItemCell:__delete()
	self.parent_view = nil

	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function LianFuBossItemCell:ClickItem()
	self.parent_view:SetSelectBossIndex(self.index)
	self.parent_view:FlushAllBossHL()

	local x, y = 0, 0
	local list = KuafuGuildBattleData.Instance:GetBossCfg()
	for k,v in pairs(list) do
		if v.boss_id == self.data.boss_id then
			x = v.born_x
			y = v.born_y
		end
	end

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 10, 10)
end

function LianFuBossItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.boss_level:SetValue("Lv." .. monster_cfg.level)
		self.boss_name:SetValue(monster_cfg.name)
	end

	if self.data.next_refresh_time <= 0 or self.data.statu == 1 then
		self.status:SetValue(ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN))
	else
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnCountDown, self), 1, self.data.next_refresh_time - TimeCtrl.Instance:GetServerTime())
		self:OnCountDown()
	end
end

function LianFuBossItemCell:FlushHL()
	local select_index = self.parent_view:GetSelectBossIndex()
	self.show_hl:SetValue(select_index == self.index)
end

function LianFuBossItemCell:OnCountDown()
	if self.data == nil or next(self.data) == nil then
		return
	end
	
	local time = math.max(0, self.data.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 or self.data.status == 1 then
		self.status:SetValue(ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN))
	else
		self.status:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end