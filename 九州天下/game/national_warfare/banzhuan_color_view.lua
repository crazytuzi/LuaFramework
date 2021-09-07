-- 国家战事（搬砖刷新颜色界面）
BanZhuanColorView = BanZhuanColorView or BaseClass(BaseView)

local Dis = 30	--主角和npc的距离

function BanZhuanColorView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "BanZhuanRefresh"}
	self.animation_lists = {}
	self.banzhuan_list = {}
	self.img_obj_list = {}
	self.is_refresh_red = false

	self.max_reward = 5 --最高的奖励
end

function BanZhuanColorView:__delete()

end

function BanZhuanColorView:ReleaseCallBack()
	self.citan_state = nil
	self.residue_number = nil
	self.is_highest_reward = nil
	self.reward_color = nil
	self.show_finish_btn = nil
	self.show_start_btn = nil
	self.show_auto_red = nil
	self.button_Affirm = nil
	self.button_refresh = nil
	self.word_qingbao = nil
	self.count_down_text = nil
	self.show_count_down = nil
	self.btn_affirm_text = nil
	self.show_share_btn = nil
	self.has_share = nil

	self.animation_lists = {}
	self.img_obj_list = {}

	self:RemoveRefreshCountDown()
end

function BanZhuanColorView:LoadCallBack()
	self.citan_state = self:FindVariable("CiTanState")
	self.residue_number = self:FindVariable("ResidueNumber")
	self.is_highest_reward = self:FindVariable("IsHighestReward")
	self.reward_color = self:FindVariable("RewardColor")
	self.show_finish_btn = self:FindVariable("ShowFinishBtn")
	self.show_start_btn = self:FindVariable("ShowStartBtn")
	self.show_auto_red = self:FindVariable("ShowAutoRed")
	self.button_Affirm = self:FindObj("ButtonAffirm")
	self.button_refresh = self:FindObj("ButtonRefresh")
	self.word_qingbao = self:FindObj("WordObj")
	self.count_down_text = self:FindVariable("CountDown")
	self.show_count_down = self:FindVariable("ShowCountDown")
	self.btn_affirm_text = self:FindVariable("BtnAffirmText")
	self.show_share_btn = self:FindVariable("ShowShareBtn")
	self.has_share = self:FindVariable("HasShare")

	self.key = 0
	self.last_refresh_time = 0

	for i = 1, 5 do
		self.animation_lists[i] = self:FindVariable("light_" .. i)
		self.img_obj_list[i] = self:FindObj("image" .. i)
	end

	self:ListenEvent("OnClose", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("StartTask", BindTool.Bind(self.RefreshColorOpera, self))
	self:ListenEvent("FinishTask", BindTool.Bind(self.OnFinishTask, self))
	self:ListenEvent("AffirmColor", BindTool.Bind(self.OnAffirmTask, self))
	self:ListenEvent("Explain", BindTool.Bind(self.OnExplain, self))
	-- self:ListenEvent("AddResidue", BindTool.Bind(self.AddBanZhuanResidue, self))
	self:ListenEvent("RefreshColor", BindTool.Bind(self.RefreshColorOpera, self))
	self:ListenEvent("RefreshRed", BindTool.Bind(self.RefreshRed, self))
	self:ListenEvent("ShareColor", BindTool.Bind(self.ShareColor, self))
	self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnTiJiaoBanZhuan)
end

function BanZhuanColorView:OnExplain()
	TipsCtrl.Instance:ShowHelpTipView(182)
end

function BanZhuanColorView:CloseCallBack()
	-- self.button_refresh.button.interactable = true
	self.button_Affirm.button.interactable = true
	if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and
		self.banzhuan_list.get_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
		self.word_qingbao:SetActive(true)
		local pos
		if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
			pos = self.img_obj_list[self.banzhuan_list.cur_color].transform.localPosition
		else
			pos = self.img_obj_list[self.banzhuan_list.get_color].transform.localPosition
		end
		self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
	end
	local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
	if color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
		self.show_auto_red:SetValue(true)
	end
	Runner.Instance:RemoveRunObj(self)
	self:RemoveCountDown()

	if nil ~= self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end
end

