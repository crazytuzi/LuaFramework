local CTeaartCollectPage = class("CTeaartCollectPage", CPageBase)

function CTeaartCollectPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeaartCollectPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(1, CFactoryPartScroll)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_GiftBtn = self:NewUI(3, CButton)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "HideAll"))
	self.m_GiftBtn:AddUIEvent("click", callback(self, "OnGift"))
	self.m_FactoryScroll:SetPartSize(2, 4)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprite = oBox:NewUI(1, CSprite)
			oBox.m_CntLabel = oBox:NewUI(2, CLabel)
			oBox.m_ID = dData.id
			oBox.m_ItemData = DataTools.GetItemData(dData.sid)
			oBox.m_Sprite:SpriteItemShape(oBox.m_ItemData.icon)
			oBox.m_CntLabel:SetText(tostring(dData.amount))
			oBox:AddUIEvent("click", callback(self, "OnClickBox"))
			oBox:SetActive(true)
			return oBox
		end
	end
	self.m_FactoryScroll:SetFactoryFunc(factory)
	self.m_FactoryScroll:SetDataSource(callback(g_HouseCtrl, "GetGiftList"))
	self.m_FactoryScroll:RefreshAll()
end

function CTeaartCollectPage.OnClickBox(self, oBox)
	CHouseItemDescView:ShowView(function(oView)
		oView:SetItemShape(oBox)
	end)
end

function CTeaartCollectPage.OnGift(self)
	self.m_ParentView:CloseView()
	if g_HouseCtrl:IsHouseOnly() then
		CHouseExchangeTestView:ShowView(function(oView)
			oView:SetMode("gift")
		end)
	else
		CHouseExchangeView:ShowView(function(oView)
			oView:SetMode("gift")
		end)
	end
end

function CTeaartCollectPage.HideAll(self)
	self.m_ParentView:HideAllPage()
end

return CTeaartCollectPage