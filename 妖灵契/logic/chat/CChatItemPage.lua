local CChatItemPage = class("CChatItemPage", CPageBase)

function CChatItemPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatItemPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(1, CLinkScrollBox)
	self.m_FilterBtnList = {}
	self.m_InputItemList = {}
	self:InitContent()
end

function CChatItemPage.InitContent(self)
	self:InitFactory()
	self.m_ParentView:Send("")
end


function CChatItemPage.GetItemData(self, itype)
	local amount = 14
	local itemlist = {}
	for i = 1, 6 do
		local oItem = g_ItemCtrl:GetEquipedByPos(i)
		if oItem then
			table.insert(itemlist, 1, oItem)
		end
	end
	table.extend(itemlist, g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(1, 1, false))
	table.extend(itemlist, g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(2, 1, false))
	table.extend(itemlist, g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(3, 1, false))
	table.extend(itemlist, g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(4, 1, false))
	table.extend(itemlist, g_ItemCtrl:GetAllBagItemsByShowTypeAndSort(5, 1, false))
	
	local resultlist = {}
	local data = {}
	for _, oItem in ipairs(itemlist) do
		table.insert(data, oItem.m_ID)
		if #data >= amount then
			table.insert(resultlist, data)
			data = {}
		end
	end
	if #data > 0 then
		table.insert(resultlist, data)
	end
	return resultlist
end

function CChatItemPage:InitFactory()
	local function factory(oPage, dData)
		if dData then
			if not oPage.m_Init then
				oPage.m_Grid = oPage:NewUI(1, CGrid)
				oPage.m_CloneBox = oPage:NewUI(2, CBox)
				oPage.m_CloneBox:SetActive(false)
				oPage.m_Init = true
			end
			oPage.m_Grid:Clear()
			for k, v in ipairs(dData) do
				local box = oPage.m_CloneBox:Clone()
				box.m_IconSpr = box:NewUI(1, CSprite)
				box.m_RareSpr = box:NewUI(2, CSprite)
				box.m_GreySpr = box:NewUI(3, CSprite)
				box.m_CountLabel = box:NewUI(4, CLabel)
				box.m_ClickBox = box:NewUI(5, CBox)
				box.m_ClickBox:AddUIEvent("drag", callback(self, "OnDrag"))
				box.m_ClickBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
				box.m_EquipSpr = box:NewUI(6, CSprite)
				box.m_ChipSpr = box:NewUI(7, CSprite)
				self:UpdateBox(box, v)
				box:SetActive(true)
				oPage.m_Grid:AddChild(box)
			end
			oPage.m_Grid:Reposition()
			oPage:SetActive(true)
			return oPage
		end
	end
	self.m_FactoryScroll:SetFactoryFunc(factory)
	self.m_FactoryScroll:SetDataSource(self:GetItemData())
	self.m_FactoryScroll:InitPage()
	g_LinkInfoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLinkCtrlEvent"))
end

function CChatItemPage.OnLinkCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Link.Event.UpdateIdx then
		if oCtrl.m_EventData.linktype == "item" then
			self:OnSendLink(oCtrl.m_EventData.itemid, oCtrl.m_EventData.idx)
		end
	
	elseif oCtrl.m_EventID == define.Link.Event.UpdateInputText then
		self:UpdateInputText(oCtrl.m_EventData)
	end
end

function CChatItemPage.UpdateBox(self, box, itemid)
	local oItem = g_ItemCtrl:GetItem(itemid)
	if oItem:IsPartnerChip() then
		box.m_IconSpr:SpriteAvatar(oItem:GetValue("icon"))
		box.m_IconSpr:SetSize(65, 65)
		local rare = oItem:GetValue("rare")
		box.m_ChipSpr:SetActive(true)
		box.m_RareSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
		box.m_ChipSpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))
	else
		box.m_ChipSpr:SetActive(false)
		box.m_IconSpr:SetSize(80, 80)
		box.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
		box.m_RareSpr:SetSpriteName("pic_tongyong_diwen_zuixin")
	end
	if oItem:GetValue("amount") > 1 then
		box.m_CountLabel:SetText(tostring(oItem:GetValue("amount")))
	else
		box.m_CountLabel:SetText("")
	end
	if table.index(self.m_InputItemList, itemid) then
		box.m_GreySpr:SetActive(true)
	else
		box.m_GreySpr:SetActive(false)
	end
	box.m_ID = itemid
	box.m_EquipSpr:SetActive(oItem:IsEquiped())
	box.m_ClickBox:AddUIEvent("click", callback(self, "GetSendLink", itemid))
end

function CChatItemPage.UpdateInputText(self, sMsg)
	local dLinks = LinkTools.FindLinkList(sMsg, "ItemLink")
	local lItem = {}
	for _, oLink in ipairs(dLinks) do
		table.insert(lItem, oLink.iLinkid)
	end
	self.m_InputItemList = lItem
	self:RefreshContent(lItem)
end

function CChatItemPage.RefreshContent(self, lItem)
	local function updatefunc(oPage)
		for _, box in ipairs(oPage.m_Grid:GetChildList()) do
			if table.index(lItem, box.m_ID) then
				box.m_GreySpr:SetActive(true)
			else
				box.m_GreySpr:SetActive(false)
			end
		end
	end
	self.m_FactoryScroll:RefreshPageContent(updatefunc)
end

function CChatItemPage.OnDrag(self, obj, deltax)
	self.m_FactoryScroll:OnDrag(obj, deltax)
end

function CChatItemPage.OnDragEnd(self, obj)
	self.m_FactoryScroll:OnDragEnd(obj)
end


function CChatItemPage.GetSendLink(self, itemid)
	g_LinkInfoCtrl:GetItemLinkIdx(itemid)
end

function CChatItemPage.OnSendLink(self, itemid, idx)
	local oItem = g_ItemCtrl:GetItem(itemid)
	local iShape = oItem:GetEquipStoneSid()
	local iAmount = oItem:GetValue("amount")
	local linkstr = LinkTools.GenerateItemLink(idx, itemid, iShape, iAmount)
	self.m_ParentView:Send(linkstr)
end
return CChatItemPage