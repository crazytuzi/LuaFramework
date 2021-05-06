local CScheduleTipsView = class("CScheduleTipsView", CViewBase)

function CScheduleTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CScheduleTipsView.OnCreateView(self)
	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CItemRewardBox)
	self.m_JoinTips = self:NewUI(7, CLabel)
	self.m_ItemBox:SetActive(false)
end

function CScheduleTipsView.SetScheduleID(self, scheduleid)
	self.m_ScheduleID = scheduleid
	local dData = data.scheduledata.SCHEDULE[scheduleid]
	self.m_IconSprite:SetSpriteName(dData.icon)
	self.m_NameLabel:SetText(dData.name)
	self.m_DescLabel:SetText(dData.desc)
	self.m_ItemGrid:Clear()
	local rewars = dData.rewardlist or {}
	local config = {isLocal = true,}
	for i,v in ipairs(rewars) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemBySid(v.sid, v.num)
		self.m_ItemGrid:AddChild(box)
	end
	self.m_ItemGrid:Reposition()

	self.m_JoinTips:SetText(dData.jointips)
end

return CScheduleTipsView