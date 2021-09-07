
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

	if scene_id == nil then return end
	self:CheckEnterBossScene(scene_id)
	self:CheckEnterDahuhaoScene(scene_id)

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

	if scene_id == MapData.WORLDMAPCFG[8] or scene_id == MapData.WORLDMAPCFG[9] or scene_id == MapData.WORLDMAPCFG[10] then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALLIANCE)
	end
end

function CommonSceneLogic:CheckEnterBossScene(scene_id)
	if BossData.IsWorldBossScene(scene_id)
		or BossData.IsDabaoBossScene(scene_id)
		or BossData.IsFamilyBossScene(scene_id)
		or BossData.IsMikuBossScene(scene_id)
		or BossData.IsActiveBossScene(scene_id)
		or BossData.IsBabyBossScene(scene_id) then
		ViewManager.Instance:Close(ViewName.KaifuActivityView)
		self.has_open_info_view = true
		if BossData.IsWorldBossScene(scene_id) then
			BossCtrl.Instance:OpenBossInfoView()
		elseif BossData.IsDabaoBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.DabaoBossInfoView)
		elseif BossData.IsFamilyBossScene(scene_id) or
			BossData.IsMikuBossScene(scene_id)
			or BossData.IsBabyBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.BossFamilyInfoView)
			ViewManager.Instance:FlushView(ViewName.BossFamilyInfoView, "boss_type", {boss_type = BossData.IsFamilyBossScene(scene_id) and 0 or 1})
		elseif BossData.IsActiveBossScene(scene_id) then
			ViewManager.Instance:Open(ViewName.ActiveBossInfoView)
		end
		MainUICtrl.Instance:SetViewState(false)
		ViewManager.Instance:Close(ViewName.Boss)
		self:ChangeAttackMode(scene_id)
	else
		local attck_mode = UnityEngine.PlayerPrefs.GetInt("attck_mode", -1)
		if attck_mode ~= nil and attck_mode ~= -1 then
			MainUICtrl.Instance:SendSetAttackMode(attck_mode)
			UnityEngine.PlayerPrefs.DeleteKey("attck_mode")
		end
	end
end

function CommonSceneLogic:ChangeAttackMode(scene_id)
	local fix_attack_mode = GameEnum.ATTACK_MODE_GUILD
	local main_role = Scene.Instance:GetMainRole()
	if BossData.IsWorldBossScene(scene_id) then
		fix_attack_mode = GameEnum.ATTACK_MODE_PEACE
		if main_role.vo.attack_mode ~= fix_attack_mode then
			UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	elseif BossData.IsDabaoBossScene(scene_id) then
		if main_role.vo.attack_mode ~= fix_attack_mode then
			UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	elseif BossData.IsFamilyBossScene(scene_id) or BossData.IsBabyBossScene(scene_id) then

		if main_role.vo.attack_mode ~= fix_attack_mode then
			UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	elseif BossData.IsMikuBossScene(scene_id) then
		fix_attack_mode = GameEnum.ATTACK_MODE_PEACE
		if main_role.vo.attack_mode ~= fix_attack_mode then
			UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	elseif BossData.IsActiveBossScene(scene_id) then
		if scene_id == 9040 then
			fix_attack_mode = GameEnum.ATTACK_MODE_PEACE
		end
		if main_role.vo.attack_mode ~= fix_attack_mode then
			UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
			MainUICtrl.Instance:SendSetAttackMode(fix_attack_mode)
		end
	end
end

function CommonSceneLogic:CheckEnterDahuhaoScene(scene_id)
	if not DaFuHaoData.Instance:IsShowDaFuHao() then
		return
	end

	if DaFuHaoData.Instance:GetIsCanGather() then
		self.dafuhao_view = true
		MainUICtrl.Instance:SetViewState(false)
		ViewManager.Instance:Open(ViewName.DaFuHao)
		MainUICtrl.Instance:FlushView("dafuhao")
	end
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
			BossData.IsActiveBossScene(scene_id)
			or BossData.IsBabyBossScene(scene_id) then

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
			or BossData.IsBabyBossScene(scene_id) then
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
			BossData.IsMikuBossScene(scene_id)
			or BossData.IsBabyBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.BossFamilyInfoView)
			BossData.Instance:ClearCache()
		elseif BossData.IsActiveBossScene(scene_id) then
			ViewManager.Instance:Close(ViewName.ActiveBossInfoView)
			BossData.Instance:ClearCache()
		elseif AncientRelicsData.IsAncientRelics(scene_id) then
			ViewManager.Instance:Close(ViewName.AncientRelics)
		-- elseif RelicData.Instance:IsRelicScene(scene_id) then
		-- 	RelicCtrl.Instance:CloseInfoView()
		end
		MainUICtrl.Instance:SetViewState(true)
	end
	if self.dafuhao_view or ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
		self.dafuhao_view = false
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance:FlushView("dafuhao")
		ViewManager.Instance:Close(ViewName.DaFuHao)
	end

	RobertManager.Instance:Stop()
end

function CommonSceneLogic:MainuiOpen()
	if self.has_open_info_view then
		MainUICtrl.Instance:SetViewState(false)
	end
end