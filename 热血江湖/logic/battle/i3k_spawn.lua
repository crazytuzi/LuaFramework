------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity");
local BASE = i3k_entity;

------------------------------------------------------
i3k_monster_pool = i3k_class("i3k_monster_pool");
function i3k_monster_pool:ctor(delta, point)
	self._popTick	= delta;
	self._tickLine	= delta;
	self._pool		= i3k_queue.new();
	self._point = point
end

function i3k_monster_pool:OnLogic(dTick)
	while true do
		local m = self._pool:pop();
		if m then
			self._point._pending = self._point._pending + 1
			local frame_task_mgr = require("i3k_frame_task_mgr")
			frame_task_mgr.addNormalTask({
					taskType = "spawn",
					run = function()
						m:create();
						self._point._pending = self._point._pending - 1
					end})
		end

		if self:IsEmpty() then
			break;
		end
	end

	--[[
	if self._pool:size() > 0 then
		self._tickLine = self._tickLine + dTick * i3k_db_common.engine.tickStep;
		if self._tickLine >= self._popTick then
			local m = self._pool:pop();
			m:create(m);

			self._tickLine = 0;
		end
	end
	]]
end

function i3k_monster_pool:Push(mon)
	self._pool:push(mon);
end

function i3k_monster_pool:Pop()
	local es = self._pool:size();
	if es > 0 then
		return self._pool:pop();
	end

	return nil;
end

function i3k_monster_pool:Size()
	return self._pool:size();
end

function i3k_monster_pool:IsEmpty()
	return self._pool:size() == 0;
end

function i3k_monster_pool:Clear()
	self._pool:clear();
end


------------------------------------------------------
i3k_spawn_point = i3k_class("i3k_spawn_point");
function i3k_spawn_point:ctor(dungeon)
	self._turnOn		= false;
	self._dungeon		= dungeon;
	self._monsterPool	= { };
	self._timer = 0
	self._pending = 0
	self._earlyDrop = {} 
end

function i3k_spawn_point:Create(scfg, _bbox, args)
	self._cfg			= scfg;
	self._monsters		= { };
	self._monsterPool	= { };
	self._monsterNum	= { total = 0, boss = 0, finally_boss = 0 };

	local k = 1;
	if args then
		for i = 1, scfg.spawnTimes do
			local ms = scfg.spawnNum[i]
			if ms then
				local num = ms[1];
				if num and num > 0 then
					if args.killedCount <= num then
						k = i;

						break
					end

					args.killedCount = args.killedCount - num;
				end
			end
		end
	end

	for times = k , scfg.spawnTimes do
		self:CreateMonster(k, mid, num, scfg, args, _mons, _bbox);	
	end
	
	if scfg.spawnTimes == -1 then
		self:CreateMonster(1 ,mid, num, scfg, args, _mons, _bbox)		
	end
	
	if args then
		if args.earlyDrop and table.nums(args.earlyDrop) > 0 then --持续掉落相关
			for k, v in pairs(self._earlyDrop) do
				if args.earlyDrop[v] and self._earlyDrop[v] > 0 then
					self._earlyDrop[v] = self._earlyDrop[v] - args.earlyDrop[v]
				end	
			end
		end
	end

	self._curMonsterPool = nil;
	if #self._monsterPool > 0 then
		self._curMonsterPool = table.remove(self._monsterPool);
	end

	return true;
end

