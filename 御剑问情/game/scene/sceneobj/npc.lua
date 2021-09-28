Npc = Npc or BaseClass(SceneObj)

function Npc:__init(vo)
	self.obj_type = SceneObjType.Npc
	self.draw_obj:SetObjType(self.obj_type)

	self.last_task_index = -1
	self.select_effect = nil

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,
		BindTool.Bind(self.OnTaskChange, self))
	self.timer = 0

	self.role_res = 0
	self.weapen_res = 0
	self.mount_res = 0
	self.wing_res = 0
	self.halo_res = 0
	self.monster_id = 0
end

function Npc:__delete()
	if nil ~= self.select_effect then
		self.select_effect:DeleteMe()
		self.select_effect = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end
	if self.task_effect then
		GameObjectPool.Instance:Free(self.task_effect)
		self.task_effect = nil
	end
end

function Npc:InitInfo()
	SceneObj.InitInfo(self)

	local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.vo.npc_id]
	if nil == npc_config then
		print_log("npc_config not find npc_id:" .. self.vo.npc_id)
		return
	end

	self.vo.name = npc_config.show_name
	self.res_id = npc_config.resid
	self.head_id = npc_config.headid
	self.obj_scale = npc_config.scale
	self.role_res = npc_config.role_res or 0
	self.weapen_res = npc_config.weapen_res or 0
	self.mount_res = npc_config.mount_res or 0
	self.wing_res = npc_config.wing_res or 0
	self.halo_res = npc_config.halo_res or 0
	self.monster_id = npc_config.monster_res
	if not self.monster_id or self.monster_id == "" then
		self.monster_id = 0
	end

	self.timer = 0
end

function Npc:InitShow()
	SceneObj.InitShow(self)

	self.load_priority = 10
	if self.obj_scale ~= nil then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(self.obj_scale, self.obj_scale, self.obj_scale)
	end

	if self.role_res <= 0 then
		if self.monster_id <= 0 then
			self:InitModel(ResPath.GetNpcModel(self.res_id))
		else
			self:InitModel(ResPath.GetMonsterModel(self.monster_id))
		end
	else
		self:ChangeModel(SceneObjPart.Main, ResPath.GetRoleModel(self.role_res))
		if self.weapen_res > 0 then
			self:ChangeModel(SceneObjPart.Weapon, ResPath.GetWeaponModel(self.weapen_res))
			-- 如果是枪手模型
			if math.floor(self.role_res / 1000) % 1000 == 3 then
				self:ChangeModel(SceneObjPart.Weapon2, ResPath.GetWeaponModel(self.weapen_res + 1))
			end
		end
		if self.wing_res > 0 then
			self:ChangeModel(SceneObjPart.Wing, ResPath.GetWingModel(self.wing_res))
		end
		if self.mount_res > 0 then
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res))
		end
	end
	self.draw_obj:Rotate(0, self.vo.rotation_y or 0, 0)
end

function Npc:InitModel(bundle, asset)
	if AssetManager.Manifest ~= nil and not AssetManager.IsVersionCached(bundle) then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetNpcModel(4026001))

		DownloadHelper.DownloadBundle(bundle, 3, function(ret)
			if ret then
				self:ChangeModel(SceneObjPart.Main, bundle, asset)
			end
		end)
	else
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Npc:OnEnterScene()
	SceneObj.OnEnterScene(self)
	self:GetFollowUi()
	self:PlayAction()
	self:UpdateTitle()
	-- self:UpdateTaskEffect()

	self:UpdataBubble()
	self:UpdataTimer()
end

function Npc:HideFollowUi()
end

function Npc:IsNpc()
	return true
end

function Npc:GetObjKey()
	return self.vo.npc_id
end

function Npc:GetNpcId()
	return self.vo.npc_id
end

function Npc:GetNpcHead()
	return self.head_id
end

function Npc:OnClick()
	SceneObj.OnClick(self)
	if nil == self.select_effect then
		self.select_effect = AsyncLoader.New(self.draw_obj:GetRoot().transform)
		self.select_effect:Load(ResPath.GetSelectObjEffect3("lvse"))
		self.select_effect:SetLocalScale(Vector3(1, 1, 1))
	end
	self.select_effect:SetActive(true)
