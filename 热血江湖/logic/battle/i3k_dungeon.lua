----------------------------------------------------------------
module(..., package.seeall)

local require = require;

local BASE = require("logic/battle/i3k_world").i3k_world;


------------------------------------------------------
i3k_dungeon = i3k_class("i3k_dungeon", BASE)
function i3k_dungeon:ctor()
end

function i3k_dungeon:Create(id)
	local dcfg = i3k_db_dungeon_base[id];
	if not dcfg then
		return false;
	end
	self.id = id;
	local ndcfg = i3k_db_new_dungeon[id];

	--self._syncRpc	= dcfg.maxPlayer == -1 or dcfg.maxPlayer > 1;
	self._mapType	= dcfg.openType;
	self._openType	= g_BASE_DUNGEON;
	if self._mapType == g_BASE_DUNGEON then
		self._openType = i3k_db_new_dungeon[id].openType;
	end
	self._fightmap  = self._mapType == g_ARENA_SOLO 
					or self._mapType == g_CLAN_ENCOUNTER 
					or self._mapType == g_CLAN_MINE 
					or self._mapType == g_CLAN_BATTLE_WAR 
					or self._mapType == g_CLAN_BATTLE_HELP 
					or self._mapType == g_TAOIST 
					or self._mapType == g_FORCE_WAR
					or self._mapType == g_FACTION_WAR
					or self._mapType == g_QIECUO
					or self._mapType == g_Pet_Waken
					or self._mapType == g_BUDO
					or self._mapType == g_DEFENCE_WAR
					or self._mapType == g_DESERT_BATTLE
					or self._mapType == g_PRINCESS_MARRY
					or self._mapType == g_MAGIC_MACHINE
					or self._mapType == g_SPY_STORY
					
	self._syncRpc	= self._openType == g_BASE_DUNGEON ;
	if self._mapType == g_PLAYER_LEAD then
		self._syncRpc = false
	end

	self._spawns	= { };
	self._tagDesc	= {};
	self._curArea	= nil;
	self._preArea	= { };
	self._nextAreaTick
					= 0;
	self._runState	= { finishType = -1, finishCheck = nil, finished = false, finally_boss = { }, finally_boss_count = 0, };
	if ndcfg then
		self._runState.finishType = ndcfg.condition;
	end

	if self._runState.finishType == 1 then
		self._runState.finishCheck = function()
			if not self._loaded then
				return false;
			end

			local kills = 0;
			for k, v in pairs(self._runState.finally_boss) do
				if v:IsDead() then
					kills = kills + 1;
				end
			end

			return kills >= self._runState.finally_boss_count;
		end
	elseif self._runState.finishType == 2 then
	end

	self._Traps		= { };
	--self._NPCs		= { };
	self._ResourcePoints	= { };
	self.Trap		= nil;
	self._Bonus		= nil;
	self._mapbuffs	= {};
	self._loaded	= false;
	self._soundID	= dcfg.soundID;
	self._isFilter = false
	for _, e in ipairs(i3k_db_common.filter.filterMapType) do
		if self._mapType == e then
			self._isFilter = true
			break
		end
	end
	


	return self:CreateFromCfg(dcfg);
end

function i3k_dungeon:Release(samemap)
	BASE.Release(self,samemap);

	if self._curArea then
		self._curArea:Release();
		self._curArea = nil;
	end

	if self._preArea then
		for k, v in ipairs(self._preArea) do
			v.area:Release();
		end
		self._preArea = { };
	end

	if self._spawns then
		for k, v in pairs(self._spawns) do
			v:Release();
		end
		self._spawns = { };
	end

	if self._Traps then
		for k, v in pairs(self._Traps) do
			v:Release();
		end
		self._Traps = { };
	end

	if self._mapbuffs then
		for k, v in pairs(self._mapbuffs) do
			v:Release();
		end
		self._mapbuffs = { };
	end

	--[[if self._NPCs then
		for k, v in pairs(self._NPCs) do
			v:Release();
		end
		self._NPCs = { };
	end]]

	if self._ResourcePoints then
		for k, v in pairs(self._ResourcePoints) do
			v:Release();
		end
		self._ResourcePoints = { };
	end
