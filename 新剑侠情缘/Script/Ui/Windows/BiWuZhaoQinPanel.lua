
local tbUi = Ui:CreateClass("BiWuZhaoQinPanel");

function tbUi:OnOpen(tbLimitInfo)
	local bInZhaoQin = tbLimitInfo and true or false;
	self.pPanel:SetActive("Recruit", bInZhaoQin);
	self.pPanel:SetActive("BtnOpen", not bInZhaoQin);
	self.pPanel:SetActive("BtnCancel", bInZhaoQin);
	self.pPanel:SetActive("Consume", not bInZhaoQin);
	self.pPanel:SetActive("BtnSelect1", not bInZhaoQin);
	self.pPanel:SetActive("BtnSelect3", not bInZhaoQin);

	self.pPanel:SetActive("TxtInput2", not bInZhaoQin);
	self.pPanel:SetActive("Title4", bInZhaoQin);
	self.pPanel:SetActive("TitleTxt1", bInZhaoQin);
	self.pPanel:SetActive("TitleTxt2", bInZhaoQin);
	self.pPanel:SetActive("TitleTxt3", bInZhaoQin);
	self:Update(tbLimitInfo);
end

function tbUi:Update(tbLimitInfo)
	self.pPanel:Label_SetText("ContentTxt", BiWuZhaoQin.szUiDesc);
	if tbLimitInfo then
		self.pPanel:Label_SetText("TitleTxt1", tbLimitInfo.nTypeId == 0 and "全服" or string.format("家族：%s", tbLimitInfo.szKinName));
		self.pPanel:Label_SetText("TitleTxt2", string.format("%s级", tbLimitInfo.nLevel));
		self.pPanel:Label_SetText("TitleTxt3", Player.tbHonorLevelSetting[tbLimitInfo.nMinHonor].Name);
		self.pPanel:Label_SetText("TitleTxt4", os.date("%Y年%m月%d日", tbLimitInfo.nOpenDay * 3600 * 24 + 1));
	else
		self.pPanel:PopupList_Clear("BtnSelect1");
		self.pPanel:PopupList_AddItem("BtnSelect1", "点击选择");
		self.pPanel:PopupList_AddItem("BtnSelect1", "全服");
		if me.dwKinId > 0 then
			self.pPanel:PopupList_AddItem("BtnSelect1", "家族");
		end
		self.pPanel:PopupList_Select("BtnSelect1", "点击选择");

		self.Item:SetDigitalItem("Gold", 0, {bShowCount = false});
		self.Item.fnClick = self.Item.DefaultClick;

		local tbLimitInfo;
		for _, tbInfo in pairs(BiWuZhaoQin.tbLimitByTimeFrame) do
			if GetTimeFrameState(tbInfo[1]) == 1 then
				tbLimitInfo = tbInfo;
			else
				break;
			end
		end
		self.tbLimitInfo = tbLimitInfo;
		self.pPanel:Label_SetText("TxtInput2", "在此输入等级");
		self.pPanel:Button_SetText("BtnSelect3", "点击选择");
	end
end


tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnCancel = function (self)
	RemoteServer.BiWuZhaoQinAct("CancelZhaoQin");
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnOpen = function (self)
	local szTypeInfo = self.pPanel:Label_GetText("SelectName1");
	if szTypeInfo ~= "全服" and szTypeInfo ~= "家族" then
		me.CenterMsg("请选择招亲范围！");
		return;
	end

	local nType = szTypeInfo == "全服" and BiWuZhaoQin.TYPE_GLOBAL or BiWuZhaoQin.TYPE_KIN;

	local szLevelInfo = self.pPanel:Label_GetText("TxtInput2") or "";
	local nLevel = string.match(szLevelInfo, "(%d+)");
	nLevel = tonumber(nLevel or "");
	if not nLevel then
		me.CenterMsg("请选择最低参与等级！")
		return;
	end

	local nHonorLevel = 0;
	local szHonor = self.pPanel:Label_GetText("SelectName3");
	for i = 1, self.tbLimitInfo[2] do
		if Player.tbHonorLevelSetting[i].Name == szHonor then
			nHonorLevel = i;
			break;
		end
	end
	if nHonorLevel <= 0 then
		me.CenterMsg("请选择最低参与头衔！");
		return;
	end

	RemoteServer.BiWuZhaoQinAct("ZhaoQin", nType, nLevel, nHonorLevel);
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnSelect3 = function (self)
	local tbInfo = {};
	for i = 1, self.tbLimitInfo[2] do
		tbInfo[i] = Player.tbHonorLevelSetting[i].Name;
	end
	Ui:OpenWindow("TextSelectPanel", tbInfo, function (nIdx)
		if nIdx and tbInfo[nIdx] then
			self.pPanel:Button_SetText("BtnSelect3", tbInfo[nIdx]);
		end
	end);
end

tbUi.tbOnClick.TxtInput2 = function (self)
	local function fnUpdate(nInput, bClose)
		nInput = nInput <= 0 and 1 or nInput;
		nInput = nInput > self.tbLimitInfo[3] and self.tbLimitInfo[3] or nInput;
		if bClose then
			nInput = math.max(nInput, BiWuZhaoQin.nMinPlayerLevel);
		end
		self.pPanel:Label_SetText("TxtInput2", string.format("%s级", nInput));
		return nInput;
	end
	local tbSize = self.pPanel:Widget_GetSize("TxtInput2");
	local tbPos = self.pPanel:GetPosition("TxtInput2");

	self.pPanel:Label_SetText("TxtInput2", string.format("%s级", BiWuZhaoQin.nMinPlayerLevel));
	Ui:OpenWindowAtPos("NumberKeyboard", tbPos.x - tbSize.x / 2, tbPos.y + tbSize.y * 1.5, fnUpdate);
end

tbUi.tbOnClick.BtnInfo = function (self)
	Ui:OpenWindow("NewInformationPanel", "BiWuZhaoQin");
end

tbUi.tbUiPopupOnChange = tbUi.tbUiPopupOnChange or {};
tbUi.tbUiPopupOnChange.BtnSelect1 = function (self, szWndName, value)
	local bShow = value ~= "点击选择";
	self.Item:SetDigitalItem("Gold", value == "全服" and BiWuZhaoQin.nCostGold_TypeGlobal or BiWuZhaoQin.nCostGold_TypeKin, {bShowCount = bShow});
end
