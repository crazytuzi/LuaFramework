local tbUi = Ui:CreateClass("ChatEmotionLink");
local ChatEquipBQ = ChatMgr.ChatEquipBQ
local tbTab2Name = {
	["Item"]         = "ItemGroup",
	["Companion"]    = "CompanionGroup",
	["Emotion"]      = "EmotionGroup",
	["Achievement"]  = "AchievementGroup",
	["LabelEmotion"] = "LabelEmotionGroup",
	["HistoryMsg"]   = "HistoryMsgGroup",
	["ActionExpression"] = "LabelEmotionGroup";
	["PartnerCard"]    = "CompanionGroup",
}
tbUi.EmotionTab = 1
tbUi.LabelEmotionTab = 2
tbUi.ActionExpressionTab = 3
tbUi.HistoryMsgTab = 4
tbUi.ItemTab = 5
tbUi.CompanionTab = 6
tbUi.LocationTab = 7
tbUi.AchievementTab = 8
tbUi.BeautySelection = 9
tbUi.PartnerCard = 10
tbUi.tbTabSetting = 
{
	[tbUi.EmotionTab] = {
		szNormalSprite = "EmotionsChat";
		szLabel = "表情";
		szTab = "Emotion";
	};
	[tbUi.LabelEmotionTab] = {
		szNormalSprite = "LabelChat";
		szLabel = "文字表情";
		szTab = "LabelEmotion";
	};
	[tbUi.ActionExpressionTab] = {
		szNormalSprite = "ActionExpression";
		szLabel = "动作表情";
		szTab = "ActionExpression";
	};
	[tbUi.HistoryMsgTab] = {
		szNormalSprite = "HistoryMessageChat";
		szLabel = "输入历史";
		szTab = "HistoryMsg";
	};
	[tbUi.ItemTab] = {
		szNormalSprite = "PropChat";
		szLabel = "道具";
		szTab = "Item";
	};
	[tbUi.CompanionTab] = {
		szNormalSprite = "CompanionChat";
		szLabel = "同伴";
		szTab = "Companion";
	};
	[tbUi.LocationTab] = {
		szNormalSprite = "CoordinateChat";
		szLabel = "当前坐标";
		fnEnable = function (itemObj)
			local bWhiteTigerFuben = Fuben.WhiteTigerFuben:IsMyMap(me.nMapTemplateId)
			return not bWhiteTigerFuben
		end;
		fnTab = function(self)
			self:AddLocation();
		end;
	};
	[tbUi.AchievementTab] = {
		szNormalSprite = "AchievementChat";
		szLabel = "成就";
		szTab = "Achievement";
	};
	[tbUi.BeautySelection] = {
		szNormalSprite = "BeautyPropaganda";
		szLabel = "选美宣传";
		fnShow = function ()
			local bShow = false
			local bGoodVoiceRun = Activity.GoodVoice:IsInProcess()
			local tbAct = bGoodVoiceRun and Activity.GoodVoice or Activity.BeautyPageant
			local szTxt = bGoodVoiceRun and "好声音宣传" or "选美宣传"
			if tbAct:IsInProcess() and tbAct:IsSignUp() then
				bShow = true
			end
			return bShow
		end;
		fnEnable = function ()
			local bEnable = false
			local bGoodVoiceRun = Activity.GoodVoice:IsInProcess()
			local tbAct = bGoodVoiceRun and Activity.GoodVoice or Activity.BeautyPageant
			local szTxt = bGoodVoiceRun and "好声音宣传" or "选美宣传"
			if tbAct:IsInProcess() and tbAct:IsSignUp() then
				bEnable = true
			end
			return bEnable
		end;
		fnTab = function(self)
			self:BeautySelection()
		end;
	};
	[tbUi.PartnerCard] = {
		szNormalSprite = "GuestChat";
		szLabel = "门客";
		szTab = "PartnerCard";
		fnShow = function ()
			return PartnerCard:IsOpen()
		end;
	};
}

function tbUi:OnOpen(pInputField, szTab, bBottom, bShowGuide)
	self.pInputField = pInputField;
	self.szCurTab = szTab or self.szCurTab or "Emotion";
	self.bShowGuide = bShowGuide
	self.pPanel:ChangePosition("Main", 0, bBottom and -85 or -13);
end

function tbUi:GuideTip()
	self.pPanel:SetActive("NewActionEmotionsTip", (self.szCurTab =="ActionExpression" and self.bShowGuide) and true or false);
