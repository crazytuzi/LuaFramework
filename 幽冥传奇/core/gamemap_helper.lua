
GameMapHelper = GameMapHelper or BaseClass()

function GameMapHelper:__init(render_unit)
	self.game_map = nil
	self.render_unit = render_unit or HandleRenderUnit
	self.camera_scale = 1
	self.is_ignore_block = false
	self.is_map_loading = false
	self.view_cneter_pos = {x = 0, y = 0}
end

function GameMapHelper:__delete()
	self.render_unit = nil

	self:ReleaseAllMap()
end

function GameMapHelper:ReleaseAllMap()
	if self.game_map then
		self.game_map:release()
		self.game_map = nil
	end
end

function GameMapHelper:Update(now_time, elapse_time)
	if self.game_map then
		self.game_map:update(elapse_time)
	end
end

function GameMapHelper:GetGameMap()
	return self.game_map
end

function GameMapHelper:ChangeScene(map_id)
	self.is_map_loading = true

	self:ReleaseAllMap()

	local map_config_name = ResPath.GetGameMapConfigPath(map_id)
	self.game_map = GameMap:create(self.render_unit:GetCoreScene())
	self.game_map:retain()
	self.game_map:load(map_config_name)
end

function GameMapHelper:OnLoadingSceneQuit()
	if not MapLoading.Instance:GetIsLoading() then
		self.is_map_loading = false
		self.game_map:setViewCenterPoint(self.view_cneter_pos.x, self.view_cneter_pos.y)
	end
end

function GameMapHelper:setViewCenterPoint(world_x, world_y)
	if self.game_map == nil then return end
	
	self.view_cneter_pos.x = world_x
	self.view_cneter_pos.y = world_y
	if not self.is_map_loading then
		self.game_map:setViewCenterPoint(self.view_cneter_pos.x, self.view_cneter_pos.y)
	end
end

function GameMapHelper:GetViewCenterPoint()
	return self.view_cneter_pos
end

function GameMapHelper:ResetViewCenterPoint()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	if 0 ~= mainrole_vo.pos_x and 0 ~= mainrole_vo.pos_y then
		local real_pos_x, real_pos_y = HandleRenderUnit:LogicToWorldXY(mainrole_vo.pos_x, mainrole_vo.pos_y)
		self:setViewCenterPoint(real_pos_x, real_pos_y + COMMON_CONSTS.SCENE_CAMERA_OFFSET_Y)
	end
end

function GameMapHelper:SetCameraScale(scale)
	if self.camera_scale == scale or self.game_map == nil then return end

	self.camera_scale = scale
	self.game_map:setCameraScale(scale)
	self:setViewCenterPoint(self.view_cneter_pos.x, self.view_cneter_pos.y)
end

function GameMapHelper:GetCameraScale()
	return self.camera_scale
end

function GameMapHelper:SetIsInnoreBlock(is_ignore_block)
	if self.game_map == nil then return end

	self.is_ignore_block = is_ignore_block
	self.game_map:setIgnoreBlock(is_ignore_block)
end

function GameMapHelper:GetIsIgnoreBlock()
	return self.is_ignore_block
end

local zone_info = 0
function GameMapHelper.IsBlock(x, y)
	zone_info = HandleGameMapHandler:GetGameMap():getZoneInfo(x, y)
	-- return zone_info == ZONE_TYPE_BLOCK or zone_info == ZONE_TYPE_BLOCK + ZoneType.ShadowDelta
	return zone_info == ZONE_TYPE_BLOCK
end
