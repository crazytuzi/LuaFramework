-------------------------------------------
--module(..., package.seeall)

local require = require;

require("i3k_math");

-------------------------------------------
--颜色常量值
g_COLOR_VALUE_RED 		= "FFCA0D0D"
g_COLOR_VALUE_WHITE 	= "FF707069"
g_COLOR_VALUE_GREEN 	= "FF029133"
g_COLOR_VALUE_BLUE 		= "FF092DAE"
g_COLOR_VALUE_PURPLE 	= "FF86229F"
g_COLOR_VALUE_ORANGE 	= "FFBB8400"
g_COLOR_VALUE_GREY 		= "FF909090"

--hl代表高亮
g_COLOR_VALUE_HL_RED 		= "FFFF0000" --高亮红
g_COLOR_VALUE_HL_GREEN 		= "FF00FF00" --高亮绿色


---------------------------------------------
function i3k_world_pos_to_logic_pos(pos)
	return i3k_vec3(i3k_integer(pos.x * 100), i3k_integer(pos.y * 100), i3k_integer(pos.z * 100));
end

function i3k_logic_pos_to_world_pos(pos)
	return i3k_vec3(pos.x / 100, pos.y / 100, pos.z / 100);
end

function i3k_world_val_to_logic_val(val)
	return i3k_integer(val * 100);
end

function i3k_logic_val_to_world_val(val)
	return val / 100;
end

-------------------------------------------
g_i3k_effect_mgr	= nil;
g_i3k_audio_listener= nil;
g_i3k_actor_manager	= nil;
g_i3k_last_clear_ui_tex_cache_time = 0;

function i3k_engine_create()
	require("i3k_effect_mgr");
	require("i3k_audio_listener");

	g_i3k_effect_mgr	= i3k_effect_mgr.new(16);
	g_i3k_actor_manager	= Engine.SceneNodeMgr();

	g_i3k_audio_listener= i3k_audio_listener.new("MainAudioListener");
	g_i3k_audio_listener:Create();
end

function i3k_engine_update(dTime)
	if g_i3k_effect_mgr then
		g_i3k_effect_mgr:OnUpdate(dTime);
	end

	if g_i3k_actor_manager then
		g_i3k_actor_manager:Update(dTime);
	end
end

function i3k_engine_cleanup()
	if g_i3k_effect_mgr then
		g_i3k_effect_mgr:Cleanup();
	end
	g_i3k_effect_mgr	= nil;

	if g_i3k_actor_manager then
		g_i3k_actor_manager:Release();
	end
	g_i3k_actor_manager	= nil;

	if g_i3k_audio_listener then
		g_i3k_audio_listener:Release();
	end
	g_i3k_audio_listener = nil;
end

function i3k_clear_ui_cache()
	cc.Director:getInstance():getLetterCacheSize(1);
	cc.Director:getInstance():clearFontLetterCache(1);
	cc.Director:getInstance():removeUnusedTextures(1);
	g_i3k_last_clear_ui_tex_cache_time = g_i3k_last_clear_ui_tex_cache_time + 1;--i3k_game_get_logic_tick()
	collectgarbage("collect")
end

local global_rnd = nil;
function i3k_engine_init_rnd(seed)
	local rnd = require("i3k_random");

	global_rnd = rnd.i3k_random.new(seed);
end

function i3k_engine_get_rnd_f(min, max)
	if global_rnd then
		return global_rnd:RangeF(min, max);
	end

	return (min + max) / 2;
end

function i3k_engine_get_rnd_u(min, max)
	if global_rnd then
		return global_rnd:RangeI(min, max);
	end

	return i3k_integer((min + max) / 2);
end

function i3k_engine_get_tick_step()
	if i3k_db_common then
		return i3k_db_common.engine.tickStep;
	end

	return 33;
end

function i3k_engine_get_min_load_time()
	if i3k_db_common then
		return i3k_db_common.engine.loadMinTime;
	end

	return 0;
end

g_i3k_frame_interval_scale = 1.0;
function i3k_engine_set_frame_interval_scale(s)
	if g_i3k_frame_interval_scale ~= s then
		g_i3k_frame_interval_scale = s;

		g_i3k_game_handler:SetFrameIntervalScale(s);
	end
end

-- 寻路目标终点标志，需要获取地图缩放比例来保证精灵在不同缩放比例下大小相同
function i3k_engine_get_minimap_scale(mapID)
	local miniMapCfg = i3k_engine_get_minimap_cfg(mapID, false)
	if miniMapCfg then
		return miniMapCfg.scale
	end
