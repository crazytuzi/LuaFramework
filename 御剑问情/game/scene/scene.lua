require("game/scene/scene_config")
require("game/scene/scene_data")
require("game/scene/scene_protocal")
require("game/scene/camera")
require("game/scene/optimize/scene_optimizes")
require("game/scene/widget/guide_arrow")
require("game/scene/loading/scene_loading")
require("game/scene/loading/predownload")
require("game/scene/loading/freedownload")
require("game/scene/scene_logic/scene_logic")
require("game/scene/follow_ui/follow_ui")
require("game/scene/follow_ui/character_follow")
require("game/scene/follow_ui/role_follow")
require("game/scene/follow_ui/monster_follow")
require("game/scene/sceneobj/scene_obj")
require("game/scene/sceneobj/character")
require("game/scene/sceneobj/role")
require("game/scene/sceneobj/main_role")
require("game/scene/sceneobj/follow_obj")
require("game/scene/sceneobj/monster")
require("game/scene/sceneobj/tower")
require("game/scene/sceneobj/door")
require("game/scene/sceneobj/jump_point")
require("game/scene/sceneobj/effect_obj")
require("game/scene/sceneobj/fall_item")
require("game/scene/sceneobj/gather_obj")
require("game/scene/sceneobj/npc")
require("game/scene/sceneobj/truck_obj")
require("game/scene/sceneobj/map_move_obj")
require("game/scene/sceneobj/spirit_obj")
require("game/scene/sceneobj/pet_obj")
require("game/scene/sceneobj/goddess_obj")
require("game/scene/sceneobj/trigger_obj")
require("game/scene/sceneobj/event_obj")
require("game/scene/sceneobj/fight_mount_obj")
require("game/scene/sceneobj/ming_ren_role")
require("game/scene/sceneobj/boat_obj")
require("game/scene/sceneobj/couple_halo_obj")
require("game/scene/sceneobj/test_role")
require("game/scene/sceneobj/walk_npc")
require("game/scene/sceneobj/city_owner_statue")
require("game/scene/sceneobj/lingchong_obj")
require("game/scene/sceneobj/city_owner_role_obj")
require("game/scene/sceneobj/super_baby_obj")

local develop_mode = require("editor/develop_mode")

Scene = Scene or BaseClass(BaseController)

DownAngleOfCamera = 180
Scene.SCENE_OBJ_ID_T = {} 	-- 场景中曾经出现过的obj_id

