----------------------------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");
require("logic/i3k_game_context");

local g_i3k_enter_map_timeout = 5; -- 5秒

------------------------------------------------------
i3k_base_logic = i3k_class("i3k_base_logic");
function i3k_base_logic:ctor()
	self._isLoadingMap
		= false;
	self._isLoadHandled
		= true;
	self._enterMapTime
		= 0;
	self._curMap
		= "";
	self._loadingTime
		= 0;
	self._loadingTick
		= 0;
	self._loadedCB
		= nil;
	self._deltaTime
		= 0;
	self._tickLine
		= 0;
	self._deltaTick
		= 0;
	self._tickTime
		= 0;
	self._logicTicks
		= 0;
	self._mainCamera
		= nil;
	self._player
		= nil;
	self._dungeonID
		= -1;
	self._lastdungeonID
		= -1;
	self._world
		= nil;
	self._selectEntity
		= nil;
	self._timers
		= { };
	self._timerScale
		= 1;
	self._dirtyTickLine
		= false;
	self._checkTime 
		= 0;

	-- only for pc move test
	self._configure = { yg = true, hitGround = true };
end

function i3k_base_logic:Create()
	local SCamera = require("i3k_camera");
	self._mainCamera = SCamera.i3k_main_camera.new();

	i3k_game_context_create();

	return true;
end

function i3k_base_logic:Release()
	if self._player then
		self._player:Release();
		self._playe	= nil;
	end

	self._mainCamera = nil;

	i3k_game_context_cleanup();
end

function i3k_base_logic:OnUpdate(dTime)
	if self._dirtyTickLine then
		self._dirtyTickLine = false;

		self._tickTime		= self._tickTime - dTime;
		self._logicTicks = self._logicTicks - i3k_integer(((self._deltaTick + i3k_integer(dTime * 1000)) / i3k_engine_get_tick_step()));
	end

	self._deltaTime	= dTime;
	self._tickTime	= self._tickTime + dTime;
	self._tickLine	= i3k_integer(self._tickTime * 1000);
	self._checkTime = self._checkTime + dTime * 1000;


	if self._isLoadingMap then
		local ui = g_i3k_ui_mgr:GetUI(eUIID_Loading);
		if ui then
			ui:updateLoadProg(g_i3k_mmengine:GetMapLoadingProgress());
		end

		self._loadingTime = self._loadingTime + i3k_integer(dTime * 1000);
		if g_i3k_mmengine:IsMapLoadOK() and self._loadingTime > i3k_engine_get_min_load_time() then
			self._loadingTick = self._loadingTick + i3k_integer(dTime * 1000);
			if self._loadingTick > self._loadingDelay then
				self._enterMapTime = self._enterMapTime + dTime;

				if not self._isLoadHandled then
					self._isLoadHandled = true;

					local cfg = g_i3k_game_context:GetUserCfg()
					g_i3k_game_handler:EnableObjHitTest(true, cfg:GetIsTouchOperate());

					if self._player then
						local hero = self._player:GetHero();
						if hero then
							hero:CreateAgent();
						end
					end

					if self._loadedCB then
						local oldCB = self._loadedCB;
						self._loadedCB();
						if oldCB == self._loadedCB then
							self._loadedCB = nil;
						end
					end

					if self._globalMapCB then
						self._globalMapCB.func(self._globalMapCB.args);
						self._globalMapCB = nil;
					end
				end

				i3k_global_log_info("self:CheckLoaded()");
				if self:CheckLoaded() then
					i3k_global_log_info("self:CheckLoaded() ok");

					self._isLoadingMap = false;

					g_i3k_ui_mgr:CloseUI(eUIID_Loading);
				else
					if self._enterMapTime > g_i3k_enter_map_timeout then
						self._enterMapTime = 0;

						i3k_game_send_str_cmd(i3k_sbean.role_enter_map.new());
					end
				end
			else
				if not g_i3k_game_context:getIsNeedLoading() then
				g_i3k_ui_mgr:OpenUI(eUIID_Loading);
				else
					local hero = i3k_game_get_player_hero()
					if hero then
						hero:PlayHitEffect(g_i3k_game_context:getIsNeedLoading())
					end
				end
			end
		else
			if not g_i3k_game_context:getIsNeedLoading() then
			g_i3k_ui_mgr:OpenUI(eUIID_Loading);
			else
				local hero = i3k_game_get_player_hero()
				if hero then
					hero:PlayHitEffect(g_i3k_game_context:getIsNeedLoading())
				end
			end
		end
	end
	--g_i3k_game_handler:UpdatePathEngine(dTime);

	self:CalcLogicTick();
	if self._world then
		self._world:OnUpdate(dTime);
	end

	if self._player then
		self._player:OnUpdate(dTime);
	end
	
	local warnTaktTime = 1000;
	if self._checkTime > warnTaktTime then
		local warnEffect = g_i3k_game_context:GetWarnEffectCache()
		self._checkTime = 0;
		for k,v in pairs(warnEffect) do
			local WarnCacheTime = 2000;
			local logicTick = i3k_game_get_logic_tick();
			local warnTime = v.warnTime + WarnCacheTime;
			local duration = (logicTick - v.logicTick) * i3k_engine_get_tick_step();
			if duration > warnTime then
				v.manager:ReleaseSceneNode(v.warnID);
				g_i3k_game_context:ClearWarnEffectCache(v.warnID);
			end	
		end	
	end
	
	
	return true;
