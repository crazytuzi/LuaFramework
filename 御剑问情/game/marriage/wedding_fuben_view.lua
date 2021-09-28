WeddingFuBenView = WeddingFuBenView or BaseClass(BaseView)

--撒花特效播放时间
local EFFECT_TIME = 5
local SKILL_1_CD = 10
local SKILL_2_CD = 10
function WeddingFuBenView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingFuBenView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUI
	self.is_safe_area_adapter = true
	self.effect_cd = 0
	self.n_refresh_yanhua_time = 0
	self.act_end_time = 0
	self.is_open_danmu = true
end

function WeddingFuBenView:ReleaseCallBack()
	-- 清理变量和对象
	self.content = nil
	self.tab_hunyan = nil
	self.tab_rank = nil
	self.rank_list = nil
	self.wedding_name = nil
	self.wedding_name2 = nil
	self.left_times = nil
	self.rewards_text = nil
	self.is_show_banner = nil
	self.banner_marrier_name = nil
	self.wedding_icon = nil
	self.is_marrier_view = nil
	self.cd_progress = nil
	self.cd_time = nil
	self.is_first = nil
	self.show_left_panel = nil
	self.can_pao_hua = nil
	self.skill_cd_progress1 = nil
	self.skill_cd_progress2 = nil
	self.skill_cd_time1 = nil
	self.skill_cd_time2 = nil
	self.skill_1_count = nil
	self.skill_2_count = nil
	-- self.show_yanhua_countdown = nil
	self.yanhua_countdown = nil
	self.act_time = nil
	self.edit_text = nil
	self.btn_baitang = nil
	self.btn_yanhua = nil
	self.btn_xiuqiu = nil
	self.btn_baitang_gray = nil
	self.btn_yanhua_gray = nil
	self.btn_xiuqiu_gray = nil
	self.is_open_notice = nil
	self.danmu_res = nil
	self.yanhua_cd_progress = nil
	self.yanhua_cd_time = nil
	self.heci_free_time = nil
	self.yanhua_cd = nil
	self.show_notice_text = nil
	self.notice_cost = nil

	for _, v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end

	self.rank_cell_list = {}
end

