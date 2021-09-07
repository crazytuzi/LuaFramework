require("game/scene/scene_config")
require("game/scene/scene_data")
require("game/scene/scene_protocal")
require("game/scene/camera")
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
require("game/scene/sceneobj/goddess_obj")
require("game/scene/sceneobj/trigger_obj")
require("game/scene/sceneobj/event_obj")
require("game/scene/sceneobj/fight_mount_obj")
require("game/scene/sceneobj/ming_ren_role")
require("game/scene/sceneobj/boat_obj")
require("game/scene/sceneobj/beauty_obj")
require("game/scene/sceneobj/mingjiang_obj")
require("game/scene/sceneobj/test_role")
require("game/scene/sceneobj/couple_halo_obj")
require("game/scene/optimize/scene_optimizes")
require("game/scene/sceneobj/baby_obj")

local UnityResources = UnityEngine.Resources
Scene = Scene or BaseClass(BaseController)

DownAngleOfCamera = 180
SHIELD_FREE_CAMERA = false 	-- 屏蔽自由视角

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

	self.act_scene_id = 0
	self.scene_logic = nil

	self:RegisterAllProtocols()						-- 注册所有需要响应的协议
	self:RegisterAllEvents()						-- 注册所有需要监听的事件

	-- 场景特效
	self.effect_list = {}

	-- 温泉皮艇
	self.boat_list = {}

	-- 夫妻光环
	self.couple_halo_obj_list = {}

	self.shield_npc_id_list = {}

	self.move_to_pos_cache = {						-- 检查并处理移动的操作缓存
		x = -1,
		y = -1,
		scene_id = 0,
		scene_path = nil,
		is_special = false,
	}

	-- 监听游戏设置改变
	self:BindGlobalEvent(SettingEventType.SHIELD_OTHERS, BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(SettingEventType.SELF_SKILL_EFFECT, BindTool.Bind1(self.OnShieldSelfEffectChanged, self))
	self:BindGlobalEvent(SettingEventType.SHIELD_SAME_CAMP, BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(SettingEventType.SKILL_EFFECT, BindTool.Bind1(self.OnShieldSkillEffectChanged, self))
	self:BindGlobalEvent(SettingEventType.CLOSE_GODDESS, BindTool.Bind1(self.OnShieldBeautyChanged, self))
	self:BindGlobalEvent(SettingEventType.CLOSE_SHOCK_SCREEN, BindTool.Bind1(self.OnShieldCameraShakeChanged, self))
	self:BindGlobalEvent(SettingEventType.CLOSE_TITLE, BindTool.Bind(self.SettingChange, self, SETTING_TYPE.CLOSE_TITLE))
	self:BindGlobalEvent(SettingEventType.SHIELD_ENEMY, BindTool.Bind1(self.OnShieldEnemy, self))
	self:BindGlobalEvent(SettingEventType.SHIELD_SPIRIT, BindTool.Bind1(self.OnShieldSpirit, self))
	self:BindGlobalEvent(SettingEventType.MAIN_CAMERA_MODE_CHANGE, BindTool.Bind1(self.UpdateCameraMode, self))
	self:BindGlobalEvent(SettingEventType.MAIN_CAMERA_SETTING_CHANGE,BindTool.Bind1(self.UpdateCameraSetting, self))

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

	if nil ~= self.clickHandle and nil ~= ClickManager.Instance then
		ClickManager.Instance:UnlistenClickGround(self.clickHandle)
		self.clickHandle = nil
	end
	self.diao_qiao = nil
	self:DelateAllObj()
	self:ClearScene()
	Scene.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function Scene:ReduceMemory()
	if Status.NowTime >= self.next_can_reduce_mem_time then
		self.next_can_reduce_mem_time = Status.NowTime + 5
		GameRoot.Instance:ReduceMemory()
	end
end

function Scene:SetSceneVisible(visible)
	self.is_scene_visible = visible
	if not IsNil(MainCamera) then
		MainCamera.enabled = self.is_scene_visible
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
end

function Scene:DelateAllObj()
	for _, v in pairs(self.obj_list) do
		self:Fire(ObjectEventType.OBJ_DELETE, v)
		v:DeleteMe()
	end
	self.obj_list = {}
end

function Scene:DeleteAllMoveObj()
	for k, v in pairs(self.obj_move_info_list) do
		v:DeleteMe()
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

	local pos_x, pos_y = self.main_role:GetLogicPos()
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

function Scene:OnChangeScene(scene_id)
	print("[Scene] OnChangeScene", scene_id)

	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_config then
		print_log("scene_config not find, scene_id:" .. scene_id)
		return
	end

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
	end

	-- 屏蔽在线奖励
	-- MainUICtrl.Instance.view:Flush("on_line")
end

-- 打开加载条加载场景
function Scene:StartLoadScene(scene_id)
	if not self:IsSceneLoading() and self.act_scene_id == scene_id then
		self:OnLoadSceneMainComplete(scene_id)
		self:OnLoadSceneDetailComplete(scene_id)
		return
	end

	self.scene_loading:Open()
	self.scene_loading:SetStartLoadingCallback(BindTool.Bind(self.OnLoadStart, self))
	self.scene_loading:Start(scene_id, BindTool.Bind(self.OnLoadEnd, self))
end

-- 加载开始
function Scene:OnLoadStart(scene_id)
	print("[Scene] OnLoadStart ", scene_id)
	self.start_loading_time = Status.NowTime
	ReportManager:Step(Report.STEP_CHANGE_SCENE_BEGIN, scene_id)

	ViewManager.Instance:Close(ViewName.Login)
	if LoginCtrl.Instance then
		LoginCtrl.Instance:ClearScenes()
	end

	AudioManager.PlayAndForget(AssetID("audios/sfxs/npcvoice/shared", "mute_voice")) 	-- 播放npc对话静音
	AudioManager.PlayAndForget(AssetID("audios/sfxs/uis", "MuteUIVoice")) 			-- 播放ui静音
	self.predownload:Stop()
	self.freedownload:Stop()
end

-- 加载结束
function Scene:OnLoadEnd(scene_id)
	local loading_time = Status.NowTime - self.start_loading_time
	ReportManager:Step(Report.STEP_CHANGE_SCENE_COMPLETE, scene_id, loading_time)
	print("[Scene] OnLoadEnd ", scene_id, loading_time)

	self.act_scene_id = scene_id
	self:OnLoadSceneMainComplete(scene_id)
	self:OnLoadSceneDetailComplete(scene_id)
	self.predownload:Start()
	self.freedownload:Start()
	MainUICtrl.Instance:GetView():ChangeGeneralState()

	self:SceneEventLogic(scene_id)

	-- force gc
	UnityResources.UnloadUnusedAssets()
	collectgarbage "collect"
end

function Scene:OnLoadSceneMainComplete(scene_id)
	if MainCamera ~= nil then
		MainCamera.enabled = self.is_scene_visible
		self:UpdateCameraMode()
		DownAngleOfCamera = 180 + MainCamera.transform.eulerAngles.y
	else
		print_error("The main camera is missing.")
	end
	
	local new_scene_type = self.scene_config.scene_type
	self.scene_logic:Enter(self.old_scene_type, new_scene_type)

	-- 场景切换俯冲效果
	if not SceneCanNotChangeCamera[scene_id] then
		Camera.Instance:SceneCameraChange()
	end

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
				if nil == prefab then
					return
				end
				local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
				local go = GameObject.Instantiate(prefab)
				go.transform.position = MoveableObject.FixToGround(Vector3(wx, 0, wy))
				table.insert(self.effect_list, go)
				PrefabPool.Instance:Free(prefab)
			end)
		end
	end

	-- 创建npc和传送门
	self:CreateNpcList()
	-- self:CreatMingRenList()
	self:CreateDoorList()
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

			-- 国战项目屏蔽点击地面取消挂机提示功能
			-- if (GuajiCache.guaji_type ~= GuajiType.None or MoveCache.is_valid or AtkCache.is_valid)
			-- 	and (self.last_click_ground_time == nil or Status.NowTime - self.last_click_ground_time > 5) then
			-- 	self.last_click_ground_time = Status.NowTime
			-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.ClickGoundAgainStopAuto)
			-- 	return
			-- end
			-- self.last_click_ground_time = Status.NowTime

			-- 国战项目取消自动挖矿
			if self:GetSceneType() == SceneType.KfMining then
				KuaFuMiningCtrl.Instance:StopAutoMining()
			end

			--策划需求70之后，玩家操作不收起右上角Buttons
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo.level < 70 then
				-- 点击到地面，移动
				self:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
			end

			TASK_GUILD_AUTO = false
			TASK_RI_AUTO = false
			local x, y = GameMapHelper.WorldToLogic(hit.point.x, hit.point.z)

			self.main_role:DoMoveByClick(x, y, 0, function ()
				GuajiCtrl.Instance:ClearAllOperate()
			end)
			-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

			local asset_name = AStarFindWay:IsBlock(x, y) and "Movement_Unwalkable" or "dianjidimian"
			EffectManager.Instance:PlayControlEffect("effects2/prefab/misc/" .. string.lower(asset_name) .. "_prefab", asset_name, Vector3(hit.point.x, hit.point.y + 0.25, hit.point.z))
		end)
	else
		print_log("This scene does not has ClickManager.")
	end
