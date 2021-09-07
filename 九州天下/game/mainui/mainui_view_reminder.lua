MainUIViewReminding = MainUIViewReminding or BaseClass(BaseRender)

DaFuHaoAutoGatherEvent = {
	func = nil
}
ShengDiFuBenAutoGatherEvent = {
	func = nil
}
MainUIViewReminding.SHOW_SHOT_LEVEL = 88
local EFFECT_CD = 1
local UILayer = GameObject.Find("GameRoot/UILayer").transform

function MainUIViewReminding:__init()
	self.gua_ji = self:FindObj("GuaJi")
	self.xun_lu = self:FindObj("XunLu")
	self.gather = self:FindObj("GatherBar")
	self.show_shuangxiu = self:FindVariable("ShowShuangXiu")
	self.be_atk_icon = MainBeAtkIcon.New(self:FindObj("BeAtkSmallParts"))
	self.gather_bar = self.gather:GetComponent(typeof(UnityEngine.UI.Slider))
	self.xunlu_act = false
	self.is_auto_gather = false
	self.is_gather_dafuhao = false
	self.is_shengdi_auto_gather = false
	self.atk_icon_show_time = 0
	self.effect_cd = 0

	self.gather_text = self:FindVariable("Gather")
	self.show_answer_button = self:FindVariable("ShowAnswerButton")
	self.show_gather_btn = self:FindVariable("ShowGatherBtn")
	self.gray_dun = self:FindVariable("GrayDun")
	self.gray_jiu = self:FindVariable("GrayJiu")
	self.gray_jiu_text = self:FindVariable("GrayJiuCDText")
	self.shot_shot = self:FindVariable("ShowShot")
	
	self.worship_cdmask = self:FindVariable("CityCombatWorshipCDMask")
	self.worship_cdmask:SetValue(0)
	self.show_worship_cdmask = self:FindVariable("ShowCityCombatWorshipCDMask")
	self.worship_cdtext = self:FindVariable("CityCombatWorshipCDText")
	self.worship_cdtext:SetValue(0)
	self.show_worship_cdtext = self:FindVariable("ShowCityCombatWorshipCDText")
	self.show_worship_cdtext:SetValue(false)
	self.city_combat_progress = self:FindObj("CityCombatProgress")
	self.city_combat_progress_slider = self.city_combat_progress:GetComponent(typeof(UnityEngine.UI.Slider))

	self.gb_worship_cdmask = self:FindVariable("GuildBattleWorshipCDMask")
	self.gb_worship_cdmask:SetValue(0)
	self.gb_show_worship_cdmask = self:FindVariable("ShowGuildBattleWorshipCDMask")
	self.gb_worship_cdtext = self:FindVariable("GuildBattleWorshipCDText")
	self.gb_worship_cdtext:SetValue(0)
	self.gb_show_worship_cdtext = self:FindVariable("ShowGuildBattleWorshipCDText")
	self.gb_show_worship_cdtext:SetValue(false)
	self.gb_progress = self:FindObj("GuildBattleWorshipProgress")
	self.gb_progress_slider = self.gb_progress:GetComponent(typeof(UnityEngine.UI.Slider))

	self.show_stun = self:FindVariable("ShowBtnStun")
	self.show_lianfu_text = self:FindVariable("ShowLianFu")
	self.show_lianfu_text:SetValue(false)
	self.carry_bag_end_time = self:FindVariable("CarryBagEndTime")

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

	self:BindGlobalEvent(ObjectEventType.LEAVE_SCENE,
		BindTool.Bind(self.OnStarLeaveScene, self))	

	self:BindGlobalEvent(OtherEventType.SHENGDI_FUBEN_INFO_CHANGE,
		BindTool.Bind(self.SetGatherBtnStateTwo, self))

	self:BindGlobalEvent(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObj, self))

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityCallBack, self)) --self.activity_call_back =

	self:ListenEvent("OnClickFollow", BindTool.Bind(self.OnClickFollow, self))
	self:ListenEvent("ClickGather", BindTool.Bind(self.ClickGather, self))
	self:ListenEvent("ClickFly", BindTool.Bind(self.ClickFly, self))
	self:ListenEvent("OnClickWorshipCityCombat", BindTool.Bind(self.OnClickWorshipHanlder, self))
	self:ListenEvent("OnClickWorshipGuildBattle", BindTool.Bind(self.OnClickGBWorshipHanlder, self))
	self:ListenEvent("OnClickBtnStun", BindTool.Bind(self.OnClickBtnStun, self))
	self:ListenEvent("OnClickBtnGoBack", BindTool.Bind(self.OnClickBtnGoBack, self))

	self.is_can_gather = true
	self.dafuhao_gather_list = {}
	self.show_answer_button:SetValue(false)
	self.is_leave_scene = false