function i3k_spawn_point:CreateMonster(k ,mid, num, scfg, args, _mons, _bbox)
		local _pool = { };
		local ms = scfg.spawnNum[k];
		for k1 = 1, #scfg.monsters do
			local _mons = i3k_monster_pool.new(50, self);
			
			if scfg.spawnTimes == -1 then
				k1 = 1;
			end
			
			local mid = scfg.monsters[k1];
			if mid then
				local num = ms[k1];
				if num and num > 0 then
					if args then
						if args.killedCount and args.killedCount > 0 then
							num = num - args.killedCount;
						end
					end
					
					for k2 = 1, num do
						local _mon = { };
						if scfg.randomPos == 0 then
							_mon.pos		= i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(scfg.pos)));
						else
							_mon.pos		= i3k_world_pos_to_logic_pos(g_i3k_mmengine:GetRandomPos(i3k_vec3_to_engine(scfg.pos), i3k_logic_val_to_world_val(scfg.randomRadius)));
						end
						_mon.create		= function()
							local SEntity = require("logic/entity/i3k_monster");
							--local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid());
							local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()));
							monster:Create(mid, false);
							monster:AddAiComp(eAType_IDLE);
							monster:AddAiComp(eAType_AUTO_MOVE);
							monster:AddAiComp(eAType_ATTACK);
							monster:AddAiComp(eAType_AUTO_SKILL);
							monster:AddAiComp(eAType_FIND_TARGET);
							monster:AddAiComp(eAType_SPA);
							monster:AddAiComp(eAType_SHIFT);
							monster:AddAiComp(eAType_DEAD);
							monster:AddAiComp(eAType_GUARD);
							monster:AddAiComp(eAType_RETREAT);
							monster:AddAiComp(eAType_FEAR);
							monster:Birth(_mon.pos);
							monster:Show(true, true, 100);
							monster:SetGroupType(eGroupType_E);
							if scfg.faceType == 2 then
								monster:SetFaceDir(0, math.pi * (scfg.faceDir.y / 180), 0);
							else
								monster:SetFaceDir(0, 0, 0);
							end
							monster:Play(i3k_db_common.engine.defaultStandAction, -1);
							monster._spawnID = self._cfg.id
							if monster then
								if monster._cfg.birtheffect then
									monster:PlayHitEffect(monster._cfg.birtheffect)
								end
							end
							if monster._baseCfg.damageHpRatio and monster._baseCfg.damageHpRatio[1] > 0 then
								for i, e in ipairs(monster._baseCfg.damageHpRatio) do
									if not self._earlyDrop[e] then
										self._earlyDrop[e] = 1
									else
										self._earlyDrop[e] = self._earlyDrop[e] + 1
									end
								end
							end
							self._dungeon:AddEntity(monster);
							if self._monsters then
								table.insert(self._monsters, monster);
							end
						end
						
						local mcfg = i3k_db_monsters[mid];
						if mcfg then
							self._monsterNum.total = self._monsterNum.total + 1;
							if mcfg.boss ~= 0 then
								if mcfg.boss == 2 then
									self._monsterNum.finally_boss = self._monsterNum.finally_boss + 1;
								end
								
								self._monsterNum.boss = self._monsterNum.boss + 1;
							end
						end
						_mons:Push(_mon);
						
						if _mon.pos.x < _bbox.minx then _bbox.minx = _mon.pos.x; end
						if _mon.pos.z < _bbox.minz then _bbox.minz = _mon.pos.z; end
						if _mon.pos.x > _bbox.maxx then _bbox.maxx = _mon.pos.x; end
						if _mon.pos.z > _bbox.maxz then _bbox.maxz = _mon.pos.z; end
					end
				end
			end
			if not _mons:IsEmpty() then
				table.insert(_pool, _mons);
			end
		end

	if #_pool > 0 then
		table.insert(self._monsterPool, _pool);
	end
end

function i3k_spawn_point:Release()
	if self._monsters then
		for k, v in pairs(self._monsters) do
			v:Release();
		end
	end
	self._monsters = nil;
end

