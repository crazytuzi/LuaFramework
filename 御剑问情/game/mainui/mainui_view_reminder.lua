MainUIViewReminding = MainUIViewReminding or BaseClass(BaseRender)

DaFuHaoAutoGatherEvent = {
	func = nil
}
ShengDiFuBenAutoGatherEvent = {
	func = nil
}
MainUIViewReminding.SHOW_SHOT_LEVEL = 88
function MainUIViewReminding:__init()
	self.gua_ji = self:FindObj("GuaJi")
	self.xun_lu = self:FindObj("XunLu")
	self.gather = self:FindObj("GatherBar")
	self.show_shuangxiu = self:FindVariable("ShowShuangXiu")
	self.be_atk_icon = MainBeAtkIcon.New(self:FindObj("BeAtkSmallParts"))
	self.gather_bar = self.gather:GetComponent(typeof(UnityEngine.UI.Slider))
	self.xunlu_act = false
	self.is_auto_gather = false
	self.is_sheng_auto_gather = false
	self.is_gather_dafuhao = false
	self.atk_icon_show_time = 0
	self.is_auto_rotation_camera = false

	self.gather_text = self:FindVariable("Gather")
	self.show_answer_button = self:FindVariable("ShowAnswerButton")
	self.show_gather_btn = self:FindVariable("ShowGatherBtn")
	self.gray_dun = self:FindVariable("GrayDun")
	self.shot_shot = self:FindVariable("ShowShot")
	self.show_dafuhao_btn_group = self:FindVariable("ShowDaFuHaoBtnGroup")
	self.dafuhao_skill_rest_times = self:FindVariable("DaFuHaoSkillRestTimes")
	self.skill_cd_time = self:FindVariable("SkillCD")
	self.skill_cd_progress = self:FindVariable("SkillCDProgress")
	self.has_first_charge = self:FindVariable("HasFirstCharge")

	self:BindGlobalEvent(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_AUTO_XUNLU,
		BindTool.Bind(self.OnMainRoleAutoXunluChange, self))
	self:BindGlobalEvent(ObjectEventType.GATHER_TIMER,
		BindTool.Bind(self.OnSetGatherTime, self))
	self:BindGlobalEvent(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self:BindGlobalEvent(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
	self:BindGlobalEvent(OtherEventType.REPAIR_STATE_CHANGE,
		BindTool.Bind(self.OnChangeRepair, self))
	self:BindGlobalEvent(OtherEventType.DAFUHAO_INFO_CHANGE,
		BindTool.Bind(self.SetGatherBtnState, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT,
		BindTool.Bind(self.OnSceneLoadQuit, self))
	self:BindGlobalEvent(OtherEventType.POWER_CHANGE_VIEW_OPEN,
		BindTool.Bind(self.PowerChangeViewOpen, self))

	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self)) -- self.obj_del_event =
	self:BindGlobalEvent(ObjectEventType.OBJ_CREATE,
		BindTool.Bind(self.OnObjCreate, self)) -- self.obj_creat =
	self:BindGlobalEvent(OtherEventType.JUMP_STATE_CHANGE,
		BindTool.Bind(self.OnJumpStateChange, self))

	self:BindGlobalEvent(OtherEventType.SHENGDI_FUBEN_INFO_CHANGE,
		BindTool.Bind(self.SetGatherBtnStateTwo, self))
	self:BindGlobalEvent(SettingEventType.MAIN_CAMERA_MODE_CHANGE,
		BindTool.Bind1(self.CameraModeChange, self))

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityCallBack, self)) --self.activity_call_back =

	self:ListenEvent("OnClickFollow",
		BindTool.Bind(self.OnClickFollow, self))
	self:ListenEvent("ClickGather",
		BindTool.Bind(self.ClickGather, self))
	self:ListenEvent("ClickFly",
		BindTool.Bind(self.ClickFly, self))
	self:ListenEvent("OnClickBingDongSkill",
		BindTool.Bind(self.OnClickBingDongSkill, self))

	self.is_can_gather = true
	self.dafuhao_gather_list = {}
	self.dafuhao_exp_list = {}
	self.show_answer_button:SetValue(false)
	self:FlushFirstCharge()
end