function BanZhuanColorView:OpenCallBack()
	for i = 1, 5 do
		self.animation_lists[i]:SetValue(false)
	end

	if self.role_pos_change == nil then
		self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeHandler, self))
	end

	self:Flush()
end

-- 关闭事件
function BanZhuanColorView:HandleClose()
	ViewManager.Instance:Close(ViewName.BanZhuanColorView)
end

-- 一键刷红颜色
function BanZhuanColorView:RefreshRed()
	local other_cfg = NationalWarfareData.Instance:GetBanZhuanOtherCfg()
	if other_cfg then
		local yes_func = function()
			self.is_refresh_red = true
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_BANZHUAN_REFRESH_COLOR, 1)	
		end
		local content = string.format(Language.NationalWarfare.RefreshMaxColor, other_cfg.refresh_best_color_need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
	end
end

-- 刷新颜色
function BanZhuanColorView:RefreshColorOpera()
	local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
	if color == CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
		SysMsgCtrl.Instance:ErrorRemind(Language.NationalWarfare.MaxQualityDesc)
		return
	else
		self.is_refresh_red = false
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_BANZHUAN_REFRESH_COLOR)
	end	
end

function BanZhuanColorView:ShareColor()
	if self.banzhuan_list.has_share_color == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.NationalWarfare.NoShareNum)
		return
	end
	CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_BANZHUAN_SHARE_COLOR)
end

function BanZhuanColorView:StartRefreshColor(is_refresh_red)
	if self.is_refresh_red or is_refresh_red then
		for i = 1, 5 do
			if self.animation_lists ~= nil and self.animation_lists[i] ~= nil then
				self.animation_lists[i]:SetValue(i == 5)
			end
		end
		self.show_auto_red:SetValue(false)
		local pos = self.img_obj_list[5].transform.localPosition
		self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)

		self.button_refresh.button.interactable = false
		self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnQueRen)
		self.show_share_btn:SetValue(true)
		self.has_share:SetValue(self.banzhuan_list.has_share_color == 0)
		return
	end
	self.button_refresh.button.interactable = false
	self.button_Affirm.button.interactable = false
	self.show_auto_red:SetValue(false)
	self.word_qingbao:SetActive(false)
	self.show_count_down:SetValue(true)
	self:TestAnimation()

	local next_time = self.banzhuan_list.next_refresh_camp_banzhuan_timestmap - TimeCtrl.Instance:GetServerTime()
	self.count_down_text:SetValue(math.floor(next_time))
	function next_time_func(elapse_time, total_time)
		if self.count_down_text then
			self.count_down_text:SetValue(math.floor(total_time - elapse_time))
		end
		if elapse_time >= total_time then
			if self.show_count_down then
				self.show_count_down:SetValue(false)
			end
			if self.button_refresh then
				local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
				if color == CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
					self.button_refresh.button.interactable = false
					self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnQueRen)
					self.show_share_btn:SetValue(true)
				else
					self.button_refresh.button.interactable = true
					self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnTiJiaoBanZhuan)
					self.show_share_btn:SetValue(false)
				end
			end
			self:RemoveRefreshCountDown()
		end
	end

	self.refresh_count_down = CountDown.Instance:AddCountDown(
		next_time, 1, next_time_func)
end

function BanZhuanColorView:RemoveRefreshCountDown()
	if self.refresh_count_down then
		CountDown.Instance:RemoveCountDown(self.refresh_count_down)
		self.refresh_count_down = nil
	end
end

-- 提交任务
function BanZhuanColorView:OnFinishTask()
	CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_COMMIT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
	self:HandleClose()
end

-- 确认情报颜色
function BanZhuanColorView:OnAffirmTask()
	local npc_cfg = NationalWarfareData.Instance:GetBanZhuanNpcCfg()
	NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
	self:HandleClose()
end

