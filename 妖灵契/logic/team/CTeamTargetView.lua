local CTeamTargetView = class("CTeamTargetView", CViewBase)

function CTeamTargetView.ctor(self)
	CViewBase.ctor(self, "UI/Team/TeamTargetView.prefab", cb)
	--界面设置
	self.m_GroupName = "teamsub"
	self.m_ExtendClose = "ClickOut"
end

return