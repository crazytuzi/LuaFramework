local tbUi = Ui:CreateClass("LabaFestivalFriendPanel");
local tbAct = Activity.LabaAct
function tbUi:OnOpen()
	tbAct:RequestNeedAssistFriendData()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local fnAssist = function(itemObj)
		local nPlayerId = itemObj.dwID
		tbAct:RequestPlayerAssistData(nPlayerId)
	end
	local tbAllFriend = tbAct:GetAllFriend()
	local fnSetItem = function(itemObj, nIdx)
		local tbRoleInfo = tbAllFriend[nIdx];
		local szName = tbRoleInfo.szName or tbRoleInfo.szWantedName;
		itemObj.pPanel:Label_SetText("Name", szName);
		local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
		itemObj.pPanel:Sprite_SetSprite("Faction",  SpFaction);
		local nHonorLevel = tbRoleInfo.nHonorLevel or 0
		itemObj.pPanel:SetActive("PlayerTitle", nHonorLevel > 0)
        if nHonorLevel > 0 then
            local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
            itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
        end
        itemObj["Box"].pPanel:SetActive("Main", tbRoleInfo.nNeedAssist == 1)
        itemObj["Box"].dwID = tbRoleInfo.dwID
        itemObj["Box"].pPanel.OnTouchEvent = fnAssist
	end
	self.ScrollView:Update(tbAllFriend, fnSetItem)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_SYNC_LABA_ACT_FRIEND_DATA, self.RefreshUi, self},

	};
	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}
