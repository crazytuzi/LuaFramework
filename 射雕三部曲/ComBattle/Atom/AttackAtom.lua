--[[
    filename: ComBattle.Atom.AttackAtom
    description: 执行人物攻击动作
    date: 2016.08.30

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local AttackAtom = {}

--[[
params:
{
    atom        攻击数据
    battleData
    callback
}
--]]
function AttackAtom.execute(params)
    local atom       = params.atom
    local battleData = params.battleData
    local from       = atom.from
    local to         = atom.to
    local fromNode   = battleData:getHeroNode(from.posId)

    local exec = function()
        AttackAtom.executeNormal(battleData, atom, function()
            if params.afterExec then
                -- 执行后触发
                params.afterExec(function()
                    if params.callback then
                        return params.callback()
                    end
                end)
            elseif params.callback then
                return params.callback()
            end
        end)
    end

    -- 执行
    if params.beforeExec then
        -- 执行前触发
        params.beforeExec(exec)
    else
        -- 正式执行
        exec()
    end
end

-- @执行事件
function AttackAtom.executeEvent(battleData, atom, key, cb)
    local to = atom.to

    bd.func.each(to, function(cont, v)
        if v[key] then
            bd.atom.execute({
                atoms      = v[key],
                battleData = battleData,
                callback   = function()
                    cont()
                end,
            })
        else
            cont()
        end
    end, cb)
end

-- @播放施法提示
function AttackAtom.castingTips(battleData, params)
    local node = battleData:getHeroNode(params.posId)
    if node and (true ~= node.isDead_) then
        battleData:emit(bd.event.eCastTip, node.idx)

        local checker = bd.func.getChecker(params.callback, 2)

        if bd.project == "project_shediao" then
            local pos = bd.interface.getStandPos(node.idx)
            battleData:get_battle_layer():cameraTo(pos, 1.5, 0.2, function()
                bd.func.performWithDelay(function()
                    battleData:get_battle_layer():cameraTo(cc.p(0, 0), 1, 0, checker)
                end, 0.5)
            end)
        else
            checker()
        end

        bd.audio.playSound("effect_c_nujichufa.mp3")
        bd.interface.newEffect({
            effectName    = bd.ui_config.castingEffect[1],
            animation     = bd.ui_config.castingEffect[2],
            loop          = false,
            endRelease    = true,
            parent        = node,
            scale         = 1.1,
            position      = cc.p(0, 100),
            zorder        = 1,
            eventListener = function(p)
                if p.event.stringValue == "start" and params.callback then
                    checker()
                end
            end
        })

        return -- **
    end

    return params.callback()
end

-- @普通攻击(目前与怒击合用)
function AttackAtom.executeNormal(battleData, atom, cb)
    local from     = atom.from
    local to       = atom.to
    local fromNode = battleData:getHeroNode(from.posId)
    local isSkill = true
    if type(fromNode.normalId) == "table" then
        for i , v in ipairs(fromNode.normalId) do
            if v == atom.skillId then
                isSkill = false
                break
            end
        end
    else
        isSkill = (fromNode.normalId ~= atom.skillId)
    end
    if isSkill and bd.project ~= "project_shediao" then
        -- 射雕在函数结尾调用切屏后通知
        battleData:emit(bd.event.eCasting, from.posId, to, atom.skillId)
    end

    -- 当人物攻击动作完成，已经伤害结算完毕后，再回调cb
    local both_end = bd.func.getChecker(function()
        if isSkill then
            battleData:emit(bd.event.eCasted, from.posId, to)
        end
        return cb()
    end, 2)

    local damage_end = bd.func.getChecker(function()
        -- 执行攻击后atoms
        AttackAtom.executeEvent(battleData, atom, "afterExec", both_end)
    end, 2)

    local first = true
    local deadonce = false
    local damage = function(percent, target, all)
        local function _doDamage()
            target = target and {target} or all or to
            for i , v in ipairs(target) do
                if v.value then
                    AttackAtom.damageOne(battleData, v.value, percent, from.posId)
                end
            end

            -- 如果所有目标的伤害数据都执行完成，调用both_end
            local check_ = bd.func.getChecker(function()
                for i, v in ipairs(all or to) do
                    if v.value and v.value.dead then
                        bd.atom.dead(battleData, v.value.dead)
                    end
                end

                damage_end()
            end, all and #all or #to)

            for i, v in ipairs(all or to) do
                if v.value and v.value.rest and v.value.rest.end_ then
                    check_()
                elseif not v.value then
                    check_()
                else
                    break
                end
            end
        end

        if first then
            first = false

            if atom.onExec then
                bd.atom.execute({
                    atoms      = atom.onExec,
                    battleData = battleData,
                })
            end
            -- 造成数值变化时触发
            AttackAtom.executeEvent(battleData, atom, "onExec", _doDamage)
        else
            _doDamage()
        end
    end

    local action = isSkill and "nuji" or "pugong"

    -- 射雕组合技，将一人施法模拟成两人同时施法
    -- 将施法者的伤害拆分30%给副将释放怒击
    local copy, copy_node
    if ld.checkComboSkill(atom.skillId) and bd.project == "project_shediao" then
        local pp = battleData:getHeroPartnerPos(from.posId)
        local node = battleData:getHeroNode(pp)
        local helper = {
            [12012404] = true,
            [12013404] = true,
            [12013502] = true,
            [12012502] = true,
            [19010006] = true,
            [12011404] = true,
        }
        if pp and node then
            if helper[node.heroId] then
                copy_node = node
            else
                copy = {
                    from    = {posId = pp},
                    to      = {},
                    skillId = type(node.skillId) == "table" and node.skillId[1] or node.skillId,
                }
                for i, v in ipairs(to) do
                    if v.value then
                        copy.to[i] = {
                            posId = v.posId,
                            value = {
                                orghp  = v.value.orghp and math.ceil(v.value.orghp * 0.3),
                                hp     = v.value.hp and math.ceil(v.value.hp * 0.3),
                                type   = v.value.type,
                                effect = v.value.effect,
                                posId  = v.value.posId,
                            },
                        }
                        v.value.orghp = v.value.orghp and (v.value.orghp - copy.to[i].value.orghp)
                        v.value.hp    = v.value.hp and (v.value.hp - copy.to[i].value.hp)
                    end
                end

                both_end = bd.func.getChecker(function()
                    if isSkill then
                        battleData:emit(bd.event.eCasted, from.posId, to)
                    end
                    return cb()
                end, 3)
            end
        end
    end

    if isSkill and bd.project == "project_shediao" then
        local function next_()
            battleData:emit(bd.event.eCasting, from.posId, to, atom.skillId)
            if copy then
                AttackAtom.executeAction(battleData, copy, action, function(p, target)
                    damage(p, target, copy.to)
                end, both_end, cc.p(-50*Adapter.MinScale, 50*Adapter.MinScale))
            else
                if copy_node then
                    bd.func.performWithDelay(copy_node, function()
                        copy_node:setLocalZOrder(-copy_node:getPositionY())
                        copy_node.state_else_.skilling = copy_node.state_else_.skilling + 1
                        copy_node:action_skill({})
                    end, 0.5 + battleData:actTime(0.2))
                end
                damage_end()
            end
            AttackAtom.executeAction(battleData, atom, action, damage, both_end, cc.p(50*Adapter.MinScale, -50*Adapter.MinScale))
        end

        if bd.interface.isFriendly(from.posId) and (not battleData:get_battle_params().data.guider) and not atom.isPet3 then
            -- 播放蓄力
            AttackAtom.castingTips(battleData, {
                posId    = from.posId,
                force    = true,
                callback = function()
                    bd.layer.parentLayer:addChild(bd.patch.skillFeature.new({
                        pos      = {[1] = {pos = from.posId, skillId = atom.skillId}},
                        callback = next_,
                        battleData = battleData,
                    }), bd.ui_config.zOrderSkill)
                end,
            })

        else
            next_()
        end
    else
        damage_end()
        AttackAtom.executeAction(battleData, atom, action, damage, both_end)
    end
end


-- @执行攻击动作
--[[
    包括移动、普攻/怒击、播放特效、受攻击方挨打
]]
function AttackAtom.executeAction(battleData, atom, action, damage, cb, offset)
    local from     = atom.from
    local to       = atom.to
    local fromNode = battleData:getHeroNode(from.posId)
    local skill_config

    if not atom.isPet3 then
        skill_config = bd.interface.getSkillById(atom.skillId)
    else
        skill_config = bd.interface.getPet3SkillById(fromNode.heroId, fromNode.step, atom.skillId)
    end

    -- 保存被攻击结点
    local attackNodes = {}
    local moved = false
    if bd.project == "project_shediao" then
        for _, v in ipairs(to) do
            local node = battleData:getHeroNode(v.posId)
            if node then
                table.insert(attackNodes, node)
            end
        end
    end

    -- 将被攻击者抓到中场
    if bd.project == "project_shediao" and skill_config.zhua and next(attackNodes)
      then
        moved = true
        battleData:emit(bd.event.eBeHit, from.posId, atom.to)
        bd.patch.moveAttackTargets(attackNodes)
        for _, v in ipairs(attackNodes) do
            v.state_else_.hitting = v.state_else_.hitting +  1
        end
    end

    -- 移动位置、特效位置、是否翻转
    -- 宠物提前获取
    local petMoveType, petMoveOffset
    if atom.isPet3 then
        petMoveType, petMoveOffset = bd.interface.getPet3MoveConfig(fromNode.heroId, fromNode.step, atom.skillId)
    end
    local mp, ep, skew = bd.interface.getAttackPos(atom, petMoveType, petMoveOffset)

    --- 还原人物站位
    local function reset_node()
        if mp then
            -- 移动回原地
            if fromNode.state_else_.hitting < 1 then
                fromNode:move_to(bd.interface.getStandPos(from.posId), function()
                    if skew ~= nil then
                        fromNode.figure:setRotationSkewY(bd.ui_config.posSkew[from.posId] and 180 or 0)
                    end

                    battleData:emit(bd.event.eMoveBack, from.posId)
                end)
            else
                battleData:emit(bd.event.eMoveBack, from.posId)
            end
        end

        if moved then
            -- 将被攻击者位置还原
            for _, v in ipairs(attackNodes) do
                v:move_to(bd.interface.getStandPos(v.idx))
                v.state_else_.hitting = v.state_else_.hitting -  1
            end

            battleData:emit(bd.event.eBeHitted, from.posId, atom.to)
        end
    end

    local function exec()
        -- 执行攻击前atoms
        AttackAtom.executeEvent(battleData, atom, "beforeExec", function()
            if atom.rp then
                -- 施法时，立即清空怒气
                bd.atom.execute({
                    atoms      = {atom.rp},
                    battleData = battleData,
                })
            end

            -- 怒击动作
            local func
            if action == "pugong" then
                func = fromNode.action_attack
            else
                func = fromNode.action_skill
            end

            local dmgTimes = 0
            local audioTimes = 0

            func(fromNode, {
                event = function(p)
                    -- 处理打击点
                    local value = bd.interface.getActionValue_daji(p.event.stringValue)
                    if value then
                        local explode = skill_config.explode
                        if not explode then
                            explode = bd.interface.getSkillById(-1).explode
                            bd.log.warnning(string.format("hero(%s)&skill(%s): explode proc not found.",fromNode.figureName, atom.skillId))
                        end
                        dmgTimes = dmgTimes + 1
                        explode({
                            from           = from.posId,
                            to             = to,
                            data           = battleData,
                            event          = p.event,
                            dmgTimes       = dmgTimes,
                            effectPos      = clone(ep),
                            attackCallback = function()
                                damage(value)
                            end,
                        })

                    -- 显示特效
                    elseif p.event.stringValue == "effect" then
                        local excute = skill_config.excute
                        if not excute then
                            excute = bd.interface.getSkillById(-1).excute
                            bd.log.warnning(string.format("hero(%s)&skill(%s): excute proc not found.", fromNode.figureName, atom.skillId))
                        end
                        -- 播放技能特效
                        excute({
                            from           = from.posId,
                            to             = to,
                            effectPos      = ep,
                            data           = battleData,
                            event          = p.event,
                            attackCallback = damage,
                        })

                    -- 播放音效
                    elseif p.event.stringValue == "audio" and skill_config.audiofunc then
                        audioTimes = audioTimes + 1
                        skill_config.audiofunc(audioTimes)

                    -- 隐藏挨打者
                    elseif p.event.stringValue == "hide_targets" then
                        for _, v in ipairs(to) do
                            local node = battleData:getHeroNode(v.posId)
                            if node then
                                node:setVisible(false)
                            end
                        end

                    -- 显示挨打者
                    elseif p.event.stringValue == "show_targets" then
                        for _, v in ipairs(to) do
                            local node = battleData:getHeroNode(v.posId)
                            if node then
                                node:setVisible(true)
                            end
                        end

                    -- 动作结束，还原人物位置
                    elseif p.event.stringValue == "end" then
                        reset_node()
                        cb()
                    end
                end,
            })
        end)
    end

    if skew ~= nil then
        fromNode.figure:setRotationSkewY(skew and 180 or 0)
    end

    local function goon()
        if action == "nuji" and bd.project == "project_shediao" then
            bd.interface.newEffect({
                parent     = bd.layer.parentLayer,
                zorder     = zOrderScreen,
                effectName = "effect_nujifenwei",
                scale      = bd.ui_config.MinScale,
                position   = cc.p(bd.ui_config.cx, bd.ui_config.cy),
            })
        end
        -- 移动到攻击位置
        if mp then
            mp = offset and cc.vec3(offset.x + mp.x, offset.y+mp.y, mp.z) or mp

            battleData:emit(bd.event.eMoveOut, from.posId)
            fromNode:move_to(mp, function()
                -- 将攻击者放在上层
                if next(attackNodes) and bd.project == "project_shediao" then
                    local attackNum = #attackNodes <= 6 and #attackNodes or 6
                    local p = bd.patch.attackMoveOffset[attackNum][1]
                    fromNode:setLocalZOrder(-p.y)
                end
                exec()
            end)
        else
            exec()
        end
    end

    if bd.project == "project_shediao" and bd.interface.isFriendly(from.posId) then
        bd.func.performWithDelay(goon, 0.5)
    else
        goon()
    end
end


-- @对人物数据进行修改
function AttackAtom.damageOne(battleData, to, percent, from)
    local percent_hundred = percent * 100
    if not to.rest then
        to.rest = {hp = to.hp or 0, orghp = to.orghp , rp = to.rp or 0, percent = 100}

        local ValueAtom = require("ComBattle.Atom.ValueAtom")
        ValueAtom.checkSpecialValue({
            battleData = battleData,
            value      = to,
        })
    end

    if (to.hp and to.hp < 0) or (to.orghp and to.orghp < 0) then
        --加血不会挨打动作
        battleData:getHeroNode(to.posId):action_hit()
    end

    -- 判断伤害是否结算完
    local _end = to.rest.percent <= percent_hundred
    to.rest.end_ = _end
    to.rest.percent = to.rest.percent - percent_hundred

    bd.log.debug(percent, "damage percent")
    bd.log.debug(to, "target value info after calc")
    if _end and to.rest.percent < 0 then
        bd.log.error(to, TR("伤害结算溢出"))
    end

    local hpDelta, rpDelata , hporgDelta = 0, 0 , nil
    if _end then
        hpDelta = to.rest.hp
        rpDelata = to.rest.rp
        hporgDelta = to.rest.orghp
    else
        -- hp 变化值
        if to.hp then
            if to.hp > 0 then
                hpDelta = math.ceil(to.hp * percent)
            elseif to.hp < 0 then
                hpDelta = math.floor(to.hp * percent)
            end
        end

        -- rp 变化值
        if to.rp and to.rp ~= 0 then
            rpDelata = math.ceil(to.rp * percent)
        end

        if to.orghp then
            if to.orghp > 0 then
                hporgDelta = math.ceil(to.orghp * percent)
            elseif to.orghp < 0 then
                hporgDelta = math.floor(to.orghp * percent)
            end
        end
    end

    -- 显示HP变化
    if (hporgDelta) or (hpDelta ~= 0) then
        to.rest.hp = to.rest.hp - hpDelta
        battleData:fixHP({
            posId = to.posId,
            value = hpDelta,
            type  = to.effect,
            ORGHP = hporgDelta,
            from  = from
        })
    end
    -- 显示RP变化
    if rpDelata ~= 0 then
        to.rest.rp = to.rest.rp - rpDelata
        battleData:fixRP({posId = to.posId, value = rpDelata})
    end
end

return AttackAtom
