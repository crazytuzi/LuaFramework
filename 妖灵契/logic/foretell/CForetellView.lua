local CForetellView = class("CForetellView", CViewBase)

function CForetellView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Foretell/ForetellView.prefab", cb)
	--界面设置
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CForetellView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_ForetellSprite = self:NewUI(3, CSprite)
	self.m_DescLabel_1 = self:NewUI(4, CLabel)
	self.m_TitleSprite = self:NewUI(5, CSprite)
	self.m_DescLabel_2 = self:NewUI(6, CLabel)
	self.m_TipsLabel = self:NewUI(7, CLabel)
	self.m_TitleTable = self:NewUI(8, CTable)
	self:InitContent()
end

function CForetellView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CForetellView.SetData(self, oData)
	if oData.detail_icon ~= "" then
		self.m_ForetellSprite:SetActive(true)
		self.m_ForetellSprite:SetSpriteName(oData.detail_icon)
		-- self.m_ForetellSprite:SetLocalPos(Vector3.New(oData.pos.x, oData.pos.y, 0))
		-- self.m_ForetellSprite:SetSize(oData.size.w, oData.size.h)
	else
		self.m_ForetellSprite:SetActive(false)
	end
	if oData.detail_model ~= 0 then
		self.m_ActorTexture:SetActive(true)
		self.m_ActorTexture:ChangeShape(oData.detail_model)
	else
		self.m_ActorTexture:SetActive(false)
	end
	self.m_TitleSprite:SetSpriteName(oData.detail_title)
	self.m_TitleSprite:MakePixelPerfect()
	self.m_TitleTable:Reposition()
	self.m_DescLabel_1:SetText(oData.detail_desc_1)
	self.m_DescLabel_2:SetText(oData.detail_desc_2)
	self.m_TipsLabel:SetText(oData.desc)
end

return CForetellView