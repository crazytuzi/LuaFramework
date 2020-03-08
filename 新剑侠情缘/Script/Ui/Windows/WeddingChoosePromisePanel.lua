local tbUi = Ui:CreateClass("WeddingChoosePromisePanel");
function tbUi:OnOpen(szName)
	self.nChoose = 1
	local fnOnClick = function(itemObj)
		self.nChoose = itemObj.nIdx
	end
	local fnSetItem = function(itemObj, nIdx)
		itemObj.nIdx = nIdx
		itemObj.pPanel:Label_SetText("WishTxt", string.format(Wedding.tbProposePromise[nIdx], szName or ""))
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:Toggle_SetChecked("Main", self.nChoose == nIdx)
	end
	self.ScrollView:Update(#Wedding.tbProposePromise, fnSetItem);
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnPropose = function (self)
		if not Wedding.tbProposePromise[self.nChoose] then
			me.CenterMsg("请选择一条誓言", true)
			return 
		end
		RemoteServer.OnWeddingRequest("TryPropose", self.nChoose);
	end;
}