end

-- 自动寻路状态改变
local scene_cfg = nil
function MainUIViewReminding:OnMainRoleAutoXunluChange(auto)
	local main_role = Scene.Instance:GetMainRole()
	if main_role ~= nil and main_role:IsMultiMountPartner() then
		self.xun_lu:SetActive(false)
		return
	end

	scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if 0 == scene_cfg.is_show_navigation then
		auto = false
	end
	if PlayerData.Instance.role_vo.husong_taskid > 0 then
		auto = false
	end
	if self.xunlu_act == auto then return end
	self.xunlu_act = auto
	-- if auto == true and SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_USE_FLY_SHOE) then
	-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	if VipPower.Instance:GetParam(VipPowerId.scene_fly) > 0 and MoveCache.cant_fly == false then
	-- 		self:ClickFly()
	-- 	else
	-- 		local shot_id = MapData.Instance:GetFlyShoeId()
	-- 		local num = ItemData.Instance:GetItemNumInBagById(shot_id)
	-- 		if num > 0 and MoveCache.cant_fly == false then
	-- 			self:ClickFly()
	-- 		else
	-- 			local buy_type = ShopData.Instance:CheckCanBuyItem(shot_id)

	-- 			if buy_type and buy_type == SHOP_BIND_TYPE.BIND and MoveCache.cant_fly == false then
	-- 				TaskCtrl.SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
	-- 			elseif buy_type and buy_type == SHOP_BIND_TYPE.NO_BIND and MoveCache.cant_fly == false then
	-- 				TaskCtrl.SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
	-- 			end
	-- 		end
	-- 	end
	-- end
	self.xun_lu:SetActive(auto and not self.pc_view_open)
	self:CheckShowShot()
end

-- 返回寻路状态
function MainUIViewReminding:GetIsXunLuState()
	return self.xunlu_act and not self.pc_view_open
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
	if self.xun_lu and self.xun_lu.gameObject.activeInHierarchy then
		if GuajiCtrl.Instance:CheakCanFly(true) then
			if PlayerData.Instance.role_vo.level < MainUIViewReminding.SHOW_SHOT_LEVEL or Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
				self.shot_shot:SetValue(false)
			else
				self.shot_shot:SetValue(true)
			end
			if MoveCache.cant_fly == true then
				self.shot_shot:SetValue(false)
			end
		else
			self.shot_shot:SetValue(false)
		end
	end
end

function MainUIViewReminding:__delete()
	self.is_auto_gather = nil

	if self.be_atk_icon ~= nil then
		self.be_atk_icon:DeleteMe()
	end

	-- GlobalEventSystem:UnBind(self.obj_del_event)
	-- self.obj_del_event = nil

	-- GlobalEventSystem:UnBind(self.obj_creat)
	-- self.obj_creat = nil

	-- if self.activity_call_back then
	-- 	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
	-- 	self.activity_call_back = nil
	-- end
	
	if self.worship_count_down then
		CountDown.Instance:RemoveCountDown(self.worship_count_down)
		self.worship_count_down = nil
	end
	
	if self.gb_worship_count_down then
		CountDown.Instance:RemoveCountDown(self.gb_worship_count_down)
		self.gb_worship_count_down = nil
	end

	if self.gray_jiu_count_down then
		CountDown.Instance:RemoveCountDown(self.gray_jiu_count_down)
		self.gray_jiu_count_down = nil
	end

	if self.lianfu_countdown then
		CountDown.Instance:RemoveCountDown(self.lianfu_countdown)
		self.lianfu_countdown = nil
	end

	if self.main_role_pos_change_callback then
		GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
		self.main_role_pos_change_callback = nil
	end

	DaFuHaoAutoGatherEvent.func = nil
	ShengDiFuBenAutoGatherEvent.func = nil
end

function MainUIViewReminding:OnSceneLoadQuit()
	self:SetGatherBtnState()
end

function MainUIViewReminding:OnChangeRepair(state)
	if self.show_shuangxiu then
		self.show_shuangxiu:SetValue(state)
	end
end

