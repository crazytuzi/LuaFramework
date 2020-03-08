local tbUi = Ui:CreateClass("DRJ_MainPanel");
local tbAct = Activity.DongRiJiAct or {};
tbAct.bIsOpenShareButton = false;

function tbUi:OnOpen()
	tbAct:GetMyMsg();
	tbAct:GetMyReceMsg();
	self.Prize.pPanel:SetActive("Doubt",false);
	self.pPanel:SetActive("BtnChoice",true);
	self.Prize:SetDigitalItem(tbAct.tbSendWishesAward[1],tbAct.tbSendWishesAward[2]);
	self.bGroupIsOpen = false;
	self.pPanel:SetActive("ChoiceGroup",false);
end

function tbUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNOTIFY_REFRESH_DRJ_FUDAI_ACT, self.OnNotify, self},
	};
	Log("Regist");
	return tbRegEvent;
end

function tbUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbUi:_OnNotify(...)
	self:UpdateContent();
end

function tbUi:OnOpenEnd()
	self.nTab = self.nTab or 1;
	self:ChangeTab(self.nTab);

	self.pPanel:SetActive("BtnShare" , self.bIsOpenShareButton);
	self.pPanel:SetActive("BtnChoice2", false);
	self.pPanel:SetActive("BtnSelectionTags2" , false);
	self.pPanel:Button_SetEnabled("BtnReceiveAwards" , true);
	self:UpdateContent();
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
		tbAct.tbReadySendData = nil;
	end;

	BtnReceiveAwards = function(self)
		self:ReceiveAwards();
	end;

	BtnChoice = function(self)
		self:ChoiceWish();
	end;

	BtnChoice2 = function(self)
		self:ChoiceWish();
	end;
	
	BtnSelectPlayer = function(self)
		self:SelectPlayer();
	end;

	BtnSelectionTags2 = function(self)
		self:SelectionTags();
	end;

	BtnRandom = function(self)
		self:RandomJiYu();
	end;
	
	BtnSendOut = function(self)
		self:SendOut();
	end;
	
	BtnViewRecord = function(self)
		self:ViewRecord();
	end;

	BtnChoicePrize = function(self)
		Ui:OpenWindow("DRJ_ChoosingGiftsPanel")
	end;

	BtnShare = function(self)
		self:ShareMsg();
	end;

	BtnChoice = function(self)
		self:OpenChoiceGroup();
	end
}



local tbTab = {"BtnDesire", "BtnGive", "BtnCollect"}
local tbTabGroup = {"DesireGroup", "GiveGroup" ,"ScrollView"}
for nIdx, szBtn in ipairs(tbTab) do
	tbUi.tbOnClick[szBtn] = function(self)
		self:ChangeTab(nIdx);
	end
end

for i = 1, 9 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self:BtnClickWish(i)
	end
end


function tbUi:OpenChoiceGroup()
	Log("Open");
	self.bGroupIsOpen = not self.bGroupIsOpen;
	if self.bGroupIsOpen == nil then self.bGroupIsOpen = true; end
	self.pPanel:SetActive("ChoiceGroup",self.bGroupIsOpen);

end

function tbUi:BtnClickWish(nIdx)
	local nChoiceWish = nIdx + 1;
	self.pPanel:SetActive("ChoiceGroup",false);
	self.bGroupIsOpen = not self.bGroupIsOpen;
	if nChoiceWish == tbAct.NONE_WISH or nChoiceWish == tbAct.tbPlayerData.nWishID then 
		return 
	end;
	local tbData = tbAct.tbPlayerData;
	local fnCancel = function()
		local szLastWish = tbAct.tbWishType[tbData.nWishID or 1];
		Log("Cancel",szLastWish);
		self.pPanel:PopupList_Select("BtnChoice", szLastWish);
	end
	local fnConfirm = function()
		Log("Sure Modify Wishes");
		if me.GetMoney("Gold") < tbAct.MODIFY_COST and (tbData.nWishID or 1) ~= tbAct.NONE_WISH then
			Ui:OpenWindow("CommonShop" , "Recharge");
			local szLastWish = tbAct.tbWishType[tbData.nWishID or 1];
			self.pPanel:PopupList_Select("BtnChoice", szLastWish);
			return ;
		end
		Log("Ready Modify Wishes" , nChoiceWish);
		tbAct:ModifyWishes(nChoiceWish);
	end
	local szNowWish = tbAct.tbWishType[nChoiceWish];
	if not szNowWish then return end;
	local szMsg = "";
	if tbAct.tbPlayerData.nWishID == tbAct.NONE_WISH then
		szMsg = string.format("首次许下愿望是免费的，再次修改愿望需要花费[FFFE0D]%d[-]元宝，确定选择[FFFE0D]%s[-]作为您的愿望吗?",tbAct.MODIFY_COST,szNowWish);
	else
		szMsg = string.format("本次修改愿望需要花费[FFFE0D]%d[-]元宝，确定选择[FFFE0D]%s[-]作为您的愿望吗?",tbAct.MODIFY_COST,szNowWish);
	end

	Ui:OpenWindow("MessageBox",szMsg,
	{ {fnConfirm}, {fnCancel} }, {"确定", "取消"})
	self:UpdateContent();
