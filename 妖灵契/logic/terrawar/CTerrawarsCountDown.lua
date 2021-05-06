local CTerrawarsCountDown = class("CTerrawarsCountDown", CViewBase)

function CTerrawarsCountDown.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerrawarsCountDown.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = nil
	self.m_BehindStrike = true
end

function CTerrawarsCountDown.OnCreateView(self)
	self.m_ShapeTexture = self:NewUI(1, CTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_TimeLabel = self:NewUI(3, CLabel)
	self.m_MaskSpr = self:NewUI(4, CSprite)
end

function CTerrawarsCountDown.InitView(self, endtime, type)
	CTerraWarReadyView:CloseView()
	self.m_Type = type
	self.m_ShapeTexture:LoadPath(string.format("Texture/Friend/frd_%d.png", g_AttrCtrl.model_info.shape))
	self.m_NameLabel:SetText(g_AttrCtrl.name)
	self.m_EndTime = endtime - g_TimeCtrl:GetTimeS()
	self.m_MaskSpr:SetFillAmount(1)
	self:LeftTime(endtime)
end

function CTerrawarsCountDown.LeftTime(self, endtime)
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	endtime = endtime - g_TimeCtrl:GetTimeS()
	local sType = ""
	--1：继续战斗  2：占领成功
	if self.m_Type == 1 then
		sType = "后进入战斗"
	elseif self.m_Type == 2 then
		sType = "后占领成功"
	end
	local function countdown()
		if Utils.IsNil(self) then
			return false
		end
		self.m_MaskSpr:SetFillAmount(endtime / self.m_EndTime)
		if endtime >= 0 then
			self.m_TimeLabel:SetText(string.format("倒计时 %d 秒%s", endtime, sType))
			endtime = endtime - 1
			return true
		end
		self:CloseView()
		return false
	end
	self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
end

return CTerrawarsCountDown