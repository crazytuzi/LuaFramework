------------------------------------------------------
module(..., package.seeall)

local require = require

-- global def
require("i3k_global");
require("logic/entity/ai/i3k_ai_def");


------------------------------------------------------
i3k_ai_base = i3k_class("i3k_ai_base");
function i3k_ai_base:ctor(entity, priority)
	self._entity	= entity;
	self._priority	= priority;
	self._turnOn	= false;
	self._timeTick	= 0;
	self._type		= eAType_BASE;
	self._name		= "undef";
end

function i3k_ai_base:SetName(name)
	self._name = name;
end

function i3k_ai_base:GetName()
	return self._name;
end

function i3k_ai_base:OnAttach()
end

function i3k_ai_base:OnDetach()
end

function i3k_ai_base:OnEnter()
	if not self._turnOn then
		self._turnOn	= true;
		self._timeTick	= 0;

		return true;
	end

	return false;
end

function i3k_ai_base:OnLeave()
	if self._turnOn then
		self._turnOn = false;

		return true;
	end

	return false;
end

function i3k_ai_base:IsTurnOn()
	return self._turnOn;
end

function i3k_ai_base:Switch()
	if not self:IsValid() then
		return false;
	end

	return true;
end

function i3k_ai_base:IsValid()
	return true;
end

function i3k_ai_base:OnUpdate(dTime)
	if not self:IsValid() then
		return false;
	end

	return true;
end

function i3k_ai_base:OnLogic(dTick)
	if not self:IsValid() then
		return false;
	end

	self._timeTick = self._timeTick + dTick * i3k_engine_get_tick_step();

	return true;
end

function i3k_ai_base:OnStopAction(action)
end

function i3k_ai_base:OnAttackAction(id)
end

function create_component(entity, priority)
	return i3k_ai_base.new(entity, priority);
end

