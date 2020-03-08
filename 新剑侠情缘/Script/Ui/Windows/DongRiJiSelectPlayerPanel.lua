local tbUi = Ui:CreateClass("DRJ_SelectPlayerPanel");
local tbAct = Activity.DongRiJiAct;
function tbUi:OnOpen()
	tbAct:GetFriendsMsg()
end

function tbUi:OnOpenEnd()
	self:Flush();
end

function tbUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNOTIFY_REFRESH_DRJ_FUDAI_ACT, self.OnNotify, self},
	};
	return tbRegEvent;
end

function tbUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbUi:_OnNotify(...)
	self:Flush();
end

function tbUi:Flush()
	local tbFriendsInfo = FriendShip:GetAllFriendData();
	local tbActInfo = tbAct:GetFriendWishMsg() or {};
	table.sort(tbFriendsInfo,  function(a,b) return a.nImity > b.nImity end )
	
	local fnSetItem = function(itemObj,nIndx)
		local tbRoleInfo = tbFriendsInfo[nIndx];
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)

		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait);
		itemObj.pPanel:Label_SetText("Name", tbRoleInfo.szName);
		itemObj.itemframe.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		itemObj.itemframe.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)
		local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
		itemObj.itemframe.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
		if ImgPrefix then
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle",false);
		end
		
		local fnBtnItemClick = function()
			local tMainUi = Ui("DRJ_MainPanel");
			tMainUi:HasChoicePlayer(tbRoleInfo.dwID, tbRoleInfo.szName);
			Ui:CloseWindow(self.UI_NAME);
		end
		itemObj.pPanel.OnTouchEvent = fnBtnItemClick;
		itemObj.pPanel:Toggle_SetChecked("Main" , false);
		itemObj.pPanel:Button_SetCheck("Main" , false);
		local tbFriendActInfo = tbActInfo[tbRoleInfo.dwID];
		if tbFriendActInfo then
			local szTag = tbAct.tbWishType[tbFriendActInfo.nTag] or "";
			itemObj.pPanel:Label_SetText("DesireTxt" , szTag);
			itemObj.pPanel:SetActive("LeaveTxt" , tbFriendActInfo.bIsLoss or false)
		else
			itemObj.pPanel:Label_SetText("DesireTxt" , "");
			itemObj.pPanel:SetActive("LeaveTxt" , false);
		end
	end
	self.ScrollView:Update(#tbFriendsInfo, fnSetItem)
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Log("BtnClose");
		Ui:CloseWindow(self.UI_NAME)
	end;
}

