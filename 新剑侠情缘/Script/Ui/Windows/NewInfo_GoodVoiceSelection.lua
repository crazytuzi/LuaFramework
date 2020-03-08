local tbUi = Ui:CreateClass("NewInfo_GoodVoiceSelection")
local MAX_SHOW_AWARD = 10

function tbUi:OnOpen(tbData)
	local tbAct = Activity.GoodVoice;
	local szActContent, tbShowData = tbAct:GetNewInfoShowData(tbData)
	self.Content3:SetLinkText(szActContent);
	for i=1,6 do
		local szWndName = string.format("GoodVoiceItem%s", i)
		self:SetWinnerAward(self[szWndName], tbShowData[i], i)
	end
	local tbContent3Size = self.pPanel:Label_GetPrintSize("Content3");
	local tbItemGroup1Size = self.pPanel:Widget_GetSize("ItemGroup");
	local tbSize = self.pPanel:Widget_GetSize("datagroup3");
	self.pPanel:Widget_SetSize("datagroup3", tbSize.x, #tbShowData * 120 + tbContent3Size.y);
	--self.pPanel:DragScrollViewGoTop("datagroup3");
	self.pPanel:UpdateDragScrollView("datagroup3");
end

function tbUi:SetWinnerAward(tbWnd, tbAwardList, nIndex)
	if tbAwardList then
		tbWnd.pPanel:SetActive("Main", true);
		local szTitle = tbAwardList.szTitle or ""
		tbWnd.pPanel:Label_SetText("GoodVoiceTitle" ..nIndex, szTitle);
		local tbAllAward = tbAwardList.tbAward or {}
		for i=1,MAX_SHOW_AWARD do
			local tbAward = tbAllAward[i]
			if tbAward then
				tbWnd["itemframe" .. i].pPanel:SetActive("Main", true);
				tbWnd["itemframe" .. i]:SetGenericItem(tbAward);
				tbWnd["itemframe" .. i].fnClick = tbWnd["itemframe" .. i].DefaultClick;
			else
				tbWnd["itemframe" .. i].pPanel:SetActive("Main", false);
			end
		end
	else
		tbWnd.pPanel:SetActive("Main", false);
	end
end

tbUi.tbOnClick = {};