local tbUi = Ui:CreateClass("BrocadeBoxJiYuPanel")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("BrocadeBoxAct") or Activity.BrocadeBoxAct

function tbUi:OnOpenEnd(szType, tbData)
	self.szType = szType
	self:Update(tbData)
end

function tbUi:Update(tbData)
	if self.szType == "Put" then			--放置时的界面
		self.nSelectItemTemplateId = tbData.nItemTemplateId
		self.nSelectItemId = tbData.nItemId
		local szOwnerName = ""
		if House:IsInHouseMap() then
			szOwnerName = House.szName
		end
		self.pPanel:Label_SetText("Name1", szOwnerName)
		self.pPanel:Label_SetText("Name2", "——"..me.szName)
		self.pPanel:SetActive("Content1", true)
		self.pPanel:SetActive("Content2", false)
		self.pPanel:Label_SetText("BtnTxt", "确定")
		self.pPanel:SetActive("BtnRandom", true)
	elseif self.szType == "Catch" then	--收取时的界面
		self.nSenderId = tbData.nSenderId
		self.pPanel:Label_SetText("Name1", me.szName)
		self.pPanel:Label_SetText("Name2", "——"..tbData.szSenderName)

		self.pPanel:SetActive("BtnRandom", false)
		self.pPanel:Label_SetText("BtnTxt", "回赠")
		self.pPanel:SetActive("Content1", false)
		self.pPanel:SetActive("Content2", true)
		self.pPanel:Label_SetText("Content2", tbData.szJiYu)
	end
end

function tbUi:OnClose()

end

tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnRandom()
	local szJiYu = tbAct:RandomTemplateJiYu()
	self.pPanel:Input_SetText("Content1", szJiYu)
end

function tbUi.tbOnClick:BtnSure()
	if self.szType == "Put" then
		self:TryPutBrocadeBox()
	elseif self.szType == "Catch" then
		self:BackSend()
	end
end

function tbUi:TryPutBrocadeBox()
	self.szJiYu = self.pPanel:Input_GetText("Content1")
	if Lib:IsEmptyStr(self.szJiYu) then
		me.CenterMsg("请填写寄语内容")
		return
	end
	RemoteServer.BrocadeBoxActCall("TryPutBrocadeBox", self.nSelectItemTemplateId, self.nSelectItemId, self.szJiYu)
	Ui:CloseWindow(self.UI_NAME)
	Ui:CloseWindow("ItemBox")
end

function tbUi:BackSend()
	RemoteServer.EnterHome(self.nSenderId)
	Ui:CloseWindow(self.UI_NAME)
end