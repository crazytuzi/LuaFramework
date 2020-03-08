local tbUi = Ui:CreateClass("BlessPanelWord");

function tbUi:OnOpen()
	self.bInAct = Activity:__IsActInProcessByType("SendBlessActWord") and true or false;
	SendBless:CheckData()

	self:UpdateList()

	self:UpdateOtherInfo()

end

function tbUi:OnClose()
end

function tbUi:UpdateList()
	local tbAllFriend = FriendShip:GetAllFriendData()
	local tbWordsGet = SendBless:GetWordsGet()
	
	local tbSortDatas = {}
	local tbSendData = SendBless.tbSendData
	local tbGetData = SendBless.tbGetData
	for i,v in ipairs(tbAllFriend) do
		if v.nLevel >= SendBless.nMinLevel then
			v.nSendedVal = tbSendData[v.dwID]
			v.nGetVal = tbGetData[v.dwID]
			if v.nGetVal then
				v.szGetWord = tbWordsGet[v.dwID] 
				if Lib:IsEmptyStr(v.szGetWord) then
					v.szGetWord = SendBless.szDefaultWord
				end
			else
				v.szGetWord = nil;
			end
			v.nSort = v.nImity
			if v.nState == 2 then
				v.nSort = v.nSort + 10000000
			end
			table.insert(tbSortDatas, v)
		end
	end
	local fnSort = function (a, b)
		return a.nSort > b.nSort
	end
	table.sort( tbSortDatas, fnSort )

	local fnOnClick = function (itemClass)
		self.nSelFriendIndex = itemClass.index
	end

	local fnSetFriend = function (itemClass, index)
		local tbRoleInfo = tbSortDatas[index]
		itemClass:SetData(tbRoleInfo, self.bInAct)
		
		itemClass.index = index
		itemClass.pPanel.OnTouchEvent = fnOnClick;
		itemClass.pPanel:Toggle_SetChecked("Main", self.nSelFriendIndex == index)
	end
	self.ScrollView:Update(tbSortDatas, fnSetFriend);
end

function tbUi:UpdateOtherInfo()
	self.pPanel:SetActive("EndTip", not self.bInAct)
	if self.bInAct then
		local tbActSetting = SendBless:GetActSetting()
		self.pPanel:Label_SetText("TodayBlessing", string.format("今天还可祝福：%d/%d", (SendBless.nMAX_SEND_TIMES - SendBless:GetSendTimes(SendBless.tbSendData, tbActSetting.bGoldSkipTimes)), SendBless.nMAX_SEND_TIMES ))	
		self.pPanel:Label_SetText("TodayTime", string.format("还可获得宝箱：%d/%d", tbActSetting.nMaxGetBlessAwardTimes - (SendBless.nCurGetBlessAwardTimes or 0), tbActSetting.nMaxGetBlessAwardTimes))
	else

		self.pPanel:Label_SetText("TodayBlessing", "今天还可祝福：-/-")
		self.pPanel:Label_SetText("TodayTime", "")
	end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:Btn_Info()
	Ui:OpenWindow("NewInformationPanel", "SendBlessActWord")
end

function tbUi:OnSynData()
	self:UpdateList()
	self:UpdateOtherInfo()
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SEND_BLESS_CHANGE, self.OnSynData, self },
	};

	return tbRegEvent;
end