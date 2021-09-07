SkyMoneyFBInfoView = SkyMoneyFBInfoView or BaseClass(BaseView)

local COLLECT_TASK = 1
local KILL_TASK = 2
local MAX_TASK_NUM = 10

local MAX_BIG_QIANDUODUO_NUM = 1

SkyMoneyAutoTaskEvent = {
	CancelHightLightFunc = nil,
}

function SkyMoneyFBInfoView:__init()
	self.ui_config = {"uis/views/skymoney", "SkyMoneyFBInFoView"}
	self.cur_task_num = nil
	-- self.item_list = {}
	self.task_item_list = {}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true

	-- self.global_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
	-- 	BindTool.Bind(self.OnClickTaskList, self))

	-- self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
	-- 	BindTool.Bind(self.OnStopGather, self))

	self.cur_gather_id = -1

	self.is_auto_gather = false
	self.is_click_auto_task = true
	self.is_safe_area_adapter = true
end

function SkyMoneyFBInfoView:__delete()
	self.cur_task_type = nil
	self.cur_task_cfg = nil
end

function SkyMoneyFBInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.task_item_list) do
		v:DeleteMe()
	end
	self.task_item_list = {}

	-- 清理变量和对象
	self.scene_name = nil
	self.big_money_rest_num = nil
	self.rest_num = nil
	self.cur_task_num = nil
	self.max_task_num = nil
	self.had_kill_num = nil
	self.need_kill_num = nil
	self.had_collect_num = nil
	self.need_collect_num = nil
	self.monster_name = nil
	self.collect_prop_name = nil
	self.cur_get_gold = nil
	self.cur_achieve_task_num = nil
	self.next_achieve_task_num = nil
	self.do_task_btn_text = nil
	self.show_kill_task = nil
	self.show_collect_task = nil
	self.show_complete = nil
	self.show_flush_time = nil
	self.show_cur_qianduoduo_num = nil
	self.show_big_flush_time = nil
	self.show_big_rest_num = nil
	self.show_arrow = nil
	self.show_hight_light = nil
	self.ShowPanel = nil
	self.MaxAchieveTaskNum = nil
	self.task_item_list = nil
	self.do_task_btn = nil
end

function SkyMoneyFBInfoView:CloseCallBack()
	self.cur_task_type = nil
	self.cur_task_cfg = nil
	self.cur_task_id = nil
	self.cur_param_value = nil
	self.gather_obj_id = 0

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.star_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.star_gather_event)
		self.star_gather_event = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.money_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.money_count_down)
		self.money_count_down = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	-- for k,v in pairs(self.item_list) do
	-- 	v:DeleteMe()
	-- end
end

function SkyMoneyFBInfoView:OpenCallBack()
	if self.global_event == nil then
		self.global_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
			BindTool.Bind(self.OnStopGather, self))
	end

	self.star_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))

	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBig, self), 2)
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.FightSmallQianDuoDuo, self))

	self.is_click_auto_task = true

	self:Flush()
end

