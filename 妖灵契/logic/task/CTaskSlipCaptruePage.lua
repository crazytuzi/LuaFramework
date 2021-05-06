local CTaskSlipCaptruePage = class("CTaskSlipCaptruePage", CPageBase)

function CTaskSlipCaptruePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTaskSlipCaptruePage.OnInitPage(self)

	self.m_StartBox = self:NewUI(1, CBox)
	self.m_EndBox = self:NewUI(2, CBox)
	self.m_TipsLabel = self:NewUI(3, CLabel)
	self.m_ButterFlySpr = self:NewUI(4, CSprite)
	self.m_MoveLightSpr = self:NewUI(5, CSprite)
	self.m_CaptrueBox = self:NewUI(6, CBox)
	self.m_SuccessSpr = self:NewUI(7, CSprite)
	self.m_DuangSpr1 = self:NewUI(8, CSprite)
	self.m_DuangSpr2 = self:NewUI(9, CSprite)
	self.m_DuangSpr3 = self:NewUI(10, CSprite)
	self.m_SuccessTextrue = self:NewUI(11, CTexture)

	self:InitContent()
	self.m_IsCaptrue = false
	self.m_Speed = 6
	self.m_W1 = 2.5 
	self.m_W2 = 2.9
	self.m_DeltaTime = 0.03
	self.m_ProgreeTimeMax = 1.5
	self.m_AutoDoingShimenTimer = nil
	self.m_ShowTimerList = {}
end

function CTaskSlipCaptruePage.InitContent(self)
	self.m_CaptrueBox:AddUIEvent("click", callback(self, "OnCaptrue"))
	self:AutoDoShiMen()
end

function CTaskSlipCaptruePage.OnCaptrue(self)
	if self.m_IsCaptrue == true then
		return
	end
	self.m_TipsLabel:SetActive(false)
	self.m_IsCaptrue = true
	local cb = function ()
		if Utils.IsNil(self) then
			return false
		end
		self.m_Progress = self.m_Progress + (1 / self.m_ProgreeTimeMax) * self.m_DeltaTime
		if self.m_Progress >= 1 then
			self:FinishAction()
			return false
		end
		local r = 200	
		local offset = self.m_Speed * (1 / self.m_ProgreeTimeMax) * self.m_DeltaTime
		self.m_W1 = self.m_W1 + offset
		local x1 = math.cos(self.m_W1) * r
		local y1 = math.sin(self.m_W1) * r
		self.m_ButterFlySpr:SetLocalPos(Vector3.New(x1, y1 , 0))

		self.m_W2 = self.m_W2 + offset
		local x2 = math.cos(self.m_W2) * r
		local y2 = math.sin(self.m_W2) * r
		self.m_MoveLightSpr:SetLocalPos(Vector3.New(x2, y2 , 0))
		return true
	end
	self.m_Progress = 0
	self.m_ProgressTimer = Utils.AddTimer(cb, self.m_DeltaTime, 0)		
end

function CTaskSlipCaptruePage.FinishAction(self)
	self.m_StartBox:SetActive(false)
	self.m_EndBox:SetActive(true)
	self:ShowSuccessAni()
	local cb = function ()
		if not Utils.IsNil(self) and self.m_ParentView and self.m_ParentView.CompleteCallBack then
			self.m_ParentView:CompleteCallBack()
		end
	end
	Utils.AddTimer(cb, 0, 3)
end

function CTaskSlipCaptruePage.Destroy(self)
	if self.m_ProgressTimer then
		Utils.DelTimer(self.m_ProgressTimer)
		self.m_ProgressTimer = nil
	end
	self:StopAutoDoingShiMenTimer()
	if self.m_ShowTimerList and next(self.m_ShowTimerList) then
		for k, v in pairs(self.m_ShowTimerList) do
			if v then
				Utils.DelTimer(v)
			end
		end
	end
	CPageBase.Destroy(self)
end

function CTaskSlipCaptruePage.AutoDoShiMen(self)
	if g_TaskCtrl:IsAutoDoingShiMen() then
		self:StopAutoDoingShiMenTimer()
		local cb = function ()
			if Utils.IsNil(self) then
				return
			end				
			self:OnCaptrue()
		end
		self.m_AutoDoingShimenTimer = Utils.AddTimer(cb, 0, CTaskCtrl.AutoDoingSM.Time)
	end
end

function CTaskSlipCaptruePage.StopAutoDoingShiMenTimer(self)
	if self.m_AutoDoingShimenTimer then
		Utils.DelTimer(self.m_AutoDoingShimenTimer)
		self.m_AutoDoingShimenTimer = nil
	end
end

function CTaskSlipCaptruePage.ShowSuccessAni(self)
	self.m_ShowTimerList[1] = Utils.AddTimer(callback(self, "SetSprActive", self.m_SuccessSpr, true), 0 , 0.5)
	self.m_ShowTimerList[2] = Utils.AddTimer(callback(self, "SetSprActive", self.m_DuangSpr1, true), 0 , 0.8)
	self.m_ShowTimerList[3] = Utils.AddTimer(callback(self, "SetSprActive", self.m_DuangSpr2, true), 0 , 0.9)
	self.m_ShowTimerList[4] = Utils.AddTimer(callback(self, "SetSprActive", self.m_DuangSpr3, true), 0 , 1.1)	
	self.m_ShowTimerList[4] = Utils.AddTimer(callback(self, "SetSprActive", self.m_SuccessTextrue, true), 0 , 0.1)	

end

function CTaskSlipCaptruePage.SetSprActive(self, obj, b1)
	if obj then
		obj:SetActive(b1)
	end
end

return CTaskSlipCaptruePage