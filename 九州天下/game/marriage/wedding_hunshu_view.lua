WeddingHunShuView = WeddingHunShuView or BaseClass(BaseView)

function WeddingHunShuView:__init()
	self.ui_config = {"uis/views/marriageview","WeddingHunshuView"}
	self.press_time = nil

	self:SetMaskBg()
end

function WeddingHunShuView:ReleaseCallBack()
	self.wedding_pledge = nil
	self.show_finger = nil
	self.count_time = nil
	self.finish_marry = nil
	self.show_effect = nil
	
	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end

	if self.finish_time then
		GlobalTimerQuest:CancelQuest(self.finish_time)
		self.finish_time = nil
	end
end

function WeddingHunShuView:LoadCallBack()
	self.Agree = false
	self.show_finger = self:FindVariable("show_finger")
	self.count_time = self:FindVariable("count_time")
	self.show_effect = self:FindVariable("show_effect")
	self.finish_marry = self:FindVariable("finish_marry")
	self.wedding_pledge = self:FindVariable("wedding_pledge")

	self:ListenEvent("Close",BindTool.Bind(self.OnClickClose, self, 0))
	self:ListenEvent("OnClickStart",BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickEnd",BindTool.Bind(self.OnClickEnd, self))
	self:Flush()
	-- self:CloseCountDown()
end

function WeddingHunShuView:OnClickClose(is_accept)
	if self.Agree then
		-- self:RemoveCountDown()
		self:Close()
		return
	end

	local yes_func = function()
		-- self:RemoveCountDown()

		local info = MarriageData.Instance:GetReqWeddingInfo()
		if not next(info) then
			local wedding_info = MarriageData.Instance:GetWeddingTargetInfo()
			if wedding_info.target_id ~= 0 then
				MarriageCtrl.Instance:SendMarryRet(wedding_info.wedding_type, is_accept, wedding_info.target_id)
			end
			return
		end
		MarriageCtrl.Instance:SendMarryRet(info.marry_type, is_accept, info.req_uid)
		self:Close()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", Language.Marriage.EscMarryPledge, yes_func)
end

function WeddingHunShuView:OnClickStart()
	self.press_time = GlobalTimerQuest:AddDelayTimer(function ()
		self.Agree = true
		self.show_effect:SetValue(true)
		self.show_finger:SetValue(true)
		MarriageCtrl.Instance:SendWeedingOperate(MARRY_REQ_TYPE.MARRY_PRESS_FINGER_REQ)
	end, 2)
end

function WeddingHunShuView:OnClickEnd()
	if self.Agree then return end
	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.MarryHunshuErroRemind)
end

function WeddingHunShuView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "finish" then
			self.show_finger:SetValue(false)
			self.finish_marry:SetValue(true)
			-- self.finish_time = GlobalTimerQuest:AddDelayTimer(function ()
			-- 	ViewManager.Instance:CloseAll()
			-- end, 2)
		end
	end
	local pledge_info = MarriageData.Instance:GetWeddingPledgeInfo()
	if pledge_info ~= 0 and self.wedding_pledge then
	 	self.wedding_pledge:SetValue(pledge_info - 1)
	end
end

function WeddingHunShuView:CloseCountDown()
	function diff_time_func(elapse_time, total_time)

		local end_times = math.ceil(30 - elapse_time)
		if self.count_time then
			self.count_time:SetValue(end_times)
		end

		if elapse_time >= total_time then
			self:RemoveCountDown()
			self:Close()
		end
	end

	local total = 30
	self.count_down = CountDown.Instance:AddCountDown(
		total, 1, diff_time_func)
end

function WeddingHunShuView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end