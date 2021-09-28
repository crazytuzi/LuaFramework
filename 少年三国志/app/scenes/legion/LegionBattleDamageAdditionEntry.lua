-- LegionBattleDamageAdditionEntry

local LegionBattleDamageAdditionEntry = class("LegionBattleDamageAdditionEntry", require "app.scenes.battle.entry.TweenEntry")

function LegionBattleDamageAdditionEntry.create(...)
    return LegionBattleDamageAdditionEntry.new("battle/tween/tween_rebel_numup.json", ...)
end

function LegionBattleDamageAdditionEntry:ctor(tweenJson, object, battleField)
    LegionBattleDamageAdditionEntry.super.ctor(self, tweenJson, nil, object, battleField)
    battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(object:convertToWorldSpaceAR(ccp(0, 100))))
end

function LegionBattleDamageAdditionEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
    
        displayNode = display.newSprite(G_Path.getBattleTxtImage('shanghaitishen.png'))

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
        
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return LegionBattleDamageAdditionEntry