end

function Scene:OnLoadSceneDetailComplete(scene_id)
	self:Fire(SceneEventType.SCENE_ALL_LOAD_COMPLETE)
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
	return self.scene_config.is_forbid_pk and tonumber(self.scene_config.is_forbid_pk) == 1
end

function Scene:GetSceneTownPos()
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
		if v:GetGatherId() == gather_id and math.abs(pos_x - x) <= 1 and math.abs(pos_y - y) <= 1 then
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

function Scene:GetSceneAssetName()
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

	local settingData = SettingData.Instance
	local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)

	-- 屏蔽自己技能特效
	local shield_self_effect = settingData:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	main_part:EnableEffect(not shield_self_effect)
	main_part:EnableFootsteps(not shield_self_effect)

	-- 屏蔽女神

	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	self.main_role:SetBeautyVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config.id == 1110 then
		local follow_ui = self.main_role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end

	-- 关闭震屏效果
	local close_camera_shake = settingData:GetSettingData(SETTING_TYPE.CLOSE_SHOCK_SCREEN)
	main_part:EnableCameraShake(not close_camera_shake)

	RobertManager.Instance:OnMainRoleCreate()

	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_CREATE)

	return self.main_role
end

function Scene:CreateRole(vo)
	local role = self:CreateObj(vo, SceneObjType.Role)

	if role and role:IsRole() then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(vo)
			self:Fire(ObjectEventType.TEAM_HP_CHANGE, vo)
		end
	end
	local settingData = SettingData.Instance
	-- 屏蔽女神
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	local main_part = role.draw_obj:GetPart(SceneObjPart.Main)
	-- 屏蔽其他玩家
	if SettingData.Instance:IsShieldOtherRole(self:GetSceneId()) then
		role.draw_obj:SetVisible(false)
		role:SetRoleVisible(false)
		role:SetBeautyVisible(false)
	else
		local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
		local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
		local is_shield = false
		if shield_others and shield_same_camp then
			is_shield = true
		elseif shield_others then
			is_shield = not self:AttackModeIsEnemy(role, shield_others)
		elseif shield_same_camp then
			is_shield = self:AttackModeIsEnemy(role, shield_others)
		end

		role.draw_obj:SetVisible(not is_shield)
		role:SetRoleVisible(not is_shield)
		role:SetBeautyVisible(not shield_goddess)
	end
	
	--屏蔽血条(跨服温泉)
	if self.scene_config.id == 1110 then
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
	if SettingData.Instance:IsShieldOtherRole(self:GetSceneId()) then
		role.draw_obj:SetVisible(false)
		role:SetRoleVisible(false)
	else
		local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
		local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
		local is_shield = false
		if shield_others and shield_same_camp then
			is_shield = true
		elseif shield_others then
			is_shield = not self:AttackModeIsEnemy(role, shield_others)
		elseif shield_same_camp then
			is_shield = self:AttackModeIsEnemy(role, shield_others)
		end
		role.draw_obj:SetVisible(not is_shield)
		role:SetRoleVisible(not is_shield)
	end
	-- 屏蔽女神
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	role:SetBeautyVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config.id == 1110 then
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
	if IsPinBiModel then return end		-- cmd命令测试屏蔽专用的。
	return self:CreateObj(vo, SceneObjType.Monster)
