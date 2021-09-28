-- TestinBattleScene

local TestinBattleScene = class("TestinBattleScene", function(...)
    return display.newScene("TestinBattleScene")
end)

function TestinBattleScene:ctor(pack, ...)
    
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    
    pack.skip = BattleLayer.SkipConst.SKIP_NO
    
    local resultLayer = nil
    local battleField = BattleLayer.create(pack, function(event)
        if event == BattleLayer.BATTLE_OPENING_FINISH then
            if resultLayer then
                resultLayer:removeFromParent()
                resultLayer = nil
            end
        elseif event == BattleLayer.BATTLE_FINISH then
            if not resultLayer then
                resultLayer = CCLayerColor:create(ccc4(0, 0, 0, 0.5*255), display.width, display.height)
                self:addChild(resultLayer)
                resultLayer:ignoreAnchorPointForPosition(false)
                resultLayer:setAnchorPoint(ccp(0.5, 0))
                resultLayer:setPosition(ccp(display.cx, display.height))
                resultLayer:runAction(CCEaseExponentialOut:create(CCMoveBy:create(1, ccp(0, -display.height))))

                local result = G_Path.getBattleImage("win")
                if not pack.msg.is_win then result = G_Path.getBattleImage("lose") end
                local sprite = display.newSprite(result)
                resultLayer:addChild(sprite)
                sprite:setPosition(ccp(display.cx, display.cy))
            end
        end
    end)
    
    self:addChild(battleField)
    
    battleField:play()
    
   
    
end

return TestinBattleScene
