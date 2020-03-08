local tbUi = Ui:CreateClass("WeddingBookPanel");
tbUi.tbSetting = 
{
	[Wedding.Level_1] = {
		szBtnName = "BtnTab1";
		szContent = "    静谧的庄园，邀请三五好友，在漫天飘落的樱花中\n许下对你的誓言，这一世，誓不辜负有你的美景。\n    「青枝连理栽，晚樱悄自开」\n    婚礼流程：[00FF00][url=openwnd:迎宾, AttributeDescription, '', false, 'WeddingWelcome']、[url=openwnd:山盟海誓, AttributeDescription, '', false, 'WeddingPromise']、[url=openwnd:拜堂, AttributeDescription, '', false, 'WeddingCeremony']、[url=openwnd:开心爆竹, AttributeDescription, '', false, 'WeddingFirecracker']、[url=openwnd:宴席, AttributeDescription, '', false, 'WeddingTableFood']、[url=openwnd:派喜糖, AttributeDescription, '', false, 'WeddingCandy'][-]";
		tbTxtScrollViewReset = {20, 100};
		nRow = 4;
	};
	[Wedding.Level_2] = {
		szBtnName = "BtnTab2";
		szContent = "    寻一方青翠怡然的海岛，邀请亲朋好友齐聚一堂，\n在琳琅满目的红灯笼与飘然若舞的红鸾装饰下，许下此生永\n不更改的誓言。「红鸾比翼飞，侠少揽月归」\n    婚礼流程：[00FF00][url=openwnd:迎宾, AttributeDescription, '', false, 'WeddingWelcome']、[url=openwnd:山盟海誓, AttributeDescription, '', false, 'WeddingPromise']、[url=openwnd:拜堂, AttributeDescription, '', false, 'WeddingCeremony']、[url=openwnd:开心爆竹, AttributeDescription, '', false, 'WeddingFirecracker']、[url=openwnd:同食同心果, AttributeDescription, '', false, 'WeddingConcentricFurit']、[url=openwnd:宴席, AttributeDescription, '', false, 'WeddingTableFood']、[url=openwnd:派喜糖, AttributeDescription, '', false, 'WeddingCandy'][-]\n    完婚后，夫妻双方额外获得[aa62fc][url=openwnd:新郎·晚樱连理, ItemTips, 'Item', nil, 6156]、[url=openwnd:新娘·晚樱连理, ItemTips, 'Item', nil, 6157]";
		tbTxtScrollViewReset = {20, 100};
		nRow = 5;
	};
	[Wedding.Level_3] = {
		szBtnName = "BtnTab3";
		szContent = "    觅一叶乘风破浪的舫舟，广邀四海之内的有缘人，\n在极尽奢华的金龙金凤的环绕之下，让八方之人见证二人三\n生三世，情缘永系。「龙凤舞和鸣，琴瑟绕三生」\n    婚礼流程：[00FF00][url=openwnd:花轿游襄阳, AttributeDescription, '', false, 'WeddingTourMap']、[url=openwnd:迎宾, AttributeDescription, '', false, 'WeddingWelcome']、[url=openwnd:山盟海誓, AttributeDescription, '', false, 'WeddingPromise']、[url=openwnd:拜堂, AttributeDescription, '', false, 'WeddingCeremony']、[url=openwnd:开心爆竹, AttributeDescription, '', false, 'WeddingFirecracker']、[url=openwnd:同食同心果, AttributeDescription, '', false, 'WeddingConcentricFurit']、[url=openwnd:宴席, AttributeDescription, '', false, 'WeddingTableFood']、[url=openwnd:派喜糖, AttributeDescription, '', false, 'WeddingCandy'][-]\n    完婚后，夫妻双方额外获得[aa62fc][url=openwnd:新郎·晚樱连理, ItemTips, 'Item', nil, 6156]、[url=openwnd:新娘·晚樱连理, ItemTips, 'Item', nil, 6157][-]、[ff578c][url=openwnd:新郎·红鸾揽月, ItemTips, 'Item', nil, 6158]、[url=openwnd:新娘·红鸾揽月, ItemTips, 'Item', nil, 6159][-]";
		tbTxtScrollViewReset = {20, 100};
		nRow = 5;
	};
}
function tbUi:OnOpen()
	Wedding:RequestSynSchedule()
end

function tbUi:OnOpenEnd(nWeddingLevel)
	self.nLevel = nWeddingLevel or Wedding.Level_1
	self:SwitchContainer(self.nLevel)
end

