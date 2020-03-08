local tbUi = Ui:CreateClass("BlessPanel");

function tbUi:OnOpen()
	SendBless:CheckData()
	self:UpdateTimer()

	self:UpdateList()

	self:UpdateOtherInfo()

	self.nTimer =  Timer:Register(Env.GAME_FPS * 1, self.UpdateTimer, self)
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:UpdateTimer()
	self.bInAct = Activity:__IsActInProcessByType("SendBlessAct")
	if self.bInAct then
		local nNowCount, nTimeDiff = SendBless:GetNowMaxSendTimes(me)
		local szEndMsg = ""
		if nNowCount < SendBless.nStackMax then
			local nNextTime = SendBless.nTimeStep - nTimeDiff % SendBless.nTimeStep
			szEndMsg = string.format("（%d秒后获得）", nNextTime)
		end
		self.pPanel:Label_SetText("BlessingTime",  string.format("祝福次数：%d/%d", nNowCount, SendBless.nStackMax) .. szEndMsg)	
	else
		self.pPanel:Label_SetText("BlessingTime",  "祝福次数：-/-")	
	end

	return true
end

function tbUi:UpdateList()
	local tbAllFriend = FriendShip:GetAllFriendData()
	local tbSortDatas = {}
	local tbSendData = SendBless.tbSendData
	local tbGetData = SendBless.tbGetData
	for i,v in ipairs(tbAllFriend) do
		if v.nLevel >= SendBless.nMinLevel then
			v.nGetBlessVal = SendBless:GetSendBlessVal(v.dwID, me.dwID, v, me)
			v.nSendedVal = tbSendData[v.dwID]
			v.nGetVal = tbGetData[v.dwID]
			v.nSortParam = math.max(v.nGetBlessVal, v.nGetVal or 0)
			table.insert(tbSortDatas, v)
		end
	end
	local fnSort = function (a, b)
		if a.nSortParam == b.nSortParam then
			return a.nImity > b.nImity
		else
			return a.nSortParam > b.nSortParam
		end
	end
	table.sort( tbSortDatas, fnSort )

	local fnOnClick = function (itemClass)
		self.nSelFriendIndex = itemClass.index
	end

	local fnSetFriend = function (itemClass, index)
		itemClass:SetData(tbSortDatas[index], self.bInAct)
		itemClass.index = index
		itemClass.pPanel.OnTouchEvent = fnOnClick;
		itemClass.pPanel:Toggle_SetChecked("Main", self.nSelFriendIndex == index)
	end
	self.ScrollView:Update(tbSortDatas, fnSetFriend);
end

function tbUi:UpdateOtherInfo()
	local nTotalVal = SendBless:GetScoreInfo(SendBless.tbGetData)
	self.pPanel:SetActive("EndTip", not self.bInAct)
	if self.bInAct then
		local tbActSetting = SendBless:GetActSetting()
		self.pPanel:Label_SetText("TodayBlessing", string.format("今天还可祝福：%d/%d", (SendBless.nMAX_SEND_TIMES - SendBless:GetSendTimes(SendBless.tbSendData, tbActSetting.bGoldSkipTimes)), SendBless.nMAX_SEND_TIMES ))	
	else
		self.pPanel:Label_SetText("TodayBlessing", "今天还可祝福：-/-")
	end
	
	self.pPanel:Label_SetText("BlessingGrossValue", nTotalVal)
    
	local nCurAwardLevel, tbCurAwrd = SendBless:GetCurAwardLevel(me, SendBless.tbGetData)
	if nCurAwardLevel then
		self.pPanel:Button_SetEnabled("BtnGet", true)
	else
		self.pPanel:Button_SetEnabled("BtnGet", false) --不能领，则显示要领的要下一级
		nCurAwardLevel, tbCurAwrd =  SendBless:GetNextLevelAward()
	end

	if nCurAwardLevel and tbCurAwrd then
		self.pPanel:SetActive("TipTxt", true)
		local tbAwardInfo = SendBless.tbTakeAwardSet[nCurAwardLevel]
		local szAwardTxt = ""
		local szAwardType, nAwardItemId, nAwardNum = unpack(tbCurAwrd)
		if Player.AwardType[szAwardType] == Player.award_type_item then
			local tbBaseInfo = KItem.GetItemBaseProp(nAwardItemId) --道具的品质颜色
			local _,_,_,_,TxtColor = Item:GetQualityColor(tbBaseInfo.nQuality)
			
			szAwardTxt = string.format("[%s][url=openwnd:%s, ItemTips, 'Item', nil, %d][-]*%d", TxtColor, tbBaseInfo.szName, nAwardItemId, nAwardNum)
		else
			local szMoneyName = Shop:GetMoneyName(szAwardType)
			szAwardTxt = string.format("[11adf6]%d%s[-]", nAwardItemId, szMoneyName)
		end
		self.TipTxt:SetLinkText(string.format("达到%d可领取奖励%s", tbAwardInfo.nScore, szAwardTxt))
	else
		self.pPanel:SetActive("TipTxt", false)
	end

end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end


function tbUi.tbOnClick:BtnDetails()
	Ui:OpenWindow("NewInformationPanel", "SendBlessAct")
end

function tbUi.tbOnClick:BtnGet()
	local nCurAwardLevel, tbCurAwrd = SendBless:GetCurAwardLevel(me, SendBless.tbGetData)
	if not nCurAwardLevel or not tbCurAwrd then
		me.CenterMsg("当前没有可领奖励")
		return
	end
	RemoteServer.RequetTakeSendBlessAward()
end

function tbUi.tbOnClick:BtnBlessingTip()
	local szTip = [[好友通过祝福函向您送出祝福时，可以获得1点祝福值。
    [FFFE0D]总祝福值[-]：获得祝福值最高的前[FFFE0D]10[-]名总和。
    按下列规则可以获得[FFFE0D]额外[-]祝福值：
    [FFFE0D]·元宝祝福[-]：1点
    [FFFE0D]·关系加成[-]：同家族1点，师徒1点
    [FFFE0D]·祝福方头衔[-]：潜龙1点，傲世2点，倚天3点，至尊4点，武圣5点。
    [FFFE0D]·亲密等级[-]：5+级1点，10+级2点，15+级3点，20+级4点，30+级5点
    ]]
	local tbPos = self.pPanel:GetRealPosition("BtnBlessingTip");
	Ui:OpenWindowAtPos("AttributeDescription", tbPos.x, tbPos.y - 100, szTip)
end

function tbUi.tbOnClick:BtnGetTip()
	local szTip = [[随着祝福函中的总祝福值越来越大，可以领取[FFFE0D]档次奖励[-]，如下：
    ·达到5：  可领取2个[11adf6][url=openwnd:黄金宝箱, ItemTips, "Item", nil, 786][-]
    ·达到10： 可领取1000贡献
    ·达到20： 可领取2个[11adf6][url=openwnd:蓝水晶, ItemTips, "Item", nil, 223][-]
    ·达到30： 可领取200元宝
    ·达到40： 可领取3000贡献
    ·达到50： 可领取[11adf6][url=openwnd:3级魂石箱, ItemTips, "Item", nil, 2164][-]
    ·达到60： 可领取[11adf6][url=openwnd:高级藏宝图, ItemTips, "Item", nil, 788][-]
    ·达到70： 可领取[11adf6][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]
    ·达到80： 可领取500元宝
    ·达到90： 可领取5000贡献
    ·达到100：可领取[11adf6][url=openwnd:4级魂石箱, ItemTips, "Item", nil, 2165][-]
    ]]
    Ui:OpenWindowAtPos("AttributeDescription", 0, 0, szTip)
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