local GUIRecyle = class("GUIRecyle", function (param)
	return cc.ScrollView:create(param.size or cc.size(100,100))
end)

function GUIRecyle:ctor(param)
	self._data = {}
	self._updateCellCallback = nil
	self:registerScriptHandler(self.scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self:registerScriptHandler(self.scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
end

function GUIRecyle:scrollToTop()

end

function GUIRecyle:scrollToTop()

end

function GUIRecyle:setUpdateCellCallback(func)
	if GameUtilSenior.isFunction(func) then
		self._updateCellCallback = func
	end
end

function GUIRecyle:reloadData(data)
	self._data = data
	if GameUtilSenior.isFunction(self._updateCellCallback) then
		self._updateCellCallback()

	end
end

function GUIRecyle:insertItemAtLast()

end

function GUIRecyle:insertItemAtHead()

end

function GUIRecyle:scrollViewDidScroll( view )
	print("view---",view)
	

end

function GUIRecyle:scrollViewDidZoom( view )
	print("view---",view)
end

return GUIRecyle