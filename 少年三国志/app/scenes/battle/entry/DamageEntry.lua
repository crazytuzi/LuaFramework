-- DamageEntry

local DamageEntry = class("DamageEntry", require "app.scenes.battle.entry.TweenEntry")

function DamageEntry.create(changeHp, ...)
    if changeHp > 0 then
        return DamageEntry.new("battle/tween/tween_healing.json", changeHp, ...)
    else
        return DamageEntry.new("battle/tween/tween_damage.json", changeHp, ...)
    end
end

function DamageEntry:ctor(damageJson, changeHp, objects, battleField, isCritical, isDodge)
    DamageEntry.super.ctor(self, damageJson, changeHp, objects, battleField)
    self._isCritical = isCritical
    self._isDodge = isDodge
    self._battleField:addToDamageSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 230))))

end

function DamageEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    
    if not displayNode then
        if tweenNode == "txt" then

            local damage = self._data
            local victim = self._objects

            if self._isDodge then
                displayNode = display.newSprite(G_Path.getBattleTxtImage("shanbi.png"))
            else
                local fnt = G_Path.getBattleDamageLabelFont()
                if damage > 0 then
                    fnt = G_Path.getBattleRecoverLabelFont()
                elseif self._isCritical and damage < 0 then
                    fnt = G_Path.getBattleCriticalLabelFont()
                end
                
                -- 这里如果现实0则就显示0，避免显示不一致掩盖错误原因
                damage = (damage > 0 and "+"..damage) or (damage == 0 and 0 or damage)

                if fnt then
                    displayNode = ui.newBMFontLabel({
                        text = tostring(damage),
                        font = fnt,
                        align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
                    })
                end
            end

            victim:changeHp(damage)
            
            -- 冒血通知
            self._battleField:dispatchEvent(self._battleField.BATTLE_DAMAGE_UPDATE, victim:getIdentity(), victim:getLocation(), tonumber(damage))
            
        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
     
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode
    
end

return DamageEntry
