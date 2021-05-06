local CSchedulePopupView = class("CSchedulePopupView", CViewBase)

function CSchedulePopupView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/SchedulePopupView.prefab", cb)
	--界面设置
	--self.m_GroupName = "main"
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CSchedulePopupView.OnCreateView(self)
	self.m_NameTexture = self:NewUI(2, CTexture)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CItemRewardBox)
	self.m_GoBtn = self:NewUI(7, CButton)
	self.m_ItemBox:SetActive(false)
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGoBtn"))
end

function CSchedulePopupView.OnGoBtn(self)
	g_ViewCtrl:CloseAll({"CMainMenuView"})
	g_ScheduleCtrl:GoToWay(self.m_ScheduleID)
	self:CloseView()
end

function CSchedulePopupView.SetScheduleID(self, scheduleid)
	self.m_ScheduleID = scheduleid
	local dData = data.scheduledata.SCHEDULE[scheduleid]
	self.m_NameTexture:LoadPath(string.format("Texture/Schedule/text_schedule_%d.png", scheduleid))
	local times = dData.times
	self.m_DescLabel:SetText(string.format("活动时间：%s-%s", times[1].opentime, times[1].endtime))
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
end

return CSchedulePopupView