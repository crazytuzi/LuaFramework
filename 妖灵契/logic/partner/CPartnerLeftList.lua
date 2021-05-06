local CPartnerLeftList = class("CPartnerLeftList", CBox)

function CPartnerLeftList.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_PartnerBox = self:NewUI(3, CBox)
	self.m_FilterBox = self:NewUI(4, CBox)
	self.m_ChipBox = self:NewUI(5, CBox)
	self.m_ScrollView2 = self:NewUI(6, CScrollView)
	self.m_WrapContent2 = self:NewUI(7, CWrapContent)
	self.m_TouchObj = self:NewUI(8, CObject)
	self.m_TouchObj2 = self:NewUI(9, CObject)
	self.m_WrapBox = self:NewUI(10, CBox)
	self.m_PartnerBox:SetActive(false)
	self.m_ChipBox:SetActive(false)
	self.m_WrapBox:SetActive(false)

	g_GuideCtrl:AddGuideUI("partner_left_list_302_partner")
	g_GuideCtrl:AddGuideUI("partner_left_list_501_partner")
	g_GuideCtrl:AddGuideUI("partner_left_list_502_partner")
	self:InitContent()
end

function CPartnerLeftList.InitContent(self)
	self:InitWrapContent()
	self:InitChipWrap()
	self:InitFilter()
	self.m_ScrollView2:SetActive(false)
	self.m_TouchObj2:SetActive(false)
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	--self:RefershPartners()
end

function CPartnerLeftList.InitWrapContent(self)
	self.m_WrapContent:SetCloneChild(self.m_WrapBox, callback(self, "ClonePartnerChild"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "RefreshPartnerChild"))
end

function CPartnerLeftList.InitChipWrap(self)
	self.m_WrapContent2:SetCloneChild(self.m_ChipBox, callback(self, "CloneChipChild"))
	self.m_WrapContent2:SetRefreshFunc(callback(self, "RefreshChipChild"))
end

function CPartnerLeftList.InitFilter(self)
	self.m_FilterLabel = self.m_FilterBox:NewUI(1, CLabel)
	self.m_FilterGrid = self.m_FilterBox:NewUI(2, CGrid)
	self.m_FilterBtn = self.m_FilterBox:NewUI(3, CButton)
	self.m_FilterTweenObj = self.m_FilterBox:NewUI(4, CSprite)
	
	self.m_FilterPart = self.m_FilterBox:NewUI(6, CObject)
	self.m_FilterBtn:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOut"))
	self.m_FilterBox:AddUIEvent("click", callback(self, "OnShowFilter"))
	self.m_CurFilterKey = 0
	self.m_FilterLabel:SetText("全部")
	self:OnHideFilter()
end

function CPartnerLeftList.UpdateView(self)
	if self.m_ShowUpdate then
		self:UpdatePartnerList()
	end
	self.m_ShowUpdate = false
end

function CPartnerLeftList.OnPartnerCtrlEvent(self, oCtrl)
	if self.m_Type == "compose" then
		return
	end

	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Partner.Event.UpdateRedPoint then
		if type(oCtrl.m_EventData) == "table" then
			for _, iParID in ipairs(oCtrl.m_EventData) do
				self:UpdatePartner(iParID)
			end
		else
			self:UpdatePartner(oCtrl.m_EventData)
		end

	else
		if not Utils.IsNil(self.m_ParentView) and not self.m_ParentView:GetActive() then
			self.m_ShowUpdate = true
		else
			self.m_ShowUpdate = false
		end
		if oCtrl.m_EventID == define.Partner.Event.FightChange then
			self:UpdatePartnerList()
		
		elseif oCtrl.m_EventID == define.Partner.Event.DelPartner then
			self:UpdatePartnerList()

		elseif oCtrl.m_EventID == define.Partner.Event.PartnerAdd then
			self:UpdatePartnerList()
		end
	end
end