end

function i3k_dungeon:Exit()
	self._runState.finished = true;
end

function i3k_dungeon:Leave()
	i3k_sbean.mapcopy_leave()
end

function i3k_dungeon:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then
		return false;
	end

	if self._runState.finished then
		return false;
	end

	if self._curArea then
		self._curArea:OnUpdate(dTime);
	end

	if self._preArea then
		for k, v in ipairs(self._preArea) do
			v.area:OnUpdate(dTime);
		end
	end

	return true;
end

function i3k_dungeon:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then
		return false;
	end

	if self._curArea then
		self._curArea:OnLogic(dTick);
		local istri = self._curArea:IsTri() or self._curArea._HasTri
		--if self._curArea:IsEmpty() and self._curArea:IsTri() then
		if self._curArea:IsEmpty() and istri then
			self._curArea:Close();

			local area = { };
				area.tick = 0;
				area.area = self._curArea;
			table.insert(self._preArea, area);

			self:GotoNextArea();
		end
	end

	if self._preArea then
		for k, v in ipairs(self._preArea) do
			v.tick = v.tick + dTick * i3k_engine_get_tick_step();
			if v.tick > 4000 then
				v.area:Release();

				table.remove(self._preArea, k);
			else
				v.area:OnLogic(dTick);
			end
		end
	end

	if not self._runState.finished then
		if self._runState.finishCheck then
			self._runState.finished = self._runState.finishCheck();
			if self._runState.finished then
				if self._curArea then
					self._curArea:KillAllMonster();

					local area = { };
						area.tick = 0;
						area.area = self._curArea;
					table.insert(self._preArea, area);

					--self:Close();
				end
			end
		end
	end

	return true;
end

function i3k_dungeon:OnMapLoaded()
	if not BASE.OnMapLoaded(self) then
		return false;
	end

	--if not self._syncRpc then
		self:OnNpcLoaded()
	--end
	
	
	if self._syncRpc then
		return true;
	end
end

function i3k_dungeon:OnTrapLoaded(args)
	local gcfg_external = i3k_db_traps_external;
	local scenecfg = self._cfg.traps;
	if gcfg_external and scenecfg then
		for _, v in ipairs(scenecfg) do
			local trapCfg = gcfg_external[v];
			if trapCfg and v then
				local SEntityTrap = require("logic/entity/i3k_entity_trap");
				local Trap = SEntityTrap.i3k_entity_trap.new(i3k_gen_entity_guid_new( SEntityTrap.i3k_entity_trap.__cname,i3k_gen_entity_guid()));
				if Trap:CreatePreRes(trapCfg.id) then
					Trap:CreateFromCfg()
					Trap:SetPos(i3k_vec3_to_engine(i3k_world_pos_to_logic_pos(trapCfg.Pos)), true);
					Trap:SetFaceDir(trapCfg.Direction[1]*3.14/180,trapCfg.Direction[2]*3.14/180,trapCfg.Direction[3]*3.14/180);
					Trap:Show(trapCfg.Visibled);
					Trap:AddAiComp(eAType_ATTACK);
					Trap:AddAiComp(eAType_MANUAL_SKILL);
					if Trap and Trap._gcfg_external.SkillID == -1 then
						Trap:NeedUpdateAlives(false);
					else
						Trap:NeedUpdateAlives(true);
					end
				end

				if args[trapCfg.id]then
					if args[trapCfg.id].TrapState ~= eSTrapClosed then
						Trap:SetGroupType(eGroupType_N);
						self:AddEntity(Trap,true);
					end
				else
					Trap:SetGroupType(eGroupType_N);
					self:AddEntity(Trap,true);
				end
				
				if trapCfg.id then
					if trapCfg.id == 3207 or trapCfg.id == 3208 or trapCfg.id == 3209 then
						Trap:SetHittable(false);
					end
				end

				if args[trapCfg.id] then
					if args[trapCfg.id].TrapState ~= trapCfg.InitStatu then
						Trap:SetTrapBehavior(args[trapCfg.id].TrapState,true);
					else
						Trap:SetTrapBehavior(trapCfg.InitStatu,true);
					end
				else
					Trap:SetTrapBehavior(trapCfg.InitStatu,true);
				end
			end
		end
		-- Dynamic Link Init
		for _, v in pairs(self._Traps) do
			if v._gcfg_external.TargetIDs ~= nil then
				for _, n in pairs(v._gcfg_external.TargetIDs) do
					v:SetTarget(n);
				end
			end
		end
	end
