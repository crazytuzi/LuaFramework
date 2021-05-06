local CItemTipsPartnerSoulPage = class("CItemTipsPartnerSoulPage", CPageBase)

CItemTipsPartnerSoulPage.EnumPopup = 
{
	Use  = { Enum = 1, String = "使用", Key = "use"},
	Get  = { Enum = 2, String = "获取", Key = "get"},	
	Sell = { Enum = 3, String = "卖出", Key = "sell"},	
}


function CItemTipsPartnerSoulPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CItem = nil
	self.m_BG = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_AttrBox = self:NewUI(3, CBox)
	self.m_LockBtn = self:NewUI(4, CButton)
	self.m_UnLockBtn = self:NewUI(5, CButton)
	self.m_ReplaceBtn = self:NewUI(6, CButton)
	self.m_StrongBtn = self:NewUI(7, CButton)
	self.m_MainGrid = self:NewUI(8, CGrid)
	self.m_SoulItem = self:NewUI(9, CParSoulItem)
	self.m_ExpSlider = self:NewUI(10, CSlider)
	self.m_CompareBox = self:NewUI(11, CBox)
	self.m_TipsLabel = self:NewUI(12, CLabel)
	self.m_DescLabel = self:NewUI(13, CLabel)
	self.m_CompareBox:SetActive(false)
	self.m_AttrBox:SetActive(false)
	self:InitCompareBox()
	self:InitContent()
end

