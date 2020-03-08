local tbUi = Ui:CreateClass("MarriageTitlePanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		self:Confirm()
	end,
}

function tbUi:OnOpen(szHusbandName, szWifeName)
	if not TeamMgr:IsCaptain() then
		return false
	end

	self.szHusbandName = szHusbandName
	self.szWifeName = szWifeName

	self.pPanel:Label_SetText("GroomTitle", string.format("%s的", szHusbandName))
	self.pPanel:Label_SetText("BrideTitle", string.format("%s的", szWifeName))
	local nCost = Wedding.nChangeTitleCost
	if me.GetItemCountInBags(Wedding.nChangeTitleItemId)>0 then
		nCost = 0
	end
	self.pPanel:Label_SetText("Cost", nCost)
	self.pPanel:Input_SetText("TxtTitle1", "")
	self.pPanel:Input_SetText("TxtTitle2", "")
end

function tbUi:Confirm()
	local szWifeTitle = self.pPanel:Input_GetText("TxtTitle1")
	local szHusbandTitle = self.pPanel:Input_GetText("TxtTitle2")

	local bOk, szErr = Wedding:CheckBeforeChangeTitle(szHusbandTitle, szWifeTitle)
	if not bOk then
		me.CenterMsg(szErr)
		return
	end

	local fnConfirm = function()
		local bOk, szErr = Wedding:ChangeTitleReq(szHusbandTitle, szWifeTitle)
		if not bOk then
			me.CenterMsg(szErr)
			return
		end
	end
	me.MsgBox(string.format("确定将夫妻称号改为[FFFE0D]「%s的%s」[-]和[FFFE0D]「%s的%s」[-]吗？", self.szHusbandName, szWifeTitle, self.szWifeName, szHusbandTitle),
				{{"确定", fnConfirm}, {"取消"}})
	Ui:CloseWindow(self.UI_NAME)
end