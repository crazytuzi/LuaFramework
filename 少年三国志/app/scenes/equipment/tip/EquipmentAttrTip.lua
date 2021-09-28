local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local EquipmentAttrTip = class ("EquipmentAttrTip", EffectMovingNode)


local MergeEquipment = require("app.data.MergeEquipment")


function EquipmentAttrTip:ctor( )
    self._txt =   UFCCSNormalLayer.new("ui_layout/equipment_EquipmentAttrTip.json") 

    local node = display.newNode()
    node:addChild(self._txt)
	node:retain()
    self.super.ctor(self, "moving_texttip", 
        function(key) 
            if key == "txt" then
                return node
            end
        end,
        function(event)
            if event == "finish" then
                self:stop()
                self:removeFromParentAndCleanup(true)
				node:release()
            end
        end 
    )

end



function EquipmentAttrTip:playWithTypeAndDelta(typeName, type, deltaValue )
    local text = typeName ..  "+" .. deltaValue 
    if MergeEquipment.isAttrTypeRate(type) then
        text = text .. "%"
    end

    self._txt:getLabelByName("Label_txt"):setText(text)

    self:play()

end


return EquipmentAttrTip
