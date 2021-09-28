-- TotalDamageEntry

local TotalDamageEntry = class("TotalDamageEntry", require "app.scenes.battle.entry.TweenEntry")

function TotalDamageEntry.create(...)
    return TotalDamageEntry.new("battle/tween/tween_zongshanghai.json", ...)
end

function TotalDamageEntry:ctor(json, totalDamage, ...)
    TotalDamageEntry.super.ctor(self, json, totalDamage, ...)
    self._battleField:addToSuperSpNode(self._node)
    local extNum = string.len(tostring(totalDamage))
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.width - extNum * 33, display.height/2)))
end

function TotalDamageEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node

    if not displayNode  then
    
        if tweenNode == "1" then    -- 伤害数
            displayNode = ui.newBMFontLabel{
                text = self._data,
                font = G_Path.getBattleCriticalLabelFont(),
                align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
            }
            displayNode:setAnchorPoint(ccp(0, 0.5))
        elseif tweenNode == "2" then    -- “总伤害”
            displayNode = display.newSprite(G_Path.getBattleTxtImage("zongshanghai.png"))
        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return TotalDamageEntry




