local tbUi = Ui:CreateClass("WeddingBlessingPanel");

function tbUi:OnOpen()
	local fnOnClick = function(itemObj)
		RemoteServer.OnWeddingRequest("TryBless", itemObj.nIdx);
	end;
	local fnSetItem = function(itemObj, nIdx)
		local szTitle = Wedding.tbBlessMsg[nIdx][1]
		itemObj.pPanel:Label_SetText("Label", szTitle)
		itemObj.nIdx = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick;
	end;
	self.ScrollView:Update(#Wedding.tbBlessMsg, fnSetItem);
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end