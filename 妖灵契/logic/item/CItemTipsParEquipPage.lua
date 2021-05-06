local CItemTipsParEquipPage = class("CItemTipsParEquipPage", CPageBase)

CItemTipsParEquipPage.EnumPopup = 
{
	Use  = { Enum = 1, String = "使用", Key = "use"},
	Get  = { Enum = 2, String = "获取", Key = "get"},	
	Sell = { Enum = 3, String = "卖出", Key = "sell"},	
}


function CItemTipsParEquipPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_LeftPos = Vector3.New(-160, 300, 0)
	self.m_RightPos = Vector3.New(271, 300, 0)
	self.m_CItem = nil
	self.m_BG = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_AttrBox = self:NewUI(3, CBox)
	self.m_SubGrid = self:NewUI(4, CGrid)
	self.m_LockBtn = self:NewUI(5, CButton)
	self.m_UnLockBtn = self:NewUI(6, CButton)
	self.m_TypeDescLabel = self:NewUI(7, CLabel)
	
	self.m_ReplaceBtn = self:NewUI(8, CButton)
	self.m_MorePopupBox = self:NewUI(9, CPopupBox, true, CPopupBox.EnumMode.NoneSelectedMode,nil, true)
	self.m_EquipItem = self:NewUI(10, CParEquipItem)
	self.m_StrongBtn = self:NewUI(11, CButton)
	self.m_SellBtn = self:NewUI(12, CButton)
	self.m_MainGrid = self:NewUI(14, CGrid)
	self.m_BtnWidget = self:NewUI(15, CWidget)
	self.m_BodyWidget = self:NewUI(16, CWidget)
	self.m_SpeicailDesc = self:NewUI(17, CLabel)

	self.m_MorePopupBox:AddSubMenu("强化")
	self.m_MorePopupBox:AddSubMenu("合成")
	self.m_MorePopupBox:SetCallback(callback(self, "OnMoreClick"))
	self.m_MorePopupBox:AddMainBtnCallBack(callback(self, "OnClickMoreBtn"))
	self.m_AttrBox:SetActive(false)
	
	self.m_CompareBox = self:NewUI(13, CBox)
	self.m_CompareBox:SetActive(false)
	self:InitCompareBox()
	self:InitContent()
end

