local OpenServiceAcitivityLuckyDrawView = OpenServiceAcitivityLuckyDrawView or BaseClass(SubView)

function OpenServiceAcitivityLuckyDrawView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 7, {0}},
	}
end

function OpenServiceAcitivityLuckyDrawView:LoadCallBack()
	self.panel_info = OpenServiceAcitivityData.Instance:GetDrawInfo()
	self:CreateDrawItem()
	self:CreateCheckBox()
	self:CreateCountdownNum()
	self:CreateDrawRecordText()
	self:CreateConsumeNumberBar()
	XUI.AddClickEventListener(self.node_t_list.layout_draw_btn.node, BindTool.Bind(self.OnClickDraw, self), true)
	self.event_proxy = EventProxy.New(OpenServiceAcitivityData.Instance, self)
	self.event_proxy:AddEventListener(OpenServiceAcitivityData.LuckyDrawChange, BindTool.Bind(self.OnFlushDrawView, self))
	self.event_proxy:AddEventListener(OpenServiceAcitivityData.LuckyStartDraw, BindTool.Bind(self.ReturnDrawResult, self))
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 19, COLOR3B.OLIVE)
end

function OpenServiceAcitivityLuckyDrawView:ReleaseCallBack()
	self.panel_info = {}

	for k, v in pairs(self.draw_item_list) do
		v:DeleteMe()
		v = nil
	end
	self.draw_item_list = nil

	if self.tiner1 ~= nil then
		self.CountDownInstance:RemoveCountDown(self.tiner1)
	end
	if self.day_num then
		self.day_num:DeleteMe()
		self.day_num = nil
	end
	if self.hour_num then
		self.hour_num:DeleteMe()
		self.hour_num = nil
	end
	if self.minute_num then
		self.minute_num:DeleteMe()
		self.minute_num = nil
	end
	if self.consume_num then
		self.consume_num:DeleteMe()
		self.consume_num = nil
	end
	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.record_text = nil

	self.check_box = nil
end

function OpenServiceAcitivityLuckyDrawView:CloseCallBack()
	if self.check_box then 
		self.check_box.status = false
		self.check_box.node:setVisible(self.check_box.status)
	end

	if self.tiner1 then
		self.CountDownInstance:RemoveCountDown(self.tiner1)
	end

	if self.draw_timer_quest then
		GlobalTimerQuest:CancelQuest(self.draw_timer_quest)
	end

	if self.node_t_list.layout_draw_btn then
		self:SetDrawBtnEnabled(true)
	end

	BagData.Instance:SetDaley(false)
end

function OpenServiceAcitivityLuckyDrawView:ShowIndexCallBack()
	self:OnFlushDrawView()
	-- self.is_draw = false
	-- self.cur_draw_index = 0
end

function OpenServiceAcitivityLuckyDrawView:OnClickDraw()
	OpenServiceAcitivityCtrl.SendDraw(1)
	if not self.check_box.status then
		BagData.Instance:SetDaley(true)
	end

	if self.check_box.status then
		self:SetDrawBtnEnabled(false)
	end

	-- if self.check_box.status then
	-- 	OpenServiceAcitivityCtrl.SendDraw(1)
	-- else
	-- 	if self.panel_info.draw_left_times > 0 then
	-- 		if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() > 0 then
	-- 			self:ReadyStartDraw()
	-- 		else
	-- 			SysMsgCtrl.Instance:FloatingTopRightText("{wordcolor;ffff00;背包不足一格,请清理背包！}")	
	-- 		end
	-- 	else
	-- 		SysMsgCtrl.Instance:FloatingTopRightText("{wordcolor;ffff00;没有抽奖次数}")
	-- 	end
	-- end
end

function OpenServiceAcitivityLuckyDrawView:CreateCountdownNum()
	local x, y = 0, 0
	if self.day_num == nil then
		local ph_day = self.ph_list.ph_day
		x, y = ph_day.x, ph_day.y
		self.day_num = NumberBar.New()
		self.day_num:SetRootPath(ResPath.GetCommon("num_150_"))
		self.day_num:SetPosition(x, y - 10)
		self.day_num:SetSpace(-1)
		self.day_num:SetGravity(NumberBarGravity.Center)
		self.node_t_list.layout_lucky_draw.node:addChild(self.day_num:GetView(), 100, 100)
	end
	if self.hour_num == nil then
		local ph_hour = self.ph_list.ph_hour
		x = ph_hour.x
		self.hour_num = NumberBar.New()
		self.hour_num:SetRootPath(ResPath.GetCommon("num_150_"))
		self.hour_num:SetPosition(x, y - 10)
		self.hour_num:SetSpace(-1)
		self.hour_num:SetGravity(NumberBarGravity.Center)
		self.node_t_list.layout_lucky_draw.node:addChild(self.hour_num:GetView(), 100, 100)
	end
	if self.minute_num == nil then
		local ph_minute = self.ph_list.ph_minute
		x = ph_minute.x
		self.minute_num = NumberBar.New()
		self.minute_num:SetRootPath(ResPath.GetCommon("num_150_"))
		self.minute_num:SetPosition(x, y - 10)
		self.minute_num:SetSpace(-1)
		self.minute_num:SetGravity(NumberBarGravity.Center)
		self.node_t_list.layout_lucky_draw.node:addChild(self.minute_num:GetView(), 100, 100)
	end
