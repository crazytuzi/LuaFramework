local TFUIBase = TFUIBase

function cloneMEWidgetChildren(obj)
	-- if obj:getDescription() == "TFRichText" then
	-- 	return
	-- end
	local childArray = obj:getChildren()
	if childArray == nil then return end
	local widget
	for i = 1, childArray:count() do
		local widget = childArray:objectAtIndex(i-1)
		TFUIBase:extends(widget)
		cloneMEWidgetChildren(widget)
	end
end