end

function i3k_dungeon:OnManualReleaseTrap(id)
	if self._Traps then
		local trap = self._Traps[id]
		if trap then
			trap:Release()
			self._Traps[id] = nil
		end
	end
end

function i3k_dungeon:OnHideTrap(id, isShow)
	if self._Traps then
		local trap = self._Traps[id]
		if trap then
			trap:Show(isShow)
		end
	end
end

function i3k_dungeon:PreLoadResource()
	require("gamedb/i3k_db_buff")
	require("gamedb/i3k_db_trigger")
	require("gamedb/i3k_db_effects")
	require("gamedb/i3k_db_string")
	require("gamedb/i3k_db_boss_level_color")
	require("logic/battle/i3k_attacker")
	require("logic/entity/i3k_monster")
	require("logic/entity/ai/i3k_ai_auto_skill")
	require("logic/entity/ai/i3k_ai_guard")
	require("logic/entity/ai/i3k_ai_retreat")

	--i3k_warn("do preload")
	local mids = { }
	for _, spid in ipairs(self._cfg.areas) do
		local spcfg = i3k_db_spawn_area[spid]
		if spcfg then
			for _, sppid in ipairs(spcfg.spawnPoints) do
				local sppcfg = i3k_db_spawn_point[sppid]
				if sppcfg then
					for _, mid in ipairs(sppcfg.monsters) do
						mids[mid] = true
					end
				end
			end
		end
	end
	for mid, _ in pairs(mids) do
		--i3k_warn(string.format("do preload mid = %s", mid))

		local SEntity = require("logic/entity/i3k_monster")
		local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()))
		monster:Create(mid, false)
		monster:Release()
	end
end

function i3k_dungeon:OnSpawnLoaded(args)
	self:PreLoadResource()
	local spawn = require("logic/battle/i3k_spawn");
	self._spawns = { };
	self._tagDesc = {}
	local tmp = self._cfg
	if i3k_db_new_dungeon[self._cfg.id] then
		self._tagDesc = i3k_db_new_dungeon[self._cfg.id].tagDesc
	end

	for k = 1, #self._cfg.areas do
		--local sp = spawn.i3k_spawn.new(i3k_gen_entity_guid(), self);
		local sp = spawn.i3k_spawn.new(i3k_gen_entity_guid_new(spawn.i3k_spawn.__cname, i3k_gen_entity_guid()), self);
		if sp:Create(self._cfg.areas[k], args) then
			self._runState.finally_boss_count = self._runState.finally_boss_count + sp._monsterNum.finally_boss;

			table.insert(self._spawns, sp);
		end
	end
	local posid = -1;
	for _,v in ipairs(self._spawns) do
		if v._monsterNum.total ~= 0 then
			break;
		end
		posid = v._spawns[1]._cfg.id
	end
	if posid > 0 then
		local cfg = i3k_db_spawn_point[posid]
		local hero = i3k_game_get_player_hero();
		if cfg and cfg.pos then
			local Player = i3k_game_get_player()
			if Player and not hero:IsDead() then
				Player:SetHeroPos(i3k_world_pos_to_logic_pos(cfg.pos));
				for k = 1, self._player:GetMercenaryCount() do
					local mercenary = self._player:GetMercenary(k);
					if mercenary and not mercenary:IsDead() then
						local offX = i3k_engine_get_rnd_u(200, 400);
						local offX_S = i3k_engine_get_rnd_u(0, 1);
						if offX_S == 0 then
							offX = offX * -1;
						end
		
						local offZ = i3k_engine_get_rnd_u(200, 400);
						local offZ_S = i3k_engine_get_rnd_u(0, 1);
						if offZ_S == 0 then
							offZ = offZ * -1;
						end
		
						local pos = i3k_vec3_clone(i3k_world_pos_to_logic_pos(cfg.pos));
						pos.x = pos.x + offX;
						pos.z = pos.z + offZ;
						mercenary:SetPos(pos, true);			
					end
				end
			end
		end
	end
	if #self._spawns > 0 then
		if i3k_db_new_dungeon[self._cfg.id] then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateDesc", self._tagDesc[#self._tagDesc - #self._spawns +1])
		end
		self._curArea = table.remove(self._spawns, 1);
	end

	for _, v in ipairs(self._spawns) do
		if v._cfg.obstacle.valid == 1 then
			v._TargetIDs = v._cfg.obstacle.TrapId
		end
	end

	return true
