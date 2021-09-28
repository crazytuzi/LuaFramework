------------------------------------------------------
module(..., package.seeall)

local require = require


------------------------------------------------------


------------------------------------------------------
local g_i3k_sendpingTime = 0;
i3k_player = i3k_class("i3k_player");
function i3k_player:ctor()
	-- only for pc move test
	self._moveKey	= { false, false, false, false };
	self._moveVel	= { x = 0, y = 0, z = 0 };
end

function i3k_player:Create()
	local logic = i3k_game_get_logic();

	self._hero			= nil;
	self._mercenaries	= { };
	self._escortCar		= { };
	self._pets			= { };
	self._summoned		= nil;
	self._marrycruise	= nil
	self._weaponCloneBody = nil
	self._npcs		= { };
	self._cameraentity	= nil;
	self._pickup		= { valid = false, items = { }, cacheItems = {}};
	self._synctick		= 0;
	self._mercenarypoptick	= 0;
	self._mercenatyindex	= 0;
	self._mercenarypoptime	= 5000;
	self._hero_bk = nil;

	return true;
end

function i3k_player:Release()
	if self._hero then
		self._hero:Release();
		self._hero = nil;
	end
	
	if self._hero_bk then
		self._hero_bk:Release();
		self._hero_bk = nil;
	end

	if self._mercenaries then
		for k, v in ipairs(self._mercenaries) do
			v:Release();
		end
		self._mercenaries = { };
	end

	if self._escortCar then
		for k,v in ipairs(self._escortCar) do
			v:Release();
		end
		self._escortCar = {}
	end

	if self._pets then
		for k, v in ipairs(self._pets) do
			v:Release();
		end
		self._pets = { };
	end
	
	if self._npcs then
		for k, v in ipairs(self._npcs) do
			v:Release();
		end
		self._npcs = { };
	end
	if self._marrycruise then
		self._marrycruise:Release()
		self._marrycruise = nil
	end

	if self._cameraentity then
		self._cameraentity:Release();
		self._cameraentity = nil;
	end
	
	if self._summoned then
		self._summoned:Release();
		self._summoned = nil;
	end

	if self._weaponCloneBody then
		self._weaponCloneBody:Release()
		self._weaponCloneBody = nil
	end
	self._synctick		= 0;
end

function i3k_player:OnUpdate(dTime, force)
	if force then
		if self._hero then
			self._hero:OnUpdate(dTime);
		end

		if self._mercenaries then
			for k, v in ipairs(self._mercenaries) do
				v:OnUpdate(dTime);
			end
		end

		if self._escortCar then
			for k,v in ipairs(self._escortCar) do
				v:OnUpdate(dTime)
			end
		end

		if self._pets then
			for k, v in ipairs(self._pets) do
				v:OnUpdate(dTime);
			end
		end

		if self._npcs then
			for k, v in ipairs(self._npcs) do
				v:OnUpdate(dTime);
			end
		end
		
		if self._summoned then
			self._summoned:OnUpdate(dTime);
		end

		if self._weaponCloneBody then
			self._weaponCloneBody:OnUpdate(dTime)
		end

		if self._marrycruise then
			self._marrycruise:OnUpdate(dTime)
		end
	end
	if self._cameraentity then
		self._cameraentity:OnUpdate(dTime);
	end
end

