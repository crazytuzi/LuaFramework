-- WaveEntry

local WaveEntry = class("WaveEntry", require "app.scenes.battle.entry.TweenEntry")

function WaveEntry.create(...)
    return WaveEntry.new("battle/tween/tween_wave.json", ...)
end

function WaveEntry:ctor(waveJson, curWave, totalWave, battleField)
    
    assert(curWave >= 1 and totalWave >= 1 and totalWave <= 3 and curWave <= totalWave, "")
    
    WaveEntry.super.ctor(self, waveJson, nil, nil, battleField)
    
    self._curWave = curWave
    self._totalWave = totalWave
    
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
end

function WaveEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local displayNode = node
    
    if not displayNode then
        -- /
        if tweenNode == "precent" then
            displayNode = display.newSprite(G_Path.getBattleImage('boshu_fenhao.png'))
        -- 当前波数
        elseif tweenNode == "curWave" then
            displayNode = display.newSprite(G_Path.getBattleImage('boshu_'..self._curWave..'.png'))
        -- 总波数
        elseif tweenNode == "totalWave" then           
            displayNode = display.newSprite(G_Path.getBattleImage('boshu_'..self._totalWave..'.png'))
        elseif tweenNode == "bg" then           
            displayNode = display.newSprite(G_Path.getBattleImage('boshu_bg.png'))
        end
        
        assert(displayNode, "Unknown displayNode with key: "..tweenNode)

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return WaveEntry




