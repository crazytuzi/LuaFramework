--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-18
-- Time: 下午1:44
-- To change this template use File | Settings | File Templates.
--

local SimpleColorLayer = class("SimpleColorLayer", function(color)
    -- local color = param.color
    return display.newColorLayer(color or ccc4(0, 0, 0, 170))
end)

function SimpleColorLayer:ctor(param)

    self:setNodeEventEnabled(true)

    self:setTouchSwallowEnabled(true)
end


function SimpleColorLayer:onEnter()


end



function SimpleColorLayer:onExit()
    ResMgr.blueLayer = nil 
end



return SimpleColorLayer