function WeddingFuBenView:LoadCallBack()
	self.content = self:FindObj("Content")
	self.tab_hunyan = self:FindObj("tab_hunyan")
	self.tab_rank = self:FindObj("tab_rank")
	self.edit_text = self:FindObj("EditText")
	self.btn_baitang = self:FindObj("BtnBaiTang")
	self.btn_yanhua = self:FindObj("BtnYanHua")
	self.btn_xiuqiu = self:FindObj("BtnXiuQiu")

	self.rank_data = {}
	self.rank_cell_list = {}
	self.rank_list = self:FindObj("rank_list")
	local scroller_delegate = self.rank_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	-- self:ListenEvent("OnClickExit", BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClicBless", BindTool.Bind(self.OnClicBless, self))
	self:ListenEvent("OnClickScatterFlower", BindTool.Bind(self.OnClickScatterFlower, self))
	self:ListenEvent("OnClickBaiTang", BindTool.Bind(self.OnClickBaiTang, self))
	self:ListenEvent("OnClickYanHua", BindTool.Bind(self.OnClickYanHua, self))
	self:ListenEvent("OnClickHeCi", BindTool.Bind(self.OnClickHeCi, self))
	self:ListenEvent("OnClickScatterFlowerBall", BindTool.Bind(self.OnClickScatterFlowerBall, self))
	self:ListenEvent("OnBtnSeekNPC", BindTool.Bind(self.OnBtnSeekNPC, self))
	self:ListenEvent("OnPublishNotice", BindTool.Bind(self.OnPublishNotice, self))
	self:ListenEvent("OnCloseNotice", BindTool.Bind(self.OnCloseNotice, self))
	self:ListenEvent("OnBtnDanMu", BindTool.Bind(self.OnBtnDanMuHandler, self))

	self.wedding_name = self:FindVariable("WeddingName")
	self.wedding_name2 = self:FindVariable("WeddingName2")
	self.left_times = self:FindVariable("LeftTimes")
	self.rewards_text = self:FindVariable("RewardsText")
	self.is_show_banner = self:FindVariable("IsShowBanner")
	self.banner_marrier_name = self:FindVariable("BannerMarrierName")
	self.wedding_icon = self:FindVariable("WeddingIcon")
	self.is_marrier_view = self:FindVariable("IsMarrierView")
	self.cd_progress = self:FindVariable("CDProgress")
	self.cd_progress:SetValue(0)
	self.cd_time = self:FindVariable("CDTime")
	self.cd_time:SetValue("")
	self.is_first = self:FindVariable("IsFirst")
	self.show_left_panel = self:FindVariable("ShowLeftPanel")
	self.can_pao_hua = self:FindVariable("CanPaoHua")
	self.skill_cd_progress1 = self:FindVariable("SkillCDProgress1")
	self.skill_cd_progress2 = self:FindVariable("SkillCDProgress2")
	self.skill_cd_time1 = self:FindVariable("SkillCDTime1")
	self.skill_cd_time2 = self:FindVariable("SkillCDTime2")
	self.skill_1_count = self:FindVariable("Skill1Count")
	self.skill_2_count = self:FindVariable("Skill2Count")
	-- self.show_yanhua_countdown = self:FindVariable("ShowYanhuaCountDown")
	self.yanhua_countdown = self:FindVariable("YanhuaCountDown")
	self.act_time = self:FindVariable("ActTime")
	self.btn_baitang_gray = self:FindVariable("BtnBaitangGray")
	self.btn_yanhua_gray = self:FindVariable("BtnYanhuaGray")
	self.btn_xiuqiu_gray = self:FindVariable("BtnXiuqiuGray")
	self.is_open_notice = self:FindVariable("IsOpenNotice")
	self.danmu_res = self:FindVariable("DanMuRes")
	self.yanhua_cd_progress = self:FindVariable("YanhuaCDProgress")
	self.yanhua_cd_time = self:FindVariable("YanhuaCDTime")
	self.heci_free_time = self:FindVariable("FreeHeciTime")
	self.show_notice_text = self:FindVariable("NoticeText")
	self.notice_cost = self:FindVariable("NoticeCost")

	self.yanhua_cd_max = MarriageData.Instance:GetActivityCfg().paohuaqiu_cd_s
	self.pao_hua_max = MarriageData.Instance:GetActivityCfg().paohuaqiu_times

	self:ChangeDanMuRes()
end

function WeddingFuBenView:GetNumberOfCell()
	return #self.rank_data
end

function WeddingFuBenView:RefreshCellList(cell, data_index)
	data_index = data_index + 1
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = QuestionRankCell.New(cell.gameObject)
		self.rank_cell_list[cell] = rank_cell
	end

	rank_cell:SetData(self.rank_data[data_index])
end

function WeddingFuBenView:OnMainUIModeListChange(is_show)
	self.show_left_panel:SetValue(not is_show)
end

function WeddingFuBenView:OpenCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.chat_hight_change = GlobalEventSystem:Bind(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE,
		BindTool.Bind(self.FulshBtnPosition, self))

	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))

	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self:Flush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local marryuser_list = MarriageData.Instance:GetMarryUserList()

	--获取当前主界面聊天框是边长的还是变短的
	local chat_view_state = MainUIData.Instance:GetChatViewState()
	local posy = 225
	if chat_view_state == MainUIData.ChatViewState.Length then
		posy = 225 + 105
	end

	self.content.rect.anchoredPosition = Vector2(0, posy)
	self.skill_cd_time1:SetValue(0)
	self.skill_cd_progress1:SetValue(0)
	self.skill_cd_time2:SetValue(0)
	self.skill_cd_progress2:SetValue(0)
	self.yanhua_cd_time:SetValue(0)
	self.yanhua_cd_progress:SetValue(0)
