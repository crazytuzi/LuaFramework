local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local EquipmentRefineLevelTip = class ("EquipmentRefineLevelTip", EffectMovingNode)




function EquipmentRefineLevelTip:ctor( )
    self._txt =   UFCCSNormalLayer.new("ui_layout/equipment_EquipmentRefineLevelTip.json") 

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



function EquipmentRefineLevelTip:playWithLevel(level )
    self._txt:getLabelBMFontByName("LabelBMFont_level"):setText("+" .. level)
   
    self:play()

end


return EquipmentRefineLevelTip
