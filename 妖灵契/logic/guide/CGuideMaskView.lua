local CGuideMaskView = class("CGuideMaskView", CViewBase)

function CGuideMaskView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/GuideMaskView.prefab", cb)
	--界面设置
	self.m_DepthType = "Guide"
	self.m_DelayCloseTimer = nil
end

function CGuideMaskView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self:InitContent()
end

function CGuideMaskView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Contanier, 4, 4)
end

function CGuideMaskView.DelayClose(self, time)
	time = time or 5
	if self.m_DelayCloseTimer then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	if time ~= 0 then
		self.m_DelayCloseTimer = Utils.AddTimer(callback(self, "OnMyClose"), 0, time)
	end
	--g_NotifyCtrl:FloatMsg(string.format("显示遮罩界面 %d", time) )
end

function CGuideMaskView.OnMyClose(self)
	if self.m_DelayCloseTimer then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	self:OnClose()
end

function CGuideMaskView.Destroy(self)
	--g_NotifyCtrl:FloatMsg(string.format("关闭遮罩界面"))
	if self.m_DelayCloseTimer then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	CViewBase.Destroy(self)
end

return CGuideMaskView
