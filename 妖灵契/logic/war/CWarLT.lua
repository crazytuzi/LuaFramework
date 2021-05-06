local CWarLT = class("CWarLT", CBox)

function CWarLT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BoutTable = self:NewUI(1, CTable)
	self.m_BoutLabel = self:NewUI(2, CLabel)
	self.m_WaveLabel = self:NewUI(3, CLabel)
	self.m_Table = self:NewUI(4, CTable)
	self.m_StartTimeLabel = self:NewUI(5, CLabel)
	self.m_ExpandBtn = self:NewUI(6, CButton)
	self.m_ExpandBtn.m_Open = false
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "ShowMenuOperate", true))
	self.m_StartTimeLabel:SetActive(false)
	self.m_BoutLabel:SetActive(false)
	self.m_AddCnt = 2
	self.m_StartTime = nil
	self.m_TableDefalutPos = self.m_BoutTable:GetLocalPos()
	local w, h = self.m_BoutLabel:GetSize()
	self.m_TableMoveY = h
	if g_WarCtrl:GetWarType() == define.War.Type.EndlessPVE or g_WarCtrl:GetWarType() == define.War.Type.Pata then
		self.m_Table:SetActive(false)
	end
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	self:Bout()
end

function CWarLT.ShowMenuOperate(self, bShow)
	if bShow then
		self.m_ExpandBtn:SetLocalRotation(Quaternion.Euler(0,0,180))
		CWarMenuOperateView:ShowView()
	else
		self.m_ExpandBtn:SetLocalRotation(Quaternion.Euler(0,0,0))
	end
end

function CWarLT.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.StartTime then
		self:RefreshStartTime()
	end
end

function CWarLT.RefreshStartTime(self)
	self.m_StartTime = g_WarCtrl:GetWarStartTime()
	if self.m_StartTime and self.m_StartTime > 0 then
		if self.m_StartTimer then
			Utils.DelTimer(self.m_StartTimer)
			self.m_StartTimer = nil
		end
		self.m_StartTimeLabel:SetActive(true)
		local time = math.max(g_TimeCtrl:GetTimeS() - self.m_StartTime, 0)
		local function addtime()
			if Utils.IsNil(self) then
				return
			end
			self.m_StartTimeLabel:SetText(string.format("战斗时间：%s", g_TimeCtrl:GetLeftTime(time)))
			time = time + 1
			return true
		end
		self.m_StartTimer = Utils.AddScaledTimer(addtime, 1, 0)
	end
end

function CWarLT.TrunBout(self)
	local iBout = g_WarCtrl:GetBout()
	if self.m_CurBout == iBout then 
		return
	end
	self.m_CurBout = iBout
	local oLabel = self.m_BoutLabel:Clone()
	oLabel:SetActive(true)
	oLabel:SetText(self.m_CurBout)
	self.m_BoutTable:AddChild(oLabel)
	local iCount = self.m_BoutTable:GetCount()
	if iCount > self.m_AddCnt then
		local oChild = self.m_BoutTable:GetChild(1)
		self.m_BoutTable:RemoveChild(oChild)
	end

	self:TweenBout()
end

function CWarLT.TweenBout(self)
	if self.m_BoutTable:GetCount() > 1 then
		self.m_BoutTable:SetLocalPos(self.m_TableDefalutPos)
		local vEndPos = Vector3.New(self.m_TableDefalutPos.x, self.m_TableDefalutPos.y - self.m_TableMoveY, self.m_TableDefalutPos.z) 
		local tweenTable = DOTween.DOLocalMove(self.m_BoutTable.m_Transform, vEndPos, 0.5)
		DOTween.SetEase(tweenTable, enum.DOTween.Ease.Linear)
	end
end

function CWarLT.Bout(self)
	self:TrunBout()

	local waveText = g_WarCtrl:GetWaveText()
	if waveText then
		self.m_WaveLabel:SetActive(true)
		self.m_WaveLabel:SetText(waveText)
	else
		self.m_WaveLabel:SetActive(false)
	end
	self.m_Table:Reposition()
	self:RefreshStartTime()
end

return CWarLT