end

function tbUi:ChangeTab(nTab)
	if self.nTab == nTab then return end;

	for nIdx, szBtn in ipairs(tbTab) do
		self.pPanel:SetActive(tbTabGroup[nIdx], nIdx == nTab);
	end
	self.nTab = nTab;
	self:UpdateContent();
end


function tbUi:UpdateContent()
	if tbAct.tbPlayerData == nil then
		tbAct:GetMyMsg();
		return;
	end;
	if tbAct.tbReceGiftData == nil then
		tbAct:GetMyReceMsg();
		return;
	end
	local tbData = tbAct.tbPlayerData;
	if self.nTab == 1 then
		self:FlushBtnChoice();
		local tbBarMsg = tbAct:GetFillBarMsg();
		self:SetBar(tbBarMsg);
		local bCanAward = tbAct:CanGetAward() or false;
		self.pPanel:Button_SetEnabled("BtnReceiveAwards" , bCanAward);
	elseif self.nTab == 2 then
		local szName = tbAct:GetRedaySendFriend() or "请选择玩家" ;
		self.pPanel:Label_SetText("PlayerName",szName);
		local nFDID = tbAct:GetReadySendFDID();
		if nFDID == nil then
			self.pPanel:Label_SetText("BtnChoicePrize","选 择\n礼 物");
			self.ChoicePrize:Clear();
		else
			self.pPanel:Label_SetText("BtnChoicePrize","");
			self.ChoicePrize:SetItemByTemplate(nFDID,1,me.nFaction, me.nSex);
		end
		local nTag = tbAct:GetFriendTag();
		self.pPanel:PopupList_Select("BtnSelectionTags", tbAct.tbTags[nTag]);
	elseif self.nTab == 3 then
		self:UpdateScrollView();
	end
end

function tbUi:SetBar(tbBarMsg)
	local nSendValue = tbBarMsg.nSendValue or 0;
	local nHasAward = tbBarMsg.nHasAward or 0;
	local bCanAward = tbAct:CanGetAward(nSendValue, nHasAward);
	local nPresent = 0;
	if bCanAward then
		nPresent = 1;
	else
		nPresent = (nSendValue - nHasAward * tbAct.TIMES_AWARD) * 20 / 100;
	end
	self.pPanel:Sprite_SetFillPercent("Bar" , nPresent);
end

