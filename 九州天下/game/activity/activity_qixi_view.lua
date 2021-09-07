ActivityQiXiView = ActivityQiXiView or BaseClass(BaseView)

function ActivityQiXiView:__init()
	self.ui_config = {"uis/views/activityview","ActivityQiXiView"}
	self.play_audio = true
	self.select_index = nil
	self.delay_tiemr = nil

	self.remind_call = BindTool.Bind(self.FlushRed, self)
end

function ActivityQiXiView:__delete()

end

function ActivityQiXiView:ReleaseCallBack()
	if self.act_list ~= nil then
		for k,v in pairs(self.act_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.act_list = nil
	end

	self.red_point_list = nil

	if RemindManager.Instance and self.remind_call then
		RemindManager.Instance:UnBind(self.remind_call)
		self.remind_call = nil
	end
	self.select_index = nil

	if self.delay_tiemr ~= nil and GlobalTimerQuest then
		GlobalTimerQuest:CancelQuest(self.delay_tiemr)
		self.delay_tiemr = nil
	end

	self.time_str = nil
end

function ActivityQiXiView:LoadCallBack()
	self.act_list = {}
	for i = 1, 4 do
		local act = self:FindObj("ActRener" .. i)
		local render = ActQiXiRender.New(act)
		self.act_list[i] = render
	end

	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))


	self.red_point_list = {}
	for i = 1, 4 do
		local data = ACTIVITY_ACT_QIXI_DATA[i]
		if data ~= nil and data.remind ~= nil and data.remind ~= "" then
			if RemindName[data.remind] ~= nil then
				self.red_point_list[RemindName[data.remind]] = i
			end
		end
	end

	if self.remind_call then
		for k, _ in pairs(self.red_point_list) do
			RemindManager.Instance:Bind(self.remind_call, k)
		end
	end

	self.time_str = self:FindVariable("TimeStr")
end

function ActivityQiXiView:FlushRed(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		local key = self.red_point_list[remind_name]
		if self.act_list ~= nil and self.act_list[key] ~= nil then
			self.act_list[key]:ShowRed(num > 0)
		end
	end
end

function ActivityQiXiView:OpenCallBack()
end

function ActivityQiXiView:CloseCallBack()
	self.select_index = nil

	if self.delay_tiemr ~= nil and GlobalTimerQuest then
		GlobalTimerQuest:CancelQuest(self.delay_tiemr)
		self.delay_tiemr = nil
	end
end

function ActivityQiXiView:ShowIndexCallBack()
	self:Flush()
end

function ActivityQiXiView:OnFlush()
	if self.act_list ~= nil then
		for k,v in pairs(self.act_list) do
			local data = ACTIVITY_ACT_QIXI_DATA[k]
			if v ~= nil and data ~= nil then
				data.is_select = self.select_index ~= nil and self.select_index == data.act_id or false
				data.show_red = false
				if data.remind ~= nil and RemindName[data.remind] ~= nil then
					data.show_red = RemindManager.Instance:GetRemind(RemindName[data.remind]) > 0
				end
				v:SetData(data)
			end
		end 
	end

	if self.time_str ~= nil then
		self.time_str:SetValue(Language.Activity.QiXiActTime)
	end
end

function ActivityQiXiView:CloseView()
	self:Close()
end

function ActivityQiXiView:SetOpenView(view_str, act_id)
	if self.delay_tiemr ~= nil and GlobalTimerQuest then
		GlobalTimerQuest:CancelQuest(self.delay_tiemr)
		self.delay_tiemr = nil
	end

	if act_id == nil or view_str == nil or view_str == "" then
		return
	end

	self.select_index = act_id
	self:Flush()
	self.delay_tiemr = GlobalTimerQuest:AddDelayTimer(function()
		ViewManager.Instance:Open(view_str)
		end, 0.5)
end

-----------------------------------------------------------------------------
ActQiXiRender = ActQiXiRender or BaseClass(BaseCell)

function ActQiXiRender:__init()
	self.name = self:FindVariable("Name")
	self.show_red = self:FindVariable("ShowRed")
	self.show_select = self:FindVariable("ShowSelect")
	self.open_view = nil

	self:ListenEvent("OnClickAct", BindTool.Bind(self.OnClickAct, self))
end

function ActQiXiRender:__delete()
	self.open_view = nil
end

function ActQiXiRender:OnClickAct()
	if self.open_view ~= nil and self.data ~= nil and self.data.act_id ~= nil then
		--ViewManager.Instance:Open(self.open_view)
		ActivityCtrl.Instance:QiXiOpenView(self.open_view, self.data.act_id)
		if self.data.act_id == ACTIVITY_TYPE.CROSS_FLOWER_RANK then
			ClickOnceRemindList[RemindName.CrossFlowerRank] = 0
			RemindManager.Instance:CreateIntervalRemindTimer(RemindName.CrossFlowerRank)
		end
	end
end

function ActQiXiRender:OnFlush()	
	if self.data == nil or next(self.data) == nil then
		return
	end

	self.open_view = nil
	local cfg = nil
	if self.data.act_id ~= nil then
		cfg = ActivityData.Instance:GetClockActivityByID(self.data.act_id)
	end

	if cfg ~= nil and next(cfg) ~= nil then
		local act_data = ActivityData.Instance:GetActivityStatuByType(self.data.act_id)
		local str = ""
		if act_data == nil or (act_data ~= nil and act_data.status == ACTIVITY_STATUS.CLOSE) then
			str = Language.Role.ToExpect
		else
			self.open_view = cfg.open_name
			str = cfg.act_name
		end

		if self.name ~= nil then
			self.name:SetValue(str)
		end
	end

	if self.show_select ~= nil then
		self.show_select:SetValue(self.data.is_select)
	end

	self:ShowRed(self.data.show_red)
end

function ActQiXiRender:ShowRed(is_show)
	if self.show_red ~= nil then
		self.show_red:SetValue(is_show)
	end
end