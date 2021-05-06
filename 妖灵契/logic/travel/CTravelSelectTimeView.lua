local CTravelSelectTimeView = class("CTravelSelectTimeView", CViewBase)

function CTravelSelectTimeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelSelectTimeView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTravelSelectTimeView.OnCreateView(self)
	self.m_CancelBtn = self:NewUI(1, CButton)
	self.m_OKBtn = self:NewUI(2, CButton)
	self.m_Grid = self:NewUI(3, CGrid)
	self:InitContent()
end

function CTravelSelectTimeView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOk"))
	self:InitGrid()
end

function CTravelSelectTimeView.OnOk(self)
	nettravel.C2GSStartTravel(self.m_TimeType)
	self:CloseView()
end

function CTravelSelectTimeView.InitGrid(self)
	self.m_TimeType = nil
	self.m_Grid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Idx = idx
		oBox.m_TimeLabel = oBox:NewUI(1, CLabel)
		oBox.m_OnSelectSprite = oBox:NewUI(2, CSprite)
		oBox:SetGroup(self.m_Grid:GetInstanceID())
		return oBox
	end)
	local oDefault
	local lData = data.traveldata.TRAVEL_TYPE
	for i,oBox in ipairs(self.m_Grid:GetChildList()) do
		local dData = lData[i]
		oBox.m_TimeType = dData.travel_type
		oBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(dData.travel_time))
		oBox:AddUIEvent("click", callback(self, "OnBox"))
		self.m_Grid:AddChild(oBox)
		if not oDefault then
			oDefault = oBox
		end
	end
	self.m_Grid:Reposition()
	if oDefault then
		self:OnBox(oDefault)
	end
end

function CTravelSelectTimeView.OnBox(self, oBox)
	oBox:SetSelected(true)
	self.m_TimeType = oBox.m_TimeType
end

return CTravelSelectTimeView