function Scene:__init()
	if Scene.Instance then
		print_error("[Scene] Attempt to create singleton twice!")
		return
	end
	Scene.Instance = self

	self.data = SceneData.New()
	self.predownload = PreDownload.New()
	self.freedownload = FreeDownload.New()
	self.scene_optimize = SceneOptimize.New()

	self.start_loading_time = nil
	self.is_scene_visible = true
	self.scene_loading = SceneLoading.New()
	self.camera = Camera.New()
	self.guide_arrow = nil

	self.main_role = MainRole.New(GameVoManager.Instance:GetMainRoleVo())
	self.obj_list = {}
	self.obj_group_list = {}

	self.is_in_update = false
	self.delay_handle_funcs = {}
	-- 场景移动对象
	self.obj_move_info_list = {}

	self.main_role_pos_x = 0
	self.main_role_pos_y = 0
	self.last_check_fall_item_time = 0
	self.next_can_reduce_mem_time = 0
	self.enter_scene_count = 0

	self.act_scene_id = 0
	self.scene_logic = nil
	self.is_first_enter_scene = false

	self:RegisterAllProtocols()						-- 注册所有需要响应的协议
	self:RegisterAllEvents()						-- 注册所有需要监听的事件

	-- 场景特效
	self.effect_list = {}

	-- 温泉皮艇
	self.boat_list = {}
	self.boat_delay_list = {}

	self.couple_halo_obj_list = {}

	self.shield_npc_id_list = {}
	self.city_statue = nil						-- 攻城战城主雕像

	-- 监听游戏设置改变
	self:BindGlobalEvent(
		SettingEventType.SHIELD_OTHERS,
		BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SELF_SKILL_EFFECT,
		BindTool.Bind1(self.OnShieldSelfEffectChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_SAME_CAMP,
		BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SKILL_EFFECT,
		BindTool.Bind1(self.OnShieldSkillEffectChanged, self))
	self:BindGlobalEvent(
		SettingEventType.CLOSE_GODDESS,
		BindTool.Bind1(self.OnShieldGoddessChanged, self))
	self:BindGlobalEvent(
		SettingEventType.CLOSE_SHOCK_SCREEN,
		BindTool.Bind1(self.OnShieldCameraShakeChanged, self))
	self:BindGlobalEvent(SettingEventType.CLOSE_TITLE,
		BindTool.Bind(self.SettingChange, self, SETTING_TYPE.CLOSE_TITLE))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_ENEMY,
		BindTool.Bind1(self.OnShieldEnemy, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_SPIRIT,
		BindTool.Bind1(self.OnShieldSpirit, self))
	self:BindGlobalEvent(
		SettingEventType.MAIN_CAMERA_MODE_CHANGE,
		BindTool.Bind1(self.UpdateCameraMode, self))
	self:BindGlobalEvent(
		SettingEventType.MAIN_CAMERA_SETTING_CHANGE,
		BindTool.Bind1(self.UpdateCameraSetting, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_APPERANCE,
		BindTool.Bind1(self.OnShieldApperanceChanged, self))
	Runner.Instance:AddRunObj(self, 6)
	self.effect_cd = 0
end

function Scene:__delete()
	self.scene_optimize:DeleteMe()
	self.freedownload:DeleteMe()
	self.predownload:DeleteMe()
	self.data:DeleteMe()
	self.camera:DeleteMe()
	self.scene_loading:DeleteMe()
	if self.main_role then
		for k, v in pairs(self.obj_list) do
			if v:IsMainRole() then
				self.obj_list[k] = nil
				break
			end
		end
		self.main_role:DeleteMe()
		self.main_role = nil
	end

	if nil ~= self.clickHandle and nil ~= ClickManager.Instance then
		ClickManager.Instance:UnlistenClickGround(self.clickHandle)
		self.clickHandle = nil
	end

	self:DelateAllObj()
	self:ClearScene()
	Scene.Instance = nil
	Runner.Instance:RemoveRunObj(self)
	self:RemoveDelayTime()
end

function Scene:ReduceMemory()
	if Status.NowTime >= self.next_can_reduce_mem_time then
		self.next_can_reduce_mem_time = Status.NowTime + 5
		GameRoot.Instance:ReduceMemory()
	end
end

function Scene:SetSceneVisible(visible)
	self:RemoveDelayTime()
	local change_visible = function ()
		self.is_scene_visible = visible
		if not IsNil(MainCamera) then
			MainCamera.enabled = self.is_scene_visible
		end
	end
	-- 这里延迟3秒钟，是因为打开全屏面板时，背景如果没有加载出来，会出现花屏
	if not visible then
		self.delay_time = GlobalTimerQuest:AddDelayTimer(change_visible, 3)
	else
		change_visible()
	end
end

function Scene:ClearScene()
	self.scene_config = nil
	for _, v in pairs(self.obj_list) do
		if v ~= self.main_role then
			self:Fire(ObjectEventType.OBJ_DELETE, v)
			v:DeleteMe()
		end
	end
	self.obj_list = {}
	self.obj_group_list = {}
	self.boat_list = {}

	self.is_in_update = false
	self:DeleteAllMoveObj()
	self:DelGuideArrow()

	if nil ~= self.scene_logic then
		self.scene_logic:DeleteMe()
		self.scene_logic = nil
	end

	for k,v in pairs(self.boat_delay_list) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.boat_delay_list = {}
end

function Scene:DelateAllObj()
	for _, v in pairs(self.obj_list) do
		self:Fire(ObjectEventType.OBJ_DELETE, v)
		v:DeleteMe()
	end
	self.obj_list = {}
end

function Scene:DeleteAllMoveObj()
	-- develop模式会触发CheckDeleteMe的检查，会导致卡顿，所以这里跳过Delete操作
	if not develop_mode:IsDeveloper() then
		for k, v in pairs(self.obj_move_info_list) do
			v:DeleteMe()
		end
	end
	self.obj_move_info_list = {}
end

function Scene:RegisterAllEvents()
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
end

function Scene:Update(now_time, elapse_time)
	self.is_in_update = true

	if nil ~= self.scene_logic then
		self.scene_logic:Update(now_time, elapse_time)
	end

	for k, v in pairs(self.obj_list) do
		v:Update(now_time, elapse_time)
	end

	for k, v in pairs(self.obj_move_info_list) do
		v:Update(now_time, elapse_time)
	end
	self.is_in_update = false

	if now_time >= self.last_check_fall_item_time + 0.2 then
		self.last_check_fall_item_time = now_time
		self:PickAllFallItem()
	end

	-- 调用延时函数
	if next(self.delay_handle_funcs) then
		local delay_funcs = self.delay_handle_funcs
		self.delay_handle_funcs = {}
		for _, v in pairs(delay_funcs) do
			v()
		end
	end

	if self:IsSceneLoading() then
		return
	end

	local pos_x, pos_y
	pos_x = 0
	pos_y = 0
	if self.main_role then
		pos_x, pos_y = self.main_role:GetLogicPos()
	end

	if self.main_role_pos_x ~= pos_x or self.main_role_pos_y ~= pos_y then
		self.main_role_pos_x, self.main_role_pos_y = pos_x, pos_y
		self:CheckClientObj()
		self:CheckJump()
	end
end

function Scene:IsSceneLoading()
	return self.scene_loading:IsSceneLoading()
end

function Scene:IsEnterScene()
	return nil ~= self.is_enter_scene
end

function Scene:ResetIsEnterScene()
	self.is_enter_scene = nil
end

function Scene:OpenSceneLoading()
	self.scene_loading:Open()
end

function Scene:IsFirstEnterScene()
	return self.is_first_enter_scene
end

function Scene:OnChangeScene(scene_id)
	print_log("[Scene] OnChangeScene", scene_id)

	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_config then
		print_log("scene_config not find, scene_id:" .. scene_id)
		return
	end

	self.is_first_enter_scene = nil == self.scene_config
	self.old_scene_type = nil ~= self.scene_config and self.scene_config.scene_type or SceneType.Common
	if self.scene_logic ~= nil then
		self.scene_logic:Out(self.old_scene_type, scene_config.scene_type)
	end

	self:ClearScene()

	self.scene_config = scene_config
	GameMapHelper.SetOrigin(self.scene_config.origin_x, self.scene_config.origin_y)

	self.scene_logic = SceneLogic.Create(self.scene_config.scene_type, scene_id)

	AStarFindWay:Init(self.scene_config.mask, self.scene_config.width, self.scene_config.height)

	self:StartLoadScene(scene_id)

	if nil == self.is_enter_scene then
		self.is_enter_scene = true
		PlayerCtrl.Instance:SendReqAllInfo()
	else
		self:CreateMainRole()
		-- 清空Boss专属者标记
		self.main_role:SetAttr("top_dps_flag", 0)
	end
end

-- 打开加载条加载场景
function Scene:StartLoadScene(scene_id)
	if not self:IsSceneLoading() and self.act_scene_id == scene_id then
		self:OnLoadSceneMainComplete(scene_id)
		self:OnLoadSceneDetailComplete(scene_id)
		return
	end

	self.scene_loading:SetStartLoadingCallback(BindTool.Bind(self.OnLoadStart, self))
	self.scene_loading:Start(scene_id, BindTool.Bind(self.OnMainLoadEnd, self), BindTool.Bind(self.OnLoadEnd, self))
end

-- 加载开始
function Scene:OnLoadStart(scene_id)
	print("[Scene] OnLoadStart ", scene_id)
	self.start_loading_time = Status.NowTime
	ReportManager:Step(Report.STEP_CHANGE_SCENE_BEGIN, nil, nil, nil, nil, scene_id)

	ViewManager.Instance:Close(ViewName.Login)
	if LoginCtrl.Instance then
		LoginCtrl.Instance:ClearScenes()
	end

	-- AudioManager.PlayAndForget(AssetID("audios/sfxs/npcvoice/shared", "mute_voice")) 	-- 播放npc对话静音
	AudioManager.PlayAndForget(AssetID("audios/sfxs/uis", "MuteUIVoice")) 			-- 播放ui静音
	self.predownload:Stop()
	self.freedownload:Stop()
end

function Scene:OnMainLoadEnd(scene_id)
	self.act_scene_id = scene_id
	self:OnLoadSceneMainComplete(scene_id)
end

-- 加载结束
function Scene:OnLoadEnd(scene_id)
	local loading_time = Status.NowTime - self.start_loading_time
	ReportManager:Step(Report.STEP_CHANGE_SCENE_COMPLETE, nil, nil, nil, nil, scene_id, loading_time)
	print("[Scene] OnLoadEnd ", scene_id, loading_time)

	self:OnLoadSceneDetailComplete(scene_id)
	self.predownload:Start()
	self.freedownload:Start()
end

function Scene:OnLoadSceneMainComplete(scene_id)
	if MainCamera ~= nil then
		MainCamera.enabled = self.is_scene_visible
		self:UpdateCameraMode()
		DownAngleOfCamera = 180 + MainCamera.transform.eulerAngles.y
	else
		print_error("The main camera is missing.")
		GlobalTimerQuest:AddDelayTimer(function ()
			MainCamera = UnityEngine.Camera.main
			self:OnLoadSceneMainComplete(scene_id)
		end, 0.2)
		return
	end

	local new_scene_type = self.scene_config.scene_type
	self.scene_logic:Enter(self.old_scene_type, new_scene_type)

	for k, v in pairs(self.obj_list) do
		v:OnLoadSceneComplete()
	end

	-- 创建场景特效
	for k,v in pairs(self.effect_list) do
		if not IsNil(v) then
			GameObject.Destroy(v)
			v = nil
		end
	end
	self.effect_list = {}
	if nil ~= self.scene_config.effects then
		for k, v in pairs(self.scene_config.effects) do
			PrefabPool.Instance:Load(AssetID(v.bundle, v.asset), function(prefab)
				local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
				local go = GameObject.Instantiate(prefab)
				if nil ~= go then
					local moveable_obj = go:GetOrAddComponent(typeof(MoveableObject))
					if moveable_obj then
						moveable_obj:SetPosition(Vector3(wx, 0, wy))
						moveable_obj:SetOffset(Vector3(v.offset[1], v.offset[2], v.offset[3]))
					end
					go.transform.localEulerAngles = Vector3(v.rotation[1], v.rotation[2], v.rotation[3])
					if v.scale then
						go.transform.localScale = Vector3(v.scale[1], v.scale[2], v.scale[3])
					end
					table.insert(self.effect_list, go)
				end
				PrefabPool.Instance:Free(prefab)
			end)
		end
	end

	-- 创建npc和传送门
	self:CreateNpcList()
	self:CreateDoorList()
	self:CreateCityOnwerStatue()
	self:CheckWorshipAct()

	self.is_in_door = true

	self:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT, self.old_scene_type, new_scene_type)

	if nil ~= ClickManager.Instance then
		if nil ~= self.clickHandle and nil ~= ClickManager.Instance then
			ClickManager.Instance:UnlistenClickGround(self.clickHandle)
			self.clickHandle = nil
		end

		self.clickHandle = ClickManager.Instance:ListenClickGround(function(hit)
			-- 当前场景无法移动
			local logic = Scene.Instance:GetSceneLogic()
			if logic and not logic:CanCancleAutoGuaji() then
				self:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
				TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
				return
			end

			self:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)

			if self:GetSceneType() == SceneType.KfMining then
				KuaFuMiningCtrl.Instance:StopAutoMining()
			end

			if (GuajiCache.guaji_type ~= GuajiType.None or MoveCache.is_valid or AtkCache.is_valid)
				and (self.last_click_ground_time == nil or Status.NowTime - self.last_click_ground_time > 5) then
				self.last_click_ground_time = Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.ClickGoundAgainStopAuto)
				return
			end
			self.last_click_ground_time = Status.NowTime
			-- 点击到地面，移动
			self:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)

			TASK_GUILD_AUTO = false
			TASK_RI_AUTO = false
			TASK_HUAN_AUTO = false
			TASK_WEEK_HUAN_AUTO = false
			local x, y = GameMapHelper.WorldToLogic(hit.point.x, hit.point.z)

			self.main_role:DoMoveByClick(x, y, 0)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			--(无特效)
			local is_block = AStarFindWay:IsBlock(x, y)
			if is_block then
				EffectManager.Instance:PlayControlEffect("effects2/prefab/misc/movement_unwalkable_prefab", "Movement_Unwalkable", Vector3(hit.point.x, hit.point.y + 0.25, hit.point.z))
			else
				EffectManager.Instance:PlayControlEffect("effects2/prefab/misc/movement_walkable_prefab", "Movement_Walkable", Vector3(hit.point.x, hit.point.y + 0.25, hit.point.z))
			end
		end)
	else
		print_log("This scene does not has ClickManager.")
	end
end

function Scene:OnLoadSceneDetailComplete(scene_id)
	self:Fire(SceneEventType.SCENE_ALL_LOAD_COMPLETE)
end

function Scene:SetTeamSecialDoorState()
	if Scene.Instance:GetSceneType() == SceneType.TeamSpecialFb then
		local team_speical_fb_info = FuBenData.Instance:GetTeamSpecialResultInfo()
		if team_speical_fb_info and team_speical_fb_info.is_passed ~= 0 and team_speical_fb_info.is_over ~= 1 then
			local vo = GameVoManager.Instance:CreateVo(DoorVo)
			self:CreateDoor(vo)
			FuBenData.Instance:SetTeamSpecialResult()
		else
			Scene.Instance:DeleteObjsByType(SceneObjType.Door)
		end
	end
end

----------------------------------------------------
-- Get begin
----------------------------------------------------
function Scene:GetMainRole()
	return self.main_role
end

function Scene:GetSceneId()
	return self.scene_config and self.scene_config.id or 0
end

function Scene:GetSceneForbidPk()
	if nil == self.scene_config then
		return false
	end
	return self.scene_config.is_forbid_pk and self.scene_config.is_forbid_pk == 1
end

-- 获取该场景是否可以切换攻击模式
function Scene:IsCanChangeAttackMode()
	local switch = true
	local cfg = self:GetCurFbSceneCfg()
	if cfg then
		switch = cfg.cant_change_mode == 0
	end
	return switch
end

function Scene:GetSceneTownPos()
	if nil == self.scene_config then
		return 0, 0
	end
	return self.scene_config.scenex or 0, self.scene_config.sceney or 0
end

function Scene:GetSceneName()
	return self.scene_config and self.scene_config.name or ""
end

function Scene:GetSceneLogic()
	return self.scene_logic
end

function Scene:GetSceneType()
	return self.scene_config and self.scene_config.scene_type or 0
end

function Scene:GetSceneMosterList()
	return self.scene_config and self.scene_config.monsters or nil
end

function Scene:GetObj(obj_id)
	return self.obj_list[obj_id]
end

function Scene:GetObjByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		return self.obj_group_list[obj_type][obj_key]
	end
	return nil
end

function Scene:GetNpcByNpcId(npc_id)
	return self:GetObjByTypeAndKey(SceneObjType.Npc, npc_id) or self:GetFakeNpcByNpcId(npc_id)
