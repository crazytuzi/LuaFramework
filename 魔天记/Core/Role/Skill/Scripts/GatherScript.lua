require "Core.Role.Skill.Scripts.AbsScript";
require "Core.Module.Friend.controlls.PartData"
-- 引力拖拽
GatherScript = class("GatherScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;
local atan2 = math.atan2;
local tabInsert = table.insert;

function GatherScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = GatherScript });
	self:SetStage(skillStage);
	return self;
end

function GatherScript:_Init(role, para)
	local r = role.transform.rotation.eulerAngles.y / 180 * pi;
	local d = tonumber(para[1]) / 100;
	local pt = role.transform.position;
	pt.x = pt.x + sin(r) * d;
	pt.z = pt.z + cos(r) * d;
	self._ortPt = pt;

	self._radius = tonumber(para[2]) / 100;
	self._time = tonumber(para[3]) / 1000;
	self._speed = tonumber(para[4]) / 100;

	self._targets = self:_GetAffectedRoles();
	self:_InitTimer(0, -1);
	self:_OnTimerHandler();
end

function GatherScript:_GetAffectedRoles()
	local map = GameSceneManager.map;
	if (map) then
		local role = self._role;
		local roles = map:GetHostileTargets(role.info.camp, role.info.pkType);

		if (self._stage.info.range_type == 3) then
			return self:_CheckInRectangle(role.transform.position, roles);
		elseif (self._stage.info.range_type == 4) then
			return self:_CheckInFan(role.transform.position, roles);
		elseif (self._stage.info.range_type == 5) then
			return self:_CheckInCircular(role.transform.position, roles);
		elseif (self._stage.info.range_type == 6 and role.target) then
			return self:_CheckInCircular(role.target.transform.position, roles);
		end
	end
	return nil;
end

function GatherScript:_CheckInRectangle(pt, roles)
	local stage = self._stage;
	local info = stage.info;
	local role = self._role;
	local roleR = role.transform.rotation.eulerAngles.y / 180 * pi;
	local p1 = tonumber(info.range[1]) / 100;
	local p2 = tonumber(info.range[2]) / 100;
	local minX = pt.x - p1 / 2;
	local maxX = pt.x + p1 / 2;
	local minZ = pt.z
	local maxZ = pt.z + p2;
	local selects = { };

	for i, v in pairs(roles) do
		if (v.info.is_back == true) then
			local tPt = v.transform.position;
			local d = Vector3.Distance2(pt, tPt);
			local r = atan2(tPt.x - pt.x, tPt.z - pt.z) - roleR
			tPt.x = pt.x + sin(r) * d;
			tPt.z = pt.z + cos(r) * d;
			if (tPt.x >= minX and tPt.x <= maxX and tPt.z >= minZ and tPt.z <= maxZ) then
				tabInsert(selects, v);
			end
		end
	end
	return selects;
end

function GatherScript:_CheckInCircular(pt, roles)
	local stage = self._stage;
	local info = stage.info;
	local role = self._role;
	local angle = tonumber(info.range[1]);
	local radius = tonumber(info.range[2]) / 100;
	local roleR = role.transform.rotation.eulerAngles.y -(angle / 2);
	local selects = { };

	for i, v in pairs(roles) do
		if (v.info.is_back == true) then
			local tPt = v.transform.position;
			if (Vector3.Distance2(pt, tPt) <= radius) then
				local r =(v.transform.rotation.eulerAngles.y - roleR)
				if (r >= 0 and r <= angle) then
					tabInsert(selects, v);
				end
			end
		end
	end
	return selects;
end

function GatherScript:_CheckInFan(pt, roles)
	local stage = self._stage;
	local info = stage.info;
	local radius = tonumber(info.range[1]) / 100;
	local selects = { };
	for i, v in pairs(roles) do
		if (v.info.is_back == true) then
			if (Vector3.Distance2(pt, v.transform.position) <= radius) then
				tabInsert(selects, v);
			end
		end
	end
	return selects;
end

function GatherScript:_OnDisposeHandler()
	if (self._targets) then
		for i, v in pairs(self._targets) do
			v:Stand();
		end
	end
end

function GatherScript:_OnTimerHandler()
	if (self._targets and self._time > 0) then
		local ortPt = self._ortPt;
		local radius = self._radius;
		local speed = self._speed * FPSScale;
		local sum = 0;
		self._time = self._time - Time.fixedDeltaTime;
		for i, v in pairs(self._targets) do
			if (v) then
				local transform = v.transform;
				if (transform) then
					local pt = transform.position;
					if (Vector3.Distance2(ortPt, pt) > radius) then
						local r = atan2(ortPt.x - pt.x, ortPt.z - pt.z);
						pt.x = pt.x + sin(r) * speed;
						pt.z = pt.z + cos(r) * speed;
						transform.rotation = Quaternion.Euler(0,(r * 180.0 / math.pi), 0);
						if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
							MapTerrain.SampleTerrainPositionAndSetPos(transform,pt)
	--						transform.position = MapTerrain.SampleTerrainPosition(pt);
							sum = sum + 1;
						end
					end
				end
			end
		end
		if (sum == 0) then
			self:Dispose();
		end
	else
		self:Dispose();
	end
end