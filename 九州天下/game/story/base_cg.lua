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
	self.is_sheild_all_npc_infb = false
	self.is_sheild_diaoqiao = false

	self.old_position = Vector3(0, 0, 0)
	self.old_rotation = nil
	self.old_scale = nil

	self.old_shield_others = false
	self.old_shield_monster = false
	self.old_mainui_layer = 0
	self.old_main_role_visible = false

	-- 是否是跳跃cg
	self.is_jump_cg = false

	-- 隐藏主角的CG场景名字
	self.is_main_role_hide_cg = {
		["Xzptfb01_Cg1"] = 1,
		["Gz_Dyfb01_Cg1"] = 1,
		["GZ_Fbfb01_Cg1"] = 1,
		["GZ_Ghfb01_Cg1"] = 1,
		["GZ_Ghfb01_Cg2"] = 1,
		["GZ_Ghfb01_Cg3"] = 1,
		["GZ_Mrghfb01_Cg1"] = 1,
		["GZ_Mrghfb01_Cg2"] = 1,
		["GZ_Pffb01_Cg1"] = 1,
		["Gz_Sbbjfb01_Cg1"] = 1,
		["Gz_Sbbjfb01_Cg2"] = 1,
		["GZ_Zdfb01_Cg1"] = 1,
		["GZ_Zdfb01_Cg2"] = 1,
		["GZ_Zqjj01_Cg1"] = 1,
		["GZ_Zqjj01_Cg2"] = 1,
		["GZ_Zqjj01_Cg3"] = 1,
		["GZ_Hy01_Cg1"] = 1,
	}

	-- 隐藏怪物的CG场景名字
	self.is_monster_hide_cg = {
		["Xzptfb01_Cg1"] = 1,
		["Gczdt01_Cg1"] = 1,
		["Hdfb01_Cg1"] = 1,
		["Cbfb01_Cg7"] = 1,
		["Dgzcdt01_Cg1"] = 1,
		["Gz_Dyfb01_Cg1"] = 1,
		["GZ_Fbfb01_Cg1"] = 1,
		["GZ_Ghfb01_Cg1"] = 1,
		["GZ_Ghfb01_Cg2"] = 1,
		["GZ_Ghfb01_Cg3"] = 1,
		["GZ_Mrghfb01_Cg1"] = 1,
		["GZ_Mrghfb01_Cg2"] = 1,
		["GZ_Pffb01_Cg1"] = 1,
		["Gz_Sbbjfb01_Cg1"] = 1,
		["Gz_Sbbjfb01_Cg2"] = 1,
		["GZ_Zdfb01_Cg1"] = 1,
		["GZ_Zdfb01_Cg2"] = 1,
		["GZ_Zqjj01_Cg1"] = 1,
		["GZ_Zqjj01_Cg2"] = 1,
		["GZ_Zqjj01_Cg3"] = 1,
		["GZ_Fhc01_Cg5"] = 1,
	}

	-- 隐藏NPC的CG场景名字
	self.is_npc_hide_cg = {
		["GZ_Xsc01_Cg9"] = 1,
		["GZ_Fhc01_Cg5"] = 1,
	}
	-- 隐藏吊桥cg
	self.is_diaoqiao_hide_cg = {
		["GZ_Fhc01_Cg4"] = 1,
	}
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
end

function BaseCg:DestoryCg()
	if nil ~= self.cg_obj then
		GameObject.Destroy(self.cg_obj)
		self.cg_obj = nil
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
	
	-- 放CG前先下坐骑
	MountCtrl.Instance:SendGoonMountReq(0)

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

function BaseCg:Pause()
	if nil ~= self.cg_ctrl then
		self.cg_ctrl:Pause()
	end
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
	if self.is_sheild_all_npc_infb then
		local npc_list = Scene.Instance:GetNpcList()
		for _, v in pairs(npc_list) do
			v:GetDrawObj():SetVisible(false)
		end
	end
end

