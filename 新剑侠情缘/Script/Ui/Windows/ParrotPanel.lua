local tbUi = Ui:CreateClass("ParrotPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	EditBTN1 = function(self)
		self:OpenEditPanel(1)
	end,

	EditBTN2 = function(self)
		self:OpenEditPanel(2)
	end,

	EditBTN3 = function(self)
		self:OpenEditPanel(3)
	end,
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_HOUSE_PARROT_UPDATE, self.OnUpdate, self},
	}
end

function tbUi:OnOpen(nId, nOwner)
	self.nOwner = nOwner or House.dwOwnerId
	self.nId = nId

	RemoteServer.HouseParrotUpdateReq(self.nOwner)
end

function tbUi:OpenEditPanel(nIdx)
	Ui:OpenWindow("ParrotEditPanel", self.nId, self.nOwner, nIdx, self.tbCurTalks[nIdx])
end

function tbUi:OnUpdate()
	local nNow = GetTime()
	local tbData = House.tbParrot.tbData
	self.tbCurTalks = {}
	for i = 1, 3 do
		local tbTalk = tbData.tbTalks[i] or {}
		local szTalk, nDeadline = unpack(tbTalk)
		if not szTalk or nDeadline <= nNow then
			szTalk, nDeadline = House.tbParrotDefaultTalks[i], -1
		end

		self.tbCurTalks[i] = szTalk
		self.pPanel:Label_SetText("Label"..i, szTalk)
		self.pPanel:SetActive("TimeRemaining"..i, nDeadline > 0)
		if nDeadline > 0 then
			self.pPanel:Label_SetText("TimeRemaining"..i, string.format("剩余：%s", Lib:TimeDesc2(nDeadline - nNow)))
		end
	end
end