function i3k_player:OnLogic(dTick, force)
	if force then
		if self._hero then
			self._hero:OnLogic(dTick);
		end

		if self._mercenaries then
			for k, v in ipairs(self._mercenaries) do
				v:OnLogic(dTick);
			end
		end

		if self._escortCar then
			for k,v in ipairs(self._escortCar) do
				v:OnLogic(dTick);
			end
		end

		if self._pets then
			for k, v in ipairs(self._pets) do
				v:OnLogic(dTick);
			end
		end

		if self._npcs then
			for k, v in ipairs(self._npcs) do
				v:OnLogic(dTick);
			end
		end
		
		if self._marrycruise then
			self._marrycruise:OnLogic(dTick)
		end
		
		if self._summoned then
			self._summoned:OnLogic(dTick);
		end

		if self._weaponCloneBody then
			self._weaponCloneBody:OnLogic(dTick)
		end
	end
	if self._cameraentity then
		self._cameraentity:OnLogic(dTick);
	end
	self._synctick = self._synctick + dTick * i3k_engine_get_tick_step();
	-- if #self._mercenaries > 0 then
		-- local world = i3k_game_get_world()
		-- if world and world._mapType == g_FIELD or world._mapType == g_BASE_DUNGEON or world._mapType == g_ACTIVITY or world._mapType == g_TOWER then
			-- self._mercenarypoptick = self._mercenarypoptick + dTick * i3k_engine_get_tick_step();
		-- end
		-- if self._mercenarypoptick > self._mercenarypoptime then
			-- local mid = i3k_engine_get_rnd_u(1, #self._mercenaries);
			-- local mercenary = self._mercenaries[mid]
			-- if not mercenary:IsDead() then
				-- local ntype = 1
				-- local enmities = mercenary:GetEnmities();
				-- if enmities then
					-- local enmity = enmities[1];
					-- if enmity then
						-- ntype = 2
					-- end
				-- end
				-- g_i3k_ui_mgr:OpenUI(eUIID_MercenaryPop1+mid - 1);
				-- g_i3k_ui_mgr:RefreshUI((eUIID_MercenaryPop1+mid - 1),ntype,mid,mercenary);
			-- end
			-- self._mercenarypoptime = i3k_engine_get_rnd_u(i3k_db_common.mercenarypop.poptimefloor,i3k_db_common.mercenarypop.poptimeceil)
			-- self._mercenarypoptick = 0
		-- end
	-- end
	if self._synctick > 500 then
		if self._hero and self._hero:IsInFightTime() then
			self._hero:OnFightTime(self._synctick,true)
			local ctime = i3k_db_common.general.fighttime
			if self._hero:GetFightTime() > ctime then
				self._hero:ClearFightTime()
			end
		end
		local logic = i3k_game_get_logic();
		if logic then
			local selEntity = logic._selectEntity;
			if selEntity and selEntity._linkParent then
				selEntity = selEntity._linkParent
			end
			if selEntity and self._hero then
				local world = i3k_game_get_world()
				local dist = i3k_vec3_dist(selEntity._curPos, self._hero._curPos)
				local filterdist = i3k_db_common.engine.unselectTargetDist
				if self._hero._PVPStatus ~= g_PeaceMode then
					filterdist = i3k_db_common.engine.fightunselectTargetDist
				end
				if dist > filterdist then
					i3k_log("SwitchSelectEntity:"..dist)
					logic:SwitchSelectEntity(nil);
				end
			end
		end
		g_i3k_game_context:UpdatePlotTick(self._synctick);
		self._synctick = 0;
		if self._pickup.valid then --掉落
			local world = i3k_game_get_world();
			if world then
				i3k_sbean.pickup_drops(self._pickup.items);
				self._pickup.valid = false;
				self._pickup.items = { };
			end
		else
			self._pickup.cacheItems = {};
		end

		local cfg = g_i3k_game_context:GetUserCfg();
		local isSelect,mark = cfg:GetAutoTakeBloodData()
		if cfg then
			if isSelect == 1 and mark then
				if g_i3k_db.i3k_db_get_is_can_auto_drug() then
					g_i3k_game_context:AutoUseDrug(mark)
				end
			end
		end
	end
	g_i3k_sendpingTime = g_i3k_sendpingTime + dTick * i3k_engine_get_tick_step()
	if g_i3k_sendpingTime > 1000 then
		if g_i3k_game_context:GetMapEnter() == true then
			i3k_sbean.send_client_ping_start()
		end
		g_i3k_sendpingTime = 0;
	end
end

function i3k_player:ClearMercentPopTime()
	self._mercenarypoptick = 0;
end

function i3k_player:getBagJudge(mapType)
	local types = 
	{
		[g_FIELD] = function(args, id) return g_i3k_game_context:IsBagEnough(args) end,
		[g_FACTION_TEAM_DUNGEON] = function(args, id) return g_i3k_game_context:IsBagEnough(args) end,
		[g_ANNUNCIATE] = function(args, id) return g_i3k_game_context:IsBagEnough(args) end,
		[g_DESERT_BATTLE] = function(args, id)
			if id then
				local itemType = g_i3k_db.i3k_db_get_common_item_type(id)
				
				if itemType == g_COMMON_ITEM_TYPE_DESERT_ITEM or itemType == g_COMMON_ITEM_TYPE_DESERT_EQUIP then
					return g_i3k_game_context:IsDesertBagEnough(args) 
				end
			end
			
			return g_i3k_game_context:IsBagEnough(args) 
		end,
	}
	
	return types[mapType]
end

function i3k_player:AddPickup(pid, itemId, itemCount)
	local world = i3k_game_get_world()
	if world then
		local fun = self:getBagJudge(world._mapType) 
		
		if fun then
			local count = self._pickup.cacheItems[itemId] or 0
			self._pickup.cacheItems[itemId] = count + itemCount
			
 			if fun(self._pickup.cacheItems, itemId) then
				self._pickup.valid = true;
				self._pickup.items[pid] = true;
			else
				if count == 0 then
					self._pickup.cacheItems[itemId] = nil
				else
					self._pickup.cacheItems[itemId] = count
				end
			end
		else
			self._pickup.valid = true;
			self._pickup.items[pid] = true;
		end		
	end
end

function i3k_player:ReleasePickItems()
	self._pickup = { valid = false, items = { }, cacheItems= {},}
end

function i3k_player:GetHero()
	return self._hero;
end

function i3k_player:GetRealHero()
	return self._hero_bk
end

function i3k_player:SetHero(hero, release)
	if hero then
		local logic = i3k_game_get_logic();
		--i3k_log("SetHero")
		if self._hero then
			local pos = self._hero._curPos
			--i3k_log("self._hero._curPos: x = "..pos.x.." y = "..pos.y.." z = "..pos.z)
			hero:SetPos(self._hero._curPos);
			--i3k_log("SetPos")
			self._hero:DetachCamera();
			if not release then
				self._hero:Release();
			else
				self._hero:Show(false, true);
				self._hero_bk = self._hero;
			end
		end
		--i3k_log("SetHero2")
		self._hero = hero;
		if self._hero then
			--self._hero:AttachCamera(logic:GetMainCamera());

			if self._mercenaries then
				for k, v in ipairs(self._mercenaries) do
					v:Bind(self._hero);
				end
			end

			if self._escortCar then
				for k,v in ipairs(self._escortCar) do
					v:Bind(self._hero)
				end
			end

			if self._pets then
				for k, v in ipairs(self._pets) do
					v:Bind(self._hero);
				end
			end
			
			if self._summoned then
				self._summoned:Bind(self._hero);
			end

			if self._weaponCloneBody then
				self._weaponCloneBody:Bind(self._hero)
			end

			if self._npcs then
				for k, v in ipairs(self._npcs) do
					v:Bind(self._hero);
				end
			end
		end
	end
end

function i3k_player:Restore()
	if self._hero_bk then
		local world = i3k_game_get_world();
		world:OnPlayerEnterWorld(nil);
		self._hero_bk:CreateAgent();
		self:SetHero(self._hero_bk, false);
		self._hero_bk = nil;

		if self._hero then
			self._inPetLife = false;
			self._inDesertBattle = false;
			self._inSpyStory = false;
			self._hero:Show(true, true);
		end
	end
end

function i3k_player:SetCameraEntity()
	self:ResetCameraEntity();

	if self._hero then
		local SEntity = require("logic/entity/i3k_ghost");
		local entityPlayer = SEntity.i3k_ghost.new(i3k_gen_entity_guid_new(SEntity.i3k_ghost.__cname,self._hero._guid));
		local cfg = g_i3k_db.i3k_db_get_general(1);
		
		entityPlayer:CreateGhostRes(eET_Ghost,cfg)
		if self._hero._gender == 1 then
			entityPlayer:CreateGhost(-1,i3k_db_tournament_base.baseData.ghostM)
		else
			entityPlayer:CreateGhost(-1,i3k_db_tournament_base.baseData.ghostW)
		end
		
		entityPlayer:SetPos(self._hero._curPos);
		entityPlayer:SetHittable(false);
		entityPlayer:AddAiComp(eAType_IDLE);
		entityPlayer:AddAiComp(eAType_MOVE);
		entityPlayer:UpdateProperty(ePropID_speed, 1, i3k_db_tournament_base.baseData.deadspeed, true, false, true);
		local logic = i3k_game_get_logic();

		if self._hero then
			entityPlayer:SetPos(self._hero._curPos);
			self._hero:DetachChessFlag() --楚汉挂载
			self._hero:DetachCamera();
			self._hero:ReleaseAgent()
		end
		entityPlayer:AttachCamera(logic:GetMainCamera());
		entityPlayer:CreateAgent();
		self._cameraentity = entityPlayer;
	end
end

function i3k_player:SetPetLifeEntity(petId, level)
	if self._hero then
		local SEntity = require("logic/entity/i3k_pet_life");
		local petPlayer = SEntity.i3k_pet_life.new("i3k_pet_life@"..self._hero._guid)
		petPlayer:SetPlayer(true);

		local cfg = i3k_db_mercenaries[petId];
		local binskills = { }
		if cfg.skills then
			for k, v in ipairs(cfg.skills) do
				if v ~= -1 then
					table.insert(binskills, v)
				end
			end
			if cfg.ultraSkill then
				table.insert(binskills, cfg.ultraSkill)
			end
		end
		local logic = i3k_game_get_logic();	
		if petPlayer:Create(petId, level) then
			petPlayer:BindSkills(binskills)

			if petPlayer then
				petPlayer:AttachCamera(logic:GetMainCamera());
				petPlayer:SetFaceDir(0, 0, 0);
				petPlayer:SetGroupType(eGroupType_O);
				petPlayer:SetHittable(false);
				petPlayer:SetCtrlType(eCtrlType_Player);
				petPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
				petPlayer:AddAiComp(eAType_IDLE);
				petPlayer:AddAiComp(eAType_MOVE);
				petPlayer:AddAiComp(eAType_MANUAL_ATTACK);
				petPlayer:AddAiComp(eAType_MANUAL_SKILL);
				petPlayer:AddAiComp(eAType_FIND_TARGET);
				petPlayer:AddAiComp(eAType_SPA);
				petPlayer:AddAiComp(eAType_SHIFT);
				petPlayer:AddAiComp(eAType_DEAD);
				petPlayer:AddAiComp(eAType_DEAD_REVIVE);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_SKILL);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				petPlayer:AddAiComp(eAType_FEAR);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);

				petPlayer:AddAiComp(eAType_PRECOMMOND);
				petPlayer:AddAiComp(eAType_AUTO_NORMALATTACK);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_RETURN);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				petPlayer:Show(true, true);

				if g_i3k_game_context:GetPetGuardIsShow() then
					petPlayer:AttachPetGuard(g_i3k_game_context:GetCurPetGuard())
				else
					petPlayer:DetachPetGuard()
				end
				self:SetHero(petPlayer, true)
			end
		end
	end