end

function Scene:GetFakeNpcByNpcId(npc_id)
	return self:GetObjByTypeAndKey(SceneObjType.FakeNpc, npc_id)
end

function Scene:GetGatherByGatherId(gather_id)
	for k, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id then
			return v
		end
	end

	return nil
end

function Scene:GetGatherByGatherIdAndPosInfo(gather_id, x, y)
	for k, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		local pos_x, pos_y = v:GetLogicPos()
		if v:GetGatherId() == gather_id and pos_x == x and pos_y == y then
			return v
		end
	end
	return nil
end

function Scene:GetObjList()
	return self.obj_list
end

local empty_table = {}
function Scene:GetObjListByType(obj_type)
	return self.obj_group_list[obj_type] or empty_table
end

function Scene:GetRoleList()
	return self.obj_group_list[SceneObjType.Role] or empty_table
end

function Scene:GetMingRenList()
	return self.obj_group_list[SceneObjType.MingRen] or empty_table
end

function Scene:GetMonsterList()
	return self.obj_group_list[SceneObjType.Monster] or empty_table
end

function Scene:GetNpcList()
	return self.obj_group_list[SceneObjType.Npc] or empty_table
end

function Scene:GetFakeNpcList()
	return self.obj_group_list[SceneObjType.FakeNpc] or empty_table
end

function Scene:GetSpiritList()
	return self.obj_group_list[SceneObjType.SpriteObj] or empty_table
end

function Scene:GetGatherList()
	return self.obj_group_list[SceneObjType.GatherObj] or empty_table
end

-- 获取场景进入点坐标
function Scene:GetEntrance(scene_id, to_scene_id)
	local list = ConfigManager.Instance:GetAutoConfig("entrance_auto").entrance_list
	local x, y = nil, nil
	for k,v in pairs(list) do
		if v.scene_id == scene_id and v.to_scene_id == to_scene_id then
			local door_id = v.door_id
			local config = ConfigManager.Instance:GetSceneConfig(to_scene_id)
			if config ~= nil and config.doors ~= nil then
				for i,j in pairs(config.doors) do
					if j.id == door_id then
						x, y = j.x, j.y
						break
					end
				end
			end
			break
		end
	end
	return x, y
end

function Scene:GetRoleByObjId(obj_id)
	local obj = self.obj_list[obj_id]
	if nil ~= obj and obj:IsRole() then
		return obj
	end
	return nil
end

function Scene:GetObjectByObjId(obj_id)
	return self.obj_list[obj_id]
end

function Scene:GetObjByUId(uid)
	for k,v in pairs(self.obj_list) do
		if v.vo.role_id == uid then
			return v
		end
	end
end

function Scene:GetObjMoveInfoList()
	return self.obj_move_info_list
end

function Scene:DelMoveObj(obj_id)
	self.obj_move_info_list[obj_id] = nil
end

function Scene:GetSceneAssetName()
	if nil == self.scene_config then
		return ""
	end
	return self.scene_config.asset_name
end

----------------------------------------------------
-- Get end
----------------------------------------------------

----------------------------------------------------
-- Create begin
----------------------------------------------------
function Scene:CreateMainRole()
	if self.main_role then
		for k, v in pairs(self.obj_list) do
			if v:IsMainRole() then
				self.obj_list[k] = nil
				break
			end
		end

		self.main_role:DeleteMe()
		self.main_role = nil
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == vo then
		print_log("Scene:CreateMainRole vo nil")
		return nil
	end

	self.main_role = self:CreateObj(vo, SceneObjType.MainRole)
	self.main_role:SetFollowLocalPosition(0)

	local settingData = SettingData.Instance
	local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)

	-- 屏蔽自己技能特效
	local shield_self_effect = settingData:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	main_part:EnableEffect(not shield_self_effect)
	main_part:EnableFootsteps(not shield_self_effect)

	-- 屏蔽女神

	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	self.main_role:SetGoddessVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config and self.scene_config.id == 1110 then
		local follow_ui = self.main_role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end

	-- 关闭震屏效果
	local close_camera_shake = settingData:GetSettingData(SETTING_TYPE.CLOSE_SHOCK_SCREEN)
	main_part:EnableCameraShake(not close_camera_shake)

	RobertManager.Instance:OnMainRoleCreate()

	return self.main_role
end

function Scene:CreateRole(vo)
	local role = self:CreateObj(vo, SceneObjType.Role)

	if role and role:IsRole() then
		role:SetFollowLocalPosition(0)
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(vo)
			self:Fire(ObjectEventType.TEAM_HP_CHANGE, vo)
		end
	end

	local settingData = SettingData.Instance
	local main_part = role.draw_obj:GetPart(SceneObjPart.Main)

	-- 屏蔽其他玩家
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	role:SetRoleVisible(not shield_others)
	role.draw_obj:SetVisible(role:IsRoleVisible())

	-- 屏蔽友方玩家
	if not shield_others then
		local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
		if not self:IsEnemy(role) then
			role:SetRoleVisible(not shield_same_camp)
			role.draw_obj:SetVisible(role:IsRoleVisible())
		end
	end

	-- 屏蔽女神
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	role:SetGoddessVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config and self.scene_config.id == 1110 then
		local follow_ui = role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end

	-- 屏蔽他人技能特效
	local shield_skill_effect = settingData:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	main_part:EnableEffect(not shield_skill_effect)
	main_part:EnableFootsteps(not shield_skill_effect)

	return role
end

function Scene:CreateTestRole(vo)
	local role = self:CreateObj(vo, SceneObjType.TestRole)

	if role and role:IsRole() then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(vo)
			self:Fire(ObjectEventType.TEAM_HP_CHANGE, vo)
		end
	end

	local settingData = SettingData.Instance
	local main_part = role.draw_obj:GetPart(SceneObjPart.Main)

	-- 屏蔽其他玩家
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	role.draw_obj:SetVisible(not shield_others)
	role:SetRoleVisible(not shield_others)

	-- 屏蔽友方玩家
	if not shield_others then
		local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
		if not self:IsEnemy(role) then
			role.draw_obj:SetVisible(not shield_same_camp)
			role:SetRoleVisible(not shield_same_camp)
		end
	end

	-- 屏蔽女神
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	role:SetGoddessVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config and self.scene_config.id == 1110 then
		local follow_ui = role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end

	-- 屏蔽他人技能特效
	local shield_skill_effect = settingData:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	main_part:EnableEffect(not shield_skill_effect)
	main_part:EnableFootsteps(not shield_skill_effect)

	return role
end

function Scene:CreateMonster(vo)
	return self:CreateObj(vo, SceneObjType.Monster)
end

function Scene:CreateDoor(vo)
	self:CreateObj(vo, SceneObjType.Door)
end

function Scene:CreateJumpPoint(vo)
	self:CreateObj(vo, SceneObjType.JumpPoint)
end

function Scene:CreateEffectObj(vo)
	return self:CreateObj(vo, SceneObjType.EffectObj)
end

function Scene:CreateFallItem(vo)
	local fall_item = self:CreateObj(vo, SceneObjType.FallItem)
	if ItemData.Instance:GetEmptyNum() and fall_item:GetAutoPickupMaxDis() > 0
		and (vo.owner_role_id <= 0 or vo.owner_role_id == self.main_role:GetRoleId()) then
		GuajiCtrl.Instance:HasNewFallItem()
	end
end

function Scene:CreateZhuaGuiNpc(vo)
	self:CreateObj(vo, SceneObjType.EventObj)
end

function Scene:CreateGatherObj(vo)
	local gather = self:CreateObj(vo, SceneObjType.GatherObj)
	if not CgManager.Instance:IsCgIng() and self.main_role
		and self.main_role.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER
		and self.main_role.vo.task_appearn_param_1 == TaskData.PIG_ID then --小猪猪写死id
		gather:GetDrawObj():SetVisible(false)
		return
	end
	if vo.gather_id == MarriageData.Instance:GetHunYanCfg().gather_id then 			--婚宴“酒席”模型更换
		GlobalTimerQuest:AddDelayTimer(function()
			MarriageData.Instance:IsChangeGatherModle(vo.obj_id)
		end, 0.02)
	end
	if vo.special_gather_type == SPECIAL_GATHER_TYPE.JINGHUA and JingHuaHuSongData.Instance then	--如果是天地精华采集物
		JingHuaHuSongData.Instance:SetJingHuaGatherAmount(vo.gather_id, vo.param)		--记录精华采集物数目
	end
end

function Scene:CreateNpc(vo)
	-- 被抱走了
	local npc = self:CreateObj(vo, SceneObjType.Npc)
	if not CgManager.Instance:IsCgIng() and self.main_role
		and self.main_role.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC
		and self.main_role.vo.task_appearn_param_1 == vo.npc_id then
		npc:GetDrawObj():SetVisible(false)
		if npc.select_effect then
			npc.select_effect:SetActive(false)
		end
		npc:ReloadUIName()
		return
	end
end

function Scene:CreateFakeNpc(vo)
	self:CreateObj(vo, SceneObjType.FakeNpc)
end

function Scene:CreateTruckObj(vo)
	return self:CreateObj(vo, SceneObjType.TruckObj)
end

function Scene:CreateSpiritObj(vo)
	return self:CreateObj(vo, SceneObjType.SpriteObj)
end

function Scene:CreatePetObj(vo)
	return self:CreateObj(vo, SceneObjType.PetObj)
end

function Scene:CreateGoddessObj(vo)
	return self:CreateObj(vo, SceneObjType.GoddessObj)
end

function Scene:CreateLingChongObj(vo)
	return self:CreateObj(vo, SceneObjType.LingChongObj)
end

