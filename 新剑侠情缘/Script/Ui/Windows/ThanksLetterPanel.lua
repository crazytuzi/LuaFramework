local tbUi = Ui:CreateClass("ThanksLetterPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen()
	for i = 1, 4 do
		self.pPanel:Label_SetText("PassWord"..i,
			string.format("？？？（%s 19：15可以查看）", self:GetDateStr(Activity.ThanksLetterAct.tbRedBags[i].nDate)))
	end
	RemoteServer.ThanksLetterUpdateReq()
end

function tbUi:GetDateStr(nDate)
	local tbTime = os.date("*t", nDate)
	return string.format("%s-%s", tbTime.month, tbTime.day)
end

function tbUi:OnServerUpdate(nNow, nCurRedBagDate)
	for i, tb in ipairs(Activity.ThanksLetterAct.tbRedBags) do
		local nDate = tb.nDate
		if Lib:IsDiffDay(0, nDate, nNow) then
			if nDate < nNow then
				self.pPanel:Label_SetText("PassWord"..i, string.format("%s 口令：%s", self:GetDateStr(nDate), tb.szPwd))
			end
		else
			if not Lib:IsDiffDay(0, nNow, nCurRedBagDate) then
				local szText = string.format("%s 口令：%s", self:GetDateStr(nDate), tb.szPwd)
				self.pPanel:Label_SetText("PassWord"..i, szText)
			end
		end
	end
end