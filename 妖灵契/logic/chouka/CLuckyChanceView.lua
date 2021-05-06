local CLuckyChanceView = class("CLuckyChanceView", CViewBase)
--wuling武灵
--wuhun武魂
function CLuckyChanceView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/LuckyChanceView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Notify"
end

function CLuckyChanceView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TextBox = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_Table = self:NewUI(4, CTable)
	--self.m_Grid = self:NewUI(5, CGrid)
	self.m_IconBox = self:NewUI(6, CBox)
	self.m_TitleBox = self:NewUI(7, CBox)
	self:InitContent()
end


function CLuckyChanceView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TextBox:SetActive(false)
	--self.m_Grid:SetActive(false)
	self.m_IconBox:SetActive(false)
	self.m_TitleBox:SetActive(false)
	self:RefreshParterTable()
	self:RefreshHelp()
end

function CLuckyChanceView.RefreshParterTable(self)
	self.m_Table:Clear()
	local pardict = {}
	local datalist = {data.partnerdata.WUHUNCARD, data.partnerdata.WULINGCARD}
	for _, d in ipairs(datalist) do
		for k, v in ipairs(d) do
			if not pardict[v.rare] then
				pardict[v.rare] = {}
			end
			for _, parid in ipairs(v.partner_list) do
				if not table.index(pardict[v.rare], parid) then
					table.insert(pardict[v.rare], parid)
				end
			end
		end
	end

	for _, text in ipairs({"SSR", "SR", "R", "N"}) do
		local idx = define.Partner.Rare[text]
		if pardict[idx] and #pardict[idx] > 0 then
			local titlebox = self:CreateTitleBox(text.."级伙伴")
			local grid = titlebox.m_Grid
			for _, parid in ipairs(pardict[idx]) do
				local iconbox = self:CreateIconBox(parid)
				if iconbox then
					grid:AddChild(iconbox)
				end
			end
			local n = grid:GetCount()
			local w = titlebox:GetWidth()
			titlebox.m_BG:SetHeight((math.floor((n - 1)/7) + 1)*100+90)
			-- titlebox:SetSize(w, (math.floor((n - 1)/7) + 1)*100+70)
			self.m_Table:AddChild(titlebox)
		end
	end
	self.m_Table:Reposition()
end

function CLuckyChanceView.RefreshHelp(self)
	for _, key in ipairs({"chouka1", "chouka2"}) do
		local box = self:CreateTextBox(key)
		if box then
			self.m_Table:AddChild(box)
		end
	end
end

function CLuckyChanceView.CreateIconBox(self, parid)
	local oPartner = data.partnerdata.DATA[parid]
	if oPartner then
		local box = self.m_IconBox:Clone()
		box:SetActive(true)
		box.m_RareSpr = box:NewUI(1, CSprite)
		box.m_NameLabel = box:NewUI(2, CLabel)
		box.m_IconSpr = box:NewUI(3, CSprite)
		box.m_NameLabel:SetText(oPartner["name"])
		g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, oPartner["rare"])
		box.m_IconSpr:SpriteAvatar(oPartner["icon"])
		return box
	end
end

function CLuckyChanceView.CreateTitleBox(self, title)
	local box = self.m_TitleBox:Clone()
	box.m_Label = box:NewUI(1, CLabel)
	box.m_BG = box:NewUI(2, CSprite)
	box.m_Grid = box:NewUI(3, CGrid)
	box.m_Label:SetText(title)
	box:SetActive(true)
	return box
end

function CLuckyChanceView.CreateTextBox(self, key)
	local hdata = data.helpdata.DATA[key]
	if hdata then
		local box = self.m_TextBox:Clone()
		box.m_Widget = box:NewUI(1, CWidget)
		box.m_Title = box:NewUI(2, CLabel)
		box.m_Desc = box:NewUI(3, CLabel)
		box.m_BG = box:NewUI(4, CSprite)
		box.m_Title:SetText(hdata["title"])
		box.m_Desc:SetText(hdata["content"])
		local _, h = box.m_Desc:GetSize()
		local w, _ = box.m_BG:GetSize()
		box.m_BG:SetSize(w, 100 + h)
		box.m_Widget:SetSize(w, 110 + h)
		box:SetActive(true)
		return box
	end
end

return CLuckyChanceView