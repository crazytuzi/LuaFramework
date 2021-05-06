local CTimeLimitPartnerPart = class("CTimeLimitPartnerPart", CBox)

function CTimeLimitPartnerPart.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CTimeLimitPartnerPart.InitContent(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_PartnerGrid = self:NewUI(2, CGrid)
	self.m_PartnerBox = self:NewUI(3, CBox)
	self.m_CloseBtn = self:NewUI(4, CBox)
	self.m_ScrollView = self:NewUI(5, CScrollView)

	self.m_PartnerBox:SetActive(false)
	self.m_PartnerBoxArr = {}
	self.m_BanDic = {}
	local nameList = {
		{name = "全部", rare = 0}, 
		{name = "传说伙伴", rare = 2}, 
		{name = "精英伙伴", rare = 1}, 
	}
	self.m_BtnDic = {}
	self.m_BtnGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Btn = oBox:NewUI(1, CLabel)
		oBox.m_SelectedMask = oBox:NewUI(2, CLabel)
		oBox.m_Btn:SetActive(true)
		oBox.m_SelectedMask:SetActive(false)
		oBox.m_Rare = nameList[idx].rare
		self.m_BtnDic[oBox.m_Rare] = oBox
		oBox.m_Btn:SetText(nameList[idx].name)
		oBox.m_SelectedMask:SetText(nameList[idx].name)
		oBox:AddUIEvent("click", callback(self, "OnSelectRare", oBox.m_Rare))
		return oBox
	end)
	self.m_AllBtn = self:CreatePartnerBox()
	self.m_PartnerGrid:AddChild(self.m_AllBtn)
	self.m_AllBtn:SetData({name = "全部伙伴", partner_type = 0})
	self.m_PartnerBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnHide"))
end

function CTimeLimitPartnerPart.CreatePartnerBox(self)
	local oPartnerBox = self.m_PartnerBox:Clone()
	oPartnerBox.m_Btn = oPartnerBox:NewUI(1, CBox)
	oPartnerBox.m_Label = oPartnerBox:NewUI(2, CLabel)
	oPartnerBox.m_SelectMark = oPartnerBox:NewUI(3, CSprite)
	oPartnerBox.m_SelectMark:SetActive(false)
	oPartnerBox.m_Btn:AddUIEvent("click", callback(self, "OnClickPartnerBox", oPartnerBox))

	function oPartnerBox.SetData(self, oData)
		oPartnerBox.m_Data = oData
		oPartnerBox.m_Label:SetText(oData.name)
	end

	return oPartnerBox
end

function CTimeLimitPartnerPart.OnSelectRare(self, iRare)
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn.m_SelectedMask:SetActive(false)
		self.m_CurrentBtn.m_Btn:SetActive(true)
	end
	--全部
	self.m_AllBtn:SetActive(iRare == 0)
	self.m_CurrentBtn = self.m_BtnDic[iRare]

	self.m_AllBtn.m_SelectMark:SetActive(self.m_CurrentParnterID == 0)
	self.m_CurrentBtn.m_SelectedMask:SetActive(true)
	self.m_CurrentBtn.m_Btn:SetActive(false)

	self.m_PartnerDic = {}
	local partnerList = self:GetPartnerList(iRare)
	for i,v in ipairs(partnerList) do
		if self.m_PartnerBoxArr[i] == nil then
			self.m_PartnerBoxArr[i] = self:CreatePartnerBox()
			self.m_PartnerGrid:AddChild(self.m_PartnerBoxArr[i])
		end
		self.m_PartnerBoxArr[i]:SetActive(true)
		self.m_PartnerBoxArr[i]:SetData(v)
		self.m_PartnerDic[v.partner_type] = self.m_PartnerBoxArr[i]
		if self.m_CurrentParnterID == v.partner_type then
			self.m_PartnerDic[v.partner_type].m_SelectMark:SetActive(true)
		else
			self.m_PartnerDic[v.partner_type].m_SelectMark:SetActive(false)
		end
	end
	for i = #partnerList + 1, #self.m_PartnerBoxArr do
		self.m_PartnerBoxArr[i]:SetActive(false)
	end
	self.m_ScrollView:ResetPosition()
end

function CTimeLimitPartnerPart.SetClickCb(self, cb)
	self.m_ClickCb = cb
end

function CTimeLimitPartnerPart.OnClickPartnerBox(self, oPartnerBox)
	-- printc("oPartnerBox.m_Data.partner_type: " .. oPartnerBox.m_Data.partner_type)
	self:OnSelectPartner(oPartnerBox.m_Data.partner_type, true)
	if self.m_ClickCb then
		self.m_ClickCb(oPartnerBox.m_Data.partner_type)
	end
end

function CTimeLimitPartnerPart.OnSelectPartner(self, partnerID, bClose)
	if bClose then
		self:OnHide()
	end
	if self.m_CurrentParnterBox ~= nil then
		self.m_CurrentParnterBox.m_SelectMark:SetActive(false)
	end
	local partnerData = data.partnerdata.DATA[partnerID]
	if partnerData then
		local iRare = partnerData.rare
		if iRare > 0 then
			self:OnSelectRare(iRare)
			self.m_CurrentParnterBox = self.m_PartnerDic[partnerID]
			self.m_CurrentParnterBox.m_SelectMark:SetActive(true)
			self.m_CurrentParnterID = partnerID
		else
			self.m_CurrentParnterID = 0
			self:OnSelectRare(0)
		end
	else
		self.m_CurrentParnterID = 0
		self:OnSelectRare(0)
	end
end

function CTimeLimitPartnerPart.SetHideCb(self, cb)
	self.m_HideCb = cb
end

function CTimeLimitPartnerPart.OnHide(self)
	if self:GetActive() and self.m_HideCb then
		self.m_HideCb()
	end
	self:SetActive(false)
end

function CTimeLimitPartnerPart.SetBanList(self, lPartnerType)
	self.m_BanDic = {}
	for k,v in pairs(lPartnerType) do
		self.m_BanDic[v] = true
	end
end

function CTimeLimitPartnerPart.GetPartnerList(self, key)
	if key == 0 then
		return {}
	end
	local list = {}
	for parid, v in pairs(data.partnerdata.DATA) do
		if v.rank == 0 and key == v.rare and not self.m_BanDic[v.partner_type] then
			table.insert(list, v)
		end
	end
	local function sortFunc(v1, v2)
		return v1.partner_type < v2.partner_type
	end
	
	table.sort(list, sortFunc)
	return list
end

return CTimeLimitPartnerPart