function CItemTipsPartnerSoulPage.InitContent(self)
	self.m_StrongBtn:AddUIEvent("click", callback(self, "OnStrong"))
	self.m_ReplaceBtn:AddUIEvent("click", callback(self, "PutEquip"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_UnLockBtn:AddUIEvent("click", callback(self, "OnLock"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
end

function CItemTipsPartnerSoulPage.InitCompareBox(self)
	local box = self.m_CompareBox
end


function CItemTipsPartnerSoulPage.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerEquip then
		if self.m_CItem and oCtrl.m_EventData == self.m_CItem.m_ID then
			self:SetInitBox(self.m_CItem)
		end

	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if self.m_CItem and oCtrl.m_EventData == self.m_CItem then
			self:SetInitBox(self.m_CItem)
		end
	end

end

function CItemTipsPartnerSoulPage.ShowPage(self, tItem, args)
	CPageBase.ShowPage(self)
	self:SetInitBox(tItem)
	self.m_DescLabel:SetActive(false)
	if tItem.m_ID then --没有道具唯一id的显示默认
		if args and args.partner then
			self:SetPartner(args.partner)
			if args.callback then
				self.m_CallBack = args.callback
			end
			self.m_ReplaceBtn:SetActive(true)
			self.m_StrongBtn:SetActive(true)
			--游戏精灵，特殊处理，更多按钮添加手指指引
		elseif args and args.equiplist then
			self:SetEquipList(args.equiplist)
			if args.callback then
				self.m_CallBack = args.callback
			end
		else
			self.m_ReplaceBtn:SetActive(false)
			self.m_StrongBtn:SetActive(false)
			self.m_DescLabel:SetActive(true)
		end
	end
	
	if args then
		if (args.isLink or args.hideui) then
			self:HideUI()
		end
		if args.hideBtn then
			self.m_DescLabel:SetActive(true)
			self.m_ReplaceBtn:SetActive(false)
			self.m_StrongBtn:SetActive(false)
		end
	end
end

function CItemTipsPartnerSoulPage.SetInitBox(self, oItem)
	if not oItem then
		return
	end
	local dColorList = {"#G", "#B", "#P", "#O", "#G", "#R"}
	self.m_CItem = oItem
	local sName = string.replace(oItem:GetValue("name"), "·", "\n")
	self.m_NameLabel:SetText(string.getstringdark(dColorList[oItem:GetValue("quality")])..sName)
	
	if oItem:GetValue("lock") == 1 then
		self.m_LockBtn:SetActive(true)
		self.m_UnLockBtn:SetActive(false)
	else
		self.m_LockBtn:SetActive(false)
		self.m_UnLockBtn:SetActive(true)
	end
	self.m_SoulItem:SetItemData(oItem)
	local mainattr = self:GetAttrList(oItem:GetValue("attr"))
	self.m_MainGrid:Clear()
	for _, attrlist in ipairs(mainattr) do
		local box = self.m_AttrBox:Clone()
		box:SetActive(true)
		box.m_Name = box:NewUI(1, CLabel)
		box.m_Value = box:NewUI(2, CLabel)
		box.m_Name:SetText(attrlist[1])
		box.m_Value:SetText(attrlist[2])
		self.m_MainGrid:AddChild(box)
	end
	self.m_MainGrid:Reposition()
	if oItem:GetValue("level") == 15 then
		self.m_ExpSlider:SetSliderText("已满级")
		self.m_ExpSlider:SetValue(1)
	else
		local iExp, iNextExp = g_ItemCtrl:GetParSoulExp(oItem)
		self.m_ExpSlider:SetSliderText(string.format("%d/%d", iExp, iNextExp))
		self.m_ExpSlider:SetValue(iExp/iNextExp)
	end
	local oParSoulTypeData = data.partnerequipdata.ParSoulType[oItem:GetValue("soul_type")]

	self.m_DescLabel:SetText(string.format("[fe4e13ff]%s核心[-]：%s", oParSoulTypeData.name, oParSoulTypeData.skill_desc))
	self.m_TipsLabel:SetText(string.format("[e5de59ff]该御灵仅穿戴到[fe4e13ff]%s[-]核心中", oParSoulTypeData.name))
end

function CItemTipsPartnerSoulPage.HideUI(self)
	self.m_LockBtn:SetActive(false)
	self.m_UnLockBtn:SetActive(false)
end

function CItemTipsPartnerSoulPage.GetAttrList(self, sAttr)
	local dAttr2Name = data.partnerequipdata.EQUIPATTR
	local dAttrData = self.m_CItem:GetParSoulAttr()

	local attrlist = {}
	for key, value in pairs(dAttrData) do
		local attrname = dAttr2Name[key]["name"]
		local attrvalue = ""
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			attrvalue = self:GetPrintPecent(value)
		else
			attrvalue = tostring(value)
		end
		table.insert(attrlist, {attrname, attrvalue})
	end
	return attrlist
end

function CItemTipsPartnerSoulPage.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CItemTipsPartnerSoulPage.SetEquipList(self, equiplist)
	self.m_EquipList = equiplist
	self.m_ReplaceBtn:SetActive(true)
	local v = self.m_ReplaceBtn:GetLocalPos()
	v.x = 30
	self.m_ReplaceBtn:SetLocalPos(v)
	table.print(equiplist, self.m_CItem.m_ID)
	if table.index(equiplist, self.m_CItem.m_ID) then
		self.m_ReplaceBtn:SetText("卸下")
	else
		self.m_ReplaceBtn:SetText("穿戴")
	end
end

function CItemTipsPartnerSoulPage.SetPartner(self, oPartner)
	self.m_CurPartner = oPartner
	if not oPartner then
		self.m_StrongBtn:SetActive(false)
		self.m_ReplaceBtn:SetActive(false)
		return
	end
	self.m_ReplaceBtn:SetActive(true)
	local dSoulInfo = oPartner:GetParSoulList()
	local bWear = false
	local iDropPos = 0
	for iPos, iItemID in pairs(dSoulInfo) do
		if iItemID == self.m_CItem.m_ID then
			bWear = true
			iDropPos = iPos
		end
	end
	if bWear then
		self.m_ReplaceBtn:SetActive(true)
		self.m_ReplaceBtn:SetText("卸下")
		self.m_ReplaceBtn:AddUIEvent("click", callback(self, "DropEquip", iDropPos))
	else
		local iPos = oPartner:GetRestSoulPos()
		if iPos > 0 then
			self.m_ReplaceBtn:SetActive(true)
			self.m_ReplaceBtn:SetText("穿戴")
		end
	end
end

function CItemTipsPartnerSoulPage.PutEquip(self)
	if self.m_CallBack then
		self.m_CallBack(self.m_CItem)
	else
		local oPartner = self.m_CurPartner 
		if oPartner then
			if oPartner:GetValue("soul_type") == self.m_CItem:GetValue("soul_type") then
				local iAttrType = self.m_CItem:GetValue("attr_type")
				for k, v in pairs(oPartner:GetParSoulList()) do
					local oItem = g_ItemCtrl:GetItem(v)
					if oItem and oItem:GetValue("attr_type") == iAttrType then
						local oView = CPartnerMainView:GetView()
						if oView and oView.m_SoulPage and oView.m_SoulPage:GetActive() then
							oView.m_SoulPage:DoFlashEffect(k)
						end
						g_NotifyCtrl:FloatMsg("同属性类型的御灵仅可穿一件")
						return
					end
				end
			end
			local iPos = oPartner:GetRestSoulPos()
			if iPos > 0 then
				netpartner.C2GSUsePartnerSoul(oPartner.m_ID, self.m_CItem.m_ID, iPos)
			else
				CPartnerSoulSelectView:ShowView(function (oView)
					oView:SetPartner(oPartner.m_ID, self.m_CItem.m_ID)
				end)
				g_NotifyCtrl:FloatMsg("当前核心御灵已满")
			end
		end
	end
	self.m_ParentView:OnClose()
end

function CItemTipsPartnerSoulPage.DropEquip(self, iPos)
	if self.m_CallBack then
		self.m_CallBack(self.m_CItem)
	else
		local oPartner = self.m_CurPartner 
		if oPartner then
			netpartner.C2GSUsePartnerSoul(oPartner.m_ID, self.m_CItem.m_ID, iPos)
		end
	end
	self.m_ParentView:OnClose()
end

function CItemTipsPartnerSoulPage.OnStrong(self)
	local parid = nil
	if self.m_CurPartner then
		parid = self.m_CurPartner.m_ID
	end
	if self.m_CItem:GetValue("level") >= 15 then
		g_NotifyCtrl:FloatMsg("此御灵已经满级")
		return
	end
	CParSoulUpGradeView:ShowView(function(oView)
		oView:SetItem(self.m_CItem)
	end)
	self.m_ParentView:OnClose()
end

function CItemTipsPartnerSoulPage.OnCompose(self)
	if self.m_CItem:GetValue("lock") == 1 then
		g_NotifyCtrl:FloatMsg("已上锁的符文无法熔炼")
		return
	end
	CPartnerEquipComposeView:ShowView(function(oView)
		oView:SetItemID(self.m_CItem)
		end)
	self.m_ParentView:OnClose()
end

function CItemTipsPartnerSoulPage.OnLock(self)
	netpartner.C2GSLockPartnerItem(self.m_CItem.m_ID)
	--self.m_ParentView:OnClose()
end

function CItemTipsPartnerSoulPage.OnMoreClick(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local sText = subMenu.m_Label:GetText()
	if sText == "强化" then
		self:OnStrong()
	
	elseif sText == "合成" then
		self:OnCompose()
	end
end

function CItemTipsPartnerSoulPage.Destroy(self)
	CPageBase.Destroy(self)
end

return CItemTipsPartnerSoulPage