function tbUi:SwitchContainer(nLevel)
	nLevel = nLevel or self.nLevel
	for nWeddingLevel, v in pairs(self.tbSetting) do
		if nWeddingLevel == nLevel then
			self.nLevel = nWeddingLevel
			self:RefreshUi(nWeddingLevel)
		end
		local nNowLevel = (nLevel or self.nLevel)
		self.pPanel:Toggle_SetChecked(v.szBtnName, nWeddingLevel == nNowLevel)
	end
	self:RefreshTitle()
end

function tbUi:RefreshUi(nWeddingLevel)
	nWeddingLevel = nWeddingLevel or self.nLevel
	local tbUiSetting = self.tbSetting[nWeddingLevel]
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbUiSetting or not tbMapSetting then
		return
	end
	self.pPanel:SetActive("BtnApply", true)
	self.pPanel:Sprite_SetGray("BtnApply", false)
	self.pPanel:Label_SetText("ApplyTxt", "申请婚礼")
	self.pPanel:Button_SetEnabled("BtnApply", true)
	self.pPanel:Sprite_SetGray("BtnCheek", nWeddingLevel == Wedding.Level_1)
	self.pPanel:Button_SetEnabled("BtnCheek", nWeddingLevel ~= Wedding.Level_1)
	self.pPanel:SetActive("BtnCheek", nWeddingLevel ~= Wedding.Level_1)
	self.pPanel:Texture_SetTexture("Scene", tbMapSetting.szOrderUiTexturePath)
	self["Content"]:SetLinkText(string.format(tbUiSetting.szContent))
	self.pPanel:SetActive("ScrollView", true)
	local nWeddingCost = tbMapSetting.nCost
	self.pPanel:SetActive("Tip", false)
	local tbMySchedule = Wedding:GetMySchdule()
	local nMyBookTime
	if tbMySchedule and next(tbMySchedule) then
		local bDue, nBookLevel, tbPlayerBookInfo = self:CheckOverdue(nWeddingLevel, tbMySchedule)
		if bDue then
			self.pPanel:SetActive("Tip", true)
			if not tonumber(tbMapSetting.nCost) then
				self.pPanel:Label_SetText("Tip", "＊你的婚礼已逾期，需要缴纳一半的费用重新申请")
			else
				self.pPanel:Label_SetText("Tip", "＊你的婚礼已逾期，需要缴纳一半的费用重新申请")
			end
			nWeddingCost = tbMapSetting.nMissCost 				-- 过期差价
		else
			if not tbPlayerBookInfo.nOpenTime and nBookLevel == nWeddingLevel then
				self.pPanel:Sprite_SetGray("Main", true)
				self.pPanel:Label_SetText("ApplyTxt", "已预定")
				self.pPanel:Button_SetEnabled("BtnApply", false)
				nMyBookTime = tbPlayerBookInfo.nBookTime
			end
		end
	end
	for i=1,3 do
		self.pPanel:SetActive("Item" ..i, false)
	end
	self.pPanel:SetActive("CostSprite", false)
	self.pPanel:SetActive("Cost", false)
	if not tonumber(nWeddingCost) then
		local tbItem = Wedding:GetCostItemInfo(nWeddingCost)
		for i, tbItemInfo in ipairs(tbItem) do
			local szItemUi = "Item" ..i
			self.pPanel:SetActive(szItemUi, true)
			local nItemId = tbItemInfo[1]
			local nCount = tbItemInfo[2] 
			self[szItemUi]:SetGenericItem({"item", nItemId, nCount})
			self[szItemUi].fnClick = self[szItemUi].DefaultClick
			local nHave = me.GetItemCountInAllPos(nItemId)
			self[szItemUi].pPanel:Label_SetText("LabelSuffix", string.format("%d/%d", nHave, nCount));
			self[szItemUi].pPanel:SetActive("LabelSuffix", true)
		end
	else
		self.pPanel:SetActive("CostSprite", true)
		self.pPanel:SetActive("Cost", true)
		self.pPanel:Label_SetText("Cost", string.format("%d", nWeddingCost))
	end
	self.pPanel:SetActive("Time", false)
	self.pPanel:SetActive("TimeSelect", false)
	local nNowTime = GetTime()
	if nWeddingLevel == Wedding.Level_1 then
		self.pPanel:SetActive("FullTip", false)
		self.pPanel:SetActive("Time", true)
		self.pPanel:Label_SetText("Time", "婚礼时间：申请后立刻开始")
		self.nBookTime = nNowTime
	else
		if nMyBookTime then
			self.pPanel:SetActive("Time", true)
			self.pPanel:Label_SetText("Time", string.format("婚礼时间：%s", tbMapSetting.fnGetDateStr(nMyBookTime)))
		end
		self.nBookTime = nil
		self.pPanel:Label_SetText("SelectName", "选择日期")
		local tbCanBook = Wedding:GetCanBookSchdule(nWeddingLevel)
		local bCanBook = next(tbCanBook) and true or false
		local bShowFull = not bCanBook and not nMyBookTime
		self.pPanel:SetActive("TimeSelect", bCanBook and (not nMyBookTime))
		self.pPanel:SetActive("FullTip", bShowFull)
		self.pPanel:Label_SetText("FullTip", string.format("近期婚礼预约已满，请%s再来吧！", tbMapSetting.szFullDate or "晚点"))
		self.pPanel:SetActive("BtnApply", not bShowFull)
	end
	-- vip等级不够时处理
	if tbMapSetting.nNeedVip and me.GetVipLevel() < tbMapSetting.nNeedVip then
		self.pPanel:SetActive("FullTip", true)
		self.pPanel:Label_SetText("FullTip", string.format("[FFFE0D]提示：剑侠尊享%s才可预定该婚礼[-]", tbMapSetting.nNeedVip))
		self.pPanel:SetActive("BtnApply", false)
	end
	local tbShowAward = self:GetShowAward(tbMapSetting.tbShowAward)
	local fnSetItem = function(itemObj, nIdx)
		local tbAwardInfo = tbShowAward[nIdx]
		if tbAwardInfo then
			itemObj.pPanel:SetActive("Main", true)
			itemObj["itemframe"]:SetGenericItem(tbAwardInfo)
			itemObj["itemframe"].fnClick = itemObj["itemframe"].DefaultClick
		else
			itemObj.pPanel:SetActive("Main", false)
		end
	end
	self.ItemGroup:Update(#tbShowAward, fnSetItem);
	local nHeightSet, nWidthSet = unpack(tbUiSetting.tbTxtScrollViewReset)
	self.pPanel:ResizeScrollViewBound("ScrollView", -(tbUiSetting.nRow * nHeightSet), nWidthSet);
end

function tbUi:RefreshTitle()
	for nWeddingLevel, v in ipairs(self.tbSetting) do
		self.pPanel:SetActive("Mark" ..nWeddingLevel, false)
		local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
		if tbMapSetting then
			for i=1, 2 do
				self.pPanel:Label_SetText(string.format("Txt%d_%d", nWeddingLevel, i), tbMapSetting.szWeddingName)
			end
			if tbMapSetting.bBook then
				local tbMySchedule = Wedding:GetMySchdule()
				if tbMySchedule and next(tbMySchedule) and tbMySchedule.nBookLevel == nWeddingLevel and not tbMySchedule.tbPlayerBookInfo.nOpenTime then
					local szMarkText = "预定"
					local bDue = self:CheckOverdue(nWeddingLevel, tbMySchedule)
					if bDue then
						szMarkText = "逾期"
					end
					local szMark = "Mark" ..nWeddingLevel
					self.pPanel:SetActive(szMark, true)
					self.pPanel:Label_SetText(szMark, szMarkText)
				end
			end
		end
	end
end

function tbUi:GetShowAward(tbShowAward)
	local tbAward = {}
	for _, v in ipairs(tbShowAward) do
		if me.GetVipLevel() < v[1] then
			tbAward = v[2]
			break;
		else
			tbAward = v[2]
		end
	end
	return tbAward
end

function tbUi:CheckOverdue(nWeddingLevel, tbMySchedule)
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	local nOpen = tbMySchedule.nOpen
	local tbPlayerBookInfo = tbMySchedule.tbPlayerBookInfo
	local nBookLevel = tbMySchedule.nBookLevel
	local nNow = tbMapSetting.fnGetDate()
	if nBookLevel == nWeddingLevel and nNow > nOpen and not tbPlayerBookInfo.nOpenTime then
		return true, nBookLevel, tbPlayerBookInfo
	end
	return false, nBookLevel, tbPlayerBookInfo
end

function tbUi:OnSelectDateFinish(nBookTime)
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[self.nLevel]
	if tbMapSetting then
		self.nBookTime = nBookTime
		if nBookTime then
			self.pPanel:Label_SetText("SelectName", tbMapSetting.fnGetDateStr(self.nBookTime))
		else
			self.pPanel:Label_SetText("SelectName", "选择日期")
		end
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_WEDDING_SCHEDULE, self.SwitchContainer, self },
		{ UiNotify.emNOTIFY_WEDDING_DATE_SELECT_FINISH, self.OnSelectDateFinish, self },
	};

	return tbRegEvent;
