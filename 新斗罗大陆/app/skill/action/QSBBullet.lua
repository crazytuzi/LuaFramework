--[[
    Class name QSBBullet
    Create by julian 

    damage_scale                伤害放缩系数
    property_promotion          改变actor身上的属性值，只在本次hit生效
--]]

local QSBAction = import(".QSBAction")
local QSBBullet = class("QSBBullet", QSBAction)

local QSkill = import("...models.QSkill")
local QBullet = import("...models.QBullet")
local QBezierBullet = import("...models.QBezierBullet")
local QBezierBullet2 = import("...models.QBezierBullet2")

QSBBullet.TIME_INTERVAL = 1.0 / 30

local function _func(target)
    local target_pos = target:getPosition()
    return not app.grid:_toGridPos(target_pos.x, target_pos.y)
end

function QSBBullet:_execute(dt)
    -- 自动寻找活着的目标，并且允许箭矢对着尸体消失的位置射击
    self._director:chooseTarget()
    self._options.dead_ok = true
    local attack_outside = self._options.attack_outside or false
	if self._skill:getBulletEffectID() == nil and self._options.effect_id == nil then
		self:finished()
        return
	end

    if self._options.check_target_by_skill then
        local skill = self._skill
        local skill_type = skill:getAttackType()
        local hero = self._attacker
        local target = self._target
        if skill_type == skill.TREAT then
            local need_change = false
            if target == nil then
                need_change = true
            else
                if hero:getType() == ACTOR_TYPES.NPC then
                    need_change = target:getType() ~= ACTOR_TYPES.NPC
                else
                    need_change = target:getType() == ACTOR_TYPES.NPC
                end
            end
            if need_change then
                local actors = app.battle:getMyTeammates(hero, true)
                local len = #actors
                if len > 0 then
                    target = actors[app.random(1, len)]
                end
            end
        else
            local need_change = false
            if target == nil then
                need_change = true
            else
                if hero:getType() == ACTOR_TYPES.NPC then
                    need_change = target:getType() == ACTOR_TYPES.NPC
                else
                    need_change = target:getType() ~= ACTOR_TYPES.NPC
                end
            end
            if need_change then
                local actors = app.battle:getMyEnemies(hero)
                local len = #actors
                if len > 0 then
                    target = actors[app.random(1, len)]
                end
            end
        end
        self._target = target
    end

    if self._options.selectTarget == nil then
        -- get targets
        if self._options.target_random then
            local actors
            if self._options.attack_outside then
                actors = app.battle:getMyEnemies(self._attacker)
            else
                actors = {}
                table.mergeForArray(actors,app.battle:getMyEnemies(self._attacker),_func)
            end
            if #actors > 0 then
                if self._options.random_num then
                    self._targets = {}
                    for i = 1, self._options.random_num, 1 do
                        if #actors > 0 then
                            local idx = app.random(1, #actors)
                            table.insert(self._targets, actors[idx])
                            table.remove(actors, idx)
                        else
                            break
                        end
                    end
                else
                    self._targets = {actors[app.random(1, #actors)]}
                end
            else
                self:finished()
                return
            end
        -------新增随机队友目标-------tdy
        elseif self._options.target_teammate_random then
            local actors = {}
            if self._options.attack_outside then
                table.mergeForArray(actors,app.battle:getMyTeammates(self._attacker),function (v) return not v:isSupport() end)
            else
                table.mergeForArray(actors,app.battle:getMyTeammates(self._attacker),function (v) return not v:isSupport() and _func(v) end)
            end
            if #actors > 0 then
                if self._options.random_num then
                    self._targets = {}
                    for i = 1, self._options.random_num, 1 do
                        if #actors > 0 then
                            local idx = app.random(1, #actors)
                            table.insert(self._targets, actors[idx])
                            table.remove(actors, idx)
                        else
                            break
                        end
                    end
                else
                    self._targets = {actors[app.random(1, #actors)]}
                end
            else
                self:finished()
                return
            end
        -------------------------------tdy
        elseif self._options.target_teammate_lowest_hp_percent or self._options.teammate_and_self_lowest_hp_percent then
            local actors = app.battle:getMyTeammates(self._attacker, self._options.teammate_and_self_lowest_hp_percent, self._options.justHero)
            if #actors > 0 then
                table.sort(actors, function(actor1, actor2)
                    local hppercent1 = actor1:getHp() / actor1:getMaxHp()
                    local hppercent2 = actor2:getHp() / actor2:getMaxHp()
                    if hppercent1 > hppercent2 then
                        return false
                    elseif hppercent1 < hppercent2 then
                        return true
                    else
                        return tonumber(actor1:getActorID()) > tonumber(actor2:getActorID())
                    end
                end)
                self._targets = {actors[1]}
            else
                self:finished()
                return
            end
        elseif self._options.enemy_lowest_hp_percent then
            local actors = app.battle:getMyEnemies(self._attacker)
            if #actors > 0 then
                table.sort(actors, function(actor1, actor2)
                    local hppercent1 = actor1:getHp() / actor1:getMaxHp()
                    local hppercent2 = actor2:getHp() / actor2:getMaxHp()
                    if hppercent1 > hppercent2 then
                        return false
                    elseif hppercent1 < hppercent2 then
                        return true
                    else
                        return tonumber(actor1:getActorID()) > tonumber(actor2:getActorID())
                    end
                end)
                self._targets = {actors[1]}
            else
                self:finished()
                return
            end
        elseif self._skill:getRangeType() == QSkill.MULTIPLE and not self._options.single then
            self._targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target)
            if self._options.target_with_buff then
                local targets = {}
                table.mergeForArray(targets, self._targets, function(target)
                    if target:getBuffByID(self._options.target_with_buff) then
                        return true
                    else
                        return false
                    end
                end)
                self._targets = targets
            end
        else
            if self._target then
                self._targets = {self._target}
            else
                self._targets = {self._attacker:getTarget()}
            end
            -- 可以额外击中一个目标
            local additional_target = self._skill:isAdditionalTarget()
            if additional_target then
                local target = self._targets[1]
                local teammates = app.battle:getMyTeammates(target, false)
                if #teammates > 0 then
                    if additional_target == true then
                        table.sort(teammates, function(t1, t2)
                            local d1 = q.distOf2Points(target:getPosition(), t1:getPosition())
                            local d2 = q.distOf2Points(target:getPosition(), t2:getPosition())
                            if d1 ~= d2 then
                                return d1 < d2
                            else
                                return t1:getUUID() < t2:getUUID()
                            end
                        end)
                    else -- other mean hp lowest
                        table.sort(teammates, function(t1, t2)
                            local h1 = t1:getHp() / t1:getMaxHp()
                            local h2 = t2:getHp() / t2:getMaxHp()
                            if h1 ~= h2 then
                                return h1 < h2 
                            else
                                return t1:getUUID() < t2:getUUID()
                            end
                        end)
                    end
                    table.insert(self._targets, teammates[1])
                end
            end
        end
    else
        self._targets = {self._options.selectTarget}
    end

    if self._options.selectTargets then
        self._targets = self._options.selectTargets
    end

    if #self._targets == 0 and not self._options.is_tornado then
        self:finished()
        return
    end

    -- create bullet
    if app.scene == nil or app.scene:getActorViewFromModel(self._attacker) ~= nil then
        -- hot fix
        if IsServerSide then
            local actor = self._attacker
            if actor:isGhost() and app.battle:isPVPMultipleWave() 
                and actor.pvp_born_wave and actor.pvp_born_wave ~= app.battle:getCurrentPVPWave()
            then
                self:finished()
                return
            end
        end

        if self._options.is_bezier then
            local set_points = self._options.set_points or {}
            local aniAtkIdx = self._options.ani_atk_idx
            local points = set_points[aniAtkIdx]
            if not points then
                aniAtkIdx = app.random(1, #set_points)
                points = set_points[aniAtkIdx]
            end
            self._options.points = clone(points)
            local bullet = QBezierBullet.new(self._attacker, self._targets, self._director, self._options)
            app.battle:addBullet(bullet)
        elseif self._options.is_bezier2 then
            local set_points = self._options.set_points or {}
            local aniAtkIdx = self._options.ani_atk_idx
            local points = set_points[aniAtkIdx]
            if not points then
                aniAtkIdx = app.random(1, #set_points)
                points = set_points[aniAtkIdx]
            end
            self._options.points = clone(points)
            local bullet = QBezierBullet2.new(self._attacker, self._targets, self._director, self._options)
            app.battle:addBullet(bullet)
        else
            local bullet = QBullet.new(self._attacker, self._targets, self._director, self._options)
            app.battle:addBullet(bullet)
        end
    end

    if app.battle._battleVCR then
        app.battle._battleVCR:_onBulletCreated(bullet)
    end

    self:finished()
end

function QSBBullet:_onCancel()

end

function QSBBullet:_onReset()
    self._targets = nil
end

return QSBBullet
