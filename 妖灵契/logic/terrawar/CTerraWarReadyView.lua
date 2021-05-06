local CTerraWarReadyView = class("CTerraWarReadyView", CViewBase)

function CTerraWarReadyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerraWarReadyView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTerraWarReadyView.OnCreateView(self)
	self.m_BoxA = self:NewUI(1, CBox)
	self.m_BoxE = self:NewUI(2, CBox)
	self.m_ReadyLabel = self:NewUI(3, CLabel)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CTerraWarReadyView.InitContent(self)
	self.m_LeftTimer = nil
	self:InitBoxAandBoxB()
end

function CTerraWarReadyView.InitBoxAandBoxB(self)
	self.m_BoxA.m_Pid = nil
	self.m_BoxA.m_ShapeTexture = self.m_BoxA:NewUI(1, CTexture)
	self.m_BoxA.m_NameLabel = self.m_BoxA:NewUI(2, CLabel)

	self.m_BoxE.m_Pid = nil
	self.m_BoxE.m_ShapeTexture = self.m_BoxE:NewUI(1, CTexture)
	self.m_BoxE.m_NameLabel = self.m_BoxE:NewUI(2, CLabel)
end

function CTerraWarReadyView.InitView(self, ready, end_time)
	local readycount = 0
	local dReadyA = ready[1]
	self.m_BoxA.m_Pid = dReadyA.pid
	self.m_BoxA.m_NameLabel:SetText(dReadyA.name)
	self.m_BoxA.m_ShapeTexture:LoadPath(string.format("Texture/Friend/frd_%d.png",dReadyA.shape))
	if dReadyA.status == 2 then
		readycount = readycount + 1
	end

	local dReadyE = ready[2]
	self.m_BoxE.m_Pid = dReadyE.pid
	self.m_BoxE.m_NameLabel:SetText(dReadyE.name)
	self.m_BoxE.m_ShapeTexture:LoadPath(string.format("Texture/Friend/frd_%d.png",dReadyE.shape))
	if dReadyE.status == 2 then
		readycount = readycount + 1
	end

	self.m_ReadyLabel:SetText(string.format("%d/2已就绪", readycount))
	if dReadyA.status == 1 and dReadyE.status == 1 then
		self:FightLeftTime(1)
	else
		self:ReadyLeftTime(end_time)
	end
end

function CTerraWarReadyView.ReadyLeftTime(self, end_time)
	if self.m_LeftTimer then
		return
	end
	end_time = end_time - g_TimeCtrl:GetTimeS()
	local function countdown()
		if Utils.IsNil(self) then
			return false
		end
		if end_time >= 0 then
			self.m_TimeLabel:SetText(string.format("倒计时 %d 秒", end_time))
			end_time = end_time - 1
			return true
		end
		self:CloseView()
		return false
	end
	self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
end

function CTerraWarReadyView.FightLeftTime(self, end_time)
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	
	local function countdown()
		if Utils.IsNil(self) then
			return false
		end
		if end_time >= 0 then
			self.m_TimeLabel:SetText(string.format("即将进入战斗 %d 秒", end_time))
			end_time = end_time - 1
			return true
		end
		self:CloseView()
		return false
	end
	self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
end

return CTerraWarReadyView