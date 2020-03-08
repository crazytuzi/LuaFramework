local tbNewInfoUi = Ui:CreateClass("NewInfo_PowerRankActivity")

function tbNewInfoUi:OnOpen(tbData)
	if not tbData then
		return
	end
	self.tbRankData = RankActivity:ManagerPowerRankData(tbData)
	self:RefreshUi()
end


function tbNewInfoUi:RefreshUi()
	local bIsEnd = next(self.tbRankData) and true or false
	self.pPanel:SetActive("FightingRank1",not bIsEnd)
	self.pPanel:SetActive("FightingRank2",bIsEnd)

	self:RefreshMainUi()
	self:RefreshRankUi()
end

function tbNewInfoUi:RefreshMainUi()
	local nOpenServerTime = Lib:GetTodayZeroHour(GetServerCreateTime());
	local nStartTime = nOpenServerTime + (RankActivity.nPowerRankOpenDay - 1) * 24 * 60 * 60 + RankActivity.nPowerRankTime
	local szStartTime = Lib:TimeDesc7(nStartTime) or ""
	local nDistanceTime = nStartTime - GetTime()
	local szDistanceTime = Lib:TimeDesc6(nDistanceTime) or ""
	local szDes = string.format("活动内容：\n      如今武林动荡，为鼓励门派新秀，[c8ff00]%s（%s后）[-]将根据门派战力榜，给各门派第一的侠士奖励。\n    （15级后通过主界面[FFFE0D] 变强 [-]可以知道如何快速提升战力）",szStartTime,szDistanceTime)
	self.pPanel:Label_SetText("FightingDetails1", szDes);
	
	local tbAllReward = RankActivity.tbPowerRankShowReward[me.nFaction] or {}
	for nItemIndex,tbReward in ipairs(tbAllReward) do
		local szItem = "FightingItem" ..nItemIndex
		if self[szItem] then
			for nIconIndex,tbAwardInfo in ipairs(tbReward) do
				local szIcon = string.format("itemframe%d_%d",nItemIndex,nIconIndex)
				if self[szItem][szIcon] then
					self[szItem][szIcon].pPanel:SetActive("Main",true)
					self[szItem][szIcon]:SetGenericItem(tbAwardInfo)
					self[szItem][szIcon].fnClick = self[szItem][szIcon].DefaultClick;

					local szLabel = string.format("ItemName%d_%d",nItemIndex,nIconIndex)
					local szName = "排名奖励"
					if tbAwardInfo[1] == "Item" or tbAwardInfo[1] == "item" then
						szName = Item:GetItemTemplateShowInfo(tbAwardInfo[2], me.nFaction, me.nSex)
					elseif tbAwardInfo[1] == "AddTimeTitle" then
						local tbTitle = PlayerTitle:GetTitleTemplate(tbAwardInfo[2])
						if tbTitle then
							szName = tbTitle.Name
						end
					end
					self[szItem].pPanel:Label_SetText(szLabel, szName)
					
				end
			end
		end
	end
end

function tbNewInfoUi:RefreshRankUi()

	local fnSetItem = function(itemObj, nIdx)
		local tbPlayerInfo = self.tbRankData[nIdx]
		if not tbPlayerInfo then
			return
		end

		itemObj.pPanel:Label_SetText("FightingPlayerName", tbPlayerInfo.szName or "-");
		itemObj.pPanel:Label_SetText("FightingFaction", Faction:GetName(tbPlayerInfo.nFaction));
		local SpFaction = Faction:GetIcon(tbPlayerInfo.nFaction)
		itemObj.pPanel:Sprite_SetSprite("FightingFactionIcon",  SpFaction);
		itemObj.pPanel:Label_SetText("FightingFamilyName", tbPlayerInfo.szKinName or "-");
	end

	self.ScrollViewPowerRank:Update(#self.tbRankData, fnSetItem);
end

tbNewInfoUi.tbOnClick = {
	BtnFightingRankCheck = function ()
		local szKey = "FightPower_" ..me.nFaction
		Ui:OpenWindow("RankBoardPanel",szKey)
	end,
}
