local tbItem = Item:GetClass("MedalItem")

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {
        szFirstName = "查看排行",
        fnFirst = function()
            Ui:CloseWindow("ItemTips")
            Ui:OpenWindow("RankBoardPanel", "MedalFightAct")
        end,
    }
end