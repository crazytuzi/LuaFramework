local CLeiTaiMainView = class("CLeiTaiMainView", CViewBase)

function CLeiTaiMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/LeiTai/CLeiTaiMainView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CLeiTaiMainView.OnCreateView(self)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_ChallengeAllBtn = self:NewUI(3, CButton)
	self.m_ChallengeOneBtn = self:NewUI(4, CButton)
	self.m_InviteFriendBtn = self:NewUI(5, CButton)
	self.m_PlayerInfoBox = self:NewUI(6, CBox)
	self.m_PlayerInfo_L_Slot = self:NewUI(7, CBox)
	self.m_PlayerInfo_R_Slot = self:NewUI(8, CBox)
	self.m_WatchBtn = self:NewUI(9, CButton)
	self.m_DefultPart = self:NewUI(10, CBox)
	self.m_OnFightPart = self:NewUI(11, CBox)
	
	self:InitContent()
end

function CLeiTaiMainView.InitContent(self)
	-- self.m_HelpBtn:SetHint(data.helpdata.DATA[define.Help.Key.EndlessPVE].content, enum.UIAnchor.Side.Bottom)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ChallengeAllBtn:AddUIEvent("click", callback(self, "OnClickChallengeAll"))
	self.m_ChallengeOneBtn:AddUIEvent("click", callback(self, "OnClickChallengeOne"))
	self.m_InviteFriendBtn:AddUIEvent("click", callback(self, "OnClickInviteFriend"))
	self.m_WatchBtn:AddUIEvent("click", callback(self, "OnClickWatch"))
	self.m_PlayerInfoBoxArr = {}

end

function CLeiTaiMainView.SetData(self)
	self.m_PlayerInfoData = nil
	if self.m_PlayerInfoData == nil then
		self.m_DefultPart:SetActive(true)
		self.m_OnFightPart:SetActive(false)
	else
		self.m_DefultPart:SetActive(false)
		self.m_OnFightPart:SetActive(true)
		local count = 0
		for k,v in pairs(self.m_PlayerInfoData) do
			count = count + 1
			if self.m_PlayerInfoData[count] == nil then
				self.m_PlayerInfoData[count] = self:CreateInfoBox()
			end
			self.m_PlayerInfoData[count]:SetData(v)
			self.m_PlayerInfoData[count]:SetActive(true)
		end
	end
end

function CLeiTaiMainView.OnClickChallengeAll(self)
	printc("OnClickChallengeAll")
end

function CLeiTaiMainView.OnClickChallengeOne(self)
	printc("OnClickChallengeOne")
end

function CLeiTaiMainView.OnClickInviteFriend(self)
	printc("OnClickInviteFriend")
end

function CLeiTaiMainView.OnClickWatch(self)
	printc("OnClickWatch")
end

function CLeiTaiMainView.CreateInfoBox(self)
	local oInfoBox = self.m_PlayerInfoBox:Clone()
	oInfoBox.m_PlayerTexture = oInfoBox:NewUI(1, CActorTexture)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_LvLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_WinCountLabel = oInfoBox:NewUI(4, CLabel)
	oInfoBox.m_WinPercentLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_SchoolSprite = oInfoBox:NewUI(6, CSprite)
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_PlayerTexture:ChangeShape(data.itemdata.PARTNER_CHIP[oData].shape)
	end

	return oInfoBox
end


return CLeiTaiMainView