end

function Scene:CreateDoor(vo)
	if IsPinBiModel then return end
	self:CreateObj(vo, SceneObjType.Door)
end

function Scene:CreateJumpPoint(vo)
	if IsPinBiModel then return end
	self:CreateObj(vo, SceneObjType.JumpPoint)
end

function Scene:CreateEffectObj(vo)
	if IsPinBiModel then return end
	return self:CreateObj(vo, SceneObjType.EffectObj)
end

function Scene:CreateFallItem(vo)
	self:CreateObj(vo, SceneObjType.FallItem)
end

function Scene:CreateZhuaGuiNpc(vo)
	if IsPinBiModel then return end
	self:CreateObj(vo, SceneObjType.EventObj)
end

function Scene:CreateGatherObj(vo)
	if IsPinBiModel then return end
	self:CreateObj(vo, SceneObjType.GatherObj)
end

function Scene:CreateNpc(vo)
	if IsPinBiModel then return end
	self:CreateObj(vo, SceneObjType.Npc)
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

function Scene:CreateGoddessObj(vo)
	return self:CreateObj(vo, SceneObjType.GoddessObj)
end

function Scene:CreateBeautyObj(vo)
	if IsPinBiModel then return end
	return self:CreateObj(vo, SceneObjType.BeautyObj)