function BanZhuanColorView:TestAnimation()
	self.interval = 0.1 					 --最后5次每次增加的时间
	self.run_number = 0 					 --计算最后5次
	self.test_num = 0 						 --目标次数
	self.total_num = 0 						 --执行总次数
	self.cur_color = self.banzhuan_list.cur_color 		 --目标位置

	if self.key > self.cur_color then
		self.cur_color = 5 - math.abs(self.cur_color - self.key)
	else
		self.cur_color = math.abs(self.cur_color - self.key)
	end

	for i = 1, 5 do
		self.animation_lists[i]:SetValue(false)
	end

	self.test_num = 30 + self.cur_color

	GlobalTimerQuest:CancelQuest(self.timer_quest)
	function diff_time_func(elapse_time, total_time)
		self.key = self.key + 1
		self.total_num = self.total_num + 1

		if self.animation_lists[self.key-1] then
			self.animation_lists[self.key-1]:SetValue(false)
		end

		if self.key >= 6 then
			self.key = 1
		end

		self.animation_lists[self.key]:SetValue(true)
		if self.total_num >= self.test_num then
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				Runner.Instance:AddRunObj(self, 8)
				self:RemoveCountDown()
			end,0.1)
		end

		if elapse_time >= total_time then
			self:RemoveCountDown()
		end
	end

	local total = 3 + (self.cur_color * 0.1) 
	self:RemoveCountDown()

	self.count_down = CountDown.Instance:AddCountDown(
		10, 0.1, diff_time_func)
end

function BanZhuanColorView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function BanZhuanColorView:Update()
	if Status.NowTime - self.interval < self.last_refresh_time then
		return
	end
	self.last_refresh_time = Status.NowTime
	self.interval = self.interval + 0.1

	self.key = self.key + 1
	self.run_number = self.run_number + 1 

	if self.animation_lists[self.key-1] then
		self.animation_lists[self.key-1]:SetValue(false)
	end
	if self.key >= 6 then
		self.key = 1
	end

	self.animation_lists[self.key]:SetValue(true)

	if self.run_number >= 5 then
		local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
		if color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
			self.show_auto_red:SetValue(true)
		end
		-- self.key = self.banzhuan_list.cur_color
		self.button_Affirm.button.interactable = true
		Runner.Instance:RemoveRunObj(self)
		self.word_qingbao:SetActive(true)
		local pos
		if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
			pos = self.img_obj_list[self.banzhuan_list.cur_color].transform.localPosition
		else
			pos = self.img_obj_list[self.banzhuan_list.get_color].transform.localPosition
		end
		self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)

		self.reward_color:SetValue(true)

		if self.button_refresh then
			if color == CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
				self.button_refresh.button.interactable = false
				self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnQueRen)
				self.show_share_btn:SetValue(true)
				self:RemoveRefreshCountDown()
			end
		end
	end
end

function BanZhuanColorView:OnFlush(param_t)
	self.banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local citan_day_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.banzhuan_list.get_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
	self.citan_state:SetValue(Language.NationalWarfare.CiTanState)

	for k, v in pairs(param_t) do
		if k == "start" then
			if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID or self.banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then
				local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
				self.is_highest_reward:SetValue(true)
				self.show_start_btn:SetValue(true)
				if v.index == 1 then
					local pos = self.img_obj_list[color].transform.localPosition
					self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
					self.animation_lists[color]:SetValue(true)

					self.word_qingbao:SetActive(true)
					self.reward_color:SetValue(true)
					if color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
						self.show_auto_red:SetValue(true)
					end
					if color == CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_RED then
						self.button_refresh.button.interactable = false
						self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnQueRen)
						self.show_share_btn:SetValue(true)
					else
						self.button_refresh.button.interactable = true
						self.btn_affirm_text:SetValue(Language.NationalWarfare.BtnTiJiaoBanZhuan)
						self.show_share_btn:SetValue(false)
					end
				end
				if v.index == 3 or v.index == 1 then
					self.has_share:SetValue(self.banzhuan_list.has_share_color == 0)
				end
			else
				self.is_highest_reward:SetValue(false)
				self.reward_color:SetValue(false)
			end
			self.show_finish_btn:SetValue(false)
		end
	end
end

function BanZhuanColorView:OnMainRolePosChangeHandler(x, y)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local camp = CampData.Instance:GetCampScene(mainrole_vo.camp)
	local npc_id = NationalWarfareData.Instance:GetBanZhuanRefreshNpc()
	local npc_cfg
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(camp)
	for k, v in pairs(scene_cfg.npcs) do
		if npc_id == v.id then
			npc_cfg = v
			break
		end
	end

	local dis = GameMath.GetDistance(npc_cfg.x, npc_cfg.y, x, y, true)
	if dis >= Dis then
		self:Close()
	end
end