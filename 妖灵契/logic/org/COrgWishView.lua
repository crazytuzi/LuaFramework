local COrgWishView = class("COrgWishView", CViewBase)

function COrgWishView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgWishView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgWishView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InfoGrid = self:NewUI(2, CGrid)
	self.m_InfoBox = self:NewUI(3, CBox)
	self.m_WishBtn = self:NewUI(4, CSprite)
	self.m_WishPart = self:NewUI(5, COrgWishChipPart)
	self.m_HelpBtn = self:NewUI(6, CButton)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_WishEquipBtn = self:NewUI(8, CSprite)
	self.m_WishEquipPart = self:NewUI(9, COrgWishEquipPart)
	self.m_XiaoRenTexture = self:NewUI(10, CSpineTexture)

	self:InitContent()
end

function COrgWishView.InitContent(self)
	self.m_XiaoRenTexture:SetActive(false)
	self.m_XiaoRenTexture:ShapeOrg("XiaoRen", function ()
		self.m_XiaoRenTexture:SetActive(true)
		self.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
	end)
	self.m_InfoBoxArr = {}
	self.m_InfoBoxDic = {}
	self.m_EquipBoxDic = {}
	-- self.m_HelpBtn:SetHint(data.helpdata.DATA[define.Help.Key.OrgWish].content, enum.UIAnchor.Side.Bottom)
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_WishBtn:AddUIEvent("click", callback(self, "OnClickWish"))
	self.m_WishEquipBtn:AddUIEvent("click", callback(self, "OnClickWishEquip"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))

	self.m_WishBtn.m_IgnoreCheckEffect = true
	self.m_WishEquipBtn.m_IgnoreCheckEffect = true
	self:SetData()
	self:CheckSelfWish()
	self.m_InfoBox:SetActive(false)
end

function COrgWishView.OnClickHelp(self)
	CHelpView:ShowView(function(oView)
		oView:ShowHelp(define.Help.Key.OrgWish)
	end)
end

