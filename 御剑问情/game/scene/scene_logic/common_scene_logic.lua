
CommonSceneLogic = CommonSceneLogic or BaseClass(BaseSceneLogic)

function CommonSceneLogic:__init()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self.story = nil
end

function CommonSceneLogic:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end

	if self.loaded_scene then
		GlobalEventSystem:UnBind(self.loaded_scene)
		self.loaded_scene = nil
	end

	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function CommonSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	if SceneType.PhaseFb == old_scene_type then
		TaskCtrl.Instance:SetAutoTalkState(true)
	end

	local scene_id = Scene.Instance:GetSceneId()

	self:CheckEnterBossScene(scene_id)
	self:CheckEnterDahuhaoScene(scene_id)
	self:CheckEnterGuaJiMScene(scene_id)
	ActivityCtrl.Instance:OpenShuShanFightView()

	self.story = XinShouStorys.New(scene_id)
	if self.story:GetStoryNum() > 0 then
		RobertManager.Instance:Start()
	end
	if AncientRelicsData.IsAncientRelics(scene_id) then
		self.has_open_info_view = true
		MainUICtrl.Instance:SetViewState(false)
		ViewManager.Instance:Open(ViewName.AncientRelics)
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_GATHER_INFO_REQ)
	end

	self:CheckShowEnterSceneTip()
	self:CheckSendGuaJiReq()
	if IS_ON_CROSSSERVER then
		MainUICtrl.Instance:GetView():Flush(MainUIViewChat.IconList.ChatButtons, {false})
	end
end

function CommonSceneLogic:CheckShowEnterSceneTip()
	if Scene.Instance:GetEnterSceneCount() < 2 then
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	TipsCtrl.Instance:ShowEneterCommonSceneView(scene_id)
end

function CommonSceneLogic:CheckEnterGuaJiMScene(scene_id)
	if YewaiGuajiData.Instance:IsGuaJiScene(scene_id) and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI) then
		FuBenCtrl.Instance:GetFuBenIconView():Open()
		FuBenCtrl.Instance:GetFuBenIconView():Flush()
	end
end

function CommonSceneLogic:CheckOutGuaJiMScene(scene_id)
	if YewaiGuajiData.Instance:IsGuaJiScene(scene_id) and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI) then
		FuBenCtrl.Instance:GetFuBenIconView():Close()
	end
end

function CommonSceneLogic:CheckEnterBossScene(scene_id)
	if BossData.IsWorldBossScene(scene_id)
		or BossData.IsDabaoBossScene(scene_id)
		or BossData.IsFamilyBossScene(scene_id)
		or BossData.IsMikuBossScene(scene_id)
		or BossData.IsActiveBossScene(scene_id)
		or BossData.IsSecretBossScene(scene_id) then
		ViewManager.Instance:Close(ViewName.KaifuActivityView)
		self.has_open_info_view = true
		if BossData.IsWorldBossScene(scene_id) then
			BossCtrl.Instance:OpenBossInfoView()
		elseif BossData.IsDabaoBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.DabaoBossInfoView)
		elseif BossData.IsFamilyBossScene(scene_id) or
			BossData.IsMikuBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.BossFamilyInfoView)
			ViewManager.Instance:FlushView(ViewName.BossFamilyInfoView, "boss_type", {boss_type = BossData.IsFamilyBossScene(scene_id) and 0 or 1})
		elseif BossData.IsActiveBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.ActiveBossInfoView)
		elseif BossData.IsSecretBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.SecretBossFightView)
		end
		MainUICtrl.Instance:SetViewState(false)
		ViewManager.Instance:Close(ViewName.Boss)

		self.is_in_boss_scene = true
	elseif BossData:IsXianJieBossScene(scene_id) then
		FuBenCtrl.Instance:GetFuBenIconView():Open()
		FuBenCtrl.Instance:GetFuBenIconView():Flush()
		ViewManager.Instance:Close(ViewName.Boss)
	end

	--一些强制切模式处理
	self:ForceChangeAttackMode(scene_id)
end

function CommonSceneLogic:ForceChangeAttackMode(scene_id)
	if BossData.IsMikuBossScene(scene_id) then						--精英boss强切仙盟
		--先记录之前旧的攻击模式
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role_vo.attack_mode))

		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	elseif BossData.IsActiveBossScene(scene_id) then --and BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE][1] ~= scene_id then				--活跃boss第二层开始强切仙盟
		--先记录之前旧的攻击模式
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role_vo.attack_mode))

		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	else
		UnityEngine.PlayerPrefs.SetInt("attck_mode", -1)
	end
end

function CommonSceneLogic:CheckEnterDahuhaoScene(scene_id)
	if not DaFuHaoData.Instance:IsShowDaFuHao() then
		return
	end

	self.dafuhao_view = true
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DaFuHao)
	MainUICtrl.Instance:FlushView("dafuhao")
end

function CommonSceneLogic:CanGetMoveObj()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		-- 世界Boss场景
		if BossData.IsWorldBossScene(scene_id) then
			-- or BossData.IsDabaoBossScene(scene_id)
			-- or BossData.IsFamilyBossScene(scene_id)
			-- or BossData.IsMikuBossScene(scene_id) then
			return true
		end
	end
	return false
end