function SkyMoneyFBInfoView:LoadCallBack()
	-- self:ListenEvent("OnClickExit", BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClickTaskList", BindTool.Bind(self.OnClickTaskList, self))
	self:ListenEvent("OnClickBig", BindTool.Bind(self.OnClickBig, self))
	-- self:ListenEvent("OnClicExplain", BindTool.Bind(self.OnClicExplain, self))
	-- self:ListenEvent("CloseHelpTip", BindTool.Bind(self.CloseHelpTip, self))

	self.scene_name = self:FindVariable("FBName")
	-- self.cur_hour = self:FindVariable("CurHour")
	-- self.cur_min = self:FindVariable("CurMin")
	-- self.cur_sec = self:FindVariable("CurSec")
	-- self.color = self:FindVariable("Color")
	-- self.flush_time_hour = self:FindVariable("FlushTimeHour")
	-- self.flush_time_min = self:FindVariable("FlushTimeMin")
	-- self.flush_time_sec = self:FindVariable("FlushTimeSec")
	self.big_money_rest_num = self:FindVariable("BigRestNum")
	self.rest_num = self:FindVariable("RestNum")	--剩余钱多多数量
	self.cur_task_num = self:FindVariable("CurTaskNum")	--当前完成任务数量
	self.max_task_num = self:FindVariable("MaxTaskNum")
	self.had_kill_num = self:FindVariable("HadKillNum")	--当前击杀怪物
	self.need_kill_num = self:FindVariable("NeedKillNum")
	self.had_collect_num = self:FindVariable("HadCollectNum")
	self.need_collect_num = self:FindVariable("NeedCollectNum")
	self.monster_name = self:FindVariable("MonsterName")
	self.collect_prop_name = self:FindVariable("CollectPropName")
	self.cur_get_gold = self:FindVariable("CurGoldNum")
	self.cur_achieve_task_num = self:FindVariable("CurAchieveTaskNum")
	self.next_achieve_task_num = self:FindVariable("NextAchieveTaskNum")
	self.do_task_btn_text = self:FindVariable("DoTaskBtnText")

	self.show_kill_task = self:FindVariable("ShowKillTask")
	self.show_collect_task = self:FindVariable("ShowCollectTask")
	self.show_complete = self:FindVariable("ShowComplete")
	self.show_flush_time = self:FindVariable("ShowFlushTime")
	self.show_cur_qianduoduo_num = self:FindVariable("ShowCurQianduoduoNum")
	self.show_big_flush_time = self:FindVariable("ShowBigFlushTime")
	self.show_big_rest_num = self:FindVariable("ShowBigCurNum")
	self.show_arrow = self:FindVariable("ShowArrow")
	self.show_hight_light = self:FindVariable("ShowHightLight")

	-- self.show_help_tip = self:FindVariable("ShowHelpTip")

	self.ShowPanel = self:FindVariable("ShowPanel")
	self.MaxAchieveTaskNum = self:FindVariable("MaxAchieveTaskNum")
	-- self.item_list = {}
	self.task_item_list = {}
	for i=1,3 do
		-- self.item_list[i] = ItemCell.New(self:FindObj("item"..i))
		self.task_item_list[i] = ItemCell.New(self:FindObj("TaskItem"..i))
	end
	self.do_task_btn = self:FindObj("DoTaskBtn")
	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	end
end

-- 去找小钱多多
function SkyMoneyFBInfoView:FightSmallQianDuoDuo()
	local qianduoduo_cfg = SkyMoneyData.Instance:GetSkyMoneyCfg().qianduoduo[1]
	local x, y = self:GetMonsterPos(qianduoduo_cfg.qingduoduo_id)
	if x and y then
		self:MoveToPosOperateFight(qianduoduo_cfg.qingduoduo_id, x, y)
	end
end

-- 获取打怪的位置
function SkyMoneyFBInfoView:GetMonsterPos(moster_id)
	local target_distance = 1000 * 1000
	local target_x = nil
	local target_y = nil
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local obj_move_info_list = Scene.Instance:GetObjMoveInfoList()
	local monster_list = Scene.Instance:GetMonsterList()


	for k, v in pairs(monster_list) do
		local vo = v:GetVo()
		if BaseSceneLogic.IsAttackMonster(vo.monster_id) and vo.monster_id == moster_id and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	if nil ~= target_x and nil ~= target_y then
		return target_x, target_y
	end

	for k, v in pairs(obj_move_info_list) do
		local vo = v:GetVo()
		if vo.obj_type == SceneObjType.Monster and BaseSceneLogic.IsAttackMonster(vo.type_special_id)
		and vo.type_special_id == moster_id and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	return target_x, target_y
end

function SkyMoneyFBInfoView:MoveToPosOperateFight(monster_id, x, y)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	self.show_hight_light:SetValue(false)
	self.is_auto_gather = false
	self.gather_obj_id = 0
	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()
	local curr_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id)
	if nil == curr_task_cfg or sky_money_info.curr_task_param >= curr_task_cfg.param_count then
		self.show_arrow:SetValue(false)
	else
		self.show_arrow:SetValue(true)
	end
	self.is_click_auto_task = false

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.param1 = monster_id
	GuajiCache.monster_id = monster_id
	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
