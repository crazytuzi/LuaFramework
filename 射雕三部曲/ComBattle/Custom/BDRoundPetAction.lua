--[[
    filename: ComBattle.Custom.BDRoundPetAction
    description: 宠物技能表现
    date: 2017.01.10

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDRoundPetAction = class("BDRoundPetAction", function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
end)

local AttackAtom = require("ComBattle.Atom.AttackAtom")

--[[
params:
{
    battleData
    atoms
    callback
}
]]
function BDRoundPetAction:ctor(params)
    dump("BDRoundPetAction:ctor")
    local atoms      = params.atoms
    local battleData = params.battleData
    local buff       = battleData:getBuffItem(atoms[1].buffId)
    local isFriendly = bd.interface.isFriendly(atoms[1].fromPos)

    local petsData = battleData:getCurrentStageData().PetList
    local roundIdx = battleData:get_stage_roundIdx()

    if not isFriendly then
        roundIdx = roundIdx + 6
    end

    -- 通过roundIdx在Pet数据中查找
    local petData = petsData[roundIdx] and next(petsData[roundIdx]) and petsData[roundIdx]

    if not petData then
        bd.log.dataerr(atoms, TR("执行回合技时，没有找到对应的petData"))
        bd.func.performWithDelay(self, function()
            self:removeFromParent()
        end, 0)
        return params.callback()
    end

    self:execute(battleData, atoms, isFriendly, petData, function()
        bd.func.performWithDelay(self, function()
            self:removeFromParent()
            return params.callback and params.callback()
        end, battleData:actTime(0.5))
    end)
end


-- @
function BDRoundPetAction:execute(battleData, atoms, isFriendly, petData, cb)
    self:skillEffect(battleData, atoms, isFriendly, petData, cb)
end


-- @技能效果
function BDRoundPetAction:skillEffect(battleData, to, isFriendly, petData, cb)
    local item = PetModel.items[petData.HeroModelId]

    local skill_config = require(string.format("BattleSkillConfig.%s", item.skillEffectCode))

    if not skill_config.excute then
        bd.log.error(TR("回合技:%s没有execute函数", item.skillEffectCode))
    end

    -- 统计数值atom数量
    -- 有的宠物是加护盾的，没有伤害
    local pureAtom_before = {}       -- 没有伤害/治疗
    local pureAtom_after = {}       -- 没有伤害/治疗
    local valueAtom = {}      -- 有伤害/治疗
    local valueCnt = 0

    for i = #to, 1, -1 do
        local v = to[i]
        if v.value then
            valueCnt = valueCnt + #v.value
            table.insert(valueAtom, v)
        elseif valueCnt == 0 then
            table.insert(pureAtom_before, v)
        else
            table.insert(pureAtom_after, v)
        end
    end

    local fromPos = petData.FormationId + (isFriendly and 0 or 6)
    local fromNode = battleData:getHeroNode(fromPos)
    if not fromNode then
        return cb()
    end

    local first, moved = true, false
    -- 保存被攻击结点
    local attackNodes = {}
    if bd.project == "project_shediao" then
        for _, v in ipairs(valueAtom) do
            local node = battleData:getHeroNode(v.posId)
            if node then
                table.insert(attackNodes, node)
            end
        end
    end

    -- 执行其他buff增减
    local function after_valuAtom(callback)
        self:executeEvent(battleData, pureAtom_after, "beforeExec", function()
            self:executeEvent(battleData, pureAtom_after, "onExec", function()
                self:executeEvent(battleData, pureAtom_after, "afterExec", function()
                    if valueCnt ~= 0 then
                        battleData:emit(bd.event.eCasted, fromPos, valueAtom)
                    end

                    if moved then
                        -- 将被攻击者位置还原
                        for _, v in ipairs(attackNodes) do
                            v:move_to(bd.interface.getStandPos(v.idx))
                        end
                        battleData:emit(bd.event.eBeHitted, fromPos, valueAtom)
                    end

                    -- 移动回原地
                    -- fromNode:move_to(bd.interface.getStandPos(fromPos), function()
                    --     battleData:emit(bd.event.eMoveBack, fromPos)
                    --     fromNode.figure:setRotationSkewY(bd.ui_config.posSkew[fromPos] and 180 or 0)
                    -- end)

                    return callback()
                end)
            end)
        end)
    end

    if valueCnt == 0 then
        pureAtom_after = pureAtom_before
        pureAtom_before = {}
        return after_valuAtom(cb)
    end

    -- 执行其他buff增减
    local function before_valuAtom(callback)
        self:executeEvent(battleData, pureAtom_before, "beforeExec", function()
            self:executeEvent(battleData, pureAtom_before, "onExec", function()
                self:executeEvent(battleData, pureAtom_before, "afterExec", callback)
            end)
        end)
    end

    -- 伤害结算
    local function atkCb(percent, target)
        target = target and {target} or to

        local function _doDamage()
            -- 伤害显示
            for _, v in ipairs(target) do
                if v.value then
                    for _, val in ipairs(v.value) do
                        AttackAtom.damageOne(battleData, val, percent)
                    end
                end
            end

            -- 如果所有目标的伤害数据都执行完成，调用cb
            local function all_done()
                -- 检查死亡的目标
                for _, v in ipairs(to) do
                    if v.value then
                        for _, val in ipairs(v.value) do
                            if val.dead then
                                bd.atom.dead(battleData, val.dead)
                            end
                        end
                    end
                end

                -- 执行攻击后atoms
                self:executeEvent(battleData, valueAtom, "afterExec", function()
                    after_valuAtom(cb)
                end)
            end

            local check_ = bd.func.getChecker(all_done, valueCnt)

            for _, v in ipairs(to) do
                if v.value then
                    -- 检查是否所有目标的伤害结算完成
                    for _, val in ipairs(v.value) do
                        if val.rest and val.rest.end_ then
                            check_()
                        else
                            break
                        end
                    end
                end
            end
        end

        if valueCnt ~= 0 and first then
            first = false
            self:executeEvent(battleData, valueAtom, "beforeExec", _doDamage)
        else
            _doDamage()
        end
    end

    local baseNode = cc.Node:create()
    fromNode:addFollowNode(baseNode, 1)

    -- 冒光
    bd.interface.newEffect({
        parent     = baseNode,
        effectName = "effect_wg_tongyichufa",
        position   = pos,
        scale      = Adapter.MinScale,
        endRelease = true,
        completeListener = function()
            -- 切屏
            local layer = bd.patch.skillFeature.new({
                battleData = battleData,
                pos = {
                    [1] = {pos = fromPos},
                },
                petID    = petData.HeroModelId,
                callback = function()
                    battleData:emit(bd.event.eCasting, fromPos, valueAtom)

                    -- battleData:emit(bd.event.eMoveOut, fromPos)

                    -- local movePos = bd.interface.getStandPos(14)
                    -- movePos.x = movePos.x + (60 * bd.ui_config.MinScale * (bd.interface.isFriendly(fromPos) and -1 or 1))
                    -- fromNode:move_to(movePos, function()
                    --     -- 将攻击者放在上层
                    --     if next(attackNodes) then
                    --         local p = bd.patch.attackMoveOffset[math.max(#attackNodes, 6)][1]
                    --         fromNode:setLocalZOrder(-p.y)
                    --     end
                    -- end)

                    -- 将被攻击者抓到中场
                    if bd.project == "project_shediao" and skill_config.zhua and next(attackNodes)
                      then
                        moved = true
                        battleData:emit(bd.event.eBeHit, fromPos, valueAtom)
                        bd.patch.moveAttackTargets(attackNodes)
                    end

                    bd.func.performWithDelay(self, function()
                        before_valuAtom(function()
                            skill_config.excute({
                                from           = valueAtom[1].fromPos,
                                to             = valueAtom,
                                data           = battleData,
                                attackCallback = atkCb,
                            })
                        end)
                    end, 0.5)
                end,
            })

            bd.layer.parentLayer:addChild(layer, bd.ui_config.zOrderSkill)
        end,
    })
end


-- @执行事件
function BDRoundPetAction:executeEvent(battleData, to, key, cb)
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


-- 背景
function BDRoundPetAction:skillBg(battleData)
    local speedLineNode = cc.Node:create()
    self:addChild(speedLineNode)
    self.speedLineNode = speedLineNode

    local time = 0.3
    local limitLeft = 100 * bd.ui_config.MinScale
    local limitRight = bd.ui_config.width - limitLeft
    local function randomRes(params)
        for i = 1 , params.number do
            local tmp = params.fit(i , params.number)
            if math.random(0,tmp) == 0 then
                local t1_x = (limitRight - limitLeft) / params.number * (i-0.5) + limitLeft
                local t2_x = (limitRight - limitLeft) / params.number * (i+0.5) + limitLeft
                local x = math.random(t1_x , t2_x)
                local y = params.fromY

                local resList = {
                    "zd_48.png",
                    "zd_49.png",
                    "zd_50.png",
                }
                local sprite = cc.Sprite:create(resList[math.random(1,#resList)])
                sprite:setPosition(cc.p(x , y))
                sprite:setScale(bd.ui_config.MinScale)
                params.parent:addChild(sprite , params.zorder)
                sprite:runAction(cc.Sequence:create({
                    cc.MoveBy:create(battleData:actTime(math.random(1,10)/10 + time), cc.p(0 , params.toY)),
                    cc.CallFunc:create(function( ... )
                        sprite:removeFromParent()
                    end)
                }))
            end
        end
    end

    randomRes({
        parent = speedLineNode,
        fromY  = bd.ui_config.height + 800*bd.ui_config.MinScale ,
        toY    = -2800*bd.ui_config.MinScale,
        zorder = 0,
        number = 11,
        fit    = function(i , number)
            local mid = math.ceil(number/2)
            return 0.5 * (i-mid)*(i-mid)
        end,
    })
    randomRes({
        parent = speedLineNode,
        fromY  = -500*bd.ui_config.MinScale,
        toY    = bd.ui_config.height + 1000*bd.ui_config.MinScale,
        zorder = 2,
        number = 5,
        fit    = function(i , number)
            return number*2
        end,
    })

    self.speedLineNode:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.DelayTime:create(battleData:actTime(time / 2)),
        cc.CallFunc:create(function()
            randomRes({
                parent = speedLineNode,
                fromY  = bd.ui_config.height + 800*bd.ui_config.MinScale ,
                toY    = - 2800*bd.ui_config.MinScale,
                zorder = 0,
                number = 11,
                fit    = function(i , number)
                    local mid = math.ceil(number/2)
                    return 0.5 * (i-mid)*(i-mid)
                end,
            })
            randomRes({
                parent = speedLineNode,
                fromY  = - 500*bd.ui_config.MinScale,
                toY    = bd.ui_config.height + 1000*bd.ui_config.MinScale,
                zorder = 2,
                number = 5,
                fit    = function(i , number)
                    return number*2
                end,
            })
        end),
    })))

    local sprite = cc.Sprite:create("zd_47.png")
    self.display_bg = sprite
    sprite:setPosition(cc.p(bd.ui_config.cx , -bd.ui_config.width))
    self:addChild(sprite)

    sprite:runAction(cc.MoveTo:create(battleData:actTime(0.3), cc.p(bd.ui_config.cx , bd.ui_config.cy)))
end


return BDRoundPetAction