end

function OpenServiceAcitivityLuckyDrawView:CreateDrawRecordText()
	if self.record_text then return end
	local x, y = self.ph_list.ph_server_recording.x, self.ph_list.ph_server_recording.y
	self.record_text = RichTextUtil.CreateLinkText("本服抽奖记录", 17, COLOR3B.GREEN, nil, true)
	self.record_text:setPosition(x, y)
	self.node_t_list.layout_lucky_draw.node:addChild(self.record_text, 10)
	XUI.AddClickEventListener(self.record_text, BindTool.Bind(self.OnClickDrawRecord, self), true)
end

function OpenServiceAcitivityLuckyDrawView:CreateConsumeNumberBar()
	if self.consume_num ~= nil then return end
	local ph = self.ph_list.ph_draw_consume
	local x, y = ph.x, ph.y
	self.consume_num = NumberBar.New()
	self.consume_num:SetRootPath(ResPath.GetCommon("num_152_"))
	self.consume_num:SetPosition(x, y - 15)
	self.consume_num:SetSpace(-5)
	self.consume_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_lucky_draw.node:addChild(self.consume_num:GetView(), 100, 100)
end

function OpenServiceAcitivityLuckyDrawView:CreateCheckBox()
	self.check_box = check_box or {}
	self.check_box.status = false
	self.check_box.node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box.node:setVisible(self.check_box.status)
	self.node_t_list.layout_extraction_all.node:addChild(self.check_box.node, 10)
	XUI.AddClickEventListener(self.node_t_list.layout_extraction_all.node, BindTool.Bind(self.OnClickSelectBoxHandler, self), true)
end

function OpenServiceAcitivityLuckyDrawView:OnClickSelectBoxHandler()
	if self.check_box == nil then return end
	self.check_box.status = not self.check_box.status
	self.check_box.node:setVisible(self.check_box.status)
end

function OpenServiceAcitivityLuckyDrawView:OnClickDrawRecord()
	ViewManager.Instance:OpenViewByDef(ViewDef.OpenServiceAcitivityDrawRecord)
	OpenServiceAcitivityCtrl.SendDrawServerRecording()
end

function OpenServiceAcitivityLuckyDrawView:OnFlushDrawView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetDrawInfo()
	self.node_t_list.lbl_left_draw_times.node:setString(self.panel_info.draw_left_times)
	self.day = self.panel_info.time.day
	self.hour = self.panel_info.time.hour
	self.minute = self.panel_info.time.min
	self.day_num:SetNumber(self.day)
	self.hour_num:SetNumber(self.hour)
	self.minute_num:SetNumber(self.minute)
	self.consume_num:SetNumber(self.panel_info.draw_consume)
	self.node_t_list.lbl_activity_time.node:setString(self.panel_info.activity_time_interval)

	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.consume_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetCountdown, self), 60)
end

-- 返回抽奖结果
function OpenServiceAcitivityLuckyDrawView:ReturnDrawResult()
	self.cur_draw_index = self.panel_info.draw_index
	self:OnFlushDrawView()
	if self.check_box.status and self.panel_info.draw_left_times > 0 then
		GlobalTimerQuest:AddDelayTimer(function ()
			OpenServiceAcitivityCtrl.SendDraw(1)
		end, 60 / 600)
		return
	end

	self:StartDraw()
end

function OpenServiceAcitivityLuckyDrawView:StartDraw()
	self:SetDrawBtnEnabled(false)
	self.selectIndex = 1
	self.runTime = 0.05
	self.CountDownInstance = CountDown.Instance
	self.tiner1 = self.CountDownInstance:AddCountDown(1, self.runTime, BindTool.Bind(self.ChangeSelect, self))
	self.draw_item_data_length = #self.panel_info.award_list
end

