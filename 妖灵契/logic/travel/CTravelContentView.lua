local CTravelContentView = class("CTravelContentView", CViewBase)

function CTravelContentView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelContentView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTravelContentView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GetRewardBtn = self:NewUI(2, CButton)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_DescTable = self:NewUI(4, CTable)
	self.m_DescBox = self:NewUI(5, CBox)

	self:InitContent()
	self:RefreshDescTable()
end

function CTravelContentView.InitContent(self)
	self.m_DescBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GetRewardBtn:AddUIEvent("click", callback(self, "OnGetRewardBtn"))
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	self.m_GetRewardBtn:SetGrey(not g_TravelCtrl:HasTravelReward())
	local function refreshbtn()
		if Utils.IsNil(self) then
			return
		end
		self.m_GetRewardBtn:SetGrey(not g_TravelCtrl:HasTravelReward())
		return true
	end
	Utils.AddTimer(refreshbtn, 0.1, 0.1)
end

function CTravelContentView.OnTravelCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Travel.Event.Base then
		self.m_GetRewardBtn:SetGrey(not g_TravelCtrl:HasTravelReward())
	elseif oCtrl.m_EventID == define.Travel.Event.MineContent then
		self:RefreshDescTable()
	end
end

function CTravelContentView.OnGetRewardBtn(self, oBtn)
	if g_TravelCtrl:IsMainTraveling() then
		local args = 
			{
				msg = "停止后将立即获取奖励，是否停止游历？",
				okCallback = function ( )
					nettravel.C2GSAcceptTravelRwd()
					end,
				okStr = "确定",
				cancelStr = "取消",
			}
		g_WindowTipCtrl:SetWindowConfirm(args)	
	elseif not g_TravelCtrl:HasTravelReward() then
		g_NotifyCtrl:FloatMsg("无奖励可领取")
	else
		nettravel.C2GSAcceptTravelRwd()
	end
end

function CTravelContentView.RefreshDescTable(self)
	self.m_DescTable:Clear()
	local lData = g_TravelCtrl:GetMineContentInfo()
	if lData then
		for i,dData in ipairs(lData) do
			local oDescBox = self:CreateDescBox(dData)
			self.m_DescTable:AddChild(oDescBox)
		end
	end
	self.m_DescTable:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CTravelContentView.CreateDescBox(self, dData)
	local oDescBox = self.m_DescBox:Clone()
	--oDescBox:SetActive(true)
	oDescBox.m_TimeLabel = oDescBox:NewUI(1, CLabel)
	oDescBox.m_DescLabel = oDescBox:NewUI(2, CLabel)
	
	oDescBox.m_TimeLabel:SetText(os.date("%H:%M",dData.travel_time))
	oDescBox.m_DescLabel:SetText(dData.content)
	local lw,lh = oDescBox.m_DescLabel:GetSize()
	local bw,bh = oDescBox:GetSize()
	oDescBox:SetSize(bw, bh + lh + 10)
	oDescBox:SetActive(true)
	return oDescBox
end

return CTravelContentView