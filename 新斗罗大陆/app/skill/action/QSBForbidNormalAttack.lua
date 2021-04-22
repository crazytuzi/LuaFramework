--[[
    Class name QSBForbidNormalAttack
    Create by wanghai
    角色不会普攻，同时不会自己移动，但是可以拖动 
--]]
local QSBAction = import(".QSBAction")
local QSBForbidNormalAttack = class("QSBForbidNormalAttack", QSBAction)

function QSBForbidNormalAttack:_execute(dt)
	if true == self._options.forbid then
		self._attacker:forbidNormalAttack()
	else
		self._attacker:allowNormalAttack()
	end

	self:finished()

	return
end

function QSBForbidNormalAttack:_onRevert()
	self._attacker:allowNormalAttack()
end

function QSBForbidNormalAttack:_onCancel()
	self._attacker:allowNormalAttack()
end


return QSBForbidNormalAttack