function i3k_spawn_point:OnUpdate(dTime)
	if self._turnOn then
		if self._cfg.spawnType == 3 then
			local entitiesCount = self:GetAliveEntitiesCount();
			if entitiesCount ~= self._cfg.spawnNum[1][1] then
				self._timer = self._timer + dTime
				if self._timer*1000 > self._cfg.spawnDTime then
					-----------------------------------
					local mid = self._cfg.monsters[1];
					if mid then
						local num = self._cfg.spawnNum[1][1] - entitiesCount;
						for k2 = 1, num do
							local _mon = { };
							if self._cfg.randomPos == 0 then
								_mon.pos		= i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(self._cfg.pos)));
							else
								_mon.pos		= i3k_world_pos_to_logic_pos(g_i3k_mmengine:GetRandomPos(i3k_vec3_to_engine(self._cfg.pos), i3k_logic_val_to_world_val(self._cfg.randomRadius)));
							end
							local SEntity = require("logic/entity/i3k_monster");
							local monster = SEntity.i3k_monster.new(i3k_gen_entity_guid_new(SEntity.i3k_monster.__cname,i3k_gen_entity_guid()));
							monster:Create(mid, false);
							monster:AddAiComp(eAType_IDLE);
							monster:AddAiComp(eAType_AUTO_MOVE);
							monster:AddAiComp(eAType_ATTACK);
							monster:AddAiComp(eAType_AUTO_SKILL);
							monster:AddAiComp(eAType_FIND_TARGET);
							monster:AddAiComp(eAType_SPA);
							monster:AddAiComp(eAType_SHIFT);
							monster:AddAiComp(eAType_DEAD);
							monster:AddAiComp(eAType_GUARD);
							monster:AddAiComp(eAType_RETREAT);
							monster:AddAiComp(eAType_FEAR);
							monster:Birth(_mon.pos);
							monster:Show(true, true, 100);
							monster:SetGroupType(eGroupType_E);
							monster:SetFaceDir(0, 0, 0);
							monster:Play(i3k_db_common.engine.defaultStandAction, -1);
							monster._spawnID = self._cfg.id
							if monster then
								if monster._cfg.birtheffect then
									monster:PlayHitEffect(monster._cfg.birtheffect)
								end
							end
							self._dungeon:AddEntity(monster);

							table.insert(self._monsters, monster);
						end
					end
					-----------------------------------
					self._timer = 0
				end
			end
		end
	end
end

function i3k_spawn_point:OnLogic(dTick)
	if self._turnOn then
		if self._curMonsterPool then
			for k, v in ipairs(self._curMonsterPool) do
				v:OnLogic(dTick);
			end
			self._curMonsterPool = nil;
		end

		if self._cfg.spawnType == 1 then
			local entitiesCount = self:GetAliveEntitiesCount();
			if entitiesCount == 0 then
				if #self._monsterPool > 0 then
					self._curMonsterPool = table.remove(self._monsterPool);
				end
			end
		elseif self._cfg.spawnType == 2 then
			if self._timeTick > self._cfg.spawnDTime then
				if #self._monsterPool > 0 then
					self._curMonsterPool = table.remove(self._monsterPool);
				end
			end
		elseif self._cfg.spawnType == 3 then

		end
	end
end

function i3k_spawn_point:IsEmpty()
	return #self._monsterPool == 0;
end

function i3k_spawn_point:GetAliveEntities()
	local alives = { };

	if self._monsters then
		for k, v in pairs(self._monsters) do
			if not v:IsDead() then
				table.insert(alives, v);
			end
		end
	end

	return alives;
end

function i3k_spawn_point:GetAliveEntitiesCount()
	local c = 0

	if self._monsters then
		for k, v in pairs(self._monsters) do
			if not v:IsDead() then
				c = c + 1
			end
		end
	end

	return c + self._pending
end

function i3k_spawn_point:Spawn()
	self._turnOn = true;
	self._HasTri = false;
end

------------------------------------------------------
i3k_spawn = i3k_class("i3k_spawn", BASE);
function i3k_spawn:ctor(guid, dungeon)
	self._cfg		= nil;
	self._timeTick	= 0;
	self._dungeon	= dungeon;
end

