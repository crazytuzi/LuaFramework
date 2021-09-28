require("game/one_yuan_snatch/snatch_content_view")
require("game/one_yuan_snatch/integral_content_view")
require("game/one_yuan_snatch/log_content_view")
require("game/one_yuan_snatch/ticket_content_view")


OneYuanSnatchView = OneYuanSnatchView or BaseClass(BaseView)

local Tab_list = {
	[1] = TabIndex.one_yuan_panel_snatch,
	[2] = TabIndex.one_yuan_panel_integral,
	[3] = TabIndex.one_yuan_panel_log,
	[4] = TabIndex.one_yuan_panel_ticket,
}



function OneYuanSnatchView:__init(instance)
	self.ui_config = {"uis/views/oneyuansnatch_prefab", "OneYuanSnatchView"}
	self.play_audio = true

	self.def_index = TabIndex.one_yuan_panel_ticket
end

function OneYuanSnatchView:__delete()

end

function OneYuanSnatchView:CloseCallBack()
	-- body
end

function OneYuanSnatchView:OpenCallBack()
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_INFO)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_BUY_RECORD)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_CONVERT_INFO)
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_SERVER_RECORD_INFO)

	self:ShowIndex(self.def_index)
	self:Flush()
end

function OneYuanSnatchView:ReleaseCallBack()
	self.show_act_time = nil
	self.act_time = nil

	self.snatch_content = nil
	self.jifen_content = nil
	self.log_content = nil
	self.ticket_content = nil

	self.toggle_list = nil

	if self.snatch_view then
		self.snatch_view:DeleteMe()
		self.snatch_view = nil
	end

	if self.integral_view then
		self.integral_view:DeleteMe()
		self.integral_view = nil
	end

	if self.log_view then
		self.log_view:DeleteMe()
		self.log_view = nil
	end

	if self.ticket_view then
		self.ticket_view:DeleteMe()
		self.ticket_view = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function OneYuanSnatchView:LoadCallBack()
	self.show_act_time = self:FindVariable("show_act_time")
	self.act_time = self:FindVariable("act_time")


	self.snatch_content = self:FindObj("SnatchContent")
	self.jifen_content = self:FindObj("JiFenContent")
	self.log_content = self:FindObj("LogContent")
	self.ticket_content = self:FindObj("TicketContent")

	self.toggle_list = {}

	for i = 1, 4 do
		self.toggle_list[i] = self:FindObj("Toggle" .. i).toggle
		self.toggle_list[i].isOn = false
	end
	self.toggle_list[4].isOn = true

	self:ListenEvent("Close",BindTool.Bind(self.CloseView,self))

	for i = 1, 4 do
		self:ListenEvent("ToggleClick" .. i,BindTool.Bind(self.OnToggleClick,self, Tab_list[i]))
	end
end

function OneYuanSnatchView:CloseView()
	self:Close()
end

function OneYuanSnatchView:OnFlush(param_list)

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	if param_list then
		for k, v in pairs(param_list) do
			if k == "snatch" and self.snatch_view then
				self.snatch_view:Flush()
			elseif k == "integral" and self.integral_view then
				self.integral_view:Flush()
			elseif k == "log" and self.log_view then
				self.log_view:Flush()
			elseif k == "ticket" and self.ticket_view then
				self.ticket_view:Flush()
			end
		end
	end
end

function OneYuanSnatchView:OnToggleClick(index)
	if index == self.show_index then
		return
	end
	self:ShowIndex(index)
end

function OneYuanSnatchView:FlushToggleHightlight(index)
	if self.toggle_list then
		for i = 1, 4 do
			if self.toggle_list[i] then
				self.toggle_list[i].isOn = (index == Tab_list[i])
			end
		end
	end
end

function OneYuanSnatchView:ShowIndexCallBack(index)
	index = index or self.def_index

	self:AsyncLoadView(index)

	self:FlushToggleHightlight(index)

	if index == TabIndex.one_yuan_panel_snatch then
		if self.snatch_view then
			self.snatch_view:OpenCallBack()
		end
	end

	if index == TabIndex.one_yuan_panel_integral then
		if self.integral_view then
			self.integral_view:OpenCallBack()
		end
	end

	if index == TabIndex.one_yuan_panel_log then
		if self.log_view then
			self.log_view:OpenCallBack()
		end
	end

	if index == TabIndex.one_yuan_panel_ticket then
		if self.ticket_view then
			self.ticket_view:OpenCallBack()
		end
	end

	self.show_index = index

	self.show_act_time:SetValue(self.show_index ~= TabIndex.one_yuan_panel_log)
end

function OneYuanSnatchView:AsyncLoadView(index)
	index = index or self.def_index

	if index == TabIndex.one_yuan_panel_snatch then
		if self.snatch_view then return end	

		UtilU3d.PrefabLoad("uis/views/oneyuansnatch_prefab", "SnatchContent",
			function(obj)
				obj.transform:SetParent(self.snatch_content.transform, false)
				obj = U3DObject(obj)
				self.snatch_view = SnatchContentView.New(obj)
				self.snatch_view:OpenCallBack()
			end)
		
	elseif index == TabIndex.one_yuan_panel_integral then
		if self.integral_view then return end	

		UtilU3d.PrefabLoad("uis/views/oneyuansnatch_prefab", "IntegralContent",
			function(obj)
				obj.transform:SetParent(self.jifen_content.transform, false)
				obj = U3DObject(obj)
				self.integral_view = IntegralContentView.New(obj)
				self.integral_view:OpenCallBack()
			end)
		
	elseif index == TabIndex.one_yuan_panel_log then
		if self.log_view then return end	

		UtilU3d.PrefabLoad("uis/views/oneyuansnatch_prefab", "LogContent",
			function(obj)
				obj.transform:SetParent(self.log_content.transform, false)
				obj = U3DObject(obj)
				self.log_view = SnatchLogView.New(obj)
				self.log_view:OpenCallBack()
			end)
		
	elseif index == TabIndex.one_yuan_panel_ticket then
		if self.ticket_view then return end	

		UtilU3d.PrefabLoad("uis/views/oneyuansnatch_prefab", "TicketContent",
			function(obj)
				obj.transform:SetParent(self.ticket_content.transform, false)
				obj = U3DObject(obj)
				self.ticket_view = SnatchTicketView.New(obj)
				self.ticket_view:OpenCallBack()
			end)
		
	end
	
end

function OneYuanSnatchView:FlushNextTime()
	local act_info = ActivityData.Instance:GetCrossRandActivityStatusByType(ACTIVITY_TYPE.KF_ONEYUANSNATCH)
	local time = 0
	if act_info and act_info.status == ACTIVITY_STATUS.OPEN and act_info.next_time then
		time = act_info.next_time - TimeCtrl.Instance:GetServerTime()
	end	
	
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		return 
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end
	
	if self.act_time then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, time_type))
	end
end





