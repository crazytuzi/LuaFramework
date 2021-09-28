-- BattleScene

require "app.cfg.knight_info"
require "app.cfg.play_info"
require "app.cfg.monster_info"
require "app.cfg.buff_info"
require "app.cfg.unite_skill_info"



local BattleScene = class("BattleScene", function(...)
    return display.newScene("BattleScene")
end)

function BattleScene:ctor(pack, ...)
    
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    
    pack.skip = BattleLayer.SkipConst.SKIP_YES
    
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

                local result = G_Path.getBattleTxtImage("win.png")
                if not pack.msg.is_win then result = G_Path.getBattleTxtImage("lose.png") end
                local sprite = display.newSprite(result)
                resultLayer:addChild(sprite)
                sprite:setPosition(ccp(display.cx, display.cy))
            end
        end
    end)
    
    self:addChild(battleField)

    battleField:play()

    -- back
    local back = ui.newTTFLabelMenuItem {
        text = "Back",
        font = "Marker Felt",
        size = 40,
        align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    }
    
    back:setAnchorPoint(ccp(0, 0))
    back:setPosition(ccp(10, 10))
    
    back:registerScriptTapHandler(function()
        uf_sceneManager:popScene()
    end)

    local menu = ui.newMenu({back})
    self:addChild(menu)
    
end

return BattleScene
