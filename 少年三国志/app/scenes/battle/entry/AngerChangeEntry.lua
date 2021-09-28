-- AngerChangeEntry

local AngerChangeEntry = class("AngerChangeEntry", require "app.scenes.battle.entry.TweenEntry")

function AngerChangeEntry.create(anger, object, battleField, isResist)
    
    local tweenJson = nil
    
    if isResist then
        tweenJson = "battle/tween/tween_word.json"
    elseif anger > 0 then
        tweenJson = "battle/tween/tween_anger_up.json"
    else
        tweenJson = "battle/tween/tween_anger_down.json"
    end
    
    return AngerChangeEntry.new(tweenJson, anger, object, battleField, isResist)
end

function AngerChangeEntry:ctor(tweenJson, anger, object, battleField, isResist)
    AngerChangeEntry.super.ctor(self, tweenJson, anger, object, battleField)
    
    self._isResist = isResist
    
    self._battleField:addToDamageSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 230))))
end

function AngerChangeEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    local anger = self._data

    if not displayNode then
    
        if tweenNode == "txt" then
            
            local angerPNG = nil
            if anger > 0 then
                angerPNG = "anger_up.png"
            else
                angerPNG = "anger_down.png"
            end
            
            displayNode = display.newSprite(G_Path.getBattleTxtImage(angerPNG))
            
        elseif tweenNode == "figure" then

            -- 这里如果现实0则就显示0，避免显示不一致掩盖错误原因
            local angerStr = anger > 0 and "+"..anger or anger

            displayNode = ui.newBMFontLabel({
                text = angerStr,
                font = anger > 0 and G_Path.getBattleRecoverLabelFont() or G_Path.getBattleDamageLabelFont(),
                align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
            })
            
        elseif tweenNode == "name" then
            
            displayNode = display.newSprite(G_Path.getBattleTxtImage('mianyi.png'))

        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)

    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode
end


return AngerChangeEntry
