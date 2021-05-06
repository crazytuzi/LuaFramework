local CHouseBuffLvUpView = class("CHouseBuffLvUpView", CViewBase)

function CHouseBuffLvUpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseBuffLvUpView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_OpenEffect = "Scale"
end

function CHouseBuffLvUpView.OnCreateView(self)
	self.m_DescLabel = self:NewUI(1, CLabel)
	self.m_AttrLabel = self:NewUI(2, CLabel)
	self.m_BuffSprite = self:NewUI(3, CSprite)
	self.m_GoBtn = self:NewUI(4, CButton)

	self:InitContent()
end

function CHouseBuffLvUpView.InitContent(self)
	self.m_GoBtn:SetActive(g_HouseCtrl:IsInHouse())
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnClickGo"))
	local oInfo = g_PlayerBuffCtrl:GetHouseBuff()
	local oData = data.housedata.LoveBuff[oInfo.stage]
	self.m_DescLabel:SetText(string.format("总亲密度达到%s级,激活%s阶特殊战斗效果", oInfo.stage, oInfo.stage))
	self.m_AttrLabel:SetText(g_PlayerBuffCtrl:GetHouseAttrStr(oInfo.stage, nil, 2))
	self.m_BuffSprite:SpriteHouseBuff(oData.icon)
end

function CHouseBuffLvUpView.OnClickGo(self)
	if g_HouseCtrl:IsInHouse() then
		local oView = CHouseMainView:GetView()
		if oView and oView:GetActive() then
			CHouseBuffView:ShowView()
		else
			CHouseMainView:SetShowCB(function ()
				CHouseBuffView:ShowView()
				CHouseMainView:ClearShowCB()
			end)
			CHouseExchangeView:CloseView()
		end
	end
	self:OnClose()
end

return CHouseBuffLvUpView