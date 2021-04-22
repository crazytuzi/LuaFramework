--[[
    Class name QSBTrapMultiple
    给多个目标上多个trap
    multiple_target_with_skill				如果技能是群体技能，那么从技能范围获取目标
    targets 								来自技能脚本传递的目标
    options_target							来自技能脚本传递的目标

    参数形式类似于							{trapId = "", pos = {} or target_pos or relative_pos}
--]]

local QSBNode = import("..QSBNode")
local QSBTrapMultiple = class("QSBTrapMultiple", QSBNode)
local QTrapDirector = import("...trap.QTrapDirector")

function QSBTrapMultiple:ctor(director, attacker, target, skill, options)
    QSBTrapMultiple.super.ctor(self, director, attacker, target, skill, options)
    self._trapOptions = clone(self._options.args)
end

function QSBTrapMultiple:_execute(dt)
	local actors = nil

	if self._options.multiple_target_with_skill then
		if self._skill:getRangeType() == self._skill.MULTIPLE then
			actors = self._attacker:getMultipleTargetWithSkill(self._skill)
		end
	end
	if self._options.targets then
		actors = self._options.targets
	end
	if self._options.options_target then
		actors = {self._options.options_target}
	end

	if actors ~= nil then
		for _, actor in pairs(actors) do
		    for _, option in ipairs(self._trapOptions) do
	            local pos
	            if option.pos then
	                pos = clone(option.pos)
	            elseif option.target_pos then
	                pos = clone(self._target:getPosition())    
	            else
	                pos = clone(option.relative_pos)
	                local curPos = actor:getPosition()
	                pos.x = pos.x + curPos.x
	                pos.y = pos.y + curPos.y
	            end
	            local trapDirector = QTrapDirector.new(option.trapId, pos, self._attacker:getType(), self._attacker, nil, self._skill)
	            app.battle:addTrapDirector(trapDirector)
		    end
		end
	end

    self:finished()
    return
end

return QSBTrapMultiple