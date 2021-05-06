local CThanksView = class("CThanksView", CViewBase)

function CThanksView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/ThanksView.prefab", cb)
	--界面设置
	self.m_DepthType = "Notify"
	self.m_ExtendClose = "Black"
	-- self.m_OpenEffect = "Scale"
end

function CThanksView.OnCreateView(self)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_SexSprite = self:NewUI(2, CSprite)
	self:InitContent()
end

function CThanksView.InitContent(self)
	g_NotifyCtrl:HideConnect()
	self.m_HasParent = false
	if g_AttrCtrl.sex ~= 1 then
		self.m_SexSprite:SetSpriteName("text_xiexiexiaojiejie")
	else
		self.m_SexSprite:SetSpriteName("text_xiexiedagege")
	end
	Utils.AddTimer(callback(self, "CheckParent"), 0, 0)
end

function CThanksView.CheckParent(self)
	if CItemRewardListView:GetView() then
		self.m_HasParent = true
	elseif self.m_HasParent then
		self:OnClose()
	end
	return true
end

return CThanksView