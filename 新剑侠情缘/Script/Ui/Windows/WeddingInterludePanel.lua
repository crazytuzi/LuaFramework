local tbUi = Ui:CreateClass("WeddingInterludePanel");
function tbUi:OnOpen(szContent, tbInfo)
	
	self.pPanel:SetActive("Title", false)
	self.pPanel:SetActive("Title2", false)
	if szContent then
		self.pPanel:SetActive("Title", true)
		self.pPanel:Label_SetText("Title", szContent)
	end

	if tbInfo then
		self.pPanel:SetActive("Title2", true)
		self.pPanel:SetActive("Name1", true)
		self.pPanel:SetActive("Name2", true)
		self.pPanel:SetActive("Content", true)
		self.pPanel:Label_SetText("Name1", tbInfo.szManName or "新郎")
		self.pPanel:Label_SetText("Name2", tbInfo.szFemanName or "新娘")
		self.pPanel:Label_SetText("Content", tbInfo.szContent or "")
	end
	
end