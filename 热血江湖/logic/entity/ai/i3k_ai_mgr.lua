------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");
require("logic/entity/ai/i3k_ai_def");

------------------------------------------------------
if jit then
	jit.off(true, true)
end

------------------------------------------------------
i3k_ai_mgr = i3k_class("i3k_ai_mgr");
function i3k_ai_mgr:ctor(entity)
	self._entity	= entity;
	self._childs	= { };
	self._child_idx	= { };
	self._activeComp
					= nil;

	-- add default ai component
	self:AddComponent(eAType_BASE);

	-- get default ai component
	self:SwitchComp();
end

function i3k_ai_mgr:AddComponent(atype)
	local ai = i3k_ai_tbl[atype];
	if ai then
		local comp = require("logic/entity/ai/" .. ai.script);
		if comp then
			local c = comp.create_component(self._entity, ai.priority);
			if c then
				c:SetName(ai.script);
				c:OnAttach();
			end
			self._childs[atype] = c;

			self:BuildIdx();
		end
	end
end

function i3k_ai_mgr:RmvComponent(atype)
	local c = self._childs[atype];
	if c then
		c:OnDetach();
	end
	self._childs[atype] = nil;

	self:BuildIdx();
end

function i3k_ai_mgr:GetActiveComp()
	return self._activeComp;
end

function i3k_ai_mgr:BuildIdx()
	self._child_idx = { };
	for k ,_ in pairs(self._childs) do
		table.insert(self._child_idx, k);
	end

	local _cmp = function(d1, d2)
		if d1 > d2 then
			return true;
		end

		return false;
	end
	table.sort(self._child_idx, _cmp);
end

function i3k_ai_mgr:SwitchComp()
	if jit then
		jit.off(true, true)
	end
	if self._entity and self._entity:IsPlayer() and g_i3k_game_context:IsInPingMode() then
		return false;
	end

	for k, v in ipairs(self._child_idx) do
		local comp = self._childs[v];
		if self._entity:IsRenderable() or (comp._priority == eAI_Priority_High) then
			if comp:Switch() then
				if self._activeComp ~= comp then
					if self._activeComp and self._activeComp:IsTurnOn() then
						self._activeComp:OnLeave();
					end

					if not comp:IsTurnOn() then
						--if self._entity:GetEntityType()==eET_Mercenary then
							--i3k_log("entity enter ai " .. comp:GetName());
					--	end
						--[[if comp._type == 16 then
							i3k_log("aiType = "..comp._type)
						end--]]
						comp:OnEnter();
					end

					self._activeComp = comp;
				end

				return true;
			end
		end
	end

	return false;
end

function i3k_ai_mgr:OnUpdate(dTime)
	if self._activeComp then
		if self._entity and self._entity:IsPlayer() and g_i3k_game_context:IsInPingMode() then
			return ;
		end
		self._activeComp:OnUpdate(dTime);
	end
end

function i3k_ai_mgr:OnLogic(dTick)
	if self._activeComp then
		if self._entity and self._entity:IsPlayer() and g_i3k_game_context:IsInPingMode() then
			return ;
		end
		if not self._activeComp:OnLogic(dTick) then
			self._activeComp:OnLeave();
			self._activeComp = nil;

			return false;
		end
	end

	return true;
end

function i3k_ai_mgr:OnStopAction(action)
	if self._activeComp then
		self._activeComp:OnStopAction(action);
	end
end

function i3k_ai_mgr:OnAttackAction(id)
	if self._activeComp then
		self._activeComp:OnAttackAction(id);
	end
end

function create_mgr(entity)
	return i3k_ai_mgr.new(entity);
end

