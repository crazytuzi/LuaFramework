----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;
--require("logic/entity/i3k_entity_itemdrop_def");

------------------------------------------------------
i3k_ai_dead = i3k_class("i3k_ai_dead", BASE);
function i3k_ai_dead:ctor(entity)
	self._type = eAType_DEAD;
end

function i3k_ai_dead:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity:IsDead();
end

function i3k_ai_dead:OnEnter()
	if BASE.OnEnter(self) then
		self._fadeOut	= false;
		self._slowMotion= false;

		local logic = i3k_game_get_logic();
		if logic then
			local player = logic:GetPlayer();
			if player and player:GetHero() then
				local hero = player:GetHero();
				if hero then
					if hero._autonormalattack then
						if hero._guid == self._entity._guid then
							hero._preautonormalattack = false;
							hero._autonormalattack = false;
						elseif self._entity._selected == self._entity._guid then
							hero._preautonormalattack = false;
							hero._autonormalattack = false;
						elseif hero._follow then
							if hero._follow._guid == self._entity._guid then
								hero._preautonormalattack = false;
								hero._autonormalattack = false;
							end
						end
					end
					
				end
			end
		end
		self._entity:ShowTitleNode(false);
		if self._entity:GetEntityType() == eET_Player then
			--清神兵状态
			if self._entity._superMode.valid then
				local hero = i3k_game_get_player_hero()
				if self._entity:IsPlayer() then
					self._entity:SuperMode(false)
												
					local maptype = 
					{
						[g_FORCE_WAR] = true,
						[g_DEMON_HOLE] = true,
						[g_FACTION_WAR] = true,
						[g_DEFENCE_WAR] = true,
						[g_MAZE_BATTLE] = true,
					}
					
					local map = i3k_game_get_map_type()
					
					if map and maptype[map] then
						self._entity:OnUnifyMode(true)
					end
				else
					self._entity:OnSuperMode(false)
				end
			end
			if self._entity:IsPlayer() then
				g_i3k_game_context:ResetLeadMode()
				local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
				if animation then
					g_i3k_game_context:OnStuntAnimationChangeHandler(animation,false)
				end
			end
			--清骑乘
			local world = i3k_game_get_world()
			if world and not world._syncRpc then
				if self._entity:IsOnRide() then
					self._entity:OnRideMode(false, true)
				end
			end
			if self._entity._DIYSkill then
				self._entity._DIYSkill:OnReset();
			end
				
		end
		if self._entity:GetEntityType() ~= eET_Pet and self._entity:GetEntityType() ~= eET_Skill then
			local alist = {}
			table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadAction, actloopTimes = 1})
			table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
			self._entity:PlayActionList(alist, 1);
		end
		self._entity:LockAni(true);

		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local syncRpc = world._syncRpc;
				if not syncRpc then
					-- send cmd
					local entity = self._entity;
					if entity and entity:GetEntityType() == eET_Monster and entity._spawnID > 0 then
						local weaponID = g_i3k_game_context:IsInSuperMode() and 1 or 0
						local damageRank = g_i3k_game_context:GetMapCopyDamageRank()
						local args = { spawnPointID = entity._spawnID , pos = entity._curPos, weaponID = weaponID, damageRank = damageRank}
						i3k_sbean.sync_privatemap_kill(args)
					end
				end
			end
		end

		if self._entity:GetEntityType() == eET_Player then
			if logic then
				local player = logic:GetPlayer()
				local hero = nil
				if player then
					hero = player:GetHero()
				end
				local logic = i3k_game_get_logic();
				local world = logic:GetWorld()
				local PetCount = player:GetPetCount()
				for i = 1,tonumber(PetCount) do
					local Pet = player:GetPet(i)
					Pet:OnDead()
				end
				if g_i3k_db.i3k_db_get_is_open_revive_ui() then	
					if hero._guid == self._entity._guid then
						if hero._killerId and hero._killerId < 0 then
							--天雷复活界面
							local killerID = math.abs(hero._killerId);
							local guid = string.split(hero._guid, "|")
							local playerId = tonumber(guid[2])
							if killerID == playerId then
								g_i3k_logic:OpenReviveUI(true)
							else
								g_i3k_logic:OpenReviveUI()
							end
						else
							g_i3k_logic:OpenReviveUI()
						end
						--i3k_log("eUIID_PlayerRevive")
						local MercenaryCount = player:GetMercenaryCount();
						for i = 1,tonumber(MercenaryCount) do
							local Mercenary = player:GetMercenary(i)
							Mercenary:OnDead()
						end
						hero:RemoveSummoned() --主角死亡移除附灵卫
					end
				else
					if hero._guid == self._entity._guid then
						if (i3k_game_get_map_type() == g_ARENA_SOLO or i3k_game_get_map_type() == g_TAOIST) then
							g_i3k_game_context:SetAutoFight(false)
							local MercenaryCount = player:GetMercenaryCount();
							for i = 1,tonumber(MercenaryCount) do
								local Mercenary = player:GetMercenary(i)
								if not Mercenary:IsDead() then
									local camera = logic:GetMainCamera()
									hero:DetachCamera()
									Mercenary:AttachCamera(camera);
									camera:UpdatePos(Mercenary._curPosE);
									break;
								end
							end
						elseif i3k_game_get_map_type() == g_DEFENCE_WAR then
							g_i3k_logic:OpenDefenceWarReviveUI()
							local MercenaryCount = player:GetMercenaryCount();
							for i = 1,tonumber(MercenaryCount) do
								local Mercenary = player:GetMercenary(i)
								Mercenary:OnDead()
							end
							hero:RemoveSummoned() --主角死亡移除附灵卫
						end
					end
				end
				if world and not world._syncRpc then
					self._entity:ClsHorseAi();
				end
			end
		end

		if self._entity._forceAttackTarget then
			self._entity._forceAttackTarget = nil;
		end

		if self._entity:GetEntityType() == eET_Mercenary then
			self._entity._deadTimeLine = g_i3k_get_GMTtime(i3k_game_get_time())
			if logic then
				local player = logic:GetPlayer()
				local hero = nil
				if player then
					hero = player:GetHero()
				end
				local logic = i3k_game_get_logic();
				local world = logic:GetWorld()
				if world._fightmap then
					if hero:IsDead() and (i3k_game_get_map_type() == g_ARENA_SOLO or i3k_game_get_map_type() == g_TAOIST) then
						local guid1 = string.split(hero._guid, "_")
						local guid2 = string.split(self._entity._guid, "_")	
						if tonumber(guid1[2]) == tonumber(guid2[3]) then
							local MercenaryCount = player:GetMercenaryCount();
							for i = 1,tonumber(MercenaryCount) do
								local Mercenary = player:GetMercenary(i)
								if not Mercenary:IsDead() then
									local camera = logic:GetMainCamera()
									self._entity:DetachCamera()
									Mercenary:AttachCamera(camera);
									camera:UpdatePos(Mercenary._curPosE);
									break;
								end
							end
						end
					end
				end
			end
			self._entity:ClsEnmities();
		end
		if self._entity:GetEntityType() == eET_Player or self._entity:GetEntityType() == eET_Mercenary then
			self._entity:ClearFightTime();
		end
		if self._entity:GetEntityType() ~= eET_Player and self._entity:GetEntityType() ~= eET_Mercenary then
			--self._entity:SetHittable(false);
		end
		if self._entity:GetEntityType() == eET_Pet then
			local world = i3k_game_get_world();
			local player = i3k_game_get_player()
			if world and not world._syncRpc then
				if self._entity._hoster then
					local curFightSP = self._entity._hoster:GetFightSp()
					self._entity._hoster:UpdateFightSpCanYing(curFightSP - 1)
					local index = player:GetPetIdx(self._entity._guid)
					if index > 0  then
						player:RmvPet(index)
					end
				end
			end
		end
		return true;
	end

	return false;
end

function i3k_ai_dead:OnLeave()
	if BASE.OnLeave(self) then
		self._entity:LockAni(false);

		return true;
	end

	return false;
end

function i3k_ai_dead:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		if dTick > 0 then
			if self._timeTick > 4000 then
				if self._entity:CanRelease() then
					self._entity:Destory()
				end
			elseif self._timeTick > 2000 then
				if self._entity:CanRelease() then
					if not self._fadeOut then
						self._fadeOut = true;

						self._entity:Show(false, true, 2000);
					end
				end
			end
			if self._entity:GetEntityType() == eET_Pet or self._entity:GetEntityType() == eET_Skill then
				if self._entity:CanRelease() then
					self._entity:Destory()
				end
			end
		end

		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_dead.new(entity, priority);
end

