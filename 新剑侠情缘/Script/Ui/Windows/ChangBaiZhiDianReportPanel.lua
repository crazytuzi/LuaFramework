local tbUi = Ui:CreateClass("ChangBaiZhiDianReportPanel")


tbUi.tbCamp2SpriteIndex = 
{
	[1] = 5,
	[2] = 4,
	[3] = 3,
	[4] = 6,
	[5] = 1,
	[6] = 8,
	[7] = 7,
	[8] = 2,
}

function tbUi:OnOpenEnd()
	self:UpdateContent()
end

function tbUi:UpdateContent()
	local _, nCamp = me.GetNpc().GetPkMode()
	local tbReportInfo = ChangBaiZhiDian.tbTeamReportInfo or {}
	local fnSetItem = function(itemObj, index)
		local tbInfo = tbReportInfo[index]
		itemObj.pPanel:Label_SetText("RankingTxt", index)
		itemObj.pPanel:Sprite_SetSprite("Camp", "ChangbaiCamp0"..tostring(self.tbCamp2SpriteIndex[tbInfo.nCamp or 1] or 1))
		itemObj.pPanel:Label_SetText("LingZhiTxt", tbInfo.LingZhi or 0)
		itemObj.pPanel:Label_SetText("RenShenxt", tbInfo.RenShen or 0)
		itemObj.pPanel:Label_SetText("XueLianxt", tbInfo.XueLian or 0)
		itemObj.pPanel:Label_SetText("LuWangxt", (tbInfo.nBossRank and tbInfo.nBossRank > 0) and tostring(tbInfo.nBossRank) or "-")
		itemObj.pPanel:Label_SetText("IntegralTxt", tbInfo.nScore or 0)
		local nFaction1 = tbInfo.tbFaction and tbInfo.tbFaction[1] or 1
		local nFaction2 = tbInfo.tbFaction and tbInfo.tbFaction[2] or 1
		Timer:Register(1 , function()
			itemObj.pPanel:Sprite_SetSprite("Occupation1", Faction:GetIcon(nFaction1))
			itemObj.pPanel:Sprite_SetSprite("Occupation2", Faction:GetIcon(nFaction2))
		end)

		itemObj.pPanel:Button_SetSprite("Main", "ListBgDark", 1)
		itemObj.pPanel:Button_SetSprite("Main", "ListBgDark", 3)
		if nCamp == tbInfo.nCamp then
			itemObj.pPanel:Button_SetSprite("Main", "ListBgLight", 1)
			itemObj.pPanel:Button_SetSprite("Main", "ListBgLight", 3)
		end
	end
	self.ScrollView:Update(tbReportInfo, fnSetItem)
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_SYNC_CHANGBAI_REPORT_DATA, self.UpdateContent},
	}
	return tbRegEvent
end