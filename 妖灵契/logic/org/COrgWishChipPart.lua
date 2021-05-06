local COrgWishChipPart = class("COrgWishChipPart", CBox)

function COrgWishChipPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self:InitContent()
end

function COrgWishChipPart.InitContent(self)
	self.m_ChipBox = self:NewUI(1, CBox)
	self.m_ChipGrid = self:NewUI(2, CGrid)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_ScrollView = self:NewUI(5, CScrollView)

	self.m_ChipBoxArr = {}
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_ChipBox:SetActive(false)
	self:SetActive(false)
	local wishList = {}
	for k,v in pairs(data.orgdata.Wish) do
		table.insert(wishList, v)
	end
	local function sortFunc(v1, v2)
		return v1.id < v2.id
	end
	table.sort(wishList, sortFunc)

	local text1 = ""
	local text2 = ""
	for i,v in ipairs(wishList) do
		if v.desc ~= "N" then
			if i ~= #wishList then
				text1 = "/" .. v.desc .. text1
				text2 = "/" .. v.amount .. text2
			else
				text1 = v.desc .. text1
				text2 = v.amount .. text2
			end
		end
	end
	self.m_TipsLabel:SetText(string.format("[6e4f40]请选择需要许愿的伙伴碎片\n[e66f5c]%s[-]每天可以需求[e66f5c]%s[-]个碎片", text1, text2))
end

function COrgWishChipPart.SetData(self)
	local oData = self:GetChipList()
	local count = 0
	for i,v in ipairs(oData) do
		count = count + 1
		if self.m_ChipBoxArr[count] == nil then
			self.m_ChipBoxArr[count] = self:CreateChipBox()
			self.m_ChipGrid:AddChild(self.m_ChipBoxArr[count])
		end
		self.m_ChipBoxArr[count]:SetData(v, data.partnerdata.CHIP[v])
		self.m_ChipBoxArr[count]:SetActive(true)
	end
	count = count + 1
	for i = count, #self.m_ChipBoxArr do
		self.m_ChipBoxArr[count]:SetActive(false)
	end
	self:SetActive(true)
	self.m_ChipGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function COrgWishChipPart.GetChipList(self)
	local chipList = {}
	local partnerDic = g_PartnerCtrl:GetPartners()
	self.m_ChipAmountDic = {}
	self.m_Star = {}
	for k,oPartner in pairs(partnerDic) do
		local iType = oPartner:GetValue("partner_type")
		self.m_ChipAmountDic[iType] = 0
		self.m_Star[iType] = oPartner:GetValue("star")
	end
	-- table.print(self.m_ChipAmountDic, "before")
	local bagChipList = g_ItemCtrl:GetPartnerChip()
	local parType = nil
	for k,v in pairs(bagChipList) do
		parType = v:GetValue("partner_type")
		self.m_ChipAmountDic[parType] = self.m_ChipAmountDic[parType] or 0
		self.m_ChipAmountDic[parType] = self.m_ChipAmountDic[parType] + v:GetValue("amount")
	end
	-- table.print(self.m_ChipAmountDic, "after")
	for k,v in pairs(data.partnerdata.CHIP) do
		if self.m_ChipAmountDic[v.partner_type] and v.can_wish == 1 then
			table.insert(chipList, v)
		end
	end

	table.sort(chipList, function (v1, v2)
		if v1.rare ~= v2.rare then
			return v1.rare > v2.rare
		else
			return v1.partner_type > v2.partner_type
		end
	end)
	return chipList
end

function COrgWishChipPart.CreateChipBox(self)
	local oChipBox = self.m_ChipBox:Clone()
	oChipBox.m_ChipProgressSlider = oChipBox:NewUI(1, CSlider)
	oChipBox.m_ProgressLabel = oChipBox:NewUI(2, CLabel)
	oChipBox.m_ChipQualityBgSprite = oChipBox:NewUI(3, CSprite)
	oChipBox.m_ChipSprite = oChipBox:NewUI(4, CSprite)
	oChipBox.m_ChipQualitySprite = oChipBox:NewUI(5, CSprite)
	oChipBox.m_FullStarMark = oChipBox:NewUI(6, CBox)
	oChipBox.m_ProgressPart = oChipBox:NewUI(7, CBox)
	oChipBox.m_ChipQualityBgSprite:AddUIEvent("click", callback(self, "OnClickWish", oChipBox))
	oChipBox.m_ParentView = self
	function oChipBox.SetData(self, oData)
		self.m_Data = oData
		local iStart = self.m_ParentView.m_Star[oData.partner_type]
		local cost = oData.compose_amount
		if iStart and iStart >=5 then
			oChipBox.m_FullStarMark:SetActive(true)
			oChipBox.m_ProgressPart:SetActive(false)
		else
			oChipBox.m_FullStarMark:SetActive(false)
			oChipBox.m_ProgressPart:SetActive(true)
		end
		if iStart then
			cost = data.partnerdata.UPSTAR[iStart].cost_amount
		end
		
		local amount = self.m_ParentView.m_ChipAmountDic[oData.partner_type]
		local rare = oData.rare
		if cost > amount then
			oChipBox.m_ChipProgressSlider:SetValue(amount / cost)
		else
			oChipBox.m_ChipProgressSlider:SetValue(1)
		end
		oChipBox.m_ProgressLabel:SetText(string.format("%s/%s", amount, cost))
		oChipBox.m_ChipQualityBgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
		oChipBox.m_ChipSprite:SetSpriteName(tostring(oData.icon))
		oChipBox.m_ChipQualitySprite:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))
	end

	return oChipBox
end

function COrgWishChipPart.OnClickWish(self, oChipBox)
	-- printc("OnClickWish: " .. oChipBox.m_Data:GetValue("sid"))
	local windowConfirmInfo = {
		msg = string.format("[ffffff]确认许愿[ff0000]%sx%s[ffffff]吗？", oChipBox.m_Data.name, g_PartnerCtrl:GetWishCount(oChipBox.m_Data.rare)),
		okStr = "确认",
		cancelStr = "取消",
		okCallback = function()
			self:OnClickClose()
			netorg.C2GSOrgWish(oChipBox.m_Data.id)
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function COrgWishChipPart.OnClickClose(self)
	self:SetActive(false)
end

return COrgWishChipPart