end

function Scene:CreateMingJiangObj(vo)
	return self:CreateObj(vo, SceneObjType.MingJiangObj)
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

function Scene:CreateBabyObj(vo)
	return self:CreateObj(vo, SceneObjType.Baby)
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

-- 根据角色创建Spirit
function Scene:CreateSpiritObjByRole(role)
	local spirit_obj = nil
	local role_vo = role:GetVo()
	if role_vo.used_sprite_id and role_vo.used_sprite_id > 0 then
		local spirit_vo = GameVoManager.Instance:CreateVo(SpriteObjVo)
		spirit_vo.pos_x, spirit_vo.pos_y = role:GetLogicPos()
		spirit_vo.pos_x = spirit_vo.pos_x + 5
		spirit_vo.name = role_vo.name.."精灵"

		spirit_vo.owner_role_id = role_vo.role_id
		spirit_vo.owner_obj_id = role_vo.obj_id
		spirit_vo.used_sprite_id = role_vo.used_sprite_id
		spirit_vo.move_speed = role:GetVo().move_speed
		spirit_vo.spirit_name = role_vo.sprite_name
		-- spirit_vo.show_hp = 100
		spirit_vo.hp = 100
		spirit_obj = self:CreateSpiritObj(spirit_vo)
		-- if nil ~= spirit_obj then
		-- 	role:SetTruckObjId(spirit_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
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
	goddess_vo.goddess_wing_id = role_vo.appearance.shenyi_used_imageid
	goddess_vo.goddess_shen_gong_id = role_vo.appearance.shengong_used_imageid
	goddess_vo.xiannv_huanhua_id = role_vo.xiannv_huanhua_id
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

function Scene:CreateBeautyObjByRole(role)
	local beauty_obj = nil
	local role_vo = role:GetVo()
	local beauty_vo = GameVoManager.Instance:CreateVo(BeautyObjVo)
	beauty_vo.pos_x, beauty_vo.pos_y = role:GetLogicPos()
	beauty_vo.pos_x = beauty_vo.pos_x + 2
	beauty_vo.owner_role_id = role_vo.role_id
	beauty_vo.owner_obj_id = role_vo.obj_id
	beauty_vo.hp = 100
	beauty_vo.move_speed = role_vo.move_speed
	beauty_vo.beauty_used_seq = role_vo.beauty_used_seq
	beauty_vo.beauty_used_huanhua_seq = role_vo.beauty_used_huanhua_seq
	beauty_vo.beauty_is_active_shenwu = role_vo.beauty_is_active_shenwu
	beauty_vo.name = ""
	beauty_vo.jingling_guanghuan_img_id = role_vo.jingling_guanghuan_img_id
	beauty_obj = self:CreateBeautyObj(beauty_vo)
	return beauty_obj
end

function Scene:CreateMingjiangObjByRole(role)
	local mingjiang_obj = nil
	local role_vo = role:GetVo()
	local mingjiang_vo = GameVoManager.Instance:CreateVo(MingJiangObjVo)
	mingjiang_vo.pos_x, mingjiang_vo.pos_y = role:GetLogicPos()
	mingjiang_vo.pos_x = mingjiang_vo.pos_x + 2
	mingjiang_vo.owner_role_id = role_vo.role_id
	mingjiang_vo.owner_obj_id = role_vo.obj_id
	mingjiang_vo.hp = 100
	mingjiang_vo.move_speed = role_vo.move_speed
	mingjiang_vo.name = ""
	mingjiang_obj = self:CreateMingJiangObj(mingjiang_vo)
	return mingjiang_obj
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

function Scene:CreateBabyObjByRole(role)
	local baby_obj = nil
	local role_vo = role:GetVo()
	local baby_vo = GameVoManager.Instance:CreateVo(BabyObjVo)
	baby_vo.pos_x, baby_vo.pos_y = role:GetLogicPos()
	baby_vo.pos_x = baby_vo.pos_x + 2
	baby_vo.owner_role_id = role_vo.role_id
	baby_vo.owner_obj_id = role_vo.obj_id
	baby_vo.baby_res_id = role_vo.baby_id
	baby_obj = self:CreateBabyObj(baby_vo)
	return baby_obj
end

-- 创建NPC列表
function Scene:CreateNpcList()
	if CgManager.Instance:IsCgIng() then
		return
	end

	if nil ~= self.scene_config.npcs then
		for k, v in pairs(self.scene_config.npcs) do
			if math.abs(v.x - self.main_role_pos_x) <= 120 and math.abs(v.y - self.main_role_pos_y) <= 120 then
				if nil == self:GetObjByTypeAndKey(SceneObjType.Npc, v.id) then
					local vo = GameVoManager.Instance:CreateVo(NpcVo)
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.npc_id = v.id
					vo.rotation_y = v.rotation_y
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
	if nil ~= self.scene_config.doors then
		for k, v in pairs(self.scene_config.doors) do
			if v.type ~= SceneDoorType.INVISIBLE then
				if math.abs(v.x - self.main_role_pos_x) <= 60 and math.abs(v.y - self.main_role_pos_y) <= 60 then
					if nil == self:GetObjByTypeAndKey(SceneObjType.Door, v.id) then
						local vo = GameVoManager.Instance:CreateVo(DoorVo)
						vo.name = "door" .. v.id
						vo.pos_x = v.x
						vo.pos_y = v.y
						vo.door_id = v.id
						vo.offset = v.offset
						vo.rotation = v.rotation

						--攻城战单独处理传送阵名字
						if v.target_scene_id == 1002 then
							vo.target_name = CityCombatData.Instance:GetDorrName()
						else
							local target_config = ConfigManager.Instance:GetSceneConfig(v.target_scene_id)
							if target_config ~= nil then
								vo.target_name = target_config.name
							end
						end

						self:CreateDoor(vo)
					end
				else
					self:DeleteObjByTypeAndKey(SceneObjType.Door, v.id)
				end
			end
		end
	end
end

-- 创建跳跃点列表
function Scene:CreateJumpPointList()
	if nil ~= self.scene_config.jumppoints then
		for k, v in pairs(self.scene_config.jumppoints) do
			if math.abs(v.x - self.main_role_pos_x) <= 300 and math.abs(v.y - self.main_role_pos_y) <= 300 then
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
					vo.jump_act = v.jump_act
					vo.jump_tong_bu = v.jump_tong_bu
					vo.jump_time = v.jump_time
					self:CreateJumpPoint(vo)
				end
			else
				self:DeleteObjByTypeAndKey(SceneObjType.JumpPoint, v.id)
			end
		end
	end
end

-- 创建温泉皮艇
function Scene:CreateBoatByCouple(boy_obj_id, girl_obj_id, boy_obj)
	local boy_boat_obj_id = self.boat_list[boy_obj_id]
	local girl_boat_obj_id = self.boat_list[girl_obj_id]
	if nil ~= boy_boat_obj_id and nil ~= girl_boat_obj_id and boy_boat_obj_id == girl_boat_obj_id then
		return
	end
	self:DeleteBoatByRole(boy_obj_id)
	self:DeleteBoatByRole(girl_obj_id)
	local vo = GameVoManager.Instance:CreateVo(BoatObjVo)
	vo.boy_obj_id = boy_obj_id
	vo.girl_obj_id = girl_obj_id
	if nil ~= boy_obj then
		vo.pos_x, vo.pos_y = boy_obj:GetLogicPos()
	end
	local boat_obj = self:CreateObj(vo, SceneObjType.BoatObj)
	self.boat_list[boy_obj_id] = boat_obj:GetObjId()
	self.boat_list[girl_obj_id] = boat_obj:GetObjId()
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

local client_obj_id_inc = 0x10000
function Scene:CreateObj(vo, obj_type)
	if vo.obj_id < 0 then
		client_obj_id_inc = client_obj_id_inc + 1
		vo.obj_id = client_obj_id_inc
	end

	if self.obj_list[vo.obj_id] then
		return nil
	end

	local obj = nil
	if obj_type == SceneObjType.Role then
		obj = Role.New(vo)
		self:SetFollowLocalPosition(0, obj)
	elseif obj_type == SceneObjType.MainRole then
		obj = MainRole.New(vo)
		self:SetFollowLocalPosition(0, obj)
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
			if self.scene_logic:CanShieldMonster() and (nil == obj.IsBoss or not obj:IsBoss()) then
				obj.draw_obj:SetVisible(not is_shield)
				obj.draw_obj:SetObjType(SceneObjType.Monster)
				local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
				if is_shield then
					follow_ui:SetHpBarLocalPosition(0, 80, 0)
				else
					follow_ui:SetHpBarLocalPosition(0, -5, 0)
				end
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
		obj = Npc.New(vo)
	elseif obj_type == SceneObjType.FakeNpc then
		obj = Npc.New(vo)
	elseif obj_type == SceneObjType.SpriteObj then
		obj = SpiritObj.New(vo)
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
	elseif obj_type == SceneObjType.BeautyObj then
		obj = Beauty.New(vo)
	elseif obj_type == SceneObjType.MingJiangObj then
		obj = MingJiangObj.New(vo)	
	elseif obj_type == SceneObjType.CoupleHaloObj then
		obj = CoupleHaloObj.New(vo)
	elseif obj_type == SceneObjType.Baby then
		obj = Baby.New(vo)
	elseif obj_type == SceneObjType.TestRole then
		obj = TestRole.New(vo)
		self:SetFollowLocalPosition(0, obj)
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

	GlobalEventSystem:Fire(ObjectEventType.OBJ_CREATE, obj)

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
		if v:IsCharacter() then
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

--选择指定id的最近的采集物
function Scene:SelectMinDisGather(gather_id, distance_limit, is_rand)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()
	local rand_tab = {}

	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					target_obj = target_obj or v
				else
					if not is_rand then
						target_obj = v
						target_distance = distance
					else
						table.insert(rand_tab, v)
					end
				end
			end
		end
	end

	if is_rand then
		math.randomseed(os.time())
		local num = math.random(1, #rand_tab)
		target_obj = rand_tab[num]
	end
	
	return target_obj
end

-- 拾取所有物品
local others_item_tips_time = 0
local bag_full_tips_time = 0
function Scene:PickAllFallItem()
	if self.main_role then
		if self.main_role:IsRealDead() then
			return
		end
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
		if not v:IsPicked() then --个人塔防里的buff需要把 item_cfg and 这个判断条件去掉了，要是这里出什么bug就加上去
			local dis = v:GetAutoPickupMaxDis()
			if dis > 0 then
				-- 红包、绑定元宝之类的
					dis = dis * dis
					local x, y = self.main_role:GetLogicPos()
					if GameMath.GetDistance(x, y, v:GetVo().pos_x, v:GetVo().pos_y, false) < dis then
						if v:GetVo().owner_role_id <= 0 or v:GetVo().owner_role_id == self.main_role:GetRoleId() and Status.NowTime >= v:GetVo().create_time + 2 then
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
				Status.NowTime >= v:GetVo().create_time + 2 and
				((auto_pick_item and item_cfg.color > auto_pick_color) or v:GetVo().is_buff_falling == 1) then
				-- 自己的物品   auto_pick_item and item_cfg.color > auto_pick_color
				v:RecordIsPicked()
				table.insert(item_objid_list, v:GetObjId())
				if not v:IsCoin() then
					pick_item_num = pick_item_num + 1
				end
			end

			if empty_num <= pick_item_num then
				break
			end
		end
	end

	if 0 == empty_num and #item_objid_list > 0 then
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
			local vx, vy = v:GetLogicPos()
			local point_distance = GameMath.GetDistance(x, y, vx, vy, false)
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
	local next_position = nil
	if target_point then
		next_position = target_point.draw_obj.root.transform.position
	end

	if self.main_role.vo.multi_mount_res_id >= 0 and self.main_role.vo.multi_mount_other_uid > 0 then --有双人坐骑直接传送
		self:JumpEnd(to_point)
	else
		self.main_role:JumpTo(vo, to_point, target_point, function()
			if to_point.vo.target_id and to_point.vo.target_id ~= 0 then
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
end

function Scene:JumpEnd(to_point)
	local target_point = self:GetObjByTypeAndKey(SceneObjType.JumpPoint, to_point.vo.target_id)
	if to_point.vo.target_id and to_point.vo.target_id ~= 0 then
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
end

function Scene:CheckJump()
	if self.main_role:IsJump() or self.main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return false
	end

	local x, y = self.main_role:GetLogicPos()

	local jumppoint_obj_list = self:FindJumpPoint(x, y)
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

	if self.main_role.vo.husong_taskid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.CanNotJump)
		return false
	end

	if SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == self.main_role.vo.special_appearance then
		local show_str_flag = self.main_role:GetNoJumpStrFlag()
		if show_str_flag then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.BianShenNoJump)
			self.main_role:SetNoJumpStrFlag(false)
		end
		return false
	end

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
	-- self:CreatMingRenList()

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
	if self.main_role then
		local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)
		main_part:EnableEffect(not value)
		main_part:EnableFootsteps(not value)
	end
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

