-- SuperSkillEntry

require "app.cfg.skill_info"

local ALIGN_CENTER = "align_center"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)

    if align == ALIGN_CENTER then

        -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
        local totalWidth = 0
        for i=1, #items do
            totalWidth = totalWidth + items[i]:getContentSize().width
        end

        local function _convertToNodePosition(position, item)

            -- print("position.x: "..position.x.." position.y: "..position.y)

            -- 居中对齐默认是以ccp(0, 0.5)为标准
            local anchorPoint = item:getAnchorPoint()
            return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

        end

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end


local SuperSkillEntry = class("SuperSkillEntry", require "app.scenes.battle.entry.TweenEntry")

function SuperSkillEntry:ctor(...)
    SuperSkillEntry.super.ctor(self, ...)
    self._battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
end

function SuperSkillEntry:initEntry()
    
    SuperSkillEntry.super.initEntry(self)
    
    -- 拉幕音效
    self:addEntryToNewQueue(nil, function()
        require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_SUPER_SKILL)
        return true
    end)
    
end

function SuperSkillEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local attacks = self._data
    local attackers = self._objects
    local fx = string.gsub("f0", "%d", frameIndex)
    
    local displayNode = node
    
    if not displayNode then
    
        -- 黑色背景
        if tweenNode == "black_bg" then

            displayNode = CCLayerColor:create(ccc4(0, 0, 0, 255))
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
            displayNode:ignoreAnchorPointForPosition(false)
            displayNode:setAnchorPoint(ccp(0.5, 0.5))

        -- 都是特效
        elseif tweenNode == "bg" or tweenNode == "appear" then

            local SpEntry = require "app.scenes.battle.entry.SpEntry"
            local spJson = tween[fx].start  -- 因为tweenNode引用sp的节点有点不一样，这里的start相当于在action引用sp的节点
            displayNode = SpEntry.new(spJson, self._objects, self._battleField)

        -- 此为遮罩层
        elseif tween.mask_info then

            local stencil = CCLayerColor:create(ccc4(0, 0, 0, 255), tween.mask_info.width, tween.mask_info.height)
            stencil:ignoreAnchorPointForPosition(false)
            stencil:setAnchorPoint(ccp(0.5, 0.5))
            
            displayNode = CCClippingNode:create()
            displayNode:setStencil(stencil)

--            -- 然后遍历下原来那些节点，如果有使用此遮罩的，则需要重新add到此遮罩下, 但是位置因为clipnode的坐标其实没有变化，所以可以不用动
--            for key, node in pairs(self._tweenArr) do
--                if node.mask and node.mask == tweenNode then
--                    node:retain()
--                    local order = node:getZOrder()
--                    local worldPosition = node:convertToWorldSpaceAR(ccp(0, 0))
--                    node:removeFromParent()
--                    displayNode:addChild(node, order)
--                    node:setPosition(displayNode:convertToNodeSpace(worldPosition))
--                    node:release()
--                end
--            end
            
            displayNode.isMask = true
            stencil.clipNode = displayNode

        -- 第一个攻击者
        elseif tweenNode == "card1_1" or tweenNode == "card1_2" or tweenNode == "card1_3" then

            local cardConfig = attackers.release_knight:getCardConfig()
            local renwuId = cardConfig.res_id
            local renwuFilePath = G_Path.getKnightPic(renwuId)
--            displayNode = display.newSprite(renwuFilePath)
            local KnightPic = require "app.scenes.common.KnightPic"
            displayNode = KnightPic.getHalfNode(renwuId, 0, true)
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)

--            local json = decodeJsonFile(G_Path.getKnightPicConfig(renwuId))
--            displayNode:setAnchorPoint(ccp((displayNode:getContentSize().width/2 - tonumber(json.x)) / displayNode:getContentSize().width, (displayNode:getContentSize().height/2 - tonumber(json.y)) / displayNode:getContentSize().height))

        -- 第二个攻击者
        elseif tweenNode == "card2_1" or tweenNode == "card2_2" or tweenNode == "card2_3" then

            local cardConfig = attackers.need_knight_1:getCardConfig()
            local renwuId = cardConfig.res_id
            local renwuFilePath = G_Path.getKnightPic(renwuId)