end

function i3k_player:SetSprogEntity(id, level, gender)
	if self._hero then
		local SEntity = require("logic/entity/i3k_sprog");
		local sprogPlayer = SEntity.i3k_sprog.new("i3k_sprog@"..self._hero._guid)
		sprogPlayer:SetPlayer(true);

		local cfg = i3k_db_new_player_guide_init[id];
		local logic = i3k_game_get_logic();
		if sprogPlayer:Create(id, level, gender) then
			sprogPlayer:BindSkills(cfg.skills)

			if sprogPlayer then
				sprogPlayer:AttachCamera(logic:GetMainCamera());
				sprogPlayer:SetFaceDir(0, 0, 0);
				sprogPlayer:SetGroupType(eGroupType_O);
				sprogPlayer:SetHittable(true);
				sprogPlayer:SetCtrlType(eCtrlType_Player);
				sprogPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
				sprogPlayer:AddAiComp(eAType_IDLE);
				sprogPlayer:AddAiComp(eAType_MOVE);
				sprogPlayer:AddAiComp(eAType_MANUAL_ATTACK);
				sprogPlayer:AddAiComp(eAType_MANUAL_SKILL);
				sprogPlayer:AddAiComp(eAType_FIND_TARGET);
				sprogPlayer:AddAiComp(eAType_SPA);
				sprogPlayer:AddAiComp(eAType_SHIFT);
				sprogPlayer:AddAiComp(eAType_DEAD);
				sprogPlayer:AddAiComp(eAType_DEAD_REVIVE);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_SKILL);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				sprogPlayer:AddAiComp(eAType_FEAR);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);

				sprogPlayer:AddAiComp(eAType_PRECOMMOND);
				sprogPlayer:AddAiComp(eAType_AUTO_NORMALATTACK);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_RETURN);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				sprogPlayer:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				sprogPlayer:Show(true, true);

				self:SetHero(sprogPlayer, true)
				
				local equips = {cfg.weapon, cfg.hand, cfg.chest, cfg.shoes, cfg.head, cfg.ring}
				for _, v in pairs(equips) do
					sprogPlayer:AttachEquip(v);
				end
			end
		end
	end
