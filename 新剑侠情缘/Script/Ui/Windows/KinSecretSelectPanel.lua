local tbUi = Ui:CreateClass("KinSecretSelectPanel")
tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		if not self.nSelectIdx or self.nSelectIdx<=0 then
			me.CenterMsg("请选择房间")
			return
		end

		RemoteServer.TryJoinKinSecret(self.nSelectIdx)
		Ui:CloseWindow(self.UI_NAME)
	end,

	Texture1 = function(self)
		self.nSelectIdx = 1
	end,

	Texture2 = function(self)
		self.nSelectIdx = 2
	end,

	Texture3 = function(self)
		self.nSelectIdx = 3
	end,
}

function tbUi:OnOpen()
	self.nSelectIdx = 0
	for i=1, 3 do
		self.pPanel:Toggle_SetChecked("Texture"..i, false)
		self.pPanel:Label_SetText("Number"..i, "当前人数：0")
	end
	Fuben.KinSecretMgr:RefreshJoinCounts()
end

function tbUi:SetCounts(tbCounts)
	for i=1, 3 do
		self.pPanel:Label_SetText("Number"..i, string.format("当前人数：%d", tbCounts[i] or 0))
	end
end