-- 自动寻路状态改变
local scene_cfg = nil
function MainUIViewReminding:OnMainRoleAutoXunluChange(auto)
	self.is_auto_rotation_camera = auto or false
	if MainCameraFollow and CAMERA_TYPE == CameraType.Free then
		MainCameraFollow.AutoRotation = self.is_auto_rotation_camera
	end
	scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if 0 == scene_cfg.is_show_navigation then
		auto = false
	end
	if PlayerData.Instance.role_vo.husong_taskid > 0 then
		auto = false
	end
	if PlayerData.Instance.role_vo.task_appearn > 0 then
		auto = false
	end
	self:CheckShowShot()
	if self.xunlu_act == auto then return end
	self.xunlu_act = auto
	if auto == true and SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_USE_FLY_SHOE) then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if VipPower.Instance:GetParam(VipPowerId.scene_fly) > 0 and MoveCache.cant_fly == false then
			self:ClickFly()
		else
			local shot_id = MapData.Instance:GetFlyShoeId()
			local num = ItemData.Instance:GetItemNumInBagById(shot_id)
			if num > 0 and MoveCache.cant_fly == false then
				self:ClickFly()
			else
				local buy_type = ShopData.Instance:CheckCanBuyItem(shot_id)

				if buy_type and buy_type == SHOP_BIND_TYPE.BIND and MoveCache.cant_fly == false then
					TaskCtrl.SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
				elseif buy_type and buy_type == SHOP_BIND_TYPE.NO_BIND and MoveCache.cant_fly == false then
					TaskCtrl.SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
				end
			end
		end
	end
	self.xun_lu:SetActive(auto and not self.pc_view_open)
end

function MainUIViewReminding:CameraModeChange()
	if MainCameraFollow and CAMERA_TYPE == CameraType.Free then
		MainCameraFollow.AutoRotation = self.is_auto_rotation_camera
	end
end

-- 挂机类型改变
function MainUIViewReminding:OnGuajiTypeChange(guaji_type)
	-- if(guaji_type == GuajiType.HalfAuto) then
	-- 	self.gua_ji:SetActive(false)
	-- 	-- if not self.gather:GetActive() then
	-- 	-- 	self.xun_lu:SetActive(true)
	-- 	-- end
	-- 	self.xunlu_act = true
	-- elseif(guaji_type == GuajiType.Auto) then
	-- 	-- self.gua_ji:SetActive(true)
	-- 	self.xun_lu:SetActive(false)
	-- 	self.xunlu_act = false
	-- else
	-- 	self.gua_ji:SetActive(false)
	-- 	self.xun_lu:SetActive(false)
	-- 	self.xunlu_act = false
	-- end
end

-- 跳跃改变
function MainUIViewReminding:OnJumpStateChange(jump_state)
	self:CheckShowShot()
end

function MainUIViewReminding:CheckShowShot()
	 local role_vo = PlayerData.Instance.role_vo
	if role_vo and (role_vo.level < MainUIViewReminding.SHOW_SHOT_LEVEL or role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2) then
		self.shot_shot:SetValue(false)
	else
		self.shot_shot:SetValue(true)
	end
	if MoveCache.cant_fly == true then
		self.shot_shot:SetValue(false)
	end
end

function MainUIViewReminding:__delete()
	self.is_auto_gather = nil
	self.is_shengdi_auto_gather = nil

	if self.be_atk_icon ~= nil then
		self.be_atk_icon:DeleteMe()
	end

	if self.skill_cd_progress_count_down then
		CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
		self.skill_cd_progress_count_down = nil
	end

	-- GlobalEventSystem:UnBind(self.obj_del_event)
	-- self.obj_del_event = nil

	-- GlobalEventSystem:UnBind(self.obj_creat)
	-- self.obj_creat = nil

	-- if self.activity_call_back then
	-- 	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
	-- 	self.activity_call_back = nil
	-- end

	DaFuHaoAutoGatherEvent.func = nil
	ShengDiFuBenAutoGatherEvent.func = nil
end

function MainUIViewReminding:OnSceneLoadQuit()
	self:SetGatherBtnState()

	self.show_dafuhao_btn_group:SetValue(DaFuHaoData.Instance:IsDaFuHaoScene())
end

function MainUIViewReminding:OnChangeRepair(state)
	if self.show_shuangxiu then
		self.show_shuangxiu:SetValue(state)
	end
end

function MainUIViewReminding:SetBeAtkIconState(role_vo)
	self.be_atk_icon:SetData(role_vo)
end



