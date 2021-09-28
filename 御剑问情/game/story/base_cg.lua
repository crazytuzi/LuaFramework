BaseCg = BaseCg or BaseClass()

local UILayer = GameObject.Find("GameRoot/UILayer")

function BaseCg:__init(bundle_name, asset_name)
	self.bundle_name = bundle_name
	self.asset_name = asset_name
	self.end_callback = nil
	self.start_callback = nil
	self.cg_ctrl = nil
	self.cg_obj = nil
	self.cg_layer = GameObject.Find("GameRoot/SceneObjLayer").transform
	self.timer_quest = nil
	self.is_deleted = false
	self.is_main_role_join = false
	self.is_sheild_all_monster_infb = false

	self.old_position = Vector3(0, 0, 0)
	self.old_rotation = Quaternion.identity
	self.old_scale = nil

	self.old_shield_others = false
	self.old_shield_monster = false
	self.old_main_role_visible = false

	-- 是否是跳跃cg
	self.is_jump_cg = false

	Runner.Instance:AddRunObj(self)
end

function BaseCg:__delete()
	Runner.Instance:RemoveRunObj(self)
	self.end_callback = nil
	self.start_callback = nil
	self.cg_ctrl = nil
	self.is_deleted = true
	self:StopTimerQuest()
	self:DestoryCg()

	ScenePreload.DeleteCacheCg(self.bundle_name, self.asset_name)

	SettingData.Instance:ResetAllAutoShield()
end

function BaseCg:DestoryCg()
	if nil ~= self.cg_obj then
		GameObject.Destroy(self.cg_obj)
		self.cg_obj = nil
		Scene.SendCancelMonsterStaticState()
		MainUIView.Instance:GetRootNode():SetLayerRecursively(MASK_LAYER.UI)
	end
end

function BaseCg:StopTimerQuest()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function BaseCg:Play(end_callback, start_callback, is_jump_cg)
	self.end_callback = end_callback
	self.start_callback = start_callback
	self.is_jump_cg = is_jump_cg or false
	UtilU3d.PrefabLoad(self.bundle_name, self.asset_name, function(obj)
		if self.is_deleted then
			if nil ~= obj then
				GameObject.Destroy(obj)
			end
			return
		end

		if nil == obj then
			print_error("CgManager Play obj is nil", self.bundle_name, self.asset_name)
			self:OnPlayEnd()

			return
		end

		self.cg_obj = obj
		self.cg_obj.transform:SetParent(self.cg_layer)

		self.cg_ctrl = obj:GetComponent(typeof(CGController))
		if self.cg_ctrl == nil then
			print_error("CgManager Play not exist CGController")
			self:DestoryCg()
			self:OnPlayEnd()

			return
		end

		self:StopTimerQuest()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
			self:CheckPlay()
		end, 0)
	end)
end

function BaseCg:Stop()
	if nil ~= self.cg_ctrl then
		self.cg_ctrl:Stop()
		self:DestoryCg()
		self.cg_ctrl = nil
	end

	MountCtrl.Instance:CheckMountUpOrDownInCg()

	-- 摄象机直接同步到角色，不缓动
	if not IsNil(MainCameraFollow) then
		MainCameraFollow:SyncImmediate()
	end

	self:ResumeVisible()
end

function BaseCg:CheckPlay()
	local main_role = Scene.Instance:GetMainRole()

	if nil == main_role
		or nil == main_role:GetDrawObj()
		or nil == main_role:GetRoot()
		or nil == main_role:GetDrawObj():GetPart(SceneObjPart.Main)
		or nil == main_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj() then

		return
	end

	self:StopTimerQuest()
	self.cg_ctrl:SetPlayEndCallback(BindTool.Bind(self.OnPlayEnd, self))
	self:OnPlayStart()
	self.cg_ctrl:Play()
end

function BaseCg:Update(now_time, elapse_time)
	if self.is_sheild_all_monster_infb then
		local monster_list = Scene.Instance:GetMonsterList()
		for _, v in pairs(monster_list) do
			v:GetDrawObj():SetVisible(false)
		end
	end
end

