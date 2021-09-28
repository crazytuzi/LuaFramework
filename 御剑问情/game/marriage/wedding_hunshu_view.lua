WeddingHunShuView = WeddingHunShuView or BaseClass(BaseView)

local TouchTime = 2

function WeddingHunShuView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingHunshuView"}
end

function WeddingHunShuView:ReleaseCallBack()
	self.show_effect = nil
	self.show_finger_me = nil
	self.show_finger_other = nil
	
	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end
end

function WeddingHunShuView:LoadCallBack()
	self.agree = false
	self.show_effect = self:FindVariable("show_effect")
	self.show_effect:SetValue(true)

	self.show_finger_me = self:FindVariable("show_finger_me")
	self.show_finger_me:SetValue(false)

	self.show_finger_other = self:FindVariable("show_finger_other")
	self.show_finger_other:SetValue(false)

	self:ListenEvent("Close",BindTool.Bind(self.OnClickClose, self, 0))
	self:ListenEvent("OnClickStart",BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickEnd",BindTool.Bind(self.OnClickEnd, self))
	self:Flush()
end

function WeddingHunShuView:OnClickClose(is_accept)
	if self.agree then
		self:Close()
		return
	end

	local yes_func = function()
		local info = MarriageData.Instance:GetReqWeddingInfo()
		if not next(info) then
			local wedding_info = MarriageData.Instance:GetWeddingTargetInfo()
			if wedding_info then
				MarriageCtrl.Instance:SendMarryRet(wedding_info.wedding_type, is_accept, wedding_info.target_id)
			end
			self:Close()
			return
		end
		MarriageCtrl.Instance:SendMarryRet(info.marry_type, is_accept, info.req_uid)
		self:Close()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", Language.Marriage.EscMarryPledge, yes_func)
end

function WeddingHunShuView:OnClickStart()
	self.press_time = GlobalTimerQuest:AddDelayTimer(function ()
		self.agree = true
		self.show_effect:SetValue(false)
		self.show_finger_me:SetValue(true)
		MarriageCtrl.Instance:SendWeedingOperate(MARRY_REQ_TYPE.MARRY_PRESS_FINGER_REQ)
	end, TouchTime)
end

function WeddingHunShuView:OnClickEnd()
	if self.agree then return end

	if self.press_time then
		GlobalTimerQuest:CancelQuest(self.press_time)
		self.press_time = nil
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.MarryHunshuErroRemind)
end

function WeddingHunShuView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "finish" then
			self.show_finger_other:SetValue(true)
		end
	end
end