function CPartnerLeftList.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateChip(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Item.Event.DelItem then
		self:DelChip(oCtrl.m_EventData)

	elseif oCtrl.m_EventID == define.Item.Event.AddItem then
		self:UpdateChip(oCtrl.m_EventData)
	end
end

function CPartnerLeftList.ClonePartnerChild(self, obj)
	--printc("obj", 1)
	obj.m_IconTexture = obj:NewUI(1, CTexture)
	obj.m_AwakeSpr = obj:NewUI(2, CSprite)
	obj.m_LockSpr = obj:NewUI(3, CSprite)
	obj.m_SelSpr = obj:NewUI(4, CSprite)
	obj.m_GradeLabel = obj:NewUI(5, CLabel)
	obj.m_StarList = {}
	for i = 1, 5 do
		obj.m_StarList[i] = obj:NewUI(5+i, CSprite)
	end
	obj.m_BgSpr1 = obj:NewUI(11, CSprite)
	obj.m_BgSpr2 = obj:NewUI(12, CSprite)
	obj.m_FightObj = obj:NewUI(13, CObject)
	obj.m_PartnerPart = obj:NewUI(14, CObject)
	obj.m_ChipPart = obj:NewUI(15, CObject)
	obj.m_ChipSlider = obj:NewUI(16, CSlider)
	obj.m_ChipComposeSpr = obj:NewUI(17, CSprite)
	obj.m_RedSpr = obj:NewUI(18, CObject)
	return obj
end

function CPartnerLeftList.RefreshPartnerChild(self, obj, oPartner)
	if oPartner then
		if oPartner.classname == "CPartner" then
			self:UpdatePartnerBox(obj, oPartner)
		else
			self:UpdateChipBox(obj, oPartner)
		end
	else
		obj.m_ID = nil
		obj.m_ChipType = nil
		obj.m_ItemID = nil
		obj:SetActive(false)
	end
end

function CPartnerLeftList.UpdatePartnerBox(self, oBox, oPartner)
	oBox:SetActive(true)
	oBox.m_PartnerPart:SetActive(true)
	oBox.m_ChipPart:SetActive(false)
	oBox.m_IconTexture:LoadListPhoto(oPartner:GetIcon())
	oBox.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
	oBox.m_LockSpr:SetActive(oPartner:IsLock())
	oBox.m_SelSpr:SetActive(self.m_CurID == oPartner.m_ID)
	oBox.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
	local iRare = oPartner:GetValue("rare")
	iRare = iRare + 2
	oBox.m_BgSpr1:SetSpriteName("pic_hblist_kuang1_"..tostring(iRare))
	oBox.m_BgSpr2:SetSpriteName("pic_hblist_kuang2_"..tostring(iRare))
	local iStar = oPartner:GetValue("star")
	for i = 1, 5 do
		if iStar >= i then
			oBox.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
		else
			oBox.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	local bFight = g_PartnerCtrl:IsFight(oPartner.m_ID)
	if bFight then
		if oPartner:IsHasUpStarRedPoint() or oPartner:CanParEquipUpStone() or 
			oPartner:CanParEquipUpStar() or oPartner:CanParEquipUpGrade() or
			oPartner:CanWearParSoul() or oPartner:CanWearParEquip() then
			oBox.m_RedSpr:SetActive(true)
		else
			oBox.m_RedSpr:SetActive(false)
		end
	else
		oBox.m_RedSpr:SetActive(oPartner:IsHasUpStarRedPoint())
	end
	oBox.m_ID = oPartner.m_ID
	oBox.m_ChipType = nil
	oBox.m_ItemID = nil
	oBox:AddUIEvent("click", callback(self, "OnClickPartner", oBox.m_ID, oBox))
	oBox.m_FightObj:SetActive(bFight)
	self:AddChildDrag(oBox)
	if oPartner:GetValue("partner_type") == 501 then
		local temp = g_GuideCtrl:GetGuideUI("partner_left_list_501_partner")
		if not temp or temp ~= oBox then
			g_GuideCtrl:AddGuideUI("partner_left_list_501_partner", oBox)
		end
	end
	if oPartner:GetValue("partner_type") == 502 then
		local temp = g_GuideCtrl:GetGuideUI("partner_left_list_502_partner")
		if not temp or temp ~= oBox then
			g_GuideCtrl:AddGuideUI("partner_left_list_502_partner", oBox)
		end
	end
	oBox.m_GuideTips = nil
	if oPartner:GetValue("partner_type") == 302 then
		local temp = g_GuideCtrl:GetGuideUI("partner_left_list_302_partner")
		if not temp or temp ~= oBox then
			g_GuideCtrl:AddGuideUI("partner_left_list_302_partner", oBox)
			oBox.m_GuideTips = "partner_left_list_302_partner"
			local guide_ui = {"partner_left_list_302_partner"}
			g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
		end
	end
end

function CPartnerLeftList.UpdateChipBox(self, oBox, oItem)
	oBox:SetActive(true)
	oBox.m_PartnerPart:SetActive(false)
	oBox.m_ChipPart:SetActive(true)
	oBox.m_ID = nil
	oBox.m_ChipType = oItem:GetValue("sid")
	oBox.m_ItemID = oItem.m_ID
	oBox.m_IconTexture:LoadListPhoto(oItem:GetValue("icon"))

	local iRare = oItem:GetValue("rare")
	oBox.m_BgSpr1:SetSpriteName("pic_hblist_kuang1_"..tostring(iRare+2))
	oBox.m_BgSpr2:SetSpriteName("pic_hblist_kuang2_"..tostring(iRare+2))
	local amount = oItem:GetValue("amount")
	local compose_amount = oItem:GetValue("compose_amount")
	oBox.m_ChipSlider:SetValue(amount/compose_amount)
	oBox.m_ChipSlider:SetSliderText(string.format("%d/%d", amount, compose_amount))
	oBox.m_ChipComposeSpr:SetActive(amount >= compose_amount)
	oBox.m_SelSpr:SetActive(self.m_CurID == oBox.m_ChipType)
	oBox:AddUIEvent("click", callback(self, "OnClickChip", oItem))
	self:AddChildDrag(oBox)
end

function CPartnerLeftList.CloneChipChild(self, obj)
	obj.m_IconTexture = obj:NewUI(1, CTexture)
	obj.m_BgSpr1 = obj:NewUI(2, CSprite)
	obj.m_BgSpr2 = obj:NewUI(3, CSprite)
	obj.m_SelSpr = obj:NewUI(4, CSprite)
	obj.m_Slider = obj:NewUI(5, CSlider)
	obj.m_ProgressLabel = obj:NewUI(6, CLabel)
	obj.m_ComposeSpr = obj:NewUI(7, CSprite)
	return obj
end

function CPartnerLeftList.RefreshChipChild(self, obj, oItem)
	if oItem then
		obj:SetActive(true)
		obj.m_ChipType = oItem:GetValue("sid")
		obj.m_ItemID = oItem.m_ID
		obj.m_IconTexture:LoadListPhoto(oItem:GetValue("icon"))

		local iRare = oItem:GetValue("rare")
		obj.m_BgSpr1:SetSpriteName("pic_hblist_kuang1_"..tostring(iRare+2))
		obj.m_BgSpr2:SetSpriteName("pic_hblist_kuang2_"..tostring(iRare+2))
		local amount = oItem:GetValue("amount")
		local compose_amount = oItem:GetValue("compose_amount")
		obj.m_Slider:SetValue(amount/compose_amount)
		obj.m_ProgressLabel:SetText(string.format("%d/%d", amount, compose_amount))
		obj.m_ComposeSpr:SetActive(amount >= compose_amount)
		obj.m_SelSpr:SetActive(self.m_CurID == obj.m_ChipType)
		obj:AddUIEvent("click", callback(self, "OnClickChip", oItem))
		self:AddChildDrag(obj)
	else
		obj.m_ID = nil
		obj.m_ChipType = nil
		obj.m_ItemID = nil
		obj:SetActive(false)
	end
end

function CPartnerLeftList.SetType(self, stype)
	local oldtype = self.m_Type
	self.m_Type = stype
	self.m_ScrollView2:SetActive(stype == "compose")
	self.m_ScrollView:SetActive(stype ~= "compose")
	self.m_TouchObj2:SetActive(stype == "compose")
	self.m_TouchObj:SetActive(stype ~= "compose")

	if stype == "compose" then
		self:RefershChips()
	else
		if not oldtype or oldtype == "compose" then
			self:RefershPartners()
		
		elseif stype == "upstar" or stype == "upgrade" then
			self:RefershPartners()
		
		elseif (oldtype == "lineup" and stype ~= "lineup") or 
			(stype == "lineup" and oldtype ~= "lineup")  then
			self:RefershPartners()
		end
	end
end

function CPartnerLeftList.UpdatePartnerList(self)
	self:RefershPartners()
	local curPartnerID = self.m_ParentView:GetCurPartnerID()
	if not curPartnerID and #list > 0 then
		self:OnClickPartner(list[1].m_ID)
	elseif curPartnerID then
		local oPartner = g_PartnerCtrl:GetPartner(curPartnerID)
		if not oPartner then
			local mainPartner = g_PartnerCtrl:GetMainFightPartner()
			if mainPartner then
				self:OnClickPartner(mainPartner.m_ID)
			end
		end
	end
end

function CPartnerLeftList.RefershPartners(self)
	local list = {}
	if self.m_Type == "lineup" then
		local dArgs = self.m_ParentView.m_LineupPage:GetDragArgs()
		self:RegisterDrag(dArgs)
		list = g_PartnerCtrl:GetPartnerByRare(0, true)
	else
	 	list = g_PartnerCtrl:GetPartnerByRare(0)
	end
	list = self:SortList2(list)

	local dChipList = {}
	if self.m_CurFilterKey == 0 then
		local dAllChipList = g_PartnerCtrl:GetChipByRare(0)
		for _, oItem in ipairs(dAllChipList) do
			if not g_PartnerCtrl:IsGetPartner(oItem:GetValue("partner_type")) then
				table.insert(dChipList, oItem)
			end
		end
		table.sort(dChipList, callback(self, "ChipSortFunc"))
	end
	self.m_DataList = table.extend(list, dChipList)

	if not self.m_ParentView:GetCurPartnerID() and #list > 0 then
		self:OnClickPartner(list[1].m_ID)
	end

	self.m_WrapContent:SetData(list, true)
	self.m_ScrollView:ResetPosition()
end

function CPartnerLeftList.SortList2(self, list)
	local sortList = {}
	for _, oPartner in ipairs(list) do
		local t = {
			oPartner,
			-(g_PartnerCtrl:GetFightPos(oPartner:GetValue("parid")) or 9999),
			oPartner:IsHasUpStarRedPoint() and 1 or 0,
			oPartner:GetValue("power"), 
			oPartner:GetValue("rare"), 
			oPartner:GetValue("partner_type"), 
			oPartner.m_ID, 
		}
		table.insert(sortList, t)
	end
	if g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBPY_MainMenu") and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HPPY_PartnerMain") then
		for _, oPartner in ipairs(sortList) do
			if oPartner[6] == 501 then
				oPartner[2] = -4
			end
		end
	end
	if g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_PartnerMain") and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWCD_One_PartnerMain") then
		for _, oPartner in ipairs(sortList) do
			if oPartner[6] == 502 then
				oPartner[2] = -2
			end
		end
	end	
	local function cmp(listA, listB)
		for i = 2, 7 do
			if listA[i] ~= listB[i] then
				return listA[i] > listB[i]
			end
		end
		return false
	end
	table.sort(sortList, cmp)
	list = {}
	for _, t in ipairs(sortList) do
		table.insert(list, t[1])
	end
	return list
