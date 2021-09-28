
local TurnNode = class("TurnNode", UFCCSNormalLayer)



function TurnNode:ctor(...)
    --self.super.ctor(self,...)   
    self.pos = 0  --位置
    self.angle = 0 -- 角度
    self.EndAngle = 0 -- 旋转时目标角度
    self.speed = 0
    self:setTouchEnabled(false)
end


return TurnNode