end

function i3k_base_logic:SetMapLoadedCB(func, args)
	self._globalMapCB = { func = func, args = args };
end

function i3k_base_logic:ResetMapLoadedCB()
	self._globalMapCB = nil;
end

function i3k_base_logic:OnLogic(dTick)
	--timer在调用i3k_engine_set_frame_interval_scale设置了速度之后，实际dtick应该把scale计算在内
	local realDTick = dTick/self._timerScale;
	for k, v in pairs(self._timers) do
		if v:OnLogic(realDTick) then
			if v:IsAutoRelease() then
				self._timers[k] = nil;
			end
		end
	end

	if self._world then
		self._world:OnLogic(dTick);
	end

	if self._player then
		self._player:OnLogic(dTick);
	end

	return true;
end

function i3k_base_logic:CalcLogicTick()
	self._deltaTick = self._tickLine % i3k_engine_get_tick_step();

	--[[
	local deltaTick = (i3k_integer(self._tickLine / i3k_engine_get_tick_step()) - self._logicTicks);
	self._logicTicks = self._logicTicks + deltaTick;
	self:OnLogic(deltaTick);
	]]

	while self._tickLine >= (self._logicTicks + 1) * i3k_engine_get_tick_step() do
		self._logicTicks = self._logicTicks + 1;

		self:OnLogic(1);
	end
end

function i3k_base_logic:CheckLoaded()
	return true;
end

-- event
function i3k_base_logic:OnKeyDown(handled, key)
	if self._world then
		self._world:OnKeyDown(handled, key);
	end

	if key == 13 or key == 78 then -- '+'
		local s = g_i3k_frame_interval_scale + 0.1;
		if s >= 10 then
			s = 10;
		end

		i3k_engine_set_frame_interval_scale(s);
	elseif key == 12 or key == 74 then -- '-'
		local s = g_i3k_frame_interval_scale - 0.1;
		if s <= 0.1 then
			s = 0.1;
		end

		i3k_engine_set_frame_interval_scale(s);
	end

	return 0;
end

function i3k_base_logic:OnKeyUp(handled, key)
	if key == 60 then -- F2
		Profile.Enable();
		Profile.DisableNativeProfile();
		Profile.Start();
	elseif key == 61 then -- F3
		Profile.Stop();
		Profile.DumpTo("profile.csv");
	end

	if self._world then
		self._world:OnKeyUp(handled, key);
	end

	return 0;
end

function i3k_base_logic:OnTouchDown(handled, x, y)
	return 0;
end

function i3k_base_logic:OnTouchUp(handled, x, y)
	if handled == 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateTargetNone")
		if self._selectEntity then
			self._selectEntity:OnSelected(false)
			if self._player then
				self._player:OnTouchUp()
			end
			self._selectEntity = nil
		end
	end

	return 0;