end

function Npc:CancelSelect()
	-- SceneObj.CancelSelect(self)
	self.is_select = false
	if nil ~= self.select_effect then
		self.select_effect:SetActive(false)
	end
end

function Npc:PlayAction()
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("Action")
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function() self:PlayAction() end, 10)
		end
	end
end

function Npc:FlushTaskEffect(enable, bundle, asset)
	if self.task_effect then
		GameObjectPool.Instance:Free(self.task_effect)
		self.task_effect = nil
	end
	if enable then
		GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
			if not obj then return end
			local draw_obj = self:GetDrawObj()
			if not draw_obj then
				GameObjectPool.Instance:Free(obj)
				return
			end
			local parent_transform = draw_obj:GetAttachPoint(AttachPoint.UI)
			if not parent_transform then
				GameObjectPool.Instance:Free(obj)
				return
			end

			obj.transform:SetParent(parent_transform, false)
			self.task_effect = obj
		end)
	end
end

function Npc:ChangeTaskEffect(index)
	if self.last_task_index ~= index then
		self.last_task_index = index
		if index >= 0 then
			local bubble, asset = ResPath.GetTaskNpcEffect(index)
			self:FlushTaskEffect(true, bubble, asset)
		else
			self:FlushTaskEffect(false)
		end
	end
end
function SceneObj:ReloadUIName()
	if self.follow_ui ~= nil then
		if self.draw_obj and self.draw_obj:GetObjVisible() then
			self.follow_ui:SetName(self.vo.name or "", self)
		else
			self.follow_ui:SetName("", self)
		end
	end
end

function Npc:UpdateTaskEffect()
	local task_cfg = TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId())
	if task_cfg then
		local status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
		if status == TASK_STATUS.CAN_ACCEPT then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo then
				local level = main_role_vo.level
				if task_cfg.min_level > level then
					status = 0
				end
			end
		end
		self:ChangeTaskEffect(status)
	else
		self:ChangeTaskEffect(-1)
	end
end

function Npc:ChangeSpecailTitle(index)
	if self.last_task_index ~= index then
		self.last_task_index = index
		if index >= 0 then
			local str = "task_" .. index
			local bubble, asset = ResPath.GetTitleModel(str)
			self:GetFollowUi():ChangeTitle(bubble, asset, 0, 60)
		else
			self:GetFollowUi():ChangeTitle(nil)
		end
	end
end

function Npc:UpdateTitle()
	local task_cfg = TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId())
	if task_cfg then
		local status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
		if status == TASK_STATUS.CAN_ACCEPT then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo then
				local level = main_role_vo.level
				if task_cfg.min_level > level then
					status = 0
				end
			end
		end
		self:ChangeSpecailTitle(status)
	else
		self:ChangeSpecailTitle(-1)
	end
	
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.HunYanFb and self.vo.npc_type and self.vo.npc_type == SceneObjType.FakeNpc then
		local user_info = MarriageData.Instance:GetHunyanQuestionUserInfo()
		if user_info and self.vo.npc_idx and self.vo.npc_idx == user_info.cur_question_idx then
			self:ChangeSpecailTitle(3)
		else
			self:ChangeSpecailTitle(-1)
		end
	end
end

function Npc:OnTaskChange()
	self:UpdateTitle()
	-- self:UpdateTaskEffect()
end

function Npc:GetBubbletext()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_npc_list
	for k,v in pairs(bubble_cfg) do
		if v.npc_id == self:GetNpcId() then
			return v.bubble_npc_text
		end
	end
end

function Npc:UpdataBubble()
	if TaskData.Instance:GetNpcOneExitsTask(self:GetNpcId()) then return end
	local rand_num = math.random(1, 10)
	local npc_odds = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].npc_odds
	if rand_num * 0.1 <= npc_odds then
		local text = self:GetBubbletext()
		if nil ~= text then
			self:GetFollowUi():ChangeBubble(text)
		end
	end
end

function Npc:UpdataTimer()
	self.timer = self.timer + 1
	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, 1)
	if self.timer > 5 then
		self:GetFollowUi():HideBubble()
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
end

function Npc:IsWalkNpc()
	return false
end