end

function CPartnerLeftList.ChipSortFunc(self, chipA, chipB)
	local composeA = (chipA:GetValue("amount") / chipA:GetValue("compose_amount"))
	local composeB = (chipB:GetValue("amount") / chipB:GetValue("compose_amount"))
	if composeA ~= composeB then
		return composeA > composeB
	end

	if chipA:GetValue("rare") ~= chipB:GetValue("rare") then
		return chipA:GetValue("rare") > chipB:GetValue("rare")
	end
	if chipA:GetValue("partner_type") ~= chipB:GetValue("partner_type") then
		return chipA:GetValue("partner_type") < chipB:GetValue("partner_type")
	end

	if chipA:GetValue("amount") ~= chipB:GetValue("amount") then
		return chipA:GetValue("amount") > chipB:GetValue("amount")
	end
	
	if chipA:GetValue("create_time") ~= chipB:GetValue("create_time") then
		return chipA:GetValue("create_time") < chipB:GetValue("create_time")
	end
	return false
end

function CPartnerLeftList.RefershChips(self)
	local list = g_PartnerCtrl:GetChipByRare(0)
	local resultList = {}
	for _, oItem in ipairs(list) do
		if not g_PartnerCtrl:IsGetPartner(oItem:GetValue("partner_type")) then
			table.insert(resultList, oItem)
		end
	end
	if not next(resultList) then
		g_NotifyCtrl:FloatMsg("你拥有了所有伙伴")
		self:OnClickFilter(0)
		self:OnTouchOut()
		return
	end
	table.sort(resultList, callback(self, "ChipSortFunc"))
	self.m_DataList = resultList
	self.m_WrapContent2:SetData(resultList, true)
	self.m_ScrollView2:ResetPosition()
	self.m_ParentView:OnChangePartner(resultList[1]:GetValue("sid"))
