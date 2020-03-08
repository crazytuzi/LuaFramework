local tbUi = Ui:CreateClass("ChatHostList");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHAT_CROSS_HOST, self.UpdateList},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	ChatMgr:AskCrossHostListInfo();
end

function tbUi:OnOpenEnd()
	self:Update();
end

function tbUi:UpdateList(szType)
	if szType == "HostList" then
		self:Update();
	end
end

function tbUi:Update()
	local tbHostList = ChatMgr:GetHostListInfo();
	local tbFollowingMap = ChatMgr:GetCrossHostFollowMap(me);

	local function fnFollowOp(btnObj)
		local nHostId = btnObj.nHostId;
		ChatMgr:FollowHostOpt(nHostId, not tbFollowingMap[nHostId]);
	end

	local fnSetItem = function (itemObj, nIdx)
		local tbHostInfo = tbHostList[nIdx];
		itemObj.pPanel:Texture_SetUrlTexture("Head", tbHostInfo.HeadUrl or "", false);
		itemObj.pPanel:Label_SetText("Name", tbHostInfo.Name or "");
		itemObj.pPanel:Label_SetText("IntroduceTxt", tbHostInfo.Signature or "");
		itemObj.pPanel:Label_SetText("Date", tbHostInfo.DateDesc or "");
		itemObj.pPanel:Label_SetText("Time", tbHostInfo.TimeDesc or "");

		if tbFollowingMap[tbHostInfo.PlayerId or 0] then
			itemObj.BtnFollow.pPanel:Label_SetText("BtnFolloweTxt", "[FFFE0D]已关注[-]");
			itemObj.pPanel:Toggle_SetChecked("BtnFollow", true);
		else
			itemObj.BtnFollow.pPanel:Label_SetText("BtnFolloweTxt", "未关注");
			itemObj.pPanel:Toggle_SetChecked("BtnFollow", false);
		end

		itemObj.BtnFollow.nHostId = tbHostInfo.PlayerId or 0;
		itemObj.BtnFollow.pPanel.OnTouchEvent = fnFollowOp;
	end

	self.ScrollView:Update(#tbHostList, fnSetItem);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end