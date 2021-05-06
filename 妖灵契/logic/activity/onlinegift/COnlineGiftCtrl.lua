local COnlineGiftCtrl = class("COnlineGiftCtrl", CCtrlBase)

function COnlineGiftCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function COnlineGiftCtrl.ResetCtrl(self)
	self.m_StartTime = 0
	self.m_Status = {}
end

function COnlineGiftCtrl.UpdateStatus(self, status)
	self.m_Status = {}
	
	for k,v in pairs(data.onlinegiftdata.DATA) do
		self.m_Status[k] = MathBit.andOp(status, 2 ^ (v.id - 1)) ~= 0
	end
	self:OnEvent(define.OnlineGift.Event.UpdateStatus)
end

function COnlineGiftCtrl.UpdateTime(self, onlinetime)
	self.m_StartTime = g_TimeCtrl:GetTimeS() - onlinetime
	self:OnEvent(define.OnlineGift.Event.UpdateTime)
end

function COnlineGiftCtrl.UpdateReward(self, dRewardInfo)
	self.m_RewardInfo = {}
	dRewardInfo = dRewardInfo or {}
	for _, dReward in ipairs(dRewardInfo) do
		self.m_RewardInfo[dReward.rewardid] = {}
		for _, obj in ipairs(dReward.random_reward) do
			table.insert(self.m_RewardInfo[dReward.rewardid], obj.amount)
		end
	end
end

function COnlineGiftCtrl.GetStartTime(self)
	return self.m_StartTime
end

function COnlineGiftCtrl.IsGiftGot(self, id)
	return self.m_Status[id]
end

function COnlineGiftCtrl.GetGetRewardList(self, id)
	if self.m_RewardInfo then
		return self.m_RewardInfo[id]
	else
		return nil
	end
end

function COnlineGiftCtrl.GetMainGiftData(self)
	for i,giftID in ipairs(data.onlinegiftdata.SortID) do
		if not self:IsGiftGot(giftID) then
			return data.onlinegiftdata.DATA[giftID]
		end
	end
	return nil
end

return COnlineGiftCtrl