end

function CPartnerLeftList.SetParentView(self, parent)
	self.m_ParentView = parent
end

function CPartnerLeftList.GetDataList(self)
	return self.m_DataList or {}
end


function CPartnerLeftList.UpdatePartner(self, iParID)
	for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
		if oChild.m_ID == iParID then
			local oPartner = g_PartnerCtrl:GetPartner(iParID)
			self:RefreshPartnerChild(oChild, oPartner)
			break
		end
	end
end

function CPartnerLeftList.OnSelectPartner(self, iParID)
	self.m_CurID = iParID
	for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
		if oChild:GetActive() and oChild.m_ID == iParID then
			oChild.m_SelSpr:SetActive(true)
		else
			oChild.m_SelSpr:SetActive(false)
		end
	end
end

function CPartnerLeftList.UpdateChip(self, oItem)
	-- if self.m_Type ~= "compose" then
	-- 	return
	-- end
	local chiptype = oItem:GetValue("sid")
	if self.m_ScrollView2:GetActive() then
		for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
			if oChild.m_ChipType == chiptype then
				self:RefreshChipChild(oChild, oItem)
				break
			end
		end
	else
		for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
			if oChild.m_ChipType == chiptype then
				self:UpdateChipBox(oChild, oItem)
				break
			end
		end
	end