function COrgWishView.SetData(self)
	self.m_Data = g_OrgCtrl:GetWishList()
	local givenDic = {}
	local GivenEquipDic = {}
	for k,v in pairs(g_AttrCtrl.give_org_wish) do
		givenDic[v] = true
	end
	for k,v in pairs(g_AttrCtrl.give_org_equip) do
		GivenEquipDic[v] = true
	end

	local count = 0
	for k,v in pairs(self.m_Data) do
		if (v.org_wish ~= nil and v.org_wish.sum_cnt ~= v.org_wish.gain_cnt) then
			count = count + 1
			if self.m_InfoBoxArr[count] == nil then
				self.m_InfoBoxArr[count] = self:CreateInfoBox()
			end
			self.m_InfoBoxDic[v.pid] = self.m_InfoBoxArr[count]
			self.m_InfoBoxArr[count]:SetData(v, givenDic[v.pid], true)
			self.m_InfoBoxArr[count]:SetActive(true)
		end
		if (v.org_wish_equip ~= nil and v.org_wish_equip.sum_cnt ~= v.org_wish_equip.gain_cnt) then
			count = count + 1
			if self.m_InfoBoxArr[count] == nil then
				self.m_InfoBoxArr[count] = self:CreateInfoBox()
			end
			self.m_EquipBoxDic[v.pid] = self.m_InfoBoxArr[count]
			self.m_InfoBoxArr[count]:SetData(v, GivenEquipDic[v.pid], false)
			self.m_InfoBoxArr[count]:SetActive(true)
		end
	end

	count = count + 1
	for i = count, #self.m_InfoBoxArr do
		self.m_InfoBoxArr[i]:SetActive(false)
	end
	-- self.m_InfoGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function COrgWishView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_PositionLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_ShapeSprite = oInfoBox:NewUI(2, CSprite)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(4, CLabel)

	oInfoBox.m_ChipProgressSider = oInfoBox:NewUI(5, CSlider)
	oInfoBox.m_ProgressLabel = oInfoBox:NewUI(6, CLabel)
	oInfoBox.m_ChipQualityBgSprite = oInfoBox:NewUI(7, CSprite)
	oInfoBox.m_ChipSprite = oInfoBox:NewUI(8, CSprite)
	oInfoBox.m_ChipQualitySprite = oInfoBox:NewUI(9, CSprite)
	oInfoBox.m_ChipNameLabel = oInfoBox:NewUI(10, CLabel)
	oInfoBox.m_ChipCountLabel = oInfoBox:NewUI(11, CLabel)

	oInfoBox.m_GivenMark = oInfoBox:NewUI(12, CBox)
	oInfoBox.m_GivenBtn = oInfoBox:NewUI(13, CSprite)
	oInfoBox.m_HandlePart = oInfoBox:NewUI(14, CBox)
	oInfoBox.m_NotEnoughMark = oInfoBox:NewUI(15, CBox)
	oInfoBox.m_OnSelectSprite = oInfoBox:NewUI(16, CSprite)
	oInfoBox.m_PositionBg = oInfoBox:NewUI(17, CSprite)
	oInfoBox.m_ItemQualitySprite = oInfoBox:NewUI(18, CSprite)
	oInfoBox.m_ItemSprite = oInfoBox:NewUI(19, CSprite)

	self.m_InfoGrid:AddChild(oInfoBox)
	oInfoBox:AddUIEvent("click", callback(self, "OnSelectInfoBox", oInfoBox))
	oInfoBox.m_GivenBtn:AddUIEvent("click", callback(self, "OnClickGive", oInfoBox))

	function oInfoBox.SetData(self, oData, hasGiven, bChip)
		oInfoBox.m_Data = oData
		oInfoBox.m_IsChip = bChip

		oInfoBox.m_ChipData = nil
		oInfoBox.m_EquipData = nil
		oInfoBox.m_PositionLabel:SetText(g_OrgCtrl:GetPosition(oData.position).pos)
		oInfoBox.m_PositionBg:SetSpriteName(g_OrgCtrl:GetPosition(oData.position).bg)
		local textColor = g_OrgCtrl:GetPosition(oData.position).text_color
		oInfoBox.m_PositionLabel:SetEffectColor(Color.New(textColor.r, textColor.g, textColor.b, 1))
		
		oInfoBox.m_ShapeSprite:SetSpriteName(tostring(oData.shape))
		oInfoBox.m_NameLabel:SetText(oData.name)
		oInfoBox.m_GradeLabel:SetText(oData.grade)
		local count = 0
		if bChip then
			oInfoBox.m_ChipData = data.partnerdata.CHIP[oData.org_wish.partner_chip]
			oInfoBox.m_ChipQualityBgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(oInfoBox.m_ChipData.rare))
			oInfoBox.m_ChipSprite:SetSpriteName(tostring(oInfoBox.m_ChipData.icon))
			oInfoBox.m_ChipQualitySprite:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(oInfoBox.m_ChipData.rare))
			oInfoBox.m_ChipNameLabel:SetText(oInfoBox.m_ChipData.name)
			oInfoBox.m_ChipProgressSider:SetValue(oData.org_wish.gain_cnt / oData.org_wish.sum_cnt)
			oInfoBox.m_ProgressLabel:SetText(string.format("%s/%s", oData.org_wish.gain_cnt, oData.org_wish.sum_cnt))
			oInfoBox.m_ItemQualitySprite:SetActive(false)
			oInfoBox.m_ChipQualityBgSprite:SetActive(true)
			count = g_ItemCtrl:GetTargetItemCountBySid(oData.org_wish.partner_chip)
		else
			oInfoBox.m_EquipData = data.orgdata.EquipWish[oData.org_wish_equip.sid]
			local itemData = DataTools.GetItemData(oInfoBox.m_EquipData.id)
			oInfoBox.m_ChipQualityBgSprite:SetActive(false)
			oInfoBox.m_ItemQualitySprite:SetActive(true)
			oInfoBox.m_ChipNameLabel:SetText(itemData.name)
			oInfoBox.m_ItemQualitySprite:SetItemQuality(itemData.quality)
			oInfoBox.m_ItemSprite:SpriteItemShape(itemData.icon)
			oInfoBox.m_ChipProgressSider:SetValue(oData.org_wish_equip.gain_cnt / oData.org_wish_equip.sum_cnt)
			oInfoBox.m_ProgressLabel:SetText(string.format("%s/%s", oData.org_wish_equip.gain_cnt, oData.org_wish_equip.sum_cnt))
			count = g_ItemCtrl:GetTargetItemCountBySid(itemData.id)
		end

		
		oInfoBox.m_HandlePart:SetActive(oData.pid ~= g_AttrCtrl.pid)

		if hasGiven then
			oInfoBox.m_GivenBtn:SetActive(false)
			oInfoBox.m_GivenMark:SetActive(true)
			oInfoBox.m_NotEnoughMark:SetActive(false)
			oInfoBox.m_ChipCountLabel:SetText("")
		elseif count <= 0 then
			oInfoBox.m_GivenBtn:SetActive(false)
			oInfoBox.m_GivenMark:SetActive(false)
			oInfoBox.m_ChipCountLabel:SetText("")
			oInfoBox.m_NotEnoughMark:SetActive(true)
		else
			oInfoBox.m_GivenBtn:SetActive(true)
			oInfoBox.m_GivenMark:SetActive(false)
			oInfoBox.m_NotEnoughMark:SetActive(false)
			oInfoBox.m_ChipCountLabel:SetText("拥有数量:" .. count)
		end

	end

	return oInfoBox