function Scene:CreateSuperBabyObj(vo)
	return self:CreateObj(vo, SceneObjType.SuperBabyObj)
end

function Scene:CreateFightMountObj(vo)
	return self:CreateObj(vo, SceneObjType.FightMount)
end

function Scene:CreateTriggerObj(vo)
	return self:CreateObj(vo, SceneObjType.Trigger)
end

function Scene:CreateMingRenObj(vo)
	if math.abs(vo.pos_x - self.main_role_pos_x) <= 60 and math.abs(vo.pos_y - self.main_role_pos_y) <= 60 then
		if nil == self:GetObjByTypeAndKey(SceneObjType.MingRen, vo.role_id) then
			return self:CreateObj(vo, SceneObjType.MingRen)
		end
	else
		self:DeleteObjByTypeAndKey(SceneObjType.MingRen, vo.role_id)
	end
end

function Scene:FlushMingRenList()
	local list = self:GetMingRenList()
	if list and #list ~= 0 then
		for k,v in pairs(list) do
			if v then
				v:FlushAppearance()
			end
		end
	else
		-- self:CreatMingRenList()
	end
end

-- 根据角色创建Truck
function Scene:CreateTruckObjByRole(role)
	local truck_obj = nil
	local role_vo = role:GetVo()
	if role_vo.husong_color > 0 and role_vo.husong_taskid > 0 then
		local truck_vo = GameVoManager.Instance:CreateVo(TruckObjVo)
		truck_vo.pos_x, truck_vo.pos_y = role:GetLogicPos()
		truck_vo.pos_x = truck_vo.pos_x + 2
		truck_vo.truck_color = role_vo.husong_color
		truck_vo.owner_role_id = role_vo.role_id
		truck_vo.owner_obj_id = role_vo.obj_id
		truck_vo.hp = 100
		truck_vo.move_speed = role:GetVo().move_speed
		truck_obj = self:CreateTruckObj(truck_vo)
		-- if nil ~= truck_obj then
		-- 	role:SetTruckObjId(truck_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return truck_obj
end

-- 根据角色创建Pet
function Scene:CreatePetObjByRole(role)
	local pet_obj = nil
	local role_vo = role:GetVo()
	if role_vo.pet_id and role_vo.pet_id > 0 then
		local pet_vo = GameVoManager.Instance:CreateVo(PetObjVo)
		pet_vo.pos_x, pet_vo.pos_y = role:GetLogicPos()
		pet_vo.pos_x = pet_vo.pos_x + 4
		pet_vo.name = role_vo.name..Language.Common.LittlePet
		pet_vo.owner_role_id = role_vo.role_id
		pet_vo.owner_obj_id = role_vo.obj_id
		pet_vo.pet_id = role_vo.pet_id
		pet_vo.hp = 100
		pet_vo.move_speed = role:GetVo().move_speed
		pet_vo.pet_name = role_vo.pet_name
		pet_vo.owner_is_mainrole = role:IsMainRole()
		pet_obj = self:CreatePetObj(pet_vo)
	end
	return pet_obj
end

-- 根据角色创建Spirit
function Scene:CreateSpiritObjByRole(role)
	local spirit_obj = nil
	local role_vo = role:GetVo()
	local spirit_info_list = SpiritData.Instance:GetSpiritInfo()
	if role_vo.used_sprite_id and role_vo.used_sprite_id > 0 or (spirit_info_list and spirit_info_list.phantom_imageid and spirit_info_list.phantom_imageid >= 0) then
		local spirit_vo = GameVoManager.Instance:CreateVo(SpriteObjVo)
		spirit_vo.pos_x, spirit_vo.pos_y = role:GetLogicPos()
		spirit_vo.pos_x = spirit_vo.pos_x + 5
		spirit_vo.name = role_vo.name .. Language.Common.FairySpoil

		spirit_vo.owner_role_id = role_vo.role_id
		spirit_vo.owner_obj_id = role_vo.obj_id
		spirit_vo.used_sprite_id = role_vo.used_sprite_id
		spirit_vo.move_speed = role:GetVo().move_speed
		spirit_vo.spirit_name = role_vo.sprite_name
		spirit_vo.use_jingling_titleid = role_vo.use_jingling_titleid or 0

		spirit_vo.lingzhu_use_imageid = role_vo.lingzhu_use_imageid or 0
		spirit_vo.hp = 100
		spirit_vo.owner_is_mainrole = role:IsMainRole()
		spirit_obj = self:CreateSpiritObj(spirit_vo)
	end
	return spirit_obj
end

function Scene:CreateGoddessObjByRole(role)
	local goddess_obj = nil
	local role_vo = role:GetVo()
	local goddess_vo = GameVoManager.Instance:CreateVo(GoddessObjVo)
	goddess_vo.pos_x, goddess_vo.pos_y = role:GetLogicPos()
	goddess_vo.pos_x = goddess_vo.pos_x + 2
	goddess_vo.owner_role_id = role_vo.role_id
	goddess_vo.owner_obj_id = role_vo.obj_id
	goddess_vo.hp = 100
	goddess_vo.move_speed = role_vo.move_speed
	goddess_vo.use_xiannv_id = role_vo.use_xiannv_id
	goddess_vo.goddess_wing_id = role_vo.appearance and role_vo.appearance.shenyi_used_imageid or 0
	goddess_vo.goddess_shen_gong_id = role_vo.appearance and role_vo.appearance.shengong_used_imageid or 0
	goddess_vo.xiannv_huanhua_id = role_vo.xiannv_huanhua_id
	goddess_vo.owner_is_mainrole = role:IsMainRole()
	local xiannv_name = role_vo.xiannv_name
	if role:IsMainRole() then
		xiannv_name = GoddessData.Instance:GetXiannvName(role_vo.use_xiannv_id)
	end
	if xiannv_name == nil or xiannv_name == "" then
		local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(role_vo.use_xiannv_id)
		if xiannv_cfg then
			xiannv_name = xiannv_cfg.name
		end
	end
	goddess_vo.name = xiannv_name
	goddess_obj = self:CreateGoddessObj(goddess_vo)
	return goddess_obj
end

--创建灵宠
function Scene:CreateLingChongObjByRole(role)
	local role_vo = role:GetVo()
	local vo = GameVoManager.Instance:CreateVo(LingChongObjVo)
	vo.pos_x, vo.pos_y = role:GetLogicPos()
	vo.hp = 100
	vo.owner_role_id = role_vo.role_id
	vo.owner_obj_id = role_vo.obj_id
	vo.owner_is_mainrole = role:IsMainRole()
	vo.move_speed = role_vo.move_speed
	vo.lingchong_used_imageid = role_vo.lingchong_used_imageid or 0
	vo.linggong_used_imageid = role_vo.linggong_used_imageid or 0
	vo.lingqi_used_imageid = role_vo.lingqi_used_imageid or 0
	local name = ""
	local image_cfg_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(role_vo.lingchong_used_imageid)
	if image_cfg_info then
		name = image_cfg_info.image_name
	end
	vo.name = name
	local lingchong_obj = self:CreateLingChongObj(vo)
	return lingchong_obj
end

--创建超级宝宝
function Scene:CreateSuperBabyObjByRole(role)
	local role_vo = role:GetVo()
	local vo = GameVoManager.Instance:CreateVo(SuperBabyObjVo)
	vo.pos_x, vo.pos_y = role:GetLogicPos()
	vo.hp = 100
	vo.owner_role_id = role_vo.role_id
	vo.owner_obj_id = role_vo.obj_id
	vo.owner_name = role_vo.name or role_vo.role_name or ""
	vo.owner_is_mainrole = role:IsMainRole()
	vo.lover_name = role_vo.lover_name or ""
	vo.move_speed = role_vo.move_speed
	vo.sup_baby_id = role_vo.sup_baby_id or -1
	vo.sup_baby_name = role_vo.sup_baby_name or ""

	local name = vo.sup_baby_name
	if name == "" then
		local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(vo.sup_baby_id)
		if cfg_info then
			name = cfg_info.name
		end
	end

	name = string.format(Language.Marriage.SceneSuperBabyName, vo.owner_name, name)
	if vo.lover_name ~= "" then
		name = vo.lover_name .. "♥" .. name
	end
	vo.name = name

	local super_baby_obj = self:CreateSuperBabyObj(vo)
	return super_baby_obj
end

function Scene:CreateFightMountObjByRole(role)
	local fight_mount_obj = nil
	local role_vo = role:GetVo()
	if role_vo.fight_mount_appeid and role_vo.fight_mount_appeid > 0 then
		local fight_mount_vo = GameVoManager.Instance:CreateVo(MultiMountObjVo)
		fight_mount_vo.pos_x, fight_mount_vo.pos_y = role:GetLogicPos()
		fight_mount_vo.mount_id = role_vo.fight_mount_appeid
		fight_mount_vo.mount_res_id = role_vo.fight_mount_appeid
		fight_mount_vo.fight_mount_appeid = role_vo.fight_mount_appeid
		fight_mount_vo.name = role_vo.name.."战斗坐骑"
		fight_mount_vo.hp = 100
		fight_mount_vo.owner_role_id = role_vo.role_id
		fight_mount_vo.owner_obj_id = role_vo.obj_id
		fight_mount_vo.move_speed = role:GetVo().move_speed
		fight_mount_obj = self:CreateFightMountObj(fight_mount_vo)
		-- if nil ~= fight_mount_obj then
		-- 	role:SetTruckObjId(fight_mount_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return fight_mount_obj
end

-- 创建NPC列表
function Scene:CreateNpcList()
	if CgManager.Instance:IsCgIng() then
		return
	end

	if nil ~= self.scene_config.npcs then
		for k, v in pairs(self.scene_config.npcs) do
			if (math.abs(v.x - self.main_role_pos_x) <= 45 and math.abs(v.y - self.main_role_pos_y) <= 45)
				or v.is_walking == 1 then
				if nil == self:GetObjByTypeAndKey(SceneObjType.Npc, v.id) then
					local vo = GameVoManager.Instance:CreateVo(NpcVo)
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.npc_id = v.id
					vo.rotation_y = v.rotation_y
					vo.is_walking = v.is_walking or 0
					vo.paths = v.paths or {}
					self:CreateNpc(vo)

					-- 屏弊npc只是不显示，仍然创建，避免影响新手任务
					if nil ~= self.shield_npc_id_list[v.id] then
						self:ShieldNpc(v.id)
					end
				end
			else
				self:DeleteObjByTypeAndKey(SceneObjType.Npc, v.id)
			end
		end
	end
end

-- 创建传送门列表
function Scene:CreateDoorList()
	if nil == self.scene_config.doors then
		return
	end

	local delay_create_door = {}
	local delay_delete_door = {}
	for k, v in pairs(self.scene_config.doors) do
		if v.type ~= SceneDoorType.INVISIBLE then
			if math.abs(v.x - self.main_role_pos_x) <= 45 and math.abs(v.y - self.main_role_pos_y) <= 45 then
				if nil == self:GetObjByTypeAndKey(SceneObjType.Door, v.id) then
					local vo = GameVoManager.Instance:CreateVo(DoorVo)
					vo.name = "door" .. v.id
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.door_id = v.id
					vo.offset = v.offset
					vo.rotation = v.rotation
					table.insert(delay_create_door, vo)

					if v.target_scene_id == 1002 then
						vo.target_name = CityCombatData.Instance:GetDorrName()
					end
				end
			else
				table.insert(delay_delete_door, v.id)
			end
		end
	end

	-- 品质副本和装备副本(须臾幻境)中打完boss再显示传送阵
	if not self:IsNeedDelayCreateDoor() then
		for k, vo in pairs(delay_create_door) do
			self:CreateDoor(vo)
		end
	end

	for k, id in pairs(delay_delete_door) do
		self:DeleteObjByTypeAndKey(SceneObjType.Door, id)
	end
end

-- 创建跳跃点列表
function Scene:CreateJumpPointList()
	if nil ~= self.scene_config.jumppoints then
		local jumppoints = {}
		for k, v in pairs(self.scene_config.jumppoints) do
			-- 跳跃点生成范围要尽可能大，否则跳到一半会中断
			if math.abs(v.x - self.main_role_pos_x) <= 200 and math.abs(v.y - self.main_role_pos_y) <= 200 then
				if nil == self:GetObjByTypeAndKey(SceneObjType.JumpPoint, v.id) then
					local vo = GameVoManager.Instance:CreateVo(JumpPointVo)
					vo.name = "jumppoint" .. v.id
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.range = v.range
					vo.id = v.id
					vo.target_id = v.target_id
					vo.jump_type = v.jump_type
					vo.air_craft_id = v.air_craft_id
					vo.is_show = v.is_show
					vo.jump_speed = v.jump_speed
					-- vo.jump_act = v.jump_act
					-- 策划要求只用跳跃1动作
					vo.jump_act = 1
					vo.jump_tong_bu = v.jump_tong_bu
					vo.jump_time = v.jump_time
					vo.camera_fov = v.camera_fov
					vo.camera_rotation = v.camera_rotation
					vo.offset = v.offset
					vo.play_cg = v.play_cg or 0
					vo.cgs = v.cgs or {}
					jumppoints[v.id] = vo
					self:CreateJumpPoint(vo)
				end
			else
				self:DeleteObjByTypeAndKey(SceneObjType.JumpPoint, v.id)
			end
		end

		-- 链接所有跳跃点
		for k,v in pairs(jumppoints) do
			v.target_vo = jumppoints[v.target_id]
		end
	end
end


-- 创建城主雕像列表
function Scene:CreateCityOnwerStatue()
	local pos_x, pos_y = CityCombatData.Instance:GetWorshipStatuePosParam()
	local worship_scene_id = CityCombatData.Instance:GetWorshipScenIdAndPosXYAndRang()
	local cur_scene_id = self:GetSceneId()
	if pos_x < 0 or pos_y < 0 or worship_scene_id < 0 then
		return
	end

	local cond_1 = math.abs(pos_x - self.main_role_pos_x) <= 50
	local cond_2 = math.abs(pos_y - self.main_role_pos_y) <= 50
	if cond_1 and cond_2 and worship_scene_id == cur_scene_id then
		if nil == self.city_statue then
			local vo = GameVoManager.Instance:CreateVo(CityOwnerStatueVo)
			vo.pos_x = pos_x
			vo.pos_y = pos_y
			self.city_statue = self:CreateObj(vo, SceneObjType.CityOwnerStatue)
		end
	else
		if nil ~= self.city_statue then
			self:DeleteObjsByType(SceneObjType.CityOwnerStatue)
			self.city_statue = nil
		end
	end
end

function Scene:CheckWorshipAct()
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	if not act_is_open then
		return
	end

	local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.GONGCHENG_WORSHIP)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then
		return
	end

	local worship_scene_id, worship_pos_x, worship_pos_y, range = CityCombatData.Instance:GetWorshipScenIdAndPosXYAndRang()
	local cur_scene_id = self:GetSceneId()
	if -1 ~= worship_scene_id and -1 ~= worship_pos_x and -1 ~= worship_pos_y and -1 ~= range then
		local cond_1 = math.abs(worship_pos_x - self.main_role_pos_x) > range
		local cond_2 = math.abs(worship_pos_y - self.main_role_pos_y) > range
		if cond_1 or cond_2 or worship_scene_id ~= cur_scene_id then
			ViewManager.Instance:Close(ViewName.WorshipView)
		elseif not ViewManager.Instance:IsOpen(ViewName.WorshipView) then
			ViewManager.Instance:Open(ViewName.WorshipView)
		end
	end
end

function Scene:GetCityStatue()
	return self.city_statue
end

-- 创建温泉皮艇
function Scene:CreateBoatByCouple(boy_obj_id, girl_obj_id, boy_obj, action_type, delete_time)
	self:DeleteBoatByRole(boy_obj_id)
	self:DeleteBoatByRole(girl_obj_id)
	local vo = GameVoManager.Instance:CreateVo(BoatObjVo)
	vo.boy_obj_id = boy_obj_id
	vo.girl_obj_id = girl_obj_id
	if nil ~= boy_obj then
		vo.pos_x, vo.pos_y = boy_obj:GetLogicPos()
	end
	vo.action_type = action_type
	local boat_obj = self:CreateObj(vo, SceneObjType.BoatObj)
	self.boat_list[boy_obj_id] = boat_obj:GetObjId()
	self.boat_list[girl_obj_id] = boat_obj:GetObjId()

	local quest1 = self.boat_delay_list[boy_obj_id]
	if nil ~= quest1 then
		GlobalTimerQuest:CancelQuest(quest1)
		self.boat_delay_list[boy_obj_id] = nil
	end
	local quest2 = self.boat_delay_list[girl_obj_id]
	if nil ~= quest2 then
		GlobalTimerQuest:CancelQuest(quest2)
		self.boat_delay_list[girl_obj_id] = nil
	end

	if delete_time then
		local delay_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:DeleteBoatByRole(boy_obj_id)
		end, delete_time)
		self.boat_delay_list[boy_obj_id] = delay_timer_quest
		self.boat_delay_list[girl_obj_id] = delay_timer_quest
	end
