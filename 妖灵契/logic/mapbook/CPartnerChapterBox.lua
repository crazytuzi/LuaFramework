local CPartnerChapterBox = class("CPartnerChapterBox", CBox)

function CPartnerChapterBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_NeedLabel = self:NewUI(3, CLabel)
	self.m_LockSpr = self:NewUI(4, CSprite)
	self.m_GreySpr = self:NewUI(5, CSprite)
	self.m_ContentLabel = self:NewUI(6, CLabel)
	self.m_NewLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CPartnerChapterBox.InitContent(self)
	-- body
end

function CPartnerChapterBox.RefreshData(self, oData)
	self.m_Data = oData
	self.m_CData = data.mapbookdata.CHAPTER[oData.id]
	--self:RefreshName()
	self:RefreshTitle()
	self:RefreshContent()
	self:RefreshLock()
	self:RefreshCondition()
end

function CPartnerChapterBox.RefreshName(self)
	self.m_NameLabel:SetText(self.m_CData.name)
end

function CPartnerChapterBox.RefreshTitle(self)
	self.m_TitleLabel:SetText(self.m_CData.name.." "..self.m_CData.title)
end

function CPartnerChapterBox.RefreshLock(self)
	if self.m_Data.unlock == 0 then
		--未解锁
		self.m_LockSpr:SetActive(true)
		self.m_GreySpr:SetActive(true)
	else
		self.m_LockSpr:SetActive(false)
		self.m_GreySpr:SetActive(false)
	end
end

function CPartnerChapterBox.RefreshContent(self)
	if self.m_Data.unlock == 0 then
		self.m_ContentLabel:SetActive(false)
	else
		self.m_ContentLabel:SetActive(true)
		self.m_ContentLabel:SetText(self.m_CData.desc)
	end
	local alllist = self.m_CData.condition
	local curlist = self.m_Data.condition
	if self.m_Data.unlock == 1 and self.m_Data.read == 0 and #alllist == #curlist then
		self.m_NewLabel:SetActive(true)
	else
		self.m_NewLabel:SetActive(false)
	end
end

function CPartnerChapterBox.RefreshCondition(self)
	local alllist = self.m_CData.condition
	local curlist = self.m_Data.condition
	local strList = {}
	
	for i, iConditoinID in ipairs(alllist) do
		local str = data.mapbookdata.CONDITION[iConditoinID]["desc"]
		if table.index(curlist, iConditoinID) then
			str = "#G"..str.."#n"
		end
		table.insert(strList, str)
	end
	self.m_NeedLabel:SetRichText(table.concat(strList, "\n"))
	self.m_NeedLabel:SetActive(self.m_Data.unlock == 0)
end

function CPartnerChapterBox.SetFrontBox(self, oBox)
	self.m_FrontLock = false
	if oBox.m_Data.read == 0 then
		self.m_FrontLock = true
		self.m_GreySpr:SetActive(true)
	end
end

return CPartnerChapterBox