--            displayNode = display.newSprite(renwuFilePath)
            local KnightPic = require "app.scenes.common.KnightPic"
            displayNode = KnightPic.getHalfNode(renwuId, 0, true)
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)

--            local json = decodeJsonFile(G_Path.getKnightPicConfig(renwuId))
--            displayNode:setAnchorPoint(ccp((displayNode:getContentSize().width/2 - tonumber(json.x)) / displayNode:getContentSize().width, (displayNode:getContentSize().height/2 - tonumber(json.y)) / displayNode:getContentSize().height))

        -- 第三个攻击者
        elseif tweenNode == "card3_1" or tweenNode == "card3_2" or tweenNode == "card3_3" then

            local cardConfig = attackers.need_knight_2:getCardConfig()
            local renwuId = cardConfig.res_id
            local renwuFilePath = G_Path.getKnightPic(renwuId)
--            displayNode = display.newSprite(renwuFilePath)
            local KnightPic = require "app.scenes.common.KnightPic"
            displayNode = KnightPic.getHalfNode(renwuId, 0, true)
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
            
--            local json = decodeJsonFile(G_Path.getKnightPicConfig(renwuId))
--            displayNode:setAnchorPoint(ccp((displayNode:getContentSize().width/2 - tonumber(json.x)) / displayNode:getContentSize().width, (displayNode:getContentSize().height/2 - tonumber(json.y)) / displayNode:getContentSize().height))


        -- 技能名称
        elseif tweenNode == "skillname_1" or tweenNode == "skillname_2" or tweenNode == "skillname_3" then

            local skillId = attacks.skill_id
            local skillConfig = skill_info.get(skillId)
            local txtId = skillConfig.txt

            local node = display.newNode()
            local skillSprite = display.newSprite(G_Path.getBattleSkillTextImage(txtId..'.png'))
            local comboTxt = display.newSprite(G_Path.getBattleSkillTextImage("heji.png"))
            
            node:addChild(skillSprite)
            node:addChild(comboTxt)
            
            local getPosition = _autoAlign(ccp(0, 0), {comboTxt, skillSprite}, ALIGN_CENTER)
            comboTxt:setPosition(getPosition(1))
            skillSprite:setPosition(getPosition(2))
            
            displayNode = node
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
            
        elseif tweenNode == "back1" or tweenNode == "back2" or tweenNode == "back3" then
            
            displayNode = display.newSprite(G_Path.getBattleImage("super_skill_name_bg.png"))
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
            
        elseif tweenNode == "name1" or tweenNode == "name2" or tweenNode == "name3" then
            
            local card = nil
            if tweenNode == "name1" then card = attackers.release_knight:getCardConfig()
            elseif tweenNode == "name2" then card = attackers.need_knight_1:getCardConfig()
            elseif tweenNode == "name3" then card = attackers.need_knight_2:getCardConfig()
            end
            
--            displayNode = Label:create()
--            displayNode:setText(card.name)
--            displayNode:setFontName(G_Path.getBattleLabelFont())
--            displayNode:setFontSize(24)
--            displayNode:setTextAreaSize(CCSizeMake(35, 160))
            
            displayNode = ui.newTTFLabel({
                text = card.name,
                font = G_Path.getBattleLabelFont(),
                size = 26,
                color = Colors.getColor(card.quality),
                align = ui.TEXT_ALIGN_CENTER, -- 文字内部居中对齐
                dimensions = CCSize(35, 160)  -- 这里的size是上面背景图的size
            })
            
            displayNode:setCascadeOpacityEnabled(true)
            displayNode:setCascadeColorEnabled(true)
            
        end
        
    end
    
    assert(displayNode, "Unknown tweenNode: "..tweenNode)
    
    if displayNode then
        
        local parent = self._node
        -- 如果存在遮罩层且名字相同，则父类切换成clipnode    
        if self._tweenArr[tween.mask] then
            parent = self._tweenArr[tween.mask].clipNode
        end
        
        if displayNode.isEntry then
            self:addEntryToNewQueue(displayNode, displayNode.updateEntry)
            parent:addChild(displayNode:getObject(), tween.order or 0)
        else
            parent:addChild(displayNode, tween.order or 0)
        end
    end
    
    return displayNode.isMask and displayNode:getStencil() or displayNode

end

return SuperSkillEntry