end

function i3k_player:SetDesertBattleEntity(id)
	if self._hero then
		local SEntity = require("logic/entity/i3k_desertBattle_life");
		local desertPlayer = SEntity.i3k_desertBattle_life.new("i3k_desertBattle_life@"..self._hero._guid)
		desertPlayer:SetPlayer(true);

		local cfg = i3k_db_desert_generals[id];
		local binskills = { }
		
		if cfg and cfg.skills then
			for k, v in ipairs(cfg.skills) do
				if v ~= -1 then
					table.insert(binskills, v)
				end
			end
			if cfg.ultraSkill then
				table.insert(binskills, cfg.ultraSkill)
			end
		end
		local logic = i3k_game_get_logic();
		
		if desertPlayer:Create(id) then
			desertPlayer:BindSkills(binskills)

			if desertPlayer then
				desertPlayer:AttachCamera(logic:GetMainCamera());
				desertPlayer:SetFaceDir(0, 0, 0);
				desertPlayer:SetGroupType(eGroupType_O);
				desertPlayer:SetHittable(false);
				desertPlayer:SetCtrlType(eCtrlType_Player);
				desertPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
				desertPlayer:AddAiComp(eAType_IDLE);
				desertPlayer:AddAiComp(eAType_MOVE);
				desertPlayer:AddAiComp(eAType_MANUAL_ATTACK);
				desertPlayer:AddAiComp(eAType_MANUAL_SKILL);
				desertPlayer:AddAiComp(eAType_FIND_TARGET);
				desertPlayer:AddAiComp(eAType_SPA);
				desertPlayer:AddAiComp(eAType_SHIFT);
				desertPlayer:AddAiComp(eAType_DEAD);
				desertPlayer:AddAiComp(eAType_DEAD_REVIVE);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_SKILL);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				desertPlayer:AddAiComp(eAType_FEAR);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);

				desertPlayer:AddAiComp(eAType_PRECOMMOND);
				desertPlayer:AddAiComp(eAType_AUTO_NORMALATTACK);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_RETURN);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				desertPlayer:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				desertPlayer:Show(true, true);

				self:SetHero(desertPlayer, true)			
			end
		end
	end
end

