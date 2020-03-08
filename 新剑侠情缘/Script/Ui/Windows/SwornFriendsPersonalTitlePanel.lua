local tbUi = Ui:CreateClass("SwornFriendsPersonalTitlePanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnCancel = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		self:Confirm()
	end,
}

function tbUi:OnOpen(bConsumeItem)
	self.bConsumeItem = bConsumeItem
	self.pPanel:Label_SetText("MainSworn", string.format("%s之", SwornFriends.szMainTitle or ""))
end

function tbUi:Confirm()
	local szTitle = self.pPanel:Input_GetText("TxtTitle")
	local bOk, szErr = SwornFriends:ChangePersonalTitleReq(szTitle, self.bConsumeItem)
	if not bOk then
		me.CenterMsg(szErr)
		return
	end
	Ui:CloseWindow(self.UI_NAME)
end