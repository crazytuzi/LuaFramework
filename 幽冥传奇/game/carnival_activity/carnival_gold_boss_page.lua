-- 神装boss页面
CarnivalGoldBossPage = CarnivalGoldBossPage or BaseClass()

function CarnivalGoldBossPage:__init()
	self.view = nil
end

function CarnivalGoldBossPage:__delete()
	self:RemoveEvent()

	self.view = nil
end

function CarnivalGoldBossPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_go_charge_now_1.node, BindTool.Bind(self.OnSigninClicked, self), true)
	self:InitEvent()
end

function CarnivalGoldBossPage:InitEvent()
	-- self.sign_in_data_event = GlobalEventSystem:Bind(WelfareEventType.SIGN_IN_DATA_CHANGE, BindTool.Bind(self.OnSignInDataChange, self))
end

function CarnivalGoldBossPage:RemoveEvent()
	-- if self.sign_in_data_event then
	-- 	GlobalEventSystem:UnBind(self.sign_in_data_event)
	-- 	self.sign_in_data_event = nil
	-- end
end


--更新视图界面
function CarnivalGoldBossPage:UpdateData(data)
	local tempData = CarnivalData.Instance:getCarnivaGoldBoss()
	if tempData then
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_activity_common_boss.node,tempData.actDesc,20,cc.c3b(0xff, 0xff, 0xff))
		local open_days =  OtherData.Instance:GetOpenServerDays()
		if tempData.enterLevelLimit[open_days] then
			self.view.node_t_list.boss_can_fit.node:setString(string.format(Language.Consign.ItemLevelZhuan, tempData.enterLevelLimit[open_days][1], tempData.enterLevelLimit[open_days][2]))
		end
		if tempData and tempData.startDay and tempData.endDay then
			local time_util = TimeUtil.CONST_3600*TimeUtil.CONST_24
			local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
			local ta_server = os.date("*t", server_time)
			server_time = server_time-(ta_server.hour*TimeUtil.CONST_3600+ta_server.min*TimeUtil.CONST_60+ta_server.sec)
			server_time = server_time-time_util*open_days
			server_time = server_time+time_util*tempData.startDay
			local format_time_begin = os.date("*t", server_time)

			if tempData.endDay > tempData.startDay then
				local left = tempData.endDay-tempData.startDay
				server_time= server_time+time_util*left
			end
			local format_time_end = os.date("*t", server_time)
			self.view.node_t_list.txt_time_common_boss.node:setString(format_time_begin.year.."/"..format_time_begin.month.."/"..format_time_begin.day.."-"..format_time_end.year.."/"..format_time_end.month.."/"..format_time_end.day)
		end

	end
	local at_state,boss_state =  CarnivalData.Instance:getBossData()
	self.view.node_t_list.txt_boss_state.node:setString(Language.Carnival.TxtBoss1)
	self.view.node_t_list.txt_boss_state.node:setVisible(boss_state==1)
end	

function CarnivalGoldBossPage:SelectItemCallBack(item)
	-- if item == nil or item:GetData() == nil then return end
	-- local data = item:GetData()
	-- local today_sign_state = WelfareData.Instance:GetTodaySignState()
	-- for k, v in pairs(self.grid_scroll:GetItems()) do
	-- end
end

function CarnivalGoldBossPage:OnSigninClicked()
	CarnivarCtrl.Instance:SendCarnivalBoss()
end

function CarnivalGoldBossPage:OnSignInDataChange()

end