local _knightPic = require("app.scenes.common.KnightPic")
local TurnplateLayer = require("app.scenes.common.turnplate.TurnplateLayer")
local RoleTurnNode = require("app.scenes.createrole.RoleTurnNode")

local RoleTurnplateLayer = class("RoleTurnplateLayer", TurnplateLayer)


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"




--6个侠客的角度

local angles = {5, 90, 175, 270}

function RoleTurnplateLayer:ctor( ... )
    self.super.ctor(self, ...)

    self._roleIdList = {1, 2, 3, 4}
end

function RoleTurnplateLayer:init(size)
    self.super.init(self, size, angles, 1)

    --乱序排一下
    math.randomseed(os.time())
    self._roleIdList = shuffled(self._roleIdList)

    for i=1, #self._roleIdList do
         local node = RoleTurnNode.create()
         node:setData(self._roleIdList[i])


         self:addNode(node, i)

         if node.angle == 270 then
            --node:setSelected(true)
        else
            node:setSelected(false)
         end

         
    end
end




function RoleTurnplateLayer:onLayerExit()

    self.super.onLayerExit(self)
end

function RoleTurnplateLayer:flyintoTurnplate( func )
    local _list = self:getOrderList()

    require("app.cfg.knight_info")
    local JumpBackCard = require("app.scenes.common.JumpBackCard")
    --local winSize = CCDirector:sharedDirector():getWinSize()
    for k, v in ipairs(_list) do
        if v then 
            v:setVisible(false)
        end
    end
    local animations = {
        {knight = _list[1], start = ccp(-100, display.height*1.5)},
        {knight = _list[2], start = ccp(-100, display.height*1.5), extraKnight={knight = _list[3], start = ccp(display.width+100, display.height)}},
        {knight = _list[4], start = ccp(display.width+100, display.height)},

    }


    local playNext


    playNext = function()
        local info = table.remove(animations, 1 )
        if info == nil then
            if func then
                func()
            end
            return
        end
        local knight = info.knight 
        local start = info.start 
        local roleId = knight:getRoleId()
        local resId = knight_info.get(roleId).res_id
        local worldPos = knight:getImageWorldPosition()
        local jumpKnight = JumpBackCard.create()
        self:addChild(jumpKnight)
        jumpKnight:play(resId, start, 0.1, worldPos, knight:getImageScale(), function() 
            jumpKnight:removeFromParentAndCleanup(true)
            knight:setVisible(true)

            if #animations == 0 then 
                knight:setSelected(true)
            end 
            playNext()
        end )

        if info.extraKnight then
            local info = info.extraKnight
            local knight = info.knight 
            local start = info.start 
            local roleId = knight:getRoleId()
            local resId = knight_info.get(roleId).res_id
            local worldPos = knight:getImageWorldPosition()
            local jumpKnight = JumpBackCard.create()
            self:addChild(jumpKnight)
            jumpKnight:play(resId, start, 0.1, worldPos, knight:getImageScale(), function() 
                jumpKnight:removeFromParentAndCleanup(true)
                knight:setVisible(true) 
               
            end )
        end
    end

    playNext()
   
   

end

function RoleTurnplateLayer:onMove()
    --移动中
    local _list = self:getOrderList()

    for k,v in ipairs(_list) do

            v:setSelected(false)
        
    end
    self._callBack(false)
end


function RoleTurnplateLayer:onMoveStop(reason)
    local _list = self:getOrderList()

    for k,v in ipairs(_list) do
        if v.angle == 270 then
            --取到最前面那个侠客

            v:setSelected(true)
            
        else
            v:setSelected(false)
            
        end
    end
    self._callBack(true)
end

-- @desc 点击武将
function RoleTurnplateLayer:onClick(pt)


end

function RoleTurnplateLayer:setCallBack(callback)

    self._callBack = callback
end


function RoleTurnplateLayer:getSelectedRoleId()
    local _list = self:getOrderList()

    for k,v in ipairs(_list) do
        if v.angle == 270 then
            return v:getRoleId()
            
       
        end
       
        
    end
    return 0
end

return RoleTurnplateLayer