end

function COrgWishView.OnSelectInfoBox(self, oInfoBox)
	if self.m_CurrentInfoBox ~= nil then
		self.m_CurrentInfoBox.m_OnSelectSprite:SetActive(false)
	end
	self.m_CurrentInfoBox = oInfoBox
	self.m_CurrentInfoBox.m_OnSelectSprite:SetActive(true)
end

function COrgWishView.OnClickWish(self)
	if g_OrgCtrl:IsPlayerWishedChip() then
		g_NotifyCtrl:FloatMsg("您今天已进行过许愿，请于明天再来许愿")
	else
		self.m_WishPart:SetData()
	end
end

function COrgWishView.OnClickWishEquip(self)
	if g_OrgCtrl:IsPlayerWishedEquip() then
		g_NotifyCtrl:FloatMsg("您今天已进行过许愿，请于明天再来许愿")
	else
		self.m_WishEquipPart:SetData()
	end
end

function COrgWishView.OnClickGive(self, oInfoBox)
	-- printc("OnClickGive: " .. oInfoBox.m_Data.pid)
	if oInfoBox.m_Data ~= nil then
		self:OnSelectInfoBox(oInfoBox)
		if oInfoBox.m_ChipData ~= nil then
			netorg.C2GSGiveOrgWish(oInfoBox.m_Data.pid)
		elseif oInfoBox.m_EquipData ~= nil then
			netorg.C2GSGiveOrgEquipWish(oInfoBox.m_Data.pid)
		end
	else
		g_NotifyCtrl:FloatMsg("该愿望已消失")
		self:SetData()
	end
end

function COrgWishView.CheckSelfWish(self)
	if g_OrgCtrl:IsPlayerWishedChip() then
		self.m_WishBtn:SetGrey(true)
		self.m_WishBtn:DelEffect("RedDot")
	else
		self.m_WishBtn:AddEffect("RedDot", 20, Vector3.New(-20, -20, 0))
		self.m_WishBtn:SetGrey(false)
	end
	if g_OrgCtrl:IsPlayerWishedEquip() then
		self.m_WishEquipBtn:SetGrey(true)
		self.m_WishEquipBtn:DelEffect("RedDot")
	else
		self.m_WishEquipBtn:AddEffect("RedDot", 20, Vector3.New(-20, -20, 0))
		self.m_WishEquipBtn:SetGrey(false)
	end
	self.m_WishEquipBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade)
end

function COrgWishView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:CheckSelfWish()
	end
end

function COrgWishView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.DelMember then
		if oCtrl.m_EventData ~= g_AttrCtrl.pid then
			if self.m_InfoBoxDic[oCtrl.m_EventData] then
				self.m_InfoBoxDic[oCtrl.m_EventData].m_Data = nil
			end
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnUpdateMemberInfo then
		self:SetData()
	end
end

function COrgWishView.OnClickClose(self)
	netorg.C2GSLeaveOrgWishUI()
	self:OnClose()
end

return COrgWishView