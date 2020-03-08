local tbUi = Ui:CreateClass("ComplaintPanel")

local tbToggles = {
	gzs = {"Option6", 1},
	ad = {"Option2", 2},
	abuse = {"Option3", 4},
	plugin = {"Option4", 8},
	other = {"Option5", 16},
}

function tbUi:ChoiceType(szType)
	self.szType = szType
	for szT, tbToggle in pairs(tbToggles) do
		self.pPanel:Toggle_SetChecked(tbToggle[1], szType == szT)
	end
	self.pPanel:SetActive("Input", szType == "other")
end

tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnCancel = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnComfirm = function(self)
		self:Confirm()
	end,
}
for szType, tbToggle in pairs(tbToggles) do
	tbUi.tbOnClick[tbToggle[1]] = function(self)
		self:ChoiceType(szType)
	end
end

function tbUi:OnOpen(nOtherId)
	self.nOtherId = nOtherId

	self.pPanel:Input_SetText("TxtTitle", "")
	for _, tbToggle in pairs(tbToggles) do
		self.pPanel:Toggle_SetChecked(tbToggle[1], false)
	end
	self.pPanel:SetActive("Input", false)
end

local COMPLAINT_DELTA = 5 * 60
local MAXCONTENT = 30
function tbUi:Confirm()
	if GetTime() - (me.nLastComplaintTime or 0) < COMPLAINT_DELTA then
		me.CenterMsg("举报太频繁了，请稍后再举报")
		return
	end

	if (self.nOtherId or 0) <= 0 then
		me.CenterMsg("举报对象不存在")
		return
	end

	if Lib:IsEmptyStr(self.szType) then
		me.CenterMsg("请选择举报类型")
		return
	end

	local szContent = ""
	if self.szType == "other" then
		szContent = self.pPanel:Input_GetText("TxtTitle")
		szContent = Lib:StrTrim(szContent)
		if Lib:IsEmptyStr(szContent) and self.szType == "other" then
			me.CenterMsg("请输入举报内容")
			return
		end
		if Lib:Utf8Len(szContent) > MAXCONTENT then
			me.CenterMsg(string.format("举报内容最多%d字", MAXCONTENT))
			return
		end
	end

	local nType = tbToggles[self.szType][2]
	RemoteServer.Complaint(self.nOtherId, nType, szContent)
	me.nLastComplaintTime = GetTime()
	Ui:CloseWindow(self.UI_NAME)
end