end

function CPartnerLeftList.DelChip(self, iItemID)
	if self.m_Type ~= "compose" then
		return
	end
	
	for _, oChild in ipairs(self.m_WrapContent2:GetChildList()) do
		if oChild.m_ItemID == iItemID then
			local oItem = g_PartnerCtrl:GetSingleChipInfo(oChild.m_ChipType)
			self:RefreshChipChild(oChild, oItem)
			break
		end
	end
end

function CPartnerLeftList.OnSelectChip(self, iChipType)
	for _, child in ipairs(self.m_WrapContent2:GetChildList()) do
		if child.m_ChipType == iChipType then
			child.m_SelSpr:SetActive(true)
		else
			child.m_SelSpr:SetActive(false)
		end
	end
	self.m_CurID = iChipType
end

function CPartnerLeftList.OnShowFilter(self)
	if self.m_FilterPart:GetActive() then
		self:OnHideFilter()
	else
		self.m_FilterPart:SetActive(true)
		local filterList = {0, 1, 2}
		local key2text = {"全部", "已拥有", "未拥有"}
		local idx = 1
		self.m_FilterGrid:Clear()
		for i, key in ipairs(filterList) do
			if self.m_CurFilterKey ~= key then
				local btn = self.m_FilterBtn:Clone()
				btn:SetActive(true)
				btn:SetText(key2text[key+1])
				btn:AddUIEvent("click", callback(self, "OnClickFilter", key))
				self.m_FilterGrid:AddChild(btn)
			end
		end
		self.m_FilterGrid:Reposition()
	end
