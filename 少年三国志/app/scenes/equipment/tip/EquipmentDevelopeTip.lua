local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local EquipmentDevelopeTip = class ("EquipmentDevelopeTip", EffectMovingNode)




function EquipmentDevelopeTip:ctor( )
    self._txt =   UFCCSNormalLayer.new("ui_layout/equipment_EquipmentDevelopeTip.json") 

    local node = display.newNode()
    node:addChild(self._txt)
    node:retain()

    self.super.ctor(self, "moving_texttip2", 
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



function EquipmentDevelopeTip:playWithLevel(level )
    self._txt:getLabelBMFontByName("LabelBMFont_level"):setText("+" .. level)
    if level > 1 then
        self._txt:getImageViewByName("ImageView_baoji"):setVisible(true)
    else
        self._txt:getImageViewByName("ImageView_baoji"):setVisible(false)
    end
    self:play()

end


return EquipmentDevelopeTip
