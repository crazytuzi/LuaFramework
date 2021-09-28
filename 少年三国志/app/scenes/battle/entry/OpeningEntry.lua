-- OpeningEntry

local OpeningEntry = class("OpeningEntry", require "app.scenes.battle.entry.TweenEntry")

function OpeningEntry.create(...)
    return OpeningEntry.new("battle/tween/tween_startdemo.json", ...)
end

function OpeningEntry:ctor(openingJson, objects, battleField)
    OpeningEntry.super.ctor(self, openingJson, nil, objects, battleField)
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
end

function OpeningEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)

    local knights = self._objects
    local displayNode = node
    
    if not displayNode then
        -- 上层
        if tweenNode == "up" then
            local upNode = display.newNode()
            upNode:setCascadeOpacityEnabled(true)
            local layerColorUp = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height/2)
            layerColorUp:setCascadeOpacityEnabled(true)
            upNode:addChild(layerColorUp)
            layerColorUp:ignoreAnchorPointForPosition(false)
            layerColorUp:setAnchorPoint(ccp(0.5, 0))

            for key, knight in pairs(knights[2]) do
                local card = knight:getCardConfig()
                if card.type == 1 then
                    local jsonName = G_Path.getBattleConfig("knight", card.res_id.."_fight")
                    local cardJson = self:getJson(jsonName) or decodeJsonFile(jsonName)
                    self:setJson(jsonName, cardJson)
                    local cardSprite = display.newSprite(cardJson.png)
                    cardSprite:setCascadeOpacityEnabled(true)
                    upNode:addChild(cardSprite)
                    cardSprite:setAnchorPoint(ccp(0.5, 0))
                    cardSprite:setPosition(ccp(upNode:getContentSize().width/2, upNode:getContentSize().height))
                    break
                end
            end

            displayNode = upNode

        -- 中间层
        elseif tweenNode == "mid" then
            local spriteNode = display.newNode()
            spriteNode:setCascadeOpacityEnabled(true)
            local sprite = display.newSprite(G_Path.getBattleImage('opening.png'))
            sprite:setCascadeOpacityEnabled(true)
            spriteNode:addChild(sprite)
            displayNode = spriteNode

        -- 下层
        elseif tweenNode == "down" then           
            local downNode = display.newNode()
            downNode:setCascadeOpacityEnabled(true)
            local layerColorDown = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height/2)
            layerColorDown:setCascadeOpacityEnabled(true)
            downNode:addChild(layerColorDown)
            layerColorDown:ignoreAnchorPointForPosition(false)
            layerColorDown:setAnchorPoint(ccp(0.5, 1))

            for key, knight in pairs(knights[1]) do
                local card = knight:getCardConfig()
                if card.type == 1 then
                    local jsonName = G_Path.getBattleConfig("knight", card.res_id.."_fight")
                    local cardJson = self:getJson(jsonName) or decodeJsonFile(jsonName)
                    self:setJson(jsonName, cardJson)
                    local cardSprite = display.newSprite(cardJson.png)
                    cardSprite:setCascadeOpacityEnabled(true)
                    downNode:addChild(cardSprite)
                    cardSprite:setAnchorPoint(ccp(0.5, 1))
                    cardSprite:setPosition(ccp(downNode:getContentSize().width/2, 0))
                    break
                end
            end

            displayNode = downNode
        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return OpeningEntry


