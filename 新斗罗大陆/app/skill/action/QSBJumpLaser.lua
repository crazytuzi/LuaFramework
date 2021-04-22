--[[

    激光弹射类
    options:
    jump_num:弹射的数目 默认为1 不包括被攻击者本身
    
    这个脚本会让switch_target失效
    在魔兽脚本的基础上优化了表现
--]]
local QSBAction = import(".QSBAction")
local QSBJumpLaser = class("QSBJumpLaser", QSBAction)

local QLaser = import("...models.QLaser")

-- options中会有apply_buffIds传递到QLaser中
function QSBJumpLaser:ctor(director, attacker, target, skill, options)
    QSBJumpLaser.super.ctor(self, director, attacker, target, skill, options)
    self._jump_num = options.jump_num or 1
    self._jump_targets = {}
    self._options.on_hit_target = handler(self,self.onLaserHitTarget)
    self._options.switch_target = false
    self._cur_idx = 0
    self._lasers = {}
    self._canceled = false
end

function QSBJumpLaser:onLaserHitTarget(target)
    if not self._canceled and self._cur_idx < self._jump_num and self._cur_idx < #self._jump_targets then
        self:createLaser(target)
        self:finished()
    end
end

local function reSortTable(t)
    local len = #t
    for i = 1, len, 1 do
        local random_idx = app.random(1, len)
        t[i], t[random_idx] = t[random_idx], t[i]
    end
end

function QSBJumpLaser:_execute(dt)
	if self._skill:getBulletEffectID() == nil and self._options.effect_id == nil then
		self:finished()
        return
	end

    if self._jump_num < 1 then
        self:finished()
        return
    end

    if self._cur_idx > 0 then
        return
    end

    if self._options.selectTargets then
        self._jump_targets = table.mergeForArray(self._options.selectTargets)
        local FirstTarget = table.remove(self._jump_targets, 1)
        self:createLaser(FirstTarget)
    else
        self._jump_targets = app.battle:getMyTeammates(self._target)
        reSortTable(self._jump_targets )
        table.insert(self._jump_targets,1,self._target)
        self:createLaser(self._attacker)
    end
end

function QSBJumpLaser:createLaser(from_target)
    self._cur_idx = self._cur_idx + 1
    local options = clone(self._options)
    if self._cur_idx == 1 then
        options.start_pos = self._options.first_offset
    end

    options.from_target = from_target
    if from_target == self._attacker then
        options.attack_dummy = self._options.attack_dummy
    else
        options.attack_dummy = self._options.hit_dummy or db:getEffectDummyByID(self._options.effect_id or self._skill:getBulletEffectID()) or from_target:getHitDummy()
    end
    local laser =  QLaser.new(self._attacker, {self._jump_targets[self._cur_idx]}, self._skill, options)
    app.battle:addLaser(laser)
    table.insert(self._lasers, laser)
end

function QSBJumpLaser:_onCancel()
    self:_onRevert()
end

function QSBJumpLaser:_onRevert()
    for i, laser in ipairs(self._lasers) do
        laser:cancel()
    end
    self._canceled = true
end

return QSBJumpLaser