end

function WeddingFuBenView:FulshBtnPosition(param)
	if self.content.gameObject.activeInHierarchy then
		local y = 225
		if param == "to_length" then
			y = 225 + 105
		end
		local tween = self.content.rect:DOAnchorPosY(y, 0.5, false)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

function WeddingFuBenView:SwitchButtonState(enable)
	self.show_left_panel:SetValue(enable)
end

function WeddingFuBenView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.chat_hight_change then
		GlobalEventSystem:UnBind(self.chat_hight_change)
		self.chat_hight_change = nil
	end
	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest1 then
		CountDown.Instance:RemoveCountDown(self.time_quest1)
		self.time_quest1 = nil
	end
	if self.time_quest2 then
		CountDown.Instance:RemoveCountDown(self.time_quest2)
		self.time_quest2 = nil
	end
	if self.time_quest_yanhua then
		CountDown.Instance:RemoveCountDown(self.time_quest_yanhua)
		self.time_quest_yanhua = nil
	end
	if self.flower_timer_quest then
		GlobalTimerQuest:CancelQuest(self.flower_timer_quest)
		self.flower_timer_quest = nil
	end
	self:RemoveFlowerEff()
	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.start_gather_event)
		self.start_gather_event = nil
	end

	if self.yanhua_refresh_timer then
		GlobalTimerQuest:CancelQuest(self.yanhua_refresh_timer)
		self.yanhua_refresh_timer = nil
	end
	self.gather_obj = nil
end

--祝福
function WeddingFuBenView:OnClicBless()
	if self.time_quest2 == nil then
		MarriageCtrl.Instance:SendMarryBless()
		if self.skill_2_count:GetInteger() > 1 then
			self:HandleCD("zhufu")
		end
	end
end

--撒花
function WeddingFuBenView:OnClickScatterFlower()
	if self.time_quest1 == nil then
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_SAXIANHUA)
		if self.skill_1_count:GetInteger() > 1 then
			self:HandleCD("sahua")
		end
	end
end

--拜堂
function WeddingFuBenView:OnClickBaiTang()
	local other_uid = MarriageData.Instance:GetMarryOhterUser()
	if other_uid ~= nil then
		if Scene.Instance:GetObjByUId(other_uid) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.WaitAgreeBaitang)
		end
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_BAITANG_REQ)
	end
end
--烟花
function WeddingFuBenView:OnClickYanHua()
	if self.time_quest_yanhua == nil then
		local data = MarriageData.Instance:GetWeddingInfo()
		if data.is_self_hunyan == 1 and (self.pao_hua_max - data.paohuaqiu_times) > 0 then
			MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_PAOHUAQIU)
			-- self:HandleCD("yanhua")
		end
	end
end

--贺词
function WeddingFuBenView:OnClickHeCi()
	local data = MarriageData.Instance:GetWeddingInfo()
	local cfg = MarriageData.Instance:GetActivityCfg()
	self.heci_free_time:SetValue(data.guest_bless_free_times >= 0 and data.guest_bless_free_times or 0)  
	self.show_notice_text:SetValue(data.guest_bless_free_times > 0)
	self.notice_cost:SetValue(tonumber(cfg.guest_bless_need_gold))
	self.is_open_notice:SetValue(true)
	self.edit_text.input_field.text = ""
end

--绣球
function WeddingFuBenView:OnClickScatterFlowerBall()
	print('绣球')
	local func = function()
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_HONGBAO)
	end
	local cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").hunyan_cfg[1]
	local str = string.format(Language.Marriage.XiuQiuTips, cfg.buy_hongbao_gold, cfg.give_hongbao_num)
	TipsCtrl.Instance:ShowCommonTip(func, nil, str)
