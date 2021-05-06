local CAndroidShopView = class("CAndroidShopView", CViewBase)

function CAndroidShopView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Pay/AndroidShopView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
	self.m_OpenEffect = "Scale"
end


function CAndroidShopView.OnCreateView(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_CloseBtn = self:NewUI(3, CButton)

	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:RefreshGrid()
end

function CAndroidShopView.RefreshGrid(self)
	local keys = table.keys(data.paydata.AndroidPay)
	local function sortbylen(k1, k2)
		return #k1 < #k2
	end
	table.sort(keys, sortbylen)
	for i, key in ipairs(keys) do
		local dData = data.paydata.AndroidPay[key]
		self:CreateBox(dData)
	end
end

function CAndroidShopView.CreateBox(self, dPayData)
	local oBox = self.m_BoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_BuyBtn = oBox:NewUI(1, CButton)
	oBox.m_CostLabel = oBox:NewUI(2, CLabel)
	oBox.m_NameLabel = oBox:NewUI(3, CLabel)

	oBox.m_CostLabel:SetText(tostring(dPayData.value/100).."元")
	oBox.m_NameLabel:SetText(dPayData.name)
	oBox.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy", dPayData.key))
	self.m_Grid:AddChild(oBox)
end

function CAndroidShopView.OnBuy(self, key)
	g_SdkCtrl:Pay(key, 1)
end

return CAndroidShopView