function OpenServiceAcitivityLuckyDrawView:SetCountdown()
	self.minute = self.minute - 1
	if self.minute < 0 then
		self.minute = 59
		self.hour = self.hour - 1
		if self.hour < 0 then
			self.hour = 23
			self.day = self.day - 1
			if self.day < 0 then
				----------------------------------------------------------
				OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()
				----------------------------------------------------------
			end
		end
	end
	self.day_num:SetNumber(self.day)
	self.hour_num:SetNumber(self.hour)
	self.minute_num:SetNumber(self.minute)
end

-- function OpenServiceAcitivityLuckyDrawView:ReadyStartDraw()
-- 	-- self:OnFlushDrawView()
-- 	self:StartDraw()
-- end

function OpenServiceAcitivityLuckyDrawView:ChangeSelect()
	if self.selectIndex == self.draw_item_data_length + 1 then
		self.selectIndex = self.selectIndex - self.draw_item_data_length
	end
	self.draw_item_list[self.selectIndex]:SetSelect(true)
	for k, v in pairs(self.draw_item_list) do
		if k ~= self.selectIndex then
			v:SetSelect(false)
		end
	end
	
	local time = self.CountDownInstance:GetRemainTime(self.tiner1)
	if self.runTime > 0.1 then
		-- if not self.is_draw then
		-- 	OpenServiceAcitivityCtrl.SendDraw(0)
		-- 	self.is_draw = true
		-- end
		-- self.runTime = 0.00001
		-- self.CountDownInstance:RemoveCountDown(self.tiner1)
		-- self.tiner1 = self.CountDownInstance:AddCountDown(0.1, self.runTime, BindTool.Bind(self.ChangeSelect, self))
		-- self.panel_info = OpenServiceAcitivityData.Instance:GetDrawInfo()
		if self.cur_draw_index == self.selectIndex then
			self.CountDownInstance:RemoveCountDown(self.tiner1)
			self:EndDraw()
			return
		end
	end
	self.selectIndex = self.selectIndex + 1
	-- if time < 0.1 then
	-- 	if not self.is_draw then
	-- 		self.runTime = self.runTime + 0.08
	-- 	end
	-- 	self.CountDownInstance:RemoveCountDown(self.tiner1)
	-- 	self.tiner1 = self.CountDownInstance:AddCountDown(1.5, self.runTime, BindTool.Bind(self.ChangeSelect, self))
	-- end
	if time < 0.1 and not self.is_draw then
		self.runTime = self.runTime + 0.06
		self.CountDownInstance:RemoveCountDown(self.tiner1)
		self.tiner1 = self.CountDownInstance:AddCountDown(1, self.runTime, BindTool.Bind(self.ChangeSelect, self))
	end
end

function OpenServiceAcitivityLuckyDrawView:EndDraw()
	if self.draw_timer_quest then
		GlobalTimerQuest:CancelQuest(self.draw_timer_quest)
	end
	self.draw_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetDrawBtnEnabled, self, true), 1)
	BagData.Instance:SetDaley(false)
	-- self:SetDrawBtnEnabled(true)
end

function OpenServiceAcitivityLuckyDrawView:SetDrawBtnEnabled(is_enabled)
	GlobalTimerQuest:CancelQuest(self.draw_timer_quest)
	self.node_t_list.layout_draw_btn.img_bg.node:setGrey(not is_enabled)
	self.node_t_list.layout_draw_btn.img_word.node:setGrey(not is_enabled)
	XUI.SetButtonEnabled(self.node_t_list.layout_draw_btn.node, is_enabled)
	if is_enabled then
		self:UpdateAward()
		-- self.is_draw = false
		self.cur_draw_index = 0
	end
end

function OpenServiceAcitivityLuckyDrawView:CreateDrawItem()
	if self.draw_item_list then return end
	self.draw_item_list = {}
	local ph = self.ph_list.ph_award
	local x = 0
	local y = 0
	for i = 1, 18 do 
		award_cell = BaseCell.New()
		if i <= 7 then
			x = ph.x + (i - 1)  * 100
			y = ph.y
		elseif i <= 10 then
			x = ph.x + 6 * 100
			y = ph.y - (i - 7) * 100
		elseif i <= 16 then
			x = ph.x + (16 - i) * 100
		elseif i <= 18 then
			x = ph.x
			y = ph.y - (19 - i) * 100
		end
		award_cell:SetPosition(x, y)
		award_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_lucky_draw.node:addChild(award_cell:GetView(), 99)
		table.insert(self.draw_item_list, award_cell)
	end
	self:UpdateAward()
end

function OpenServiceAcitivityLuckyDrawView:UpdateAward()
	self.panel_info = OpenServiceAcitivityData.Instance:GetDrawInfo()
	for k, v in pairs(self.panel_info.award_list) do
		self.draw_item_list[k]:SetData(v)
		self.draw_item_list[k]:SetSelect(false)
	end
end

return OpenServiceAcitivityLuckyDrawView