function Scene:OnShieldBeautyChanged(value)
	local settingData = SettingData.Instance
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	if CgManager.Instance:IsCgIng() or shield_friend then
		shield_goddess = true
	end
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetBeautyVisible(not shield_goddess)
		end
	end
end

-- 在不同模式是否敌方
function Scene:AttackModeIsEnemy(target_obj, shield_others)
	return self.scene_logic:AttackModeIsEnemy(target_obj, self.main_role, shield_others)
end

function Scene:OnShieldRoleChanged(value, is_shield)
	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	local is_shield_role = false
	if is_shield or SettingData.Instance:IsShieldOtherRole(self:GetSceneId()) then
		is_shield_role = true
	end
	if shield_others or shield_friend or is_shield_role then
		RobertMgr.Instance:ShieldAllRobert()
		for _, v in pairs(self.obj_list) do
			if v:IsRole() and not v:IsMainRole() and v.vo.role_id ~= self.main_role.vo.multi_mount_other_uid and v:GetVo().shadow_type < ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES then		
				if is_shield_role then
					--
				elseif shield_others and shield_friend then
					is_shield_role = true
				elseif shield_others then
					is_shield_role = not self:AttackModeIsEnemy(v, shield_others)
				else
					is_shield_role = self:AttackModeIsEnemy(v, shield_others)
				end
				v.draw_obj:SetVisible(not is_shield_role)
				v:SetRoleVisible(not is_shield_role)

				if v:GetVo().shadow_type ~= ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER then
					v.draw_obj:GetSceneObj():GetFollowUi():Show()
				end
			
				if SettingData.Instance:IsShieldOtherRole(self:GetSceneId()) then
					v.draw_obj:GetSceneObj():GetFollowUi():Hide()
				end
				-- if is_shield_role then
				-- 	self:SetFollowLocalPosition(100, v)
				-- else
				-- 	self:SetFollowLocalPosition(0, v)
				-- end
				-- end
			elseif v:IsRole() and not v:IsMainRole() and v.vo.role_id == self.main_role.vo.multi_mount_other_uid then
				v.draw_obj:SetVisible(true)
				v:SetRoleVisible(true)

				if v:GetVo().shadow_type ~= ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER then
					v.draw_obj:GetSceneObj():GetFollowUi():Show()
				end
				
				self:SetFollowLocalPosition(0, v, true)
			end
		end
		return
	else
		RobertMgr.Instance:UnShieldAllRobert()
		for _, v in pairs(self.obj_list) do
			if v:IsRole() and not v:IsMainRole() and not v:IsRoleVisible() then
				v.draw_obj:SetVisible(true)
				v:SetRoleVisible(true)

				if v:GetVo().shadow_type ~= ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER then
					v.draw_obj:GetSceneObj():GetFollowUi():Show()
				end
				
				self:SetFollowLocalPosition(0, v)
			end
		end
	end
