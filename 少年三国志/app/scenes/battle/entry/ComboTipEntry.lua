-- ComboTipEntry

local ComboTipEntry = class("ComboTipEntry", require "app.scenes.battle.entry.TweenEntry")

function ComboTipEntry.create(...)
    return ComboTipEntry.new("battle/tween/tween_heji.json", ...)
end

function ComboTipEntry:ctor(json, data, objects, ...)
    ComboTipEntry.super.ctor(self, json, data, objects, ...)
    self._battleField:addToNormalSpNode(self._node, 100)        -- 合击文字放到最上层
    self._node:setPosition(self._node:getParent():convertToNodeSpace(objects:convertToWorldSpace(ccp(15, 190))))
end

function ComboTipEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
        if tweenNode == "txt" then
            displayNode = display.newSprite(G_Path.getBattleTxtImage("zd-hejiqipao.png"))
        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return ComboTipEntry