-- 开始采集
function MainUIViewReminding:OnStartGather(role_obj_id, gather_obj_id)
	local main_role = Scene.Instance:GetMainRole()
	local obj_id = main_role:GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	-- self.xun_lu:SetActive(false)
	self.isOn = true
	local name = nil
	local describe = ""
	local config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)

	local id = nil
	if gather_obj then
		id = gather_obj:GetGatherId()
		if Scene.Instance:GetSceneType() == SceneType.DaFuHao then
			self.is_gather_dafuhao = true
			self.is_auto_gather = true
		else
			local cfg = ConfigManager.Instance:GetAutoConfig("qingyuanshengdiconfig_auto").gather or {}
			for k,v in pairs(cfg) do
				if v.gather_id == id then
					self.is_shengdi_auto_gather = true
					break
				else
					self.is_shengdi_auto_gather = false
				end
			end
		end

		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.Fishing then
			--钓鱼特殊处理
			FishingCtrl.Instance:HideFishing(true)
		end

		if not KuaFuMiningData.Instance:IsMiningGather(id) then
			KuaFuMiningCtrl.Instance:SetMiningButtonVisable(false)
		else
			KuaFuMiningCtrl.Instance:SetMiningButtonVisable(true)
		end
		if Scene.Instance:GetSceneType() == SceneType.KfMining and KuaFuMiningData.Instance:IsMiningGather(id) then
			KuaFuMiningCtrl.Instance:SetGatherVisable(true) 	--显示挖矿转盘
			return
		end
	end
	self.gather:SetActive(true)
	if config and id then
		local gather_config = config[id]
		if gather_config then
			name = gather_config.show_name
			describe = gather_config.describe
		end
	end
	name = name or Language.Common.DefaultGather
	describe = describe == "" and Language.Common.IsGather .. name or describe
	if id == GuildBonfireData:GetBonfireOtherCfg().gathar_id then
		self.gather_text:SetValue(Language.Guild.Praying)
	else
		self.gather_text:SetValue(describe)
	end
end

-- 停止采集
function MainUIViewReminding:OnStopGather(role_obj_id)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.gather:SetActive(false)

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.KfMining then
		KuaFuMiningCtrl.Instance:SetMiningButtonVisable(true)
		KuaFuMiningCtrl.Instance:StopMining()
	end

	if scene_type == SceneType.Fishing then
		FishingCtrl.Instance:HideFishing(false)
	end
	
	-- self.xun_lu:SetActive(self.xunlu_act or false)
	self.gather_bar.value = 0
	self.isOn = false
	if self.tweener then
		self.tweener:Pause()
	end
	self:SetGatherBtnState()

	self:SetGatherBtnStateTwo()
end

-- 设置采集时间
function MainUIViewReminding:OnSetGatherTime(gather_time)
	if not gather_time then return end
	if not self.isOn then
		return
	end
	-- if gather_time > 0.2 then
	-- 	gather_time = gather_time - 0.2
	-- end
	self.gather_bar.value = 0
	self.tweener = self.gather_bar:DOValue(1, gather_time, false)
	self.tweener:SetEase(DG.Tweening.Ease.Linear)
	self.tweener:OnComplete(function ()
		if self.gather and not IsNil(self.gather.gameObject) then
			self.gather:SetActive(false)
		end
	end)
end

function MainUIViewReminding:PowerChangeViewOpen(is_open)
	self.pc_view_open = is_open
	self.xun_lu:SetActive(self.xunlu_act and not self.pc_view_open)
end

-- 点击跟随榜首
function MainUIViewReminding:OnClickFollow()
	GuajiCtrl.Instance:StopGuaji()
	HotStringChatCtrl.Instance:SendFirstPos()
end

function MainUIViewReminding:SetQuestionState(state)
	self.show_answer_button:SetValue(state)
end

function MainUIViewReminding:OnObjDelete(obj)
	if nil == obj then return end

	if DaFuHaoData.Instance and DaFuHaoData.Instance:IsDaFuHaoGather(obj) then
		self:SetGatherBtnState()
	end
end

function MainUIViewReminding:OnObjCreate(obj)
	if nil == obj then return end

	if DaFuHaoData.Instance and DaFuHaoData.Instance:IsDaFuHaoGather(obj) then
		self:SetGatherBtnState()
	end
end

function MainUIViewReminding:ActivityCallBack(activity_type)
	if activity_type == DaFuHaoDataActivityId.ID then
		self:SetGatherBtnState()
	end
end

