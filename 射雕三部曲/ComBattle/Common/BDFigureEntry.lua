local BDFigureEntry = {}


-- 跳入的实现方式
-- params.isOut                 出场(true) 或者 入场(false)
-- params.fromPos               出发位置
-- params.toPos                 目标位置
-- params.node                  参与入场的节点
-- params.callback              结束回调
-- params.time                  动画总时间
local function jump_impl(params)
    local yanchengScale = bd.ui_config.MinScale
    local aniTime = params.time or 0.2
    local node = params.node

    local jumpToPos = params.toPos

    -- if node.isBoss then
    --     yanchengScale = BattleData:getBossInfo(node.figurePic).shadowScale or 1
    -- end

    node:setVisible(true)
    node:setPosition3D(params.fromPos)

    local actionArray = {}

    table.insert(actionArray, cc.JumpTo:create(aniTime, jumpToPos, 220 * bd.ui_config.MinScale, 1))
    if params.isOut == false then
        table.insert(actionArray, cc.CallFunc:create(function()
            local effPos = clone(jumpToPos)
            effPos.y = effPos.y - 20 * bd.ui_config.MinScale

            local effect = bd.interface.newEffect({
                parent           = node:getParent(),
                effectName       = "effect_ui_chuchangguangquan" ,
                rotationY        = bd.interface.isEnemy(node.idx),
                position3D       = effPos,
                scale            = yanchengScale,
                endRelease       = true,
                completeListener = function()
                    return params.callback and params.callback()
                end
            })
            effect:setLocalZOrder(bd.interface.getHeroZOrder(effPos) + 1)

            bd.adapter.audio.playSound(bd.patch.entryAudio)

        end))
    end

    node:runAction(cc.Sequence:create(actionArray))
end


-- step_impl
local function step_impl(node, stepByPos, callback, stepTime)
    local oldScale = node:getScale()
    local scaleTo = 1.15 * oldScale

    local actionArray = cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveBy:create(stepTime, stepByPos),
            cc.Sequence:create({
                cc.ScaleTo:create(stepTime / 2, scaleTo),
                cc.ScaleTo:create(stepTime / 2, oldScale),
            })
        }),
        cc.CallFunc:create(function()
            local effPos = node:getPosition3D()
            effPos.y = effPos.y - 20 * bd.ui_config.MinScale

            local effect = bd.interface.newEffect({
                parent     = node:getParent(),
                effectName = "effect_ui_chuchangyanchen" ,
                rotationY  = bd.interface.isEnemy(node.idx),
                position3D = effPos,
                endRelease = true,
            })
            effect:setLocalZOrder(bd.interface.getHeroZOrder(effPos) + 1)
        end),
        cc.DelayTime:create(stepTime / 2),
        cc.CallFunc:create(function()
            if callback then
                callback()
            end
        end)
    })

    node:runAction(actionArray)
end

-- 跳入的实现方式
-- params.isOut                 出场(true) 或者 入场(false)
-- params.fromPos               出发位置
-- params.toPos                 目标位置
-- params.node                  参与入场的节点
-- params.callback              结束回调
-- params.time                  动画总时间
-- params.moveDistance          地图背景移动的距离
-- params.localMove             原地不动
local function jump_step_impl(params)
    local stepLenth = 60 * bd.ui_config.MinScale
    local stepTime = params.time or 0.2
    local node = params.node
    local localMove = params.localMove or false

    local jumpToPos = params.toPos

    node:setVisible(true)
    node:setPosition3D(params.fromPos)

    -- 计算跳入次数
    local disty
    if localMove then
        disty = params.moveDistance
    else
        disty = jumpToPos.y - params.fromPos.y
    end

    local tmpTime = math.abs(disty) / stepLenth
    local mod = math.abs(disty) % stepLenth

    if mod > stepLenth / 2 then
        tmpTime = math.ceil(tmpTime)
    else
        tmpTime = math.floor(tmpTime)
    end

    local moveBy
    if localMove then
        moveBy = cc.p(0, 0)
    else
        moveBy = cc.p(0, disty / tmpTime)
    end

    local callback
    callback = function()
        tmpTime = tmpTime - 1

        if tmpTime == 0 then
            params.callback()
        else
            step_impl(node, moveBy, callback, stepTime)
        end
    end
    step_impl(node, moveBy, callback, stepTime)

    return tmpTime * (params.time or 1) * 1.5
