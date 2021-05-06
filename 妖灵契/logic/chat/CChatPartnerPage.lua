local CChatPartnerPage = class("CChatPartnerPage", CPageBase)

function CChatPartnerPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatPartnerPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(2, CLinkScrollBox)
	self.m_InputPartner = {}
	
	self:InitContent()
end

function CChatPartnerPage:InitContent()
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
				box.m_NameLabel = box:NewUI(2, CLabel)
				box.m_ClickBox = box:NewUI(3, CBox)
				box.m_ClickBox:AddUIEvent("drag", callback(self, "OnDrag"))
				box.m_ClickBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
				box.m_GradeLabel = box:NewUI(4, CLabel)
				box.m_PowerLabel = box:NewUI(5, CLabel)
				box.m_FightSpr = box:NewUI(6, CSprite)
				box.m_StarGrid = box:NewUI(7, CGrid)
				box.m_Star = box:NewUI(8, CSprite)
				box.m_RareSpr = box:NewUI(9, CSprite)
				box.m_AwakeLabel = box:NewUI(10, CLabel)
				box.m_GreySpr = box:NewUI(11, CSprite)
				box.m_Star:SetActive(false)
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
	self.m_FactoryScroll:SetDataSource(self:GetAllData())
	self.m_FactoryScroll:InitPage()
	g_LinkInfoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLinkCtrlEvent"))
	self.m_ParentView:Send("")
end

function CChatPartnerPage.OnLinkCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Link.Event.UpdateIdx then
		if oCtrl.m_EventData.linktype == "partner" then
			self:OnSendLink(oCtrl.m_EventData.parid, oCtrl.m_EventData.idx)
		end
	
	elseif oCtrl.m_EventID == define.Link.Event.UpdateInputText then
		self:UpdateInputText(oCtrl.m_EventData)
	end
end

function CChatPartnerPage.UpdateBox(self, box, parid)
	box.m_NameLabel:SetText(tostring(parid))
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	if not oPartner then
		return
	end
	
	box.m_NameLabel:SetText(oPartner:GetValue("name"))
	box.m_GradeLabel:SetText("等级："..tostring(oPartner:GetValue("grade")))
	box.m_PowerLabel:SetText("战力："..tostring(oPartner:GetValue("power")))
	local iPos = g_PartnerCtrl:GetFightPos(oPartner.m_ID)
	box.m_IconSpr:SpriteAvatar(oPartner:GetIcon())
	g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, oPartner:GetValue("rare"))
	box.m_FightSpr:SetActive(true)
	if iPos == 1 then
		box.m_FightSpr:SetSpriteName("pic_liaotian_zhuzhan")
	elseif iPos then
		box.m_FightSpr:SetSpriteName("pic_liaotian_fuzhan")
	else
		box.m_FightSpr:SetActive(false)
	end
	box.m_AwakeLabel:SetActive(oPartner:GetValue("awake") == 1)
	box.m_StarGrid:Clear()
	for i = 1, 5 do
		local spr = box.m_Star:Clone()
		spr:SetActive(true)
		if oPartner:GetValue("star") >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
		box.m_StarGrid:AddChild(spr)
	end
	box.m_ID = parid
	if table.index(self.m_InputPartner, parid) then
		box.m_GreySpr:SetActive(true)
	else
		box.m_GreySpr:SetActive(false)
	end
	box.m_ClickBox:AddUIEvent("click", callback(self, "GetSendLink", parid))
end

function CChatPartnerPage.GetAllData(self)
	local partnerList = g_PartnerCtrl:GetPartnerByRare(0, true)
	local sortList = {}
	for _, oPartner in ipairs(partnerList) do
		local t = {
			oPartner,
			g_PartnerCtrl:GetFightPos(oPartner:GetValue("parid")) or 9999,
			oPartner:GetValue("power"), 
			oPartner:GetValue("rare"), 
			oPartner:GetValue("partner_type"), 
			oPartner:GetValue("parid"), 
		}
		table.insert(sortList, t)
	end
	local function cmp(listA, listB)
		if listA[2] ~= listB[2] then
			return listA[2] < listB[2]
		end
		if listA[3] and listB[3] and listA[3] ~= listB[3] then
			return listB[3] < listA[3]
		end
		if listA[4] and listB[4] and listA[4] ~= listB[4] then
			return listA[4] > listB[4]
		end
		if listA[5] and listB[5] and listA[5] ~= listB[5] then
			return listA[5] < listB[5]
		end
		return listA[6] > listB[6]
	end
	table.sort(sortList, cmp)
	
	local list = {}
	local d = {}
	for _, v in ipairs(sortList) do
		table.insert(d, v[1].m_ID)
		if #d > 3 then
			table.insert(list, d)
			d = {}
		end
	end
	if #d > 0 then
		table.insert(list, d)
	end
	return list
end

function CChatPartnerPage.UpdateInputText(self, sMsg)
	local dLinks = LinkTools.FindLinkList(sMsg, "SummonLink")
	local lPartner = {}
	for _, oLink in ipairs(dLinks) do
		table.insert(lPartner, oLink.iLinkid)
	end
	self.m_InputPartner = lPartner
	self:RefreshContent(lPartner)
end

function CChatPartnerPage.RefreshContent(self, lPartner)
	local function updatefunc(oPage)
		for _, box in ipairs(oPage.m_Grid:GetChildList()) do
			if table.index(lPartner, box.m_ID) then
				box.m_GreySpr:SetActive(true)
			else
				box.m_GreySpr:SetActive(false)
			end
		end
	end
	self.m_FactoryScroll:RefreshPageContent(updatefunc)
end

function CChatPartnerPage.GetSendLink(self, parid)
	if table.index(self.m_InputPartner, parid) then
		self:OnSendLink(parid, 0)
	else
		g_LinkInfoCtrl:GetPartnerLinkIdx(parid)
	end
end

function CChatPartnerPage.OnSendLink(self, parid, idx)
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	local linkstr = LinkTools.GenerateSummonLink(idx, parid, oPartner:GetValue("partner_type"))
	self.m_ParentView:Send(linkstr)
end

function CChatPartnerPage.OnDrag(self, obj, deltax)
	self.m_FactoryScroll:OnDrag(obj, deltax)
end

function CChatPartnerPage.OnDragEnd(self, obj)
	self.m_FactoryScroll:OnDragEnd(obj)
end

return CChatPartnerPage