end

function i3k_base_logic:OnDrag(handled, touchDown, x, y)
	return 0;
end

function i3k_base_logic:OnZoom(handled, delta)
	return 0;
end

function i3k_base_logic:OnHitObject(handled, entities)
	local entity = entities[1];
	local hero = i3k_game_get_player_hero()
	local validDistTable = {
		[eET_NPC] 					= i3k_db_common.engine.npcValidDist,
		[eET_ResourcePoint] 		= i3k_db_common.digmine.DigMineDistance,
	}
	if hero then
		for k, v in ipairs(entities) do
			local dist = i3k_vec3_dist(hero._curPos, v._curPos);
			if validDistTable[v:GetEntityType()] and dist < validDistTable[v:GetEntityType()] then --
				entity = v;
				break;
			end
		end
	end
	
	if entity:GetEntityType() == eET_Player then
		local guid = string.split(entity._guid, "|")
		local entityId = tonumber(guid[2])
		for k, v in pairs(self._world._embracers) do
			local _guid = string.split(v._guid, "|")
			local playerId = tonumber(_guid[2])
			if playerId == entityId then
				entity = v._linkHugParent;
			end
		end
	end

	if self._world then
		self._world:OnHitObject(handled, entity);
	end
	self:SwitchSelectEntity(entity);

	return 1;
end

function i3k_base_logic:OnHitGround(handled, x, y, z)
	self:SwitchSelectEntity(nil);
	if self._world then
		self._world:OnHitGround(handled, x, y, z);
	end
	return 0;
end

function i3k_base_logic:SwitchSelectEntity(entity)
	local buffs = {}
	
	if self._selectEntity then
		if entity and self._selectEntity._guid == entity._guid then
			entity:OnSelected(true);
			
			return 0;
		end
		g_i3k_game_context:OnTargetBuffChangedHandler(buffs)
		self._selectEntity:OnSelected(false);
	end

	self._selectEntity = entity;
	if self._selectEntity then
		self._selectEntity:OnSelected(true);
	end
	
	local hero = i3k_game_get_player_hero()
	if hero then
		if hero._autonormalattack then
			hero._autonormalattack = false;
			hero._preautonormalattack = false;
		end
	end
	return 1;
end

function i3k_base_logic:GetSelectEntity()
	return self._selectEntity
end

function i3k_base_logic:OnLogin()
end

function i3k_base_logic:OnCharList()
end

function i3k_base_logic:OnRelogin()
	if self._player then
		self._player:Release();
		self._player = nil;
	end

	self:EnterNewWorld(nil);
end

function i3k_base_logic:OnClearRole()
	if self._player then
		self._player:Release();
		self._player = nil;
	end

	self:EnterNewWorld(nil);
end

function i3k_base_logic:SelectCharacter(idx)
	if idx > 0 then
		local roleInfo = g_i3k_game_context:GetRoleList();
		if roleInfo  then
			local char = roleInfo[idx];
			if char then
				i3k_do_role_login(char._id)
			end
		end
	end

	return false;
end

function i3k_base_logic:GetSelectCharacter()
	return self._selectCharacter or 0;
end

