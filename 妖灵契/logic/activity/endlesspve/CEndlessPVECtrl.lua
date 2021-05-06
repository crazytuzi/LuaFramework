local CEndlessPVECtrl = class("CEndlessPVECtrl", CCtrlBase)

function CEndlessPVECtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ChipList = {}
	self.m_RingInfo = 1
	self.m_CountDownValue = 0
	self.m_OverTime = 0
	self.m_TargetChip = 0
	self.m_ReceiveResult = false
	self.m_ReceiveCb = nil
end

function CEndlessPVECtrl.GetChipList(self)
	nethuodong.C2GSGetEndlessList()
end

function CEndlessPVECtrl.OnReceiveChipList(self, oList)
	-- printc("OnReceiveChipList: ")
	self.m_ChipList = {}
	-- self.m_RefreshCount = refreshed
	for k,v in pairs(oList) do
		self.m_ChipList[v.mode] = v
	end
	if CEndlessPVEView:GetView() then
		self:OnEvent(define.EndlessPVE.Event.OnReceiveChipList)
	else
		CEndlessPVEView:ShowView()
	end

end

function CEndlessPVECtrl.Fight(self, id)
	self.m_ReceiveResult = false
	nethuodong.C2GSEndlessPVEStart(id)
end

-- function CEndlessPVECtrl.GetRefreshCost(self)
-- 	local count = self.m_RefreshCount + 1
-- 	if count > #data.endlesspvedata.RefreshInfo then
-- 		count = #data.endlesspvedata.RefreshInfo
-- 	end
-- 	return data.endlesspvedata.RefreshInfo[count].cost
-- end

function CEndlessPVECtrl.OnReceiveWarRingInfo(self, ring, overTime)
	self.m_RingInfo = ring
	self.m_OverTime = overTime
	self.m_CountDownValue = overTime - g_TimeCtrl:GetTimeS()
	if CEndlessPVEWarView:GetView() == nil then
		CEndlessPVEWarView:ShowView()
	else
		if ring == 1 then
			self:OnEvent(define.EndlessPVE.Event.BeginCountDown)
		end
		self:OnEvent(define.EndlessPVE.Event.OnReceiveRingInfo)
	end
end

function CEndlessPVECtrl.WarEnd(self, passRing)
	if self.m_ReceiveCb then
		self.m_ReceiveCb()
		self.m_ReceiveCb = nil
	end
	self.m_RingInfo = passRing
	self.m_ReceiveResult = true
	self:OnEvent(define.EndlessPVE.Event.OnWarEnd)
end

function CEndlessPVECtrl.GetRingInfo(self)
	return self.m_RingInfo
end

function CEndlessPVECtrl.GetRestTimeS(self)
	return self.m_OverTime - g_TimeCtrl:GetTimeS()
end

function CEndlessPVECtrl.ShowWarResult(self, oCmd)
	local function func()
		CWarResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			if not g_WarCtrl:IsObserverView() then
				oView:ShowEndlessPVEResult()
			end
		end)
	end
	self.m_ReceiveCb = func
	if self.m_ReceiveResult or g_WarCtrl:IsObserverView() then
		self.m_ReceiveCb()
		self.m_ReceiveCb = nil
	end
end

return CEndlessPVECtrl