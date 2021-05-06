local CWarWinView = class("CWarWinView", CViewBase)

function CWarWinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarWinView.prefab", cb)

	self.m_GroupName = "WarMain"
	self.m_ExtendClose = "Black"
end

function CWarWinView.OnCreateView(self)
	self.m_PlayerTexture = self:NewUI(1, CTexture)
	self.m_ExpGrid = self:NewUI(2, CGrid)
	self.m_ExpBox = self:NewUI(3, CBox)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_ItemBox = self:NewUI(5, CItemTipsBox)
	self.m_DescLabel = self:NewUI(6, CLabel)
	self.m_LittleTitleLabel = self:NewUI(7, CLabel)
	self.m_WarID = nil

	self.m_ExpBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_PlayerTexture:LoadFullPhoto(g_AttrCtrl.model_info.shape)
	g_EndlessPVECtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))

	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CWarWinView.SetWarID(self, id)
	self.m_WarID = id
	local dResultInfo = g_WarCtrl.m_ResultInfo
	if g_WarCtrl:GetWarType() == define.War.Type.EndlessPVE then
		self.m_LittleTitleLabel:SetActive(true)
		self:RefreshEndlessRing()
	end
	if dResultInfo.war_id ~= id then
		return
	end
	self.m_ExpDatas = dResultInfo.exp_list
	self:RefreshExpGrid()
	self.m_ItemDatas = dResultInfo.item_list
	self:RefreshItemGrid()
	local sText = dResultInfo.desc or ""
	self.m_DescLabel:SetText(sText)
end

function CWarWinView.RefreshExpGrid(self)
	self.m_ExpGrid:Clear()
	for i, dExp in ipairs(self.m_ExpDatas) do
		local oBox = self.m_ExpBox:Clone()
		oBox:SetActive(true)
		oBox.m_Avatar = oBox:NewUI(1, CSprite)
		oBox.m_ExpLabel = oBox:NewUI(2, CLabel)
		oBox.m_LvLabel = oBox:NewUI(3, CLabel)
		oBox.m_Slider = oBox:NewUI(4, CSlider)

		oBox.m_Avatar:SpriteAvatar(dExp.shape)
		oBox.m_ExpLabel:SetText(string.format("EXP +%d", dExp.add))
		oBox.m_LvLabel:SetText(string.format("lv.%d", dExp.grade))
		if dExp.max > 0 then
			oBox.m_Slider:SetValue(dExp.cur/dExp.max)
		else
			oBox.m_Slider:SetValue(1)
		end
		self.m_ExpGrid:AddChild(oBox)
	end
end

function CWarWinView.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	for i, dItemInfo in ipairs(self.m_ItemDatas) do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		local config = {isLocal = true,}
		if  dItemInfo.virtual ~= 1010 then
			oBox:SetItemData(dItemInfo.sid, dItemInfo.amount, nil ,config)	
		else
			oBox:SetItemData(dItemInfo.virtual, dItemInfo.amount, dItemInfo.sid ,config)	
		end
		self.m_ItemGrid:AddChild(oBox)
	end
end

function CWarWinView.RefreshEndlessRing(self)
	self.m_LittleTitleLabel:SetText(string.format("通关%s波", g_EndlessPVECtrl:GetRingInfo()))
end

function CWarWinView.CloseView(self)
	g_WarCtrl:SetInResult(false)
	CViewBase.CloseView(self)
end

function CWarWinView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.EndlessPVE.Event.OnWarEnd then
		self:RefreshEndlessRing()
	end
end

function CWarWinView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	CViewBase.Destroy(self)
end

return CWarWinView