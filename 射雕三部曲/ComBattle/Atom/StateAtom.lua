--[[
    filename: ComBattle.Atom.StateAtom
    description: 执行BUFF相关的atom
    date: 2016.11.01

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local StateAtom = {}


--[[
params:
{
    atom
    battleData
    callback
}
--]]
function StateAtom.execute(params)
    local atom = params.atom
    local battleData = params.battleData

    local function exec()
        StateAtom.doExecute(battleData, atom, function()
            if params.afterExec then
                params.afterExec(params.callback)
            else
                params.callback()
            end
        end)
    end

    if params.beforeExec then
        params.beforeExec(exec)
    else
        exec()
    end
end


function StateAtom.doExecute(battleData, atom, cb)
    local buff = battleData:getBuffItem(atom.buffId)
    if not buff then
        bd.log.dataerr(TR("找不到Buff: %s", atom.buffId))
        cb()
        return
    end

    -- 添加buff
    if atom.stateType == bd.adapter.config.atomBuffType.eADD then
        bd.log.info(TR("添加buff: %s->%s: id:%s name:%s uid:%s", atom.fromPos, atom.toPos, atom.buffId, buff.name, atom.uniqueId))

        local checker_ = bd.func.getChecker(cb, 2)
        StateAtom.execute_buff_add(battleData, atom, buff, checker_)

        -- 修改数据
        battleData:addBuff(atom.toPos,
            {
                id  = atom.buffId,
                uid = atom.uniqueId,
            }
        )
        checker_()

    -- 删除buff
    elseif atom.stateType == bd.adapter.config.atomBuffType.eDEL then
        bd.log.info(TR("删除buff: %s->%s: id:%s name:%s uid:%s", atom.fromPos, atom.toPos, atom.buffId, buff.name, atom.uniqueId))
        local checker_ = bd.func.getChecker(cb, 2)
        StateAtom.execute_buff_del(battleData, atom, buff, checker_)

        -- 修改数据
        battleData:delBuff(atom.toPos,
            {
                id  = atom.buffId,
                uid = atom.uniqueId,
            }
        )
        checker_()

    -- 执行buff
    elseif atom.stateType == bd.adapter.config.atomBuffType.eEXEC then
        bd.log.info(TR("执行buff: %s->%s: id:%s name:%s uid:%s", atom.fromPos, atom.toPos, atom.buffId, buff.name, atom.uniqueId))

        -- Todo: 需要调整伤害结算和表现流程

        local check_ = bd.func.getChecker(cb, 2)

        -- 数值变化
        local function change_value()
            local node = battleData:getHeroNode(atom.toPos)
            if node and atom.value then
                for _, value in ipairs(atom.value) do
                    if value.orghp or value.hp then
                        battleData:fixHP({
                            posId = value.posId,
                            value = value.hp,
                            type  = value.effect,
                            ORGHP = value.orghp,
                            from  =  atom.fromPos,
                        })
                    end
                    if value.rp then
                        battleData:fixRP({
                            posId = value.posId,
                            value = value.rp,
                        })
                    end
                    if value.dead then
                        bd.atom.dead(battleData, value.dead)
                    end
                end
            end

            check_()
        end

        StateAtom.execute_buff_exec(battleData, atom, buff, check_)
        change_value()
    else
        return cb()
    end
end


-- @执行重生
function StateAtom.execute_rebirth(battleData, atom, cb)
    -- Todo: 重生未完成
    local node = battleData:getHeroNode(atom.toPos)
    if node then
        node.isDead_ = nil
        node:setVisible(true)
        node:action_idle()
    end

    cb()
end


-- @buff添加
function StateAtom.execute_buff_add(battleData, atom, buff, cb)
    if buff.displayBegin then
        StateAtom.buff_display(battleData, atom, buff.displayBegin, cb)
    else
        cb()
    end
end


-- @buff执行
function StateAtom.execute_buff_exec(battleData, atom, buff, cb)
    if buff.displayExec then
        StateAtom.buff_display(battleData, atom, buff.displayExec, cb)
    else
        cb()
    end
end


-- @buff删除
function StateAtom.execute_buff_del(battleData, atom, buff, cb)
    if buff.displayEnd then
        StateAtom.buff_display(battleData, atom, buff.displayEnd, cb)
    else
        return cb and cb()
    end
end


-- @显示buff特效
function StateAtom.buff_display(battleData, atom, display, cb)
    for _, item in ipairs(display) do
        if item.effect then
            StateAtom.create_effect(battleData, atom, item)
        elseif item.picture then
            StateAtom.create_picture(battleData, atom, item)
        elseif item.audio then
            bd.audio.playSound(item.audio)
        end
    end

    return cb and cb()
end


-- @创建特效
function StateAtom.create_effect(battleData, atom, display)
    local effect_name = display.effect
    -- 常驻的特效则循环播放
    local loop = display.showType == bd.CONST.buffShowType.eStay

    local baseNode = StateAtom.getBuffBaseNode(battleData, atom, display)

    -- baseNode.checker功能见 StateAtom.getBuffBaseNode 里面的注释
    -- 保证baseNode.checker在这里只被调用一次
    local myChecker = bd.func.getChecker(baseNode.checker, 1)

    if loop then
        local node = battleData:getHeroNode(atom.toPos)
        node:addStateEffect(effect_name)
    else
        local sp = bd.interface.newEffect({
            effectName       = display.effect,
            scale            = (bd.ui_config.buffEffectScale[display.effect] or 1) * bd.ui_config.MinScale * (bd.patch.nodeScale or 1),
            loop             = loop,
            endRelease       = not loop,
            position         = cc.p(0, 0),
            completeListener = myChecker,
        })

        if not sp then
            bd.log.warnning(display, "failed to create state effect")
            return
        end

        baseNode:addChild(sp)
    end

    return baseNode
end


-- @创建图片
function StateAtom.create_picture(battleData, atom, display)
    local sp = bd.interface.newSprite({
        img   = display.picture,
        scale = bd.ui_config.MinScale * (bd.patch.nodeScale or 1),
        pos   = cc.p(math.random(-20, 20) * bd.ui_config.MinScale, math.random(100, 120) * bd.ui_config.MinScale),
    })

    if not sp then
        bd.log.warnning(display, "failed to create state picture")
        return
    end

    local baseNode = StateAtom.getBuffBaseNode(battleData, atom, display)
    baseNode:addChild(sp, 1)

    local act = {
        cc.MoveBy:create(battleData:actTime(0.5), cc.p(0, 70* bd.ui_config.MinScale)),
        cc.MoveBy:create(battleData:actTime(1.2), cc.p(0, 50* bd.ui_config.MinScale)),
        cc.CallFunc:create(function()
            if display.showType ~= bd.CONST.buffShowType.eStay then
                -- 不需要常驻时,自删除
                sp:removeFromParent()
            end
            baseNode.checker()
        end),
    }

    -- 渐隐
    if display.showType ~= bd.CONST.buffShowType.eStay then
        table.insert(act, 3, cc.FadeOut:create(battleData:actTime(0.1)))
    end

    sp:runAction(cc.Sequence:create(act))

    return baseNode
end


-- @获取一个放置buff的结点
function StateAtom.getBuffBaseNode(battleData, atom, display)
    local node = battleData:getHeroNode(atom.toPos)
    local baseNode = cc.Node:create()
    node:addFollowNode(baseNode)

    local function watch_buff_del(posId, buffId, uId)
        if uId == atom.uniqueId then
            if display.showType == bd.CONST.buffShowType.eStay then
                local nowNode = battleData:getHeroNode(atom.toPos)
                if nowNode and nowNode.delStateEffect then
                    nowNode:delStateEffect(display.effect)
                end
            end

            if not tolua.isnull(baseNode) then
                baseNode.checker()
            end
        end
    end

    -- 这个checker用来保证特效至少播放完成一次
    baseNode.checker = bd.func.getChecker(function()
        -- 特效动作已完成，且Buff已被清除，则自删除
        baseNode:removeFromParent()

        -- 延时删除监听事件，避免在emit的循环里面删除
        bd.func.performWithDelay(function()
            battleData:off(bd.event.eBuffDel, watch_buff_del)
        end, 0)
    end, 2)

    battleData:on(bd.event.eBuffDel, watch_buff_del)

    return baseNode
end


return StateAtom
