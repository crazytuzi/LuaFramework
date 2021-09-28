-- MoShenOpeningEntry

local MoShenOpeningEntry = class("MoShenOpeningEntry", require "app.scenes.battle.entry.TweenEntry")

function MoShenOpeningEntry.create(...)
    return MoShenOpeningEntry.new("battle/tween/tween_rebel_starup.json", ...)
end

function MoShenOpeningEntry:ctor(tweenJson, battleField, style)
    MoShenOpeningEntry.super.ctor(self, tweenJson, nil, nil, battleField)
    self._style = style
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
end

function MoShenOpeningEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
    
        if tweenNode == "pic" then
            if not self._style then
                displayNode = display.newSprite(G_Path.getBattleTxtImage('rebel_starup.png'))
            else
                if self._style == 1 then
                    displayNode = display.newSprite(G_Path.getBattleTxtImage('rebel_common_attack.png'))
                elseif self._style == 2 then
                    displayNode = display.newSprite(G_Path.getBattleTxtImage('rebel_super_attack.png'))
                else
                    assert(false, "Unknown style: "..self._style)
                end
            end
            
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
        end
    end
        
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return MoShenOpeningEntry




