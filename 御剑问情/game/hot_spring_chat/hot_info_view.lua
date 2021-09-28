HotInfoView = HotInfoView or BaseClass(BaseView)

function HotInfoView:__init()
	self.ui_config = {"uis/views/chatroom_prefab","HotSpringInfoView"}
	self.view_layer = UiLayer.MainUI
end

function HotInfoView:__delete()

end

function HotInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self:RemoveCountDown()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.show_rank_view = nil
	self.rest_time = nil
	self.right_percent = nil
	self.my_rank = nil
	self.my_exp = nil
	self.scroller = nil
	self.massage_cd = nil
	self.snowball_cd = nil
	self.massage_count = nil
	self.snowball_count = nil
	self.massage_fill_amount = nil
	self.snow_ball_fill_amount = nil
	self.show_follow_btn = nil
	self.show_catch_btn = nil
	self.catch_count = nil
	self.target_obj = nil
end

function HotInfoView:LoadCallBack()
	self.rank_data = {}
	self.target_vo = {}

	self.show_rank_view = self:FindVariable("ShowRankView")
	self.rest_time = self:FindVariable("RestTime")
	self.right_percent = self:FindVariable("RightPercent")
	self.my_rank = self:FindVariable("MyRank")
	self.my_exp = self:FindVariable("MyExp")
	self.massage_cd = self:FindVariable("MassageCD")
	self.snowball_cd = self:FindVariable("SnowBallCD")
	self.massage_count = self:FindVariable("MassageCount")
	self.snowball_count = self:FindVariable("SnowBallCount")
	self.massage_fill_amount = self:FindVariable("MassageFillAmount")
	self.snow_ball_fill_amount = self:FindVariable("SnowBallFillAmount")
	self.show_follow_btn = self:FindVariable("ShowFollowBtn")
	self.show_catch_btn = self:FindVariable("ShowCatchBtn")
	self.catch_count = self:FindVariable("CatchCount")

	self.my_exp:SetValue("")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:ListenEvent("OnClickShuangXiu",
        BindTool.Bind(self.OnClickShuangXiu, self))
	self:ListenEvent("OnClickRank",
        BindTool.Bind(self.OnClickRank, self))
	self:ListenEvent("OnClickThrowSnowBall",
        BindTool.Bind(self.OnClickThrowSnowBall, self))
	self:ListenEvent("OnClickMassage",
        BindTool.Bind(self.OnClickMassage, self))
	self:ListenEvent("OnClickFollow",
        BindTool.Bind(self.OnClickFollow, self))
	self:ListenEvent("OnClickCatch",
        BindTool.Bind(self.OnClickCatch, self))

	self.main_role_arrive = BindTool.Bind(self.OnMainRoleArrive, self)

	local skill_cfg1 = HotStringChatData.Instance:GetSkillCfgByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
	self.massage_cold_down_time = skill_cfg1.cold_down_time or 0
	self.distance1 = skill_cfg1.skill_distance or COMMON_CONSTS.SELECT_OBJ_DISTANCE
	local skill_cfg2 = HotStringChatData.Instance:GetSkillCfgByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL)
	self.snowball_cold_down_time = skill_cfg2.cold_down_time or 0
	self.distance2 = skill_cfg2.skill_distance or COMMON_CONSTS.SELECT_OBJ_DISTANCE
	self:InitScroller()
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSkillCD, self), 0.1)
end

function HotInfoView:OpenCallBack()
	self.eh_move_start = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_START, BindTool.Bind1(self.OnMainRoleMoveStart, self))
	self.obj_delete = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.click_shuang_xiu = GlobalEventSystem:Bind(ObjectEventType.CLICK_SHUANGXIU,
		BindTool.Bind(self.ClickTargetShuangXiu, self))
	self:FlushRankList()
	self:FlushSkillInfo()
	self:FlushCatchInfo()
end

function HotInfoView:CloseCallBack()
	if self.eh_move_start then
		GlobalEventSystem:UnBind(self.eh_move_start)
		self.eh_move_start = nil
	end

	if self.obj_delete then
		GlobalEventSystem:UnBind(self.obj_delete)
		self.obj_delete = nil
	end
	if self.click_shuang_xiu then
		GlobalEventSystem:UnBind(self.click_shuang_xiu)
		self.click_shuang_xiu = nil
	end
end

