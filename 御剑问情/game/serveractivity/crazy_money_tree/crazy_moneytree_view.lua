CrazyMoneyTreeView = CrazyMoneyTreeView or BaseClass(BaseView)
function CrazyMoneyTreeView:__init()
	self.ui_config = {"uis/views/serveractivity/crazymoneytree_prefab", "CrazyMoneyTree"}
	self.play_audio = true
end

function CrazyMoneyTreeView:__delete()

end

function CrazyMoneyTreeView:ReleaseCallBack()
	self.act_time = nil
	self.has_recharge = nil
	self.res_recharge = nil
	self.return_echarge = nil
	self.is_show_redpoint = nil
	self.recharge_text = nil
	self.is_brought_out = nil
	self.can_get_gold = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CrazyMoneyTreeView:CloseCallBack()

end

function CrazyMoneyTreeView:LoadCallBack()
	self.act_time = self:FindVariable("ActTime")
	self.has_recharge = self:FindVariable("HasRecharge")
	self.res_recharge = self:FindVariable("ResRecharge")
	self.return_echarge = self:FindVariable("ReturnRecharge")
	self.is_show_redpoint = self:FindVariable("is_show_red_point")
	self.recharge_text = self:FindVariable("RechargeText")
	self.is_brought_out = self:FindVariable("is_brought_out")
	self.can_get_gold = self:FindVariable("CanGetGold")

	self:ListenEvent("OnClickShanke", BindTool.Bind(self.OnClickShake, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

function CrazyMoneyTreeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end
--显示界面回调
function CrazyMoneyTreeView:ShowIndexCallBack()
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
end


function CrazyMoneyTreeView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.act_time ~= nil then
		if time > 0 then
			self.act_time:SetValue(TimeUtil.FormatSecond2HMS(time))
		else
			self.act_time:SetValue("00:00:00")
		end
	end
end

--点击摇一摇按钮回调
function CrazyMoneyTreeView:OnClickShake()
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
	if chongzhi == 0 or math.floor(chongzhi * has_return_recive / 100) == gold then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	elseif gold == max_chongzhi_num then	
		SysMsgCtrl.Instance:ErrorRemind(Language.CrazyMoneyTree.TipsBroughtOut)
		self.is_brought_out:SetValue(false)
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_FETCH_GOLD)
	end
end

function CrazyMoneyTreeView:FlushButtonText()
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
	if chongzhi == 0 then
		self.recharge_text:SetValue(Language.CrazyMoneyTree.GoShop)
	elseif gold == max_chongzhi_num then	
		self.recharge_text:SetValue(Language.CrazyMoneyTree.BroughtOut)	
		self.is_brought_out:SetValue(false)
	elseif math.floor(chongzhi * has_return_recive / 100) == gold then
		self.recharge_text:SetValue(Language.CrazyMoneyTree.GoShop)
	else
		self.recharge_text:SetValue(Language.CrazyMoneyTree.GetGold)
	end
end

--刷新
function CrazyMoneyTreeView:OnFlush(param_t, index)
	local show_point = CrazyMoneyTreeData.Instance:GetCanCrazy()
	self.is_show_redpoint:SetValue(show_point)
	
	local chongzhi = CrazyMoneyTreeData.Instance:GetTotalGold() or 0
	self.has_recharge:SetValue(chongzhi)
	local gold = CrazyMoneyTreeData.Instance:GetMoney()
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum()
	local surplus = max_chongzhi_num - gold
	if surplus >= 0 then
		self.res_recharge:SetValue(string.format(Language.CrazyMoneyTree.SurplusGold ,surplus))
	else
		self.res_recharge:SetValue(string.format(Language.CrazyMoneyTree.SurplusGold ,0))
	end
	local return_echarge = CrazyMoneyTreeData.Instance:GetReturnChongzhi()
	self.return_echarge:SetValue(return_echarge.."%")

	local has_return_recive = CrazyMoneyTreeData.Instance:GetReturnChongzhi() or 0
	if math.floor(chongzhi * has_return_recive / 100) <= max_chongzhi_num then
		local can_get = math.floor(chongzhi * has_return_recive / 100) - gold
		self.can_get_gold:SetValue(can_get)
	else
		can_get = max_chongzhi_num - gold
		self.can_get_gold:SetValue(can_get)
	end

	-- 活动剩余时间
	local nexttime = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then
		local time_t = TimeUtil.Format2TableDHM(nexttime)
		if time_t.day > 0 then
			local time_str = ""
			if time_t.day > 0 then
				time_str = time_str .. time_t.day .. Language.Common.TimeList.d
			end
			if time_t.hour > 0 or "" ~= time_str then
				time_str = time_str .. time_t.hour .. Language.Common.TimeList.h
			end
			if time_t.min > 0 or "" ~= time_str then
				time_str = time_str .. time_t.min .. Language.Common.TimeList.min
			end
			self.act_time:SetValue(time_str)
		else
			 self:UpdataRollerTime(0, nexttime)
			 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))
		end
	end

	self:FlushButtonText()
end

function CrazyMoneyTreeView:OnClickClose()
	self:Close()
end

