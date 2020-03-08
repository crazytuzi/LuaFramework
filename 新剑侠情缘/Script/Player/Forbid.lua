function Forbid:IsForbidAward()
	local nEndTime = self.nEndTime or 0;

	return nEndTime < 0 or (nEndTime > 0 and GetTime() < nEndTime);
end

function Forbid:OnSyncForbidAwardState(nEndTime, szMsg,bHideBox)
	self.nEndTime = nEndTime;
	self.szMsg = szMsg or "不正当的游戏行为";
	local bIsForbid = self:IsForbidAward()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FORBID_STATE_CHANGE, bIsForbid)

	if not bHideBox then
		Ui:OpenWindow("MessageBoxBig", self:GetDesc(bIsForbid),
				{ {} },
		 		{"确定"}, 3)
	end
end

function Forbid:GetDesc(bIsForbid)
	if bIsForbid then
		return string.format("由于[FFFE0D]%s[-]，你目前处于零收益状态。零收益状态下会被限制部分游戏功能，并且无法获得游戏奖励。距离状态解除还剩余时间 [FFFE0D]%s[-] ", 
			self.szMsg, Lib:TimeDesc(self.nEndTime - GetTime()))
	else
		return "你已被解除零收益状态！";
	end
end
function Forbid:OnForbidAwardNotice()
	Ui:OpenWindow("MessageBoxBig", string.format("当前处于零收益状态，无法获得系统奖励。距离状态解除还剩余时间 [FFFE0D]%s[-] ", 
			Lib:TimeDesc(self.nEndTime - GetTime())),
			{ {} },
	 		{"确定"}, 3)
end

function Forbid:OnLeaveGame()
	self.nEndTime = 0;
	self.szMsg = "";
end

function Forbid:OnBanNotice(szMsg)
	Ui:OpenWindow("MessageBoxBig", szMsg,
				{ {} },
		 		{"确定"}, 3)
end
