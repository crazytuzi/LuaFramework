local tbUi = Ui:CreateClass("BrocadeBoxQuestionPanel")

local tbOptionButtons = {
	"BtnA",
	"BtnB",
	"BtnC",
	"BtnD",
}

function tbUi:OnOpenEnd(tbAnwser, nNpcId)
	self.nNpcId = nNpcId
	self.pPanel:Label_SetText("TxtQuestion", "猜猜看是以下哪位好友给您赠送的锦盒呢？")
	for nIdx, szBtnName in ipairs(tbOptionButtons) do
		self[szBtnName].pPanel:Label_SetText("TxtAnwser", tbAnwser[nIdx])

		self[szBtnName].pPanel:SetActive("Fork", false);
		self[szBtnName].pPanel:SetActive("Hook", false);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:AnwserQuestion(nAnwserIdx)
	RemoteServer.BrocadeBoxActCall("OnAnwserQuestion", self.nNpcId, nAnwserIdx)
end

for nIndex, szBtnName in ipairs(tbOptionButtons) do
	tbUi.tbOnClick[szBtnName] = function (self)
		self:AnwserQuestion(nIndex);
		Ui:CloseWindow(self.UI_NAME)
	end
end