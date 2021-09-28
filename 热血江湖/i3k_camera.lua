----------------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");

----------------------------------------------------------------
--主摄像机
i3k_main_camera = i3k_class("i3k_main_camera");
function i3k_main_camera:ctor()
	self._vertAngle	= 0;
	self._distance	= 0;
	self._vertLen	= 0;
	self._up		= { x = 0, y = 1, z = 0 };
	self._look		= Engine.SVector3(0, 0, 0);
	self._right		= Engine.SVector3(0, 0, 0);
	self._pos		= Engine.SVector3(0, 0, 0);
	self._posL		= i3k_vec3(0, 0, 0);
	self._pose      = { pos = i3k_vec3(0, 0, 0), rot = -math.pi * 0.25, dir = i3k_vec3(0, 0, 0) };
	self._angle		= 0.0;
	self._dirty		= true;

	self:LoadCfg(1);
end

function i3k_main_camera:LoadCfg(inter)
	local dist1		= i3k_db_common.engine.cameraMinDist;
	local angle1	= i3k_db_common.engine.cameraMinAngle;
	local dist2		= i3k_db_common.engine.cameraMaxDist;
	local angle2	= i3k_db_common.engine.cameraMaxAngle;

	local dist = dist1 + (dist2 - dist1) * inter;
	local angle = angle1 + (angle2 - angle1) * inter;

	self:UpdateParam(math.pi * (angle / 180), dist);
end

function i3k_main_camera:UpdateParam(angle, distance)
	self._vertAngle	= angle;
	self._distance	= distance;
	self._vertLen1	= math.tan(self._vertAngle);
	self._vertLen2	= 1;

	self:CalcCameraPose();
end

function i3k_main_camera:GetParam()
	return self._vertAngle, self._distance
end

function i3k_main_camera:CalcCameraPose()
	local dir = i3k_vec3_normalize1(Engine.RotatePos(Engine.SVector3(0, self._vertLen1, -self._vertLen2), Engine.SVector3(0, self._pose.rot, 0)));
	self._pose.dir	= i3k_vec3_mul2(dir, self._distance);

	self._look		= i3k_vec3_normalize1(i3k_vec3_sub1(i3k_vec3(0, 1, 0), i3k_vec3_add1(self._pose.dir, i3k_vec3(0, 0, 0))));
	self._right		= i3k_vec3_normalize1(i3k_vec3_cp(self._up, self._look));
	self._angle		= i3k_vec3_angle1(self._right, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0));
	self._dirty		= true;
end

function i3k_main_camera:UpdateCameraDistance(inter)
	self:LoadCfg(inter);

	self:UpdatePos(self._pose.pos, self._pose.rot);
end

-- 外部类调用
function i3k_main_camera:UpdateCameraPos()
	self:UpdatePos(self._pose.pos, self._pose.rot);
end


function i3k_main_camera:UpdatePos(pos, rotate)
	local _rot = -math.pi * 0.25;
	local world = i3k_game_get_world();
	if world and world._cfg then
		local mcfg = i3k_db_combat_maps[world._cfg.mapID];
		if mcfg then
			_rot = -(mcfg.cameraRot / 180) * math.pi;
			if mcfg.offsetHeight and mcfg.offsetHeight ~= 0 then
				pos = i3k_vec3_add1(pos, i3k_vec3(0, mcfg.offsetHeight, 0))
			end
		end
	end
	local rot = rotate or g_i3k_game_context:getCameraAngle() or _rot;

	local calc = self._pose.rot ~= rot;
	if calc then
		self._pose.rot = rot;

		self:CalcCameraPose();
	end


	self._pose.pos	= pos;

	local _pos		= i3k_vec3_add1(self._pose.dir, pos);

	--[[
	local dTime = i3k_game_get_logic():GetDeltaTime();
	if dTime > 0 and i3k_vec3_dist(_pos, self._pos) > 0 then
		--i3k_log("                camera pos = " .. i3k_format_pos(_pos) .. " prev pos = " .. i3k_format_pos(self._pos));
		i3k_log("                camera update time = " .. dTime .. " dist = " .. i3k_vec3_dist(_pos, self._pos) .. " real speed = " .. i3k_vec3_dist(_pos, self._pos) / dTime);
	end
	]]

	self._pos		= _pos;
	self._posL		= i3k_world_pos_to_logic_pos(pos);

	if self._dirty then
		self._dirty = false;

		g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(self._look), i3k_vec3_to_engine(self._right), i3k_vec3_to_engine(self._pos));
	else
		g_i3k_mmengine:MoveCameraTo("MainCamera", i3k_vec3_to_engine(self._pos), true, true);
	end
end
