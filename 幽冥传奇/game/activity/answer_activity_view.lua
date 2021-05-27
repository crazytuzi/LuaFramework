AnswerActivityView = AnswerActivityView or BaseClass(XuiBaseView)

function AnswerActivityView:__init()
	self.texture_path_list[1] = 'res/xui/activity.png'
	self.config_tab = {
		{"welkin_ui_cfg", 3, {0}},
	}
	self.answer_activity_id = nil 
	self.level_subject = nil 
	self.remain_time = 0
	self.subject_content = nil 
	self.subject_score = nil 
	self.answer_t = {}
	self.bool_gery = false
	self.btn_type = nil 
	self.remain_time_2 = 0
end

function AnswerActivityView:__delete()

end

function AnswerActivityView:ReleaseCallBack()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	if self.timer_2 then
		GlobalTimerQuest:CancelQuest(self.timer_2)
		self.timer_2 = nil
	end
	if self.alert_window ~= nil then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
	if self.show_my_ranking then
		GlobalEventSystem:UnBind(self.show_my_ranking)
		self.show_my_ranking = nil
	end	
	if self.alert_close_window ~= nil then
		self.alert_close_window:DeleteMe()
		self.alert_close_window = nil
	end
end

function AnswerActivityView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		for i = 1, 4 do
			self.node_t_list["btn_"..i].node:addClickEventListener(BindTool.Bind(self.BtnAnswer, self, i))
		end
		self.node_t_list.btn_ok_onekey.node:addClickEventListener(BindTool.Bind(self.OneKeySure, self))
		self.node_t_list.btn_ranking_info.node:addClickEventListener(BindTool.Bind(self.OpenRankingView, self))
		self.node_t_list.btn_close.node:addClickEventListener(BindTool.Bind(self.CloseView, self))
		self.show_my_ranking = GlobalEventSystem:Bind(AllDayActivityEvent.ANSWER_RANKING_My_DATA,BindTool.Bind(self.ShowMyRanking, self))
		self.node_t_list.effect_1.node:setVisible(false)
		GlobalEventSystem:Bind(ObjectEventType.OBJ_BUFF_CHANGE, BindTool.Bind(self.OnObjBuffChange, self))
	end
end

function AnswerActivityView:OpenRankingView()
	MagicCityCtrl.Instance:ReqRankinglistData(MagicCityRankingListData_TYPE.AnswerQuestionTadayRanking) -- 活动答题共用排行榜， 不区分类型
end

function AnswerActivityView:OneKeySure()
	if self.answer_activity_id and self.level_subject then
		if self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
			ActivityCtrl.Instance:ReqApplyAnswer(self.answer_activity_id, self.level_subject, ANSWER_OPRETE_TYPE.ONE_KEY_SURE, 0)
		end
	end
end

function AnswerActivityView:BtnAnswer(type)
	self.btn_type = type
	local answer_activity_id, level_subject = ActivityData.Instance:GetAnswerData()
	if answer_activity_id and level_subject then
		if answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
			ActivityCtrl.Instance:ReqApplyAnswer(answer_activity_id, level_subject, ANSWER_OPRETE_TYPE.SELECT_ANSWER, type)
		else
			local x,y = ActivityData.Instance:GetRandArea(type)
			Scene.Instance:GetMainRole():StopMove() --移动是停止动作
			Scene.Instance:GetMainRole():LeaveFor(SceneAnswerConfig.sceneId, x, y)
			ActivityData.Instance:SetSelectData(type)
		end
		local pos = self.node_t_list["btn_"..type].node:getPositionX()
		self.node_t_list.effect_1.node:setPositionX(pos)
		self.node_t_list.effect_1.node:setVisible(true)
	end
end

function AnswerActivityView:SetBtnCanTouchEnabled(bool)
	for i = 1, 4 do
		if self.node_t_list["btn_"..i] ~= nil then
			XUI.SetButtonEnabled(self.node_t_list["btn_"..i].node, bool)
		end
	end
	if self.node_t_list.btn_ok_onekey ~=nil then
		XUI.SetButtonEnabled(self.node_t_list.btn_ok_onekey.node, bool)
	end