end

-- 入场方式实现
-- params.isOut                 出场(true) 或者 入场(false)
-- params.node              	参与入场的节点
-- params.callback 				结束回调
-- params.time 					动画总时间
-- params.moveDistance          地图背景移动的距离
BDFigureEntry.exec = {
	[bd.CONST.entryType.eJumpLeft] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        if params.isOut then
            toPos = cc.vec3(-300 * bd.ui_config.MinScale, toPos.y, toPos.z)
        else
            fromPos = cc.vec3(-300 * bd.ui_config.MinScale, toPos.y, toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos

        jump_impl(params)
	end,
    [bd.CONST.entryType.eJumpRight] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        if params.isOut then
            toPos = cc.vec3(bd.ui_config.width + 300 * bd.ui_config.MinScale, toPos.y, toPos.z)
        else
            fromPos = cc.vec3(bd.ui_config.width + 300 * bd.ui_config.MinScale, toPos.y, toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos

        jump_impl(params)
    end,
    [bd.CONST.entryType.eJumpTop] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        if params.isOut then
            toPos = cc.vec3(toPos.x, bd.ui_config.height + 800 * bd.ui_config.MinScale, toPos.z)
        else
            fromPos = cc.vec3(toPos.x, bd.ui_config.height + 800 * bd.ui_config.MinScale, toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos

        jump_impl(params)
    end,
    [bd.CONST.entryType.eJumpBottom] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        if params.isOut then
            toPos = cc.vec3(toPos.x, - 800 * bd.ui_config.MinScale, toPos.z)
        else
            fromPos = cc.vec3(toPos.x, - 800 * bd.ui_config.MinScale, toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos

        jump_impl(params)
    end,
    [bd.CONST.entryType.eFlash] = function( params )
        local node = params.node

        if params.isOut == false then
            node:setVisible(false)
        end

        local function setNodeDisappear(node, pos)
            -- 消失
            if params.isOut == true then
                node:setPosition( pos )
                node:setVisible(false)
            -- 出现
            else
                node:setPosition( pos )
                node:setVisible(true)
            end
        end

        local pos = bd.interface.getStandPos(node.idx)
        local effect = bd.interface.newEffect({
            parent        = node:getParent(),
            effectName    = bd.ui_config.heroEntryEffect[1],
            animation     = bd.ui_config.heroEntryEffect[2],
            position3D    = pos,
            scale         = 1,
            eventListener = function(p)
                if p.event.stringValue == "display" then
                    setNodeDisappear(node, pos)
                end
            end,
            completeListener = function()
                if params.callback then
                   params.callback()
                end
            end,
            endRelease = true
        })
        effect:setLocalZOrder(node:getLocalZOrder() + 1)
    end,
    [bd.CONST.entryType.eJumpForward] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        local offsety = (params.node.idx > 6) and 400 * bd.ui_config.MinScale or -400 * bd.ui_config.MinScale

        if params.isOut then
            toPos = cc.vec3(toPos.x, toPos.y + offsety, toPos.z)
        else
            fromPos = cc.vec3(toPos.x, toPos.y + offsety, toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos

        jump_step_impl(params)
    end,
    [bd.CONST.entryType.eJumpLocal] = function( params )
        local toPos = bd.interface.getStandPos(params.node.idx)
        local fromPos = bd.interface.getStandPos(params.node.idx)

        local offsety = (params.node.idx > 6) and 400 * bd.ui_config.MinScale or -400 * bd.ui_config.MinScale

        if params.isOut then
            toPos = cc.vec3(toPos.x, toPos.y , toPos.z)
        else
            fromPos = cc.vec3(toPos.x, toPos.y , toPos.z)
        end

        params.fromPos = fromPos
        params.toPos = toPos
        params.localMove = true
        jump_step_impl(params)
    end,
    [bd.CONST.entryType.eNone] = function(params)
        local toPos = bd.interface.getStandPos(params.node.idx)
        params.node:setPosition3D(toPos)
        if params.isOut then
            params.node:setVisible(false)
        else
            params.node:setVisible(true)
        end
        params.callback()
    end
}


return BDFigureEntry