end

--撒花CD
function WeddingFuBenView:HandleCD(cd_type)
	if cd_type == "sahua" then
		if self.time_quest1 then
			return
		end
		self.time_quest1 = CountDown.Instance:AddCountDown(SKILL_1_CD, 1, BindTool.Bind(self.Skill1CDTimer, self))
		self.skill_cd_time1:SetValue(SKILL_1_CD)
		self.skill_cd_progress1:SetValue(1)

	elseif cd_type == "zhufu" then
		if self.time_quest2 then
			return
		end
		self.time_quest2 = CountDown.Instance:AddCountDown(SKILL_2_CD, 1, BindTool.Bind(self.Skill2CDTimer, self))
		self.skill_cd_time2:SetValue(SKILL_2_CD)
		self.skill_cd_progress2:SetValue(1)

	elseif cd_type == "yanhua" then
		if self.time_quest_yanhua then
			return
		end
		self.yanhua_cd = MarriageData.Instance:GetNextRefreshYanhuaTime() and (MarriageData.Instance:GetNextRefreshYanhuaTime() - TimeCtrl.Instance:GetServerTime()) or self.yanhua_cd_max
		self.time_quest_yanhua = CountDown.Instance:AddCountDown(self.yanhua_cd, 1, BindTool.Bind(self.YanhuaCDTimer, self))
		self.yanhua_cd_time:SetValue(self.yanhua_cd)
		self.yanhua_cd_progress:SetValue(1)
	end
end

--撒花CDTimer
function WeddingFuBenView:Skill1CDTimer(elapse_time, total_time)
	local left_time = total_time - elapse_time
	left_time = math.ceil(left_time)
	left_time = left_time > SKILL_1_CD and SKILL_1_CD or left_time
	if left_time <= 0 then
		if self.time_quest1 then
			CountDown.Instance:RemoveCountDown(self.time_quest1)
			self.time_quest1 = nil
		end
		self.skill_cd_time1:SetValue(0)
		self.skill_cd_progress1:SetValue(0)
		return
	end

	self.skill_cd_time1:SetValue(left_time)
	self.skill_cd_progress1:SetValue(left_time / SKILL_1_CD)
end

--祝福CDTimer
function WeddingFuBenView:Skill2CDTimer(elapse_time, total_time)
	local left_time = total_time - elapse_time
	left_time = math.ceil(left_time)
	left_time = left_time > SKILL_2_CD and SKILL_2_CD or left_time
	if left_time <= 0 then
		if self.time_quest2 then
			CountDown.Instance:RemoveCountDown(self.time_quest2)
			self.time_quest2 = nil
		end
		self.skill_cd_time2:SetValue(0)
		self.skill_cd_progress2:SetValue(0)
		return
	end

	self.skill_cd_time2:SetValue(left_time)
	self.skill_cd_progress2:SetValue(left_time / SKILL_2_CD)
end

--祝福CDTimer
function WeddingFuBenView:YanhuaCDTimer(elapse_time, total_time)
	local left_time = total_time - elapse_time
	left_time = math.ceil(left_time)
	left_time = left_time > self.yanhua_cd and self.yanhua_cd or left_time
	if left_time <= 0 then
		if self.time_quest_yanhua then
			CountDown.Instance:RemoveCountDown(self.time_quest_yanhua)
			self.time_quest_yanhua = nil
		end
		self.yanhua_cd_time:SetValue(0)
		self.yanhua_cd_progress:SetValue(0)
		return
	end

	self.yanhua_cd_time:SetValue(left_time)
	self.yanhua_cd_progress:SetValue(left_time / self.yanhua_cd_max)
end

