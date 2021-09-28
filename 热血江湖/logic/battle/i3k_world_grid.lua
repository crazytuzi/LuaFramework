----------------------------------------------------------------
local require = require;

require("i3k_global");

local eGridSize = 1000; -- 10米

------------------------------------------------------
i3k_world_grid = i3k_class("i3k_world_grid");
function i3k_world_grid:ctor(mgr, gid, x, z)
	self._guid		= gid;
	self._mgr		= mgr;
	self._x			= x;
	self._z			= z;
	self._active	= false;
	self._entities	= { };
end

function i3k_world_grid:Release()
	self._entities = { };
end

function i3k_world_grid:Active(val)
	if self._active ~= val then
		self._active = val;

		for k, v in pairs(self._entities) do
			--v:EnableRender(val);
		end
	end
end

function i3k_world_grid:OnUpdate(dTime)
	for k, v in pairs(self._entities) do
		v:OnUpdate(dTime);
	end
end

function i3k_world_grid:OnLogic(dTick)
	for k, v in pairs(self._entities) do
		if not v:IsDestory() then
			if not v:IsSyncEntity() then
				v:OnLogic(dTick);
			end
		else
			if self._mgr._world then
				self._mgr._world:RmvEntity(v);
			end

			v:Release();
		end
	end
end

function i3k_world_grid:AddEntity(entity)
	if not entity then
		return false;
	end
	entity:UpdateGrid(self);

	self._entities[entity:GetGUID()] = entity;

	self._mgr:OnAddEntity(self, entity);

	return true;
end

function i3k_world_grid:RmvEntity(entity)
	if not entity then
		return false;
	end
	entity:UpdateGrid(nil);

	self._entities[entity:GetGUID()] = nil;

	self._mgr:OnRmvEntity(self, entity);

	return true;
end

function i3k_world_grid:GetEntities()
	return self._entities;
end

function i3k_world_grid:LogInfo(detail)
	local entities = i3k_table_length(self._entities);

	--i3k_log("grid[" .. self._guid .. "] has " .. entities .. " entity.");
	if detail then
		for k, v in pairs(self._entities) do
			i3k_log("    grid[" .. self._guid .. "][" .. k .. "]");
		end
	end

	return entities;
end

------------------------------------------------------
i3k_grid_mgr = i3k_class("i3k_grid_mgr");
function i3k_grid_mgr:ctor(world)
	self._grids		= { };
	self._activeGrids
					= { };
	self._world		= world;
	self._activetick
					= 0;
end

function i3k_grid_mgr:Cleanup()
	for k, v in pairs(self._grids) do
		v:Release();
	end
	self._grids = { };
end

function i3k_grid_mgr:OnUpdate(dTime)
	--[[
	local camera = i3k_game_get_logic():GetMainCamera();
	if camera then
		local grids = self:GetValidGridsByPos(camera._posL);
		for k, v in ipairs(grids) do
			v:OnUpdate(dTime);
		end
	end
	]]

	--for k, v in ipairs(self._activeGrids) do
	for k, v in pairs(self._grids) do
		v:OnUpdate(dTime);
	end
end

function i3k_grid_mgr:OnLogic(dTick)
	self._activeGrids = { };

	local camera = i3k_game_get_logic():GetMainCamera();
	if camera then
		for k, v in pairs(self._grids) do
			v:OnLogic(dTick);

			local active = false;
			local gpos = self:CalcPos(camera._posL);
			if v._x >= gpos.x - 2 and v._x <= gpos.x + 2 then
				if v._z >= gpos.z - 2 and v._z <= gpos.z + 2 then
					active = true;
				end
			end

			if active then
				table.insert(self._activeGrids, v);
			end

			v:Active(active);
		end
	end
end

function i3k_grid_mgr:OnAddEntity(grid, entity)
	--[[
	if self:IsValidGridInWorld(grid) then
		entity:EnableRender(true);
	else
		entity:EnableRender(false);
	end
	]]
end

function i3k_grid_mgr:OnRmvEntity(grid, entity)
end

function i3k_grid_mgr:CalcPos(pos)
	local _pos = { };
	if pos.x >= 0 then _pos.x = pos.x + eGridSize / 2; else _pos.x = pos.x - eGridSize / 2; end
	if pos.z >= 0 then _pos.z = pos.z + eGridSize / 2; else _pos.z = pos.z - eGridSize / 2; end

	local gx = i3k_integer((_pos.x / eGridSize));
	local gz = i3k_integer((_pos.z / eGridSize));

	return { x = gx, z = gz };
end

function i3k_grid_mgr:CalcID(pos)
	return pos.x * 1000 + pos.z;
end

function i3k_grid_mgr:GetGridByPos(pos)
	local gpos = self:CalcPos(pos);
	local gid  = self:CalcID(gpos);

	if not self._grids[gid] then
		self._grids[gid] = i3k_world_grid.new(self, gid, gpos.x, gpos.z);
	end

	return self._grids[gid];
end

function i3k_grid_mgr:GetGridByGuid(gid)
	return self._grids[gid];
end

function i3k_grid_mgr:GetAllGrid()
	return self._grids;
end

function i3k_grid_mgr:GetAllEntities()
	local entities = { };

	for k, v in pairs(self._grids) do
		local es = v:GetEntities();
		for k1, v1 in pairs(es) do
			table.insert(entities, es);
		end
	end

	return entities;
end

function i3k_grid_mgr:GetValidEntitiesByPos(pos, filter)
	local entities = { };

	local gpos = self:CalcPos(pos);
	for x = gpos.x - 1, gpos.x + 1 do
		for z = gpos.z - 1, gpos.z + 1 do
			local gid = self:CalcID({ x = x, z = z });

			local grid = self._grids[gid];
			if grid then
				local es = grid:GetEntities();
				for k, v in pairs(es) do
					if not (type(v) == "number") then
						if filter then
							if filter(v) then
								table.insert(entities, v);
							end
						else
							table.insert(entities, v);
						end
					end
				end
			end
		end
	end

	return entities;
end

function i3k_grid_mgr:GetValidGridsByPos(pos)
	local grids = { };

	local gpos = self:CalcPos(pos);
	for x = gpos.x - 1, gpos.x + 1 do
		for z = gpos.z - 1, gpos.z + 1 do
			local gid = self:CalcID({ x = x, z = z });

			local grid = self._grids[gid];
			if grid then
				table.insert(grids, grid);
			end
		end
	end

	return grids;
end

function i3k_grid_mgr:IsValidGridInWorld(grid)
	local camera = i3k_game_get_logic():GetMainCamera();
	if camera then
		local gpos = self:CalcPos(camera._posL);
		if grid._x < gpos.x - 2 or grid._x > gpos.x + 2 then
			return false;
		end

		if grid._z < gpos.z - 2 or grid._z > gpos.z + 2 then
			return false;
		end

		return true;
	end

	return false;
end

function i3k_grid_mgr:LogInfo(detail)
	local sum = 0;
	for k, v in pairs(self._grids) do
		sum = sum + v:LogInfo(detail);
	end

	i3k_log("grid total has " .. sum .. " entity.");
end

