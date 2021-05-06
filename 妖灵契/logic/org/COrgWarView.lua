local COrgWarView = class("COrgWarView", CViewBase)

function COrgWarView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgWarView.prefab", cb)
	-- self.m_ExtendClose = "Shelter"
end

function COrgWarView.OnCreateView(self)
	self.m_ProgressSlider = self:NewUI(1, CSlider)
	self.m_AtkSprite = self:NewUI(2, CSprite)
	self.m_DefSprite = self:NewUI(3, CSprite)
	self.m_StatusLabel = self:NewUI(4, CLabel)
	self.m_Container = self:NewUI(5, CWidget)
	g_OrgWarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgWarEvent"))
end

function COrgWarView.OnShowView(self)
	self:Refresh()
end

function COrgWarView.Refresh(self)
	self.m_AtkSprite:SetActive(false)
	self.m_DefSprite:SetActive(false)
	if g_OrgWarCtrl.m_OrderStatus == define.Org.OrderType.Attack then
		self.m_Container:SetActive(true)
		self.m_AtkSprite:SetActive(true)
		self.m_StatusLabel:SetText("进攻中")
	elseif g_OrgWarCtrl.m_OrderStatus == define.Org.OrderType.Defense then
		self.m_Container:SetActive(true)
		self.m_DefSprite:SetActive(true)
		self.m_StatusLabel:SetText("防御中")
	else
		self.m_Container:SetActive(false)
	end
	self:PlayAni()
end

function COrgWarView.PlayAni(self)
	self.m_Progress = 0
	self.m_Target = 1
	self.m_Speed = 0.2
	if g_OrgWarCtrl.m_OrderStatus == define.Org.OrderType.Attack or g_OrgWarCtrl.m_OrderStatus == define.Org.OrderType.Defense then
		if self.m_TimerID == nil then
			self.m_TimerID = Utils.AddTimer(callback(self, "Update"), 0, 0)
		end
	else
		self:DelTimer()
	end
end

function COrgWarView.Update(self)
	self.m_Progress = self.m_Progress + self.m_Speed * Time.deltaTime
	if self.m_Progress >= self.m_Target then
		self.m_Target = self.m_Target + 1
		if g_OrgWarCtrl.m_OrderStatus == define.Org.OrderType.Attack then
			g_NotifyCtrl:FloatMsg("敌方水晶血量-5")
		end
	end
	self.m_ProgressSlider:SetValue(self.m_Progress - self.m_Target + 1)
	return true
end

function COrgWarView.DelTimer(self)
	if self.m_TimerID then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
end

function COrgWarView.OnOrgWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrderStatus then
		self:Refresh()
	end
end


return COrgWarView