end

function i3k_engine_get_minimap_cfg(mapID, isForcewar)
	local mapId = nil
	if mapID ~= nil and math.ceil(mapID) == mapID then
		mapId = mapID
	else
		mapId = g_i3k_game_context:GetWorldMapID()
	end
	local miniMapCfg
	local mapType = i3k_game_get_map_type()
	local cfgTb = {
		[g_FACTION_TEAM_DUNGEON]	= {cfg = i3k_db_faction_team_dungeon},
		[g_ANNUNCIATE]				= {cfg = i3k_db_annunciate_dungeon},
		[g_FACTION_WAR] 			= {cfg = i3k_db_factionFight_dungon},
		[g_FACTION_GARRISON] 		= {cfg = i3k_db_faction_garrsion_minimap},
		[g_BUDO] 					= {cfg = i3k_db_fight_team_fb},
		[g_GLOBAL_PVE] 				= {cfg = i3k_db_crossRealmPVE_fb},
		[g_HOME_LAND] 				= {cfg = i3k_db_home_land_minimap},
		[g_DEFENCE_WAR] 			= {cfg = i3k_db_defenceWar_dungeon},
		[g_PET_ACTIVITY_DUNGEON] 	= {cfg = i3k_db_pet_dungeon_Map},
		[g_DESERT_BATTLE] 			= {cfg = i3k_db_desert_battle_map},
		[g_PRINCESS_MARRY] 			= {cfg = i3k_db_princess_Config},
		[g_MAGIC_MACHINE] 			= {cfg = i3k_db_magic_machine_miniMap},
		[g_GOLD_COAST]				= {cfg = i3k_db_war_zone_map_fb},
		[g_CATCH_SPIRIT]			= {cfg = i3k_db_catch_spirit_dungeon},
		[g_SPY_STORY]				= {cfg = i3k_db_spy_story_map},
		[g_BIOGIAPHY_CAREER]		= {cfg = i3k_db_wzClassLand_land},
	}
	if cfgTb[mapType] then
		local mapCfg =  cfgTb[mapType].cfg
		miniMapCfg = mapCfg[mapId]
	elseif mapType == g_DEMON_HOLE then
			local curFloor, grade = g_i3k_game_context:GetDemonHoleFloorGrade()
			miniMapCfg = i3k_db_demonhole_fb[grade][curFloor]
		else
		miniMapCfg = isForcewar and i3k_db_forcewar_fb[mapId] or i3k_db_field_map[mapId]
	end
	return miniMapCfg
end

function i3k_engine_world_pos_to_minmap_pos(pos, imageW, imageH, mapID, isForcewar, isTarget)
	local miniMapCfg  = i3k_engine_get_minimap_cfg(mapID, isForcewar)
	if not miniMapCfg then
		local uisname = ""
		if g_i3k_ui_mgr then
			for i, e in ipairs(g_i3k_ui_mgr:GetCurrentOpenedUIs()) do
				if uisname then
					uisname = uisname .. "|"
				else
					uisname = ""
				end
				uisname = uisname .. e
			end
		end
		local forceStr = isForcewar and "true" or "false"
		error("minimap cfg not found, mapid = ".. mapID .. ", forcewar ".. forceStr.. "\n"..uisname)
	end
	local _cfg = { blockSize = 64, mapSize = 512, scale = miniMapCfg.scale };
	local padCfgID = not g_i3k_ui_mgr:JudgeIsPad() and 1 or (isTarget and 2 or 3)
	local padCfg  = -- pad 分辨率下寻路终点坐标有问题，故在这里加一个特殊的配置
	{
		[1] = {coefficient = 1,    targetOffset = 1   },
		[2]	= {coefficient = 1,    targetOffset = 0.75},
		[3] = {coefficient = 0.75, targetOffset = 1   },
	}

	local block_x	= i3k_integer(pos.x / _cfg.blockSize);
	local block_y	= i3k_integer(pos.z / _cfg.blockSize);
	local offset_x	= i3k_integer(pos.x) - _cfg.blockSize * block_x;
	local offset_y	= i3k_integer(pos.z) - _cfg.blockSize * block_y;

	local x = (_cfg.mapSize * block_x + offset_x / _cfg.blockSize * _cfg.mapSize) * _cfg.scale* padCfg[padCfgID].coefficient
	local y = (_cfg.mapSize * block_y + offset_y / _cfg.blockSize * _cfg.mapSize) * _cfg.scale* padCfg[padCfgID].coefficient
	local mpos = { };
	mpos.x = (imageW * miniMapCfg.scaleX + x) * padCfg[padCfgID].targetOffset
	mpos.y = (imageH * miniMapCfg.scaleY + y) * padCfg[padCfgID].targetOffset
	return mpos;
