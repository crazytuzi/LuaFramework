KaifuActivity7DayRedpacket = KaifuActivity7DayRedpacket or BaseClass(BaseRender)

local HONGBAO_ZHUANGTAI_FLAG = {
	[1] = {true, false, false},
	[2] = {false, true, false},
	[3] = {false, false, true},
}

function KaifuActivity7DayRedpacket:__init()
	self.leiji_diamonds = self:FindVariable("LeiJiDiamonds")
	self.final_rebate = self:FindVariable("FinalRebate")
	-- self.rebate_day = self:FindVariable("RebateDay")
	self.rebate_time = self:FindVariable("RebateTime")
	self.total_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.is_end = self:FindVariable("IsEnd")
	self.red_packet_list = {}
	for i = 1 , 7 do
		self.red_packet_list[i] = KaifuActivityRedpacketCell.New(self:FindObj("RedPacket" .. i))		
		self.red_packet_list[i]:FlushData(i, self.total_day)
	end

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "hongbao_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end

	self:FlushView()
end

function KaifuActivity7DayRedpacket:__delete()
	for i=1,7 do
		if self.red_packet_list[i]	then
			self.red_packet_list[i]:DeleteMe()
			self.red_packet_list[i] = nil
		end
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaifuActivity7DayRedpacket:FlushView()
	local recharge_list = ActiviteHongBaoData.Instance:GetDiamondNum()
	local rebate_val =  ActiviteHongBaoData.Instance:GetRebateTotalVal()
	self.total_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.total_day >= 8 then
		self.is_end:SetValue(false)
	end
	self.leiji_diamonds:SetValue(recharge_list[self.total_day])
	self.final_rebate:SetValue(rebate_val)
	if self.total_day < 8 then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time + (7 - self.total_day) * 24 * 3600
		self:SetRestTime(reset_time_s)
	end
	for i = 1 ,7 do
		self.red_packet_list[i]:FlushData(i, self.total_day)
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

function KaifuActivity7DayRedpacket:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_str = ""
			local left_day = math.floor(left_time / 86400)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 8)
			else
				time_str = TimeUtil.FormatSecond(left_time)
			end
			self.rebate_time:SetValue(time_str)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function KaifuActivity7DayRedpacket:OnFlush()
	self:FlushView()
end

-----红包cell
KaifuActivityRedpacketCell = KaifuActivityRedpacketCell or BaseClass(BaseRender)

function KaifuActivityRedpacketCell:__init()
	self.is_show_money = self:FindVariable("IsShowMoney")
	self.is_get = self:FindVariable("IsGet")
	self.is_can_get = self:FindVariable("IsCanGet")
	self.is_can_open = self:FindVariable("IsCanOpen")	
	self.amount = self:FindVariable("Amount")

	self:ListenEvent("OnOpenButtonClick", BindTool.Bind(self.OnOpenButtonClick, self))
end

function KaifuActivityRedpacketCell:__delete()

end

function KaifuActivityRedpacketCell:FlushData(index, cur_day)
	self.day = index or self.day
	local rebate_val = ActiviteHongBaoData.Instance:GetRebateDayVal(index)
	local flag = 0
	self.amount:SetValue(rebate_val)
	if cur_day < 8 then
		if index < cur_day then
			self:SetAmountActive(true)
		elseif index == cur_day then
			self:SetAmountActive(true)
		else
			self:SetAmountActive(false)
			flag = 1
		end
	else
		if ActiviteHongBaoData.Instance:GetRebateDayVal(index) == 0 then
			self:SetAmountActive(true)
		else
			self:SetAmountActive(false)
			if ActiviteHongBaoData.Instance:GetFlag(index) == 0 then
				flag = 3
			else
				flag = 2
			end
		end
	end
	self:SetZhuangTai(flag)
end

function KaifuActivityRedpacketCell:SetZhuangTai(flag)
	if flag == 0 then
		return
	end
	self.is_can_get:SetValue(HONGBAO_ZHUANGTAI_FLAG[flag][1])
	self.is_get:SetValue(HONGBAO_ZHUANGTAI_FLAG[flag][2])
	self.is_can_open:SetValue(HONGBAO_ZHUANGTAI_FLAG[flag][3])
end

function KaifuActivityRedpacketCell:SetAmountActive(is_show)
	self.is_show_money:SetValue(is_show)
end

function KaifuActivityRedpacketCell:OnOpenButtonClick()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.day - 1)
end
