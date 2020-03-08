local tbItem = Item:GetClass("ClueMapGuide");
function tbItem:OnClientUse(it)
    local nSeqId = KItem.GetItemExtParam(it.dwTemplateId, 1);
    if not Compose.ValueCompose:GetSeqInfo(nSeqId) then
    	return
    end
    Ui:OpenWindow("ClueMapPanel", nSeqId)
end