----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_find_way = i3k_class("i3k_ai_autofight_find_way", BASE);
function i3k_ai_autofight_find_way:ctor(entity)
	self._type		= eAType_AUTOFIGHT_FIND_WAY;
	self._target	= nil;
end

function i3k_ai_autofight_find_way:IsValid()
	local entity = self._entity;
	if not entity._AutoFight then
		return false;
	end

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	if entity._behavior:Test(eEBPrepareFight) then
		return false;
	end

	if entity._behavior:Test(eEBDisAttack) then
		return false;
	end

	local radius = entity:GetPropertyValue(ePropID_alertRange);

	local world = i3k_game_get_world();
	if world then
		if world._cfg.autofightradius then
			radius = world._cfg.autofightradius;
		end

		local target = entity._alives[2][1]; -- 敌方
		if entity._alives[3][1] then--中立
			local trap =  entity._alives[3][1];
			if trap.entity and trap.entity._traptype == eSTrapActive then
				target = entity._alives[3][1];		
			end
		end
		
		if target then
			if target.dist < radius then
				if target.entity._groupType == eGroupType_N and target.dist > i3k_db_common.droppick.AutoFightMapbuffAutoRange then
				else
					return false;
				end
			end
		else
			if world._mapType == g_TOURNAMENT then
				return false;
			end
		end

		if world._mapType == g_BASE_DUNGEON or world._mapType == g_ACTIVITY or world._mapType == g_FACTION_DUNGEON or world._mapType == g_TOWER or world._mapType == g_WEAPON_NPC or world._mapType == g_RIGHTHEART or world._mapType == g_ANNUNCIATE or world._mapType == g_FIGHT_NPC or world._mapType == g_Pet_Waken 
		or world._mapType == g_AT_ANY_MOMENT_DUNGEON or world._mapType == g_FIVE_ELEMENTS then
			if world._openType == g_FIELD then
				if #world._spawns == 0 and not world._curArea then	
					return false
				end
			else
				local spawnID = math.abs(g_i3k_game_context:GetDungeonSpawnID())
				local monsterPos = g_i3k_game_context:GetMonsterPosition()
				if spawnID == 0 and not monsterPos then
					return false
				end
				
				local dist = nil;
				if spawnID ~= 0 then
					local spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
					_pos = i3k_db_spawn_point[spawnPointID].pos
					dist = i3k_vec3_dist(entity._curPos,i3k_world_pos_to_logic_pos(_pos))
					if dist and dist < 100 and not monsterPos then
						return false
					end					
				end
			end
		elseif world._mapType == g_FIELD or world._mapType == g_Life or world._mapType == g_OUT_CAST or world._mapType == g_BIOGIAPHY_CAREER then
			if entity._PVPStatus ~= g_PeaceMode then
				return false;
			end

			local dist = i3k_vec3_dist(entity._curPos,entity._AutoFight_Point)
			if dist < radius then
				return false;
			end
			
			local value = g_i3k_game_context:getAutoFightRadius()
			if value and value == g_OneMap then
				return false;
			end
		else -- TODO
			return false;
		end
	end

	return true;
end