function CItemTipsParEquipPage.InitContent(self)
	self.m_StrongBtn:AddUIEvent("click", callback(self, "OnStrong"))
	self.m_ReplaceBtn:AddUIEvent("click", callback(self, "PutEquip"))
	self.m_SellBtn:AddUIEvent("click", callback(self, "OnSell"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_UnLockBtn:AddUIEvent("click", callback(self, "OnLock"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
	g_GuideCtrl:AddGuideUI("partner_equip_replace_btn", self.m_ReplaceBtn)
	g_GuideCtrl:AddGuideUI("partner_equip_strong_btn", self.m_StrongBtn)
end

function CItemTipsParEquipPage.InitCompareBox(self)
	local box = self.m_CompareBox
	box.m_BG = box:NewUI(1, CSprite)
	box.m_NameLabel = box:NewUI(2, CLabel)
	box.m_AttrBox = box:NewUI(3, CBox)
	box.m_SubGrid = box:NewUI(4, CGrid)
	box.m_EquipItem = box:NewUI(5, CParEquipItem)
	box.m_TypeDescLabel = box:NewUI(6, CLabel)
	box.m_MainGrid = box:NewUI(7, CGrid)
	box.m_AttrBox:SetActive(false)
end

function CItemTipsParEquipPage.InitPartnerEquip(self, box)
	box.m_IconSpr = box:NewUI(2, CSprite)
	box.m_StarGrid= box:NewUI(3, CGrid)
	box.m_StarSpr = box:NewUI(4, CSprite)
	box.m_GradeLabel = box:NewUI(5, CLabel)
	box.m_StarSpr:SetActive(false)
end

function CItemTipsParEquipPage.OnItemEvent(self, oCtrl)
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

function CItemTipsParEquipPage.ShowPage(self, tItem, args)
	self:SetLocalPos(self.m_LeftPos)
	CPageBase.ShowPage(self)
	if not tItem.m_ID then --没有道具唯一id的显示默认
		self:SetInitBox(tItem)
		self:ShowLocalItem(tItem)
		return
	end
	self.m_SpeicailDesc:SetActive(false)
	self.m_BodyWidget:SetActive(true)
	self:SetInitBox(tItem)
	
	local h = self.m_TypeDescLabel:GetHeight()
	if args and args.partner then
		self:SetEquipList(args.equiplist)
		self:SetPartner(args.partner)
		if args.callback then
			self.m_CallBack = args.callback
		end
		self.m_BG:SetSize(470, math.max(0, h-46) + 450)
		self.m_ReplaceBtn:SetActive(true)
		self.m_StrongBtn:SetActive(false)
		self.m_SellBtn:SetActive(true)
		self.m_BtnWidget:SetLocalPos(Vector3.New(-34, -387-(h-46), 0))
	else
		if args.hideui then
			self:HideUI()
		end
		self.m_BG:SetSize(470, math.max(0, h-40) + 400)
		self.m_ReplaceBtn:SetActive(false)
		self.m_StrongBtn:SetActive(false)
		self.m_SellBtn:SetActive(false)
	end
	if args and args.isLink then
		self.m_UnLockBtn:SetActive(false)
		self.m_LockBtn:SetActive(false)
	end
end

function CItemTipsParEquipPage.SetInitBox(self, tItem)
	if not tItem then
		return
	end
	
	self.m_CItem = tItem
	self.m_NameLabel:SetText(tItem:GetValue("name"))
	
	if tItem:GetValue("lock") == 1 then
		self.m_LockBtn:SetActive(true)
		self.m_UnLockBtn:SetActive(false)
	else
		self.m_LockBtn:SetActive(false)
		self.m_UnLockBtn:SetActive(true)
	end
	self.m_EquipItem:SetItemData(tItem)
	local mainattr = self:GetAttrList(tItem:GetValue("attr"))
	self.m_MainGrid:Clear()
	for _, attrlist in ipairs(mainattr) do
		local box = self.m_AttrBox:Clone()
		box:SetActive(true)
		box.m_Name = box:NewUI(1, CLabel)
		box.m_Value = box:NewUI(2, CLabel)
		box.m_Name:SetText("[51E414]"..attrlist[1])
		box.m_Value:SetText("[51E414]"..attrlist[2])
		self.m_MainGrid:AddChild(box)
	end
	self.m_MainGrid:Reposition()
	
	local subattr =self:GetStoneAttr(tItem)
	self.m_SubGrid:Clear()
	if #subattr == 0 then
		subattr ={{"吞食符石可增加符石属性", ""}}
	end
	for _, attrlist in ipairs(subattr) do
		local box = self.m_AttrBox:Clone()
		box:SetActive(true)
		box.m_Name = box:NewUI(1, CLabel)
		box.m_Value = box:NewUI(2, CLabel)
		box.m_Name:SetText("[51E414]"..attrlist[1])
		box.m_Value:SetText("[51E414]"..attrlist[2])
		self.m_SubGrid:AddChild(box)
	end
	self.m_SubGrid:Reposition()
end

function CItemTipsParEquipPage.HideUI(self)
	self.m_LockBtn:SetActive(false)
	self.m_UnLockBtn:SetActive(false)
end

function CItemTipsParEquipPage.ShowSpecialItem(self, oItem)
	self.m_BodyWidget:SetActive(false)
	self.m_ReplaceBtn:SetActive(false)
	self.m_StrongBtn:SetActive(false)
	self.m_SellBtn:SetActive(false)
	self.m_UnLockBtn:SetActive(false)
	self.m_LockBtn:SetActive(false)
	self.m_SpeicailDesc:SetActive(true)
	self.m_SpeicailDesc:SetText(oItem:GetValue("description"))
	local h = self.m_SpeicailDesc:GetHeight()
	self.m_BG:SetSize(400, math.max(0, h-40) + 200)
end

function CItemTipsParEquipPage.ShowLocalItem(self, oItem)
	self.m_BodyWidget:SetActive(false)
	self.m_ReplaceBtn:SetActive(false)
	self.m_StrongBtn:SetActive(false)
	self.m_SellBtn:SetActive(false)
	self.m_UnLockBtn:SetActive(false)
	self.m_LockBtn:SetActive(false)
	self.m_SpeicailDesc:SetActive(true)
	local txt = "[624d34]◆[-][D9D256FF]主属性[-]\n%s\n[624d34]◆[-][D9D256FF]套装效果[-]\n%s"
	local typedata = data.partnerequipdata.ParSoulType[oItem:GetValue("equip_type")]
	local typelist = {}
	if typedata then
		if typedata["skill_desc"] then
			table.insert(typelist, typedata["skill_desc"])
		end
	end
	local typestr = table.concat(typelist, "\n")
	txt = string.format(txt, oItem:GetValue("introduction"), typestr)
	self.m_SpeicailDesc:SetText(txt)
	local h = self.m_SpeicailDesc:GetHeight()
	self.m_BG:SetSize(400, math.max(0, h-40) + 200)
end

function CItemTipsParEquipPage.GetAttrList(self, info)
	info = loadstring("return "..info)()
	local attrlist = {}
	if info and table.count(info) > 0 then
		for key, value in pairs(info) do
			local attrname = data.partnerequipdata.EQUIPATTR[key]["name"]
			local attrvalue = ""
			if string.endswith(key, "_ratio") or key == "critical_damage" then
				attrvalue = self:GetPrintPecent(value)
			else
				attrvalue = value
			end
			table.insert(attrlist, {attrname, attrvalue})
		end
	end
	return attrlist
end

function CItemTipsParEquipPage.GetStoneAttr(self, oItem)
	local dStoneInfo = oItem:GetValue("stone_info")
	local dAttrDict = {}
	for _, dStone in ipairs(dStoneInfo) do
		for _, dApply in ipairs(dStone.apply_info) do
			dAttrDict[dApply.key] = dAttrDict[dApply.key] or 0
			dAttrDict[dApply.key] = dAttrDict[dApply.key] + dApply.value
		end
	end
	local d = data.partnerequipdata.EQUIPATTR
	local attrlist = {}
	for key, value in pairs(dAttrDict) do
		local attrname = d[key]["name"]
		local attrvalue = nil
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			attrvalue = self:GetPrintPecent(value)
		else
			attrvalue = value
		end
		table.insert(attrlist, {attrname, attrvalue})
	end
	return attrlist
end

function CItemTipsParEquipPage.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CItemTipsParEquipPage.SetEquipList(self, equiplist)
	self.m_EquipList = equiplist
end

function CItemTipsParEquipPage.SetPartner(self, oPartner)
	self.m_CurPartner = oPartner
	if not oPartner then
		self.m_SellBtn:SetActive(false)
		self.m_StrongBtn:SetActive(false)
		self.m_ReplaceBtn:SetActive(false)
		return
	end
	self.m_ReplaceBtn:SetActive(true)

	local equipinfo = oPartner:GetCurEquipInfo()
	if self.m_EquipList then
		equipinfo = self.m_EquipList
	end
	local equippos = self.m_CItem:GetValue("pos")
	self:ShowCompareEquip()
	if equipinfo[equippos] then
		if equipinfo[equippos] == self.m_CItem.m_ID then
			self.m_ReplaceBtn:SetText("更换")
		else
			self.m_ReplaceBtn:SetText("更换")
			self:ShowCompareEquip(equipinfo[equippos])
		end
	else
		self.m_ReplaceBtn:SetText("更换")
	end
	-- self.m_StrongBtn:DelEffect("RedDot")
	-- if g_PartnerCtrl:IsFight(oPartner.m_ID) then
	-- 	if self.m_CItem and (self.m_CItem:IsPartnerEquipCanUpGrade() or
	-- 		self.m_CItem:IsPartnerEquipCanUpStar() or self.m_CItem:GetParEquipUpStoneResult()) then
	-- 		self.m_StrongBtn:AddEffect("RedDot")
	-- 	end
	-- end
end

function CItemTipsParEquipPage.ShowCompareEquip(self, itemid)
	if true then
		return
	end
	if itemid then
		local box = self.m_CompareBox
		box:SetActive(true)
		local tItem = g_ItemCtrl:GetItem(itemid)
		box.m_NameLabel:SetText(tItem:GetValue("name"))
		box.m_EquipItem:SetItemData(tItem)
		local info = tItem:GetValue("partner_equip_info")
		local mainattr = self:GetAttrList(info["main_apply"])
		local subattr = self:GetAttrList(info["sub_apply"])
		box.m_MainGrid:Clear()
		for _, attrlist in ipairs(mainattr) do
			local attrbox = self.m_AttrBox:Clone()
			attrbox:SetActive(true)
			attrbox.m_Name = attrbox:NewUI(1, CLabel)
			attrbox.m_Value = attrbox:NewUI(2, CLabel)
			attrbox.m_Name:SetText(attrlist[1])
			attrbox.m_Value:SetText(attrlist[2])
			box.m_MainGrid:AddChild(attrbox)
		end
		box.m_MainGrid:Reposition()
		
		box.m_SubGrid:Clear()
		if #subattr == 0 then
			subattr ={{"无", ""}}
		end
		for _, attrlist in ipairs(subattr) do
			local attrbox = self.m_AttrBox:Clone()
			attrbox:SetActive(true)
			attrbox.m_Name = attrbox:NewUI(1, CLabel)
			attrbox.m_Value = attrbox:NewUI(2, CLabel)
			attrbox.m_Name:SetText("[51E414]"..attrlist[1])
			attrbox.m_Value:SetText("[51E414]"..attrlist[2])
			box.m_SubGrid:AddChild(attrbox)
		end
		box.m_SubGrid:Reposition()
		
		local typedata = data.partnerequipdata.ParSoulType[oItem:GetValue("equip_type")]
		local typelist = {}
		if typedata then
			if typedata["skill_desc"] then
				table.insert(typelist, typedata["skill_desc"])
			end
		end
		local typestr = table.concat(typelist, "\n")
		box.m_TypeDescLabel:SetText(typestr)
		local h = box.m_TypeDescLabel:GetHeight()
		box.m_BG:SetSize(326, math.max(0, h-40) + 440)
		self:SetLocalPos(self.m_RightPos)
	else
		self:SetLocalPos(self.m_LeftPos)
		self.m_CompareBox:SetActive(false)
	end
end

function CItemTipsParEquipPage.PutEquip(self)
	if self.m_CallBack then
		self.m_CallBack(self.m_CItem)
	else
		if self.m_CurPartner then
			if CWearParEquipView:IsValidOpen(self.m_CItem.m_ID) then
				CWearParEquipView:ShowView(function (oView)
					oView:SetItem(self.m_CItem)
				end)
			end
		end
	end
	self.m_ParentView:OnClose()
end

function CItemTipsParEquipPage.OnStrong(self)
	local parid = nil
	if self.m_CurPartner then
		parid = self.m_CurPartner.m_ID
	end
	if self.m_CItem:GetValue("level") >= define.Partner.ParEquip.MaxLevel and self.m_CItem:GetValue("star") < define.Partner.ParEquip.MaxStar then
		CPartnerEquipImproveView:ShowView(function(oView)
			oView:SetItemData(self.m_CItem)
			oView:ShowUpStarPage()
		end)
	else
		CPartnerEquipImproveView:ShowView(function(oView)
			oView:SetItemData(self.m_CItem)
		end)
	end
	self.m_ParentView:OnClose()
end

function CItemTipsParEquipPage.OnSell(self)
	local oItem = self.m_CItem
	if oItem:GetValue("lock") == 1 then
		g_NotifyCtrl:FloatMsg("该符文已上锁，请解锁后再进行出售")
		return
	end
	if oItem:GetValue("star") > 1 or oItem:GetValue("level") > 1 then
		local windowConfirmInfo = {
			msg				= "该符文已进行强化，出售后将不会返回强化材料，是否继续出售？",
			okCallback		= callback(self, "OnC2SSell"),
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnC2SSell()
	end
end

function CItemTipsParEquipPage.OnC2SSell(self)
	netpartner.C2GSRecyclePartnerEquipList({self.m_CItem.m_ID})
	self.m_ParentView:OnClose()
end

function CItemTipsParEquipPage.OnLock(self)
	netpartner.C2GSLockPartnerItem(self.m_CItem.m_ID)
end

function CItemTipsParEquipPage.OnMoreClick(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local sText = subMenu.m_Label:GetText()
	if sText == "强化" then
		self:OnStrong()
	
	elseif sText == "合成" then
		self:OnCompose()
	end
end

function CItemTipsParEquipPage.OnClickMoreBtn(self, isOpen)	
	if g_PowerGuideCtrl.m_Sp_PartnerEquipStrong_Flag then
		local cnt = self.m_MorePopupBox.m_BtnGrid:GetCount()
		if cnt > 0 then
			for i = 1, cnt do
				local oBox = self.m_MorePopupBox.m_BtnGrid:GetChild(i)
				if oBox and oBox.m_Label and oBox.m_Label:GetText() == "强化" then
						oBox:AddEffect("Finger")
					break
				end
			end
		end
	end
end

function CItemTipsParEquipPage.Destroy(self)
	CPageBase.Destroy(self)
end

return CItemTipsParEquipPage