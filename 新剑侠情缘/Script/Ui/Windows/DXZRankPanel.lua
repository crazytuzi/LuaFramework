local tbUi = Ui:CreateClass("DXZRankPanel");
local tbDaXueZhang = Activity.tbDaXueZhang;
function tbUi:OnOpen(tbData)
	if not tbData then
		return
	end
	self:Update(tbData)
end

function tbUi:Update(tbData)
	table.sort(tbData, function (a, b) return a.nSingleRank < b.nSingleRank end )
	local fnSetItem = function (itemObj, nIdx)
		local tbShowInfo = tbData[nIdx]
		local nJiFen = tbShowInfo.nJiFen
		local nSingleRank = tbShowInfo.nSingleRank or 0
		local szName = tbShowInfo.szName
		local dwID = tbShowInfo.dwID
		--local nFaction = tbShowInfo.nFaction
		local nHonor = tbDaXueZhang:GetSingRankHonorByRank(nSingleRank)
		itemObj.pPanel:Label_SetText("Rank", nSingleRank)
		--itemObj.pPanel:Label_SetText("FactionName", Faction:GetName(nFaction))
		itemObj.pPanel:Label_SetText("TxtName", szName)
		itemObj.pPanel:Label_SetText("TxtCombo", nJiFen)
		itemObj.pPanel:Label_SetText("TxtBattlefieldHonor", nHonor)
		local szSprite = dwID == (me.nLocalServerPlayerId or me.dwID or 0) and "ListBgLight" or "ListBgDark"
		itemObj.pPanel:Sprite_SetSprite("BattleListBar", szSprite)

	end
	self.ScrollView:Update(#tbData, fnSetItem)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_DAXUEZHANG_SINGLE_RANK_DATA, self.Update, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}