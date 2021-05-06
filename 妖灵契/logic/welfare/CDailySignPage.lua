local CDailySignPage = class("CDailySignPage", CPageBase)

function CDailySignPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CDailySignPage.OnInitPage(self)
	self.m_SginBtn = self:NewUI(1, CButton)
	self.m_ItemGrid = self:NewUI(2, CGrid)

	self.m_ItemGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Idx = idx
		oBox.m_DayLabel = oBox:NewUI(1, CLabel)
		oBox.m_ItemBox = oBox:NewUI(2, CItemRewardBox)
		oBox.m_DayLabel:SetText("第"..idx.."天")
		local reward = data.welfaredata.DailySign_Week[idx].reward
		oBox.m_ItemBox:SetActive(true)
		oBox.m_ItemBox:SetItemBySid(reward.sid, reward.amount, {isLocal = true})
		return oBox
	end)
	self:InitContent()
end

function CDailySignPage.InitContent(self)
	self.m_SginBtn:AddUIEvent("click", callback(self, "OnSginBtn"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	self:Refresh()
end

function CDailySignPage.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnDailySign then
		self:Refresh()
	end
end

function CDailySignPage.Refresh(self)
	local info = g_WelfareCtrl:GetDailySignInfo()
	self.m_Info = info["week"]
	self.m_Key = self.m_Info.key
	self.m_SignDay = self.m_Info.sign_day
	self.m_IsSign = self.m_Info.is_sign
	self.m_SginBtn:SetText("签 到")
	for i,oBox in ipairs(self.m_ItemGrid:GetChildList()) do
		oBox:SetGreySprites(oBox.m_Idx <= self.m_SignDay)
		if oBox.m_Idx == self.m_SignDay and self.m_IsSign then
			oBox:SetGreySprites(true)
			self.m_SginBtn:SetText("已签到")
		end
	end
end

function CDailySignPage.OnSginBtn(self)
	nethuodong.C2GSDailySign(self.m_Key)
end

return CDailySignPage