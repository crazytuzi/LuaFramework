------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity");
local BASE = i3k_entity;

local releaseTime = 5
------------------------------------------------------
i3k_entity_transferpoint = i3k_class("i3k_entity_transferpoint", BASE);

function i3k_entity_transferpoint:ctor(guid)
	self._entityType	= eET_ResourcePoint;
	self._showmode		= true
	self._PVPColor		= -2;
	self._cfg			= nil;
	self.dist			= 0;
	self:CreateActor();
end

function i3k_entity_transferpoint:Create(id, agent, endTime)
	local gcfg = g_i3k_db.i3k_db_get_maze_transfer_points_cfg(id, i3k_game_get_map_type())
	
	if not gcfg then
		return false;
	end
	self._gid	= id;
	return self:CreateFromCfg(gcfg);
end

function i3k_entity_transferpoint:CreateFromCfg(gcfg)

	self._gcfg	= gcfg;

	self._entityType = eET_TransferPoint;
	if i3k_game_get_map_type() == g_MAZE_BATTLE then
		self._name = i3k_get_string(i3k_db_maze_battle.transferName);
	else
		self._name = gcfg.Tips
	end

	self:CreateResSync(gcfg.modelID);
	self:ShowTitleNode(true);

	return true;
end

function i3k_entity_transferpoint:IsDestory()
	return self._entity == nil;
end

function i3k_entity_transferpoint:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("transferpoint_title_node_" .. self._guid) then
		title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, tonumber("0xffffffff", 16), self._name);
	else
		title.node = nil;
	end
	if i3k_game_get_map_type() == g_MAZE_BATTLE then	
		local titleIcon = g_i3k_db.i3k_db_get_scene_icon_path(i3k_db_maze_battle.transferTopImage)
		title.image = title.node:AddImgLable(-0.5, 1, -1.2, 1, titleIcon);
	end

	return title;
end

function i3k_entity_transferpoint:ValidInWorld()
	return true;
end

function i3k_entity_transferpoint:OnUpdate(dTime)
end

function i3k_entity_transferpoint:OnLogic(dTick)
	if not self:IsInLeaveCache() and not self._showmode then
		self._showmode = true;
		self:Show(true);
	end

	if self:IsInLeaveCache() then
		self:UpdateCacheTime(dTick * i3k_engine_get_tick_step());
		self._showmode = false;
		self:Show(false);
		if self:GetLeaveCacheTime() > releaseTime then
			local world = i3k_game_get_world();
			if world then
				local guid = string.split(self._guid, "|")								
				local RoleID = tonumber(guid[2])
				local entityTransferPoint = world._TransferPoints[RoleID];
				if entityTransferPoint then
					--world._TransferPoints[RoleID] = nil
					world:RmvEntity(entityTransferPoint);
					entityTransferPoint:Release()
					self._showmode = true
				end
			end

			self:ShowTitleNode(false)
			self:ResetLeaveCache();
		end
	end
end

function i3k_entity_transferpoint:GetGuidID()
	local guid = string.split(self._guid, "|")
	return tonumber(guid[2])
end

