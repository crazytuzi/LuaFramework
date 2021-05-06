local CSecondTestPage = class("CSecondTestPage", CPageBase)

function CSecondTestPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CSecondTestPage.OnInitPage(self)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemBox = self:NewUI(2, CBox)
	self.m_FinishMark = self:NewUI(3, CBox)
	self.m_Label = self:NewUI(4, CLabel)
	self.m_TimeLabel = self:NewUI(5, CLabel)
	self.m_TipsLabel = self:NewUI(6, CLabel)
	self.m_AddPartnerbtn = self:NewUI(7, CButton)
	self.m_PartnerItem = self:NewUI(8, CBox)
	self.m_AddSpr = self:NewUI(9, CSprite)
	self.m_TipsLabel2 = self:NewUI(10, CLabel)
	self.m_FinishMark.m_Component = self.m_FinishMark:GetComponent(classtype.UISprite)
	if self.m_FinishMark.m_Component then
		self.m_FinishMark.m_Component.enabled = true
	end
	self:InitContent()
end

function CSecondTestPage.InitContent(self)
	self.m_AddPartnerbtn:AddUIEvent("click", callback(self, "OnClickPartner"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	local oData = data.welfaredata.FuliReward[100001]
	if oData.title_reward and oData.title_reward ~= 0 then
		local oItemBox = self:CreateItemBox()
		oItemBox:SetTitle(oData.title_reward)
		oItemBox:SetActive(true)
		oItemBox:AddEffect("bordermove", Vector4.New(-40, 40, -40, 40))
		self.m_ItemGrid:AddChild(oItemBox)
	end

	for i,v in ipairs(oData.reward) do
		local oItemBox = self:CreateItemBox()
		oItemBox:SetData(v)
		oItemBox:SetActive(true)
		self.m_ItemGrid:AddChild(oItemBox)
	end
	self.m_TimeLabel:SetText(oData.time_des)
	--self.m_TipsLabel:SetText(oData.condition_des)
	self.m_ItemBox:SetActive(false)
	self:Refresh()
end

function CSecondTestPage.CreateItemBox(self)
	local oItemBox = self.m_ItemBox:Clone()
	oItemBox.m_ItemSprite = oItemBox:NewUI(1, CSprite)
	oItemBox.m_DescLabel = oItemBox:NewUI(2, CLabel)
	oItemBox:AddUIEvent("click", callback(self, "OnClickBox", oItemBox))

	function oItemBox.SetData(self, oData)
		if string.find(oData.sid, "value") then
			oItemBox.m_Id, oItemBox.m_Value = g_ItemCtrl:SplitSidAndValue(oData.sid)
			oItemBox.m_ItemData = CItem.NewBySid(oItemBox.m_Id)
			oItemBox.m_ItemSprite:SpriteItemShape(oItemBox.m_ItemData:GetValue("icon"))
			printc("name: " ..oItemBox.m_ItemData:GetValue("name"))
			printc("oItemBox.m_Value: " .. oItemBox.m_Value)
			oItemBox.m_DescLabel:SetText("")
			oItemBox.m_DescLabel:SetText(string.format("%sx%s", oItemBox.m_ItemData:GetValue("name"), oItemBox.m_Value))
		elseif string.find(oData.sid, "partner") then
			oItemBox.m_Id, oItemBox.m_ParId = g_ItemCtrl:SplitSidAndValue(oData.sid)
			oItemBox.m_PartnerData = data.partnerdata.DATA[oItemBox.m_ParId]
			oItemBox.m_ItemSprite:SpriteAvatar(oItemBox.m_PartnerData.icon)
			oItemBox.m_DescLabel:SetText(string.format("%sx%s", oItemBox.m_PartnerData.name, oData.num))
			oItemBox.m_ItemSprite:SpriteItemShape("")
		else
			oItemBox.m_Id = tonumber(oData.sid)
			oItemBox.m_ItemData = CItem.NewBySid(oItemBox.m_Id)
			oItemBox.m_ItemSprite:SpriteItemShape(oItemBox.m_ItemData:GetValue("icon"))
			oItemBox.m_DescLabel:SetText(string.format("%sx%s", oItemBox.m_ItemData:GetValue("name"), oData.num))
		end
	end

	function oItemBox.SetTitle(self, title)	
		oItemBox.m_TitleId = title
		oItemBox.m_ItemSprite:SpriteItemShape(data.titledata.DATA[title].item_icon)			
		oItemBox.m_DescLabel:SetText(data.titledata.DATA[title].name)			
	end

	return oItemBox
end

function CSecondTestPage.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnChangeSecondTest or 
	oCtrl.m_EventID == define.Welfare.Event.OnBackPartnerInfo then
		self:Refresh()
	elseif oCtrl.m_EventID == define.Welfare.Event.OnSetBackPartner then
		self:SetPartner(self.m_SelectPartId, self.m_SelectStar)
	end
end

function CSecondTestPage.Refresh(self)
	self:RefreshPartner()
	self.m_Label:SetText(string.format("[25bcd7]当前等级：[8D4F12]%s级\n[25bcd7]已连续登录：[8D4F12]%s天", g_AttrCtrl.grade, g_WelfareCtrl.m_SecondTestDay))
	self.m_FinishMark:SetActive(g_WelfareCtrl.m_SecondTest == 1)
end

function CSecondTestPage.OnClickBox(self, oItemBox)
	if oItemBox.m_TitleId then
		g_WindowTipCtrl:SetTitleSimpleInfoTips(oItemBox.m_TitleId, {widget = oItemBox,})
	elseif oItemBox.m_PartnerData then
		g_WindowTipCtrl:SetWindowPartnerInfo(oItemBox.m_ParId, {widget = oItemBox, openView = self.m_ParentView})
	elseif oItemBox.m_ItemData then		
		if oItemBox.m_HousePartnerID then
			g_WindowTipCtrl:SetWindowHousePartnerInfo(self.m_HousePartnerID, {widget = oItemBox, openView = self.m_ParentView})
		
		elseif oItemBox.m_ItemData:GetValue("type") == define.Item.ItemType.EquipStone then
			g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItemBox.m_ItemData, {isLink = true, openView = self.m_ParentView})
		else
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItemBox.m_Id, {widget = oItemBox, openView = self.m_ParentView, behindStrike = false}, nil, {quality = oItemBox.m_ItemData:GetValue("quality") })
		end
	end