end

function Scene:SetFollowLocalPosition(high, obj, is_multi)
	local follow_ui = obj:GetFollowUi()
	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

	local is_shield = false
	if shield_others and shield_friend then
		is_shield = true
	elseif shield_others then
		is_shield = not self:AttackModeIsEnemy(obj, shield_others)
	elseif shield_friend then
		is_shield = self:AttackModeIsEnemy(obj, shield_others)
	end

	if is_multi then
		is_shield = false
	end

	local temp_high = (is_shield and not obj:IsMainRole()) and 100 or 0
	local high = temp_high

	-- follow_ui:SetFollowTarget(obj.draw_obj:GetRoot().transform)
	if follow_ui then
		follow_ui:SetFollowTarget(obj.draw_obj:GetTransfrom())
		follow_ui:SetLocalUI(0,high,0)
		follow_ui:GetHpObj().transform:SetLocalPosition(0,10,0)
		-- follow_ui:GetNameTextObj().transform:SetLocalPosition(0,90,0)
		follow_ui:SetNameTextPosition()
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
		if nil == v.IsBoss or not v:IsBoss() then
			v.draw_obj:SetVisible(not value)
			if v.draw_obj:GetObjType() == SceneObjType.Monster then
				v.draw_obj:GetSceneObj():_FlushFollowTarget()
			end
			local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
			if value then
				follow_ui:SetHpBarLocalPosition(0, 80, 0)
			else
				follow_ui:SetHpBarLocalPosition(0, -5, 0)
			end
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

