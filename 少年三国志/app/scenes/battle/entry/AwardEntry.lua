-- AwardEntry

local AwardEntry = class("AwardEntry", require "app.scenes.battle.entry.TweenEntry")

function AwardEntry.create(...)
    return AwardEntry.new("battle/tween/tween_shakingbox.json", ...)
end

function AwardEntry:ctor(...)
    AwardEntry.super.ctor(self, ...)
    self._battleField:addToNormalSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 0))))
end

function AwardEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    
    if not displayNode then
        if tweenNode == "item" then

            local awardType = self._data

            if awardType == 3 then -- 道具
                displayNode = display.newSprite(G_Path.getBattleImage("diaoluo_daoju.png"))
            elseif awardType == 2 then -- 武将
                displayNode = display.newSprite(G_Path.getBattleImage("diaoluo_wujiang.png"))
            elseif awardType == 1 then -- 装备
                displayNode = display.newSprite(G_Path.getBattleImage("diaoluo_zhuangbei.png"))
            else
                assert(false, "Unknown award type: "..tostring(awardType))
            end

            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
        end
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode
end

return AwardEntry