end

-- 去找大钱多多
function SkyMoneyFBInfoView:OnClickBig()
	local qianduoduo_cfg = SkyMoneyData.Instance:GetSkyMoneyCfg().big_qianduoduo[1]
	local x, y = self:GetMonsterPos(qianduoduo_cfg.bigqian_id)
	if x and y then
		self:MoveToPosOperateFight(qianduoduo_cfg.bigqian_id, x, y)
	end
end

function SkyMoneyFBInfoView:OnStopGather(role_obj_id)
	local main_role = Scene.Instance:GetMainRole()
	local obj_id = main_role:GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	-- if self.is_auto_gather and not main_role:IsMove() then
	-- 	self:AutoDoTask()
	-- end
	self.is_auto_gather = false
end

function SkyMoneyFBInfoView:OnObjDelete(obj)
	local main_role = Scene.Instance:GetMainRole()

	if obj and obj:IsGather() and obj:GetGatherId() == self.cur_gather_id and self.is_auto_gather and self.gather_obj_id == obj:GetObjId() then
		self.is_auto_gather = false
		GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.2)
	end
end

function SkyMoneyFBInfoView:OnStartGather(role_obj_id, gather_obj_id)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end

	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)
	local gather_id = gather_obj and gather_obj:GetGatherId() or 0

	if self.cur_gather_id == gather_id then
		self.is_auto_gather = true
		self.gather_obj_id = gather_obj_id
	end
end

function SkyMoneyFBInfoView:AutoDoTask()
	if not self.is_click_auto_task then
		return
	end

	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()
	local curr_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id)
	if nil == curr_task_cfg or sky_money_info.curr_task_param >= curr_task_cfg.param_count then
		self.show_hight_light:SetValue(false)
		SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
		self.show_arrow:SetValue(false)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
	local scene_gather_list = {}

	local x, y, id = 0, 0, 0
	local end_type = MoveEndType.GatherById
	local target = {}
	local list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if self.cur_task_type == KILL_TASK then
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.FightByMonsterId
		-- GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	end

	local gather_list = SkyMoneyData.Instance:GetSceneGatherListById(self.cur_task_cfg.param_id)

	list = self.cur_task_type ~= KILL_TASK and (next(gather_list) and gather_list or list) or list

	for k, v in pairs(list) do
		if self.cur_task_cfg ~= nil and self.cur_task_cfg.param_id == v.id then
			if not AStarFindWay:IsBlock(v.x, v.y) then
				local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
				if distance < target_distance then
					x = v.x
					y = v.y
					target_distance = distance
					id = v.id
				end
			end
		end
	end

	target = {scene = scene_id, x = x, y = y, id = id}
	MoveCache.end_type = end_type
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCache.monster_id = target.id

	self.cur_gather_id = target.id
	self.show_hight_light:SetValue(true)
	self.show_arrow:SetValue(false)

	local click_call_back = function()
		self.show_hight_light:SetValue(false)
		self.show_arrow:SetValue(true)
	end

	-- TipsCtrl.Instance:SetStandbyMaskClickCallBack(click_call_back)
	-- TipsCtrl.Instance:ShowOrHideStandbyMaskView(true)
	SkyMoneyAutoTaskEvent.CancelHightLightFunc = function()
		self.show_hight_light:SetValue(false)
		self.is_auto_gather = false
		self.gather_obj_id = 0
		self.show_arrow:SetValue(true)
		self.is_click_auto_task = false
	end
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
end

