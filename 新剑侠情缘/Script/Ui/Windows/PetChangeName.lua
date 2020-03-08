local tbUi = Ui:CreateClass("PetChangeName")

function tbUi:OnOpen(nPetTemplateId)
	self.nPetTemplateId = nPetTemplateId
	self.pPanel:SetActive("TXT1", false)		
	self.pPanel:SetActive("TXT2", true)
	self.nCost = Pet.Def.nChangeNamePrice
	self.pPanel:Label_SetText("TXT2", string.format("[FFFE0D]%d[-]", self.nCost))
	self.pPanel:Input_SetText("TxtTitle", "")
end

tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnComfirm = function (self)
	if me.GetMoney("Gold") < self.nCost  then
		me.CenterMsg("您的元宝不足")
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
		return
	end

	local szNewName = self.pPanel:Input_GetText("TxtTitle")
	local fnYes = function ()
		Pet:ChangeName(self.nPetTemplateId, szNewName)
		Ui:CloseWindow(self.UI_NAME)
	end
	local szMsg = string.format("是否确认花费 [FFFE0D]%d元宝[-] 改名为 [FFFE0D]%s[-]", self.nCost, szNewName)
	Ui:OpenWindow("MessageBox",
		szMsg,
	 { {fnYes},{} }, 
	 {"同意", "取消"})
end
