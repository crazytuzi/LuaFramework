----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_guard = i3k_class("i3k_ai_guard", BASE);
function i3k_ai_guard:ctor(entity)
	self._type = eAType_GUARD;
	self._tick = 0;
	if entity then
		self._tick = i3k_engine_get_rnd_u(entity._cfg.guard.tick[1], entity._cfg.guard.tick[2]);
	end
end

function i3k_ai_guard:IsValid()
	if not BASE.IsValid(self) then return false; end

	local entity = self._entity;

	if entity:IsDead() then
		return false;
	end

	if entity:GetEntityType() ~= eET_Monster then
		return false;
	end

	local mgr = entity._triMgr;
	if mgr then
		if mgr._events[eTEventIdle].valid then
			local logic = i3k_game_get_logic();
			if logic and (logic:GetLogicTick() - mgr._events[eTEventIdle].tickline) * i3k_engine_get_tick_step() >= self._tick then
				return true;
			end
		end
	end

	return false;
end

function i3k_ai_guard:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		entity._behavior:Set(eEBGuard);

		self._tick = i3k_engine_get_rnd_u(entity._cfg.guard.tick[1], entity._cfg.guard.tick[2]);

		self:UpdateGuardPath();

		return true;
	end

	return false;
end

function i3k_ai_guard:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_guard:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end

	return true;
end

function i3k_ai_guard:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	return false;
end

function i3k_ai_guard:UpdateGuardPath()
	local entity = self._entity;
	
	local pos = i3k_vec3_clone(entity._birthPos);

	local findCnt = 0;
	while true do
		local rnd_x = i3k_integer(i3k_engine_get_rnd_f(-1, 1) * entity._cfg.guard.radius);
		local rnd_z = i3k_integer(i3k_engine_get_rnd_f(-1, 1) * entity._cfg.guard.radius);

		local _pos = i3k_vec3_clone(pos);
			_pos.x = pos.x + rnd_x;
			_pos.y = pos.y;
			_pos.z = pos.z + rnd_z;
		_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos)));

		local paths = g_i3k_mmengine:FindPath(entity._curPosE, i3k_vec3_to_engine(_pos));
		if paths:size() > 0 then
			pos = paths:front();

			break;
		end

		findCnt = findCnt + 1;
		if findCnt > 5 then
			break;
		end
	end

	if findCnt > 5 then
		return false;
	end

	local movePaths = { };
	table.insert(movePaths, i3k_world_pos_to_logic_pos(pos));

	entity:MovePaths(movePaths, true);

	return true;
end

function create_component(entity, priority)
	return i3k_ai_guard.new(entity, priority);
end