end

-- 删除温泉皮艇
function Scene:DeleteBoatByRole(role_obj_id)
	local boat_obj_id = self.boat_list[role_obj_id]
	if nil ~= boat_obj_id then
		local boat_obj = self:GetObjectByObjId(boat_obj_id)
		if nil ~= boat_obj then
			local boy_obj_id = boat_obj.vo.boy_obj_id
			local girl_obj_id = boat_obj.vo.girl_obj_id
			if nil ~= boy_obj_id then
				self.boat_list[boy_obj_id] = nil
			end
			if nil ~= girl_obj_id then
				self.boat_list[girl_obj_id] = nil
			end
		end
		self:DeleteObj(boat_obj_id, 0)
	end
end

function Scene:GetBoatByRole(role_obj_id)
	local boat_obj_id = self.boat_list[role_obj_id]
	if nil ~= boat_obj_id then
		return self:GetObjectByObjId(boat_obj_id)
	end
end

function Scene:CreateCoupleHaloObj(target_1_role_id, target_2_role_id, halo_type)
	local target_1_halo_obj = self.couple_halo_obj_list[target_1_role_id]
	local target_2_halo_obj = self.couple_halo_obj_list[target_2_role_id]
	if target_1_halo_obj ~= nil or target_2_halo_obj ~= nil then
		return
	end
	local vo = GameVoManager.Instance:CreateVo(CoupleHaloObjVo)
	vo.target_1_role_id = target_1_role_id
	vo.target_2_role_id = target_2_role_id
	vo.halo_type = halo_type
	local couple_halo_obj = self:CreateObj(vo, SceneObjType.CoupleHaloObj)
	self.couple_halo_obj_list[target_1_role_id] = couple_halo_obj
	self.couple_halo_obj_list[target_2_role_id] = couple_halo_obj
end

function Scene:DeleteCoupleHaloObj(role_obj_id)
	local couple_halo_obj = self.couple_halo_obj_list[role_obj_id]
	if couple_halo_obj then
		local vo = couple_halo_obj:GetVo()
		local target_1_role_id = vo.target_1_role_id
		local target_2_role_id = vo.target_2_role_id

		local couple_halo_obj_id = couple_halo_obj:GetObjId()
		self:DeleteObj(couple_halo_obj_id, 0)

		self.couple_halo_obj_list[target_1_role_id] = nil
		self.couple_halo_obj_list[target_2_role_id] = nil
	end
