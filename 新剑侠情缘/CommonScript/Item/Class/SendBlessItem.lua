
local tbItem = Item:GetClass("SendBlessItem");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbActSetting = SendBless:GetActSetting()
	return {szFirstName = tbActSetting.szItemUseName, fnFirst = "UseItem"};
end

function tbItem:OnClientUse()
    Ui:CloseWindow("ItemTips")
    local tbActSetting = SendBless:GetActSetting()
    Ui:OpenWindow(tbActSetting.szOpenUi)
end
