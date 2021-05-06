local CFieldBossAwardView = class("CFieldBossAwardView", CViewBase)

function CFieldBossAwardView.ctor(self, cb)
	CFieldBossAwardView.ctor(self, "UI/Activity/FieldBoss/FieldBossAwardView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_SwitchSceneClose = true
end

function CFieldBossAwardView.OnCreateView(self)
	
	self:InitContent()
end

function CFieldBossAwardView.InitContent(self)
	
end

return CFieldBossAwardView