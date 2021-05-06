local CCostScoreBuyView = class("CCostScoreBuyView", CBaseBuyItemView)

function CCostScoreBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/LimitReward/CCostScoreBuyView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_CostShape = nil
	self.m_FullValueCb = nil
end

function CCostScoreBuyView.InitDerive(self)
	self.m_TotalGoldNameLabel:SetText("所需积分")
	self.m_CurGoldNameLabel:SetText("我的积分")
end

return CCostScoreBuyView