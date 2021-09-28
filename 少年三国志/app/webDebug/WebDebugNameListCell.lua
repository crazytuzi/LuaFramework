local WebDebugNameListCell = class("WebDebugNameListCell",function()
    return CCSItemCellBase:create("ui_layout/common_WebDebugListItem1.json")
end)

function WebDebugNameListCell:ctor()
	self._label = self:getLabelByName("Label_name")
	self._checkBox = self:getCheckBoxByName("CheckBox_check")
	self:setTouchEnabled(true)
	
	self:registerCellClickEvent(function ( cell, index )
		print("clicked")
		if self._func then
			self._func(self._index)
		end
	end) 
	self:registerCheckboxEvent("CheckBox_check",function ( widget, type, isCheck )
		if self._func then
			self._func(self._index)
		end
	end) 
end

function WebDebugNameListCell:updateData(data,index,checkedIndex,func)
	self._label:setText(data)
	self._index = index
	self._checkBox:setSelectedState(index == checkedIndex)
	self._func = func
end

return WebDebugNameListCell