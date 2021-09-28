-- CityPatrolStateEventItem
-- 武将巡逻事件item

local CityPatrolStateEventItem = class("CityPatrolStateEventItem", function()
    return CCSItemCellBase:create("ui_layout/city_PatrolStateEventItem.json")
end)

function CityPatrolStateEventItem:ctor()
    
    local label = self:getLabelByName("Label_content")
    label:setText("")
    local size = label:getSize()
    
    local parent = label:getParent()
    
    local label1 = CCSRichText:create(size.width, size.height)
    label1:setFontName(label:getFontName())
    label1:setFontSize(label:getFontSize())
    label1:setShowTextFromTop(true)
    label1:setPosition(ccp(label:getPosition()))

    parent:addChild(label1, 5)
    
    self._richText = label1
    self._timeText = self:getLabelByName("Label_time")
    
end

function CityPatrolStateEventItem:updateContent(timeLabel, contentLabel)
    
    self._timeText:setText(timeLabel)
    
    self._richText:clearRichElement()
    self._richText:appendContent(contentLabel, ccc3(255, 255, 255))
    self._richText:reloadData()

end


return CityPatrolStateEventItem