function i3k_player:SetBiographyCareerEntity(careerId)
	if self._hero then
		local SEntity = require("logic/entity/i3k_biography_career");
		local petPlayer = SEntity.i3k_biography_career.new("i3k_biography_career@"..self._hero._guid)
		petPlayer:SetPlayer(true);
		local binskills = {}
		local equips = {}
		local careerData = g_i3k_game_context:getBiographyCareerInfo()
		if careerData and careerData[careerId] and careerData[careerId].taskId ~= 0 then
			binskills = careerData[careerId].equipSkills
			local taskCfg = i3k_db_wzClassLand_task[careerId][careerData[careerId].taskId]
			equips = {[eEquipWeapon] = i3k_db_wzClassLand_prop[taskCfg.changeClassID].weapon, [eEquipClothes] = i3k_db_wzClassLand_prop[taskCfg.changeClassID].chest}
		end
		local logic = i3k_game_get_logic();	
		if petPlayer:Create(careerId) then
			petPlayer:BindSkills(binskills)
			if petPlayer then
				petPlayer:AttachCamera(logic:GetMainCamera());
				petPlayer:SetFaceDir(0, 0, 0);
				petPlayer:SetGroupType(eGroupType_O);
				petPlayer:SetHittable(false);
				petPlayer:SetCtrlType(eCtrlType_Player);
				petPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
				petPlayer:AddAiComp(eAType_IDLE);
				petPlayer:AddAiComp(eAType_MOVE);
				petPlayer:AddAiComp(eAType_MANUAL_ATTACK);
				petPlayer:AddAiComp(eAType_MANUAL_SKILL);
				petPlayer:AddAiComp(eAType_FIND_TARGET);
				petPlayer:AddAiComp(eAType_SPA);
				petPlayer:AddAiComp(eAType_SHIFT);
				petPlayer:AddAiComp(eAType_DEAD);
				petPlayer:AddAiComp(eAType_DEAD_REVIVE);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_SKILL);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				petPlayer:AddAiComp(eAType_FEAR);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);
				petPlayer:AddAiComp(eAType_PRECOMMOND);
				petPlayer:AddAiComp(eAType_AUTO_NORMALATTACK);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_RETURN);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				petPlayer:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				petPlayer:Show(true, true);
				self:SetHero(petPlayer, true)
				for k, v in pairs(equips) do
					petPlayer:changeEquipSkin(k, v)
				end
				petPlayer:SetCombatType(careerData[careerId].combat.combatType)
			end
		end
	end
end

function i3k_player:SetSpyEntity(camp,id)
	if self._hero then
		local SEntity = require("logic/entity/i3k_spy_life");
		local spyPlayer = SEntity.i3k_spy_life.new("i3k_spy_life@"..self._hero._guid)
		spyPlayer:SetPlayer(true);

		local cfg = i3k_db_spy_story_generals[camp][id];
		local binskills = { }
		
		if cfg and cfg.skills then
			for k, v in ipairs(cfg.skills) do
				if v ~= -1 then
					table.insert(binskills, v)
				end
			end
			if cfg.ultraSkill then
				table.insert(binskills, cfg.ultraSkill)
			end
		end
		local logic = i3k_game_get_logic();
		
		if spyPlayer:Create(camp,id) then
			spyPlayer:BindSkills(binskills)

			if spyPlayer then
				spyPlayer:AttachCamera(logic:GetMainCamera());
				spyPlayer:SetFaceDir(0, 0, 0);
				spyPlayer:SetGroupType(eGroupType_O);
				spyPlayer:SetHittable(false);
				spyPlayer:SetCtrlType(eCtrlType_Player);
				spyPlayer:Play(i3k_db_common.engine.defaultStandAction, -1);
				spyPlayer:AddAiComp(eAType_IDLE);
				spyPlayer:AddAiComp(eAType_MOVE);
				spyPlayer:AddAiComp(eAType_MANUAL_ATTACK);
				spyPlayer:AddAiComp(eAType_MANUAL_SKILL);
				spyPlayer:AddAiComp(eAType_FIND_TARGET);
				spyPlayer:AddAiComp(eAType_SPA);
				spyPlayer:AddAiComp(eAType_SHIFT);
				spyPlayer:AddAiComp(eAType_DEAD);
				spyPlayer:AddAiComp(eAType_DEAD_REVIVE);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_SKILL);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				spyPlayer:AddAiComp(eAType_FEAR);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);

				spyPlayer:AddAiComp(eAType_PRECOMMOND);
				spyPlayer:AddAiComp(eAType_AUTO_NORMALATTACK);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_RETURN);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				spyPlayer:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				spyPlayer:Show(true, true);

				self:SetHero(spyPlayer, true)			
			end
		end
	end
end

function i3k_player:ResetCameraEntity()
	if self._hero and self._cameraentity then
		local logic = i3k_game_get_logic();
		self._cameraentity:ReleaseAgent()
		self._cameraentity:DetachCamera();
		self._hero:AttachCamera(logic:GetMainCamera());
		self._hero:CreateAgent();
		self._cameraentity:Release();
		self._cameraentity = nil;
	end
end