function MainUIViewReminding:SetBeAtkIconState(role_vo)
	-- 策划要求跨服中不弹
	if IS_ON_CROSSSERVER then
		return
	end
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
		self.gather_id_buff = id
		self.gather_obj_id = gather_obj_id
		local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
		local banzhuan_cfg = NationalWarfareData.Instance:GetBanZhuanOtherCfg()
		if banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT and id == banzhuan_cfg.gather_id then --采集砖头
			local camp_other_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if Scene.Instance:GetSceneId() == camp_other_cfg["scene_id_" .. vo.camp] then
				SysMsgCtrl.Instance:ErrorRemind(Language.NationalWarfare.StealZhuanKuai)
				return
			else
				ViewManager.Instance:Open(ViewName.BanZhuanColorView)
			end
		end

		if Scene.Instance:GetSceneType() == SceneType.KfMining then
			KuaFuMiningCtrl.Instance:SetGatherVisable(true)
			return
		end
		
		local cfg = ConfigManager.Instance:GetAutoConfig("millionaire_auto").gather_box_cfg or {}
		for k, v in pairs(cfg) do
			if v.gather_id == id then
				self.is_gather_dafuhao = true
				self.is_auto_gather = true
				break
			else
				self.is_gather_dafuhao = false
				self.is_auto_gather = false
			end
		end
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
function MainUIViewReminding:OnStopGather(role_obj_id, stop_reason)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.gather:SetActive(false)

	local scene_type = Scene.Instance:GetSceneType()
	if stop_reason == 1 and scene_type == SceneType.CrossGuildBattle then
		TipsCtrl.Instance:ShowSystemMsg(Language.KuafuGuildBattle.GatherSucceed)
	end

	if scene_type == SceneType.KfMining then
		KuaFuMiningCtrl.Instance:StopMining()
	end
	-- self.xun_lu:SetActive(self.xunlu_act or false)
	self.gather_bar.value = 0
	self.isOn = false
	if self.tweener then
		self.tweener:Pause()
	end

	self.is_leave_scene = false
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
	local cfg = DaFuHaoData.Instance:GetDaFuHaoCfg().gather_box_cfg or {}
	for k, v in pairs(cfg) do
		for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
			if j:GetGatherId() == v.gather_id then
				local pos_x, pos_y = j:GetLogicPos()
				if not AStarFindWay:IsBlock(pos_x, pos_y) then
					self.dafuhao_gather_list[#self.dafuhao_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
				end
			end
		end
	end 
end

function MainUIViewReminding:SetGatherBtnState(gather_id) 
	if self.show_gather_btn then

		if not DaFuHaoData.Instance:IsShowDaFuHao() then
			self.show_gather_btn:SetValue(false)
			return
		end
		if not (DaFuHaoData.Instance:GetIsCanGather()) then
			self.show_gather_btn:SetValue(false)
			return
		end
		if YunbiaoData.Instance:GetIsHuShong() then
			self.show_gather_btn:SetValue(false)
			return
		end
		local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}

		self:GetDafuhaoGather()

		self.show_gather_btn:SetValue(nil ~= next(self.dafuhao_gather_list))

		if dafuhao_info.gather_total_times == 5 or dafuhao_info.gather_total_times == 10 or dafuhao_info.gather_total_times == 15 then
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

function MainUIViewReminding:ClickFly()
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	if not GuajiCtrl.Instance:CheakCanFly() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Map.DontCanFly)
		return
	end
	local shot_id = MapData.Instance:GetFlyShoeId()
	local num = ItemData.Instance:GetItemNumInBagById(shot_id)
	local enough_money = ShopData.Instance:CheckCanBuyItem(shot_id)
	if VipData.Instance:GetIsCanFly(GameVoManager.Instance:GetMainRoleVo().vip_level) or num > 0 then
		Scene.Instance:GetMainRole():ClearAutoMove()
	end
	self:FlyToPos(MoveCache.scene_id, MoveCache.x, MoveCache.y)
end

function MainUIViewReminding:FlyToPos(scene_id, x, y)
	TaskCtrl.SendFlyByShoe(scene_id, x, y)
	-- GuajiCtrl.Instance:MoveToScenePos(scene_id, x, y)
end

function MainUIViewReminding:ClickGather()
	self.is_auto_gather = true
	self.is_click_gather = true
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

	if not can_gather then
		-- if self.is_auto_gather then
		-- 	print_error("当前范围内无大富豪采集物", self.dafuhao_gather_list[1], "scene_id :", scene_id)
		-- end
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