end

function i3k_dungeon:OnNpcLoaded()
	local dcfg = self._cfg.npcs;
	if dcfg then
		for _,v in ipairs(dcfg) do
			local SEntity = require("logic/entity/i3k_npc");
			local entityNPC = SEntity.i3k_npc.new(i3k_gen_entity_guid_new(SEntity.i3k_npc.__cname, i3k_gen_entity_guid()));
			local cfg = i3k_db_npc_area[tonumber(v)]
			if cfg and entityNPC:Create(cfg.NPCID, false) then
				if cfg then
					local Dir_m = cfg.dir.y*6.28/360
					local Pos = cfg.pos
					entityNPC:SetFaceDir(0,Dir_m,0);
					entityNPC:SetPos(i3k_world_pos_to_logic_pos(Pos));
				end
				entityNPC:SetGroupType(eGroupType_O);
				entityNPC:Play(i3k_db_common.engine.defaultStandAction, -1);
				entityNPC:Show(true, true, 100);
				entityNPC:NeedUpdateAlives(false);
				entityNPC:SetCtrlType(eCtrlType_Network);
				entityNPC:AddAiComp(eAType_IDLE_NPC);
				entityNPC:AddAiComp(eAType_DEAD);
				entityNPC:ReplaceNpcAction()
				self:CheckNpcShow(entityNPC)
				self:AddEntity(entityNPC);
				self:CheckSpecialNpcShow(cfg.NPCID)
				--table.insert(self._NPCs,entityNPC)
			end
		end
	end

	return true
end

function i3k_dungeon:OnResourcePointLoaded(args)
	local Entityresourcepoint = require("logic/entity/i3k_entity_resourcepoint");
	self._ResourcePoints = { };
	for k, v in pairs(args) do
		local ResourcePoint = Entityresourcepoint.i3k_entity_resourcepoint.new(i3k_gen_entity_guid_new(Entityresourcepoint.i3k_entity_resourcepoint.__cname,v.MineID));
		ResourcePoint:Create(v.MineCfgID,v.MineID);
		ResourcePoint:SetPos(i3k_vec3_to_engine(v.Pos), true);
		ResourcePoint:Show(true, true, 100);
		ResourcePoint:NeedUpdateAlives(false);
		ResourcePoint:SetTrapBehavior(eSTrapMine,true);
		table.insert(self._ResourcePoints,v.MineID,ResourcePoint)
	end
	self._loaded = true;

	return true
end

function i3k_dungeon:OnMapbuffLoaded(args)
	local Entitymapbuff = require("logic/entity/i3k_mapbuff");
	self._mapbuffs = { };
	for k, v in pairs(args) do
		local MapBuff = Entitymapbuff.i3k_mapbuff.new(i3k_gen_entity_guid_new( Entitymapbuff.i3k_mapbuff.__cname,v.MapbuffID));
		MapBuff:Create(v.MapbuffCfgID,v.MapbuffID);
		MapBuff:SetPos(i3k_vec3_to_engine(v.Pos), true);
		MapBuff:NeedUpdateAlives(false);
		MapBuff:Show(true, true, 100);
		MapBuff:SetHittable(false)
		table.insert(self._mapbuffs,v.MapbuffID,MapBuff)
	end

	return true