function i3k_player:SetHeroPos(pos)
	if self._hero then
		self._hero:SetPos(pos);
	end

	if self._mercenaries then
		for k, v in ipairs(self._mercenaries) do
			--[[
			local posE = i3k_vec3_clone(self._hero._curPosE);

			local findCnt = 0;
			while true do
				local rnd_x = i3k_engine_get_rnd_f(-1, 1);
				local rnd_z = i3k_engine_get_rnd_f(-1, 1);

				local _pos = i3k_vec3_clone(posE);
				_pos.x = posE.x + rnd_x;
				_pos.y = posE.y + 1;
				_pos.z = posE.z + rnd_z;
				_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));

				local paths = g_i3k_mmengine:FindPath(entity._curPosE, i3k_vec3_to_engine(_pos));
				if paths:size() > 0 then
					posE = paths:front();

					break;
				end

				findCnt = findCnt + 1;
				if findCnt > 5 then
					break;
				end
			end
			]]
			local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3);

			v:SetPos(i3k_world_pos_to_logic_pos(_pos));
		end
	end

	if self._escortCar then
		for k,v in ipairs(self._escortCar) do
			local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3)

			v:SetPos(i3k_world_pos_to_logic_pos(_pos))
		end
	end

	if self._pets then
		for k, v in ipairs(self._pets) do
			local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3);

			v:SetPos(i3k_world_pos_to_logic_pos(_pos));
		end
	end
	
	if self._summoned then
		local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3);
		self._summoned:SetPos(i3k_world_pos_to_logic_pos(_pos));
	end

	if self._weaponCloneBody then
		local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3)
		self._weaponCloneBody:SetPos(i3k_world_pos_to_logic_pos(_pos))
	end

	if self._npcs then
		for k, v in ipairs(self._npcs) do
			local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3);

			v:SetPos(i3k_world_pos_to_logic_pos(_pos));
		end
	end

	if self._marrycruise then
		local _pos = g_i3k_mmengine:GetRandomPos(self._hero._curPosE, 3);
		self._marrycruise:SetPos(i3k_world_pos_to_logic_pos(_pos));
	end
end

function i3k_player:GetHeroPos()
	if self._hero then
		return self._hero._curPos;
	end

	return i3k_vec3(0, 0, 0);
end

function i3k_player:Show(s, r, f)
	if self._hero then
		self._hero:Show(s, r, f);
		self._hero:ShowTitleNode(s);
	end

	if self._mercenaries then
		for k, v in ipairs(self._mercenaries) do
			v:Show(s, r, f);
			v:ShowTitleNode(s);
		end
	end

	if self._escortCar then
		for k, v in ipairs(self._escortCar) do
			v:Show(s, r, f);
			v:ShowTitleNode(s);
		end
	end

	if self._pets then
		for k, v in ipairs(self._pets) do
			v:Show(s, r, f);
			v:ShowTitleNode(s);
		end
	end
	
	if self._summoned then
		self._summoned:Show(s, r, f);
		self._summoned:ShowTitleNode(s);
	end

	if self._weaponCloneBody then
		self._weaponCloneBody:Show(s, r, f)
		self._weaponCloneBody:ShowTitleNode(s)
	end

	if self._npcs then
		for k, v in ipairs(self._npcs) do
			v:Show(s, r, f);
			v:ShowTitleNode(s);
		end
	end
	if self._marrycruise then
		self._marrycruise:Show(s, r, f)
		self._marrycruise:ShowTitleNode(s)
	end
end

function i3k_player:AddMercenary(mercenary)
	if mercenary then
		if self._hero then
			mercenary:Bind(self._hero);
		end
		table.insert(self._mercenaries, mercenary);
	end
end

function i3k_player:RmvMercenary(idx)
	local mercenary = self._mercenaries[idx];
	if mercenary then
		mercenary:Release();
	end
	table.remove(self._mercenaries, idx);
end

function i3k_player:GetMercenaryCount()
	return #self._mercenaries;
end

function i3k_player:GetMercenary(idx)
	return self._mercenaries[idx];
end

function i3k_player:GetMercenaries()
	return self._mercenaries;
end

function i3k_player:AddEscortCar(escortCar)
	if escortCar then
		if self._hero then
			escortCar:Bind(self._hero);
		end
		table.insert(self._escortCar, escortCar);
	end
end

function i3k_player:RmvEscortCar(idx)
	local escortCar = self._escortCar[idx];
	if escortCar then
		escortCar:RestoreModelFacade();
		escortCar:Release();
	end
	table.remove(self._escortCar, idx);
end

function i3k_player:GetEscortCarCount()
	return #self._escortCar;
end

function i3k_player:GetEscortCar(idx)
	return self._escortCar[idx];
end

function i3k_player:GetEscortCars()
	return self._escortCar;
end

function i3k_player:UseItem(id)
	if self._hero then
		self._hero:UseItem(id);
	end
end

function i3k_player:AddPet(pet)
	if pet then
		if self._hero then
			pet:Bind(self._hero);
		end
		table.insert(self._pets, pet);
	end
end

