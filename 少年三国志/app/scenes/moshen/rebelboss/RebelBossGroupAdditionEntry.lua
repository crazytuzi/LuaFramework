
local RebelBossGroupAdditionEntry = class("RebelBossGroupAdditionEntry", require "app.scenes.battle.entry.TweenEntry")

function RebelBossGroupAdditionEntry.create(...)
    return RebelBossGroupAdditionEntry.new("battle/tween/tween_rebel_numup.json", ...)
end

function RebelBossGroupAdditionEntry:ctor(tweenJson, object, battleField)
    RebelBossGroupAdditionEntry.super.ctor(self, tweenJson, nil, object, battleField)
    battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(object:convertToWorldSpaceAR(ccp(0, 100))))
end

function RebelBossGroupAdditionEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
    
        displayNode = display.newSprite(G_Path.getBattleTxtImage('zhenyingjiacheng.png'))

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
        
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return RebelBossGroupAdditionEntry