function BaseCg:OnPlayStart()
	local scene_type = Scene.Instance:GetSceneType()
	-- 婚宴场景不设置主角形象，播放默认的cg形象
	if scene_type ~= SceneType.HunYanFb then
		self:ModifyTrack()
	end

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

	if not IsNil(MainCamera) then
		MainCamera.gameObject:SetActive(false)
	end
	Scene.Instance:OnShieldRoleChanged(true, true)
	SettingData.Instance:SystemAutoSetting(10)
	Scene.Instance:ShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	--屏蔽所有跑任务机器人
  	RobertMgr.Instance:ShieldAllRobert()

  	if MainUIView and MainUIView.Instance and MainUIView.Instance:GetRootNode() then
 		self.old_mainui_layer = MainUIView.Instance:GetRootNode().layer
		MainUIView.Instance:GetRootNode():SetLayerRecursively(MASK_LAYER.INVISIBLE)
  	end

	self:HandleSpecialCgOnPlay()
end

function BaseCg:HandleSpecialCgOnPlay()
	local main_role = Scene.Instance:GetMainRole()
	self.old_main_role_visible = main_role:GetDrawObj():GetObjVisible()
	-- 隐藏主角
	if self.is_main_role_hide_cg[self.asset_name] then
		main_role:GetDrawObj():SetVisible(false)
	end

	-- 隐藏怪物
	if self.is_monster_hide_cg[self.asset_name] then
		self.is_sheild_all_monster_infb = true
	end

	-- 隐藏NPC
	if self.is_npc_hide_cg[self.asset_name] then
		self.is_sheild_all_npc_infb = true
	end

	if self.is_diaoqiao_hide_cg[self.asset_name] then
		self.is_sheild_diaoqiao = true
		Scene.Instance:SetDiaoqiaoIsShield(false)
	end

	main_role:SetBeautyVisible(false)
end

function BaseCg:OnPlayEnd()
	self:DestoryCg()
	self.cg_ctrl = nil

	-- 有主角参与的cg将下马参与
	if self.is_main_role_join then
		MountCtrl.Instance:CheckMountUpOrDownInCg()
	end
	Scene.Instance:OnShieldRoleChanged()
	local main_role = Scene.Instance:GetMainRole()
	main_role:StopMove()
	main_role:ChangeToCommonState()
	main_role:GetRoot().gameObject.transform.localPosition = self.old_position
	main_role:GetRoot().gameObject.transform.localRotation = self.old_rotation
	main_role:GetRoot().gameObject.transform.localScale = self.old_scale
	main_role:SetBeautyVisible(true)

	-- 摄象机直接同步到角色，不缓动
	if not IsNil(MainCamera) then
		MainCamera.gameObject:SetActive(true)
		if not IsNil(MainCameraFollow) then
			MainCameraFollow:SyncImmediate()
		end
	end

	self:ResumeVisible()
	
	if nil ~= self.end_callback then
		self.end_callback()
	end
end

function BaseCg:ResumeVisible()
	SettingData.Instance:ResetAllAutoShield(true)
	Scene.Instance:UnShieldNpc(COMMON_CONSTS.CG_NVSHEN_NPC_ID)

	-- 恢复mainui层
	if MainUIView and MainUIView.Instance and MainUIView.Instance:GetRootNode() then
		MainUIView.Instance:GetRootNode():SetLayerRecursively(self.old_mainui_layer)
	end

	-- 恢复显示主角
	local main_role = Scene.Instance:GetMainRole()
	if nil == main_role then
		return
	end

	main_role:GetDrawObj():SetVisible(self.old_main_role_visible)

	-- 恢复显示怪物
	if self.is_sheild_all_monster_infb then
		self.is_sheild_all_monster_infb = false
		local monster_list = Scene.Instance:GetMonsterList()
		for _, v in pairs(monster_list) do
			v:GetDrawObj():SetVisible(true)
		end
	end

	-- 恢复显示NPC
	if self.is_sheild_all_npc_infb then
		self.is_sheild_all_npc_infb = false
		local npc_list = Scene.Instance:GetNpcList()
		for _, v in pairs(npc_list) do
			v:GetDrawObj():SetVisible(true)
		end
	end
	
	if self.is_sheild_diaoqiao then
		self.is_sheild_diaoqiao = false
		Scene.Instance:SetDiaoqiaoIsShield(true)
	end

	--恢复所有跑任务机器人
	RobertMgr.Instance:UnShieldAllRobert()
end

function BaseCg:ModifyTrack()
	local main_role = Scene.Instance:GetMainRole()
	local vo = main_role:GetVo()

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