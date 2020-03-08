local tbUi = Ui:CreateClass("GiftSystem");

local tbAct = Activity.WomanAct

local emPLAYER_STATE_NORMAL = 2 --正常在线状态
local nNumPerRow = 7;
tbUi.nDelayCountTime = 1 	 -- 延迟递增的时间（秒）
tbUi.nCountAddInterval = 3 	 -- 增加数量间隔时间（帧数）

tbUi.HideUI =
{
	["BtnGive"] = true,
	["Txt1"] = true,
	["Txt2"] = true,
	["ScrollViewItem"] = true,
	["Number"] = true,
	["ScrollViewHead"] = true,
}

tbUi.tbSetting = 
{
	["PartnerCard"] = {
		fnOnOpen = function (self, nCardId)
			PartnerCard:RequestCardGiftData()
			self:UpdatePartnerCard(nCardId)
		end;
		szNoFriendTip = "没有可赠送的门客";
		szSelectFriendTip = "请选择要赠送的门客...";
		bNotShowVipTip = true;
		szAddImility = "[92D2FF]与[FFFE0D]%s[-]友好度增加：[-]%d";
		szChoseResetTip = "[92D2FF]今日已赠送礼物数[-]";
		szChoseTip = "[92D2FF]已赠送礼物数量[-]";
		fnGetAllGift = function (self)
			return PartnerCard:GetAllCanSendGift(me, self.nCurDwId)
		end;
		fnMaxSendTimes = function (self)
			return PartnerCard:GetMaxSendTimes()
		end;
		fnRemainSendTimes = function (self)
			return PartnerCard:GetCardRemainTimes(self.nCurDwId)
		end;
		fnGetAddImitity = function (self, nItemId)
			return PartnerCard:GetItemAddExp(nItemId)
		end;
		fnGetIsReset = function (self)
			return PartnerCard.bGiftTimesReset
		end;
		fnBtnSend = function (self, nCardId, nItemId, nCount)
			PartnerCard:SendGift(nCardId, nItemId, nCount)
		end;
		fnBtnHelp = function ()
			Ui:OpenWindow("GeneralHelpPanel", "PartnerCardGiftHelp")
		end;
	};
}

function tbUi:OnOpen(nFriendDwId, tbItemInfo, szKey)
	self.szKey = szKey
	self.tbKeySetting = self.tbSetting[szKey]
	if self.tbKeySetting and self.tbKeySetting.fnOnOpen then
		self.tbKeySetting.fnOnOpen(self, nFriendDwId)
	else
		Gift:UpdateGiftData();
		self:UpdateAllFriendData(nFriendDwId,tbItemInfo);
	end
end

function tbUi:OnOpenEnd()
	self.pPanel:Label_SetText("NoFriends", "没有可赠送的好友")
	self.pPanel:Label_SetText("SelectFriends", "请选择要赠送的好友...")
	self.pPanel:SetActive("Tip02", true)
	self.pPanel:SetActive("Tip01", true)
	self.pPanel:SetActive("NoGoods", false)
	if self.tbKeySetting and self.tbKeySetting.bNotShowVipTip then
		self.pPanel:SetActive("Tip02", false)
		self.pPanel:SetActive("Tip01", false)
	end
	if self.tbKeySetting and self.tbKeySetting.szNoFriendTip then
		self.pPanel:Label_SetText("NoFriends", self.tbKeySetting.szNoFriendTip)
	end
	if self.tbKeySetting and self.tbKeySetting.szSelectFriendTip then
		self.pPanel:Label_SetText("SelectFriends", self.tbKeySetting.szSelectFriendTip)
	end
	if not self.tbAllFriend or not next(self.tbAllFriend) then
		for szUiName,_ in pairs(self.HideUI) do
			self.pPanel:SetActive(szUiName,false);
		end
		self.pPanel:SetActive("NoFriends",true)
		self.pPanel:SetActive("SelectFriends",true)
		self:UpdateVipPrivilegeDesc()
		return ;
	else
		for szUiName,_ in pairs(self.HideUI) do
			self.pPanel:SetActive(szUiName,true);
		end
		self.pPanel:SetActive("NoFriends",false)
		self.pPanel:SetActive("SelectFriends",false)
	end
	self:InitBaseData();
	self:UpdateFriendList(true);
	self:UpdateGiftList();
	self:UpdateBottomInfo();
	self:UpdateVipPrivilegeDesc()