function WeddingFuBenView:FlushView()
	--注意:data可能为空
	local data = MarriageData.Instance:GetWeddingInfo()
	if not next(data) then
		return
	end

	self.yanhui_type = data.yanhui_type
	self.marryuser_list = data.marryuser_list
	self.remainder_eat_times = data.remainder_eat_food_num
	local cfg = MarriageData.Instance:GetWeddingCfgByType(self.yanhui_type)
	if self.yanhui_type == 1 then
		self.wedding_name2:SetValue(string.format(Language.Marriage.WeddingName, cfg.marry_name))
		self.wedding_name:SetValue("")
	else
		self.wedding_name:SetValue(string.format(Language.Marriage.WeddingName, cfg.marry_name))
		self.wedding_name2:SetValue("")
	end
	local is_marrier = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--可获得奖励
	local count = 1
	local reward_text = ""
	for i=1,10 do
		local id = cfg["reward_id_"..i]
		if id ~= nil and id ~= "" then
			local item_cfg = ItemData.Instance:GetItemConfig(id)
			if reward_text == "" then
				reward_text = item_cfg.name
			else
				reward_text = reward_text.."\n"..item_cfg.name
			end
		else
			break
		end
	end
	self.rewards_text:SetValue(reward_text)
	--婚宴名
	local name_text = ""
	for k,v in pairs(self.marryuser_list) do
		local color = "#00ff00"
		if name_text == "" and v.marry_name ~= "" then
			name_text = ToColorStr(v.marry_name, color)
		elseif v.marry_name ~= "" then
			name_text = name_text.. Language.Marriage.AndDes ..ToColorStr(v.marry_name, color)
		end
		if v.marry_uid == main_role_vo.role_id then
			is_marrier = true
		end
	end
	self.is_marrier_view:SetValue(is_marrier)

	if data.is_self_hunyan == 1 then
	   -- self.can_pao_hua:SetValue(true)
	else
	  	-- self.can_pao_hua:SetValue(false)
	   	local zhufu_count = MarriageData.Instance:GetZhufuCount()
		local sahua_count = MarriageData.Instance:GetSaxianhuaCount()
	   	local cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").hunyan_activity[1]
	   	self.skill_1_count:SetValue(cfg.saxianhua_count - sahua_count)
	   	self.skill_2_count:SetValue(cfg.per_session_zhufu_times - zhufu_count)
    end
	-- end

	self.banner_marrier_name:SetValue(name_text)
	self.left_times:SetValue(self.remainder_eat_times)

	self.n_refresh_yanhua_time = MarriageData.Instance:GetNextRefreshYanhuaTime()
	self.act_end_time = MarriageData.Instance:GetWeedingNextTime() or 0
	-- self.show_yanhua_countdown:SetValue(self.n_refresh_yanhua_time - TimeCtrl.Instance:GetServerTime() > 0)
	if nil == self.yanhua_refresh_timer then
		self.yanhua_refresh_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function WeddingFuBenView:FlushBtnState()
	local wedding_data = MarriageData.Instance:GetWeddingInfo()
	local cur_wedding_info = MarriageData.Instance:GetCurWeddingInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local wedding_role_info = MarriageData.Instance:GetWeddingRoleInfo()
	if main_role_vo.role_id == cur_wedding_info.marryuser_list[1].marry_uid or main_role_vo.role_id == cur_wedding_info.marryuser_list[2].marry_uid then
		self.btn_baitang_gray:SetValue(wedding_role_info.is_baitang ~= 2)
		self.btn_baitang.toggle.interactable = wedding_role_info.is_baitang ~= 2
		local yanhua_btn = ((self.pao_hua_max - wedding_data.paohuaqiu_times) > 0)
		self.btn_yanhua_gray:SetValue(yanhua_btn)
		self.btn_yanhua.toggle.interactable = yanhua_btn
		self.btn_xiuqiu_gray:SetValue(true)
		self.btn_xiuqiu.toggle.interactable = true
	else
		self.btn_baitang_gray:SetValue(false)
		self.btn_baitang.toggle.interactable = false
		self.btn_yanhua_gray:SetValue(false)
		self.btn_yanhua.toggle.interactable = false
		self.btn_xiuqiu_gray:SetValue(false)
		self.btn_xiuqiu.toggle.interactable = false
	end
