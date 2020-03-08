local tbUi = Ui:CreateClass("KinChangeName")

function tbUi:OnOpen()
	Client:SetFlag("ChangeNameRed")
	local nCost, bHasItem = Kin:GetChangeNamePrice(me)
	self.nCost = nCost
	if nCost<=0 then
		self.pPanel:SetActive("TXT1", true)		
		self.pPanel:SetActive("TXT2", false)		
		if bHasItem then
			local tbItem = KItem.GetItemBaseProp(Kin.Def.nChangeNameItem)
			self.pPanel:Label_SetText("TXT1", string.format("当前有 [FFFE0D]%s[-] 道具，本次改名免费", tbItem.szName))
		end
	else
		self.pPanel:SetActive("TXT1", false)		
		self.pPanel:SetActive("TXT2", true)		
		self.pPanel:Label_SetText("TXT2", string.format("[FFFE0D]%d[-]", nCost))
	end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnComfirm = function (self)
	local szNewName = self.pPanel:Input_GetText("TxtTitle")
	local bSuccess, szErr = Kin:CheckChangeName(szNewName)
	if not bSuccess then
		me.CenterMsg(szErr)
		return
	end

	local nCost, bHasItem = Kin:GetChangeNamePrice(me)
	if self.nCost ~= nCost then
		self:OnOpen()
	end

	local fnYes = function()
		if not Kin:ChangeName(szNewName) then
			return
		end
		Ui:CloseWindow(self.UI_NAME)
	end
	local szMsg = string.format("是否确认花费 [FFFE0D]%d元宝[-] 改名为 [FFFE0D]%s[-]", Kin.Def.nChangeNameCost, szNewName)
	if bHasItem then
		szMsg = "是否确认消耗道具改名"
	end
	Ui:OpenWindow("MessageBox", szMsg, { {fnYes},{} }, {"同意", "取消"})
end
