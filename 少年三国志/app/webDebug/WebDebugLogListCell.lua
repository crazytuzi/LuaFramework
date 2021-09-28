local WebDebugLogListCell = class("WebDebugLogListCell",function()
    return CCSItemCellBase:create("ui_layout/common_WebDebugListItem2.json")
end)

function WebDebugLogListCell:ctor()
	self._label = self:getLabelByName("Label_txt")
end

function WebDebugLogListCell:updateData(data)
	self._label:setText(data)
end

return WebDebugLogListCell