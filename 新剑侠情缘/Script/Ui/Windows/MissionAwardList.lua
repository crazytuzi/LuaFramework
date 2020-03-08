local tbMAItem = Ui:CreateClass("MAItem")
tbMAItem.tbOnClick = {};
tbMAItem.tbOnClick.BtnAward = function (self)
	RemoteServer.CallMissionAwardFunc("ShowMissionAward", nil, self.nType, self.nRecordId);
	Ui:CloseWindow("MissionAwardList");
end

local tbUi = Ui:CreateClass("MissionAwardList");

function tbUi:OnOpenEnd()
	RemoteServer.CallMissionAwardFunc("GetAwardListList");
end

function tbUi:Update(tbList)
	tbList = tbList or {};
	local function fnSetItem(itemObj, index)
		local tbInfo = tbList[index];
		
		itemObj.pPanel:Label_SetText("Name", tbInfo.szName);
		itemObj.pPanel:Label_SetText("Tips", tbInfo.bHasFreeTimes and "有免费抽奖次数" or "有可抽奖次数");
		itemObj.nType = tbInfo.nType;
		itemObj.nRecordId = tbInfo.nRecordId;
	end

	self.ScrollView:Update(tbList, fnSetItem);
end

function tbUi:OnClose()
	self:Update();
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