function MainUIViewReminding:GetDafuhaoGather()
	self.dafuhao_gather_list = {}
	self.dafuhao_exp_list = {}
	if Scene.Instance:GetSceneType() ~= SceneType.DaFuHao then
		return
	end
	for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
		if DaFuHaoData.Instance:IsDaFuHaoBox(j:GetGatherId()) then
			local pos_x, pos_y = j:GetLogicPos()
			self.dafuhao_gather_list[#self.dafuhao_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
		else
			local pos_x, pos_y = j:GetLogicPos()
			self.dafuhao_exp_list[#self.dafuhao_exp_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
		end
	end
end

function MainUIViewReminding:SetGatherBtnState(gather_id)
	if self.show_gather_btn then
		self.show_gather_btn:SetValue(true)
		self:SetDaFuHaoSkill()
		local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}
		self:GetDafuhaoGather()
		if dafuhao_info.reward_index and dafuhao_info.reward_index < 0 and dafuhao_info.gather_total_times == 10 and nil == next(self.dafuhao_exp_list) then
			self.is_auto_gather = false
		end

		DaFuHaoAutoGatherEvent.func = function(is_click_obj)
			self.is_auto_gather = false
			if self.auto_gather_timer then
				GlobalTimerQuest:CancelQuest(self.auto_gather_timer)
				self.auto_gather_timer = nil
			end
		end

		if self.is_auto_gather then
			if not self.auto_gather_timer and not self.is_click_gather then
				self.auto_gather_timer = GlobalTimerQuest:AddDelayTimer(function()
					self:AutoGather()
					if self.auto_gather_timer then
						GlobalTimerQuest:CancelQuest(self.auto_gather_timer)
						self.auto_gather_timer = nil
					end
				end, 0.1)
			end
		end
	end
end

function MainUIViewReminding:SetDaFuHaoSkill()
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}
	if nil == next(dafuhao_info) then return end

	self.dafuhao_skill_rest_times:SetValue(DaFuHaoData.Instance:GetSkillRestTimes())

	self:SetSkillCDProgress(dafuhao_info)
	self:SetSkillCDTime(dafuhao_info)
end

function MainUIViewReminding:SetSkillCDProgress(dafuhao_info)
	local cd = dafuhao_info.millionaire_last_perform_skill_time - TimeCtrl.Instance:GetServerTime()

	if nil == self.skill_cd_progress_count_down then
		self.skill_cd_progress_count_down = CountDown.Instance:AddCountDown(
			cd, 0.05, function(elapse_time, total_time)
				local progress = (total_time - elapse_time) / total_time
				self.skill_cd_progress:SetValue(progress)

				if progress <= 0 and nil ~= self.skill_cd_progress_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
					self.skill_cd_progress_count_down = nil
				end
			end)
	end
end

function MainUIViewReminding:SetSkillCDTime(dafuhao_info)
	local cd = dafuhao_info.millionaire_last_perform_skill_time - TimeCtrl.Instance:GetServerTime()

	if nil == self.skill_cd_time_count_down then
		self.skill_cd_time:SetValue(DaFuHaoData.Instance:GetSkillCD())

		self.skill_cd_time_count_down = CountDown.Instance:AddCountDown(
			cd, 1.0, function(elapse_time, total_time)
				self.skill_cd_time:SetValue(math.ceil(total_time - elapse_time))

				if math.ceil(total_time - elapse_time) <= 0 and nil ~= self.skill_cd_time_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_time_count_down)
					self.skill_cd_time_count_down = nil
				end
			end)
	end
end

function MainUIViewReminding:ClickFly()
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	self:FlyToPos(MoveCache.scene_id, MoveCache.x, MoveCache.y)
end

function MainUIViewReminding:FlyToPos(scene_id, x, y)
	TaskCtrl.SendFlyByShoe(scene_id, x, y)
end

function MainUIViewReminding:ClickGather()
	GuajiCtrl.Instance:StopGuaji()
	self.is_auto_gather = true
	self.is_click_gather = true
	self:GetDafuhaoGather()
	self:AutoGather()
	self.is_click_gather = false
end

function MainUIViewReminding:AutoGather()
	if self.isOn or not self.is_auto_gather then return end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	for k, v in pairs(self.dafuhao_exp_list) do
		if not AStarFindWay:IsBlock(v.x, v.y) then
			local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
			if distance < target_distance then
				min_x = v.x
				min_y = v.y
				target_distance = distance
				id = v.id
			end
			can_gather = true
		end
	end
	if not can_gather and not DaFuHaoData.Instance:IsGatherTimesLimit() then
		for k, v in pairs(self.dafuhao_gather_list) do
			if not AStarFindWay:IsBlock(v.x, v.y) then
				local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
				if distance < target_distance then
					min_x = v.x
					min_y = v.y
					target_distance = distance
					id = v.id
				end
				can_gather = true
			end
		end
	end

	if not can_gather then
		-- if self.is_auto_gather then
		-- 	print_error("当前范围内无大富豪采集物", self.dafuhao_gather_list[1], "scene_id :", scene_id)
		-- end
		if DaFuHaoData.Instance:IsGatherTimesLimit() then
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.DaFuHaoNoBox)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.DaFuHaoBoxFlush)
		end
		return
	end

	target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
