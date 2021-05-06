-----------------------------------------------------------------------------
--装备的合成选择类型界面


-----------------------------------------------------------------------------

local CForgeCompositeEquipSelectView = class("CForgeCompositeEquipSelectView", CViewBase)

CForgeCompositeEquipSelectView.UIType = 
{	
	Composite = 1,
	EquipFbVipReward = 2,
}

function CForgeCompositeEquipSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeCompositeEquipSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_UIType = CForgeCompositeEquipSelectView.UIType.Composite
	self.m_Config = {}
end

function CForgeCompositeEquipSelectView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_EquipBox = self:NewUI(2, CBox)
	self.m_EquipGrid = self:NewUI(3, CGrid)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self.m_BgSpr = self:NewUI(6, CSprite)
	self.m_CenterSpr = self:NewUI(7, CSprite)
	self.m_SubTitleLabel = self:NewUI(8, CLabel)
	self:InitContent()
end

function CForgeCompositeEquipSelectView.InitContent(self)
	self.m_EquipBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_SelectSid = 0
end

function CForgeCompositeEquipSelectView.SetContent(self, list, uiType, config)
	if not list or next(list) == nil then
		self:CloseView()
	end
	self.m_UIType = uiType or CForgeCompositeEquipSelectView.UIType.Composite
	self.m_Config = config or {}
	self:RefreshType()
	for i, v in ipairs(list) do
		local oBox = self.m_EquipBox:Clone()
		oBox.m_IconSpr = oBox:NewUI(1, CSprite)
		oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
		oBox.m_NameLabel = oBox:NewUI(3, CLabel)
		oBox.m_SchoolLabel = oBox:NewUI(4, CLabel)
		oBox.m_SelectSpr = oBox:NewUI(5, CSprite)
		oBox:SetActive(true)
		oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
		oBox:SetSelected(i == 1)	
		local oItem = data.itemdata.EQUIPSTONE[v]
		oBox.m_IconSpr:SpriteItemShape(oItem.icon)
		oBox.m_NameLabel:SetQualityColorText(oItem.quality, oItem.name)
		oBox.m_QualitySpr:SetItemQuality(oItem.quality)
		if self.m_UIType == CForgeCompositeEquipSelectView.UIType.EquipFbVipReward then
			oBox.m_SchoolLabel:SetQualityColorText(oItem.quality, string.format("Lv.%d", oItem.level ))
		else
			oBox.m_SchoolLabel:SetQualityColorText(oItem.quality, string.format("适用:%s", g_ItemCtrl:GetEquipFitInfoBySid(v) ))
		end
		oBox:AddUIEvent("click", callback(self, "OnClickEquip", v))		
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressPreview", v))	
		self.m_EquipGrid:AddChild(oBox)
	end
	self.m_SelectSid = list[1]
	local cnt = self.m_EquipGrid:GetCount()
	local w, h = self.m_EquipGrid:GetCellSize()
	self.m_BgSpr:SetWidth(cnt * w + 60)
	self.m_CenterSpr:SetWidth(cnt * w + 20)
	if self.m_UIType == CForgeCompositeEquipSelectView.UIType.EquipFbVipReward then
		self.m_BgSpr:SetHeight(350)
		self.m_SubTitleLabel:SetActive(true)
		self.m_TitleLabel:SetLocalPos(Vector3.New(0, 300, 0))			
	else			
		self.m_BgSpr:SetHeight(330)
		self.m_SubTitleLabel:SetActive(false)
		self.m_TitleLabel:SetLocalPos(Vector3.New(0, 270, 0))
	end	
end

function CForgeCompositeEquipSelectView.OnClickEquip(self, sid)
	self.m_SelectSid = sid
end

function CForgeCompositeEquipSelectView.OnLongPressPreview(self, sid, oBox, bpress)
	if bpress then		
		CItemTipsAttrEquipChangeView:ShowView(function (oView)
			local tItem = CItem.NewBySid(sid)
			oView:SetData(tItem, nil, CItemTipsAttrEquipChangeView.enum.Composite, true)
		end)
	end
end

function CForgeCompositeEquipSelectView.OnConfirm(self)
	if self.m_SelectSid ~= 0 then
		if self.m_UIType == CForgeCompositeEquipSelectView.UIType.Composite then
			local id = self.m_Config.id or 0
			netitem.C2GSCompoundItem(self.m_SelectSid, id)
		else		
			local floor = self.m_Config.floor
			if floor then
				nethuodong.C2GSGetEquipFBReward(floor, self.m_SelectSid)
			end
			self:CloseView()
		end		
	end
end

function CForgeCompositeEquipSelectView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.ForgeCompositeSuccess then
		self:CloseView()
	end
end

function CForgeCompositeEquipSelectView.RefreshType(self)
	if self.m_UIType == CForgeCompositeEquipSelectView.UIType.EquipFbVipReward then
		self.m_TitleLabel:SetText("请选择装备")
		self.m_ConfirmBtn:SetText("确定")
	else
		self.m_TitleLabel:SetText("合成武器类型")
		self.m_ConfirmBtn:SetText("确定合成")
	end
end

return CForgeCompositeEquipSelectView