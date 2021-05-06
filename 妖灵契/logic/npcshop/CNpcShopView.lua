local CNpcShopView = class("CNpcShopView", CViewBase)

function CNpcShopView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/NpcShopView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_IsAlwaysShow = true
end

function CNpcShopView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainPage = self:NewUI(2, CNpcShopMainPage)
	self.m_SkinPage = self:NewUI(3, CNpcShopSkinPage)
	self.m_BuWaWa = self:NewUI(4, CSpineTexture)
	self:InitContent()
end

function CNpcShopView.OnShowView(self)
	g_ViewCtrl:SaveEnv(function(v)
		return (v:GetDepth() < self:GetDepth() and (not g_HouseCtrl:IsInHouse()) and v.classname ~= "CPaTaView")
	end)
end

function CNpcShopView.InitContent(self)
	self.m_MainPage.m_ParentView = self
	self.m_SkinPage.m_ParentView = self
	self.m_SkinPage:SetActive(true)
	self.m_SkinPage:SetLocalScale(Vector3.New(0.0001, 0.0001, 0.0001))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BuWaWa:AddUIEvent("click", callback(self, "OnClickBuWaWa"))
	self.m_BuWaWa:ShapeShop("BuWaWa", function ()
		self.m_BuWaWa:SetAnimation(0, "idle_1", false)
	end,0.5)
end

function CNpcShopView.OnClickBuWaWa(self)
	self.m_BuWaWa:SetAnimation(0, "idle_2", false)
end

function CNpcShopView.ShowSkin(self, oItemCell)
	-- self:ShowSubPage(self.m_SkinPage)
	self.m_SkinPage:SetActive(true)
	self.m_MainPage:SetActive(false)
	self.m_SkinPage:SetLocalScale(Vector3.one)
	self.m_SkinPage:SetData(oItemCell)
end

function CNpcShopView.ShowMain(self)
	self.m_SkinPage:SetLocalScale(Vector3.New(0.0001, 0.0001, 0.0001))
	self.m_MainPage:SetActive(true)
	-- self:ShowSubPage(self.m_MainPage)
end

function CNpcShopView.SetShopData(self, shopID, goodsID)
	-- self:ShowSubPage(self.m_MainPage)
	self.m_MainPage:SetActive(true)
	self.m_SkinPage:SetLocalScale(Vector3.New(0.0001, 0.0001, 0.0001))
	self.m_MainPage:SetShopData(shopID, goodsID)
end

function CNpcShopView.OpenRecharge(self)
	self.m_MainPage:SetActive(true)
	self.m_SkinPage:SetLocalScale(Vector3.New(0.0001, 0.0001, 0.0001))
	self.m_MainPage:OnRecharge()
end

function CNpcShopView.Destroy(self)
	g_ViewCtrl:RestoreEnv()
	CViewBase.Destroy(self)
	self.m_MainPage:Destroy()
	self.m_SkinPage:DelUpdate()
end

return CNpcShopView