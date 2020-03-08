local tbUi = Ui:CreateClass("ParrotEditPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnComfirm = function(self)
		local szTalk = self.pPanel:Input_GetText("TxtTitle")
		local nLength = Lib:Utf8Len(szTalk)
		local nMin, nMax = unpack(House.tbParrotTalkLength)
		if nLength < nMin or nLength > nMax then
			me.CenterMsg(string.format("语句长度限制为%d~%d字", nMin, nMax))
			return
		end
		if ReplaceLimitWords(szTalk) then
			me.CenterMsg("有敏感词，请修改后再试")
			return
		end
		szTalk = ChatMgr:Filter4CharString(szTalk)
		RemoteServer.HouseParrotSetTalk(self.nOwner, self.nIdx, szTalk)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(nId, nOwner, nIdx, szCurTalk)
	self.nOwner = nOwner or House.dwOwnerId
	self.nId = nId
	self.nIdx = nIdx

	local _, szMoneyEmotion = Shop:GetMoneyName(House.szParrotEditMoneyType)
	self.pPanel:Label_SetText("TXT", string.format("%s%s", szMoneyEmotion, self.nOwner == me.dwID and House.tbParrotEditPrice.tbOwner[nIdx] or House.tbParrotEditPrice.tbOther[nIdx]))
	self.pPanel:Input_SetText("TxtTitle", szCurTalk or "")
end