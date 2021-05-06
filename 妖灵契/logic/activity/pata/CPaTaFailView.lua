local PaTaFailView = class("PaTaFailView", CViewBase)

function PaTaFailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PaTaFailView.prefab", cb)
	self.m_ExtendClose = "Shelter"
end

function PaTaFailView.OnCreateView(self)
	self.m_RePlayBtn = self:NewUI(1, CButton)
	self.m_RightLeaveBtn = self:NewUI(2, CButton)
	self.m_MidLeaveBtn = self:NewUI(3, CButton)
	self.m_Container = self:NewUI(4, CWidget)
	self.m_Fail = self:NewUI(5, CBox)
	self.m_FailEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shibai.prefab", self:GetLayer(), false)
	self.m_FailEffect:SetParent(self.m_Fail.m_Transform)
	self.m_FailEffect:SetLocalPos(Vector3.New(0, 180, 0))

	self.m_InviteCount = nil 
	self.m_DefaultShowTime = nil
	UITools.ResizeToRootSize(self.m_Container)

	self:InitContent()

	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function PaTaFailView.InitContent(self)
	self.m_RePlayBtn:AddUIEvent("click", callback(self, "OnRePlay"))
	self.m_RightLeaveBtn:AddUIEvent("click", callback(self, "OnLeave"))
	self.m_MidLeaveBtn:AddUIEvent("click", callback(self, "OnLeave"))

	g_PataCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPataEvent"))
end

function PaTaFailView.OnLeave(self)
	g_WarCtrl:SetInResult(false)
	g_PataCtrl:PaTaEnterView()
end

function PaTaFailView.OnRePlay(self)
	g_WarCtrl:SetInResult(false)	
	-- if self.m_InviteCount and self.m_InviteCount > 0 then
	-- 	g_PataCtrl:PaTaReadyFight()
	-- else
	-- 	g_PataCtrl:CtrlC2GSPataInvite()
	-- end

	g_PataCtrl:CtrlC2GSPataInvite()
end

function PaTaFailView.SetContent(self, cnt)
	self.m_InviteCount = cnt
	self.m_RePlayBtn:SetActive(false)
	self.m_RightLeaveBtn:SetActive(false)
	self.m_MidLeaveBtn:SetActive(false)
 	if cnt and cnt > 0 then
 		self.m_RePlayBtn:SetActive(true)
		self.m_RightLeaveBtn:SetActive(true)
 	else
 		self.m_MidLeaveBtn:SetActive(true)
 	end
	if self.m_DefaultShowTime then
		Utils.DelTimer(self.m_DefaultShowTime)
		self.m_DefaultShowTime = nil
	end 	
 end 

 function PaTaFailView.OnCtrlPataEvent(self, oCtrl )
	if oCtrl.m_EventID == define.PaTa.Event.WarResult then
		if self.m_IsShowResult == false then		
			if g_PataCtrl.m_WarResult ~= nil and g_PataCtrl.m_WarResult.win ~= 1 then
				local result = g_PataCtrl.m_WarResult
				self.m_IsShowResult = true
				self:SetContent(result.inviteCnt)
				g_PataCtrl.m_WarResult = nil
			end
		end
	end
end

 function PaTaFailView.SetDefaultShow(self)
	if g_PataCtrl.m_WarResult ~= nil and g_PataCtrl.m_WarResult.win ~= 1 then
		local result = g_PataCtrl.m_WarResult
		self.m_IsShowResult = true
		self:SetContent(result.inviteCnt)
		g_PataCtrl.m_WarResult = nil
	else
		self.m_RePlayBtn:SetActive(false)
	 	self.m_RightLeaveBtn:SetActive(false)
	 	self.m_MidLeaveBtn:SetActive(false)

		if self.m_DefaultShowTime then
			Utils.DelTimer(self.m_DefaultShowTime)
			self.m_DefaultShowTime = nil
		end
		local function timeCb()
			self.m_MidLeaveBtn:SetActive(true)
		end
		self.m_DefaultShowTime = Utils.AddTimer(timeCb, 0, 5)	

	end  	
end

function PaTaFailView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	if self.m_DefaultShowTime then
		Utils.DelTimer(self.m_DefaultShowTime)
		self.m_DefaultShowTime = nil
	end
	CViewBase.Destroy(self)
end

return PaTaFailView