local CReplaceParEquipView = class("CReplaceParEquipView", CViewBase)

function CReplaceParEquipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParEquipReplaceView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CReplaceParEquipView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_WrapContent = self:NewUI(3, CWrapContent)
	self.m_ItemObj = self:NewUI(4, CBox)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CReplaceParEquipView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnReplaceEquip"))
	self.m_ItemObj:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_ItemObj, callback(self, "SetWrapCloneChild"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "SetWrapRefreshFunc"))
end

function CReplaceParEquipView.SetPartner(self, iParID)
	self.m_ParID = iParID
	local newlist = {}
	for _, oPartner in ipairs(g_PartnerCtrl:GetPartnerByRare(0)) do
		if oPartner.m_ID ~= iParID then
			local t = oPartner:GetValue("equip_list")
			table.insert(newlist, oPartner)
		end
	end
	table.sort(newlist, callback(self, "SortFunc"))
	self.m_SelID = newlist[1].m_ID
	self.m_WrapContent:SetData(newlist, true)
end

function CReplaceParEquipView.SortFunc(self, oPartner1, oPartner2)
	local t1 = oPartner1:GetValue("equip_list") or {}
	local t2 = oPartner2:GetValue("equip_list") or {}
	if #t1 ~= #t2 then
		if #t1 == 0 then
			return false
		elseif #t2 == 0 then
			return true
		end
	end
	local pos1 = g_PartnerCtrl:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = g_PartnerCtrl:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 < pos2
	end
	local iPowner1 = oPartner1:GetValue("power")
	local iPowner2 = oPartner2:GetValue("power")
	if iPowner1 and iPowner2 and iPowner1 ~= iPowner2 then
		return iPowner2 < iPowner1
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CReplaceParEquipView.SetWrapCloneChild(self, oChild)
	oChild.m_ParSpr = oChild:NewUI(1, CSprite)
	oChild.m_AwakeSpr = oChild:NewUI(2, CSprite)
	oChild.m_GradeLabel = oChild:NewUI(3, CLabel)
	oChild.m_Border = oChild:NewUI(4, CSprite)
	oChild.m_ParEquipList = {}
	for i = 1, 4 do
		oChild.m_ParEquipList[i] = oChild:NewUI(4+i, CParEquipItem)
	end
	oChild.m_SelSpr = oChild:NewUI(9, CSprite)
	oChild.m_SelSpr:SetActive(false)
	oChild:SetActive(false)
	oChild:AddUIEvent("click", callback(self, "OnClickItemObj", oChild))
	return oChild
end

function CReplaceParEquipView.SetWrapRefreshFunc(self, oChild, oPartner)
	if oPartner then
		oChild.m_ParSpr:SpriteAvatarBig(oPartner:GetShape())
		oChild.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
		oChild.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
		g_PartnerCtrl:ChangeRareBorder(oChild.m_Border, oPartner:GetValue("rare"))
		oChild.m_ID = oPartner.m_ID
		local info = oPartner:GetCurEquipInfo()
		
		for i = 1, 4 do
			oChild.m_ParEquipList[i]:SetActive(false)
			if info[i] then
				oChild.m_ParEquipList[i]:SetActive(true)
				oChild.m_ParEquipList[i]:SetItem(info[i])
				oChild.m_ParEquipList[i].m_Icon:AddUIEvent("click", callback(self, "OnClickEquip", info[i]))
			end
		end
		oChild.m_SelSpr:SetActive(self.m_SelID == oChild.m_ID)
		oChild:SetActive(true)
	else
		oChild:SetActive(false)
	end
end

function CReplaceParEquipView.IsValidOpen(cls, iItemID)
	local oCurItem = g_ItemCtrl:GetItem(iItemID)
	local dItemList = g_ItemCtrl:GetPartnerEquip()
	local dSortList = {}
	if oCurItem then
		for _, oItem in ipairs(dItemList) do
			if oItem:GetValue("pos") == oCurItem:GetValue("pos") and oItem.m_ID ~= oCurItem.m_ID then
				return true
			end
		end
	end
	g_NotifyCtrl:FloatMsg("无可进行更换的符文")
	return false
end


function CReplaceParEquipView.OnReplaceEquip(self)
	if self.m_SelID then
		CPartnerPlanCompareView:ShowView(function (oView)
			oView:SetPartnerID(self.m_ParID, self.m_SelID)
		end)
	end
	self:OnClose()
end

function CReplaceParEquipView.OnClickEquip(self, iItemID)
	local oItem = g_ItemCtrl:GetItem(iItemID)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {})
	end
end

function CReplaceParEquipView.OnClickItemObj(self, oItemObj)
	self.m_SelID = oItemObj.m_ID
	for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
		if oChild:GetActive() then
			oChild.m_SelSpr:SetActive(self.m_SelID == oChild.m_ID)
		end
	end
end

return CReplaceParEquipView