function tbUi:UpdateScrollView()
	local fnSort = function(a,b)
		if a == nil or b == nil then return false end;
 		if a.bHasUse ~= b.bHasUse then 
 			return a.bHasUse 
 		end
 		if a.bHasUse then
 			return a.Id > b.Id
 		else
 			return a.Id < b.Id
 		end
 		return false;
	end
	local tbListMsg = tbAct:GetReceRecordMsg() or {};
	for i,Msg in ipairs(tbListMsg) do
		Msg.Id = i;
	end
	if #tbListMsg > 1 then
		table.sort(tbListMsg, fnSort);
	end
	local fnSetItem = function(itemObj, nIndx)
		local tbData = tbListMsg[nIndx];
		local fnCallBack = function() --快速回赠
			self:ChangeTab(2);
			--self.BtnGive.OnTouchEvent();
			self:HasChoicePlayer(tbData.playerMsg.nSendPlayerID, tbData.playerMsg.szName);
		end

		local fnGetGift = function() --领取礼物
			tbAct:ReceiveGift(tbData.nGiftID);
		end

		itemObj.Item1.pPanel:Label_SetText("Name", tbData.playerMsg.szName);
		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbData.playerMsg.nPortrait);
		itemObj.Item1.itemframe.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		local SpFaction = Faction:GetIcon(tbData.playerMsg.nFaction);
		itemObj.Item1.itemframe.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.playerMsg.nHonorLevel);
		if ImgPrefix then
			itemObj.Item1.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.Item1.pPanel:SetActive("PlayerTitle",false);
		end
		itemObj.Item1.itemframe.pPanel:Label_SetText("lbLevel", tbData.playerMsg.nLevel);
		local szJiYu = tbData.szJiYu or tbAct.tbJiYuModel[tbData.nJiYuType] or tbAct.tbJiYuModel[1];
		itemObj.pPanel:Label_SetText("Item2Txt" , szJiYu);
		
		local fnClick = function()
			Ui:OpenWindow("ItemTips", "Item", nil, tbData.nFDID, me.nFaction, me.nSex);
		end
		itemObj.Item1.ItemBox:SetItemByTemplate(tbData.nFDID);
		itemObj.Item1.ItemBox.fnClick = fnClick;
		itemObj.Item1.BtnQuickRebate.pPanel.OnTouchEvent = fnCallBack;
		itemObj.Item1.BtnReceiveGifts.pPanel.OnTouchEvent = fnGetGift;
		itemObj.Item1.pPanel:Button_SetEnabled("BtnReceiveGifts",tbData.bHasUse or false);
	end
	self.ScrollView:Update(#tbListMsg,fnSetItem);
end

function tbUi:RandomJiYu()
	if not tbAct.tbJiYuModel or #tbAct.tbJiYuModel < 1 then return end;
	local fn = Lib:GetRandomSelect(#tbAct.tbJiYuModel);
	local nRand = fn();
	local szJiYu = tbAct.tbJiYuModel[nRand];
	self.pPanel:Input_SetText("InputField",tbAct.tbJiYuModel[nRand]);
end

function tbUi:SendOut()
	local szJiYu = self.pPanel:Input_GetText("InputField");
	tbAct:SendGift(szJiYu);
end

function tbUi:SelectPlayer()
	Ui:OpenWindow("DRJ_SelectPlayerPanel");
	self:UpdateContent();
end

function tbUi:ViewRecord()
	Ui:OpenWindow("DRJ_RecordPanel");
	self:UpdateContent();
end

function tbUi:ChoiceWish()

end

function tbUi:ReceiveAwards()
	tbAct:GetRandomGift();
end

function tbUi:ShareMsg()

end

tbUi.tbUiPopupOnChange = tbUi.tbUiPopupOnChange or {};
tbUi.tbUiPopupOnChange.BtnChoice = function (self, szWndName, value)

end

function tbUi:FlushBtnChoice()

	local tbData = tbAct.tbPlayerData;
	if not tbData then return end;
	local szMsg = tbAct.tbWishType[tbData.nWishID or 1];
	self.pPanel:PopupList_Select("BtnChoice", szMsg);
end

tbUi.tbUiPopupOnChange.BtnSelectionTags = function (self, szWndName, value)
	local nTag = tbAct.tbKeyTags[value];
	tbAct.tbReadySendData = tbAct.tbReadySendData or {};
	tbAct.tbReadySendData.nTag = nTag;
end

function tbUi:HasChoicePlayer(nPlayerId, szName)
	Log(nPlayerId, szName);
	self.pPanel:Label_SetText("PlayerName",szName);
	tbAct.tbReadySendData = tbAct.tbReadySendData or {};
	tbAct.tbReadySendData.nSendPlayerID = nPlayerId;
	tbAct.tbReadySendData.szSendPlayerName = szName;
	self:UpdateContent();
end

function tbUi:GetJiYu()
	local szMsg = self.pPanel:Input_GetText("InputTxt");
	return szMsg;
end