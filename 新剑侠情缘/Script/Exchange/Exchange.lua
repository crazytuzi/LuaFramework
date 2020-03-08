

function Exchange:ExchangeItems(szType, tbItems)
	local tbSetting = self.tbExchangeSetting[szType];
	if not tbSetting then
		return
	end
	if not next(tbItems) then
		me.CenterMsg("没有选择道具")
		return
	end

	if not Lib:IsEmptyStr(tbSetting.CheckFun) then
		local fnFunc = self[tbSetting.CheckFun]
		local bRet, szMsg = fnFunc(self, tbItems, tbSetting)
		if not bRet then
			if szMsg then
				me.CenterMsg(szMsg)
			end
			return
		end
	end

	RemoteServer.ConfirmExchange(tbItems)	
end