end

function WeddingFuBenView:FlushNextTime()
	local info = AncientRelicsData.Instance:GetInfo()
	local hunyan_time =MarriageData.Instance:GetHunYanTime()
	local time = math.max(hunyan_time - TimeCtrl.Instance:GetServerTime(), 0)
	self.yanhua_countdown:SetValue(time)
	-- if time <= 0 then
		-- self.show_yanhua_countdown:SetValue(false)
	-- end

	time = math.max(self.act_end_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
end

function WeddingFuBenView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "sahua" then
			self:AddFlowerEffect()
		elseif k == "zhufu" then
			self:AddYanhuaEffect()
		elseif k == "yanhua" then
			local data = MarriageData.Instance:GetWeddingInfo()
			if data.is_self_hunyan == 1 and (self.pao_hua_max - data.paohuaqiu_times) <= 0 then
				self.btn_yanhua_gray:SetValue(false)
				self.btn_yanhua.toggle.interactable = false
				self.btn_yanhua.toggle.isOn = false
				self.yanhua_cd_time:SetValue(0)
			end
			self:HandleCD("yanhua")
		elseif k == "answer_rank" then
			self.rank_data = MarriageData.Instance:GetHunyanQuestionRankInfo()
			self.rank_list.scroller:ReloadData(0)
		elseif k == "role_info" then
			self:FlushBtnState()
		else
			self:FlushView()
		end
	end
end

function WeddingFuBenView:OnBtnSeekNPC()
	local user_info, question_list = MarriageData.Instance:GetHunyanQuestionUserInfo()
	if question_list[user_info.cur_question_idx + 1] then
		local npc_id = MarriageData.Instance:GetQuestionNpc(user_info.cur_question_idx + 1)
		local pos = MarriageData.Instance:GetQuestionNpcPos(question_list[user_info.cur_question_idx + 1].npc_pos_seq)
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = npc_id
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.pos_x, pos.pos_y, 1, 1, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AchieveQuestion)
	end
end

--添加撒花特效
function WeddingFuBenView:AddFlowerEffect()
	if self.flower_eff == nil and self.flower_timer_quest == nil then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/w2_changjing/w2_yw_03(z)_huaxuguo_prefab", "taohua"),
    	function (prefab)
        	if self.flower_eff then
        		self:RemoveFlowerEff()
        	end
            if prefab ~= nil then
        		if nil == MainCamera then
        			 PrefabPool.Instance:Free(prefab)
        			return
        		end
                local obj = GameObject.Instantiate(prefab)
                PrefabPool.Instance:Free(prefab)
                local transform = obj.transform
                transform:SetParent(MainCamera.transform, false)
                self.flower_eff = obj
                local sys = self.flower_eff.transform:FindHard("Particle System")
				if sys then
					self.particle = sys:GetComponent(typeof(UnityEngine.ParticleSystem))
				end
            end
		end)
		self:AddFlowerTimer()
	elseif self.flower_timer_quest == nil then
		if self.particle then
			self.particle:Play()
		end
		self:AddFlowerTimer()
	end
end

function WeddingFuBenView:AddFlowerTimer()
	self.flower_timer_quest = GlobalTimerQuest:AddDelayTimer(function ()
		if self.particle then
			self.particle:Stop()
		end
		self.flower_timer_quest = nil
	end, EFFECT_TIME)
end

function WeddingFuBenView:RemoveFlowerEff()
	if not IsNil(self.flower_eff) then
		GameObject.Destroy(self.flower_eff)
	end
	self.flower_eff = nil
	self.particle = nil
end

