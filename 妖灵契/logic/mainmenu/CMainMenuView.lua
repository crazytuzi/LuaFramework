local CMainMenuView = class("CMainMenuView", CViewBase)


function CMainMenuView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MainMenu/MainMenuView.prefab", cb)
	
	self.m_DepthType = "Menu"
	self.m_GroupName = "main"
	self.m_OnShowCallback = nil
	self.m_IsShowView = true
end

function CMainMenuView.OnCreateView(self)
	self.m_LT = self:NewUI(1, CMainMenuLT)
	self.m_LB = self:NewUI(2, CMainMenuLB)
	self.m_RT = self:NewUI(3, CMainMenuRT)
	self.m_RB = self:NewUI(4, CMainMenuRB)
	self.m_Center = self:NewUI(5, CMainMenuCenter)
	self.m_Container = self:NewUI(6, CWidget)
	self.m_HideBtn = self:NewUI(7, CButton)
	self.m_BuffBtn = self:NewUI(8, CButton)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnHidePart"))
	self.m_BuffBtn:AddUIEvent("click", callback(self, "OnBuffBtn"))
	g_PlayerBuffCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBuffEvent"))
end

function CMainMenuView.SwitchEnv(self, bWar)
	self.m_LB:SetActive(not bWar)
	self.m_HideBtn:SetActive(not bWar)
	self.m_LB:SetExpLabelActive(not bWar)
	self.m_LT:SetActive(not bWar)
	self.m_RT:SetActive(not bWar)
	self.m_RB:SetActive(not bWar)
	self.m_RT.m_TopGrid:SetActive(true)
	self.m_RT:CheckForetell()
	self:CheckPlayerBuff()
	
	self.m_LB.m_SocialityPart:SetActive(not bWar)
	self.m_LB.m_SocialityPart:Reset()

	self.m_IsShowView = true
	self:OnHideOtherPart()
	self.m_HideBtn:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	
	-- TODO:临时屏蔽，Tips不可以在战斗中显示
	self.m_Center:RefrehNotifyTip()

	if bWar == false then
		self.m_RB:OnShowView()
		self.m_RT:OnShowView()
		if self.m_LT and self.m_LT.m_TeamBox then
			self.m_LT.m_TeamBox:OnShowView()
		end
	end
end

function CMainMenuView.IsCanShow(self)
	if g_ChoukaCtrl:IsInChouka() then
		return false
	else
		return true
	end
end

function CMainMenuView.OnBuffBtn(self)
	CPlayerBuffView:ShowView()
end

function CMainMenuView.OnShowView(self)
	self.m_LB.m_ChatBox:DelayCall(0, "RefreshAllMsg")
	self:SwitchEnv(g_WarCtrl:IsWar())
	if self.m_OnShowCallback then
		self.m_OnShowCallback()
		self.m_OnShowCallback = nil
	end
end

function CMainMenuView.SetOnShowCallback(self, cb)
	self.m_OnShowCallback = cb
end

function CMainMenuView.BagItemDoTweenScale(self)
	if self and self.m_RB and self.m_RB.m_ItemBtn.m_Transform then
		self:TweenBtnScale(self.m_RB.m_ItemBtn)
	end
end

function CMainMenuView.TweenPartnerBtn(self)
	if self and self.m_RB and self.m_RB.m_PartnerBtn.m_Transform then
		self:TweenBtnScale(self.m_RB.m_PartnerBtn)
	end
end
function CMainMenuView.TweenHouseBtn(self)
	if self and self.m_RB and self.m_RB.m_HouseBtn.m_Transform then
		self:TweenBtnScale(self.m_RB.m_HouseBtn)
	end
end

function CMainMenuView.TweenBtnScale(self, oBtn)
	if oBtn then
		local trans = oBtn.m_Transform
		local seq = DOTween.Sequence(trans)
		DOTween.Append(seq, DOTween.DOScale(trans, Vector3.New(1.2, 1.2, 1.2), 0.3))
		DOTween.Append(seq, DOTween.DOScale(trans, Vector3.New(1.0, 1.0, 1.0), 0.2))
	end
end

function CMainMenuView.SetActive(self, bActive)
	CViewBase.SetActive(self, bActive)
	g_GuideCtrl:CheckTaskNvGuide()
	g_MainMenuCtrl:CheckTaskScrollViewUpdateTimer()
end

function CMainMenuView.OnHidePart(self)
	self.m_IsShowView = not self.m_IsShowView	
	self.m_LT:SetActive(self.m_IsShowView)
	self.m_RT.m_TopGrid:SetActive(self.m_IsShowView)
	if self.m_IsShowView then
		self.m_RT:CheckForetell()
	else
		self.m_RT.m_ForetellBtn:SetActive(false)
	end	
	self.m_RB:SetActive(self.m_IsShowView)
	local ratation = self.m_IsShowView == true and 0 or 180
	self.m_HideBtn:SetLocalRotation(Quaternion.Euler(0, ratation, 0))
	self:OnHideOtherPart()
end

function CMainMenuView.OnHideOtherPart(self)
	if self.m_LB.m_ChatBox and self.m_LB.m_ChatBox.RefreshButtonPos then
		self.m_LB.m_ChatBox:RefreshButtonPos()
	end

	if self.m_RT.CheckFirstCharge then
		self.m_RT:CheckFirstCharge()
	end
end

--场景答题，不讲道理隐藏一切
function CMainMenuView.SetSceneExamMode(self, bShow)
	if not g_SceneExamCtrl:IsInExam() then
		bShow = false
	end
	self.m_RT.m_TopGrid:SetActive(true)
	self.m_RT:CheckForetell()	
	self.m_LB:SetActive(not bShow)
	self.m_RB:SetActive(not bShow)
	self.m_RT:SetActive(not bShow)
	if self.m_LT and self.m_LT.m_TeamBox then
		self.m_LT.m_TeamBox:SetActive(not bShow)
	end
	self.m_HideBtn:SetActive(not bShow)
	if bShow then
		Utils.AddTimer(objcall(self, function(obj) 
			obj:SetOnShowCallback(callback(obj, "SetSceneExamMode", true)) 
		end), 0, 0)
	else
		self:SetOnShowCallback()
	end
end

function CMainMenuView.OnBuffEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PlayerBuff.Event.OnRefreshBuff then
		self:CheckPlayerBuff()
	end
end

function CMainMenuView.CheckPlayerBuff(self)
	self.m_BuffBtn:SetActive((not g_WarCtrl:IsWar()) and g_PlayerBuffCtrl:HasBuff())
end

return CMainMenuView