function SkyMoneyFBInfoView:OnClickTaskList()
	self.is_click_auto_task = true
	self:AutoDoTask()
end

function SkyMoneyFBInfoView:SetInfo()
	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()

	local task_reward_cfg = SkyMoneyData.Instance:GetTaskRewardByCurTaskNum(sky_money_info.has_finish_task_num)
	self.MaxAchieveTaskNum:SetValue(string.format(Language.SkyMoney.SmallReward, task_reward_cfg.complete_task_num))
	if task_reward_cfg.complete_task_num and task_reward_cfg.complete_task_num > sky_money_info.has_finish_task_num then
		self.cur_achieve_task_num:SetValue(string.format("<color=#ff0000>%s</color>", sky_money_info.has_finish_task_num))
	else
		self.cur_achieve_task_num:SetValue(sky_money_info.has_finish_task_num)
		self.MaxAchieveTaskNum:SetValue(Language.SkyMoney.FinishTask)
	end
	self.next_achieve_task_num:SetValue(task_reward_cfg.complete_task_num)

	-- for k, v in pairs(self.item_list) do
	-- 	v:SetActive(nil ~= task_reward_cfg["reward_item"..k] and task_reward_cfg["reward_item"..k].item_id and task_reward_cfg["reward_item"..k].item_id > 0)
	-- 	if task_reward_cfg["reward_item"..k] then
	-- 		v:SetData(task_reward_cfg["reward_item"..k])
	-- 	end
	-- end

	local cur_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id) or {}
	self.cur_task_cfg = cur_task_cfg
	local config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.cur_task_type = cur_task_cfg.task_type

	local is_set_exp = false
	for k, v in pairs(self.task_item_list) do
		v:SetActive(true and sky_money_info.curr_task_id >= 0)
		if cur_task_cfg.reward and cur_task_cfg.reward[k - 1] then
			v:SetData(cur_task_cfg.reward[k - 1])
		else
			v:SetActive(not is_set_exp)
			if not is_set_exp then
				v:SetData(SkyMoneyData.Instance:GetRewardExp())
				is_set_exp = true
			end
		end
	end
	MainUICtrl.Instance:SetViewState(false)

	self.scene_name:SetValue(Scene.Instance:GetSceneName())

	if self.cur_task_id ~= sky_money_info.curr_task_id then
		self.cur_task_id = sky_money_info.curr_task_id
		self:AutoDoTask()
	end

	local small_diff_time = 0
	if sky_money_info.small_money_flush_time > 0 then
		small_diff_time = math.floor(math.max(sky_money_info.small_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0))
	end
	local big_diff_time = 0
	if sky_money_info.big_money_flush_time > 0 then
		big_diff_time = math.floor(math.max(sky_money_info.big_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0))
	end

	local qianduoduo_id = SkyMoneyData.Instance:GetQianDuoDuoId()
	local big_qianduoduo_id = SkyMoneyData.Instance:GetQianDuoDuoId(true)

	FuBenCtrl.Instance:SetMonsterInfo(qianduoduo_id)
	FuBenCtrl.Instance:SetMonsterInfo(big_qianduoduo_id, 2)
	FuBenCtrl.Instance:SetSkyMoneyTextState(true)

	local small_flush_text = sky_money_info.cur_qianduoduo_num .. "/" .. SkyMoneyData.Instance:GetQianDuoDuoMaxNum()
	local big_flush_text = sky_money_info.cur_bigqianduoduo_num .. "/" .. MAX_BIG_QIANDUODUO_NUM
	local show_monster_had_flush_1 = sky_money_info.cur_qianduoduo_num > 0
	local show_monster_had_flush_2 = sky_money_info.cur_bigqianduoduo_num > 0
	local show_monster_1 = sky_money_info.cur_qianduoduo_num > 0 or small_diff_time > 0
	local show_monster_2 = sky_money_info.cur_bigqianduoduo_num > 0 or (big_diff_time > 0 and small_diff_time <= 0)

	FuBenCtrl.Instance:SetMonsterDiffTime(small_diff_time)
	FuBenCtrl.Instance:SetMonsterDiffTime(big_diff_time, 2)

	FuBenCtrl.Instance:SetMonsterIconState(show_monster_1)
	FuBenCtrl.Instance:SetMonsterIconState(show_monster_2, 2)

	FuBenCtrl.Instance:ShowMonsterHadFlush(show_monster_had_flush_1, small_flush_text)
	FuBenCtrl.Instance:ShowMonsterHadFlush(show_monster_had_flush_2, big_flush_text, 2)

	-- self.rest_num:SetValue(sky_money_info.cur_qianduoduo_num)
	-- self.big_money_rest_num:SetValue(sky_money_info.cur_bigqianduoduo_num)
	-- self.show_cur_qianduoduo_num:SetValue(sky_money_info.cur_qianduoduo_num > 0)
	-- self.show_big_rest_num:SetValue(sky_money_info.cur_bigqianduoduo_num > 0)
	-- self.show_flush_time:SetValue(small_diff_time > 0 and big_diff_time > small_diff_time or big_diff_time == 0)
	-- self.show_big_flush_time:SetValue(math.abs(big_diff_time - small_diff_time) <= 2 and big_diff_time > 0)
	-- if sky_money_info.small_money_flush_time - TimeCtrl.Instance:GetServerTime() <= 0 then
	-- 	self.show_big_flush_time:SetValue(sky_money_info.big_money_flush_time - TimeCtrl.Instance:GetServerTime() > 0)
	-- else
	-- 	self.show_big_flush_time:SetValue(false)
	-- end

	self.cur_get_gold:SetValue(sky_money_info.get_total_gold)
	self.cur_task_num:SetValue(sky_money_info.has_finish_task_num)
	self.max_task_num:SetValue(MAX_TASK_NUM)

	if sky_money_info.has_finish_task_num == GameEnum.TIANJIANGCAIBAO_TASK_MAX then
		self.show_complete:SetValue(true)
		self.show_kill_task:SetValue(false)
		self.show_collect_task:SetValue(false)
		self.do_task_btn_text:SetValue(Language.Common.CompleteTask)
		self.do_task_btn.button.interactable = false
		self.show_arrow:SetValue(false)
		SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
		self.show_hight_light:SetValue(false)
	else
		self.show_kill_task:SetValue(cur_task_cfg.task_type == 2)
		self.show_collect_task:SetValue(cur_task_cfg.task_type == 1)
		self.show_complete:SetValue(false)
		self.do_task_btn_text:SetValue(Language.Common.ContinueTask)
		if nil ~= self.cur_param_value and self.cur_param_value ~= sky_money_info.curr_task_param and cur_task_cfg.task_type ~= 1 then
			self:AutoDoTask()
		end
	end

	if cur_task_cfg.task_type then
		if cur_task_cfg.task_type == 1 then
			self.collect_prop_name:SetValue(config[cur_task_cfg.param_id].show_name)
			local curr_task_param = sky_money_info.curr_task_param
			if sky_money_info.curr_task_param < cur_task_cfg.param_count then
				curr_task_param = string.format(Language.Mount.ShowRedNum, curr_task_param)
			end
			self.had_collect_num:SetValue(curr_task_param)
			self.need_collect_num:SetValue(cur_task_cfg.param_count)
		else
			self.monster_name:SetValue(monster_cfg[cur_task_cfg.param_id].name)
			local curr_task_param = sky_money_info.curr_task_param
			if sky_money_info.curr_task_param < cur_task_cfg.param_count then
				curr_task_param = string.format(Language.Mount.ShowRedNum, curr_task_param)
			end
			self.had_kill_num:SetValue(curr_task_param)
			self.need_kill_num:SetValue(cur_task_cfg.param_count)
		end
	end
	self.cur_param_value = sky_money_info.curr_task_param
