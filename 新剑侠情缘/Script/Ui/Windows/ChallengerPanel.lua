local tbUi = Ui:CreateClass("ChallengerPanel");

function tbUi:OnOpen()
	self:RefreshUi()
	ArenaBattle:SynChallengerData()
end

function tbUi:RefreshUi()

	local tbApplyData = ArenaBattle:GetApplyData() or {}

	local function fnChanllge(itemObj)
		local tbData = 
		{
			nIdx = itemObj.nIdx,
			nChallengerId = itemObj.nChallengerId,
			nArenaId = itemObj.nArenaId,
		}
		ArenaBattle:PickChallenger(tbData)
	end
	local fnSetItem = function(itemObj,nIdx)

		local tbApplyInfo = tbApplyData[nIdx]

		local szName = tbApplyInfo.szName
		local nLevel = tbApplyInfo.nLevel
		local nApplyIndex = tbApplyInfo.nIdx
		local nHonorLevel = tbApplyInfo.nHonorLevel
		local nPortrait = tbApplyInfo.nPortrait
		local nFaction = tbApplyInfo.nFaction
		local nTeammate = tbApplyInfo.nTeammate
		local nChallengerId = tbApplyInfo.nPlayerID
		local nArenaId = tbApplyInfo.nArenaId

		itemObj.pPanel:Label_SetText("Name", szName);
		itemObj.pPanel:Label_SetText("lbLevel", nLevel);

		local SpFaction = Faction:GetIcon(nFaction)
		itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);

		itemObj.pPanel:SetActive("PlayerTitle", nHonorLevel > 0);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
		itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);

	    local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(nPortrait)
	    itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szIcon,szAtlas);

	     local szTeammate = ""
	    if nTeammate == -1 then
	    	szTeammate = "队伍人数：单人"
	    else
	    	szTeammate = string.format("队伍人数：%s人",nTeammate)
	    end
	    itemObj.pPanel:Label_SetText("Number", szTeammate);
	    
	    itemObj["BtnAcceptChallenge"].nIdx = nApplyIndex
	    itemObj["BtnAcceptChallenge"].nChallengerId = nChallengerId
	    itemObj["BtnAcceptChallenge"].nArenaId = nArenaId

	    itemObj["BtnAcceptChallenge"].pPanel.OnTouchEvent = fnChanllge
	end

	self.ScrollView:Update(#tbApplyData,fnSetItem);
	self.pPanel:SetActive("NoChallenger",(not next(tbApplyData)))
end


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYN_ARENA_APPLY_DATA, self.RefreshUi, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow("ChallengerPanel");
	end,
}