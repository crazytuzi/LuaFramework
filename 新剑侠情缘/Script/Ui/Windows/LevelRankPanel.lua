local tbNewInfoUi = Ui:CreateClass("NewInfo_LevelRankActivity")

function tbNewInfoUi:OnOpen(tbData)
	if not tbData then
		return
	end
	self.tbRankData = tbData
	self:RefreshUi()
end

function tbNewInfoUi:RefreshUi()
	local nRemainLevelRank = RankActivity:RemainLevelRankCount()
	self.pPanel:SetActive("LevelRank1",nRemainLevelRank > 0)
	self.pPanel:SetActive("LevelRank2",nRemainLevelRank <= 0)

	self:RefreshMainUi()
	self:RefreshRankUi()
end

function tbNewInfoUi:RefreshMainUi()
	local nLevelRank = RankActivity:LevelRankCount() or 0
	local nRankReaminCount1 = nLevelRank > 0 and 0 or 1

	local nRankReaminCount2 = (10 - nLevelRank - nRankReaminCount1) < 0 and 0 or (10 - nLevelRank - nRankReaminCount1)
	local nRankRemainCount3 = 0
	if nRankReaminCount2 > 0 then
		nRankRemainCount3 = 90
	else
		nRankRemainCount3 = (100 - nLevelRank) < 0 and 0 or (100 - nLevelRank)
	end

	local szRemain1 = string.format("剩余名额：%d / 1",nRankReaminCount1)
	local szRemain2 = string.format("剩余名额：%d / 9",nRankReaminCount2)
	local szRemain3 = string.format("剩余名额：%d / 90",nRankRemainCount3)

	self["LevelItem1"].pPanel:Label_SetText("Remainder1", szRemain1);
	self["LevelItem2"].pPanel:Label_SetText("Remainder2", szRemain2);
	self["LevelItem3"].pPanel:Label_SetText("Remainder3", szRemain3);

	local tbAllReward = RankActivity.tbLevelRankShowReward[me.nFaction] or {}
	for nItemIndex,tbReward in ipairs(tbAllReward) do
		local szItem = "LevelItem" ..nItemIndex
		if self[szItem] then
			for nIconIndex,tbAwardInfo in ipairs(tbReward) do
				local szIcon = string.format("itemframe%d_%d",nItemIndex,nIconIndex)
				if self[szItem][szIcon] then
					self[szItem][szIcon].pPanel:SetActive("Main",true)
					self[szItem][szIcon]:SetGenericItem(tbAwardInfo)
					self[szItem][szIcon].fnClick = self[szItem][szIcon].DefaultClick;
				end
			end
		end
	end

end

function tbNewInfoUi:RefreshRankUi()
	for nRank = 1,RankActivity.MAX_NEW_INFO_COUNT do
		self.pPanel:SetActive("TopTenLevelRank" ..nRank,false)
		local tbPlayerInfo = self.tbRankData[nRank]
		if tbPlayerInfo then
			self.pPanel:SetActive("TopTenLevelRank" ..nRank,true)
			local szName = tbPlayerInfo.szName
			local nFaction = tbPlayerInfo.nFaction
			local nPortrait = tbPlayerInfo.nPortrait
			local szKinName = tbPlayerInfo.szKinName

			self.pPanel:Label_SetText("LevelNumber" ..nRank, nRank);
			self.pPanel:Label_SetText("LevelPlayerName" ..nRank, szName);
			self.pPanel:Label_SetText("LevelFaction" ..nRank, Faction:GetName(nFaction));
			local SpFaction = Faction:GetIcon(nFaction)
			self.pPanel:Sprite_SetSprite("LevelFactionIcon" ..nRank,  SpFaction);
			self.pPanel:Label_SetText("LevelFamilyName" ..nRank, szKinName);
		end
	end
end

function tbNewInfoUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_ONSYNC_LEVEL_RANK,           		  self.RefreshUi},
    };
end


tbNewInfoUi.tbOnClick = {
	BtnLevelRankCheck = function ()
		Ui:OpenWindow("RankBoardPanel","Level")
	end,
}