end

function i3k_minmap_pos_to_engine_world_pos(mpos, imageW, imageH, mapID, isForcewar)--加一个参数
	local miniMapCfg  = i3k_engine_get_minimap_cfg(mapID, isForcewar)
	local _cfg = { blockSize = 64, mapSize = 512, scale = miniMapCfg.scale};
	local coefficient = g_i3k_ui_mgr:JudgeIsPad() and 0.75 or 1

	local _x = (mpos.x / coefficient - imageW * miniMapCfg.scaleX) / _cfg.scale
	local _y = (mpos.y / coefficient - imageH * miniMapCfg.scaleY) / _cfg.scale

	local block_x = i3k_integer(_x / _cfg.mapSize);
	local block_y = i3k_integer(_y / _cfg.mapSize);
	local offset_x = i3k_integer(_x) - block_x * _cfg.mapSize;
	local offset_y = i3k_integer(_y) - block_y * _cfg.mapSize;

	local _pos = { x = 0, y = 50, z = 0 };
	_pos.x = ((block_x * _cfg.blockSize) + offset_x * (_cfg.blockSize / _cfg.mapSize))
	_pos.z = ((block_y * _cfg.blockSize) + offset_y * (_cfg.blockSize / _cfg.mapSize))
	return _pos;
end


function i3k_engine_trace_line(pos, dir, speed, duration)
	local dpos = i3k_vec3_add1(pos, i3k_vec3_mul2(i3k_vec3_normalize1(dir), i3k_logic_val_to_world_val(speed) * duration));

	local res = g_i3k_mmengine:TraceLineWalk(pos, i3k_vec3_to_engine(dpos));

	local moveInfo = { valid = res.mValid, path = i3k_world_pos_to_logic_pos(res.mPos) };

	return moveInfo;
end

function i3k_engine_trace_line_ex(pos, target_pos)
	local res = g_i3k_mmengine:TraceLineWalk(pos, i3k_vec3_to_engine(target_pos));

	local moveInfo = { valid = res.mValid, path = i3k_world_pos_to_logic_pos(res.mPos) };

	return moveInfo;
end

function i3k_engine_get_valid_pos(pos, rangeValid)
	--[[local _maxY = maxY or 0;
	local Pos = i3k_vec3_clone(pos);
	if maxY then
		Pos.y = maxY;
	end--]]

	local validPos = g_i3k_mmengine:GetValidPos(i3k_vec3_to_engine(pos), rangeValid or 30);
	--[[
	if math.abs(validPos.y - pos.y) > 50 then
		return pos;
	end
	]]

	return validPos;
end

function i3k_engine_check_pos(pos)
	if i3k_math_is_NaN(pos.x) or i3k_math_is_NaN(pos.y) or i3k_math_is_NaN(pos.z) then
		return false;
	end

	return true;
end

function i3k_engine_check_modle_by_extPackId(modelID)
	local max = g_i3k_db.i3k_db_get_ext_pack_max_id()
	if modelID and max then
		local extPackId = g_i3k_download_mgr:getMaxdownloadPackId(max);
		local modelPackId = i3k_db_models[modelID].package;
		if (modelPackId <= extPackId ) then
			return true;
		end
	end
	return false;
end

function i3k_engine_check_is_use_stock_model(modelID)
	if g_i3k_download_mode then--是否是分包
		if i3k_engine_check_modle_by_extPackId(modelID) then
			return modelID;
		else
			return i3k_db_models[modelID].standbyModelId;
		end
	end
	return modelID;
end

function i3k_engine_check_channel_name(finishedDays)
	local cfg = g_i3k_game_context:GetUserCfg()
	local channelName = cfg:GetChannelName()
	for k,v in pairs(i3k_db_extra_sign_award) do
		if tonumber(channelName) == k then
			if finishedDays and v then
				local day = string.format("day%s", finishedDays + 1)
				return v[day];
			end
		end
	end

	return false;
end
