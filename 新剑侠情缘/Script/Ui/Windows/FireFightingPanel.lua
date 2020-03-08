local tbUi = Ui:CreateClass("FireFightingPanel");
local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;
function tbUi:OnOpen(tbData, bFireWin, bIsFirePlayer)
	if not tbData then
		return
	end
	self.pPanel:SetActive("BtnClose", false);
	self.pPanel:SetActive("Fire", bFireWin);
	self.pPanel:SetActive("Water", not bFireWin);
	self:Update(tbData, bIsFirePlayer)
end

function tbUi:Update(tbData, bIsFirePlayer)
	if not bIsFirePlayer then
		table.sort(tbData, function (a, b) return a.nRank < b.nRank end )
	end
	local fnSetItem = function (itemObj, nIdx)
		local tbShowInfo = tbData[nIdx]
		local nValue = tbShowInfo.nValue
		local szName = tbShowInfo.szName
		local dwID = tbShowInfo.dwID
		--local nFaction = tbShowInfo.nFaction
		itemObj.pPanel:Label_SetText("Rank", nIdx)
		--itemObj.pPanel:Label_SetText("FactionName", Faction:GetName(nFaction))
		itemObj.pPanel:Label_SetText("TxtName", szName)
		itemObj.pPanel:Label_SetText("TxtCombo", nValue)
		local szSprite = dwID == (me.nLocalServerPlayerId or me.dwID or 0) and "ListBgLight" or "ListBgDark"
		itemObj.pPanel:Sprite_SetSprite("BattleListBar", szSprite)

	end
	self.ScrollView:Update(#tbData, fnSetItem)
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("FireFightingPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end    