end

function CPartnerLeftList.OnTouchOut(self)
	if not self.m_FilterTweenObj.m_Tween then
		self.m_FilterTweenObj.m_Tween = self.m_FilterTweenObj:GetComponent(classtype.UITweener)
	end
	self.m_FilterTweenObj.m_Tween:PlayReverse()
	self:OnHideFilter()
end

function CPartnerLeftList.OnHideFilter(self)
	self.m_FilterPart:SetActive(false)
end

function CPartnerLeftList.OnClickFilter(self, key)
	local key2text = {"全部", "已拥有", "未拥有"}
	self.m_CurFilterKey = key
	self.m_FilterLabel:SetText(key2text[key+1])
	self:OnHideFilter()
	if key < 2 then
		self:RefershPartners()
		self.m_ParentView:ShowMainPage()
	else
		self.m_ParentView:ShowComposePage()
	end
end

function CPartnerLeftList.OnClickChip(self, oItem)
	if self.m_ParentView then
		self.m_ParentView:ChangeComposePage(oItem:GetValue("sid"))
	end
	for _, child in ipairs(self.m_WrapContent:GetChildList()) do
		if child.m_ChipType == oItem:GetValue("sid") then
			child.m_SelSpr:SetActive(true)
		else
			child.m_SelSpr:SetActive(false)
		end
	end
	self.m_CurID = oItem:GetValue("sid")
end

function CPartnerLeftList.OnClickPartner(self, iParID, oBox)
	if self.m_ParentView then
		if self.m_ParentView.m_CurPage == self.m_ParentView.m_PartnerComposePage then
			self.m_ParentView:SwitchMainPage(iParID)
		else
			self.m_ParentView:OnChangePartner(iParID)
		end
	end
	for _, child in ipairs(self.m_WrapContent:GetChildList()) do
		if child.m_ID == iParID then
			child.m_SelSpr:SetActive(true)
		else
			child.m_SelSpr:SetActive(false)
		end
	end
	self.m_CurID = iParID
	if oBox and oBox.m_GuideTips then
		g_GuideCtrl:ReqTipsGuideFinish(oBox.m_GuideTips)
	end
end

function CPartnerLeftList.RegisterDrag(self, dArgs)
	self.m_DragArgs = dArgs
	local list =  self.m_WrapContent:GetChildList()
	for k, oChild in ipairs(self.m_WrapContent:GetChildList()) do
		g_UITouchCtrl:AddDragObject(oChild, dArgs)
	end
end

function CPartnerLeftList.AddChildDrag(self, oChild)
	if self.m_DragArgs then
		g_UITouchCtrl:AddDragObject(oChild, self.m_DragArgs)
	end
end

function CPartnerLeftList.UnRegisterDrag(self)
	self.m_DragArgs = nil
	local list = self.m_WrapContent:GetChildList()
	for k, oChild in ipairs(list) do
		g_UITouchCtrl:DelDragObject(oChild)
	end
end

return CPartnerLeftList