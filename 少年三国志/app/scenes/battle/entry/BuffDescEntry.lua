-- BuffDescEntry

require "app.cfg.buff_info"


local BuffDescEntry = class("BuffDescEntry", require "app.scenes.battle.entry.TweenEntry")

function BuffDescEntry:ctor(buff, data, object, battleField, isResist, isRemoved, isRecovered)
    
    -- 抵抗
    self._isResist = isResist
    -- 消除
    self._isRemoved = isRemoved
    -- 驱散
    self._isRecovered = isRecovered
    
    local buffTween = nil
    if isRemoved then
        buffTween = "tween_buff_down"
    elseif isRecovered then
        buffTween = "tween_buff_up"
    elseif isResist then
        buffTween = "tween_buff_up"
    else
        if buff then
            local buff_id = buff.buff_id
            local buffConfig = buff_info.get(buff_id)
            assert(buffConfig, "Could not find the buffConfig with id: "..buff_id)

            buffTween = buffConfig.buff_tween
            local buffImg = buffConfig.buff_tween_pic
            assert(buffTween and buffImg, "Could not find the buffTween or buffImg with id: "..buff_id)

            self._buffImg = buffImg
        end
    end
    
    BuffDescEntry.super.ctor(self, "battle/tween/"..buffTween..".json", data, object, battleField)
    
    battleField:addToNormalSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 130))))
    
end

function BuffDescEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    
    if not displayNode then
        if tweenNode == "txt" then
            if self._isResist then
                displayNode = display.newSprite(G_Path.getBattleTxtImage('zhuangtaitishi_xuanyundikang.png'))
            elseif self._isRemoved then
                displayNode = display.newSprite(G_Path.getBattleTxtImage('qingchu.png'))
            elseif self._isRecovered then
                displayNode = display.newSprite(G_Path.getBattleTxtImage('qusan.png'))
            else
                displayNode = display.newSprite(G_Path.getBattleTxtImage(self._buffImg..'.png'))
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

return BuffDescEntry
