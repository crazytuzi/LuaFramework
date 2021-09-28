------------------------------------------------------
module(..., package.seeall)

local require = require

-- global def
require("i3k_global");
require("logic/entity/i3k_entity_trap_def");


------------------------------------------------------
i3k_trap_base = i3k_class("i3k_trap_base");
function i3k_trap_base:ctor(entity)
	self._entity	= entity;
	self._turnOn	= false;
	self._type	= eSTrapBase;
end

function i3k_trap_base:OnEnter()
	if not self._turnOn then
		self._turnOn = true;

		return true;
	end

	return false;
end

function i3k_trap_base:OnLeave()
	if self._turnOn then
		self._turnOn = false;

		return true;
	end

	return false;
end

function i3k_trap_base:IsTurnOn()
	return self._turnOn;
end


function i3k_trap_base:IsValid()
	return true;
end

function i3k_trap_base:OnUpdate(dTime)
	if not self:IsValid() then
		return false;
	end

	return true;
end

function i3k_trap_base:OnLogic(dTick)
	if not self:IsValid() then
		return false;
	end

	return true;
end

function create_component(entity, priority)
	return i3k_trap_base.new(entity, priority);
end