function BaseCg:OnPlayStart()
	self:ModifyTrack()

	-- 有主角参与的cg将下马参与
	if self.is_main_role_join and not self.is_jump_cg then
		MountCtrl.Instance:CheckMountUpOrDownInCg()
	end

	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	if self.start_callback then
		self.start_callback()
	end

	main_role:StopMove()
	self.old_position = main_role:GetRoot().gameObject.transform.localPosition
	self.old_rotation = main_role:GetRoot().gameObject.transform.localRotation
	self.old_scale = main_role:GetRoot().gameObject.transform.localScale

	-- cg里面屏蔽翅膀
	local draw_obj = main_role:GetDrawObj()
	if draw_obj then
		local wing_part = draw_obj:GetPart(SceneObjPart.Wing)
		wing_part:SetVisible(false)
	end

	SettingData.Instance:SystemAutoSetting(10)

	-- self.old_shield_others = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, true, true)

	-- self.old_shield_monster = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_ENEMY, true, true)


	if not IsNil(MainCamera) then
		MainCamera.gameObject:SetActive(false)
	end

	-- Scene.Instance:ShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	--屏蔽所有npc
	Scene.Instance:ShieldAllNpc()

	--屏蔽所有跑任务机器人
	RobertMgr.Instance:ShieldAllRobert()

	MainUIView.Instance:GetRootNode():SetLayerRecursively(MASK_LAYER.INVISIBLE)

	self:HandleSpecialCgOnPlay()
end

function BaseCg:HandleSpecialCgOnPlay()
	-- 隐藏主角
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end
	self.old_main_role_visible = main_role:GetDrawObj():GetObjVisible()
	if "Xzptfb01_Cg1" == self.asset_name then
		main_role:GetDrawObj():SetVisible(false)
	end

	-- 隐藏怪物
	self.is_sheild_all_monster_infb = true
	-- if "Xzptfb01_Cg1" == self.asset_name
	--   or "Gczdt01_Cg1" == self.asset_name
	--    or "Hdfb01_Cg1" == self.asset_name
	--    or "Cbfb01_Cg7" == self.asset_name
	--    or "Dgzcdt01_Cg1" == self.asset_name then
	-- end
end

function BaseCg:OnPlayEnd()
	self:DestoryCg()
	self.cg_ctrl = nil

	-- 有主角参与的cg将下马参与
	if self.is_main_role_join and not self.is_jump_cg then
		MountCtrl.Instance:CheckMountUpOrDownInCg()
	end

	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	main_role:StopMove()
	main_role:ChangeToCommonState()
	main_role:GetRoot().gameObject.transform.localPosition = self.old_position
	main_role:GetRoot().gameObject.transform.localRotation = self.old_rotation
	main_role:GetRoot().gameObject.transform.localScale = self.old_scale

	-- 摄象机直接同步到角色，不缓动
	if not IsNil(MainCamera) then
		MainCamera.gameObject:SetActive(true)
		if not IsNil(MainCameraFollow) then
			MainCameraFollow:SyncImmediate()
		end
	end

	-- 恢复之前的其他玩家屏蔽状态
	self:ResumeVisible()

	if nil ~= self.end_callback then
		self.end_callback()
	end
end

function BaseCg:ResumeVisible()
	SettingData.Instance:ResetAllAutoShield()
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, self.old_shield_others, true)
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_ENEMY, self.old_shield_monster, true)
	-- Scene.Instance:UnShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	--恢复所有npc
	Scene.Instance:UnShieldAllNpc()

	--恢复所有跑任务机器人
	RobertMgr.Instance:UnShieldAllRobert()

	-- 恢复mainui层
	MainUIView.Instance:GetRootNode():SetLayerRecursively(MASK_LAYER.UI)

	-- 恢复显示主角
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	local draw_obj = main_role:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(self.old_main_role_visible)
		local wing_part = draw_obj:GetPart(SceneObjPart.Wing)
		wing_part:SetVisible(true)
		draw_obj:AddOcclusion()
	end
	-- 恢复显示怪物
	if self.is_sheild_all_monster_infb then
		self.is_sheild_all_monster_infb = false
		local monster_list = Scene.Instance:GetMonsterList()
		for _, v in pairs(monster_list) do
			v:GetDrawObj():SetVisible(true)
		end
	end
end

function BaseCg:ModifyTrack()
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	local vo = main_role:GetVo()

	local draw_obj = main_role:GetDrawObj()
	if draw_obj then
		draw_obj:RemoveOcclusion()
	end

	-- 把主角obj替换到cg里
	local succ1 = self.cg_ctrl:AddActor(main_role:GetDrawObj():GetPart(SceneObjPart.Main):GetObj().gameObject, "MainRoleActTrack")
	local succ2 = self.cg_ctrl:AddActor(main_role:GetRoot().gameObject, "MainRoleTrack")
	self.is_main_role_join = succ1 or succ2

	local act_track_name = string.format("1%d0%d", main_role:GetVo().sex, main_role:GetVo().prof)
	-- 开启主角的动作(默认全部静默中)
	for i = GameEnum.FEMALE, GameEnum.MALE  do
		for j = GameEnum.ROLE_PROF_1, GameEnum.ROLE_PROF_4 do
			local track_name = string.format("1%d0%d", i, j)
			self.cg_ctrl:SetTrackMute(track_name, act_track_name ~= track_name)
		end
	end
end