local CLostBookArticleBox = class("CLostBookArticleBox", CBox)

function CLostBookArticleBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_NeedLabel = self:NewUI(3, CLabel)
	self.m_LockSpr = self:NewUI(4, CSprite)
	self.m_GreySpr = self:NewUI(5, CSprite)
	self.m_ContentLabel = self:NewUI(6, CLabel)
	self.m_NewLabel = self:NewUI(7, CLabel)
	self.m_CostGrid = self:NewUI(8, CGrid)
	self.m_KeySpr = self:NewUI(9, CSprite)
	self.m_RedSpr = self:NewUI(10, CSprite)
	self:InitContent()
end

function CLostBookArticleBox.InitContent(self)
	self.m_KeySpr:SetActive(false)
end

function CLostBookArticleBox.RefreshData(self, oData)
	self.m_Data = oData
	self.m_CData = data.mapbookdata.CHAPTER[oData.id]
	self:RefreshName()
	self:RefreshTitle()
	self:RefreshContent()
	self:RefreshLock()
	self:RefreshCondition()
	self:RefreshCost()
end

function CLostBookArticleBox.RefreshName(self)
	self.m_NameLabel:SetText(self.m_CData.name)
end

function CLostBookArticleBox.RefreshTitle(self)
	self.m_TitleLabel:SetText(self.m_CData.name.." "..self.m_CData.title)
end

function CLostBookArticleBox.RefreshLock(self)
	if self.m_Data.unlock == 0 and #self.m_CData.condition ~= #self.m_Data.condition then
		--未解锁
		self.m_LockSpr:SetActive(true)
		self.m_GreySpr:SetActive(true)
	elseif self.m_CData.content == " " then
		self.m_LockSpr:SetActive(true)
		self.m_GreySpr:SetActive(true)
	else
		self.m_LockSpr:SetActive(false)
		self.m_GreySpr:SetActive(false)
	end
end

function CLostBookArticleBox.RefreshContent(self)
	if self.m_Data.unlock == 0 and #self.m_CData.condition ~= #self.m_Data.condition then
		self.m_ContentLabel:SetActive(false)
	else
		self.m_ContentLabel:SetActive(true)
		self.m_ContentLabel:SetText(self.m_CData.desc)
	end
	self.m_NewLabel:SetActive(false)
	self.m_RedSpr:SetActive(false)
	if self.m_Data.unlock == 1 and self.m_Data.read == 0 and #self.m_CData.condition == #self.m_Data.condition then
		self.m_NewLabel:SetActive(true)
	
	elseif self.m_Data.unlock == 0 and #self.m_CData.condition == #self.m_Data.condition then
		self.m_RedSpr:SetActive(true)
	
	else
		self.m_NewLabel:SetActive(false)
	end

	if self.m_CData.content == " " then
		self.m_NewLabel:SetActive(false)
	end
end

function CLostBookArticleBox.RefreshCondition(self)
	local alllist = self.m_CData.condition
	local curlist = self.m_Data.condition
	local strList = {}
	for i, iConditoinID in ipairs(alllist) do
		local str = data.mapbookdata.CONDITION[iConditoinID]["desc"]
		if table.index(curlist, iConditoinID) then
			str = "#G"..str
		end
		table.insert(strList, str)
	end
	self.m_NeedLabel:SetRichText(table.concat(strList, "\n"))
	if self.m_Data.unlock == 0  then
		self.m_NeedLabel:SetActive(true)
	elseif #self.m_CData.condition ~= #self.m_Data.condition then
		self.m_NeedLabel:SetActive(true)
	else
		self.m_NeedLabel:SetActive(false)
	end
end

function CLostBookArticleBox.RefreshCost(self)
	self.m_CostGrid:Clear()
	if self.m_Data.unlock == 0 and #self.m_CData.condition == #self.m_Data.condition then
		for i = 1, self.m_CData.unlock_keys do
			local spr = self.m_KeySpr:Clone()
			spr:SetActive(true)
			self.m_CostGrid:AddChild(spr)
		end
	else
		
	end
	self.m_CostGrid:Reposition()
end

function CLostBookArticleBox.SetFrontBox(self, oBox)
	self.m_FrontLock = false
	if oBox.m_Data.read == 0 then
		self.m_FrontLock = true
		self.m_GreySpr:SetActive(true)
	end
end

return CLostBookArticleBox