-- 寻找合适双修的角色
function HotInfoView:FindRole(x, y, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit
	local target_x, target_y, distance = 0, 0, 0
	local can_select = true

	local near_role_list = Scene.Instance:GetRoleList()
	for _, v in pairs(near_role_list) do
		can_select = true
		-- 如果已经有双修对象
		if v.vo.special_param >= 0 and v.vo.special_param < 65535 then
			can_select = false
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(x, y, target_x, target_y, false)
			if not AStarFindWay:IsBlock(target_x, target_y) then
				if distance < target_distance then
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj, target_distance
end

--点击排名面板
function HotInfoView:OnClickRank()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end

--点击双修按钮
function HotInfoView:OnClickShuangXiu()
	-- 自己已经在双修了
	if HotStringChatData.Instance:GetRepairState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.IsRepairs)
		return
	end
	local distance = 0
	local target_obj = nil
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	if nil == self.target_obj then
		target_obj, distance = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
		if not target_obj then
			SysMsgCtrl.Instance:ErrorRemind(Language.HotString.NotReqairPartner)
			return
		end
		self.target_obj = target_obj
		self.target_vo = target_obj.vo
	else
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		distance = u3d.v2Length(delta_pos)
	end

	if distance <= 4 then
		HotStringChatCtrl.Instance:AddPartner(self.target_obj:GetObjId())
	else
		MoveCache.end_type = MoveEndType.FollowObj
		GuajiCtrl.Instance:SetArriveCallBack(self.main_role_arrive)
		MoveCache.param1 = self.target_obj:GetObjId()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
		-- GuajiCtrl.Instance:MoveToObj(self.target_obj)
	end
end

--点击人物设置(取消)双修目标
function HotInfoView:ClickTargetShuangXiu(target_obj, target_vo, click_type)
	if nil == target_obj or nil == target_vo then
		return
	end

	if click_type == "select" then
		self.target_vo = target_vo
		self.target_obj = target_obj
	elseif click_type == "cancel" then
		self.target_vo = {}
		self.target_obj = nil
	end
end

function HotInfoView:SwitchButtonState(enable)
	self.show_rank_view:SetValue(enable)
end

-- 主角开始移动
function HotInfoView:OnMainRoleMoveStart()
	if HotStringChatData.Instance:GetRepairState() then
		HotStringChatCtrl.Instance:DelPartnerReq()
		HotStringChatData.Instance:ClearpartnerId()
		self.target_obj = nil
		self.target_vo = {}
	end
end

-- 主角结束移动
function HotInfoView:OnMainRoleArrive()
	if self.target_obj then
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		local distance = u3d.v2Length(delta_pos)
		if distance <= 4 then
			if HotStringChatData.Instance:GetRepairState() then
				TipsCtrl.Instance:ShowSystemMsg(Language.HotString.TargetIsShuangXiu)
			else
				HotStringChatCtrl.Instance:AddPartner(self.target_vo.obj_id)
			end
			self.target_vo = {}
			self.target_obj = nil
		end
	end
end

function HotInfoView:OnObjDelete(obj)
	if obj == self.target_obj then
		self.target_vo = {}
		self.target_obj = nil
	end
end

function HotInfoView:CloseWindow()
	self:Close()
end

function HotInfoView:FlushRankList()
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		self.my_rank:SetValue(rank_info.self_rank)
		if rank_info.self_rank <= 0 then
			self.my_rank:SetValue(Language.Common.ZanWu)
		end
		if self.scroller.scroller.isActiveAndEnabled then
			self.scroller.scroller:ReloadData(0)
		end
	end

end

function HotInfoView:FlushRoleInfo()
	local role_info = HotStringChatData.Instance:GetRoleAnswerInfo()
	if role_info then
		local total_count = role_info.question_right_count + role_info.question_wrong_count
		local right_percent = 0
		if total_count ~= 0 then
			right_percent = math.floor((role_info.question_right_count / total_count) * 100)
		end
		self.right_percent:SetValue(right_percent)
		self:FlushSkillInfo()
		self:FlushCatchInfo()
	end
end

function HotInfoView:FlushJingYan()
	local jing_yan = HotStringChatData.Instance:GetJingYan()
	self.my_exp:SetValue(CommonDataManager.ConverMoney(jing_yan))
end

function HotInfoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "jing_yan" then
			self:FlushJingYan()
		elseif k == "rank" then
			self:FlushRankList()
		elseif k == "question" then
			self:CheckIsAnswering()
		elseif k == "role_info" then
			self:FlushRoleInfo()
		elseif k == "skill" then
			self:FlushSkillInfo()
		end
	end
	self:SetCountDown()
end

-- 检查是否正在答题中
function HotInfoView:CheckIsAnswering()
	local flag = false
	local question_info = HotStringChatData.Instance:GetQuestionInfo()
    if question_info then
	    local current_count = question_info.broadcast_question_total or 0
	    local total_question_count = HotStringChatData.Instance:GetTotalQuestionCount() or 0
	    if current_count > 0 and current_count < total_question_count then
	    	flag = true
	    elseif current_count == total_question_count then
	    	local rest_time = question_info.curr_question_end_time - TimeCtrl.Instance:GetServerTime()
	    	if rest_time > 0 then
	    		flag = true
	    	end
	    end
	end
	self.show_follow_btn:SetValue(flag)
end

function HotInfoView:SetCountDown()
	if not self.count_down then
		self.rest_time:SetValue("00:00")
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_HOT_SPRING) or {}
		local end_time = activity_info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		if total_time > 0 then
			self:DiffTime(0, total_time)
			self.count_down = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.DiffTime, self))
		end
	end