function i3k_base_logic:OnPlay()
	if self._mainCamera then
		self._mainCamera:LoadCfg(i3k_get_load_cfg():GetCameraInter());
	end

	local roleInfo = g_i3k_game_context:GetRoleInfo();

	if self._player then
		self._player:Release();
		self._player = nil;
	end

	self._guid = nil;

	local SPlayer = require("logic/battle/i3k_player");

	-- mt
	local player = SPlayer.i3k_player.new();
	if not player:Create() then
		player = nil;
	end

	if player then
		local SEntity = require("logic/entity/i3k_hero");

		local ch = roleInfo.curChar;
		if ch then
			self._guid = i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, ch._id);
			i3k_game_register_entity_RoleID(eET_Player.."|"..ch._id, self._guid);
			local hero = SEntity.i3k_hero.new(self._guid, true);
			if not hero:Create(ch._ctype, ch._name, ch._gender, ch._hair, ch._face, ch._level, roleInfo.skills.all, true, true, nil, ch._bwtype) then
				hero = nil;
				self._guid = nil;
			end
			g_i3k_game_handler:SetWindowTitle("rxjh[ " .. Engine.UTF82A(ch._name) .. " ]");

			if hero then
				--hero._soaringDisplay = ch._soaringDisplay
				if g_i3k_game_context then
					hero._soaringDisplay = {}
					hero._soaringDisplay.footEffect = g_i3k_game_context:getCurFootEffect()
					hero._soaringDisplay.skinDisplay = g_i3k_game_context:getCurWearShowType()
					hero._soaringDisplay.weaponDisplay = g_i3k_game_context:getCurWeaponShowType()
					if hero._soaringDisplay.footEffect ~= 0 then
						hero:changeFootEffect(g_i3k_game_context:getCurFootEffect())
					end
				end
				hero:BindSkills(roleInfo.skills.use);

				--hero:AttachCamera(self:GetMainCamera());
				hero:SetFaceDir(0, 0, 0);
				hero:SetGroupType(eGroupType_O);
				hero:SetHittable(false);
				hero:SetCtrlType(eCtrlType_Player);
				hero:Play(i3k_db_common.engine.defaultStandAction, -1);
				hero:AddAiComp(eAType_IDLE);
				hero:AddAiComp(eAType_MOVE);
				hero:AddAiComp(eAType_MANUAL_ATTACK);
				hero:AddAiComp(eAType_MANUAL_SKILL);
				hero:AddAiComp(eAType_FIND_TARGET);
				hero:AddAiComp(eAType_SPA);
				hero:AddAiComp(eAType_SHIFT);
				hero:AddAiComp(eAType_DEAD);
				hero:AddAiComp(eAType_DEAD_REVIVE);
				hero:AddAiComp(eAType_AUTOFIGHT_SKILL);
				--hero:AddAiComp(eAType_AUTOFIGHT_TRIGGER_SKILL);
				hero:AddAiComp(eAType_AUTOFIGHT_STUNT_SKILL);
				hero:AddAiComp(eAType_FEAR);
				--hero:AddAiComp(eAType_AUTOFIGHT_MERCENARY_SKILL);
				hero:AddAiComp(eAType_AUTOFIGHT_FIND_TARGET);
				hero:AddAiComp(eAType_AUTOFIGHT_CAST_FIND_TARGET);
				hero:AddAiComp(eAType_Blink);
				
				hero:AddAiComp(eAType_PRECOMMOND);
				hero:AddAiComp(eAType_AUTO_NORMALATTACK);
				hero:AddAiComp(eAType_AUTOFIGHT_RETURN);
				hero:AddAiComp(eAType_AUTOFIGHT_FIND_WAY);
				hero:AddAiComp(eAType_AUTOFIGHT_MISSION_SKILL);
				hero:AddAiComp(eAType_AUTO_SUPERMODE);--自动变身
				player:SetHero(hero);

				player:Show(false, true);
				player:OnUpdate(0);

				self._player = player;

				local equips = g_i3k_game_context:GetWearEquips();
				for k, v in pairs(equips) do
					if v and v.equip then
						hero:AttachEquip(v.equip.equip_id,true);
					end
				end
				local fashions = g_i3k_game_context:GetWearFashionData();
				local isshow = g_i3k_game_context:GetIsShwoFashion();
				if fashions[g_FashionType_Dress]  then
					hero:AttachFashion(fashions[g_FashionType_Dress], isshow, g_FashionType_Dress);
				end
				local isShowWeap = g_i3k_game_context:GetIsShowWeapon();
				if fashions[g_FashionType_Weapon] and not hero:isSpecial() then
					hero:AttachFashion(fashions[g_FashionType_Weapon], isShowWeap, g_FashionType_Weapon);
				end
				if not hero:isSpecial() then
					hero:changeWeaponShowType()
				end
				--[[local isShowWeap = g_i3k_game_context:GetIsShowWeapon();
				if fashions[g_FashionType_Weapon] and not hero:isSpecial() then
					hero:AttachFashion(fashions[g_FashionType_Weapon], isShowWeap, g_FashionType_Weapon);
				end
				if not isShowWeap and not hero:isSpecial() then
					local heirloom = g_i3k_game_context:getHeirloomData()
					if heirloom.isOpen == 1 and g_i3k_game_context:getCurWeaponShowType() == g_HEIRHOOM_SHOW_TYPE then
						local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID()];
						if scfg then
							hero:ReleaseFashion(hero._fashion, eEquipWeapon)
							if hero._equips[eEquipWeapon] then
								for k, v in ipairs(hero._equips[eEquipWeapon]._skin.skins) do
									hero._entity:DetachHosterSkin(v.name);
								end
							end 
							local name = string.format("hero_skin_%s_%d", hero._guid, 1);
							hero._entity:AttachHosterSkin(scfg.path, name, not hero._syncCreateRes);
							hero:AttachSkinEffect(eFashion_Weapon,scfg.effectID)
						end
					end
				end--]]
				
				local armorId, armorData, talent, rune ,hideEffect= g_i3k_game_context:getUnderWearData()
				if armorId~=0 then
					hero:AttachArmor(armorId, armorData[armorId].level, armorData[armorId].rank, i3k_clone(armorData[armorId].soltGroupData), i3k_clone(armorData[armorId].talentPoint),hideEffect)
				end
				hero:UpdateEquipProps();
				hero:UpdateRewardProps();
				hero:UpdateArmorProps();
				if roleInfo.buffs then
					for k, v in ipairs(roleInfo.buffs) do
						BUFF = require("logic/battle/i3k_buff");
						local bcfg = i3k_db_buff[v.id];
						local buff = BUFF.i3k_buff.new(nil, v.id, bcfg);
						if buff then
							hero:AddBuff(nil, buff);
						end
					end
				end
			
				if g_i3k_game_context and g_i3k_game_context._shenBing.use then
					hero:UseWeapon(g_i3k_game_context._shenBing.use);
				end
				
				if g_i3k_game_context and g_i3k_game_context:getUseSteed() ~= 0 then
					hero:UseRide(g_i3k_game_context:getUseSteed());
					hero:setRideCurShowID(g_i3k_game_context:getSteedCurShowID())
				end

				if g_i3k_game_context and g_i3k_game_context:getCurrentSkillID()~= 0 then
					local kfcfg = g_i3k_game_context:getCreateKungfuData()
					hero:LoadDIYSkill(g_i3k_game_context:getCurrentSkillID(),kfcfg)
				end

				hero:OnBuffChanged(hero);
				hero:AttachEquipEffect();
				if g_i3k_game_context then
					if g_i3k_game_context:getCurWeaponShowType() == g_FLYING_SHOW_TYPE then
						hero:ClearEquipEffect()
					end
				end
				if g_i3k_game_context then
					g_i3k_game_context:setShenBingUniqueTrigger()
				end
				if self._world then
					self._world:OnPlayerEnterWorld(self._player);
				end
				if hero:isSpecial() then
					hero:SpringSpecialShow();
				end
				if ch._level >= i3k_db_martial_soul_cfg.openLvl then
					hero:AttachWeaponSoul()
				end
				if g_i3k_game_context then
					hero:SetCombatType(g_i3k_game_context:GetCombatType())
				end
			end
		end
	end

	self:ResetMapLoadedCB();