end

--创建图片阴影
function Scene:TryToCreateSpriteShadow(parent_obj)
	if nil == parent_obj or nil == parent_obj.draw_obj then
		return
	end

	if not SceneObjShadowList[parent_obj.draw_obj:GetObjType()] then
		return
	end

	local bundle, asset = ResPath.GetMiscPreloadRes("SpriteShadow")
	parent_obj:ChangeModel(SceneObjPart.Shadow, bundle, asset)
end

local client_obj_id_inc = 0x10000
function Scene:CreateObj(vo, obj_type)
	if vo.obj_id < 0 then
		client_obj_id_inc = client_obj_id_inc + 1
		vo.obj_id = client_obj_id_inc
	end

	if self.obj_list[vo.obj_id] then
		return nil
	end

	if self.obj_move_info_list[vo.obj_id] then
		self.obj_move_info_list[vo.obj_id]:OnScene(true)
	end

	local obj = nil
	if obj_type == SceneObjType.Role then
		obj = Role.New(vo)
	elseif obj_type == SceneObjType.MainRole then
		obj = MainRole.New(vo)
	elseif obj_type == SceneObjType.Monster then
		local monster_id = vo.monster_id
		if ClashTerritoryData.Instance:IsTowerId(monster_id) then
			obj = Tower.New(vo)
		else
			obj = Monster.New(vo)
		end
		local scene_id = Scene.Instance:GetSceneId()
		local can_shield = true
		for k,v in pairs(GameEnum.NOT_SHIELD_ENEMY_SCENE_ID) do
			if v == scene_id then
				can_shield = false
			end
		end
		if can_shield then
			local settingData = SettingData.Instance
			local is_shield = settingData:GetSettingData(SETTING_TYPE.SHIELD_ENEMY)
			if self.scene_logic:CanShieldMonster() and (nil == obj.IsBoss or not obj:IsBoss()) and obj:IsCanShield() then
				obj.draw_obj:SetVisible(not is_shield)
				obj.draw_obj:SetObjType(SceneObjType.Monster)
				local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
				follow_ui:SetHpBarLocalPosition(0, -5, 0)
			end
		end
	elseif obj_type == SceneObjType.Door then
		obj = Door.New(vo)
	elseif obj_type == SceneObjType.JumpPoint then
		obj = JumpPoint.New(vo)
	elseif obj_type == SceneObjType.EffectObj then
		obj = EffectObj.New(vo)
	elseif obj_type == SceneObjType.FallItem then
		obj = FallItem.New(vo)
	elseif obj_type == SceneObjType.GatherObj then
		obj = GatherObj.New(vo)
	elseif obj_type == SceneObjType.TruckObj then
		obj = TruckObj.New(vo)
	elseif obj_type == SceneObjType.Npc then
		if vo.is_walking and vo.is_walking == 1 then
			obj = WalkNpc.New(vo)
		else
			obj = Npc.New(vo)
		end
	elseif obj_type == SceneObjType.FakeNpc then
		obj = Npc.New(vo)
	elseif obj_type == SceneObjType.SpriteObj then
		obj = SpiritObj.New(vo)
	elseif obj_type == SceneObjType.PetObj then
		obj = PetObj.New(vo)
	elseif obj_type == SceneObjType.GoddessObj then
		obj = Goddess.New(vo)
	elseif obj_type == SceneObjType.EventObj then
		obj = EventObj.New(vo)
	elseif obj_type == SceneObjType.FightMount then
		obj = FightMountObj.New(vo)
	elseif obj_type == SceneObjType.Trigger then
		obj = TriggerObj.New(vo)
	elseif obj_type == SceneObjType.MingRen then
		obj = MingRenRole.New(vo)
	elseif obj_type == SceneObjType.BoatObj then
		obj = BoatObj.New(vo)
	elseif obj_type == SceneObjType.CoupleHaloObj then
		obj = CoupleHaloObj.New(vo)
	elseif obj_type == SceneObjType.CityOwnerStatue then
		obj = CityOwnerStatue.New(vo)
	elseif obj_type == SceneObjType.CityOwnerObj then
		obj = CityOwnerObj.New(vo)
	elseif obj_type == SceneObjType.TestRole then
		obj = TestRole.New(vo)
		obj:SetFollowLocalPosition(0)
	elseif obj_type == SceneObjType.LingChongObj then
		obj = LingChongObj.New(vo)
	elseif obj_type == SceneObjType.SuperBabyObj then
		obj = SuperBabyObj.New(vo)
	end

	obj.draw_obj:SetObjType(obj_type)
	obj:Init(self)
	self.obj_list[vo.obj_id] = obj

	if obj:GetObjKey() then
		if nil == self.obj_group_list[obj_type] then
			self.obj_group_list[obj_type] = {}
		end
		self.obj_group_list[obj_type][obj:GetObjKey()] = obj
	end

	if obj:IsJumpPoint() then
		obj:UpdateJumppointRotate()
	end

	self:TryToCreateSpriteShadow(obj)

	self:Fire(ObjectEventType.OBJ_CREATE, obj)
	Scene.SCENE_OBJ_ID_T[vo.obj_id] = true
	return obj
end
----------------------------------------------------
-- Create end
----------------------------------------------------

----------------------------------------------------
-- Delete begin
----------------------------------------------------
function Scene:DeleteObjByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		local obj = self.obj_group_list[obj_type][obj_key]
		if nil ~= obj then
			self:DeleteObj(obj:GetObjId(), 0)
		end
	end
end

function Scene:DeleteObjsByType(obj_type)
	if nil ~= self.obj_group_list[obj_type] then
		local t = self.obj_group_list[obj_type]
		if nil ~= t then
			for _, v in pairs(t) do
				self:DeleteObj(v:GetObjId(), 0)
			end
		end
	end
end

function Scene:DeleteObj(obj_id, delay_time)
	delay_time = delay_time or 0
	if self.is_in_update then
		if self.obj_list[obj_id] then
			-- update过程延迟删除
			table.insert(self.delay_handle_funcs, BindTool.Bind(self.DelObjHelper, self, obj_id, delay_time))
		end
	else
		self:DelObjHelper(obj_id, delay_time)
	end
end

function Scene:DelObjHelper(obj_id, delay_time)
	local del_obj = self.obj_list[obj_id]
	if del_obj == nil or del_obj == self.main_role then
		return
	end

	self.obj_list[obj_id] = nil

	if del_obj:GetObjKey() ~= nil and self.obj_group_list[del_obj:GetType()] ~= nil then
		self.obj_group_list[del_obj:GetType()][del_obj:GetObjKey()] = nil
	end

	self:Fire(ObjectEventType.OBJ_DELETE, del_obj)

	if delay_time > 0 then
		GlobalTimerQuest:AddDelayTimer(function()
			del_obj:DeleteMe()
		end, delay_time)
	else
		del_obj:DeleteMe()
	end

	-- if self.obj_move_info_list[obj_id] ~= nil and del_obj:GetObjKey() ~= nil then
	-- 	print_log("self.obj_move_info_list DelObjHelper :", obj_id)
	-- 	self.obj_move_info_list[obj_id] = nil
	-- end
end

----------------------------------------------------
-- Delete end
----------------------------------------------------

-- 是否友方
function Scene:IsFriend(target_obj)
	return self.scene_logic:IsFriend(target_obj, self.main_role)
end

-- 是否敌方
function Scene:IsEnemy(target_obj, ignore_table)
	return self.scene_logic:IsEnemy(target_obj, self.main_role, ignore_table)
end

-- 选取最近的对象
function Scene:SelectObjHelper(obj_type, x, y, distance_limit, select_type, ignore_table)
	local obj_list = self:GetObjListByType(obj_type)
	local target_obj = nil
	local target_distance = distance_limit
	local target_x, target_y, distance = 0, 0, 0
	local can_select = true
	local target_obj_reserved = nil
	local target_distance_reserved = distance_limit

	for _, v in pairs(obj_list) do
		if v:IsCharacter() and not v:IsModelTransparent() then
			can_select = true
			if SelectType.Friend == select_type and not v:IsMainRole() then
				can_select = self.scene_logic:IsFriend(v, self.main_role)
			elseif SelectType.Enemy == select_type then
				can_select = self.scene_logic:IsEnemy(v, self.main_role, ignore_table)
			end

			if can_select then
				target_x, target_y = v:GetLogicPos()
				distance = GameMath.GetDistance(x, y, target_x, target_y, false)
				-- 优先寻找非障碍区的
				if not AStarFindWay:IsBlock(target_x, target_y) then
					if distance < target_distance then
						target_obj = v
						target_distance = distance
					end
				else
					if distance < target_distance_reserved then
						target_obj_reserved = v
						target_distance_reserved = distance
					end
				end
			end
		end
	end

	if nil == target_obj then
		return target_obj_reserved, target_distance_reserved
	end

	return target_obj, target_distance
end

--选择指定id的最近的怪物
function Scene:SelectMinDisMonster(monster_id, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetMonsterList()) do
		if v:GetMonsterId() == monster_id and not v:IsRealDead() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					target_obj = target_obj or v
				else
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj
end

function Scene:GetGatherObj(target_distance, target_x, target_y, distance)
	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					return target_obj or v, target_distance, target_x, target_y
				else
					return v, distance, target_x, target_y
				end
			end
		end
	end
end

