local tbUi = Ui:CreateClass("AnniversaryJiYuWritePanel")
local tbAct = Activity.AnniversaryJiYuAct

function tbUi:OnOpenEnd(nPlayerId)
	self.bSelf = nPlayerId == me.dwID
	if not self.bSelf and (not tbAct:GetPlayerData(nPlayerId) or not next(tbAct:GetPlayerData(nPlayerId))) then
		return 0
	end
	self.nPlayerId = nPlayerId
	self:UpdateContent()
end

function tbUi:UpdateContent()
	self:CheckCanEdit()
	if self.bSelf then
		self:UpdateMyContent()
	else
		self:UpdateOtherContent()
	end
end

function tbUi:CheckCanEdit()
	if self.bSelf then
		local tbData = tbAct:GetPlayerData(self.nPlayerId) or {}
		local szJiYu = tbData.szJiYu or ""
		if Lib:IsEmptyStr(szJiYu) then
			self.bEdit = true
		else
			self.bEdit = false
		end
	else
		self.bEdit = false
	end
end

function tbUi:UpdateMyContent()
	self.pPanel:SetActive("ContentGroup", true)
	self.pPanel:SetActive("BtnGroup", true)
	self.pPanel:SetActive("BtnShareRight", not self.bEdit)
	self.pPanel:SetActive("BtnEdit", not self.bEdit)
	self.pPanel:SetActive("BtnSubmission", self.bEdit)
	self.pPanel:SetActive("BtnRandom", self.bEdit)

	local tbData = tbAct:GetPlayerData(self.nPlayerId) or {}
	local szJiYu = tbData.szJiYu or ""
	self.szOldJiYu = szJiYu
	local tbJiYu = Lib:SplitStr(szJiYu, "，")
	for i = 1, 3 do
		self.pPanel:Input_SetText("InputField"..i, tbJiYu[i] or "")
		self.pPanel:SetActive("InputField"..i, self.bEdit)
	end
	self.pPanel:SetActive("BtnFabulous", true)
	self.pPanel:Button_SetText("BtnFabulous", tbData.nScore or 0)
end

function tbUi:UpdateOtherContent()
	local tbData = tbAct:GetPlayerData(self.nPlayerId) or {}
	local szJiYu = tbData.szJiYu or ""
	local tbJiYu = Lib:SplitStr(szJiYu, "，")
	for i = 1, 3 do
		self.pPanel:Input_SetText("InputField"..i, tbJiYu[i])
		self.pPanel:SetActive("InputField"..i, false)
	end
	self.pPanel:SetActive("ContentGroup", true)
	self.pPanel:SetActive("BtnGroup", true)

	self.pPanel:SetActive("BtnShareRight", false)
	self.pPanel:SetActive("BtnEdit", false)
	self.pPanel:SetActive("BtnSubmission", false)
	self.pPanel:SetActive("BtnRandom", false)
	self.pPanel:SetActive("BtnFabulous", true)

	self.pPanel:Button_SetText("BtnFabulous", tbData.nScore or 0)
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnRandom()
	if not self.bEdit then
		return
	end
	local szJiYu = tbAct:RandomTemplateJiYu()
	local tbJiYu = Lib:SplitStr(szJiYu, "，")
	for i = 1, #tbJiYu do
		self.pPanel:Input_SetText("InputField"..i, tbJiYu[i])
	end
end

function tbUi.tbOnClick:BtnSubmission()
	local tbJiYu = {}
	for i = 1, 3 do
		local szJiYu = self.pPanel:Input_GetText("InputField"..i)
		table.insert(tbJiYu, szJiYu)
	end
	local szJiYu = table.concat(tbJiYu, "，")
	tbAct:CommitJiYu(szJiYu, self.szOldJiYu)
end

function tbUi.tbOnClick:BtnEdit()
	self.bEdit = true
	self:UpdateMyContent()
end

function tbUi.tbOnClick:BtnFabulous()
	RemoteServer.AnniversaryJiYuActClientCall("RequestThumbsUp", self.nPlayerId)
end

function tbUi.tbOnClick:BtnShareRight()
	RemoteServer.AnniversaryJiYuActClientCall("ShareJiYu")
end

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_SYNC_ANNIVERSARYJIYU_DATA, self.UpdateContent}
	}
end