function i3k_spawn:Create(id, args)
	local obstacle = require("logic/battle/i3k_obstacle");

	local cfg = i3k_db_spawn_area[id];
	if not cfg then
		return false;
	end

	self._cfg = cfg;

	--local pos = cfg.pos;
	--self:SetPos(i3k_world_pos_to_logic_pos(pos));

	self._range			= cfg.range;
	self._isTri			= false;
	self._denytime			= 0
	self._denypush			= false;

	-- 光幕门
	self._TargetIDs			= {};

	self._bbox			= { minx = 9999999, minz = 9999999, maxx = -9999999, maxz = -9999999 };
	self._spawns		= { };
	self._monsterNum	= { total = 0, boss = 0, finally_boss = 0 };
	local logic = i3k_game_get_logic();
	local restoredungeon  = false ;
	if table.getn(args) > 0 then
		restoredungeon = true;
	end
	local totleMonster = 0
	for k, v in ipairs(cfg.spawnPoints) do
		local scfg = i3k_db_spawn_point[v];
		if scfg then
			local sp = i3k_spawn_point.new(self._dungeon);
			if sp:Create(scfg, self._bbox, args[v]) then
				self._monsterNum.total			= self._monsterNum.total + sp._monsterNum.total;
				self._monsterNum.boss			= self._monsterNum.boss + sp._monsterNum.boss;
				self._monsterNum.finally_boss	= self._monsterNum.finally_boss + sp._monsterNum.finally_boss;
				table.insert(self._spawns, sp);
			end
		end
		totleMonster = totleMonster + self._monsterNum.total + self._monsterNum.boss
	end

	if totleMonster == 0 then
		self._HasTri = true
	else
		self._HasTri = false
	end

	self._bbox.minx = self._bbox.minx - i3k_integer(cfg.range);
	self._bbox.minz = self._bbox.minz - i3k_integer(cfg.range);
	self._bbox.maxx = self._bbox.maxx + i3k_integer(cfg.range);
	self._bbox.maxz = self._bbox.maxz + i3k_integer(cfg.range);

	return BASE.Create(self, id);
end

function i3k_spawn:Release()
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			if self._TargetIDs then
				for k, v in pairs(self._TargetIDs) do
					local trap = world._Traps[v];
					if trap then
						trap:SetTransLogic(eTrapTransAreaClear);
					end
				end
			end
		end
	end
	---------------击杀屏蔽门操作
	local world = logic:GetWorld();
	if world then
		local SpawnID = self._cfg.id
		local SpawnCfg = i3k_db_spawn_area[SpawnID]
		if SpawnCfg.EndOpen then
			for k, v in pairs(SpawnCfg.EndOpen) do
				local trap = world._Traps[v];
				if trap then
					if trap:GetStatus() ~= eSTrapAttack and trap:GetStatus() ~= eSTrapClosed then
						trap:SetTrapBehavior(eSTrapAttack,true);
						trap:ClearTransLogic()
					end
				end
			end
		end
		if SpawnCfg.EndClose then
			for k, v in pairs(SpawnCfg.EndClose) do
				local trap = world._Traps[v];
				if trap then
					if trap:GetStatus() ~= eSTrapActive then
						trap:SetTrapBehavior(eSTrapActive,true);
						trap:ClearTransLogic()
					end
				end
			end
		end
	end
		---------------
	--[[if self._Target then
		self._Target:SetTransLogic(eTrapTransAreaClear);
	end]]
	if self._spawns then
		for k, v in ipairs(self._spawns) do
			v:Release();
		end
	end

	BASE.Release(self);
end

function i3k_spawn:IsEmpty()
	if self._spawns then
		for k, v in ipairs(self._spawns) do
			if not v:IsEmpty() then
				return false;
			end

			local es = v:GetAliveEntitiesCount();
			if es > 0 then
				return false;
			end
		end
	end

	return true;
end

function i3k_spawn:IsTri()
	return self._isTri;
end

function i3k_spawn:Close()
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			if self._TargetIDs then
				for k, v in pairs(self._TargetIDs) do
					local trap = world._Traps[v];
					if trap then
						trap:SetTransLogic(eTrapTransAreaClear);
					end
				end
			end
		end
		---------------击杀屏蔽门操作
		local world = logic:GetWorld();
		if world then
			local SpawnID = self._cfg.id
			local SpawnCfg = i3k_db_spawn_area[SpawnID]
			if SpawnCfg.EndOpen then
				for k, v in pairs(SpawnCfg.EndOpen) do
					local trap = world._Traps[v];
					if trap then
						if trap:GetStatus() ~= eSTrapAttack and trap:GetStatus() ~= eSTrapClosed then
							trap:SetTrapBehavior(eSTrapAttack,true);
							trap:ClearTransLogic()
						end
					end
				end
			end
			if SpawnCfg.EndClose then
				for k, v in pairs(SpawnCfg.EndClose) do
					local trap = world._Traps[v];
					if trap then
						trap:SetTrapBehavior(eSTrapActive,true);
						trap:ClearTransLogic()
					end
				end
			end
		end
		---------------
	end
	--[[if self._Target then
		self._Target:SetTransLogic(eTrapTransAreaClear);
	end]]
