-- CommonSkillEntry

local CommonSkillEntry = class("CommonSkillEntry", require "app.scenes.battle.entry.TweenEntry")

function CommonSkillEntry.create(...)
    return CommonSkillEntry.new("battle/tween/tween_common_skill.json", ...)
end

function CommonSkillEntry:ctor(...)
    CommonSkillEntry.super.ctor(self, ...)
    self._battleField:addToNormalSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 250))))
end

function CommonSkillEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    local attacks = self._data

    if not displayNode then
    
        if tweenNode == "txt" then
            local skillId = attacks.skill_id
            local skillConfig = skill_info.get(skillId)
            local txtId = skillConfig.txt
            local txtFilePath = G_Path.getBattleSkillTextImage(txtId..'.png')
            local txt = display.newSprite(txtFilePath)
			    
            -- 背景
            local bg = display.newSprite(G_Path.getBattleImage("skill_name.png"))
            bg:addChild(txt)
            txt:setCascadeOpacityEnabled(true)
            txt:setCascadeColorEnabled(true)
            txt:setPosition(ccpMult(ccpFromSize(bg:getContentSize()), 0.5))
			
            displayNode = bg
        end

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)

    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode
end

return CommonSkillEntry