end

function AnswerActivityView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AnswerActivityView:ShowIndexCallBack(index)
	self:Flush(index)
end

function AnswerActivityView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新界面
function AnswerActivityView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self.answer_activity_id, self.level_subject, self.subject_content, self.subject_score, self.answer_t = ActivityData.Instance:GetAnswerData()
			if self.level_subject ~= nil and self.subject_score ~= nil then
				self.node_t_list.txt_name_1.node:setString(string.format(Language.AllDayActivity.Level_subject, self.level_subject, self.subject_score))
			end
			for k, v in pairs(self.answer_t) do
				self.node_t_list["btn_"..k].node:setTitleText(v.answer_content)
			end
			if self.timer_2 then
				GlobalTimerQuest:CancelQuest(self.timer_2)
				self.timer_2 = nil
			end
			self.node_t_list.txt_next_time.node:setString("")
			RichTextUtil.ParseRichText(self.node_t_list.rict_text.node, self.subject_content, 24)
			XUI.SetRichTextVerticalSpace(self.node_t_list.rict_text.node,4)
			self.node_t_list.effect_1.node:setVisible(false)
			self.node_t_list.txt_name.node:setString(Language.AllDayActivity.Answer_Activity_Name[self.answer_activity_id] or "")
			local num = 0
			if self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
				num = PersonAnswerConfig.answerNum
				self.node_t_list.img_title_bg.node:loadTexture(ResPath.GetActivityPic("answer_activity"))
				self.node_t_list.btn_ok_onekey.node:setVisible(true)
				self.node_t_list.btn_ranking_info.node:setPositionX(508)
				self.node_t_list.txt_my_ranking.node:setPositionX(426)
				self.node_t_list.txt_consume_gold.node:setVisible(true)
				self.node_t_list.txt_my_buff.node:setVisible(false)
				self.node_t_list.txt_consume_gold.node:setString(string.format(Language.AllDayActivity.ConsumeGold, PersonAnswerConfig.oneKeyFee.count))
			else
				num = SceneAnswerConfig.answerNum
				self.node_t_list.img_title_bg.node:loadTexture(ResPath.GetActivityPic("answer_activity_2"))
				self.node_t_list.btn_ok_onekey.node:setVisible(false)
				self.node_t_list.btn_ranking_info.node:setPositionX(408)
				self.node_t_list.txt_my_ranking.node:setPositionX(316)
				self.node_t_list.txt_consume_gold.node:setVisible(false)
				self:OnObjBuffChange()
				if ActivityData.Instance:GetSelectdata() ~= 0 then
					local btn_type = ActivityData.Instance:GetSelectdata()
					local pos = self.node_t_list["btn_"..btn_type].node:getPositionX()
					self.node_t_list.effect_1.node:setPositionX(pos)
					self.node_t_list.effect_1.node:setVisible(true)
				else
					self.node_t_list.effect_1.node:setVisible(false)
				end
			end 
			local txt = string.format(Language.AllDayActivity.Answer_Question_num, num)
			self.node_t_list.txt_num.node:setString(txt)
			self.bool_gery = true
			local bool = ActivityData.Instance:GetHadBoolGery()
			self:SetBtnCanTouchEnabled(bool)
			self.remain_time = ActivityData.Instance:GetRemainTime() 
			
			if self.timer then
				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
			end
			
			if self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
				self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushSubjectTime, self),  1)
				self:FlushSubjectTime()
			end
		elseif k == "bool_select" then
			if self.answer_activity_id == ANSWERACTIVITY.SceneQuestion then
				self:SetBtnCanTouchEnabled(false)
			end 
			if self.timer_2 then
				GlobalTimerQuest:CancelQuest(self.timer_2)
				self.timer_2 = nil
			end
			if self.timer then
				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
			end
			self.node_t_list.txt_remian_time.node:setString("")
			if self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
				self.remain_time_2 = ActivityData.Instance:GetNextSubjectTime()
				self.timer_2 = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushCDTime, self),  1)
				self:FlushCDTime()
			end

			local _, level_subject = ActivityData.Instance:GetAnswerData()
			--print("44444444444", level_subject, PersonAnswerConfig.answerNum)
			if level_subject == PersonAnswerConfig.answerNum and self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
				if nil == self.alert_close_window then
					self.alert_close_window = Alert.New()
				end
				self.alert_close_window:Open()
				self.alert_close_window:UseOne()
				self.alert_close_window:SetLableString(Language.AllDayActivity.CloseTip)
				self.alert_close_window:SetOkFunc(function()
					self:Close()
				end)
				self.alert_close_window:SetCloseFunc(function()
					self:Close()
				end)
			end
		elseif k == "enabled_false" then

			self:SetBtnCanTouchEnabled(false)
			self.bool_gery = false
			local oprate_type, oprate_can_shu = ActivityData.Instance:GetAnswerOprateResult()
			if oprate_type == 2 then
				local pos = self.node_t_list["btn_"..oprate_can_shu].node:getPositionX()
				self.node_t_list.effect_1.node:setPositionX(pos)
				self.node_t_list.effect_1.node:setVisible(true)
			end
			
		end
	end
	local rank = MagicCityData.Instance:GetMyRankingData()
	self:ShowMyRanking(rank)
