
local tbUi = Ui:CreateClass("StarAwardList");
local tbBtnAward = Ui:CreateClass("BtnAward");
function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	local tbAwardInfo = {};
	local function fnBtnAward(itemObj)
		RemoteServer.TryGetStarAward(itemObj.nSectionIdx, itemObj.nFubenLevel, itemObj.nStarIdx);
		itemObj.pPanel:SetActive("Main", false);
	end

	local function fnSetItem(itemObj, index)
		local tbInfo = tbAwardInfo[index];
		local szName = string.format("第%s章", tbInfo[1]);
		if tbInfo[2] == PersonalFuben.PERSONAL_LEVEL_ELITE then
			szName = szName .. "·精英";
		end

		itemObj.pPanel:Label_SetText("Name", szName);
		itemObj.pPanel:Label_SetText("StarNumber", PersonalFuben.tbStarAwardNum[tbInfo[3]]);
		itemObj["Award"]:SetGenericItem(tbInfo[4][1]);
		itemObj["Award"].fnClick = itemObj["Award"].DefaultClick;
		itemObj["BtnAward"].pPanel.OnTouchEvent = fnBtnAward;
		itemObj["BtnAward"].nSectionIdx = tbInfo[1];
		itemObj["BtnAward"].nFubenLevel = tbInfo[2];
		itemObj["BtnAward"].nStarIdx = tbInfo[3];
		itemObj["BtnAward"].pPanel:SetActive("Main", true);
	end

	self.ScrollView:Update(tbAwardInfo, fnSetItem);
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
