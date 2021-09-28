-- ComboEntry

local ComboEntry = class("ComboEntry", require "app.scenes.battle.entry.TweenEntry")

function ComboEntry.create(...)
    return ComboEntry.new("battle/tween/tween_combo.json", ...)
end

function ComboEntry:ctor(...)
    ComboEntry.super.ctor(self, ...)
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.width - 100, display.height/2 + 60)))
end

function ComboEntry:addCombo(combo)
    self:setComboNumber(self._data + combo)
end

function ComboEntry:setComboNumber(combo)
    self._data = combo
    
    local node = self:getTweenNode("txt1")
    if node then node:setText(tostring(combo)) end
    
    local node = self:getTweenNode("txt2")
    if node then node:setText(tostring(combo)) end
    
    local node = self:getTweenNode("txt3")
    if node then node:setText(tostring(combo)) end
end

function ComboEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
        if tweenNode == "txt1" or tweenNode == "txt2" or tweenNode == "txt3" then
--            displayNode = ui.newBMFontLabel{
--                text = self._data,
--                font = G_Path.getBattleComboLabelFont(),
--                align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
--            }
--            displayNode = CCLabelBMFont:create(self._data, G_Path.getBattleComboLabelFont())
            
            displayNode = LabelBMFont:create()
            displayNode:setFntFile(G_Path.getBattleComboLabelFont())
            displayNode:setText(tostring(self._data))
            
        elseif tweenNode == "combo" then
            displayNode = display.newSprite(G_Path.getBattleTxtImage("lianji.png"))
        elseif tweenNode == "heidi" then           
            --displayNode = display.newSprite(G_Path.getBattleImage("lianji_di.png"))
            displayNode = display.newNode()
        end

        if displayNode then
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
        end
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return ComboEntry