end

function AnswerActivityView:FlushSubjectTime()
	local time = self.remain_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		self.node_t_list.txt_remian_time.node:setString("")
		return
	end
	local bool = true 
	if time < 1 or self.bool_gery == false then --小于1秒就不可点
		bool = false
	end
	self:SetBtnCanTouchEnabled(bool)
	
	local time_dao = TimeUtil.FormatSecond2Str(time)
	local txt = string.format(Language.Tip.ItemTip, time_dao)
	self.node_t_list.txt_remian_time.node:setString(txt)
end

function AnswerActivityView:FlushCDTime()
	local time = self.remain_time_2 - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		self.node_t_list.txt_next_time.node:setString("")
		return
	end
	local time_dao = TimeUtil.FormatSecond2Str(time)
	local txt = string.format(Language.AllDayActivity.Next_Subject, time_dao)
	self.node_t_list.txt_next_time.node:setString(txt)
end

function AnswerActivityView:CloseView()
	if self.answer_activity_id == ANSWERACTIVITY.PerssonalQuestion then
		if nil == self.alert_window then
			self.alert_window = Alert.New()
		end
		self.alert_window:SetLableString(Language.AllDayActivity.DescTipsClose)
		self.alert_window:SetOkFunc(function()
						if self.answer_activity_id and self.level_subject then
							ActivityCtrl.Instance:ReqApplyAnswer(self.answer_activity_id, self.level_subject, ANSWER_OPRETE_TYPE.STOP_ANSWER, 0)
						end
						self:Close()
						ViewManager.Instance:Close(ViewName.AnswerActivityTip)
					end)
		self.alert_window:Open()	
	else
		self:Close()
	end
end

function AnswerActivityView:ShowMyRanking(rank)
	if self.node_t_list.txt_my_ranking ~= nil then
		local txt = ""
		if rank == 0 or rank == nil  then
			txt = string.format(Language.AllDayActivity.MyRanking, Language.Guild.WeiShangBang)	
		else
			txt = string.format(Language.AllDayActivity.MyRanking, rank or "")
		end
		self.node_t_list.txt_my_ranking.node:setString(txt)
	end
end

function AnswerActivityView:OnObjBuffChange()
	local mainrole_vo = Scene.Instance:GetMainRole():GetVo()
	if nil == mainrole_vo.buff_list or MainuiBuffRender.ColCount <= 0 then
		return
	end
	local txt = ""
	for k, v in pairs(mainrole_vo.buff_list) do
		if v.buff_id == 989 or v.buff_id == 990 then
			txt = v.buff_name
		end
	end
	if txt == "" then
		txt = Language.Common.No
	end
	if self.answer_activity_id == ANSWERACTIVITY.SceneQuestion then
		if self.node_t_list.txt_my_buff ~= nil then
			self.node_t_list.txt_my_buff.node:setString(string.format(Language.AllDayActivity.BuffEffect, txt))
			self.node_t_list.txt_my_buff.node:setVisible(true)
		end
	end
end