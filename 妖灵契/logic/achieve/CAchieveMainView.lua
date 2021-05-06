local CAchieveMainView = class("CAchieveMainView", CViewBase)

function CAchieveMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Achieve/AchieveMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
	
	self.m_Init = true
	self.m_CurDirectionBox = nil
	self.m_CurBelongBox = nil
	self.m_DirectionBoxDic = {}
	self.m_AchieveList = {}
end

function CAchieveMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_AchieveSlider = self:NewUI(4, CSlider)
	self.m_AchieveRewardBtn = self:NewUI(5, CButton)
	self.m_DirectionBox = self:NewUI(6, CAchieveDirectionBox)
	self.m_AchieveInfoBox = self:NewUI(7, CAchieveInfoBox)
	self:InitContent()
end

function CAchieveMainView.InitContent(self)
	self.m_DirectionBox:SetParentView(self)
	self.m_AchieveInfoBox:SetParentView(self)
	self.m_AchieveRewardBtn.m_TweenRotation = self.m_AchieveRewardBtn:GetComponent(classtype.TweenRotation)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AchieveRewardBtn:AddUIEvent("click", callback(self, "OnAchieveRewardBtn"))
	g_AchieveCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAchieveCtrl"))
end

function CAchieveMainView.CloseView(self)
	netachieve.C2GSCloseMainUI()
	CViewBase.CloseView(self)
end

function CAchieveMainView.OnAchieveCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Achieve.Event.AchieveDone then
		self:RefreshAchieveSlider()
	--	g_AchieveCtrl:ForceShow(self:GetCurDirection(), self:GetCurBelong())
	elseif oCtrl.m_EventID == define.Achieve.Event.RedDot then
		self:CheckRedDot()
	elseif oCtrl.m_EventID == define.Achieve.Event.AchieveDegree then
		if oCtrl.m_EventData then
			self:RefreshAchieve(oCtrl.m_EventData)
		end
	end
end

function CAchieveMainView.OnAchieveRewardBtn(self, obj)
	if obj.get then
		g_AchieveCtrl:C2GSAchievePointReward(g_AchieveCtrl:GetCurRewardIdx())
		g_AchieveCtrl:C2GSAchieveMain()
	else
		CAchieveRewardView:ShowView()
	end
end

function CAchieveMainView.GetCurDirection(self)
	return self.m_DirectionBox:GetCurDirection()

end

function CAchieveMainView.GetCurBelong(self)
	return self.m_DirectionBox:GetCurBelong()
end

function CAchieveMainView.RefreshAchieveInfo(self, achlist)
	self.m_AchieveInfoBox:RefreshAchieveInfo(achlist)
end

function CAchieveMainView.RefreshAchieveSlider(self)
	local iCurRewardIdx = g_AchieveCtrl:GetCurRewardIdx()
	local curReward = data.achievedata.REWARDPOINT[iCurRewardIdx]
	local cur_point = g_AchieveCtrl:GetCurPoint()
	self.m_AchieveSlider:SetValue(cur_point / curReward.point)
	self.m_AchieveSlider:SetSliderText(string.format("%d/%d", cur_point, curReward.point))
	self.m_AchieveRewardBtn:SetSpriteName("pic_baoxiang_4_h")
	if cur_point >= curReward.point and not g_AchieveCtrl:IsAllRewardGet() then
		self.m_AchieveRewardBtn.get = true
		self.m_AchieveRewardBtn.m_TweenRotation.enabled = true
	else
		self.m_AchieveRewardBtn.get = false
		self.m_AchieveRewardBtn.m_TweenRotation.enabled = false
		self.m_AchieveRewardBtn:SetLocalRotation(Quaternion.identity)
	end
end

function CAchieveMainView.CheckRedDot(self)
	self.m_DirectionBox:CheckRedDot()
end

function CAchieveMainView.RefreshAchieve(self, info)
	self.m_AchieveInfoBox:RefreshAchieve(info)
end

function CAchieveMainView.DefaultSelect(self, iDirection, iBelong)
	self.m_DirectionBox:DefaultSelect(iDirection, iBelong)
end

return CAchieveMainView