function CommonSceneLogic:GetGuajiSelectObjDistance()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsDabaoBossScene(scene_id) or
			BossData.IsFamilyBossScene(scene_id) or
			BossData.IsMikuBossScene(scene_id) or
			BossData.IsActiveBossScene(scene_id) or
			BossData.IsSecretBossScene(scene_id) then

			return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
		end
	end

	return COMMON_CONSTS.SELECT_OBJ_DISTANCE
end

-- 拉取移动对象信息间隔
function CommonSceneLogic:GetMoveObjAllInfoFrequency()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		-- 世界Boss场景
		if BossData.IsWorldBossScene(scene_id)
			or BossData.IsDabaoBossScene(scene_id)
			or BossData.IsFamilyBossScene(scene_id)
			or BossData.IsMikuBossScene(scene_id)
			or BossData.IsActiveBossScene(scene_id)
			or BossData.IsSecretBossScene(scene_id) then
			return 5
		end
	end
	return 100000
end

--退出
function CommonSceneLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	if self.has_open_info_view then
		self.has_open_info_view = false
		local scene_id = Scene.Instance:GetSceneId()
		if BossData.IsWorldBossScene(scene_id) then
			BossCtrl.Instance:CloseBossInfoView()
			BossData.Instance:ClearCache()
		elseif BossData.IsDabaoBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.DabaoBossInfoView)
			BossData.Instance:ClearCache()
		elseif BossData.IsFamilyBossScene(scene_id) or
			BossData.IsMikuBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.BossFamilyInfoView)
			BossData.Instance:ClearCache()
		elseif BossData.IsActiveBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.ActiveBossInfoView)
			BossData.Instance:ClearCache()
		elseif AncientRelicsData.IsAncientRelics(scene_id) then
			ViewManager.Instance:Close(ViewName.AncientRelics)
		elseif BossData.IsSecretBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.SecretBossFightView)
		-- elseif RelicData.Instance:IsRelicScene(scene_id) then
		-- 	RelicCtrl.Instance:CloseInfoView()
		end
		MainUICtrl.Instance:SetViewState(true)
	end

	if ActivityData.Instance:IsInHuangChengAcitvity(scene_id) then
		ActivityCtrl.Instance:CloseShuShanFightView()
	end

	self:CheckOutGuaJiMScene(scene_id)

	--回普通场景时变回人物之前的攻击模式
	if PlayerData.Instance then
		local attr_mode = PlayerData.Instance:GetAttr("attack_mode")
		MainUICtrl.Instance:SetAttackMode(attr_mode)
	end

	if self.dafuhao_view or ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
		self.dafuhao_view = false
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance:FlushView("dafuhao")
		ViewManager.Instance:Close(ViewName.DaFuHao)
	end

	RobertManager.Instance:Stop()
	FuBenCtrl.Instance:GetFuBenIconView():Close()
	TipsCtrl.Instance:CloseEneterCommonSceneView()
	MainUICtrl.Instance:GetView():Flush(MainUIViewChat.IconList.ChatButtons, {true})
end

function CommonSceneLogic:MainuiOpen()
	if self.has_open_info_view then
		MainUICtrl.Instance:SetViewState(false)
	end
end

function CommonSceneLogic:CheckHaveGatherTimes()
	if Scene.Instance:GetSceneId() == AncientRelicsData.SCENE_ID then
		--远古遗迹
		if not AncientRelicsData.Instance:CanGather() then
			return false
		end
	end

	return true
end

-- 检查是否是挂机地图
function CommonSceneLogic:CheckIsGuajiScene()
	local scene_id = Scene.Instance:GetSceneId()
	return YewaiGuajiData.Instance:IsGuaJiScene(scene_id)
end

function CommonSceneLogic:CheckSendGuaJiReq()
	local is_guaji_scene = self:CheckIsGuajiScene()
	if is_guaji_scene then
		-- 请求Boss列表
		KuafuGuildBattleCtrl.Instance:CSReqMonsterGeneraterList(scene_id)
	end
end

-- 角色是否是敌人
function CommonSceneLogic:IsRoleEnemy(target_obj, main_role)
	local flag = BaseSceneLogic.IsRoleEnemy(self, target_obj, main_role)
	local is_guaji_scene = self:CheckIsGuajiScene()
	if is_guaji_scene then
		local main_role = Scene.Instance:GetMainRole()
		local logic_x, logic_y = main_role:GetLogicPos()

		local scene_id = Scene.Instance:GetSceneId()
		local safe_area_cfg = YewaiGuajiData.Instance:GetSafeAreaPosition(scene_id)
		if nil ~= safe_area_cfg then
			for i = 0, 99 do
				local center_x = safe_area_cfg["center_pos_" .. i .. "_x"]
				local center_y = safe_area_cfg["center_pos_" .. i .. "_y"]
				local len = safe_area_cfg["border_" .. i .. "_len"]
				if nil == center_x or "" == center_x then
					break
				end
				local sqrt_distance = GameMath.GetDistance(logic_x, logic_y, center_x, center_y, false)
				if sqrt_distance <= len * len then
					flag = false
					break
				end
			end
		end
	end
	return flag
end

function CommonSceneLogic:OnSceneDetailLoadComplete()
	BaseSceneLogic.OnSceneDetailLoadComplete(self)
	if Scene.Instance:GetSceneForbidPk() then
		--禁止pk的场景飘提示语
		SysMsgCtrl.Instance:ErrorRemind(Language.Fight.SceneForbidPk)
	end
end