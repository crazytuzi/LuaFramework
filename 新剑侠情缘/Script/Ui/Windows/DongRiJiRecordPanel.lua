local tbUi = Ui:CreateClass("DRJ_RecordPanel");
local tbAct = Activity.DongRiJiAct;

function tbUi:OnOpen()
	Log("Open DRJ_RecordPanel");
	tbAct:GetMySendMsg();
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
	local tbListMsg = tbAct:GetSendRecordMsg() or {};
	local fnSetItem = function(itemObj,nIndx)
		local tbData = tbListMsg[nIndx];
		itemObj.pPanel:Label_SetText("Name", tbData.playerMsg.szName);
		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbData.playerMsg.nPortrait);
		itemObj.itemframe.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		itemObj.itemframe.pPanel:Label_SetText("lbLevel",tbData.playerMsg.nLevel);
		local SpFaction = Faction:GetIcon(tbData.playerMsg.nFaction)
		itemObj.itemframe.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.playerMsg.nHonorLevel);
		if ImgPrefix then
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle",false);
		end
		itemObj.pPanel:SetActive("Leave", tbData.bIsLossPlayer);
		itemObj.pPanel:Label_SetText("RankingTxt",nIndx);
		itemObj.pPanel:Label_SetText("RelationshipTxt",tbAct.tbTags[tbData.nTag]);
		local fnClick = function(itemObj)
			Ui:OpenWindow("ItemTips", "Item", nil, tbData.nFDID, me.nFaction, me.nSex);
		end
		itemObj.ItemBox:SetItemByTemplate(tbData.nFDID,1,me.nFaction, me.nSex);
		itemObj.ItemBox.fnClick = fnClick;
	end

	self.ScrollView:Update(#tbListMsg,fnSetItem);
end

function tbUi:OnOpenEnd()
	self:Flush();
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Log("BtnClose");
		Ui:CloseWindow(self.UI_NAME)
	end;
}