function i3k_player:RmvPet(idx,isrelease)
	local pet = self._pets[idx];
	if pet then
		if isrelease then
			pet:Release();
		end

		table.remove(self._pets, idx);
	end
end

function i3k_player:GetPetIdx(guid)
	for k,v in pairs(self._pets) do
		if v._guid == guid then
			return k
		end
	end
	return 0;
end

function i3k_player:GetPetCount()
	return #self._pets;
end

function i3k_player:GetPet(idx)
	return self._pets[idx];
end

function i3k_player:AddSummoned(summoned)
	if summoned then
		if self._hero then
			self._summoned = summoned;
			self._summoned:Bind(self._hero);
		end
	end
end

function i3k_player:RmvSummoned()
	if self._summoned then
		self._summoned:Release();
		self._summoned = nil;
	end
end

function i3k_player:GetSummoned()
	if self._summoned then
		return self._summoned;
	end
	return false;
end

--神兵分身
function i3k_player:AddWeaponCloneBody(cloneBody)
	if cloneBody then
		if self._hero then
			self._weaponCloneBody = cloneBody;
			self._weaponCloneBody:Bind(self._hero)
		end
	end
end
function i3k_player:RmvWeaponCloneBody()
	if self._weaponCloneBody then
		self._weaponCloneBody:Release()
		self._weaponCloneBody = nil
	end
end

function i3k_player:GetWeaponCloneBody()
	return self._weaponCloneBody
end

function i3k_player:AddMarryCruise(marryCruise)
	if marryCruise then
		if self._hero then
			marryCruise:Bind(self._hero);
		end
		self._marrycruise = marryCruise
	end
end

function i3k_player:RmvMarryCruise()
	if self._marrycruise then
		self._marrycruise:Release();
		self._marrycruise = nil
	end
end

function i3k_player:GetMarryCruise()
	return self._marrycruise
end

function i3k_player:AddNPC(npc)
	if npc then
		if self._hero then
			npc:Bind(self._hero);
		end
		table.insert(self._npcs, npc);
	end
end

function i3k_player:RmvNPC(idx,isrelease)
	local npc = self._npcs[idx];
	if npc then
		if isrelease then
			npc:Release();
		end

		table.remove(self._npcs, idx);
	end
end

function i3k_player:GetNPCIdx(guid)
	for k,v in pairs(self._npcs) do
		if v._guid == guid then
			return k
		end
	end
	return 0;
end

function i3k_player:GetNPCCount()
	return #self._npcs;
end

function i3k_player:GetNPC(idx)
	return self._npcs[idx];
end

function i3k_player:MoveTo(pos)
	if self._hero then
		self._hero:UseSkill(nil);
		self._hero:SetTarget(nil);

		self._hero:MoveTo(pos);
	end

	if self._cameraentity then
		self._cameraentity:UseSkill(nil);
		self._cameraentity:SetTarget(nil);

		self._cameraentity:MoveTo(pos);
	end
end

function i3k_player:SetVelocity(vel)
	if self._hero then
		self._hero:UseSkill(nil);
		self._hero:SetTarget(nil);
		self._hero:ClearFindwayStatus(true)
--		self._hero._isfindway = false
		self._hero:SetVelocity(vel);
	end

	if self._cameraentity then
		self._cameraentity:UseSkill(nil);
		self._cameraentity:SetTarget(nil);

		self._cameraentity:SetVelocity(vel);
	end
end

function i3k_player:StopMove()
	if self._hero then
		self._hero:StopMove();
	end
	if self._cameraentity then
		self._cameraentity:StopMove();
	end
end

function i3k_player:OnKeyDown(handled, key)
	if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
		local logic = i3k_game_get_logic();
		local mainCamera = logic:GetMainCamera();

		if key == 97 then -- 1
			--i3k_pause();
		elseif key == 98 then -- 2
			--i3k_resume();
		elseif key == 17 then -- w
			self._moveKey[1] = true;
			self._moveVel.z = -1;
		elseif key == 30 then -- a
			self._moveKey[2] = true;
			self._moveVel.x = -1;
		elseif key == 31 then -- s
			self._moveKey[3] = true;
			self._moveVel.z =  1;
		elseif key == 32 then -- d
			self._moveKey[4] = true;
			self._moveVel.x =  1;
		end

		if self._moveKey[1] or self._moveKey[2] or self._moveKey[3] or self._moveKey[4] then
 			local hero = self:GetHero()
			hero._PreCommand = ePreTypeJoystickMove;
			if hero._AutoFight then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
			end

			local angle1 = i3k_vec3_angle1(mainCamera._right, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0));
			local angle2 = i3k_vec3_angle1(self._moveVel, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0));
			local angle = angle2 - angle1;

			local vel = { x = math.cos(angle), y = 0, z = math.sin(angle) }
			self._hero:ClearFindwayStatus(true)
	--		hero._isfindway = false
			self:SetVelocity(vel);
		end
		
		if key==15 then -- Tab
			local hero = self:GetHero()
			hero:ChangeEnemy()
		end

		return 0;
	end