function i3k_ai_autofight_find_way:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		local radius = entity:GetPropertyValue(ePropID_alertRange)
		local logic = i3k_game_get_logic();
		local world = i3k_game_get_world();
		if world then
			if world._cfg.autofightradius then
				radius = world._cfg.autofightradius
			end
			if world._mapType == g_BASE_DUNGEON or world._mapType == g_ACTIVITY or world._mapType == g_FACTION_DUNGEON or world._mapType == g_TOWER or world._mapType == g_WEAPON_NPC or world._mapType == g_RIGHTHEART or world._mapType == g_ANNUNCIATE or world._mapType == g_FIGHT_NPC or world._mapType == g_Pet_Waken 
			or world._mapType == g_AT_ANY_MOMENT_DUNGEON or world._mapType == g_FIVE_ELEMENTS then
				for k,v in pairs(world._ItemDrops) do
					if v and v:GetStatus() == eSItemDropActive then
						local _pos = i3k_logic_pos_to_world_pos(v._curPos)
						entity:MoveTo(_pos)
						return false;
					end
				end
				if world._openType == g_FIELD then
					if #world._spawns > 0 or world._curArea then
						local _pos = nil;
						local isfind = false
						for k1,v1 in pairs(world._curArea._spawns) do
							for k2,v2 in pairs(v1._monsters) do
								if not v2:IsDead() then
									isfind = true;
									break;
								end
							end
							if isfind then
								_pos = v1._cfg.pos;
								break;
							end
						end
						if not _pos then
							_pos = world._curArea._spawns[1]._cfg.pos
						end
						--local _pos = world._curArea._spawns[1]._cfg.pos
						local dist = i3k_vec3_dist(entity._curPos,i3k_world_pos_to_logic_pos(_pos))
						local mindist = dist
						for k,v in pairs(world._mapbuffs) do
							if v and v:GetStatus() == 1 then
								local distbuff = i3k_vec3_dist(v._curPos,entity._curPos)
								if distbuff < mindist and distbuff < i3k_db_common.droppick.AutoFightMapbuffAutoRange then
									mindist = distbuff
									_pos = i3k_logic_pos_to_world_pos(v._curPos)
								end
							end
						end
						entity:MoveTo(_pos)
					end
				else
					local monsterPos = g_i3k_game_context:GetMonsterPosition()
					local _pos = nil
					local spawnID = math.abs(g_i3k_game_context:GetDungeonSpawnID())
					local dist = 99999999999;
					if spawnID ~= 0 then
						local spawnPointID = i3k_db_spawn_area[spawnID].spawnPoints[1]
						_pos = i3k_db_spawn_point[spawnPointID].pos
						dist = i3k_vec3_dist(entity._curPos, i3k_world_pos_to_logic_pos(_pos))					
					end
		
					local mindist = dist
					local isspawn = true
					for k,v in pairs(world._mapbuffs) do
						if v and v:GetStatus() == 1 then
							local distbuff = i3k_vec3_dist(v._curPos,entity._curPos)
							if distbuff < mindist and distbuff < i3k_db_common.droppick.AutoFightMapbuffAutoRange then
								mindist = distbuff
								isspawn = false;
								_pos = i3k_logic_pos_to_world_pos(v._curPos)
							end
						end
					end
					if mindist < 150 and isspawn and g_i3k_game_context:GetDungeonSpawnID() < 0 then
						g_i3k_game_context:SetDungeonSpawnID(0);
						_pos = nil;
					end
					
					if monsterPos then
						entity:MoveTo(i3k_logic_pos_to_world_pos(monsterPos))
						local monsterPosDist = i3k_vec3_dist(entity._curPos, i3k_world_pos_to_logic_pos(monsterPos))
						if monsterPosDist < 150 then
							g_i3k_game_context:SetMonsterPosition(nil)
						end
					elseif _pos then
						entity:MoveTo(_pos)
					end
				end
			elseif world._mapType == g_FIELD or world._mapType == g_Life or world._mapType == g_OUT_CAST or world._mapType == g_BIOGIAPHY_CAREER then
				for k,v in pairs(world._mapbuffs) do
					if v and v:GetStatus() == 1 then
						local distbuff = i3k_vec3_dist(v._curPos,entity._AutoFight_Point)
						if  distbuff < radius and distbuff < i3k_db_common.droppick.AutoFightMapbuffAutoRange then
							local _pos = i3k_logic_pos_to_world_pos(v._curPos)
							entity:MoveTo(_pos)
							return false;
						end
					end
				end
			end
		end

		return false;
	end

	return false;
end

function i3k_ai_autofight_find_way:OnLeave()
	if BASE.OnLeave(self) then

		return true;
	end

	return false;
end

function i3k_ai_autofight_find_way:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_find_way:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_autofight_find_way.new(entity, priority);
end