function WeddingFuBenView:OnStopGather(role_obj_id, reason)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if (obj_id ~= role_obj_id) then
		return
	end
	if reason == 0 then self.gather_obj = nil return end
	if self.gather_obj ~= nil then
		local res_id = 6002002				--更换酒席模型id
		self.gather_obj:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(res_id))
		self.gather_obj = nil
	end
end

function WeddingFuBenView:OnStartGather(role_obj_id, gather_obj_id)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if (obj_id ~= role_obj_id) then
		return
	end
	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)
	local gather_id = gather_obj and gather_obj:GetGatherId() or 0
	local hunyan_cfg = MarriageData.Instance:GetHunYanCfg()
	if gather_id == hunyan_cfg.gather_id then
		self.gather_obj = gather_obj
	end
end

--添加烟花特效
function WeddingFuBenView:AddYanhuaEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local transform = Scene.Instance:GetMainRole():GetRoot().transform
		if transform then
			EffectManager.Instance:PlayControlEffect(
				"effects2/prefab/misc/effect_yanhua_da_prefab",
				"effect_yanhua_da",
				transform.position,
				nil,
				nil,
				effect_scale
			)
		end

		self.effect_cd = Status.NowTime + EFFECT_TIME
	end
end

--发送贺词
function WeddingFuBenView:OnPublishNotice()
	if self.edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	end

	local activity_cfg = MarriageData.Instance:GetActivityCfg()
	local data = MarriageData.Instance:GetWeddingInfo()
	if not next(data) then
		return
	end

	local ok_fun = function ()
		self:SendBless()
	end
	if data.guest_bless_free_times == 0 then
		if UnityEngine.PlayerPrefs.GetInt("show_danmu") == 1 then
			self:SendBless()
		else
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Marriage.GuestBlessingTip,activity_cfg.guest_bless_need_gold), nil, nil, true, false, "show_danmu")
		end
	else
		self:SendBless()
	end

end

--发送贺词
function WeddingFuBenView:OnCloseNotice()
	self.is_open_notice:SetValue(false)
end

function WeddingFuBenView:SendBless()
	local str_len = string.len(self.edit_text.input_field.text)
	local text = ChatFilter.Instance:Filter(self.edit_text.input_field.text)
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_GUEST_BLESS, str_len, 0, text)
	self.is_open_notice:SetValue(false)
end


function WeddingFuBenView:ChangeDanMuRes()
	if self.is_open_danmu then
		local bundle, asset = ResPath.GetMarryImage("close_danmu")
		self.danmu_res:SetAsset(bundle, asset)
	else
		local bundle, asset = ResPath.GetMarryImage("open_danmu")
		self.danmu_res:SetAsset(bundle, asset)
	end
end

function WeddingFuBenView:OnBtnDanMuHandler()
	self.is_open_danmu = not self.is_open_danmu
	self:ChangeDanMuRes()

	if not self.is_open_danmu then
		if RollingBarrageCtrl.Instance.view:IsOpen() then
			RollingBarrageCtrl.Instance.view:Close()
		end
	end
end

function WeddingFuBenView:GetIsOpenDanMu()
	return self.is_open_danmu
end

----------------QuestionRankCell
---------------------------------------
QuestionRankCell = QuestionRankCell or BaseClass(BaseCell)

function QuestionRankCell:__init()
	self.rank = self:FindVariable("rank")
	-- self.rank_icon = self:FindVariable("icon")
	self.name = self:FindVariable("name")
	self.score = self:FindVariable("score")
end

function QuestionRankCell:__delete()
	
end

function QuestionRankCell:OnFlush()
	if self.data == nil then
		return
	end
	self.rank:SetValue(self.data.rank)
	self.name:SetValue(self.data.name)
	self.score:SetValue(self.data.score)
	-- if self.data.rank <= 3 and self.data.rank > 0 then
	-- 	local bundle, asset = ResPath.GetRankIcon(self.data.rank)
	-- 	self.rank_icon:SetAsset(bundle, asset)
	-- end

end