end

function i3k_player:OnKeyUp(handled, key)
	if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
		local logic = i3k_game_get_logic();
		local mainCamera = logic:GetMainCamera();

		if key == 17 then -- w
			self._moveKey[1] = false;
			self._moveVel.z = 0;
		elseif key == 30 then -- a
			self._moveKey[2] = false;
			self._moveVel.x = 0;
		elseif key == 31 then -- s
			self._moveKey[3] = false;
			self._moveVel.z = 0;
		elseif key == 32 then -- d
			self._moveKey[4] = false;
			self._moveVel.x = 0;
		elseif key == 33 then -- f
			i3k_log("play current position = " .. i3k_format_pos(self._hero._curPosE));
		elseif key == 34 then -- g
			--[[
			if self._testEffectID and self._testEffectID > 0 then
				g_i3k_actor_manager:ReleaseSceneNode(self._testEffectID);
			end
			self._testEffectID = -1;

			self._testEffectID = g_i3k_actor_manager:CreateSceneNode("effect/mt/fankelifu_attack03_gongji.aef", "demo_effect");
			if self._testEffectID ~= -1 then
				g_i3k_actor_manager:EnterScene(self._testEffectID);

				g_i3k_actor_manager:SetLocalTrans(self._testEffectID, self._hero._curPosE);
				g_i3k_actor_manager:SetVisible(self._testEffectID, true, true);
				g_i3k_actor_manager:Play(self._testEffectID, -1);
			end
			]]
		--[[
		elseif key == 36 then -- j
			self._hero:MaunalAttack(0);
		elseif key == 37 then -- k
			self._hero:MaunalAttack(1);
		elseif key == 38 then -- l
			self._hero:MaunalAttack(2);
		elseif key == 23 then -- i
			self._hero:MaunalAttack(3);
		elseif key == 24 then -- o
			self._hero:MaunalAttack(4);
		elseif key == 18 then -- e
			self._hero:AttachEquip(600413001);
		elseif key == 19 then -- r
			self._hero:DetachEquip(eFashion_Body, true);
		elseif key == 20 then -- t
			self._hero:AttachEquip(10413001);
		]]
		elseif key == 87 then -- F11
			i3k_engine_set_frame_interval_scale(1.0);
		end

		if not self._moveKey[1] and not self._moveKey[2] and not self._moveKey[3] and not self._moveKey[4] then
			local hero = self:GetHero()
			--if hero._AutoFight then
				hero._PreCommand = -1;
			--end
			self._hero:StopMove();
			if self._cameraentity then
				self._cameraentity:StopMove();
			end
		else
			local angle1 = i3k_vec3_angle1(mainCamera._right, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0));
			local angle2 = i3k_vec3_angle1(self._moveVel, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0));
			local angle = angle2 - angle1;

			local vel = { x = math.cos(angle), y = 0, z = math.sin(angle) }
			self:SetVelocity(vel);
		end

		return 0;
	end
end

function i3k_player:OnHitObject(handled, entity)
	if self._hero then
		local guid = entity._guid
		local index = string.find(guid, '|', 1)
		local entityClass
		if index then
			entityClass = string.sub(guid, 1, index-1)
			if entityClass=="i3k_hero" then
				--g_i3k_game_context:SetTargetTeamId(tonumber(entity:GetTeamID()))
				local beforeClass = g_i3k_game_context:GetTargetClass()
				if beforeClass and beforeClass==entityClass then
					local index = string.find(guid, '|', 1)
					local roleId
					if index and entityClass=="i3k_hero" then
						roleId = tonumber(string.sub(guid, index+1, -1))
					end
					local beforeTargetId = g_i3k_game_context:GetTargetId()
					if roleId==beforeTargetId then

					else
						g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
					end
				end

				g_i3k_game_context:SetTargetGuid(guid)
			end
		else
			g_i3k_game_context:SetTargetGuid(nil)
			g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		end
		self._hero:UpdateAlives()
		self._hero:SetForceTarget(entity);

		return 1;
	end

	return 0;
end

function i3k_player:OnHitGround(handled, x, y, z)
	if self._hero then
		self._hero:SetForceTarget(nil);
		--[[
		local battleUI = g_i3k_ui_mgr:GetUI(eUIID_Battle)
		if battleUI then
			local bossUI = battleUI:GetChildByVarName("boss")
			bossUI:hide()
			g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		end
		]]

		local logic = i3k_game_get_logic();
		local world = logic:GetWorld();
		local user_cfg = i3k_get_load_cfg()
		if world and user_cfg:GetIsTouchOperate() then
			if logic._configure.hitGround then
				--self._hero:SetPos(i3k_world_pos_to_logic_pos(i3k_vec3(x, y, z)));
				self._hero:ClearFindwayStatus(true)
--				self._hero._isfindway = false
				self:MoveTo(i3k_vec3(x, y, z));
			end
		end
	end
end

function i3k_player:OnTouchUp()
	if self._hero then
		self._hero:SetForceTarget(nil)
	end
end