end

function i3k_dungeon:OnKeyDown(handled, key)
	-- for test
	if key == 3 then -- '2'
		--self._player:Show(false, true, 100);
	elseif key == 2 then -- '1'
		--self._player:Show(true, true, 100);
	elseif key == 4 then -- '3'
		if self._entities[eGroupType_E] then
			local heros = self._entities[eGroupType_E];
			if heros then
				for k, v in pairs(heros) do
					v:OnDead();
				end
			end
			self._entities[eGroupType_E] = { };
		end

		if self._curArea then
			self._curArea:Release();
			self._curArea = nil;

			self:GotoNextArea();
		end
	end

	return BASE.OnKeyDown(self, handled, key);
end

function i3k_dungeon:GotoNextArea()
	self._curArea = nil;
	if #self._spawns > 0 then
		-- 新手关，出现最后一个boss时添加动画
		if #self._spawns == 1 then
			if g_i3k_game_context:isOnSprog()then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "addLastBossAndAnis")
			end
		end
		if i3k_db_new_dungeon[self._cfg.id] then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateDesc", self._tagDesc[#self._tagDesc - #self._spawns +1])
		end
		self._curArea = table.remove(self._spawns, 1);

		if g_i3k_game_context:isOnSprog()then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "hideAllWidgets")
			local stage = g_i3k_game_context:getPlayerLeadStage()
			if #self._spawns == 3 then -- 杀死第二波小怪，添加坐标指引提示
				local world = i3k_game_get_world();
				world:OnManualReleaseTrap(3201)
				-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "onChangeGuideEffectId", 2, 1)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "showGuideTrap", 2)
			end
			if stage == 2 then
				g_i3k_game_context:addPlayerLeadStage()
			end
			if stage == 4 then
				g_i3k_game_context:addPlayerLeadStage() -- 杀死倒数第二个怪，开始进入5阶段，提示二段跳
			end
		end

	-- 离开新手关入口
	elseif #self._spawns == 0 then
		if g_i3k_game_context:isOnSprog()then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "onLeavePlayerLead")
		end
	end

end


function i3k_dungeon:OnAddEntity(entity)
	BASE.OnAddEntity(self, entity);
	if entity:GetEntityType() == eET_Monster then
		if g_i3k_game_context:isOnSprog() then
			local stage = g_i3k_game_context:getPlayerLeadStage()
			if stage == 1 then
				g_i3k_game_context:addFirstPlayerLeadStage()
			end
			if entity._id == 90002 then -- 预警怪的id
				g_i3k_game_context:addThirdPlayerLeadStage()
			end
		end
		if entity._isBoss then
			if self._runState.finishType == 1 then
				if entity._cfg.boss == 2 then
					table.insert(self._runState.finally_boss, entity);
				end
			elseif self._runState.finishType == 2 then
			end

			local hero = i3k_game_get_player_hero()
			if hero and not hero:IsDead() then
				hero:SetForceTarget(entity);
			end
		end
	end
end
	
-- 获取单机本中刷怪点 持续掉落信息
function i3k_dungeon:GetEarLyDropInfo(spawnPointID)
	if self._curArea then
		for _, e in ipairs(self._curArea._spawns) do
			if e._cfg.id == spawnPointID then
				return e._earlyDrop
			end
		end
	end
end

-- 设置持续掉落数据
function i3k_dungeon:SetEarLyDropInfo(spawnPointID, ratio)
	if self._curArea then
		for _, e in ipairs(self._curArea._spawns) do
			if e._cfg.id == spawnPointID then
				e._earlyDrop[ratio] = e._earlyDrop[ratio] - 1
			end
		end
	end
end

function i3k_dungeon:GetSingleDungeonTagDesc()
	if #self._spawns > 0 then
		return self._tagDesc[#self._tagDesc - #self._spawns]
	else
		return #self._tagDesc > 0 and self._tagDesc[#self._tagDesc] or 0
	end
end
