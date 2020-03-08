local tbUi = Ui:CreateClass("KinDinnerPartyGuessPanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		self:Guess()
	end,
}

function tbUi:OnOpen(nNpcId, nRound)
	self.nNpcId = nNpcId
	self.pPanel:Label_SetText("Title", string.format("当前为第[FFFE0D]%d[-]轮，请输入成语", nRound))
	self.pPanel:Input_SetText("TxtTitle", "")
end

function tbUi:Guess()
	local szGuess = self.pPanel:Input_GetText("TxtTitle")
	if not szGuess or szGuess == "" then
		me.CenterMsg("请输入")
		return
	end

	if Lib:Utf8Len(szGuess) > KinDinnerParty.Def.nMaxGuessLen then
		me.CenterMsg(string.format("成语最多%d个字", KinDinnerParty.Def.nMaxGuessLen))
		return
	end

	RemoteServer.KinDinnerPartyReq("Guess", self.nNpcId, szGuess)
	Ui:CloseWindow(self.UI_NAME)
end