function MainUIViewReminding:SetQiuJiuGray()
	if self.gray_jiu_count_down then
		CountDown.Instance:RemoveCountDown(self.gray_jiu_count_down)
		self.gray_jiu_count_down = nil
	end
	local time = 10
	self.gray_jiu:SetValue(true)
	self.gray_jiu_text:SetValue(time)
	self.gray_jiu_count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.QiuJiuCountDown, self))
end

function MainUIViewReminding:QiuJiuCountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		if self.gray_jiu_count_down then
			CountDown.Instance:RemoveCountDown(self.gray_jiu_count_down)
			self.gray_jiu_count_down = nil
		end
		self.gray_jiu:SetValue(false)
		return
	end
	local left_times = math.ceil(total_time - elapse_time)
	self.gray_jiu_text:SetValue(left_times)
end
----------------------------------------------------------------
-- 攻城战膜拜
-- 点击膜拜按钮事件
function MainUIViewReminding:OnClickWorshipHanlder()
	CityCombatCtrl.Instance:SendGCZWorshipReq()
end

function MainUIViewReminding:SetWorshipCountDown(time)
	self.show_worship_cdmask:SetValue(true)

	if self.worship_count_down then
		CountDown.Instance:RemoveCountDown(self.worship_count_down)
		self.worship_count_down = nil
	end
	self.worship_count_down = CountDown.Instance:AddCountDown(time, 0.1, BindTool.Bind(self.UpdateTime, self))

	local progress_time = 0
	local other_cfg = CityCombatData.Instance:GetOtherConfig()
	if other_cfg then
		progress_time = other_cfg.worship_gather_time or 0
	end
	self:UpdateProgress(progress_time)
end

function MainUIViewReminding:UpdateProgress(progress_time)
	local worship_cfg = CityCombatData.Instance:GetOtherConfig().worship_click_time	
	local city_combat_count = CityCombatData.Instance:GetWorshipClickNum()
	self.city_combat_progress:SetActive(true)

	self.city_combat_progress_slider.value = 0
	if self.progress_tweener then
		self.progress_tweener:Pause()
	end
	self.progress_tweener = self.city_combat_progress_slider:DOValue(1, progress_time, false)
	self.progress_tweener:SetEase(DG.Tweening.Ease.Linear)
	self.progress_tweener:OnComplete(function ()
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.CityCombat.CityCombatCount, worship_cfg - city_combat_count))		
		self.city_combat_progress:SetActive(false)
	end)
end

function MainUIViewReminding:UpdateTime(elapse_time, total_time)
	local rest_of_time = (total_time - elapse_time) / total_time
	self.worship_cdmask:SetValue(rest_of_time)
	if rest_of_time > 0 then
		self.show_worship_cdtext:SetValue(true)
		self.worship_cdtext:SetValue(rest_of_time * 10)
	else
		self.show_worship_cdtext:SetValue(false)
	end
end

function MainUIViewReminding:ShowWorshipCdmask(state)
	if self.show_worship_cdmask then
		self.show_worship_cdmask:SetValue(state)
	end
end

function MainUIViewReminding:GetWorshipCountDown()
	return self.worship_count_down
end

---------------------------------------------------------------
-- 公会争霸膜拜
-- 点击膜拜按钮事件
function MainUIViewReminding:OnClickGBWorshipHanlder()
	GuildFightCtrl.Instance:SendWorshipReq()
end

function MainUIViewReminding:SetGBWorshipCountDown(time)
	self.gb_show_worship_cdmask:SetValue(true)

	if self.gb_worship_count_down then
		CountDown.Instance:RemoveCountDown(self.gb_worship_count_down)
		self.gb_worship_count_down = nil
	end
	self.gb_worship_count_down = CountDown.Instance:AddCountDown(time, 0.1, BindTool.Bind(self.GBUpdateTime, self))

	local progress_time = 0
	local other_cfg = GuildFightData.Instance:GetOtherConfig()
	if other_cfg then
		progress_time = other_cfg.worship_gather_time or 0
	end
	self:GBUpdateProgress(progress_time)
end

function MainUIViewReminding:GBUpdateProgress(progress_time)
	local other_cfg = GuildFightData.Instance:GetConfig().other[1].worship_time
	local GuildFightCount = GuildFightData.Instance:GetWorshipInfo().worship_time
	self.gb_progress:SetActive(true)

	self.gb_progress_slider.value = 0
	if self.gb_progress_tweener then
		self.gb_progress_tweener:Pause()
	end
	self.gb_progress_tweener = self.gb_progress_slider:DOValue(1, progress_time, false)
	self.gb_progress_tweener:SetEase(DG.Tweening.Ease.Linear)

	self.gb_progress_tweener:OnComplete(function ()
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.CityCombat.CityCombatCount, other_cfg - GuildFightCount))				
		self.gb_progress:SetActive(false)
	end)