end

-- 设置活动时间
-- function SkyMoneyFBInfoView:SetActivityCountDown()
-- 	local activity_data = ActivityData.Instance:GetActivityStatuByType(SkyMoneyDataId.ID)
-- 	local diff_time = (activity_data and activity_data.next_time or 0) - TimeCtrl.Instance:GetServerTime()
-- 	if self.count_down == nil and diff_time > 0 then
-- 		local function diff_time_func(elapse_time, total_time)
-- 			local left_time = math.floor(diff_time - elapse_time + 0.5)
-- 			if left_time <= 0 then
-- 				if self.count_down ~= nil then
-- 					CountDown.Instance:RemoveCountDown(self.count_down)
-- 					self.count_down = nil
-- 				end
-- 				ViewManager.Instance:Open(ViewName.SkyMoneyRewardView)
-- 				return
-- 			end
-- 			local left_hour = math.floor(left_time / 3600)
-- 			local left_min = math.floor((left_time - left_hour * 3600) / 60)
-- 			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
-- 			self.cur_hour:SetValue(left_hour)
-- 			self.cur_min:SetValue(left_min)
-- 			self.cur_sec:SetValue(left_sec)
-- 		end

-- 		diff_time_func(0, diff_time)
-- 		self.count_down = CountDown.Instance:AddCountDown(
-- 			diff_time, 0.5, diff_time_func)
-- 	end
-- end

