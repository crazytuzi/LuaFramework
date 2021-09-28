-- 副本收益限时调整
local M = class( "temp52" , function() return cc.Layer:create() end  )
function M:ctor( params )
    self.data = {}

    local rightBg = createSprite( self , "res/layers/activity/bg8.jpg" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    
    local function createLayout()
        self.data = DATA_Activity.CData["netData"]    
    end
    DATA_Activity:readData(createLayout)
end

return M
