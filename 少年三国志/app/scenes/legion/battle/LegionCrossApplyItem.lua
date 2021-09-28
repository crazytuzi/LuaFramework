--LegionCrossApplyItem.lua


local LegionCrossApplyItem = class("LegionCrossApplyItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/Legion_CrossApplyItem.json")
end)

function LegionCrossApplyItem:ctor( ... )
	local panel = self:getWidgetByName("Root")
	local timeLabel = self:getLabelByName("Label_sample")
	if panel and timeLabel then 
		local size = panel:getSize()
		local label1 = CCSRichText:create(size.width, size.height)
    	label1:setFontName(timeLabel:getFontName())
    	label1:setFontSize(timeLabel:getFontSize())
    	label1:setShowTextFromTop(true)
    	label1:setPositionXY(size.width/2, size.height/2)
    	panel:addChild(label1)

    	self._richText = label1
	end
end

function LegionCrossApplyItem:updateItem( index )
	if type(index) ~= "number" then 
		return 
	end

	local corpInfo = G_Me.legionData:getCorssApplyInfoByIndex(index)
	if self._richText and corpInfo then 
	local desc = G_lang:get("LANG_LEGION_CROSS_APPLY_CORP_FORMAT", {corpName=corpInfo.name})
	self._richText:clearRichElement()
    	self._richText:appendContent(desc, Colors.darkColors.DESCRIPTION)
    	self._richText:reloadData()
	end
end

return LegionCrossApplyItem