end

function tbUi:RefreshUi()
	self:UpdateFriendList();
	self:UpdateGiftList();
	self:UpdateBottomInfo();
end

function tbUi:UpdateVipPrivilegeDesc()
	local szDesc = Recharge:GetVipPrivilegeDesc("WaiYi") or ""
	self.pPanel:Label_SetText("Tip02", szDesc)
	szDesc = Recharge:GetVipPrivilegeDesc("FriendImity") or ""
	self.pPanel:Label_SetText("Tip01", szDesc)
end

function tbUi:InitBaseData()
	self.nCurDwId = self.tbAllFriend[1].dwID;
	self.nFaction = self.tbAllFriend[1].nFaction;
	self.szName = self.tbAllFriend[1].szName;
	self.nSex = Player:Faction2Sex(self.nFaction, self.tbAllFriend[1].nSex);
	self.nGiftType = 1;
	self.nSend = 0;
	self.nCurItemId = 0;
end

function tbUi:IsOnline(nIdx)
	local tbRoleInfo = self.tbAllFriend[nIdx]
	return tbRoleInfo.nState ~= Player.emPLAYER_STATE_NONE
end

-- 更新好友
function tbUi:UpdateFriendList(bIsGoTop)

	local fnOnClick = function(itemObj)
		self.bOnline = itemObj.bOnline
		self.nCurDwId = itemObj.dwID;
		self.nFaction = itemObj.nFaction;
		self.szName = itemObj.szName;
		self.nSex = itemObj.nSex;
		self.nGiftType = 1;
		self.nSend = 0;
		self.nLevel = itemObj.nLevel;
		self:UpdateGiftList();
		self:UpdateBottomInfo();
	end

	local fnSetItem = function(itemObj,nIdx)
		local tbRoleInfo = self.tbAllFriend[nIdx];
		local szName = tbRoleInfo.szName or self.tbAllFriend[nIdx].szWantedName;
		local nLevel = tbRoleInfo.nLevel;

		itemObj.pPanel:Label_SetText("Label", szName);
		itemObj.pPanel:Label_SetText("lbLevel", nLevel);
		itemObj.pPanel:SetActive("lbLevel", false)
		itemObj.pPanel:SetActive("Star", false)
		if not tbRoleInfo.nFaction or tbRoleInfo.nFaction <= 0 then
			itemObj.pPanel:SetActive("SpFaction", false)
		else
			itemObj.pPanel:SetActive("SpFaction", true)
			local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
			itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
		end
		local bOnline = true
		if tbRoleInfo.nPartnerTempleteId then
			local szName, nQualityLevel, nNpcTemplateId = GetOnePartnerBaseInfo(tbRoleInfo.nPartnerTempleteId);
			local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
			local szAtlas, szSprite = Npc:GetFace(nFaceId);
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);
			itemObj.pPanel:SetActive("Star", true)
			Ui:CreateClass("PartnerCardItem"):SetLevel(itemObj, nLevel)
		else
			local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
			bOnline = self:IsOnline(nIdx)
			if bOnline then
				itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
			else
				itemObj.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
			end
			itemObj.pPanel:SetActive("lbLevel", true)
		end
		itemObj.pPanel:Button_SetSprite("Main", bOnline and "BtnListThirdNormal" or "BtnListThirdDisabled", 1)
		
		itemObj.bOnline = bOnline
		itemObj.dwID = tbRoleInfo.dwID;
		itemObj.nFaction = tbRoleInfo.nFaction;
		itemObj.szName = szName;
		itemObj.nSex = Player:Faction2Sex(tbRoleInfo.nFaction, tbRoleInfo.nSex);
		itemObj.nLevel = nLevel;
		itemObj.pPanel.OnTouchEvent = fnOnClick;

		itemObj.pPanel:Toggle_SetChecked("Main", false);

		if self.nCurDwId == tbRoleInfo.dwID then
			itemObj.pPanel:Toggle_SetChecked("Main", true);
			fnOnClick(itemObj);
		end
	end
	self.ScrollViewHead:Update(#self.tbAllFriend,fnSetItem);
	if bIsGoTop then
		self.ScrollViewHead:GoTop();
	end
end

--更新礼物
function tbUi:UpdateGiftList()
	self:CloseCountTimer()
	if self.tbKeySetting and self.tbKeySetting.fnGetAllGift then
		self.tbAllGift = self.tbKeySetting.fnGetAllGift(self)
	else
		self.tbAllGift = Gift:GetAllCanSendGift(self.nFaction,self.nCurDwId, self.bOnline, self.nLevel, self.nSex);
	end
	
	local bHadFriend = (self.tbAllFriend and next(self.tbAllFriend)) and true or false

	if not self.tbAllGift or not next(self.tbAllGift) and bHadFriend then 									-- 没有可赠送礼物的处理
		self.pPanel:SetActive("NoGoods",true)
 		self.tbAllGift = {}
 	else
 		self.pPanel:SetActive("NoGoods",false)
	end

	self.nCurItemId = self.tbAllGift[1] and self.tbAllGift[1].nItemId or 0							-- 当前默认选中第一个物品

	if not bHadFriend then
		return
	end

	local fnSetItem = function(itemObj,nIdx)
		local nCur = (nIdx - 1) * nNumPerRow + 1;
		local nStep = nCur + nNumPerRow - 1;
		local tbRowList = self:UpdateRowInfo(nCur,nStep);
		self:SetItem(itemObj, nIdx, tbRowList);
	end

	local nRow = math.ceil(#self.tbAllGift/nNumPerRow)

	self.ScrollViewItem:Update(nRow,fnSetItem);
	-- if next(self.tbAllGift) then
	-- 	self:Select(self.ScrollViewItem.Grid["Item0"]["item1"],1)               -- 选中道具的第一个
	-- end
end

function tbUi:UpdateRowInfo(nCur,nStep)
	local tbRowList = {};
	for index = nCur,nStep do
		if self.tbAllGift[index] then
			table.insert(tbRowList,self.tbAllGift[index]);
		end
	end
	return tbRowList;
end

-- 隐藏所有的选择特效，选中当前点击
function tbUi:Select(itemObj,nRemainSend)
	for i=0,100 do
		local pObj = self.ScrollViewItem.Grid["Item" ..i]
		if not pObj then
			break
		end
		for j=1,100 do
			local cObj = pObj["item" ..j]
			if not cObj then
				break;
			end
			cObj.pPanel:SetActive("Select",false)
		end
	end
	itemObj.pPanel:SetActive("Select", nRemainSend > 0);
end

-- 清掉之前的操作信息,决定是否可以批量送（想批量送则不清）
function tbUi:ClearObj()
	for i=0,100 do
		local pObj = self.ScrollViewItem.Grid["Item" ..i]
		if not pObj then
			break
		end
		for j=1,100 do
			local cObj = pObj["item" ..j]
			if not cObj then
				break;
			end
			if cObj.nSend and cObj.nHave then
				cObj.nSend = 0
				local nSend = cObj.nSend
				local nHave = cObj.nHave
				local szCount = nSend < 1 and string.format("%d",nHave) or string.format("%d/%d",nSend,nHave);
				cObj.pPanel:Label_SetText("LabelSuffix", szCount);
				cObj.pPanel:SetActive("LabelSuffix",cObj.nHave > 0)
				cObj["MinusSign"].pPanel:SetActive("Main",nSend > 0)
			end
		end
	end
end

function tbUi:GetRemainTimes(dwID, nGiftType, nItemId)
	local nRemainSend = 0
	if self.tbKeySetting and self.tbKeySetting.fnRemainSendTimes then
		nRemainSend = self.tbKeySetting.fnRemainSendTimes(self, dwID)
	else
		nRemainSend = Gift:RemainTimes(self.nCurDwId, nGiftType, nItemId)
	end
	return nRemainSend
end

function tbUi:GetMaxSend(nGiftType, nItemId)
	local nMaxSend = 0
	if self.tbKeySetting and self.tbKeySetting.fnMaxSendTimes then
		nMaxSend = self.tbKeySetting.fnMaxSendTimes(self)
	else
		nMaxSend = Gift:MaxTimes(nGiftType, nItemId) or 0;
	end
	return nMaxSend
end

function tbUi:SetItem(itemObj, index, tbRowList)
	local function fnClickMinus(itemObj)
		local parentObj = itemObj.parentObj
		if self.nCurItemId ~= parentObj.nItemId then
			self:ClearObj()
		end
		self.nCurItemId = parentObj.nItemId;
		self.nGiftType = parentObj.nGiftType;

		local nHave = parentObj.nHave;
		if nHave <= 0 then
			return ;
		end
		local nSend = parentObj.nSend;
		nSend = nSend - 1;
		nSend = nSend < 1 and 0 or nSend;
		parentObj.nSend = nSend;
		self.nSend = nSend;
		self:Select(itemObj.parentObj,nSend);
		local szCount = nSend < 1 and string.format("%d",nHave) or string.format("%d/%d",nSend,nHave);
		parentObj.pPanel:Label_SetText("LabelSuffix", szCount);

		itemObj.pPanel:SetActive("Main",nSend > 0)
		parentObj.pPanel:SetActive("Select",nSend > 0)
		self:UpdateBottomInfo(true);
	end

	for i,tbInfo in ipairs(tbRowList) do
		if tbInfo then
			local nItemId = tbInfo.nItemId;
			itemObj["item" .. i].nItemId = nItemId;
			itemObj["item" .. i].nGiftType = tbInfo.nGiftType;
			itemObj["item" .. i].nHave = me.GetItemCountInAllPos(nItemId);
			itemObj["item" .. i].nSend = 0;
			local nHave = itemObj["item" .. i].nHave
			local nSend = itemObj["item" .. i].nSend
			local szCount = nSend < 1 and string.format("%d",nHave) or string.format("%d/%d",nSend,nHave);
			itemObj["item" .. i].pPanel:Label_SetText("LabelSuffix", szCount);
			itemObj["item" .. i].pPanel:SetActive("LabelSuffix",itemObj["item" .. i].nHave > 0)
			itemObj["item" .. i]["MinusSign"].parentObj = itemObj["item" .. i];
			itemObj["item" .. i]["MinusSign"].pPanel.OnTouchEvent = fnClickMinus;
			itemObj["item" .. i]["MinusSign"].pPanel:SetActive("Main",itemObj["item" .. i].nSend > 0)
			local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nItemId, self.nFaction or me.nFaction, self.nSex or 0)
  	       	local szIconAtlas, szIconSprite, szExtAtlas, szExtSprite = Item:GetIcon(nIcon);
  	       	itemObj["item" .. i].pPanel:SetActive("Fragment", false)
  	       	if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
  	       		itemObj["item" .. i].pPanel:Sprite_SetSprite("Fragment", szExtSprite, szExtAtlas);
  	 			itemObj["item" .. i].pPanel:SetActive("Fragment", true)
  	       	end
  	       	itemObj["item" .. i].pPanel:Sprite_SetSprite("ItemLayer", szIconSprite,szIconAtlas);
  	       	
  	       	itemObj["item" .. i].pPanel:SetActive("ItemLayer",true)
  	       	itemObj["item" .. i].pPanel:SetActive("Select", false);
  	       	local _, szIcon = Item:GetQualityColor(nQuality)
    		itemObj["item" .. i].pPanel:Sprite_SetSprite("Color", szIcon);
    		itemObj["item" .. i].pPanel:SetActive("Main",true)
    		local nFragNum = Compose.EntityCompose.tbShowFragTemplates[nItemId]
    		if nFragNum then
    			local szAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab";
				local szSprite = "itemfragmnet";
				itemObj["item" .. i].pPanel:Sprite_SetSprite("Fragment", szSprite, szAtlas);
				itemObj["item" .. i].pPanel:SetActive("Fragment", true)
			end
			itemObj["item" .. i].fnPress = function (itemObj, szBtnName, bIsPress) 
				self:CloseCountTimer() 
				if not bIsPress then
					self.bExpTip = nil
					itemObj.bRemainTip = nil
					Item:ShowItemDetail({nTemplate=itemObj.nItemId, nFaction=self.nFaction, nSex = self.nSex, bForceTips = true}, {x=370, y=-1})
					return
				end
				itemObj.nSend = self.nSend
				self:UpdateObjCount(itemObj)
				self:TryStartCountTimer(itemObj)

			end;
		end
	end
	self:CheckObj(itemObj,tbRowList);
end

function tbUi:StartCountTimer(itemObj)
	self.bExpTip = false
	self.nDelayCountTimer = nil
	self.nStartCountTimer = Timer:Register(self.nCountAddInterval, function () 
		--itemObj.nSend = itemObj.nSend + 1
		local bRet = self:UpdateObjCount(itemObj)
		if not bRet then
			self.nStartCountTimer = nil
			self.bExpTip = nil
			return false
		end
		return true
	end)
end

function tbUi:TryStartCountTimer(itemObj)
	self.nDelayCountTimer = Timer:Register(Env.GAME_FPS * self.nDelayCountTime, self.StartCountTimer, self, itemObj)
end

function tbUi:UpdateObjCount(itemObj)
	local bPartnerCard = self.szKey == "PartnerCard"
	if self.nCurItemId ~= itemObj.nItemId then
		self:ClearObj()
	end
	self.nCurItemId = itemObj.nItemId;
	self.nGiftType = itemObj.nGiftType;
	local nMaxSend = self:GetMaxSend(self.nGiftType, self.nCurItemId)
	local nHave = itemObj.nHave;
	if nHave <= 0 then
		return ;
	end
	local nSend = itemObj.nSend;
	nSend = nSend + 1;
	if bPartnerCard then
		local nCardId = self.nCurDwId
		local nItemId = self.nCurItemId
		local nItemAddExp = PartnerCard:GetItemAddExp(nItemId)
		local bCanSend, szMsg = PartnerCard:CheckCanSendExp(me, nCardId, nItemId, nSend, nItemAddExp)
		if not bCanSend then
			nSend = nSend - 1
			if not self.bExpTip then
				self.bExpTip = true
				me.CenterMsg(szMsg, true)
			end
		end
	end
	nSend = nSend > nHave and nHave or nSend;

	local nRemainSend = self:GetRemainTimes(self.nCurDwId, self.nGiftType, self.nCurItemId)

	-- 次数不足
	if (nRemainSend <= 0 or nSend > nRemainSend) and nMaxSend ~= Gift.Times.Forever then
		if not itemObj.bRemainTip then
			me.CenterMsg("剩余赠送次数不足");
		end
		itemObj.bRemainTip = true
	end

	if nMaxSend ~= Gift.Times.Forever then
		nSend = nRemainSend < nSend and nRemainSend or nSend;
	end

	if nMaxSend == Gift.Times.Forever then
		self:Select(itemObj,1);
	else
		self:Select(itemObj,nRemainSend);
	end
	itemObj.nSend = nSend;
	self.nSend = nSend;
	
	local szCount = nSend < 1 and string.format("%d",nHave) or string.format("%d/%d",nSend,nHave);
	itemObj.pPanel:Label_SetText("LabelSuffix", szCount);
	itemObj.pPanel:SetActive("MinusSign",nSend > 0)
	self:UpdateBottomInfo(true);
	--Item:ShowItemDetail({nTemplate=itemObj.nItemId, nFaction=self.nFaction, nSex = self.nSex, bForceTips = true}, {x=370, y=-1})
	return true
end

function tbUi:CloseCountTimer()
	if self.nDelayCountTimer then
		Timer:Close(self.nDelayCountTimer)
		self.nDelayCountTimer = nil
	end
	if self.nStartCountTimer then
		Timer:Close(self.nStartCountTimer)
		self.nStartCountTimer = nil
	end
end

function tbUi:OnClose()
	self:CloseCountTimer()
	self.bExpTip = nil
end

function tbUi:CheckObj(itemObj,tbRowList)
	local rowNum = #tbRowList;
	if rowNum < nNumPerRow then
		rowNum = rowNum + 1;
		for i = rowNum,nNumPerRow do
			itemObj.pPanel:SetActive("item" .. i, false);
		end
	end
end

local tbHideBottomUi =
{
	["Txt1"] = true,
	["Txt2"] = true,
	["Txt3"] = true,
	["Number"] = true,
	["Intimacy"] = true,
}

function tbUi:GetAddImitity(nCurItemId, nGiftType, nSend)
	local nAddImitity = 0
	if self.tbKeySetting and self.tbKeySetting.fnGetAddImitity then
		nAddImitity = self.tbKeySetting.fnGetAddImitity(self, nCurItemId) * nSend
	else
		local nRate = Gift.Rate[nGiftType] or 0;
		if nGiftType == Gift.GiftType.MailGift then
			nRate = Gift:GetMailAddImitity(nGiftType, nCurItemId) or 0
		end
		nAddImitity = nRate * nSend;
	end
	return nAddImitity
end

function tbUi:GetIsReset(nGiftType, nItemId)
	local bReset = false
	if self.tbKeySetting and self.tbKeySetting.fnGetIsReset then
		bReset = self.tbKeySetting.fnGetIsReset(self, nGiftType, nItemId)
	else
		bReset = Gift:GetIsReset(nGiftType, nItemId)
	end
	return bReset
end

function tbUi:UpdateBottomInfo(bChooseItem)
	for szUiName,_ in pairs(tbHideBottomUi) do
		self.pPanel:SetActive(szUiName,false)
	end
	if bChooseItem then
		self.pPanel:SetActive("Txt1",true)
		self.pPanel:SetActive("Txt2",true)
		self.pPanel:SetActive("Number",true)
		local bPartnerCard = self.szKey == "PartnerCard"
		local nGiftType = self.nGiftType;
		local dwID = self.nCurDwId;
		local nSend = self.nSend or 0;

		local nRemainSend = self:GetRemainTimes(dwID, nGiftType, self.nCurItemId)
		local nMaxSend = self:GetMaxSend(nGiftType, self.nCurItemId)
		local nWillSend = nMaxSend - nRemainSend + nSend;
		nWillSend = nWillSend > nMaxSend and nMaxSend or nWillSend;
		
		local nAddImitity = self:GetAddImitity(self.nCurItemId, nGiftType, nSend)

		local szName = self.szName or "";
		nWillSend = bChooseItem and nWillSend or 0
		local nPercent = nWillSend / nMaxSend;

		local szPercent = nMaxSend == Gift.Times.Forever and "-/-" or string.format("%d / %d",nWillSend,nMaxSend)

		if nMaxSend == Gift.Times.Forever then
			nPercent = 0
		end
		self.pPanel:Sprite_SetFillPercent("NumberBar", nPercent)
		local szAddImility = "[92D2FF]与[FFFE0D]%s[-]亲密度增加：[-]%d"
		if self.tbKeySetting and self.tbKeySetting.szAddImility then
			szAddImility = self.tbKeySetting.szAddImility
		end
		

		self.pPanel:Label_SetText("NumberTxt",szPercent);

		local szItemName = Gift:GetItemAliasName(self.nCurItemId) or Item:GetItemTemplateShowInfo(self.nCurItemId, me.nFaction, me.nSex) or ""
		local bReset = self:GetIsReset(nGiftType,self.nCurItemId)
		local szChoseResetTip ="[92D2FF]今日已赠送[FFFE0D]%s[-]数量[-]"
		if self.tbKeySetting and self.tbKeySetting.szChoseResetTip then
			szChoseResetTip = self.tbKeySetting.szChoseResetTip
		end
		local szChoseTip = "[92D2FF]已赠送[FFFE0D]%s[-]数量[-]"
		if self.tbKeySetting and self.tbKeySetting.szChoseTip then
			szChoseTip = self.tbKeySetting.szChoseTip
		end
		local szTip = bReset and  string.format(szChoseResetTip, szItemName) or string.format(szChoseTip, szItemName)
		local szNoChoseTip = bReset and "今日已赠送数量"  or "已赠送数量"
		local szItemTips = bChooseItem and szTip or szNoChoseTip
		self.pPanel:Label_SetText("Txt2",szItemTips);
		if bPartnerCard then
			local nCardId = dwID
			local tbCardInfo = PartnerCard:GetCardInfo(nCardId)
			if tbCardInfo then
				szAddImility = "[92D2FF]与[FFFE0D]%s[-]友好度"
				self.pPanel:SetActive("Intimacy",true)
				local nCurExp = PartnerCard:GetCardSaveInfo(me, nCardId, PartnerCard.nExpIdxStep) or 0
				local nWillExp = nCurExp + nAddImitity
				local nLevel = PartnerCard:GetCardSaveInfo(me, nCardId, PartnerCard.nLevelIdxStep) or 0
				local _, nQualityLevel = GetOnePartnerBaseInfo(tbCardInfo.nPartnerTempleteId);
				local tbLevelExp = PartnerCard.tbCardUpGrade[nQualityLevel] or {}
				local tbNextLevelInfo =  tbLevelExp[nLevel] or {}
				local nNextLevelExp = tbNextLevelInfo.nUpGradeExp or 0
				local szExp = string.format("%d/%d", nWillExp, nNextLevelExp)
				local nPercent = nWillExp / nNextLevelExp
				self.pPanel:Label_SetText("IntimacyTxt", szExp)
				self.pPanel:Sprite_SetFillPercent("IntimacyBar", nPercent)
			end
			
			self.pPanel:Sprite_SetFillPercent("NumberBar", nPercent)

		end
		self.pPanel:Label_SetText("Txt1",string.format(szAddImility,szName,nAddImitity));
	else
		self.pPanel:SetActive("Txt3",true)
	end
end

function tbUi:UpdateAllFriendData(nFriendDwId,tbItemInfo)
	local tbAllFriend = FriendShip:GetAllFriendData()
	--按在线和亲密度值排序， 在线的》 亲密
	local fnSort = function (a, b)
		if a.nState == emPLAYER_STATE_NORMAL and b.nState == emPLAYER_STATE_NORMAL then
			return a.nImity > b.nImity
		elseif a.nState == emPLAYER_STATE_NORMAL then
			return true
		elseif b.nState == emPLAYER_STATE_NORMAL then
			return false
		else
			return a.nImity > b.nImity
		end
	end
	table.sort(tbAllFriend, fnSort)

	local tbTemp = Lib:CopyTB(tbAllFriend);
	local tbAllFriendTemp = {}
	local tbRoleInfo = nil;

	if nFriendDwId then
		for index,tbInfo in ipairs(tbTemp) do
			if tbInfo.dwID == nFriendDwId then
				tbRoleInfo = tbInfo;
				table.remove(tbTemp,index);
				break;
			end
		end
	end

	if tbRoleInfo then
		table.insert(tbAllFriendTemp,tbRoleInfo);
	end

	for index,tbInfo in ipairs(tbTemp) do
		if not tbItemInfo or not tbItemInfo.nGiftType or not tbItemInfo.nItemId or Gift:CheckItemFriend(tbItemInfo.nGiftType,tbItemInfo.nItemId,tbInfo.dwID) then
			table.insert(tbAllFriendTemp,tbInfo);
		end
	end
	self.tbAllFriend = tbAllFriendTemp
end

function tbUi:UpdatePartnerCard(nCardId)
	self.tbAllFriend = PartnerCard:GetAllOwnCard(me)
	local nPriorIdx
	if nCardId then
		for nIdx, v in ipairs(self.tbAllFriend) do
			if v.dwID == nCardId then
				nPriorIdx = nIdx
				break;
			end
		end
	end
	local tbPriorInfo = self.tbAllFriend[nPriorIdx]
	if tbPriorInfo then
		table.remove(self.tbAllFriend, nPriorIdx)
		table.insert(self.tbAllFriend, 1, tbPriorInfo)
	end
end

-------------------------------------------------------------------------------------

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow("GiftSystem");
	end;
	BtnGive = function(self)
		if not self.nSend or self.nSend < 1 then
			me.CenterMsg("请选择要赠送的物品");
			return
		end
		if self.tbKeySetting and self.tbKeySetting.fnBtnSend then
			self.tbKeySetting.fnBtnSend(self, self.nCurDwId, self.nCurItemId, self.nSend)
			return
		end

		local bNeedSure = Gift:CheckNeedSure(self.nGiftType,self.nCurItemId)
		if bNeedSure then
			local szSureTip = "确定要赠送吗"
			if self.nGiftType == Gift.GiftType.MailGift then
				local tbInfo = Gift:GetMailGiftItemInfo(self.nCurItemId)
				if not tbInfo then
					me.CenterMsg("请选择要赠送的物品");
					return
				end
				if tbInfo.tbData.szSureTip then
					szSureTip = tbInfo.tbData.szSureTip
				end
			end
			me.MsgBox(szSureTip,
			{
				{"确定", function () RemoteServer.SendGift(self.nGiftType,self.nCurDwId,self.nSend,self.nCurItemId); end},
				{"取消"},
			})

		else
			RemoteServer.SendGift(self.nGiftType,self.nCurDwId,self.nSend,self.nCurItemId);
		end
	end;
	GiftSystemHelp = function (self)
		if self.tbKeySetting and self.tbKeySetting.fnBtnHelp then
			self.tbKeySetting.fnBtnHelp(self)
		else
			Ui:OpenWindow("GeneralHelpPanel", "GiftSystemHelp")
		end
	end;
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		--{ UiNotify.emNOTIFY_SEND_GIFT_SUCCESS, self.RefreshUi, self },
		{ UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH, self.RefreshUi, self },
	};

	return tbRegEvent;
end