end

function i3k_base_logic:LoadMap(mapName, pos, cfg, loadedCB, delay)
	g_i3k_game_handler:EnableObjHitTest(false, false);

	self._enterMapTime = 0;

	if self._curMap ~= mapName then
		if self._player then
			local hero = self._player:GetHero();
			if hero then
				hero:ReleaseAgent();
			end
		end

		self:UnloadMap();

		--[[
		local XML = require("i3k_xml");

		local parser = XML.i3k_xml_parser.new();

		local ncfg = parser:Load("scene/map/" .. mapName .. "/navigation.cfg");
		if not ncfg then
			i3k_log("use defualt navigation param.");

			g_i3k_mmengine:InitPathEngine();
		else
			local cellSize = tonumber(ncfg.cellSize._value);
			local tileSize = tonumber(ncfg.tileSize._value);

			i3k_log("use custom navigation param. tileSize = " .. tileSize .. ", cellSize = " .. cellSize);

			g_i3k_mmengine:InitPathEngine(tileSize, cellSize);
		end
		]]

		self._curMap		= mapName;
		self._isLoadingMap 	= true;
		self._isLoadHandled	= false;
		self._loadingTick	= 0;
		self._loadingTime	= 0;
		self._loadingDelay	= delay or 0;
		self._loadedCB 		= loadedCB;

		if g_i3k_game_context then
			g_i3k_game_context:SetMapEnter(false);
		end
		g_i3k_mmengine:LoadMap(mapName, EFS_NATIVE, pos, cfg);
	else
		self._isLoadingMap 	= true;
		self._isLoadHandled	= false;
		self._loadedCB 		= loadedCB;
		if not g_i3k_game_context:getIsNeedLoading() then
		g_i3k_ui_mgr:OpenUI(eUIID_Loading);
		else
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:PlayHitEffect(g_i3k_game_context:getIsNeedLoading())
			end
		end
		if g_i3k_game_context then
			g_i3k_game_context:SetMapEnter(false);
		end

		local cfg = g_i3k_game_context:GetUserCfg()
		g_i3k_game_handler:EnableObjHitTest(true, cfg:GetIsTouchOperate());
		
		--[[
		if loadedCB then
			loadedCB();
		end
		]]
	end
