local CTaskAddTipsView = class("CTaskAddTipsView", CViewBase)

function CTaskAddTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskAddTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CTaskAddTipsView.OnCreateView(self)
	self.m_Live2dTexture = self:NewUI(1, CLive2dTexture)
	self.m_Label = self:NewUI(1, CLabel)
	--g_GuideCtrl:StartTipsGuide("Tips_XiaoMengQingQiu")
	self:SetContent()
end

function CTaskAddTipsView.SetContent(self)
	self.m_Live2dTexture:SetDefaultMotion("idle_1")
	self.m_Live2dTexture:LoadModel(tonumber(1003))
	self.m_Live2dTexture.m_LiveModel:PlayMotion("Guide_1", false)
	self.m_Live2dTexture.m_LiveModel:SetRandomMotionList({"Guide_1"})	
end

function CTaskAddTipsView.Destroy(self)
	self.m_Live2dTexture:Destroy()
	CViewBase.Destroy(self)
end

return CTaskAddTipsView