end

function MainUIViewReminding:GBUpdateTime(elapse_time, total_time) 
	local rest_of_time = (total_time - elapse_time) / total_time
	self.gb_worship_cdmask:SetValue(rest_of_time)
	if rest_of_time > 0 then
		self.gb_show_worship_cdtext:SetValue(true)
		self.gb_worship_cdtext:SetValue(rest_of_time * 10)
	else
		self.gb_show_worship_cdtext:SetValue(false)
	end
end

function MainUIViewReminding:ShowGBWorshipCdmask(state)
	if self.gb_show_worship_cdmask then
		self.gb_show_worship_cdmask:SetValue(state)
	end
end

function MainUIViewReminding:GetGBWorshipCountDown()
	return self.gb_worship_count_down
end

-----------------------------------------------

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


----------------------------------------------------------------
function MainUIViewReminding:OnStarLeaveScene()
	self.gather_id_buff = nil
   	local main_role = Scene.Instance:GetMainRole()
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, main_role:GetObjId())

	self.isOn = true
	self.is_leave_scene = true
	self.gather:SetActive(true)
	self.gather_text:SetValue(Language.Common.IsInLeaveScene)
 
	self:OnSetGatherTime(5.5)
end

function MainUIViewReminding:OnSelectObj(target_obj, select_type)
	if nil ~= target_obj then
		self.target_obj = target_obj
		self.show_stun:SetValue(target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_MALE
			or target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_FEMALE)
		if target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_MALE
			or target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_FEMALE then
			if self.main_role_pos_change_callback == nil then
				self.main_role_pos_change_callback = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnCCWorshipPosChange, self))
			end
		end
		if self.target_obj.effect_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_CROSS_XYCITY_CAPTIVE_BAG then
			self.show_stun:SetValue(false)
			LianFuDailyCtrl.Instance:SendCrossXYCityReq(CROSS_XYCITY_REQ_TYPE.OP_CAPTURE_CAPTIVE, self.target_obj.vo.obj_id)
		end
	end
end

function MainUIViewReminding:OnClickBtnStun()
	if nil ~= self.target_obj then
		LianFuDailyCtrl.Instance:SendCrossXYCityReq(CROSS_XYCITY_REQ_TYPE.OP_HIT_CAPTIVE, self.target_obj.vo.obj_id)
		self.show_stun:SetValue(false)
	end
	if self.main_role_pos_change_callback then
		GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
		self.main_role_pos_change_callback = nil
	end
end

--监听人物距离怪物的距离
function MainUIViewReminding:OnCCWorshipPosChange()
	local x, y = self.target_obj.vo.pos_x,self.target_obj.vo.pos_y
	local main_role = Scene.Instance:GetMainRole()
	local role_pos_x, role_pos_y = main_role:GetLogicPos()
	local distance = GameMath.GetDistance(role_pos_x, role_pos_y, x, y, false)
	if distance > 800 then
		self.show_stun:SetValue(false)
		if self.main_role_pos_change_callback then
			GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
			self.main_role_pos_change_callback = nil
		end
	end
end

function MainUIViewReminding:ChangeLianFuInfoStatus(new_value)
	if self.show_lianfu_text then
		local end_time = KuafuGuildBattleData.Instance:GetEndTime()
		if end_time <= 0 then
			if self.lianfu_countdown then
				CountDown.Instance:RemoveCountDown(self.lianfu_countdown)
				self.lianfu_countdown = nil
			end
			self.show_lianfu_text:SetValue(false)
			return
		end
		local totle_time = end_time - TimeCtrl.Instance:GetServerTime()
		if not self.lianfu_countdown then
			self.lianfu_countdown = CountDown.Instance:AddCountDown(totle_time, 0.1, BindTool.Bind(self.UpdateLianFuTime, self))
		end
		self.show_lianfu_text:SetValue(new_value == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE)
	end
end

function MainUIViewReminding:UpdateLianFuTime(elapse_time, total_time)
	if self.carry_bag_end_time then
		self.carry_bag_end_time:SetValue(string.format(Language.LianFuDaily.EndTime, math.floor(total_time - elapse_time)))
	end
end

function MainUIViewReminding:OnClickBtnGoBack()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(vo.server_group)
	if cfg and cfg.scene_id then
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(cfg.scene_id)
		GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, x, y)
	end
end