end

function i3k_spawn:KillAllMonster()
	if self._spawns then
		for k, v in ipairs(self._spawns) do
			local monsters = v:GetAliveEntities();
			if monsters then
				for k1, v1 in ipairs(monsters) do
					v1:OnDead();
				end
			end
		end
	end
end

function i3k_spawn:OnUpdate(dTime)
	BASE.OnUpdate(self, dTime);

	if self._spawns then
		for k, v in ipairs(self._spawns) do
			v:OnUpdate(dTime);
		end
	end
end

function i3k_spawn:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	self._timeTick = self._timeTick + dTick * i3k_db_common.engine.tickStep;

	if not self._isTri and not self._denypush then
		local logic		= i3k_game_get_logic();
		local player	= logic:GetPlayer();

		local p1 = player:GetHeroPos();
		local bx = self._bbox;

		if p1.x <= bx.maxx and p1.x >= bx.minx and p1.z <= bx.maxz and p1.z >= bx.minz then
			---------------触发激活屏蔽门操作

			local world = logic:GetWorld();
			if world then
				local SpawnID = self._cfg.id
				local SpawnCfg = i3k_db_spawn_area[SpawnID]
				if SpawnCfg.BeginOpen then
					for k, v in pairs(SpawnCfg.BeginOpen) do
						local trap = world._Traps[v];
						if trap then
							if trap:GetStatus() ~= eSTrapAttack and trap:GetStatus() ~= eSTrapClosed then
								trap:SetTrapBehavior(eSTrapAttack,true);
								trap:ClearTransLogic()
							end
						end
					end
				end
				if SpawnCfg.BeginClose then
					for k, v in pairs(SpawnCfg.BeginClose) do
						local trap = world._Traps[v];
						if trap then
							trap:SetTrapBehavior(eSTrapActive,true);
							trap:ClearTransLogic()
						end
					end
				end
				if not world._sceneAni.bossbegin and self._spawns then
					for k, v in ipairs(self._spawns) do
						if v._monsterNum.finally_boss > 0 then
							world._sceneAni.bossbegin = true;
							if i3k_db_new_dungeon[world._cfg.id] then
								i3k_game_play_scene_ani(i3k_db_new_dungeon[world._cfg.id].bossbegin)
							end
--							g_i3k_game_context:playFlash(i3k_db_new_dungeon[world._cfg.id].bossbegin)
							break;
						end
					end
				end
				if SpawnCfg.spawndeny > 0 then
					self._denytime = SpawnCfg.spawndeny
					self._denypush = true;
				else
					self._isTri = true;
					if self._spawns then
						for k, v in ipairs(self._spawns) do
							v:Spawn();
						end
					end
				end
			end
			---------------
			--[[if self._spawns then
				for k, v in ipairs(self._spawns) do
					v:Spawn();
				end
			end]]
		end
	end

	if not self._isTri and self._denypush then
		--i3k_log("spawnpush:"..self._denytime)
		self._denytime = self._denytime - dTick * i3k_db_common.engine.tickStep;
		if self._denytime < 0 then
			self._denypush = false
			self._denytime = 0
			self._isTri = true;
			if self._spawns then
				for k, v in ipairs(self._spawns) do
					v:Spawn();
				end
			end
		end
	end

	if self._spawns then
		for k, v in ipairs(self._spawns) do
			v:OnLogic(dTick);
		end
	end
end

function i3k_spawn:CanMove()
	return false;
end