end

function i3k_base_logic:UnloadMap()
	self._curMap = "";

	g_i3k_mmengine:UnloadMap();
end

function i3k_base_logic:GetMainCamera()
	return self._mainCamera;
end

function i3k_base_logic:GetPlayer()
	return self._player;
end

function i3k_base_logic:NewDungeon(id)
	if id == self._lastdungeonID then
		self._dungeonID = id;
		self._lastdungeonID = -1;
	else
		self._lastdungeonID = self._dungeonID;
		self._dungeonID = id;
	end	

	return true;
end

function i3k_base_logic:GetDungeonID()
	return self._dungeonID;
end

function i3k_base_logic:GetLastDungeonID()
	return self._lastdungeonID;
end

function i3k_base_logic:EnterNewWorld(world)
	if self._world then
		self._world:Release();
	end

	self._world = world;
	if self._world then
		self._world:OnPlayerEnterWorld(self._player);
	end
end

function i3k_base_logic:GetWorld()
	return self._world;
end

function i3k_base_logic:GetConfigure()
	return self._configure;
end

function i3k_base_logic:GetDeltaTime()
	return self._deltaTime;
end

function i3k_base_logic:GetLogicTick()
	return self._logicTicks;
end

function i3k_base_logic:SetLogicTick(ticks)
	self._logicTicks = ticks;
end

function i3k_base_logic:GetTickTime()
	return self._tickTime;
end

function i3k_base_logic:GetTickLine()
	return self._tickLine;
end

function i3k_base_logic:SetTickLine(tickLine)
	self._tickLine		= tickLine;
	self._tickTime		= tickLine / 1000;
	self._deltaTick		= tickLine % i3k_engine_get_tick_step();

	--[[
	while self._tickLine >= (self._logicTicks + 1) * i3k_engine_get_tick_step() do
		self._logicTicks = self._logicTicks + 1;

		self:OnLogic(1);
	end
	]]

	self._logicTicks	= i3k_integer(self._tickLine / i3k_engine_get_tick_step());
	self._dirtyTickLine = true;
end

function i3k_base_logic:GetDeltaTick()
	return self._deltaTick;
end

function i3k_base_logic:SetDeltaTick(tick)
	self._deltaTick = tick;
end

local gTimerID = 0;
local function GenTimerID()
	local id = gTimerID;
	gTimerID = (gTimerID + 1) % 99999;

	return id;
end

function i3k_base_logic:RegisterTimer(timer)
	local id = GenTimerID();

	self._timers[id] = timer;

	return id;
end

function i3k_base_logic:UnregisterTimer(id)
	self._timers[id] = nil;
end

function i3k_base_logic:SetTimerScale(scale)
	self._timerScale = scale;
end

function i3k_base_logic:FilterNetPacket(packet)
	return false;
end

