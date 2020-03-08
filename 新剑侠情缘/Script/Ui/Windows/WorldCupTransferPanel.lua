local tbUi = Ui:CreateClass("WorldCupTransferPanel")
local tbAct = Activity.WorldCupAct

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnTransformation = function(self)
		local bOk, szErr = tbAct:Transfer(self.bNormal)
		if not bOk then
			if szErr and szErr ~= "" then
				me.CenterMsg(szErr)
			end
			return
		end
	end,

	Badge1 = function(self)
		Ui:OpenWindow("WorldCupTransSelPanel", true)
	end,
	Badge2 = function(self)
		if self.bNormal then
			me.CenterMsg("普通的徽章转换符不能指定目标徽章")
			return
		end
		Ui:OpenWindow("WorldCupTransSelPanel", false)
	end,
}

function tbUi:OnOpen(bNormal)
	self.bNormal = not not bNormal
	self.pPanel:SetActive("Title1", self.bNormal)
	self.pPanel:SetActive("Title2", not self.bNormal)
	self.pPanel:SetActive("texiao", false)
	self.pPanel:SetActive("BtnTransformation", true)

	tbAct.nTransFromItemId = nil
	tbAct.nTransToItemId = nil

	tbAct:UpdateData()
	self:Refresh()
end

function tbUi:Refresh()
	local tbItems = {tbAct.nTransFromItemId or 0, tbAct.nTransToItemId or 0}
	for i, nItemId in ipairs(tbItems) do
		local szName = "请选择"
		self["itemframe"..i]:SetItemByTemplate(nItemId > 0 and nItemId or tbAct.nMedalItemId, 1, nil, nil, {bShowCDLayer = false})
		if nItemId > 0 then
			szName = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
		end
		if self.bNormal and i == 2 then
			szName = "随机"
		end
		self.pPanel:Label_SetText("Tip"..i, szName)
	end
end
