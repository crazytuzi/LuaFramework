-------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


-------------------------------------------------------------
local g_i3k_dlc_mgr = nil;
function i3k_dlc_mgr_create()
	if not g_i3k_dlc_mgr then
		g_i3k_dlc_mgr = i3k_dlc_mgr.new();
	end

	return g_i3k_dlc_mgr;
end

function i3k_dlc_mgr_cleanup()
	if g_i3k_dlc_mgr then
		g_i3k_dlc_mgr:Cleanup();

		g_i3k_dlc_mgr = nil;
	end
end

function i3k_dlc_mgr_load_dlc(name)
	if g_i3k_dlc_mgr then
		return g_i3k_dlc_mgr:Load(name);
	end

	return false;
end

function i3k_dlc_mgr_get_current()
	if g_i3k_dlc_mgr then
		return g_i3k_dlc_mgr._cur_dlc;
	end

	return nil;
end

function i3k_dlc_mgr_register_dlc(name, dlc)
	if g_i3k_dlc_mgr then
		g_i3k_dlc_mgr:RegisterDLC(name, dlc);
	end
end

-------------------------------------------------------------
i3k_dlc_mgr = i3k_class("i3k_dlc_mgr", i3k_logic_state);
function i3k_dlc_mgr:ctor()
	self._dlc_tbl = { };
	self._cur_dlc = nil;
end

function i3k_dlc_mgr:Load(name)
	if self._cur_dlc then
		self._cur_dlc:Release();
		self._cur_dlc = nil;
	end

	local dlc = self._dlc_tbl[name];
	if not dlc then
		if require("dlc/" .. name) then
			dlc = self._dlc_tbl[name];
		end
	end

	if dlc then
		self._cur_dlc = dlc._inst;
	end

	return self._cur_dlc ~= nil;
end

function i3k_dlc_mgr:Cleanup()
	for v, d in pairs(self._dlc_tbl) do
		d._inst:Release();
	end
	self._dlc_tbl = { };
end

function i3k_dlc_mgr:RegisterDLC(name, dlc)
	local _dlc = self._dlc_tbl[name];
	if _dlc then
		_dlc._inst = dlc;
	else
		self._dlc_tbl[name] = { _inst = dlc };
	end
end

function i3k_dlc_mgr:CreateDLC()
	if self._cur_dlc then
		return self._cur_dlc:Create();
	end

	return false;
end

function i3k_dlc_mgr:ReleaseDLC()
	if self._cur_dlc then
		self._cur_dlc:Release();
		self._cur_dlc = nil;
	end
end

function i3k_dlc_mgr:Entry(fsm, from, evt, to)
	return self:CreateDLC();
end

function i3k_dlc_mgr:Leave(fsm, evt)
	self:ReleaseDLC();

	return true;
end

function i3k_dlc_mgr:OnUpdate(dTime)
	if self._cur_dlc then
		self._cur_dlc:OnUpdate(dTime);
	end
end

function i3k_dlc_mgr:OnHitObject(handled, entity)
	if self._cur_dlc then
		return self._cur_dlc:OnHitObject(handled, entity);
	end

	return 0;
end

function i3k_dlc_mgr:OnHitGround(handled, x, y, z)
	if self._cur_dlc then
		return self._cur_dlc:OnHitGround(handled, x, y, z);
	end

	return 0;
end

-------------------------------------------------------------
i3k_dlc = i3k_class("i3k_dlc");
function i3k_dlc:ctor()
end

function i3k_dlc:Create()
	return true;
end

function i3k_dlc:Release()
end

function i3k_dlc:OnUpdate(dTime)
end

function i3k_dlc:LoadMap(path, pos, cfg, delay)
	local _cb = function()
		self:OnMapLoaded();
	end
	g_i3k_logic_component:LoadMap(path, pos, cfg, _cb, delay);
end

function i3k_dlc:OnMapLoaded()
end

function i3k_dlc:OnHitObject(handled, entity)
	return 0;
end

function i3k_dlc:OnHitGround(handled, x, y, z)
	return 0;
end