function Scene:ShieldNpc(npc_id, ui_show)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(false)
		if ui_show then
			npc_obj:GetFollowUi():Hide()
		end
	end
	self.shield_npc_id_list[npc_id] = true
end

function Scene:UnShieldNpc(npc_id)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(true)
		npc_obj:GetFollowUi():Show()
	end
	self.shield_npc_id_list[npc_id] = nil
end

function Scene:UpdateCameraMode(param_1, param_2)
	local flag = 0
	if param_2 then
		flag = param_2
	else
		local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
		flag = guide_flag_list.item_id
		if self.main_role and PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then 	--抱美人固定3视角
			flag = 3
		end
	end
	self:SetCameraMode(flag)
end

function Scene:SetCameraMode(index)
	index = index or 0
	-- 策划要求镜头1和镜头2参数交换
	if index == 0 or SceneType.ExpFb == Scene.Instance:GetSceneType() or Scene.Instance:GetSceneId() == 3153 then
		index = 1
	elseif index == 1 then
		-- index = 0 	--不要第二个锁定视角
		index = 2
	end

	if SHIELD_FREE_CAMERA then
		if index == 2 then
			index = 3
		end
	end

	-- 切换到自由视角
	if index == 2 and CAMERA_TYPE == CameraType.Fixed then
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
	elseif index ~= 2 and CAMERA_TYPE == CameraType.Free then
		if not IsNil(MainCamera) then
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
	end

	if CAMERA_TYPE == CameraType.Fixed and not IsNil(MainCameraFollow) then
		-- 抱花任务特殊处理
		if index == 3 then
			index = 2
		end
		MainCameraFollow:SetCameraTransform(index)
	end
