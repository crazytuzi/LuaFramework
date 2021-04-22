--[[
    根据敌人身上的状态发射激光
    from_target:发射激光的起始位置 target:技能目标, self:技能释放者  hero_target:英雄目标
    enemy_status:要检查的状态名称
    其他参数参考QSBLaser
    这个脚本会让switch_target参数无效
--]]

local QSBAction = import(".QSBAction")
local QSBLaserWithEnemyStatus = class("QSBLaserWithEnemyStatus", QSBAction)

local QSkill = import("...models.QSkill")
local QLaser = import("...models.QLaser")

function QSBLaserWithEnemyStatus:_execute(dt)
	if self._skill:getBulletEffectID() == nil and self._options.effect_id == nil then
		self:finished()
        return
	end
    self._targets = {}
    local status = self._options.enemy_status
    for i,target in ipairs(app.battle:getMyEnemies(self._attacker)) do
        if target:isUnderStatus(status) then
            table.insert(self._targets, target)
        end
    end
    self._options.enemy_status = nil
    local from_target = self._options.from_target or "target"
    if from_target then
        if from_target == "target" then
            self._options.from_target = self._target
        elseif from_target == "self" then
            self._options.from_target = self._attacker
        elseif from_target == "hero_target" then
            self._options.from_target = self._attacker:getTarget()
        else
            self._options.enemy_status = nil
        end
    end
    self._options.switch_target = false
    -- create bullet
    local laser = QLaser.new(self._attacker, self._targets, self._skill, self._options)
    app.battle:addLaser(laser)

    if app.battle._battleVCR then
        app.battle._battleVCR:_onLaserCreated(laser)
    end

    self:finished()
end

return QSBLaserWithEnemyStatus