end

-- 检测范围
function MainUIViewReminding:CheckRange(x, y, range)
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	return math.floor((x - self_x) * (x - self_x)) + math.floor((y - self_y) * (y - self_y)) <= range * range
end

-- 使用冰冻技能
function MainUIViewReminding:OnClickBingDongSkill()
	self.is_auto_gather = false
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	local flush_time = dafuhao_info.millionaire_last_perform_skill_time or 0
	local cd = flush_time - TimeCtrl.Instance:GetServerTime()

	-- 技能CD中
	if cd > 0 or nil ~= self.skill_cd_progress_count_down or nil ~= self.skill_cd_time_count_down then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SkillCD)
		return
	end

	if DaFuHaoData.Instance:GetSkillRestTimes() <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.NoUseSkillTimes)
		return
	end

	-- local obj_id = GuajiCache.target_obj_id
	-- if obj_id < 0 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Society.SelectName)
	-- 	return
	-- end

	-- local obj = Scene.Instance:GetRoleByObjId(obj_id)
	local obj = GuajiCtrl.Instance:SelectFriend()
	if nil == obj then
		TipsCtrl.Instance:ShowSystemMsg(Language.Fight.NoRoleTarget)
		return
	end

	local pos_x, pos_y = obj:GetLogicPos()
	-- local my_x, my_y = Scene.Instance:GetMainRole():GetLogicPos()
	-- local distance = GameMath.GetDistance(my_x, my_y, pos_x, pos_y, false)
	local skill_dis = DaFuHaoData.Instance:GetSkillDistance()

	if not self:CheckRange(pos_x, pos_y, skill_dis) then
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Role.AttackDistanceFar)
		local scene_id = Scene.Instance:GetSceneId()
		MoveCache.end_type = MoveEndType.UseBingDongSkill
		GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y, skill_dis - 1, 0)
		return
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	scene_logic:UseBingDongSkill()
end

function MainUIViewReminding:AutoGatherTwo()
	if self.isOn or not self.is_shengdi_auto_gather then return end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	for k, v in pairs(self.shengdi_fuben_gather_list) do
		if not AStarFindWay:IsBlock(v.x, v.y) then
			local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
			if distance < target_distance then
				min_x = v.x
				min_y = v.y
				target_distance = distance
				id = v.id
			end
			can_gather = true
		end
	end
	if not can_gather then
		return
	end

	target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
end

function MainUIViewReminding:SetHuDunGray(state)
	if self.gray_dun then
		self.gray_dun:SetValue(state)
	end
end

function MainUIViewReminding:FlushFirstCharge()
	if self.has_first_charge then
		local is_first = DailyChargeData.Instance:HasFirstRecharge()
		self.has_first_charge:SetValue(is_first)
	end
end

function MainUIViewReminding:GetShengDiFuBenGather()
	self.shengdi_fuben_gather_list = {}
	local cfg = MarriageData.Instance:GetGatherCfg() or {}
	for k, v in pairs(cfg) do
		for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
			if j:GetGatherId() == v.gather_id then
				local pos_x, pos_y = j:GetLogicPos()
				self.shengdi_fuben_gather_list[#self.shengdi_fuben_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
			end
		end
	end
end

function MainUIViewReminding:SetGatherBtnStateTwo(gather_id)
		self:GetShengDiFuBenGather()

		if MarriageData.Instance:IsGatherTimesLimit() then
			self.is_shengdi_auto_gather = false
		end
		ShengDiFuBenAutoGatherEvent.func = function(is_click_obj)
			self.is_shengdi_auto_gather = false
			if self.shengdi_auto_gather_timer then
				GlobalTimerQuest:CancelQuest(self.shengdi_auto_gather_timer)
				self.shengdi_auto_gather_timer = nil
			end
		end
		if self.is_shengdi_auto_gather then
			if not self.shengdi_auto_gather_timer and not self.is_click_gather then
				self.shengdi_auto_gather_timer = GlobalTimerQuest:AddDelayTimer(function()
					self:AutoGatherTwo()
					if self.shengdi_auto_gather_timer then
						GlobalTimerQuest:CancelQuest(self.shengdi_auto_gather_timer)
						self.shengdi_auto_gather_timer = nil
					end
				end, 0.1)
			end
		end
	-- end
end