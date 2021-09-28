

local HandBookScroll = class("HandBookScroll", function (data)
    return display.newNode()
end)

function HandBookScroll:ctor(param)
    local data = param.data
    local size = param.size


    -- print("scroll data")
    -- dump(data)

    local scrollNode = display.newColorLayer(ccc4(100,200,50,0))
    local scrollViewBg = CCScrollView:create()

    self:addChild(scrollViewBg) 

    self.cellTable = {}
    local orY = 0 
    local orX = size.width/2

    local curX = orX
    local curY = orY

    local scrollHeight = 0

    for i = 1,#data do

        local cell  = require("game.HandBook.HandBookCell").new({cellData = data[i]})
        self.cellTable[#self.cellTable + 1] = cell
        scrollHeight = scrollHeight + cell:getHeight()
        scrollNode:addChild(cell)
        
    end

    curY = orY + scrollHeight

    for i = 1,#self.cellTable do
        if i ~= 1 then
            curY = curY - self.cellTable[i-1]:getHeight()            
        end
        self.cellTable[i]:setPosition(curX,curY)
    end



    scrollViewBg:setViewSize(CCSize(size.width,size.height-50))
    scrollViewBg:ignoreAnchorPointForPosition(true)
        
    scrollViewBg:setContainer(scrollNode)
    scrollNode:setContentSize(CCSize(size.width,scrollHeight))
    scrollViewBg:setContentSize(CCSize(size.width,scrollHeight))
    scrollViewBg:updateInset()
    local min = scrollViewBg:minContainerOffset()

    scrollViewBg:setContentOffset(min,false)

    scrollViewBg:setDirection(kCCScrollViewDirectionVertical)
    scrollViewBg:setClippingToBounds(true)

    scrollViewBg:setBounceable(true)

    scrollViewBg:setAnchorPoint(ccp(0.5,0))





end

return HandBookScroll