--选择指定id的最近的采集物
function Scene:SelectMinDisGather(gather_id, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					target_obj = target_obj or v
				else
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj
end

--获取指定id的最近的采集物的距离
function Scene:GetMinDisGather(gather_id, distance_limit)
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if not v:IsInBlock() then
					target_distance = distance
				end
			end
		end
	end
	return target_distance
end

-- --选择指定id的最近的采集物(返回x,y) 若没找到视野内的目标,返回视野外的目标点
-- function Scene:SelectMinDisGather(gather_id, distance_limit)
-- 	local target_obj = nil
-- 	local target_distance = distance_limit or 50
-- 	target_distance = target_distance * target_distance
-- 	local target_x, target_y, distance = 0, 0, 0
-- 	local main_role_x, main_role_y = self.main_role:GetLogicPos()
-- 	target_obj, distance, target_x, target_y = self:GetGatherObj(target_distance, target_x, target_y, distance, gather_id)
-- 	if target_obj == nil then
-- 		for k,v in pairs(self.obj_move_info_list) do
-- 			if gather_id == v.obj_id then
-- 				return  v.pos_x, v.pos_y
-- 			end
-- 		end
-- 	end

-- 	return target_x, target_y
-- end

-- 拾取所有物品
local others_item_tips_time = 0
local bag_full_tips_time = 0
function Scene:PickAllFallItem()
	if self.main_role and self.main_role:IsRealDead() then
		return
	end

	local fall_item_list = self:GetObjListByType(SceneObjType.FallItem)
	if not next(fall_item_list) then
		return
	end
	local auto_pick_item = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY)
	local empty_num = ItemData.Instance:GetEmptyNum()

	local item_objid_list = {}
	local auto_pick_color = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_COLOR) or 0

	local pick_item_num = 0
	local has_others_item = false
	for k, v in pairs(fall_item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.vo.item_id)
		if not v:IsPicked() then
			local dis = v:GetAutoPickupMaxDis()
			if dis > 0 then
				-- 红包、绑定元宝之类的
					dis = dis * dis
					local x, y = self.main_role:GetLogicPos()
					if GameMath.GetDistance(x, y, v:GetVo().pos_x, v:GetVo().pos_y, false) < dis then
						if v:GetVo().owner_role_id <= 0 or v:GetVo().owner_role_id == self.main_role:GetRoleId() then
							pick_item_num = pick_item_num + 1
							v:RecordIsPicked()
							table.insert(item_objid_list, v:GetObjId())
						else
							if v.others_tips_time == nil or v.others_tips_time < Status.NowTime then
								v.others_tips_time = Status.NowTime + 10
								has_others_item = true
							end
						end
					end
			elseif (v:GetVo().owner_role_id <= 0 or v:GetVo().owner_role_id == self.main_role:GetRoleId()) and
				Status.NowTime >= v:GetVo().create_time + 1 and
				((auto_pick_item and item_cfg and item_cfg.color > auto_pick_color) or v:GetVo().is_buff_falling == 1) then
				-- 自己的物品
				v:RecordIsPicked()
				table.insert(item_objid_list, v:GetObjId())
				if not v:IsCoin() then
					pick_item_num = pick_item_num + 1
				end
			end
			if v:GetVo().is_buff_falling == 1 then
				self.is_buff_falling = true
			end
			if empty_num <= pick_item_num and v:GetVo().is_buff_falling ~= 1 then
				break
			end
		end
	end

	if 0 == empty_num and #item_objid_list > 0 and not self.is_buff_falling then
		if bag_full_tips_time < Status.NowTime and (auto_pick_item or GoldMemberData.Instance:GetVIPSurplusTime() <= 0) then
			bag_full_tips_time = Status.NowTime + 2
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
		return
	end

	if has_others_item and others_item_tips_time < Status.NowTime and #item_objid_list == 0 then
		others_item_tips_time = Status.NowTime + 1
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotMyItem)
	end

	if next(item_objid_list) then
		Scene.ScenePickItem(item_objid_list)
	end
end

-- 寻找跳跃点
function Scene:FindJumpPoint(x, y)
	local temp_table = {}
	for k,v in pairs(self:GetObjListByType(SceneObjType.JumpPoint)) do
		if v.vo.target_id ~= 0 and v.vo.range > 0 then
			local position = v:GetLuaPosition()
			local point_distance = GameMath.GetDistance(x, y, position.x, position.z, false)
			if point_distance <= v.vo.range then
				table.insert(temp_table, v)
			end
		end
	end
	return temp_table
end

-- 跳跃到目的地
function Scene:JumpTo(vo, to_point)
	local target_point = self:GetObjByTypeAndKey(SceneObjType.JumpPoint, to_point.vo.target_id)
	self.main_role:JumpTo(vo, to_point, target_point, function()
		if to_point.vo.target_id and to_point.vo.target_id > -1 then
			if target_point then
				-- 延迟到下一帧执行
				CountDown.Instance:AddCountDown(0.01, 0.01, function()
					self:JumpTo(to_point.vo, target_point)
				end)
				return
			end
		end

		-- 只需要在最后一个跳跃点完成时同步位置
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		Scene.SendSyncJump(self:GetSceneId(), to_point.vo.pos_x, to_point.vo.pos_y, scene_key)
		-- if self:GetSceneType() == SceneType.Common and not GuajiCtrl.Instance:IsSpecialCommonScene() then
		-- 	TaskCtrl.SendFlyByShoe(self:GetSceneId(), to_point.vo.pos_x, to_point.vo.pos_y, scene_key, true)
		-- end
		Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
		self.main_role:SetJump(false)
		self.main_role.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		self:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
		if self.main_role.mount_res_id and self.main_role.mount_res_id > 0 then
			self.main_role:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.main_role.mount_res_id))
		elseif self.main_role.fight_mount_res_id and self.main_role.fight_mount_res_id > 0 then
			self.main_role:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.main_role.fight_mount_res_id))
		end
	end)
end

function Scene:CheckJump()
	if self.main_role:IsJump() or self.main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return false
	end

	-- 名将变身时不能跳跃
	local cur_general = GeneralSkillData.Instance:GetCurUseSeq()
	if cur_general ~= -1 then
		return false
	end

	local position = self.main_role:GetLuaPosition()

	local jumppoint_obj_list = self:FindJumpPoint(position.x, position.z)
	if #jumppoint_obj_list < 1 then
		return false
	end

	if jumppoint_obj_list[1].vo.id == self.main_role.jumping_id then
		return false
	end

	local target_point = self:GetObjByTypeAndKey(SceneObjType.JumpPoint, jumppoint_obj_list[1].vo.target_id)
	if not target_point then
		return false
	end

	-- if self.main_role.vo.husong_taskid > 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.CanNotJump)
	-- 	return false
	-- end

	self:JumpTo(jumppoint_obj_list[1].vo, target_point)

	return true
end

function Scene:CheckClientObj()
	if nil == self.scene_config then
		return
	end

	self:CreateNpcList()
	self:CreateDoorList()
	self:CreateJumpPointList()
	self:CreateCityOnwerStatue()
	self:CheckWorshipAct()

	-- 是否传送
	local door_obj = nil
	for k, v in pairs(self:GetObjListByType(SceneObjType.Door)) do
		local door_x, door_y = v:GetLogicPos()
		if GameMath.GetDistance(self.main_role_pos_x, self.main_role_pos_y, door_x, door_y, false) < 4 * 4 then
			door_obj = v
			break
		end
	end

	if nil ~= door_obj and false == self.is_in_door then
		self.is_in_door = true
		self.main_role:ChangeToCommonState()

		-- 离开副本
		if door_obj:GetDoorType() == SceneDoorType.FUBEN then
			FuBenCtrl.Instance:SendLeaveFB()
		else
			self.SendTransportReq(door_obj:GetDoorId())
		end
	else
		self.is_in_door = (nil ~= door_obj)
	end
end

function Scene:GetCurFbSceneCfg()
	local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
	return fb_config.fb_scene_cfg_list[self:GetSceneType()] or
			fb_config.fb_scene_cfg_list[SceneType.Common]
end

--@scene_id 传送点所在场景，@to_scene_id 传送要去的场景
function Scene:GetSceneDoorPos(scene_id, to_scene_id)
	local scene = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene ~= nil then
		for i,j in pairs(scene.doors) do
			if j.target_scene_id == to_scene_id then
				return j.x, j.y
			end
		end
	end
	return nil, nil
end

-- 根据npc_id获取该npc所在的场景信息 @{scene, x, y, id}
function Scene:GetSceneNpcInfo(npc_cfg_id)
	local scene_npc_cfg = nil
	local scene_id = 0
	for k,v in pairs(Config_scenelist) do
		if v.sceneType == SceneType.Common then
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.id)
			if scene_cfg ~= nil and scene_cfg.npcs ~= nil then
				for i, j in pairs(scene_cfg.npcs) do
					if j.id == npc_cfg_id then
						scene_npc_cfg = j
						scene_id = v.id
						break
					end
				end
			end
			if scene_npc_cfg ~= nil then
				break
			end
		end
	end
	if scene_npc_cfg ~= nil then
		local info = {}
		info.scene = scene_id
		info.x = scene_npc_cfg.x
		info.y = scene_npc_cfg.y
		info.id = npc_cfg_id
		return info
	end
end

function Scene:OnShieldSelfEffectChanged(value)
	local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableEffect(not value)
	main_part:EnableFootsteps(not value)
end

function Scene:OnShieldGoddessChanged(value)
	local settingData = SettingData.Instance
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetGoddessVisible(not shield_goddess)
		end
	end
end

function Scene:OnShieldRoleChanged(value)
	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

	if shield_others or shield_friend then
		for _, v in pairs(self.obj_list) do
			if v:IsRole() and not v:IsMainRole() and not v:IsMainRoleParnter() then
				local is_shield = shield_others or (shield_friend and not self:IsEnemy(v))
				if is_shield == v:IsRoleVisible() then
					v.draw_obj:SetVisible(not is_shield)
					v:SetRoleVisible(not is_shield)
					if is_shield then
						v:SetFollowLocalPosition(100)
					else
						v:SetFollowLocalPosition(0)
					end
				end
			end
		end
		return
	else
		for _, v in pairs(self.obj_list) do
			if v:IsRole() and not v:IsMainRole() and not v:IsRoleVisible() then
				v.draw_obj:SetVisible(true)
				v:SetRoleVisible(true)
				v:SetFollowLocalPosition(0)
			end
		end
	end
