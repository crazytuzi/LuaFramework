-- MoShenAdditionEntry

local MoShenAdditionEntry = class("MoShenAdditionEntry", require "app.scenes.battle.entry.TweenEntry")

function MoShenAdditionEntry.create(...)
    return MoShenAdditionEntry.new("battle/tween/tween_rebel_numup.json", ...)
end

function MoShenAdditionEntry:ctor(...)
    MoShenAdditionEntry.super.ctor(self, ...)
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 100))))
end

function MoShenAdditionEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
        
        local value = self._data

        local fnt = G_Path.getMoshenBattleFont()
        value = "x"..value

        displayNode = ui.newBMFontLabel({
            text = value,
            font = fnt,
            align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
        })
        
        displayNode:setCascadeColorEnabled(true)
        displayNode:setCascadeOpacityEnabled(true)
        
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode
    
end

return MoShenAdditionEntry


