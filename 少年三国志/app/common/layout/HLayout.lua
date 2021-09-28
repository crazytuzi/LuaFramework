local HLayout = {}
HLayout.__index = HLayout

function HLayout.new(target, gap, align)    
    local t = {
        _gap = gap, 
        _target = target, 
        _align=align, 
        _itemsWidth=0, 
        _targetWidth=target:getContentSize().width,
        _childs={}
    }


    return setmetatable(t, HLayout)
end





function HLayout:add(item, needAddChildToTarget)
    if needAddChildToTarget == nil then
        needAddChildToTarget = true
    end

    --get rect    
    local size = item:getContentSize()
    local anchorPt = item:getAnchorPoint()

    local placex = self._itemsWidth + (#self._childs > 0 and self._gap or 0 ) + anchorPt.x * size.width
    self._itemsWidth = placex + size.width*(1-anchorPt.x)
    table.insert(self._childs, {placex = placex, item=item})

    local startx = 0
    if self._align == "left" then
    elseif self._align == "center" then
        startx = (self._targetWidth - self._itemsWidth) /2
    end


    for i=1,#self._childs do
        local item = self._childs[i].item

        item:setPositionX(startx + self._childs[i].placex)
    end

  

    if needAddChildToTarget then
        self._target:addChild(item) 
    end
       
end



return HLayout