end

function tbUi:OnOpenEnd()
	self:UpdateTab()
	self:Switch(self.szCurTab);
	--self.pPanel:Toggle_SetChecked(self.szCurTab .. "Tab", true);
	--self:UpdateLocationTab()
	--self:UpdateBeautyTab()
end

function tbUi:UpdateTab()
	local tbTabList = self:GetShowTabList()
	local fnOnClick = function (itemObj)
		local szTab = itemObj.szTab
		local fnTab = itemObj.fnTab
		if fnTab then
			fnTab(self)
		elseif szTab then
			self:Switch(szTab)
		end
	end;
	local fnSetTab = function(itemObj, nLineIdx)
		for i=1, 3 do
			local nTabIdx = (nLineIdx - 1) * 3 + i
			local tbTabInfo = tbTabList[nTabIdx] or {}
			local szTabName = "Tab" ..i
			if next(tbTabInfo) then
				itemObj[szTabName].pPanel:Sprite_SetSprite("Icon", tbTabInfo.szNormalSprite)
				itemObj[szTabName].pPanel:Label_SetText("Txt", tbTabInfo.szLabel)
				local bEnable = true
				if tbTabInfo.fnEnable then
					bEnable = tbTabInfo.fnEnable()
				end
				itemObj[szTabName].pPanel:Button_SetEnabled("Main", bEnable)
				itemObj[szTabName].pPanel:SetActive("Main", true)
				itemObj[szTabName].pPanel:Toggle_SetChecked("Main", tbTabInfo.szTab == self.szCurTab and true or false)
			else
				itemObj[szTabName].pPanel:SetActive("Main", false)
			end
			itemObj[szTabName].szTab = tbTabInfo.szTab
			itemObj[szTabName].fnTab = tbTabInfo.fnTab
			itemObj[szTabName].pPanel.OnTouchEvent = fnOnClick;
		end
	end
	local nLine = math.ceil(#tbTabList / 3)
	self.ScrollViewTab:Update(nLine, fnSetTab)
end

function tbUi:GetShowTabList()
	local tbList = {}
	for _, v in ipairs(self.tbTabSetting) do
		if not v.fnShow or v.fnShow() then
			table.insert(tbList, v)
		end
	end
	return tbList
end

function tbUi:UpdateLocationTab()
	local bWhiteTigerFuben = Fuben.WhiteTigerFuben:IsMyMap(me.nMapTemplateId)
	self.pPanel:Button_SetEnabled("LocationTab", not bWhiteTigerFuben)
end

function tbUi:UpdateBeautyTab()
	local bEnable = false
	local bGoodVoiceRun = Activity.GoodVoice:IsInProcess()
	local tbAct = bGoodVoiceRun and Activity.GoodVoice or Activity.BeautyPageant
	local szTxt = bGoodVoiceRun and "好声音宣传" or "选美宣传"
	if tbAct:IsInProcess() and tbAct:IsSignUp() then
		bEnable = true
	end
	self.pPanel:SetActive("BeautySelection", bEnable)
	self.pPanel:Button_SetEnabled("BeautySelection", bEnable)
	self.pPanel:Label_SetText("BeautySelectionLabel", szTxt)
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	self.pInputField = nil;
	self.bShowGuide = nil
end

function tbUi:Switch(szTab)
	local szShowActiveName = "";
	for szKey, szName in pairs(tbTab2Name) do
		if szKey == szTab then
			szShowActiveName = szName;
			self.pPanel:SetActive(szName, true);
			self[szKey .. "Update"](self);
			self.szCurTab = szTab;
		else
			if szShowActiveName ~= szName then
				self.pPanel:SetActive(szName, false);
			end
		end
	end
	self:GuideTip(self.bShowGuide)
end

function tbUi:EmotionUpdate()
	local nEmotionMax = #ChatMgr.tbChatEmotionList; -- 当前最大表情数
	local nEmotionPerLine = 12; -- 每行表情数

	local fnSelectEmotion = function (emotionItem)
		self:AddEmotion(emotionItem.nIndex);
	end

	local fnSetItem = function (itemObj, nIndex)
		itemObj.nIndex = nIndex;
		for i = 1, nEmotionPerLine do
			local nEmotionIndex = (nIndex - 1) * nEmotionPerLine + i;
			local tbEmotionInfo = ChatMgr.tbChatEmotionList[nEmotionIndex];
			if tbEmotionInfo then
				-- 确认所有聊天表情都在同一图集上，故不传图集参数，传图集参数会因为异步加载导致显示问题
				itemObj.pPanel:Sprite_SetSprite("Item" .. i, tostring(tbEmotionInfo.EmotionId));
				itemObj.pPanel:Sprite_Animation("Item" .. i, tbEmotionInfo.EmotionId .. "-");
				itemObj["Item" .. i].nIndex = tbEmotionInfo.EmotionId;
				itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectEmotion;
			end
			itemObj.pPanel:SetActive("Item" .. i, tbEmotionInfo and true or false);
		end
	end

	self.EmotionScrollView:Update(math.ceil(nEmotionMax / nEmotionPerLine), fnSetItem);
end

--判断普通道具是否装备上，装备不需要走这里
tbUi.tbFunCheckEquip = {
	["JueYao"] = function (pItem)
		return pItem.GetIntValue(ZhenFa.JUEYAO_EQUIP_FLAG) == 1
	end
}

function tbUi:ItemUpdate()
	local tbItems = {};

	local tbEquip = me.GetEquips(1);
	for i = 0, Item.EQUIPPOS_NUM do
		if tbEquip[i] then
			table.insert(tbItems, {Id = tbEquip[i], bEquiped = true})
		end
	end

	local tbStoneMap = {}; -- 镶嵌在装备上的魂石也要可发送，需去重
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		local tbInset = me.GetInsetInfo(nEquipPos) or {};
		for i = 1, StoneMgr.INSET_COUNT_MAX do
			local nTemplateId = tbInset[i];
			if nTemplateId and nTemplateId ~= 0 and not tbStoneMap[nTemplateId] then
				tbStoneMap[nTemplateId] = true;
				table.insert(tbItems, {nTemplateId = nTemplateId, bEquiped = true});
			end
		end
	end

	local tbItemInBag = me.GetItemListInBag();
	table.sort(tbItemInBag, function (a, b)
		if a.nItemType == b.nItemType then
			if a.nDetailType == b.nDetailType then
				if a.GetSingleValue() == b.GetSingleValue() then
					return a.dwId < b.dwId;
				end
				return a.GetSingleValue() > b.GetSingleValue();
			end
			return a.nDetailType < b.nDetailType;
		end
		return a.nItemType < b.nItemType;
	end);

	for _, pItem in ipairs(tbItemInBag) do
		local bEquiped = false
		if self.tbFunCheckEquip[pItem.szClass] and self.tbFunCheckEquip[pItem.szClass](pItem) then
			bEquiped = true
		end
		table.insert(tbItems, {Id = pItem.dwId, bEquiped = bEquiped})
	end

	local fnSelectItem = function (itemObj)
		self:AddItem(itemObj.Id or 0, itemObj.nTemplateId or 0);
	end

	local fnSetItem = function (itemObj, nRow)
		for i = 1, 8 do
			local nIndex = (nRow - 1) * 8 + i;
			local item = tbItems[nIndex];
			itemObj.pPanel:SetActive("item" .. i, item and true or false);
			if item then
				if item.Id then
					itemObj["item" .. i]:SetItem(item.Id);
					itemObj["item" .. i].Id = item.Id;
					itemObj["item" .. i].nTemplateId = nil;
				else
					itemObj["item" .. i]:SetItemByTemplate(item.nTemplateId);
					itemObj["item" .. i].nTemplateId = item.nTemplateId;
					itemObj["item" .. i].Id = nil;
				end
				itemObj["item" .. i].fnClick = fnSelectItem;
				itemObj["item" .. i].pPanel:SetActive("TagTip", item.bEquiped);
				if item.bEquiped then
					itemObj["item" .. i].pPanel:Sprite_SetSprite("TagTip", "itemtag_yizhuangbei");
				end
			end
		end
	end

	self.ItemScrollView:Update(math.ceil(#tbItems / 8), fnSetItem)
end

function tbUi:PartnerCardUpdate()
	local fnSelectPartner = function (partnerObj)
		self:AddPartnerCard(partnerObj.tbCardInfo);
	end
	local tbCard = PartnerCard:GetSortOwnPartnerCard()
	local fnSetItem = function (itemObj, nIndex)
		for i = 1, 3 do
			local tbCardInfo = tbCard[3 * (nIndex - 1) + i];
			itemObj.pPanel:SetActive("Item" ..i, tbCardInfo and true or false);
			if tbCardInfo then
				itemObj["Item" ..i]:Init(tbCardInfo);
				itemObj["Item" ..i].tbCardInfo = tbCardInfo;
				itemObj["Item" ..i].pPanel.OnTouchEvent = fnSelectPartner;
			end
		end
	end
	self.PartnerScrollView:Update(math.ceil(#tbCard / 3), fnSetItem);
end

function tbUi:CompanionUpdate()
	local tbPartners = me.GetAllPartner();
	local tbItems = {};
	for nId, tbItem in pairs(tbPartners) do
		tbItem.nId = nId;
		table.insert(tbItems, tbItem);
	end

	table.sort(tbItems, function(a, b)
		if a.nQualityLevel == b.nQualityLevel then
			return a.nFightPower > b.nFightPower;
		else
			return a.nQualityLevel < b.nQualityLevel;
		end
	end);

	local fnSelectPartner = function (partnerObj)
		self:AddPartner(partnerObj.tbPartner);
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbItem1 = tbItems[3 * nIndex - 2];
		local tbItem2 = tbItems[3 * nIndex - 1];
		local tbItem3 = tbItems[3 * nIndex];

		itemObj.pPanel:SetActive("Item1", tbItem1 and true or false);
		itemObj.pPanel:SetActive("Item2", tbItem2 and true or false);
		itemObj.pPanel:SetActive("Item3", tbItem3 and true or false);

		if tbItem1 then
			itemObj.Item1:Init(tbItem1);
			itemObj.Item1.tbPartner = tbItem1;
			itemObj.Item1.pPanel.OnTouchEvent = fnSelectPartner;
		end

		if tbItem2 then
			itemObj.Item2:Init(tbItem2);
			itemObj.Item2.tbPartner = tbItem2;
			itemObj.Item2.pPanel.OnTouchEvent = fnSelectPartner;
		end

		if tbItem3 then
			itemObj.Item3:Init(tbItem3);
			itemObj.Item3.tbPartner = tbItem3;
			itemObj.Item3.pPanel.OnTouchEvent = fnSelectPartner;
		end
	end

	self.PartnerScrollView:Update(math.ceil(#tbItems / 3), fnSetItem);
end

function tbUi:AchievementUpdate()
	self.AchievementGroup:OnOpenByParent(self)
end

local tbQuickChatMsg = LoadTabFile("Setting/Chat/QuickChatMsg.tab", "ss", nil, {"Title", "Content"});

function tbUi:LabelEmotionUpdate()
	local tbItems = tbQuickChatMsg;

	local fnSelectItem = function (btnObj)
		local szMsg = btnObj.tbItem.Content;
		szMsg = string.gsub(szMsg, "$M", me.szName) or szMsg;
		self:AddMsg(szMsg);
	end

	local fnSetItem = function (itemObj, nIndex)
		for i = 1, 3 do
			local tbItem = tbItems[(nIndex - 1) * 3 + i];
			itemObj.pPanel:SetActive("Item"..i, tbItem and true or false);
			if tbItem then
				itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, tbItem.Title);
				itemObj["Item" .. i].pPanel:SetActive(string.format("texiao (%d)", i), false);
				itemObj["Item" .. i].tbItem = tbItem;
				itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem;
			end
		end
	end
	self.LabelScrollView:Update(math.ceil(#tbItems / 3), fnSetItem);
end

function tbUi:ActionExpressionUpdate()
	local tbAllItem = {};
	local pNpc = me.GetNpc();
	local tbBQActionType = ChatMgr:GetActionBQType(pNpc.nShapeShiftNpcTID);
	for _, tbInfo in pairs(tbBQActionType) do
		if tbInfo.ChatID > 0 then
			table.insert(tbAllItem, tbInfo);
		end
	end

	local tbEquipBQ = ChatEquipBQ:GetAllEquipBQ(me)
	for _, nBQId in ipairs(tbEquipBQ) do
		local tbInfo = ChatMgr:GetActionBQInfo(ChatEquipBQ.nNpcType, nBQId)
		if tbInfo then
			table.insert(tbAllItem, tbInfo)
		end
	end
	table.sort(tbAllItem, function (a, b)
		local nARate, nBRate = 0, 0
		if a.nNpcType and a.nNpcType == ChatEquipBQ.nNpcType then
			nARate = nARate + 1000
		end
		if b.nNpcType and b.nNpcType == ChatEquipBQ.nNpcType then
			nBRate = nBRate + 1000
		end
		nARate = nARate + a.Sort
		nBRate = nBRate + b.Sort
	    return nARate > nBRate;
	end);
	local fnSelectItem = function (btnObj)
		if InDifferBattle.bRegistNotofy then
			me.CenterMsg("当前暂不可用")
			return
		end

		if not btnObj.tbItem then
			me.CenterMsg("操作错误！", true);
			return;
		end
		-- 检查主题是否过期
		Lib:CallBack({ChatMgr.ChatDecorate.TryCheckValid,ChatMgr.ChatDecorate});
		RemoteServer.SendChatBQ(btnObj.tbItem.ChatID, btnObj.tbItem.nNpcType);
		Ui:CloseWindow("ChatEmotionLink");
		Ui:CloseWindow("ChatLargePanel");

	end

	local fnSetItem = function (itemObj, nIndex)
		for i = 1, 3 do
			local tbItem = tbAllItem[(nIndex - 1) * 3 + i];
			itemObj.pPanel:SetActive("Item"..i, tbItem and true or false);
			if tbItem then
				itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, tbItem.Name);
				local bShowActionEffect = false
				if self.bShowGuide and tbItem.nNpcType == ChatEquipBQ.nNpcType then
					bShowActionEffect = true
				end
				itemObj["Item" .. i].pPanel:SetActive(string.format("texiao (%d)", i), bShowActionEffect);
				itemObj["Item" .. i].tbItem = tbItem;
				itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem;
			end
		end
	end
	self.LabelScrollView:Update(math.ceil(#tbAllItem / 3), fnSetItem);
end

function tbUi:HistoryMsgUpdate()
	local tbItems = ChatMgr:GetRecentMsgs();

	local fnSelectItem = function (btnObj)
		self:AddMsg(btnObj.szMsg);
		ChatMgr:SetChatLink(btnObj.nLinkType, btnObj.linkParam);
	end

	local fnSetItem = function (itemObj, nIndex)
		for i = 1, 3 do
			local tbItem = tbItems[(nIndex - 1) * 3 + i];
			-- 兼容历史数据用
			if type(tbItem) ~= "table" then
				tbItem = {tbItem};
			end

			local szMsg, nLinkType, linkParam = unpack(tbItem);
			itemObj.pPanel:SetActive("Item"..i, szMsg and true or false);
			if szMsg then
				itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, ChatMgr:CutMsg(szMsg, 11));
				itemObj["Item" .. i].szMsg = szMsg;
				itemObj["Item" .. i].nLinkType = nLinkType or 0;
				itemObj["Item" .. i].linkParam = linkParam or 0;
				itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem;
			end
		end
	end
	self.HistoryMsgScrollView:Update(math.ceil(#tbItems / 3), fnSetItem);
	self.HistoryMsgScrollView:GoTop();
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

-- for szKey, _ in pairs(tbTab2Name) do
-- 	tbUi.tbOnClick[szKey .. "Tab"] = function (self)
-- 		self:Switch(szKey);
-- 	end
-- end

-- function tbUi.tbOnClick:LocationTab()
-- 	self:AddLocation();
-- end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("ChatEmotionLink");
end

function tbUi:BeautySelection()
	local tbAct = Activity.BeautyPageant
	if Activity.GoodVoice:IsInProcess() then
		tbAct = Activity.GoodVoice
	end
	local nChannelId = self.pInputField.pChatLarge.nChannelId

	local bFriend = nChannelId == ChatMgr.nChannelFriendName

	local nType = tbAct.MSG_CHANNEL_TYPE.NORMAL
	local nParam = nChannelId

	if bFriend then
		nType = tbAct.MSG_CHANNEL_TYPE.PRIVATE
		nParam = self.pInputField.pChatLarge.nNowChatFriendId
	elseif nChannelId >= ChatMgr.nDynChannelBegin then
		nType = tbAct.MSG_CHANNEL_TYPE.FACTION
	end

	tbAct:SendMsg(nType, nParam)

	self.pInputField:UpdateCdExpression();
	if bFriend then
		self.pInputField.pChatLarge:UpdateChatList()
	end
end

function tbUi:AddEmotion(nEmotionIdx)
	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local szEmotion = string.format("#%d", nEmotionIdx);
	szMsg = szMsg .. szEmotion;
	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end
	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
end

function tbUi:AddLocation()
	local nMapId, nPosX, nPosY = Decoration:GetPlayerSettingOrgPos(me);
	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local nMapTemplateId = me.nMapTemplateId
	local szMapName = Map:GetMapDescInChat(nMapTemplateId)
	--秦始皇陵特殊处理
	if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or
	 ImperialTomb:IsBossMapByTemplate(nMapTemplateId) or
	 ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or
	 ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then

	 	local nTmpMapId

	 	nMapTemplateId, nTmpMapId, nPosX, nPosY = ImperialTomb:GetCurRoomEnterPos();
	 	nMapId = nMapTemplateId
	 	szMapName = Map:GetMapDescInChat(nMapTemplateId)

	 	if ImperialTomb.szBossName and ImperialTomb.szBossName~="" then
	 		szMapName = string.format("%s-%s", szMapName, ImperialTomb.szBossName)
	 	end
	end

	if House.nHouseMapId and me.nMapId == House.nHouseMapId then
		szMapName = string.format("%s的家", House.szName);
	end

	local szLocaltion = string.format("<%s(%d,%d)>", szMapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale);

	if BossLeader:IsBossLeaderMap(me.nMapTemplateId, "Boss") then
		local tbNpcList = KNpc.GetNpcListInCurrentMap();
		for _, pNpc in pairs(tbNpcList or {}) do
			if pNpc.szName == "项羽" and not pNpc.GetPlayer() then
				szLocaltion = szLocaltion .. "项羽已现身#70";
				break;
			end
		end
	end

	szMsg = szLocaltion .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2");

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end

	-- 家族地图可跳转的特别处理
	if nMapTemplateId == Kin.Def.nKinMapTemplateId then
		nMapId = Kin.Def.nKinMapTemplateId;
	end

	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapId, nPosX, nPosY, nMapTemplateId});
end

function tbUi:AddPartner(tbPartner)
	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local szPartner = string.format("<%s>", tbPartner.szName);
	szMsg = szPartner .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2");

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end

	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Partner, tbPartner.nId);
end

function tbUi:AddPartnerCard(tbCard)
	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local szPartner = string.format("<%s>", tbCard.szName);
	szMsg = szPartner .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2");

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end
	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
	ChatMgr:SetChatLink(ChatMgr.LinkType.PartnerCard, {nCardId = tbCard.nCardId});
end

function tbUi:AddMsg(szMsg)
	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
end

function tbUi:AddAchievement(szKind, nLevel)
	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local szName = Achievement:GetTitleAndDesc(szKind, nLevel);
	local szName = string.format("成就：%s", szName);
	local szAchievement = string.format("<%s>", szName);
	szMsg = szAchievement .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2");

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end

	self.pInputField.pPanel:Input_SetText("InputField", szMsg);

	local nId = Achievement:GetIdByKind(szKind);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Achievement, nId * 100 + nLevel);
end

function tbUi:AddItem(nId, nTemplateId)
	local szName = "";
	local itemObj = KItem.GetItemObj(nId);
	if itemObj then
		szName = itemObj.GetItemShowInfo();
	else
		szName = Item:GetItemTemplateShowInfo(nTemplateId, me.nFaction, me.nSex);
	end
	if Lib:IsEmptyStr(szName) then
		return;
	end

	local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or "";
	local szItem = string.format("<%s>", szName);
	szMsg = szItem .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2");

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("输入的内容超出上限");
		return;
	end

	self.pInputField.pPanel:Input_SetText("InputField", szMsg);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Item, {nId, nTemplateId});
end

local tbPartnerItem = Ui:CreateClass("ChatPartnerItem");

function tbPartnerItem:Init(tbItem)
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%s级", tbItem.nLevel));
	else
		self.pPanel:Label_SetText("Level", "Lv." ..tbItem.nLevel);
	end

	self.pPanel:Label_SetText("PartnerName", tbItem.szName);
	self.pPanel:SetActive("Level", tbItem.nId and true or false)
	self.pPanel:SetActive("Star", not tbItem.nId and true or false)
	if tbItem.nId then
		self.Face:SetPlayerPartnerWhithoutLevel(tbItem.nId)
	else
		local nQualityLevel = PartnerCard:GetQualityByCardId(tbItem.nCardId)
		self.Face:SetPartnerFace(tbItem.nNpcTemplateId, nil, nil, tbItem.nFightPower, true)
		self.Face.pPanel:SetActive("GrowthLevel", false);
		Ui:GetClass("PartnerCardItem"):SetLevel(self, tbItem.nLevel)
	end
	
end