-- 设置钱多多刷新时间
-- function SkyMoneyFBInfoView:SetMoneyMonsterCountDown()
-- 	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()
-- 	local diff_time = 0
-- 	if sky_money_info.small_money_flush_time > 0 then
-- 		diff_time = math.max(sky_money_info.small_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0)
-- 	end
-- 	if sky_money_info.big_money_flush_time > 0 then
-- 		local temp_diff_time = math.max(sky_money_info.big_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0)
-- 		if math.abs(diff_time - temp_diff_time) <= 2 then diff_time = temp_diff_time end
-- 	end
-- 	if diff_time > 0 and self.money_count_down then
-- 		CountDown.Instance:RemoveCountDown(self.money_count_down)
-- 		self.money_count_down = nil
-- 	end
-- 	if self.money_count_down == nil and diff_time > 0 then
-- 		local function money_diff_time(elapse_time, total_time)
-- 			local left_time = math.floor(diff_time - elapse_time + 0.5)
-- 			if left_time <= 0 then
-- 				if self.money_count_down ~= nil then
-- 					CountDown.Instance:RemoveCountDown(self.money_count_down)
-- 					self.money_count_down = nil
-- 				end
-- 				return
-- 			end
-- 			local left_hour = math.floor(left_time / 3600)
-- 			local left_min = math.floor((left_time - left_hour * 3600) / 60)
-- 			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
-- 			self.flush_time_hour:SetValue(left_hour)
-- 			self.flush_time_min:SetValue(left_min)
-- 			self.flush_time_sec:SetValue(left_sec)
-- 		end

-- 		money_diff_time(0, diff_time)
-- 		self.money_count_down = CountDown.Instance:AddCountDown(
-- 			diff_time, 0.5, money_diff_time)
-- 	end
-- end

function SkyMoneyFBInfoView:SwitchButtonState(enable)
	self.ShowPanel:SetValue(enable)
end

function SkyMoneyFBInfoView:OnFlush(param_t)
	self:SetInfo()
	-- self:SetActivityCountDown()
	-- self:SetMoneyMonsterCountDown()
end

function SkyMoneyFBInfoView:GetTime(time)
	local index = string.find(time, ":")
	local next_index = string.find(string.sub(time, index + 1, -1), ":")
	if next_index ~= nil then
		return string.sub(time, 1, index - 1), string.sub(string.sub(time, index + 1, -1), 1, next_index -1)
	end
	return string.sub(time, 1, index - 1), string.sub(time, index + 1, -1)
end