end

function HotInfoView:DiffTime(elapse_time, total_time)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond(left_time, 2)
	local start_time = HotStringChatData.Instance:GetOtherCfg().refresh_gather_start_time_min or 0
	local flag = (start_time * 60) > left_time
	-- 根据配置时间显示采集按钮
	if self.show_catch_btn then
		self.show_catch_btn:SetValue(flag)
	end
	self.rest_time:SetValue(the_time_text)
	if left_time <= 0 then
		self:RemoveCountDown()
	end
end

function HotInfoView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function HotInfoView:OnClickMassage()
	if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SkillsCountNotEnough)
		return
	end
	local target_obj, distance = self:FindSkillRole()
	if target_obj then
		if distance <= self.distance1 then
			HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
		else
			MoveCache.end_type = MoveEndType.FollowObj
			GuajiCtrl.Instance:SetArriveCallBack(function ()
				GuajiCtrl.Instance:StopGuaji()
				HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
			end)
			MoveCache.param1 = target_obj:GetObjId()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
		end
	end
end

function HotInfoView:OnClickThrowSnowBall()
	if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SkillsCountNotEnough)
		return
	end
	local target_obj, distance = self:FindSkillRole()
	if target_obj then
		if distance <= self.distance2 then
			HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SnowBallNeedClose)
		end
	end
end

-- 寻找可以施放技能的角色
function HotInfoView:FindSkillRole()
	-- 自己已经在双修了
	if HotStringChatData.Instance:GetRepairState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.CannotUseSkill)
		return
	end
	local target_obj = nil
	local distance = 0
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	if nil == self.target_obj then
		target_obj, distance = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
		if not target_obj then
			SysMsgCtrl.Instance:ErrorRemind(Language.Answer.NoSelect)
			return
		end
		self.target_obj = target_obj
		self.target_vo = target_obj.vo
	else
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		distance = u3d.v2Length(delta_pos)
	end
	return self.target_obj, distance
end

function HotInfoView:UpdateSkillCD()
	local skill_info = HotStringChatData.Instance:GetSkillInfo()
	if skill_info then
		if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) > 0 then
			local time = skill_info.skill_1_can_perform_time - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				self.massage_cd:SetValue(time)
				if self.massage_cold_down_time > 0 then
					self.massage_fill_amount:SetValue(time / self.massage_cold_down_time)
				end
			else
				self.massage_cd:SetValue(0)
				self.massage_fill_amount:SetValue(0)
			end
		end
		if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) > 0 then
			local time = skill_info.skill_2_can_perform_time - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				self.snowball_cd:SetValue(time)
				if self.snowball_cold_down_time > 0 then
					self.snow_ball_fill_amount:SetValue(time / self.snowball_cold_down_time)
				end
			else
				self.snowball_cd:SetValue(0)
				self.snow_ball_fill_amount:SetValue(0)
			end
		end
	end
end

function HotInfoView:FlushSkillInfo()
	self.massage_count:SetValue(HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) or 0)
	self.snowball_count:SetValue(HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) or 0)
end

function HotInfoView:FlushCatchInfo()
	self.catch_count:SetValue(HotStringChatData.Instance:GetRestGatherTimesByType())
end
----------------------------------------InitScroller---------------------------------------------------

--初始化滚动条
function HotInfoView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self.cell_list = {}
	local scroller_delegate = self.scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function HotInfoView:GetRoomNumberOfCells()
	local count = 0
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		count = rank_info.rank_count or 0
	end
	return count
end

--滚动条刷新
function HotInfoView:GetRoomCellView(cellObj, data_index)
	local cell = self.cell_list[cellObj]
	if cell == nil then
		self.cell_list[cellObj] = HotRankCell.New(cellObj)
		cell = self.cell_list[cellObj]
	end
	cell:SetIndex(data_index + 1)
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		local data = rank_info.rank_list[data_index + 1]
		cell:SetData(data)
	end
end

-- 点击跟随榜首
function HotInfoView:OnClickFollow()
	GuajiCtrl.Instance:StopGuaji()
	HotStringChatCtrl.Instance:SendFirstPos()
end

-- 点击捕捉
function HotInfoView:OnClickCatch()
	local last_gather_time = HotStringChatData.Instance:GetRestGatherTimesByType()
	if last_gather_time <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.HotString.GatherTimeOver)
		return
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
    if scene_logic then
        if scene_logic:GetSceneType() == SceneType.HotSpring then
        	scene_logic:GotoGather()
        end
    end
end

---------------------HotRankCell-----------------------------
HotRankCell = HotRankCell or BaseClass(BaseCell)

function HotRankCell:__init()
	-- 获取变量
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
end

function HotRankCell:__delete()

end

function HotRankCell:OnFlush()
	if self.data then
		self.name:SetValue(self.data.name)
		self.score:SetValue(self.data.score)
	end
	self.rank:SetValue(self.index or 0)
end