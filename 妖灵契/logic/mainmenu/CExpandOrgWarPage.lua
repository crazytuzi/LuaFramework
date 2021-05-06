local CExpandOrgWarPage = class("CExpandOrgWarPage", CPageBase)

function CExpandOrgWarPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandOrgWarPage.OnInitPage(self)
	self.m_OrgInfoBox1 = self:NewUI(1, CBox)
	self.m_OrgInfoBox2 = self:NewUI(2, CBox)
	self.m_ShowGroup = self:NewUI(3, CBox)
	self.m_CountDownLabel = self:NewUI(4, CCountDownLabel)
	self.m_RebornLabel = self:NewUI(5, CCountDownLabel)
	self:InitContent()
end

function CExpandOrgWarPage.InitContent(self)
	self.m_RebornLabel:SetActive(false)
	self.m_CountDownLabel:SetTickFunc(callback(self, "OnCount"))
	self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	self.m_RebornLabel:SetTickFunc(callback(self, "OnRebornCount"))
	self.m_RebornLabel:SetTimeUPCallBack(callback(self, "OnRebornTimeUp"))
	self:InitInfoBox(self.m_OrgInfoBox1, false)
	self:InitInfoBox(self.m_OrgInfoBox2, true)
	g_OrgWarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgWarEvent"))
end

function CExpandOrgWarPage.SetData(self)
	-- self.m_ShowGroup:SetActive(g_OrgWarCtrl:GetCurrentScene() == define.Org.OrgWarScene.War)
	self.m_OrgInfoBox1:RefreshCnt(g_OrgWarCtrl:GetEnemyInfo())
	self.m_OrgInfoBox2:RefreshCnt(g_OrgWarCtrl:GetMyOrgInfo())
end

function CExpandOrgWarPage.OnShowPage(self)
	self:SetData()
	self.m_CountDownLabel:BeginCountDown(g_OrgWarCtrl:GetRestTime())
	self:RefreshReviveTime()
end

function CExpandOrgWarPage.OnCount(self, iValue)
	self.m_CountDownLabel:SetText(string.format("[FBEAB8]剩余时间：[3eeaa3]%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function CExpandOrgWarPage.OnTimeUp(self)
	self.m_CountDownLabel:SetText("[FBEAB8]活动结束")
end

function CExpandOrgWarPage.OnRebornCount(self, iValue)
	self.m_RebornLabel:SetText(string.format("复活倒计时：%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function CExpandOrgWarPage.OnRebornTimeUp(self)
	self.m_RebornLabel:SetActive(false)
end

function CExpandOrgWarPage.InitInfoBox(self, oInfoBox, isMyInfo)
	oInfoBox.m_Label = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_BloodSlider = oInfoBox:NewUI(2, CSlider)
	oInfoBox.m_GoBtn = oInfoBox:NewUI(3, CButton)
	oInfoBox.m_IsMyInfo = isMyInfo

	if isMyInfo then
		oInfoBox.m_LabelFormat = "[FBEAB8]己方水晶防守人员：[3eeaa3]%s"
		oInfoBox.m_GoBtn:AddUIEvent("click", callback(self, "OnDefense"))
	else
		oInfoBox.m_LabelFormat = "[FBEAB8]敌方水晶防守人员：[3eeaa3]%s"
		oInfoBox.m_GoBtn:AddUIEvent("click", callback(self, "OnAttack"))
	end

	function oInfoBox.RefreshCnt(self, oData)
		if oData then
			oInfoBox.m_Label:SetText(string.format(oInfoBox.m_LabelFormat, oData.defend))
			oInfoBox.m_BloodSlider:SetValue(oData.hp / 1000)
			oInfoBox.m_BloodSlider:SetSliderText((oData.hp/10) .. "%")
		else
			oInfoBox.m_Label:SetText(string.format(oInfoBox.m_LabelFormat, 0))
			oInfoBox.m_BloodSlider:SetValue(1)
			oInfoBox.m_BloodSlider:SetSliderText("100%")
		end
	end

	return oInfoBox
end

function CExpandOrgWarPage.OnDefense(self)
	nethuodong.C2GSOrgWarOption(define.Org.OrderType.Defense)
end

function CExpandOrgWarPage.OnAttack(self)
	nethuodong.C2GSOrgWarOption(define.Org.OrderType.Attack)
end

function CExpandOrgWarPage.RefreshReviveTime(self)
	local iTime = g_OrgWarCtrl:GetReviveTime()
	if iTime > 0 then
		self.m_RebornLabel:SetActive(true)
	end
	self.m_RebornLabel:BeginCountDown(iTime)
end

function CExpandOrgWarPage.OnOrgWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.OnUpdateBlood then
		self:SetData()
	elseif oCtrl.m_EventID == define.Org.Event.EnterOrgWarScene or oCtrl.m_EventID == define.Org.Event.LeaveOrgWarScene then
		-- self.m_ShowGroup:SetActive(g_OrgWarCtrl:GetCurrentScene() == define.Org.OrgWarScene.War)
	elseif oCtrl.m_EventID == define.Org.Event.UpdateReviveTime then
		self:RefreshReviveTime()
	end
end

return CExpandOrgWarPage