end

function Scene:OnShieldApperanceChanged()
	for _, v in pairs(self.obj_list) do
		if v:IsRole() then
			v:ApperanceShieldChanged()
		end
	end
end

function Scene:OnShieldSkillEffectChanged(value)
	if IsLowMemSystem then
		value = true
	end
	for _, v in pairs(self.obj_list) do
		if v:IsRole() and not v:IsMainRole() then
			local main_part = v.draw_obj:GetPart(SceneObjPart.Main)
			main_part:EnableEffect(not value)
			main_part:EnableFootsteps(not value)
		end
	end
end

function Scene:OnShieldCameraShakeChanged(value)
	local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableCameraShake(not value)
end

function Scene:SettingChange(setting_type, switch)
	switch = not switch
	if setting_type == SETTING_TYPE.CLOSE_TITLE then
		local obj_list = self:GetObjListByType(SceneObjType.Role)
		if obj_list then
			for k,v in pairs(obj_list) do
				v:SetTitleVisible(switch)
			end
		end
	end
	self:GetMainRole():SetTitleVisible(switch)
end

--屏蔽怪物
function Scene:OnShieldEnemy(value)
	local scene_id = self:GetSceneId()
	for k,v in pairs(GameEnum.NOT_SHIELD_ENEMY_SCENE_ID) do
		if v == scene_id then
			return
		end
	end
	if not self.scene_logic:CanShieldMonster() then
		print_warning("当前场景不能屏蔽怪物  scene_id: ", scene_id)
		return
	end
	for k,v in pairs(self:GetMonsterList()) do
		if (nil == v.IsBoss or not v:IsBoss()) and v:IsCanShield() then
			v.draw_obj:SetVisible(not value)
			if v.draw_obj:GetObjType() == SceneObjType.Monster then
				v.draw_obj:GetSceneObj():_FlushFollowTarget()
			end
			local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
			follow_ui:SetHpBarLocalPosition(0, -5, 0)
			-- if value then
			-- 	follow_ui:SetHpBarLocalPosition(0, 80, 0)
			-- else
			-- 	follow_ui:SetHpBarLocalPosition(0, -5, 0)
			-- end
		end
	end
end

--屏蔽精灵
function Scene:OnShieldSpirit(value)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetSpriteVisible(not value)
		end
	end
end

-- 激活引导箭头指向某点
function Scene:ActGuideArrowTo(x, y)
	if nil == self.guide_arrow then
		self.guide_arrow = GuideArrow.New()
	end
	self.guide_arrow:SetMoveArrowTo(x, y)
end

function Scene:DelGuideArrow()
	if nil ~= self.guide_arrow then
		self.guide_arrow:DeleteMe()
		self.guide_arrow = nil
	end
end

function Scene:ShieldNpc(npc_id)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(false)
	end
	self.shield_npc_id_list[npc_id] = true
end

function Scene:UnShieldNpc(npc_id)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(true)
	end

	self.shield_npc_id_list[npc_id] = nil
end

function Scene:ShieldAllNpc()
	local npc_list = self:GetNpcList()
	for k, v in pairs(npc_list) do
		v:GetDrawObj():SetVisible(false)
		if v.select_effect then
			v.select_effect:SetActive(false)
		end
		self.shield_npc_id_list[k] = true
	end
end

function Scene:UnShieldAllNpc()
	for k, _ in pairs(self.shield_npc_id_list) do
		local npc_obj = Scene.Instance:GetNpcByNpcId(k)
		if nil ~= npc_obj then
			npc_obj:GetDrawObj():SetVisible(true)
		end
		self.shield_npc_id_list[k] = nil
	end
end

function Scene:SetEnterSceneCount()
	self.enter_scene_count = self.enter_scene_count + 1
end

function Scene:GetEnterSceneCount()
	return self.enter_scene_count
end

local last_camera_mode = nil
function Scene:UpdateCameraMode(param_1, param_2)
	local flag = 0
	if param_2 then
		flag = param_2
	else
		local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
		flag = guide_flag_list.item_id
		if self.main_role and self.main_role.vo.task_appearn > 0 and last_camera_mode then
			flag = last_camera_mode
		end
	end
	self:SetCameraMode(flag)
end

function Scene:SetCameraMode(index)
	index = index or 0
	-- 策划要求镜头1和镜头2参数交换
	last_camera_mode = index

	-- 切换到自由视角
	if index == 1 and CAMERA_TYPE == CameraType.Fixed then
		if not IsNil(MainCamera) then
			local camera_follow2 = CameraFollow2.Bind(MainCamera.transform.parent.gameObject)
			if camera_follow2 then
				camera_follow2.enabled = true
			end
			local camera_follow1 = MainCamera:GetComponentInParent(typeof(CameraFollow))
			if camera_follow1 then
				camera_follow1.enabled = false
			end
			MainCameraFollow = camera_follow2
			CAMERA_TYPE = CameraType.Free
			self:UpdateCameraSetting()
			Scheduler.Delay(function()
				self.main_role:UpdateCameraFollowTarget(false)
			end)
		end
	-- 切换到锁定视角
	elseif index ~= 1 and CAMERA_TYPE == CameraType.Free then
		local camera_follow2 = CameraFollow2.Bind(MainCamera.transform.parent.gameObject)
		if camera_follow2 then
			camera_follow2.enabled = false
		end
		local camera_follow1 = MainCamera:GetComponentInParent(typeof(CameraFollow))
		if camera_follow1 then
			camera_follow1.enabled = true
		end
		MainCameraFollow = camera_follow1
		CAMERA_TYPE = CameraType.Fixed
		Scheduler.Delay(function()
			self.main_role:UpdateCameraFollowTarget(false)
		end)
	end

	if CAMERA_TYPE == CameraType.Fixed and not IsNil(MainCameraFollow) then
		-- 抱花任务特殊处理
		if index == 3 then
			index = 2
		end
		MainCameraFollow:SetCameraTransform(index)
	end
end

-- 是否显示天气效果
function Scene:ShowWeather()
	local flag = false
	if self.scene_config then
		if self.scene_config.show_weather and self.scene_config.show_weather == 1 then
			flag = true
		end
	end
	return flag
end

-- 婚宴场景假的npc
function Scene:CreateFakeNpcList()
	local user_info, question_list = MarriageData.Instance:GetHunyanQuestionUserInfo()
	if user_info and question_list then
		for k, v in pairs(question_list) do
			local pos = MarriageData.Instance:GetQuestionNpcPos(v.npc_pos_seq)
			local npc_id = MarriageData.Instance:GetQuestionNpc(k)
			if nil == self:GetObjByTypeAndKey(SceneObjType.FakeNpc, npc_id) then
				local vo = GameVoManager.Instance:CreateVo(NpcVo)
				vo.pos_x = pos.pos_x
				vo.pos_y = pos.pos_y
				vo.npc_id = npc_id
				vo.obj_id = npc_id
				vo.question_id = v.question_id
				vo.answer_status = v.answer_status
				vo.npc_type = SceneObjType.FakeNpc
				vo.npc_idx = k - 1
				self:CreateFakeNpc(vo)
			end
		end
	end
end

function Scene:UpdateCameraSetting()
	local rotation_x = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_X).item_id
	local rotation_y = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_Y).item_id
	local distance = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_DISTANCE).item_id
	rotation_x = rotation_x == 0 and 45 or rotation_x
	rotation_y = rotation_y == 0 and 10 or rotation_y
	distance = distance == 0 and 9 or distance
	Scene.SetCameraFollow(Vector2(rotation_x, rotation_y), distance)
end

function Scene.SetCameraFollow(angle, distance)
	if not IsNil(MainCameraFollow) and CAMERA_TYPE == CameraType.Free then
		MainCameraFollow.AllowYRotation = true
		MainCameraFollow.RotationSmoothing = 7
		MainCameraFollow.ZoomSmoothing = 15
		MainCameraFollow.MaxDistance = 13
		MainCameraFollow.MinDistance = 0.1
		MainCameraFollow.MinPitchAngle = 5
		MainCameraFollow.MaxPitchAngle = 50
		MainCameraFollow.OriginAngle = angle
		MainCameraFollow.Distance = distance
	end
end

function Scene:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function Scene:IsNeedDelayCreateDoor()
	local scene_type = Scene.Instance:GetSceneType()
	if SceneType.TeamSpecialFb == scene_type and FuBenData.Instance:IsTeamSpecialNeedDelayCreateDoor() then
		return true
	elseif SceneType.ChallengeFB == scene_type and FuBenData.Instance:IsChallengeFBNeedDelayCreateDoor() then
		return true
	end

	return false
end

--这个方法使人物半透明
function Scene:OnAddTransparent()
	local main_role = Scene.Instance:GetMainRole()
	local draw_obj = main_role:GetDrawObj()
	if nil == draw_obj then
		return
	end

	for _, v in ipairs(TransparentPart) do
		local part = draw_obj:GetPart(v)
		if part then
			part:AddTransparentMaterial()
		end
	end
end

--这个方法使人物从半透明变化原先样子
function Scene:OnRemoveTransparent()
	local main_role = Scene.Instance:GetMainRole()
	local draw_obj = main_role:GetDrawObj()
	if nil == draw_obj then
		return
	end

	for _, v in ipairs(TransparentPart) do
		local part = draw_obj:GetPart(v)
		if part then
			part:RemoveTransparentMaterial()
		end
	end
end