end

function CSecondTestPage.OnClickPartner(self)
	CWelfarePartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "SetList"))
	end)
end

function CSecondTestPage.SetList(self, partnerlist)
	local list = {}
	for k, oPartner in ipairs(partnerlist) do
		if (not g_EqualArenaCtrl:IsPartnerUsed(oPartner:GetValue("parid"))) and oPartner:IsEqualarenaPartner() then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CSecondTestPage.OnChangePartner(self, parid)
	local star = g_WelfareCtrl.m_BackList[parid] or  1		
	netfuli.C2GSSetBackPartner(parid, star)
	self.m_SelectPartId = parid
	self.m_SelectStar = star
end

function CSecondTestPage.RefreshPartner(self)	
	if g_WelfareCtrl.m_BackPid and g_WelfareCtrl.m_BackStar then
		self:SetPartner(g_WelfareCtrl.m_BackPid, g_WelfareCtrl.m_BackStar)
	else
		self.m_PartnerItem:SetActive(false)
		self.m_AddSpr:SetActive(true)
	end
end

function CSecondTestPage.SetPartner(self, parid, star)
	local d = data.partnerdata.DATA[parid]
	if not d then
		self.m_PartnerItem:SetActive(false)
		self.m_AddSpr:SetActive(true)		
		return
	end
	self.m_PartnerItem:SetActive(true)
	self.m_AddSpr:SetActive(false)
	local oBox = self.m_PartnerItem
	if not oBox.Init then
		oBox.Init = true
		oBox.m_Texture = oBox:NewUI(1, CActorTexture)
	end
	oBox.m_Texture:ChangeShape(d.icon)
end

return CSecondTestPage