end

function Scene:GetMoveToPosCache()
	return self.move_to_pos_cache
end

function Scene:ClearMovePosCache()
	self.move_to_pos_cache.x = -1
	self.move_to_pos_cache.y = -1
	self.move_to_pos_cache.scene_id = 0
	self.move_to_pos_cache.scene_path = nil
	self.move_to_pos_cache.is_special = false
end

function Scene:GetSceneMosterList()
	return self.scene_config and self.scene_config.monsters or nil
end

-- 场景事件逻辑,用于场景中某些功能的，比如开吊桥这些
function Scene:SceneEventLogic(scene_id)
	local cur_sence_id = 2020	--假副本场景id
	local task_vo = TaskData.Instance:GetDiaoQiaoTask(PlayerData.Instance.role_vo.camp)
	if task_vo and (scene_id == task_vo.sence_id or scene_id == cur_sence_id) then
		local diao_qiao = UnityEngine.GameObject.Find("Diaoqiao")
		if diao_qiao then
			local diaoqiao_obj = diao_qiao.transform:Find("Fhc_diaoqiao_01_D")
			if diaoqiao_obj then
				local diaoqiao_animator = diaoqiao_obj:GetComponent(typeof(UnityEngine.Animator))
				if diaoqiao_animator then
					diaoqiao_animator.enabled = TaskData.Instance:GetTaskIsCompleted(task_vo.task_id)
				end
			end
		end
	end
end

--设置吊桥是否显示
function Scene:SetDiaoqiaoIsShield(bool)
	local cur_sence_id = 2020	--假副本场景id
	if self:GetSceneId() == cur_sence_id then
		if self.diao_qiao == nil then
			self.diao_qiao = UnityEngine.GameObject.Find("Diaoqiao")
		end
		if self.diao_qiao then
			self.diao_qiao:SetActive(bool)
		end
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
		MainCameraFollow.RotationSmoothing = 20
		MainCameraFollow.ZoomSmoothing = 10
		MainCameraFollow.MaxDistance = 13
		MainCameraFollow.MinPitchAngle = 10
		MainCameraFollow.MaxPitchAngle = 75
		MainCameraFollow.OriginAngle = angle
		MainCameraFollow.Distance = distance
		MainCameraFollow.TargetOffset = (Vector3(0, 2.5, 0))
	end
end
