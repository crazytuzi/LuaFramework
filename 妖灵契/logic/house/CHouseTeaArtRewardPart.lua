local CHouseTeaArtRewardPart = class("CHouseTeaArtRewardPart", CBox)

function CHouseTeaArtRewardPart.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CHouseTeaArtRewardPart.InitContent(self)
	self.m_CloseBtn = self:NewUI(1, CBox)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CItemTipsBox)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_SubmitBtn = self:NewUI(6, CButton)
	self.m_Effect = self:NewUI(7, CUIEffect)
	self.m_Bg = self:NewUI(8, CBox)

	self.m_ItemBox:SetActive(false)
	self.m_ItemBoxArr = {}
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
end

function CHouseTeaArtRewardPart.SetData(self, itemList)
	self:SetLocalScale(Vector3.one)
	self:SetActive(true)
	self.m_Effect:Above(self.m_Bg)
	self.m_Effect:SetActive(true)
	local count = 0
	for k,v in pairs(itemList) do
		count = count + 1
		if self.m_ItemBoxArr[count] == nil then
			self.m_ItemBoxArr[count] = self.m_ItemBox:Clone()
			self.m_ItemGrid:AddChild(self.m_ItemBoxArr[count])
		end
		printc("v.sid: " .. v.sid)
		local itemData = DataTools.GetItemData(v.sid)
		self.m_ItemBoxArr[count]:SetActive(true)
		self.m_TitleLabel:SetText(string.format("获得了%s", itemData.name))
		self.m_ItemBoxArr[count]:SetItemData(v.sid, v.amount, nil, {isLocal = true, uiType = 1})
	end
	count = count + 1
	for i = count, #self.m_ItemBoxArr do
		self.m_ItemBoxArr[i]:SetActive(false)
	end
	self.m_ItemGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CHouseTeaArtRewardPart.OnClickClose(self)
	self:SetLocalScale(Vector3.New(0.001, 0.001, 0.001))
	self.m_Effect:SetActive(false)
end

function CHouseTeaArtRewardPart.OnSubmit(self)
	self:OnClickClose()
end

return CHouseTeaArtRewardPart