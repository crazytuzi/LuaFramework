--[[
    filename: ComBattle.UICtrl.BDLabel
    description: 伤害/治疗量显示
    date: 2016.08.31

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDLabel = class("BDLabel", {})

function BDLabel:ctor(params)
    self.battleData    = params.battleData
    self.battleProcess = params.battleProcess
end


-- @显示伤害
function BDLabel:showDamageValue(posId, delta, type)
    local baseNode = cc.Node:create()
    baseNode:setScale(bd.patch.nodeScale or 1)
    local pos = bd.interface.getStandPos(posId)  -- 目标位置

    local children = cc.Node:create()
    children:setPositionY(200 * bd.ui_config.MinScale)
    children:setPositionX(bd.func.random(-30, 30) * bd.ui_config.MinScale)
    children:setScale(bd.ui_config.MinScale)
    baseNode:addChild(children)

    -- 伤害值
    local label = self:createNumberLabel(type, delta)
    if label then
        children:addChild(label)
    end

    -- 提示文字（闪避、暴击、格挡）
    local tip = self:createTipLabel(type)
    if tip then
        children:addChild(tip)

        if label then
            tip:setScale(0.65)
            tip:setPositionY(35)
            if type == bd.adapter.config.damageType.eBLOCK then
                tip:setPositionY(25)
            end
        end
    end

    if label or tip then
        local mov = self.uniformMove
        if type == bd.adapter.config.damageType.eCRITICAL
            or type == bd.adapter.config.damageType.eCRITICALHEAL
            or type == bd.adapter.config.damageType.eBLOCK
          then
            mov = self.variableMove
        end

        -- 飘出后自删除
        mov(self, children, function()
            if tip then
                baseNode:runAction(cc.FadeOut:create(0.4))
            end
            if label then
                label:runAction(cc.FadeOut:create(0.4))
            end

            bd.func.performWithDelay(baseNode, function()
                baseNode:removeFromParent()
            end, 0.41)
        end)
    end

    local node = self.battleData:getHeroNode(posId)
    if node then
        baseNode:setPosition3D(node:getPosition3D())
        node:addFollowNode(baseNode, bd.ui_config.zOrderLabel)
    else
        baseNode:setPosition3D(pos)
    end
end


-- @显示治疗量
function BDLabel:showCureValue(...)
    return self:showDamageValue(...)
end


-- @显示击杀怒气
function BDLabel:showRageValue(posId, delta, value, isKill)
    if isKill ~= true then
        return
    end

    local baseNode = cc.Node:create()
    local pos = bd.interface.getStandPos(posId)  -- 目标位置

    local killRage = cc.Sprite:create(bd.ui_config.killRPTipPic)
    killRage:setPosition(cc.p(bd.func.random(-15, 15), 200 + bd.func.random(-15, 15)))
    killRage:setScale(bd.ui_config.MinScale * (bd.patch and bd.patch.nodeScale or 1))
    baseNode:addChild(killRage)

    killRage:runAction(cc.Sequence:create({
        cc.DelayTime:create(0.7),
        cc.FadeOut:create(0.4),
        cc.CallFunc:create(function()
            local node = self.battleData:getHeroNode(posId)
            if node then
                node:removeFollowNode(baseNode)
            end
            baseNode:removeFromParent()
        end)
    }))
    killRage:runAction(cc.MoveBy:create(self.battleData:actTime(1.0 + bd.func.random(-0.15, 0.15)), cc.p(0 , 50)))

    local node = self.battleData:getHeroNode(posId)
    if node then
        baseNode:setPosition3D(node:getPosition3D())
        node:addFollowNode(baseNode, bd.ui_config.zOrderLabel)
    else
        node:setPosition(pos)
    end
end


-- @创建数值
function BDLabel:createNumberLabel(type, value)
    local c = bd.ui_config.effectNumberPic[type]
    if not c then
        return
    end
    --生命文字
    local label = cc.Label:createWithCharMap(unpack(c))
    label:setString(math.abs(value))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setScale(0.7)
    label:setPosition(0, 0)
    return label
end

-- @创建提示文字
function BDLabel:createTipLabel(type)
    local c = bd.ui_config.effectTipPic[type]
    if not c then
        return
    end

    return cc.Sprite:create(c)
end


-- @匀速移动
function BDLabel:uniformMove(baseNode, fadeOutCallback)
    local array = {
        cc.EaseExponentialOut:create(cc.ScaleTo:create(0.3, 2* bd.ui_config.MinScale)),
        cc.EaseBounceOut:create(cc.ScaleTo:create(0.2, 1.5* bd.ui_config.MinScale)),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.4),
        cc.CallFunc:create(function()
            baseNode:removeFromParent(true)
        end)
    }
    if fadeOutCallback then
        table.insert(array, 4, cc.CallFunc:create(fadeOutCallback))
    end
    baseNode:runAction(cc.Sequence:create(array))
    baseNode:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.3 , cc.p(0 , 70* bd.ui_config.MinScale)),
        cc.MoveBy:create(1.1 , cc.p(0 , 50* bd.ui_config.MinScale))
    }))
end

-- @变速移动
function BDLabel:variableMove(baseNode, fadeOutCallback)
    local array = {
        cc.EaseExponentialOut:create(cc.ScaleTo:create(0.3, 3* bd.ui_config.MinScale)),
        cc.EaseBounceOut:create(cc.ScaleTo:create(0.2, 1.8* bd.ui_config.MinScale)),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.4),
        cc.CallFunc:create(function()
            baseNode:removeFromParent(true)
        end)
    }

    if fadeOutCallback then
        table.insert(array, 4, cc.CallFunc:create(fadeOutCallback))
    end

    baseNode:runAction(cc.Sequence:create(array))
    baseNode:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.3 , cc.p(0 , 70* bd.ui_config.MinScale)),
        cc.MoveBy:create(1.1 , cc.p(0 , 50* bd.ui_config.MinScale))
    }))
end


return BDLabel