end

function tbUi:TrySwitchContainer(nWeddingLevel)
	Ui:CloseWindow("WeddingDatePanel")
	self:SwitchContainer(nWeddingLevel)
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow("WeddingDatePanel")
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnTab1 = function (self)
		self:TrySwitchContainer(Wedding.Level_1)
	end;
	BtnTab2 = function (self)
		self:TrySwitchContainer(Wedding.Level_2)
	end;
	BtnTab3 = function (self)
		self:TrySwitchContainer(Wedding.Level_3)
	end;
	BtnCheek = function (self)
		if Ui:WindowVisible("WeddingDatePanel") == 1 then
			me.CenterMsg("请先选择日期")
			return
		end
		if self.nLevel ==  Wedding.Level_1 then
			return
		end
		Ui:OpenWindow("WeddingBookDetailPanel", self.nLevel)
	end;
	BtnApply = function (self)
		local tbMapSetting = Wedding.tbWeddingLevelMapSetting[self.nLevel]
		if not tbMapSetting then
			return
		end
		if not tbMapSetting.bBook then
			local nOpenDay = Wedding:GetStartOpen(tbMapSetting)
			if tbMapSetting.fnGetDate() ~= nOpenDay then
				me.CenterMsg("暂未开启")
				return
			end
			local bRet, szMsg = Wedding:CheckOpenTime()
			if not bRet then
				me.CenterMsg(szMsg)
				return
			end
		end
		if Ui:WindowVisible("WeddingDatePanel") == 1 then
			me.CenterMsg("请先选择日期")
			return
		end
		local nEngaged = Wedding:GetEngaged(me.dwID)
		if not nEngaged then
			me.CenterMsg("订婚关系的双方才能预定婚礼")
			return
		end
		if not self.nBookTime then
			me.CenterMsg("请先选择日期")
			return
		end
		if tbMapSetting.fnGetDate() > tbMapSetting.fnGetDate(self.nBookTime or 0) then
			me.CenterMsg("没有可预定的日期")
			return
		end
		
		local szBoxMsg
		local tbMySchedule = Wedding:GetMySchdule()
		if tbMySchedule and next(tbMySchedule) then
			local nOpen = tbMySchedule.nOpen
			local tbPlayerBookInfo = tbMySchedule.tbPlayerBookInfo
			local nBookLevel = tbMySchedule.nBookLevel
			local tbBookMapSetting = Wedding.tbWeddingLevelMapSetting[nBookLevel]
			local nNow = tbBookMapSetting.fnGetDate()
			-- 过期
			if nNow > nOpen and not tbPlayerBookInfo.nOpenTime then
				-- 预订过期档
				if self.nLevel ~= nBookLevel then
					szBoxMsg = string.format("你预定的婚礼[FFFE0D]%s[-]已逾期，可以补交一半的费用重新申请。[FF6464FF]若预定其他婚礼需缴纳全额费用，确定要继续预定[FFFE0D]%s[-]吗？[-]", tbBookMapSetting.szWeddingName, tbMapSetting.szWeddingName)
				end
			else
			-- 没过期
				if self.nLevel <= nBookLevel then
					me.CenterMsg(string.format("你当前已经预定了[FFFE0D]%s[-]，不能更换婚礼", tbBookMapSetting.szWeddingName))
					return
				else
					szBoxMsg = string.format("你当前已经预定了[FFFE0D]%s[-]，你确定要继续预定[FFFE0D]%s[-]吗？\n[FF6464FF]提示：已预定婚礼的费用不退还[-]", tbBookMapSetting.szWeddingName, tbMapSetting.szWeddingName)
				end
			end
		end
		local fnBook = function (self)
	        local szTip = "确定要现在举行[FFFE0D]庄园·晚樱连理[-]婚礼吗？\n[FFFE0D]提示：婚礼时长大约为25分钟[-]"
	        local szSure = "举行婚礼"
			if self.nLevel == Wedding.Level_2 or self.nLevel == Wedding.Level_3 then
				szTip = string.format("确定将婚期定在[FFFE0D]%s[-]吗？", Lib:TimeDesc11(self.nBookTime))
				szSure = "预定婚礼"
			end
			Timer:Register(1, function ()
	            me.MsgBox(szTip,
				{
					{szSure, function ()
							RemoteServer.OnWeddingRequest("TryBookWedding", self.nLevel, self.nBookTime);
					end};
					{"取消"};
				});
	        end)
	    end
		if szBoxMsg then
		    me.MsgBox(szBoxMsg, {{"确定预定", fnBook, self}, {"取消"}})
		else
			fnBook(self)
		end
	end;
	BtnSelect = function (self)
		if Ui:WindowVisible("MessageBox") == 1 then
			me.CenterMsg("请先完成当前操作")
			return
		end
		Ui:OpenWindow("WeddingDatePanel", self.nLevel)
	end;
}