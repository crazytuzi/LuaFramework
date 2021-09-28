------------------------------------------------------
--module(..., package.seeall)

local require = require

require("i3k_global");
require("i3k_text_pool");
require("logic/entity/i3k_entity_def");


------------------------------------------------------
i3k_entity = i3k_class("i3k_entity");
function i3k_entity:ctor(guid)
	local TRI = require("logic/entity/ai/i3k_trigger");

	self._id			= -1;
	self._isCreated		= false;
	self._syncRpc		= false;
	self._groupType		= eGroupType_N;
	self._ctrlType		= eCtrlType_AI;
	self._renderable	= true;
	self._syncCreateRes = false;
	self._faceDir		= i3k_vec3(0, 0, 0);
	self._orientation	= i3k_vec3(0, 0, 0);
	self._movable		= false;
	self._cacheable		= false;
	self._actionPause	= 0;
	self._actionName	= nil;
	self._actionLst		= nil;
	self._actionChanged	= false;
	self._actionLoops	= -999;
	self._aiController	= nil;
	self._camera		= nil;
	self._curPos		= Engine.SVector3(0, 0, 0);
	self._curPosE		= Engine.SVector3(0, 0, 0);
	self._velocity		= nil;
	self._targetPos		= nil;
	self._fearPos		= nil;
	self._movePaths		= { };
	self._follow		= nil;
	self._moveChanged	= false;
	self._forceMove		= false;
	self._turnMode		= false;
	self._updateAlives	= true;
	self._updateAliveTick
						= 0;
	self._lastUpdateAliveTick
						= 0;
	self._properties	= { };
	self._passives		= { };
	self._pasResetStack	= 0;
	self._behavior		= i3k_entity_behavior.new(self);
	self._text_pool		= i3k_text_effect_pool.new();
	self._lockAni		= false;
	self._destory		= false;
	self._radius		= 75;
	self._selected		= false;
	self._spawnID		= 0;
	self._entityType	= eET_Unknown;
	self._height		= 2.5;
	self._guid			= guid;
	self._name			= "";
	self._triMgr		= TRI.i3k_ai_trigger_mgr_create(self);
	self._resCreated	= 1;
	self._TitleColor	= { tonumber("0xffffffff", 16), tonumber("0xffffa500", 16), tonumber("0xfffc8da1", 16), tonumber("0xffff6666", 16), tonumber("0xffff0000", 16), tonumber("0xff990033", 16), tonumber("0xff660000", 16) };
	self._isShow		= false;
	self._selEffScale	= 1.0;
	self._titleInfo		= { name = false, blood = false, buff = false, vis = false};
	self._cacheClearTime
						= 0;
	self._inLeaveCache	= false;
	self._inWorld		= false;
	self._moveInfo		= { ticks = 0, speed = 0, dirs = { }, paths = { } };
	self._titleshow		= true;
	self._carState		= 0;
	self._sectID		= 0;
	self._teamID		= 0;
	self._is_actor		= false;
	self._hitEffectIDs  = {}
	self._linkChilds = {} --存储乘客entity
	self._replaceAct = nil
	self._allPorpReduceValue = 0
	self._WeaponBlessAllPorpReduceValue = 0
	self._canClickData = {canClickCount = 0, clickTime = 0, haveClickCount = 0}
	self._firstCreate = nil --第一次创建
	self._petDungeonInfo = nil --宠物试炼变身信息
	self._desertInfo = {modleId = 0, scroe = 0} --决战荒漠信息
	self._spyInfo = {camp = 1, modleId = 1}		-- 密探风云信息
	self._findPathData = {endPos = nil, callBack = nil, releaseCo = nil, entityFlag = true, aiFlag = true, runFlag = false, fadeDistance = 0, checkFlag = true} --寻路相关
	self._isInDungeonModel = nil --是否是副本特殊模型
end

function i3k_entity:CreateActor()
	if not self._is_actor then
		self._is_actor = true;

		self._entity = Engine.MEntity(self._guid);
		self._entity:Create();

		i3k_game_register_entity(self._guid, self);
	end
end

function i3k_entity:Create(id, name)
	self._id	= id;
	self._name	= name;

	self._properties = self:InitProperties();

	local aiMgr = require("logic/entity/ai/i3k_ai_mgr");
	if not aiMgr then
		return false;
	end
	self._aiController = aiMgr.create_mgr(self);

	if self._entity then
		self._entity:SyncScenePos(self:IsPlayer());
	end
	if self:IsPlayer() then
		self._isCreated		= true;
	end
	return true;
end

function i3k_entity:IsCreated()
	return self._isCreated
end

function i3k_entity:IsCheckModelByPackId(modelID)
	local isCheck = false;
	if self:GetEntityType() == eET_NPC or self:GetEntityType() == eET_Monster or self:GetEntityType() == eET_Mercenary or self:GetEntityType() == eET_ResourcePoint then
		isCheck = true;
	end
	if isCheck then
		return i3k_engine_check_is_use_stock_model(modelID)
	end
	return modelID;
end

function i3k_entity:CreateRes(modelID)
	if g_i3k_download_mode then--是否是分包
		modelID = self:IsCheckModelByPackId(modelID)
	end
	modelID = self:GetCreateModelId(modelID)
	if self._syncCreateRes then
		i3k_warn("use sync create")
		self:CreateResSync(modelID)
		return
	end
	local mcfg = i3k_db_models[modelID];
	if mcfg and self._entity then
		self._rescfg = mcfg;
		self._entity:AsyncCreateHosterModel(mcfg.path, string.format("entity_%s", self._guid));
		if self._inSprog then
			self._entity:EnterWorld(true);
		else
			self._entity:EnterWorld(false);
		end
		self._entity:SetActionBlendTime(0);

		if i3k_game_get_map_type() == g_HOMELAND_HOUSE then
			self._entity:SetViewDistance(i3k_db_common.cameraClip.FilterRadius)
		else
			if self:GetEntityType() ~= eET_Monster then				
				self._entity:SetViewDistance(i3k_db_common.filter.FilterRadius / 100);
			else
				self._entity:SetViewDistance(i3k_db_common.filter.FilterMonsterRadius / 100);
			end
		end
			
		self._height		= mcfg.titleOffset;
		self._selEffScale	= mcfg.selEffScale;
		self._baseScale		= mcfg.scale;
		self:SetScale(mcfg.scale);
		self:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
	end
end

function i3k_entity:GetCreateModelId(modelID)
	local mapType = i3k_game_get_map_type()
	local isCombat = i3k_get_is_combat()
	local isPlayer = self:GetEntityType() == eET_Player and not self:IsPlayer()
	self._isInDungeonModel = nil
	if not isCombat then
		if (mapType == g_FACTION_WAR or mapType == g_FORCE_WAR or mapType == g_DEMON_HOLE or mapType == g_DEFENCE_WAR or mapType == g_MAZE_BATTLE) and isPlayer then
			local showType = self._bwType
			if mapType == g_FORCE_WAR or mapType == g_FACTION_WAR or mapType == g_DEFENCE_WAR then
				showType = self._forceType
			end
			modelID = g_i3k_db.i3k_db_get_unify_model_id(self._id, self._gender, showType)
			self._isInDungeonModel = true
		elseif mapType == g_PET_ACTIVITY_DUNGEON and isPlayer then
			if self._petDungeonInfo then
				local awakeUse = self._petDungeonInfo.awakeUse
				
				if awakeUse and awakeUse.use and awakeUse.use == 1 then
					modelID = i3k_db_mercenariea_waken_property[self._petDungeonInfo.id].modelID;
					self._isInDungeonModel = true
				else
					modelID = i3k_db_mercenaries[self._petDungeonInfo.id].modelID
					self._isInDungeonModel = true
				end			
			end
		elseif mapType == g_DESERT_BATTLE and isPlayer then
			if self._desertInfo then
				local cfg = i3k_db_desert_generals[self._desertInfo.modleId]
				
				if cfg then
					modelID = cfg.modelID
					self._isInDungeonModel = true
				end			
			end
		elseif mapType == g_SPY_STORY and isPlayer then
			if self._spyInfo then
				local cfg = i3k_db_spy_story_generals[self._spyInfo.camp][self._spyInfo.modelID]
				if cfg then
					modelID = g_i3k_db.i3k_db_get_spy_story_modelID(self._gender, cfg) 
					self._isInDungeonModel = true
				end			
			end
		end
	end
	return modelID
end

function i3k_entity:IsResCreated()
	return self._resCreated == 0;
end

function i3k_entity:SetTitleVisiable(vis)
end

function i3k_entity:SetViewDistance(radius)
	self._entity:SetViewDistance(radius/100)
end

function i3k_entity:Cacheable()
	return self._cacheable;
end

function i3k_entity:CreateResSync(modelID)
	local mcfg = i3k_db_models[modelID];
	if mcfg and self._entity then
		self._rescfg = mcfg;

		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._resCreated	= self._resCreated - 1;
			self._height		= mcfg.titleOffset;
			self._selEffScale	= mcfg.selEffScale;
			--i3k_log("CreateResSync:"..self._guid)
			self._title = self:CreateTitle();
			if self._title.node then
				self._title.node:SetVisible(true);
				self._title.node:EnterWorld();

				self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
			end

			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			if self:GetTitleShow() ~= nil then
				self:SetTitleVisiable(self:GetTitleShow())
			end
			
			if i3k_game_get_map_type() == g_HOMELAND_HOUSE then
				self._entity:SetViewDistance(i3k_db_common.cameraClip.FilterRadius)
			else
				if self:GetEntityType() ~= eET_Monster then				
					self._entity:SetViewDistance(i3k_db_common.filter.FilterRadius / 100);
				else
					self._entity:SetViewDistance(i3k_db_common.filter.FilterMonsterRadius / 100);
				end
			end

			self._entity:EnterWorld(false);
			if self:IsPlayer() then
				--self:SetColor(i3k_db_common.login.role.entityColor)
			end
		end
	end
end

function i3k_entity:OnAsyncLoaded()
	if self._entity then
		self._resCreated = self._resCreated - 1;

		if self:GetEntityType() ~= eET_Ghost then
			self._title = self:CreateTitle();
			if self._title and self._title.node then
				self._title.node:SetVisible(true);
				self._title.node:EnterWorld();
				if self._rescfg then
					self._entity:AddTitleNode(self._title.node:GetTitle(), self._rescfg.titleOffset);
				else
					self._entity:AddTitleNode(self._title.node:GetTitle(), 0);
				end
			end
			if not self._behavior:Test(eEBInvisible) then
				self:Show(self._isShow, true);
				self:ShowTitleNode(self._titleInfo.vis);
			end
			self:SetFaceDir(self._faceDir.x, self._faceDir.y, self._faceDir.z);
			self:EnableRender(self._renderable);
			if self:GetTitleShow() ~= nil then
				self:SetTitleVisiable(self:GetTitleShow())
			end
			if self._behavior:Test(eEBInvisible) then
				self:Show(false, true);
			end
		end
		if self:GetEntityType() == eET_Monster and not i3k_game_get_world()._syncRpc then
			self:AddSpecialEffect()
		end
		self:PlayAction();
		self:SetColor(g_i3k_db.i3k_db_get_map_entity_color())
		--[[
		if self:IsResCreated() then
			if self._actionName then
				if self._rescfg then
					if self._rescfg.ignoreBlend[self._actionName] then
						self._entity:SetActionBlendTime(0);
					else
						self._entity:SetActionBlendTime(0.2);
					end
				else
					self._entity:SetActionBlendTime(0.2);
				end
				self._entity:SelectAction(self._actionName, self._actionLoops);
			elseif self._actionLst then
				self._entity:SelectActionList(self._actionLst);
			end
			self._entity:Play();
		end
		]]
		if self._cfg and self._cfg.actionList and self._firstCreate then			
			local alist = {}
			local nums = #self._cfg.actionList
			for k, v in ipairs(self._cfg.actionList) do
				local times = k < nums and 1 or -1
				table.insert(alist, {actionName = v, actloopTimes = times})
			end
			if self._cfg.actionLiftTime then
				self._titleCo = g_i3k_coroutine_mgr:StartCoroutine(function()
					self:ShowTitleNode(false);
					g_i3k_coroutine_mgr.WaitForSeconds(self._cfg.actionLiftTime/1000)
					self:ShowTitleNode(true);
					g_i3k_coroutine_mgr:StopCoroutine(self._titleCo)
					self._titleCo = nil
				end)
			end
			self:PlayActionList(alist, 1);
			self._firstCreate = nil

		end
		self:TitleColorTest();
	end
end

function i3k_entity:PlayHugAction(entity, anim, standAction)
	local alist = {}
	table.insert(alist, {actionName = anim, actloopTimes = 1})
	table.insert(alist, {actionName = standAction, actloopTimes = -1})
	entity:PlayActionList(alist, 1);
end

function i3k_entity:PlayAction()
	if self._actionName then
		self:Play(self._actionName, self._actionLoops, true);
	elseif self._actionLst then
		self:PlayActionList(self._actionLst, self._actionLoops, true, true);
	end
end

function i3k_entity:OnAsyncModelChanged()
	--i3k_log("OnAsyncModelChanged:"..self._guid)
end

function i3k_entity:GetTitleShow()
	return self._titleshow
end

function i3k_entity:SetTitleShow(vis)
	self._titleshow = vis
end

function i3k_entity:CreateTitle(reset)
	local _T = require("logic/entity/i3k_entity_title");
	if reset then
		if self._title and self._title.node then
			self._title.node:Release();
			self._title.node = nil;
		end
		self._title = nil;
	end
	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("entity_title_node_" .. self._guid) then
		if self._name ~= "" then
			title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, tonumber("0xffffffff", 16), self._name);
		end
	else
		title.node = nil;
	end

	return title;
end

function i3k_entity:GetTitleOffset()
	if self:IsResCreated() and self:GetEntityType() == eET_Player and self:IsOnRide() then
		if self._ride and self._ride.deform.args then
			local mcfg = i3k_db_models[self._ride.deform.args]
			return mcfg.titleOffset
		end
	end
    
	if self._rescfg then
		return self._rescfg.titleOffset;
	end

	return 1.5;
end

function i3k_entity:ChangeTitleOffset(offset)
	if self:IsResCreated() and self._entity and self._title and self._title.node then
		self._entity:AddTitleNode(self._title.node:GetTitle(), offset);
	end
end

function i3k_entity:SetVehicleInfo(path, hs, cs)
	self._vehicle = { path = path, hs = hs, cs = cs };
end

function i3k_entity:Mount()
	if self._vehicle then
		if self._entity:CreateVehicle(self._vehicle.path, "entity.vehicle." .. self._guid, self._vehicle.hs, self._vehicle.cs) then
			local world = i3k_game_get_world()
			if world then
				world:UpdateIsShowPlayerSate(true)
			end
			if self._actionName and self._actionLoops then
				self:Play(self._actionName,self._actionLoops)
			end

			if self:IsPlayer() then
				self:EnableOccluder(true);
			end
			self:SetColor(g_i3k_db.i3k_db_get_map_entity_color())

			return true;
		end
	end

	return false;
end

function i3k_entity:Unmount()
	self._entity:ReleaseVehicle();
	if self._actionName and self._actionLoops then
		if g_i3k_game_context:GetIsSpringWorld() then
			self:PlaySpringIdleAct()
		else
			if self._actionName == "stand01" then
				self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
			else
				self:Play(self._actionName,self._actionLoops)
			end
		end
	end
end

function i3k_entity:CarryItem(cfgID)
	local cfg = i3k_db_models[cfgID];
	if cfg and self._entity then
		self._carryItem = self._entity:LinkHosterChild(cfg.path, string.format("entity_carryitem_%s_item_%d", self._guid, cfgID), self._missionMode.mcfg.RoleLinkPoint, self._missionMode.mcfg.ItemLinkPoint, 0.0, cfg.scale);
		if self._carryItem > 0 then
			self:SetLinkChildColor(self._carryItem, g_i3k_db.i3k_db_get_map_entity_color())
		end

		if not self:IsPlayer() then
			local world = i3k_game_get_world()
			if world:IsShowPlayer(self) then
				self:ShowCarryItem(true)
			else
				self:ShowCarryItem(false)
			end
		end
	end
	self:PlayAction();

	return false;
end

function i3k_entity:ShowCarryItem(s)
	if self._entity and self._carryItem and self._carryItem > 0 then
		self._entity:LinkChildShow(self._carryItem, s)
	end
end

function i3k_entity:UnCarryItem()
	if self._carryItem and self._carryItem > 0 then
		self._entity:RmvHosterChild(self._carryItem);
	end
	self._carryItem = nil;

	self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1); --任务变身结束播放默认站立动作
end

-- 钓鱼动作，挂载spr，主角和鱼竿播放不同的动作
function i3k_entity:LinkFishItem(cfgID, roleID)
	local fishActCfg = i3k_db_home_land_base.fishActCfg
	self:LinkItem(cfgID, roleID, fishActCfg.roleLinkPoint, fishActCfg.itemLinkPoint, i3k_db_home_land_base.fishActCfg.actStand)
end
function i3k_entity:LinkPetGuardItem(petGuardId)
	local hosterLink = i3k_db_pet_guard_base_cfg.sprLink
	local cfg = i3k_db_pet_guard[petGuardId]
	local petId = self._id
	local modelCfg = i3k_db_models[cfg.modleId]
	local isAwake = self._awaken == 1
	local scale = (isAwake and i3k_db_mercenariea_waken_property or i3k_db_mercenaries)[petId].petGuardScale * modelCfg.scale
	local Y = (isAwake and i3k_db_mercenariea_waken_property or i3k_db_mercenaries)[petId].petGuardY
	self:LinkItem(cfg.modleId, self._guid, hosterLink, hosterLink, "stand", Y, scale / 10000)
end
function i3k_entity:LinkItem(cfgID, guid, roleLinkPoint, itemLinkPoint, defaultAction, offsetY, scale)
	local world = i3k_game_get_world()
	if world then
		if not self._linkItem then
			local mountEntity = require("logic/entity/i3k_entity_mount")
			local Guid = world:CreateOnlyGuid(cfgID, eET_Mount, guid);
			local mount = mountEntity.i3k_entity_mount.new(Guid)
			mount:SetSyncCreateRes(true)
			mount:createMount(cfgID)
			local r = i3k_vec3_angle2(i3k_vec3(1, 1, 0), i3k_vec3(1, 0, 0))
			mount:SetFaceDir(0, r, 0)
			mount:Show(true, true)
			mount:SetHittable(false)
			mount:SetPos(self._curPos)
			self:AddLinkItem(mount, roleLinkPoint, itemLinkPoint, defaultAction, offsetY, scale)
		end
	end
end

function i3k_entity:Destory()
	self._destory = true;
end

function i3k_entity:IsDestory()
	return self._destory;
end

function i3k_entity:Release()
	if self._is_actor then
		self._is_actor = false;

		i3k_game_register_entity(self._guid, nil);

		if self._title and self._title.node then
			self._title.node:Release();
			self._title.node = nil;
		end
		self._title = nil;

		if self._entity then
			self._entity:Release();
			self._entity = nil;
		end
		self:ReleaseAgent();

		self._text_pool:Clear();

		self:ResetLeaveCache();
		local world = i3k_game_get_world()
		if world and table.nums(world._specialMonsters) > 0 then
			if world._specialMonsters[self._guid] then
				world._specialMonsters[self._guid] = nil;
			end
		end

		if self._linkItem then
			self._linkItem:Release()
		end
	end

	self._resCreated = 1;
end

function i3k_entity:CanRelease()
	return true;
end

function i3k_entity:IsPlayer()
	return false;
end

function i3k_entity:IsSyncEntity()
	return false;
end

function i3k_entity:UpdateBloodBar(percent)
	if self._title and self._title.node and self._title.bbar then
		self._title.node:UpdateBloodBar(self._title.bbar, percent);
	end
end

function i3k_entity:NeedUpdateAlives(enable)
	self._updateAlives = enable;
end

function i3k_entity:IsNeedUpdateAlives()
	return self._updateAlives;
end

function i3k_entity:OnEnterWorld()
	self._inWorld = true;
end

function i3k_entity:OnLeaveWorld()
	self._inWorld = false;
	if self:IsPlayer() then
		self._behavior:ClearAll();
		self:ClearMoveState();
	end
	self:StopMove(true);
end

function i3k_entity:IsInWorld()
	return self._inWorld;
end

function i3k_entity:SyncRpc(enable)
	self._syncRpc = enable;
end

function i3k_entity:IsNeedSyncRpc()
	return self._syncRpc;
end

-- 更新引擎相关
function i3k_entity:OnUpdate(dTime)
	if self._turnMode then
		self._turnTick = self._turnTick + dTime;
		if self._turnTick <= (self._turnTime or 1) then
			local d = self._turnTick / (self._turnTime or 1);

			local f = i3k_vec3_lerp(self._turnOriDir, self._turnDir, d);

			self:SetFaceDir(f.x, f.y, f.z);
		else
			self._turnMode = false;

			self:SetFaceDir(self._turnDir.x, self._turnDir.y, self._turnDir.z);
		end
	end

	if self._triMgr then
		self._triMgr:OnUpdate(dTime);
	end

	if self._aiController then
		self._aiController:OnUpdate(dTime);
	end

	self._text_pool:OnUpdate(dTime);

	return true;
end

function i3k_entity:OnEndUpdate(tick, tickline)
end

function i3k_entity:SetBloodBarVisiable(vis)
	if self._title and self._title.node and self._title.bbar then
		--if vis then
		--	i3k_log("SetBloodBarVisiable:true")
		--else
		--	i3k_log("SetBloodBarVisiable:false")
		--end
		self._title.node:SetElementVisiable(self._title.bbar,vis)
	end
end

function i3k_entity:SetTypeNameVisiable(vis)
	if self._title and self._title.node and self._title.typeName then

		self._title.node:SetElementVisiable(self._title.typeName, vis)
	end
end

-- 更新逻辑相关
function i3k_entity:OnLogic(dTick)
	--[[
	if self._agent then
		self._agent:Update((dTick * i3k_engine_get_tick_step()) / 1000);
	end
	]]

	if self._triMgr then
		self._triMgr:OnLogic(dTick);
	end

	if self._aiController then
		local loops = 1;

		local preAI = nil;
		local first = true;
		while true do
			self._aiController:SwitchComp();
			if preAI == self._aiController:GetActiveComp() then
				break;
			end
			preAI = self._aiController:GetActiveComp();

			local ticks = 0;
			if first then
				first = false;
				ticks = dTick;
			end

			if not self:IsInWorld() or self._aiController:OnLogic(ticks) then
				break;
			end

			loops = loops + 1;
			if loops > 5 then -- TODO
				i3k_global_log_info("ai:SwitchComp:" .. self._guid .. " ai = " .. preAI:GetName());

				break;
			end
		end
	end

	return true;
end

function i3k_entity:ResetLeaveCache()
	self._inLeaveCache = false;
	self._cacheClearTime = 0;
end

function i3k_entity:GetLeaveCacheTime()
	return self._cacheClearTime;
end

function i3k_entity:IsInLeaveCache()
	return self._inLeaveCache;
end

function i3k_entity:EnterLeaveCache()
	if not self._inLeaveCache then
		self._inLeaveCache = true;
		self._cacheClearTime = 0;
	end
end

function i3k_entity:UpdateCacheTime(dTick)
	if self._inLeaveCache then
		self._cacheClearTime = self._cacheClearTime + dTick * i3k_engine_get_tick_step();
	end
end

function i3k_entity:SetHittable(val)
	if self._entity then
		self._entity:EnableHittable(val);
	end
end

function i3k_entity:ShowInfo(attacker, style, info, dur, sourceType)
	if not i3k_game_get_scene_ani_is_playing() then
		if info ~= '' then
			local _d = dur or i3k_db_common.engine.durNumberEffect[1] / 1000;

			local pos = Engine.SVector3();
				pos.x = self._curPosE.x;
				pos.y = self._curPosE.y + self._height;
				pos.z = self._curPosE.z;

			local entity = attacker or self;
			if not sourceType then
				sourceType = entity:GetEntityType()
				if sourceType == eET_Skill then
					local entity = entity:GetHoster();
					if entity then
						sourceType = entity:GetEntityType()
					end
				end
			end

			if sourceType == eET_Player then
				self._text_pool:AllocEffect(style[1], pos, info, _d);
			elseif sourceType == eET_Monster then
				self._text_pool:AllocEffect(style[2], pos, info, _d);
			elseif sourceType == eET_Pet or sourceType == eET_Mercenary or sourceType == eET_Summoned then
				self._text_pool:AllocEffect(style[3], pos, info, _d);
			elseif sourceType == eET_Trap  then
				self._text_pool:AllocEffect(style[4], pos, info, _d);
			elseif sourceType == eET_Skill  then
				self._text_pool:AllocEffect(style[1], pos, info, _d);
			end
		end
	end
end

function i3k_entity:LockAni(val)
	if self._lockAni and not val then
		if self._actionChanged then
			if self._entity then
				-- i3k_log("LockAni1:"..self._actionName)
				if self._actionName then
					--[[
					if self._rescfg then
						if self._rescfg.ignoreBlend[self._actionName] then
							self._entity:SetActionBlendTime(0);
						else
							self._entity:SetActionBlendTime(0.2);
						end
					else
						self._entity:SetActionBlendTime(0.2);
					end
					]]

					if self:IsResCreated() then
						-- i3k_log("LockAni3:"..self._actionName)
						self._entity:SelectAction(self._actionName, self._actionLoops);
					end

					if self._entity:HaveVehicle() then
						if self:IsResCreated() then
							local hAction = self:getMountAction(self._actionName, 1)
							if hAction then
								self._entity:SelectMountAction(hAction, self._actionLoops);
							end
						end
					end

				else
					if self:IsResCreated() then
						self._entity:SelectActionList(self._actionLst);
					end
				end

				if self:IsResCreated() then
					-- i3k_log("LockAni2:"..self._actionName)
					self._entity:Play();
				end
			end
		end
	end

	self._lockAni = val;
end

function i3k_entity:ReplaceActName(old_name, new_name)
	if not self._replaceAct then
		self._replaceAct = { };
	end
	self._replaceAct[old_name] = new_name;
end

function i3k_entity:ResetActName(old_name)
	if self._replaceAct then
		self._replaceAct[old_name] = nil;
	end
end

function i3k_entity:ReplacePlayerRunAct(actionName)
	if self:GetEntityType() == eET_Player and actionName == i3k_db_common.engine.defaultRunAction and not self:IsOnRide() then
		local world = i3k_game_get_world();
		if world and world._cfg then
			local mcfg = i3k_db_combat_maps[world._cfg.mapID];
			if mcfg.specialAction ~= "" then
				return mcfg.specialAction
			end
		end
	end
	return actionName
end

function i3k_entity:getMountAction(actionName, index)
	local showID = self._ride.curShowID
	if showID then
		local showCfg = i3k_db_steed_huanhua[showID]
		index = index or 1
		if actionName == "run" then
			return showCfg.mulRoleRunAction[index] or "zq_run"
		elseif actionName == "walk" then
			return showCfg.mulRoleWalkAction[index] or "zq_walk"
		elseif actionName == "stand" or actionName == "attackstand" or actionName == "stand01" then
			return showCfg.mulRoleStandAction[index] or "zq_stand"
		end
	else
		local mountActionMap =
		{
			["run"]				= "zq_run",
			["walk"]			= "zq_walk",
			["stand"]			= "zq_stand",
			["attackstand"]		= "zq_stand",
			["stand01"]			= "zq_stand",
		};
		return mountActionMap[actionName]
	end
end

function i3k_entity:onMissionModeAction(actName)
	if self._missionMode and self._missionMode.valid and self._missionMode.type == 4 then
		local roleStandAction = self._missionMode.mcfg.convoyStandAction
		local roleRunAction = self._missionMode.mcfg.convoyRunAction
		local itemStandAction = self._missionMode.mcfg.ItemStandAction
		local itemRunAction = self._missionMode.mcfg.ItemRunAction
		local carryActionMap = {
			["run"]				= roleRunAction,
			["husong"]			= roleRunAction,
			["husongstand"]		= roleRunAction,
			[roleRunAction]		= roleRunAction,
			["stand"]			= roleStandAction,
			["attackstand"]		= roleStandAction,
			["stand01"]			= roleStandAction,
			[roleStandAction] 	= roleStandAction,
		}
		local itemActionMap = {
			["run"]				= itemRunAction,
			["husong"]			= itemRunAction,
			["husongstand"]		= itemRunAction,
			[roleRunAction]		= itemRunAction,
			["stand"]			= itemStandAction,
			["attackstand"]		= itemStandAction,
			["stand01"]			= itemStandAction,
			[roleStandAction] 	= itemStandAction,
		}
		if carryActionMap[actName] then
			if self._carryItem and self._carryItem > 0 and self._entity then
				self._entity:LinkChildSelectAction(self._carryItem, itemActionMap[actName])
				self._entity:LinkChildPlay(self._carryItem, -1, true);
			end
		end
		return carryActionMap[actName] and carryActionMap[actName] or actName
	end
	return actName
end

function i3k_entity:getFightFlgAction(actName)
	if self:GetEntityType() == eET_ResourcePoint and self._gcfg and self._gcfg.nType == 5 then --添加帮派夺旗战动作
		local flagActionMap = {
			["change01"]		= "change01",
			["stand"]			= "stand01",
			["stand01"]			= "stand01",	
		};
		return flagActionMap[actName] and flagActionMap[actName] or actName
	end
	return actName
end

function i3k_entity:getHugAction(actName)
	if self:GetEntityType() == eET_Player and self._hugMode.valid then
		local roleRunAction = "sj_baowalk"
		local roleStandAction = "sj_bao"
		local hugActionMap = {
			["run"]				= roleRunAction,
			["husong"]			= roleRunAction,
			["husongstand"]		= roleRunAction,
			[roleRunAction]		= roleRunAction,
			["stand"]			= roleStandAction,
			["attackstand"]		= roleStandAction,
			["stand01"]			= roleStandAction,
			[roleStandAction] 	= roleStandAction,
		}
		if self._linkHugChild then --TODO 播放被抱着时的动作
			--self._linkHugChild:Play()
		end
		if hugActionMap[actName] and self._hugMode.isLeader then
			return hugActionMap[actName]
		else
			return actName
		end
	end
	return actName
end

-- 家园装备特殊动作映射
function i3k_entity:getFishAction(actName)
	if self:GetEntityType() == eET_Player then
		if self:GetIsBeingHomeLandEquip() then
			local dbCfg = i3k_db_home_land_base.fishActCfg
			local dbCommon = i3k_db_common.engine
			local actionMap = {
				[dbCommon.defaultRunAction]			= dbCfg.itemRunAct,
				[dbCommon.defaultStandAction]		= dbCfg.itemStandAct,
				[dbCommon.defaultAttackIdleAction]	= dbCfg.itemStandAct,
				[dbCommon.roleWalkAction]			= dbCfg.itemWalkAct,
			}
			if actionMap[actName] then
				return actionMap[actName]
			end
		end
	end
	return actName
end

--拳师替换站姿
function i3k_entity:getQuanshiAction(actName)
	if self:GetEntityType() == eET_Player then
		if self:CanPlayCombatTypeAction() then
			local dbCommon = i3k_db_common.engine
			local dbGeneral = i3k_db_common.general
			local boxerActionList = 
			{
				[g_BOXER_NORMAL] = i3k_db_common.engine.defaultAttackIdleAction,
				[g_BOXER_ATTACK] = i3k_db_common.general.boxerAttackAction,
				[g_BOXER_DEFENCE] = i3k_db_common.general.boxerDefenceAction,
			};
			local combatType = self:GetCombatType()
			local actionMap = {
				[dbCommon.defaultAttackIdleAction]	= boxerActionList[combatType],
				[dbCommon.defaultStandAction] = boxerActionList[combatType],
			}
			if actionMap[actName] then
				return actionMap[actName]
			end
		end
	end
	return actName
end
-- 骑马技能替换动作
function i3k_entity:getPlayerRideAction(actName)
	-- i3k_log("getPlayerRideAction- ".. actName)
	if self:GetEntityType() == eET_Player and self:IsOnRide() then
		return g_i3k_db.i3k_db_get_ride_mapped_action(actName)
	end
	return nil
end

function i3k_entity:getPetGuardAction(actName)
	if self:GetEntityType() == eET_Mercenary then
		local tb = {
			["run"] = "run",
			["attackstand"] = "stand",
		}
		return tb[actName]
	end
end
function i3k_entity:Play(actionName, loopTimes, force)
	if self:GetEntityType() == eET_Mercenary then
		local actName = self:getPetGuardAction(actionName)
		if actName then
			self:PlayPetGuardAction(actName)
		end
	end
	if actionName and actionName ~= "" then
		local use_action = actionName;
		if self._replaceAct then
			if self._replaceAct[actionName] then
				use_action = self._replaceAct[actionName];
			end
		end

		use_action = self:getHugAction(use_action)
		use_action = self:onMissionModeAction(use_action)
		use_action = self:getFightFlgAction(use_action)
		use_action = self:ReplacePlayerRunAct(use_action)
		use_action = self:getFishAction(use_action)
		use_action = self:getQuanshiAction(use_action)
		local playerAct, horseAct
		if self:getPlayerRideAction(use_action) then
			playerAct, horseAct = self:getPlayerRideAction(use_action)
			use_action = horseAct
		end

		self._actionName	= use_action;
		self._actionLst		= nil;
		self._actionChanged = false;

		if (force or not self._lockAni) and self._actionPause == 0 then
			if self._entity then
				if self:IsResCreated() then
					self._entity:SelectAction(self._actionName, loopTimes);
				end

				if self._entity:HaveVehicle() then
					if self:IsResCreated() then
						local hAction
						if self:getMountAction(self._actionName) then
							local entitys = self:GetLinkEntitys()
							if table.nums(entitys) > 0 then
								for i, e in pairs(entitys) do
									e:Play(self:getMountAction(self._actionName, i+2), loopTimes)
								end
							end
							hAction = table.nums(entitys) > 0 and self:getMountAction(self._actionName, 2) or self:getMountAction(self._actionName, 1)
						end
						if hAction or playerAct then
							self._entity:SelectMountAction(playerAct or hAction, loopTimes);
						end
					end
				end

				self._actionLoops = loopTimes;
				if self:IsResCreated() then
					self._entity:Play();
				end

			end
		else
			self._actionLoops	= loopTimes;
			self._actionChanged	= true;
		end
	end
end

-- 钓鱼鱼竿序列动作
function i3k_entity:LinkItemActionList(lstTb)
	if self:GetEntityType() == eET_Player then
		if self._linkItem and self._linkItem._entity then
			local actlist = Engine.ActionList();
	        for _, e in ipairs(lstTb) do
	            actlist:AddAction(e.actionName, e.actloopTimes)
	        end
			if self:IsResCreated() then
				self._linkItem._entity:SelectActionList(actlist);
			end
		end
	end
end
function i3k_entity:PlayLinkPetGuardItemAction(actionName)
	if self:GetEntityType() == eET_Mercenary then
		if self._linkItem and self._linkItem._entity then
			local alist = {}
			if actionName == "01attack01" then
				table.insert(alist, {actionName = actionName, actloopTimes = 1})
				table.insert(alist, {actionName = "stand", actloopTimes = -1})
			else
				table.insert(alist, {actionName = actionName, actloopTimes = -1})
			end
			self._linkItem:PlayActionList(alist, 1);
		end
	end
end

function i3k_entity:getActionList(lstTb, isMount, isAsync)
	local actlist = Engine.ActionList();
    if not isAsync then
        for _, e in ipairs(lstTb) do
            local actName = self:getFishAction(e.actionName)
            local playerAct, horseAct
            if self:getPlayerRideAction(actName) then
                playerAct, horseAct = self:getPlayerRideAction(actName)
                actName = horseAct
            end
            actlist:AddAction(isMount and playerAct or actName, e.actloopTimes)
        end
    end
	return isAsync and lstTb or actlist
end

function i3k_entity:PlayActionList(lstTb, loopTimes, force, isAsync)
    local actlist = self:getActionList(lstTb, false, isAsync)
   
	self._actionName	= nil;
	self._actionLst		= actlist;
	self._actionChanged = false;

	if (force or not self._lockAni) and self._actionPause == 0 then
		if self._entity then
			if self:IsResCreated() then
				self._entity:SelectActionList(actlist);
			end

			if self._linkItem then
				self:LinkItemActionList(lstTb);
			end

			if self._entity:HaveVehicle() then
				if self:IsResCreated() then
					self._entity:SelectMountActionList(self:getActionList(lstTb, true));
				end
			end

			self._actionLoops = loopTimes;
			if self:IsResCreated() then
				self._entity:Play();
			end
		end
	else
		self._actionLoops	= loopTimes;
		self._actionChanged	= true;
	end
end

function i3k_entity:Pause()
	if self._actionPause == 0 then
		if self._entity then
			self._entity:Pause();
		end
	end

	self._actionPause = self._actionPause + 1;
end

function i3k_entity:Resume()
	if self._actionPause > 0 then
		self._actionPause = self._actionPause - 1;

		if self._actionPause == 0 then
			if self._actionName then
				self:Play(self._actionName, self._actionLoops, true);
			elseif self._actionLst then
				self:PlayActionList(self._actionLst, self._actionLoops, true);
			end
		end
	end
end

function i3k_entity:OnStopAction(action)
	if self._aiController and self._aiController.OnStopAction then
		self._aiController:OnStopAction(action);
	end
end

function i3k_entity:OnAttackAction(id)
	if self._aiController and self._aiController.OnAttackAction then
		self._aiController:OnAttackAction(id);
	end
end

function i3k_entity:OnStopChild(id)
	if self._entity then
	self._entity:RmvHosterChild(id);
	end

	if id == self._reviveEffectID then
		self._reviveEffectID = nil;
	end

	self._hitEffectIDs[id] = nil;
end

function i3k_entity:PlayAttackEffectByTargets(entities, flySpeed)
	local _id = i3k_gen_attack_effect_guid();

	local atargets 	= Engine.AttackTargetByName();
	for k, v in pairs(entities) do
		if v._entity then
			atargets:AddTarget(v._entity:GetName());
		end
	end

	if self._entity then
		self._entity:SetCurrentAttackEvent(_id, atargets, 1.0, flySpeed, 0.0);
	end
end

function i3k_entity:PlayAttackEffectByPos(pos, flySpeed)
	local _id = i3k_gen_attack_effect_guid();
	if self._entity then
		local posE = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos));
		self._entity:SetVirtualAttackPoint(_id, posE, 1.0, flySpeed, 0.0);
	end
end

function i3k_entity:PlayHitEffect(eid)
	if self._entity then
		local cfg = i3k_db_effects[eid];
		if cfg then
			local effectID = -1;
			if cfg.hs == '' or cfg.hs == 'default' then
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s_%d", self._guid, eid, i3k_gen_attack_effect_guid()), "", "", 0.0, cfg.radius, true, true);
			else
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s_%d", self._guid, eid, i3k_gen_attack_effect_guid()), cfg.hs, "", 0.0, cfg.radius, true, true);
			end

			if effectID > 0 then
				self._entity:LinkChildPlay(effectID, 1, true);
				self._hitEffectIDs[effectID] = effectID;
			end
		end
	end
end

function i3k_entity:PlayHitEffectAlways(eid)
	if self._entity then
		local cfg = i3k_db_effects[eid];
		if cfg then
			local effectID = -1;
			if cfg.hs == '' or cfg.hs == 'default' then
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s_%d", self._guid, eid, i3k_gen_attack_effect_guid()), "", "", 0.0, cfg.radius);
			else
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s_%d", self._guid, eid, i3k_gen_attack_effect_guid()), cfg.hs, "", 0.0, cfg.radius);
			end
			if effectID > 0 then
				self._entity:LinkChildPlay(effectID, 1, true);
				self._hitEffectIDs[effectID] = effectID;
				return effectID
			end
		end
	end
	return 0
end
function i3k_entity:PlayReviveEffect(eid)
	if self._entity then
		local cfg = i3k_db_effects[eid];
		if cfg then
			if self._reviveEffectID and self._reviveEffectID > 0 then
				self._entity:RmvHosterChild(self._reviveEffectID);
			end
			self._reviveEffectID = nil;

			if cfg.hs == '' or cfg.hs == 'default' then
				self._reviveEffectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s", self._guid, eid), "", "", 0.0, cfg.radius, true, true);
			else
				self._reviveEffectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s", self._guid, eid), cfg.hs, "", 0.0, cfg.radius, true, true);
			end

			if self._reviveEffectID and self._reviveEffectID > 0 then
				self._entity:LinkChildPlay(self._reviveEffectID, -1, true);
			end
		end
	end
end

function i3k_entity:StopReviveEffect()
	if self._reviveEffectID and self._reviveEffectID > 0 then
		self._entity:RmvHosterChild(self._reviveEffectID);
	end
	self._reviveEffectID = nil;
end

function i3k_entity:PlayMissionEffect(eid)
	if self._entity then
		local cfg = i3k_db_effects[eid];
		if cfg then
			if self._missionEffectID then
				self._entity:RmvHosterChild(self._missionEffectID);
				self._missionEffectID = nil;
			end

			if cfg.hs == '' or cfg.hs == 'default' then
				self._missionEffectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_mission_effect_%s", self._guid, eid), "", "", 0.0, cfg.radius, true);
			else
				self._missionEffectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_mission_effect_%s", self._guid, eid), cfg.hs, "", 0.0, cfg.radius, true);
			end

			self._entity:LinkChildPlay(self._missionEffectID, -1, true);
		end
	end
end

function i3k_entity:StopMissionEffect()
	if self._missionEffectID and self._entity then
		self._entity:RmvHosterChild(self._missionEffectID);
		self._missionEffectID = nil;
	end
end

function i3k_entity:SetFaceDir(x, y, z)
	if self._actionPause <= 0 then
		self._faceDir		= i3k_vec3(x, y, z);
		self._orientation	= i3k_vec3_from_angle(math.pi * 2 - self._faceDir.y);

		if self._entity and not self._linkId then
			self._entity:SetRotation(x, y, z);
		end
	end
end

function i3k_entity:SetScale(s)
	self._scale = s;

	if self._entity then
		self._entity:SetScale(s);
	end
end

function i3k_entity:SetSyncCreateRes(b)
	self._syncCreateRes = b and true or false
end

function i3k_entity:GetRadius()
	return self._radius or 75;
end

function i3k_entity:Show(s, recursion, fadeTime, isSetTitleShow)
	local _r = recursion;
	if _r == nil then
		_r = true;
	end
	
	local _f = fadeTime;
	if _f == nil then
		_f = 0;
	end
	
	local isSet = isSetTitleShow;
	if isSet == nil then
		isSet = true
	end
	self._isShow = s;
	
	if self._entity then
		if s then
			self._entity:FadeIn(_f, _r);
			--self._entity:FadeIn(0, true);
		else
			self._entity:FadeOut(_f, _r);
		end
	end

	if self._title and self._title.node and isSet then
		self._title.node:SetVisible(s);
	end
end

function i3k_entity:IsShow()
	return self._isShow;
end

function i3k_entity:HidePlayerModel()
	self:Show(false, true)
	if not self._behavior:Test(eEBInvisible) then
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
		end
	end
end

function i3k_entity:TitleColorTest()
	--if self:IsResCreated() then
		if self._title and self._title.node and self._title.name then
			local mapType = i3k_game_get_map_type()
			local hero = i3k_game_get_player_hero()
			if mapType==g_ARENA_SOLO or mapType == g_QIECUO or mapType==g_CLAN_ENCOUNTER or mapType==g_CLAN_MINE or mapType==g_CLAN_BATTLE_WAR or mapType==g_CLAN_BATTLE_HELP or mapType==g_TOURNAMENT then
				local guid1 = string.split(hero._guid, "|")
				local guid2 = string.split(self._guid, "|")
				local isfriend = false
				if hero._guid == self._guid then
					isfriend = true
				elseif guid1[2] and guid2[3] and guid1[2] == guid2[3] then
					isfriend = true
				elseif self._hosterID == tonumber(guid1[2]) and self._hosterID then
					isfriend = true
				elseif g_i3k_game_context:IsTeamMember(tonumber(guid2[2])) then
					isfriend = true
				end
				if self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Mercenary then
					if isfriend then
						self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xff46bcff", 16), true);
					else
						self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xffff5069", 16), true);
					end
				end
				if mapType == g_TOURNAMENT then
					if self:GetEntityType() == eET_Mercenary then
						local test = self:GetTournamentFriendPet(self._guid)
						if test then
							self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xff46bcff", 16), true);
						end
					end
				end
			elseif mapType==g_TAOIST then
				local entityType = self:GetEntityType()
				if self._bwType==hero._bwType then
					self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xff46bcff", 16), true);
				else
					self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xffff5069", 16), true);
				end
			elseif mapType==g_FORCE_WAR or mapType == g_FACTION_WAR or mapType == g_BUDO or mapType == g_DEFENCE_WAR or mapType == g_DESERT_BATTLE or mapType == g_SPY_STORY then
				if self._forceType == hero._forceType then
					self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xff46bcff", 16), true);
				else
					self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xffff5069", 16), true);
				end
			else
				if self:GetEntityType() == eET_Player or self:GetEntityType() == eET_Mercenary then
					self._title.node:UpdateTextLable(self._title.name, "", false, self._TitleColor[self._PVPColor + 3], true);
				end
			end
		end
	--end
end

function i3k_entity:ShowTitleNode(vis)
	self._titleInfo.vis = vis
	if self._title and self._title.node then
		self._title.node:SetVisible(vis);
	end
end

function i3k_entity:CreateAgent()
	self:ReleaseAgent();

	if self._entity then
		self._agent = Engine.MAgent();
		self._agent:Create(self._entity:GetSelf(), self._curPosE, i3k_logic_val_to_world_val(self:GetPropertyValue(ePropID_speed)));
	end
end

function i3k_entity:ReleaseAgent()
	if self._agent then
		self._agent:Release();
		self._agent = nil;
	end
end

function i3k_entity:GetAgent()
	return self._agent;
end

function i3k_entity:UpdateAgentPos(pos)
	local _pos = pos;
	if self._agent then
		--[[
		_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
		self._agent:SetPosition(_pos);

		_pos = i3k_world_pos_to_logic_pos(self._agent:GetPosition());
		]]
		self._agent:SetPosition(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
	end

	return _pos;
end

function i3k_entity:SyncPos(pos)
	self._syncPos = true;

	self:SetPos(pos, true);
end

function i3k_entity:IsSyncPos()
	return self._syncPos;
end

function i3k_entity:ClearSyncPosState()
	self._syncPos = nil;
end

function i3k_entity:SetPos(pos, force, updateCamera)
	if not i3k_engine_check_pos(pos) then
		--i3k_log_stack();
		return false;
	end

	local _force = true;
	if force ~= nil then
		_force = force;
	end

	return self:UpdatePos(self:UpdateAgentPos(pos), force, updateCamera);
end

function i3k_entity:UpdatePos(pos, real, updateCamera)
	if not i3k_engine_check_pos(pos) then
		--i3k_log_stack();
		return false;
	end

	local _updateCamera = true;

	if updateCamera ~= nil then
		_updateCamera = updateCamera;
	end

	local _pos = i3k_vec3_clone(pos);
	if not self:IsPlayer() then
		local entityType = self:GetEntityType()
		if entityType == eET_Monster or entityType == eET_Pet or entityType == eET_Summoned or entityType == eET_HomePet or (entityType == eET_Player and self:GetGuidID() < 0)  then
			local world = i3k_game_get_world();
			if world and world._syncRpc then
				local height = i3k_db_combat_maps[world._cfg.mapID].height;
				local rangeValid = g_i3k_db.i3k_db_get_detection_block_range(self._cfg)	--  检测范围设置
				if not rangeValid then
				_pos.y = i3k_game_get_player_hero()._curPos.y + height;
				end
				_pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_logic_pos_to_world_pos(_pos), rangeValid));
			end
		end
	end

	if self._entity then
		self._entity:SetPosition(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos)), false);
		self:UpdateMemberPos(_pos)
		self:UpdateHugMemberPos(_pos)
	end

	self._curPos  = _pos;
	self._curPosE = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos));

	if _updateCamera and self._camera then
		self._camera:UpdatePos(self._curPosE);
	end

	g_i3k_game_context:OnEntityPosChanged(self);

	return true;
end

function i3k_entity:UpdateWorldPos(pos)
	if not i3k_engine_check_pos(pos) then
		return false;
	end

	if self._entity then
		self._entity:SetPosition(pos, false);
	end

	self._curPos  = i3k_world_pos_to_logic_pos(pos);
	self._curPosE = pos;

	if self._camera then
		self._camera:UpdatePos(self._curPosE);
	end

	self:UpdateMemberPos(self._curPos)
	self:UpdateHugMemberPos(self._curPos)
	g_i3k_game_context:OnEntityPosChanged(self);

	return true;
end

function i3k_entity:UpdateMemberPos(pos) --多人坐骑同步乘客位置
	if table.nums(self:GetLinkEntitys()) > 0 and not g_i3k_game_context:GetIsSpringWorld() then
		local memberOffSet = self._ride.deform.memberOffSet
		for i, e in pairs(self:GetLinkEntitys()) do
			if e then
				local nPos = i3k_vec3_clone(pos)
				local mPosX = nPos.x + (memberOffSet[i].x * self._orientation.x - memberOffSet[i].z * self._orientation.z)
				local mPosZ = nPos.z + (memberOffSet[i].x * self._orientation.z + memberOffSet[i].z * self._orientation.x)
				-- pos = {x = pos.x + memberOffSet[i].x, y = pos.y, z = pos.z + memberOffSet[i].z}
				local nPos = {x = mPosX, y = nPos.y, z = mPosZ}
				e:UpdatePos(nPos);
			end
		end
	end
end

function i3k_entity:GetCurPos()
	return self._curPos
end

function i3k_entity:UpdateHugMemberPos(pos) --相依相偎乘客位置同步
	if self._linkHugChild then
		self._linkHugChild:UpdatePos(pos)
	end
end

function i3k_entity:StartTurnTo(dir)
	if self._turnMode then
		self:SetFaceDir(self._turnDir.x, self._turnDir.y, self._turnDir.z);
		return;
	end

	local i3k_normalize_dir = function(dir)
		local v1 = i3k_vec3_clone(i3k_vec3_sub1(dir, self._faceDir));

		local pi1 = math.pi;
		local pi2 = math.pi * 2;

		while math.abs(v1.x) > pi1 do
			if v1.x > 0 then
				v1.x = v1.x - pi2
			else
				v1.x = v1.x + pi2
			end
		end

		while math.abs(v1.y) > pi1 do
			if v1.y > 0 then
				v1.y = v1.y - pi2
			else
				v1.y = v1.y + pi2
			end
		end

		while math.abs(v1.z) > pi1 do
			if v1.z > 0 then
				v1.z = v1.z - pi2
			else
				v1.z = v1.z + pi2
			end
		end

		self._turnTime = math.abs(v1.y) / (2 * math.pi) * 3
		v1 = i3k_vec3_add1(v1, self._faceDir)
		-- while v1.x > pi1 do v1.x = v1.x - pi2; end
		-- while v1.x < 0   do v1.x = v1.x + pi2; end

		-- while v1.y > pi1 do v1.y = v1.y - pi2; end
		-- while v1.y < 0   do v1.y = v1.y + pi2; end

		-- while v1.z > pi1 do v1.z = v1.z - pi2; end
		-- while v1.z < 0   do v1.z = v1.z + pi2; end
		return v1;
	end

	self._turnTick	= 0;
	self._turnMode	= true;
	self._turnDir	= i3k_normalize_dir(dir);
	self._turnOriDir= i3k_vec3_clone(self._faceDir);

	-- self:SetFaceDir(dir.x, dir.y, dir.z);
end

function i3k_entity:ClsBuffs()
end

function i3k_entity:ClsChilds()
end

function i3k_entity:ClsAttackers()
end

function i3k_entity:ClsEffect()
end

function i3k_entity:AddEnmity(entity, force)
	return false;
end

function i3k_entity:RmvEnmity(entity)
end

function i3k_entity:ClsEnmities()
end

function i3k_entity:UpdateEnmities()
end

function i3k_entity:GetEnmities()
	return { };
end

function i3k_entity:OnRandomResetSkill()
end

function i3k_entity:OnEnableDodgeSkill(value)
end

function i3k_entity:IsAttackable(attacker)
	return false;
end

function i3k_entity:CanAttack()
	return false;
end

function i3k_entity:ResetDamageRetrive()
end

function i3k_entity:UpdateDamageRetrive(all, dmg, cir, value)
end

function i3k_entity:GetDamageRetrive(dmg, cir)
	return 1;
end

function i3k_entity:CanMove()
	local ret = self._behavior:Test(eEBSpasticity) or self._behavior:Test(eEBShift) or self._behavior:Test(eEBStun) or self._behavior:Test(eEBSleep) or self._behavior:Test(eEBRoot) or self._behavior:Test(eEBFreeze) or self._behavior:Test(eEBPetrifaction);

	local speed = self:GetPropertyValue(ePropID_speed);
	if speed > 0 and self._movable then
		return not ret;
	end

	return false;
end

function i3k_entity:CalcMoveInfo()
	self._moveInfo.ticks = 0;
	self._moveInfo.speed = 0;
	self._moveInfo.dirs  = { };
	self._moveInfo.paths = { };
	self._moveInfo.keys = { };

	self._motionData	= nil;

	local agent = self:GetAgent();
	if agent then
		local data = agent:CalcMotionData(3, i3k_engine_get_tick_step());
		if data.mResult then
			self._motionData = data;

			--[[
			local _preP = nil;
			i3k_log("data.mTicks = " .. data.mTicks);
			for k = 1, data.mTicks do
				local p = data.mPaths[k - 1];
				i3k_log("     pos[" .. k .. "] = " .. i3k_format_pos(p));
				if k > 1 then
					i3k_log("     dist = [" .. k .. "] = " .. i3k_vec3_dist_2d(p, _preP));
				end
				_preP = p;
			end
			]]
		end
	end

	return self._motionData ~= nil;
end

function i3k_entity:IsValidMotionFrame(frame)
	local agent = self:GetAgent();
	if agent then
		if agent:IsPathPending() then
			return true;
		end

		if self._motionData then
			return self._motionData:IsValidFrame(frame);
		end
	end

	return false;
end

function i3k_entity:IsPathPending()
	local agent = self:GetAgent();
	if agent then
		return agent:IsPathPending();
	end

	return false;
end

function i3k_entity:SetVelocity(vel, force)
	if not self:CanMove() then
		return false;
	end

	if self._behavior:Test(eEBFear) then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;

		local _vel = { };
			_vel.x	= i3k_integer(vel.x * 1000) / 1000;
			_vel.y	= 0;
			_vel.z	= i3k_integer(vel.z * 1000) / 1000;

		local _valid = true;
		if self._velocity then
			if i3k_vec3_dist_2d(self._velocity, _vel) < 0.2 then
				_valid = false;
			end
		end

		if _force or _valid then
			self._velocity		= _vel;
			self._targetPos		= nil;
			self._fearPos		= nil;
			self._movePaths		= { };
			self._follow		= nil;
			self._moveChanged	= true;
		end
	end
end

function i3k_entity:SyncVelocity(vel, tick)
	self:SetVelocity(vel, false);
end

function i3k_entity:MoveTo(pos, force)
	if not self:CanMove() then
		return false;
	end

	if self._behavior:Test(eEBFear) then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;
		self._velocity		= nil;
		self._targetPos		= pos;
		self._fearPos		= nil;
		self._movePaths		= { };
		self._follow		= nil;
		self._moveChanged	= true;
	end
end

function i3k_entity:FearTo(pos, force)
	if not self:CanMove() then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;
		self._velocity		= nil;
		self._targetPos		= nil;
		self._fearPos		= pos;
		self._movePaths		= { };
		self._follow		= nil;
		self._moveChanged	= true;
	end
end

function i3k_entity:MovePaths(paths, force)
	if not self:CanMove() then
		return false;
	end

	if self._behavior:Test(eEBFear) then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;
		self._velocity		= nil;
		self._targetPos		= nil;
		self._fearPos		= nil;
		self._movePaths		= paths or { };
		self._follow		= nil;
		self._moveChanged	= true;

		self._behavior:Set(eEBMove);
	end
end

function i3k_entity:Follow(entity, force)
	if not self:CanMove() then
		return false;
	end

	if self._behavior:Test(eEBFear) then
		return false;
	end

	local _force = false;
	if force ~= nil then
		_force = force;
	end

	if _force or not self._forceMove then
		self._forceMove		= _force;
		self._velocity		= nil;
		self._targetPos		= nil;
		self._fearPos		= nil;
		self._movePaths		= { };
		self._follow		= entity;
		self._moveChanged	= true;
	end
end

function i3k_entity:TryMove()
	if self._moveChanged then
		if self._agent then
			self._agent:SetPosition(self._curPosE);
		end

		if self._velocity then
			self._moveChanged = false;

			local speed = self:GetPropertyValue(ePropID_speed);
			speed = i3k_logic_val_to_world_val(speed);

			local vel = i3k_vec3_normalize1(self._velocity);
			vel = i3k_vec3_mul2(vel, speed);

			local velE = i3k_vec3_to_engine(vel);
			if self._agent then
				self._agent:SetVelocity(velE);
			end

			self._behavior:Set(eEBMove);
		elseif self._targetPos then
			self._moveChanged = false;

			local pos = self._targetPos;

			local posE = i3k_vec3_to_engine(pos);
			if self._agent then
				self._agent:SetDestination(posE);
			end

			self._behavior:Set(eEBMove);
		elseif self._fearPos then
			self._moveChanged = false;

			local pos = self._fearPos;

			local posE = i3k_vec3_to_engine(pos);
			if self._agent then
				self._agent:SetDestination(posE);
			end

			self._behavior:Set(eEBMove);
		elseif self._follow then
			self._moveChanged = false;

			local pos = self._follow._curPosE;
			if self._agent then
				self._agent:SetDestination(pos);
			end

			self._behavior:Set(eEBMove);
		end
		self:CalcMoveInfo();

		return true;
	end

	return false;
end

function i3k_entity:StopMove(force)
	local _force = false;
	if force ~= nil then _force = force end

	if _force or self._behavior:Test(eEBMove) then
		self:ClearMoveState();

		self._behavior:Clear(eEBMove);
		--[[
		if self._aiController then
			self._aiController:SwitchComp();
		end
		]]
	end
end

function i3k_entity:SyncStopMove(tick)
	self:StopMove(false);
end

function i3k_entity:ClearMoveState()
	self._velocity		= nil;
	self._targetPos		= nil;
	self._fearPos		= nil;
	self._movePaths		= { };
	self._moveChanged	= false;
	self._forceMove		= false;
	self._preMove		= nil;
	self._moveInfo.dirs  = { };
	self._moveInfo.paths = { };
    self._moveInfo.ticks = 0;

	if self._agent then
		self._agent:StopMove();
	end

	if self._onStopMove then
		self._onStopMove(self._curPosE);
	end
end

function i3k_entity:IsMoving()
	return self._behavior:Test(eEBMove);
end

function i3k_entity:AttachCamera(camera)
	self._camera = camera;

	if self._camera and self._curPosE then
		self._camera:UpdatePos(self._curPosE);
	end
end

function i3k_entity:DetachCamera()
	self._camera = nil;
end

function i3k_entity:AddAiComp(atype)
	if self._aiController then
		self._aiController:AddComponent(atype);
	end
end

function i3k_entity:RmvAiComp(atype)
	if self._aiController then
		self._aiController:RmvComponent(atype);
	end
end

function i3k_entity:InitProperties()
	local properties =
	{
		[ePropID_lvl] 	= i3k_entity_property.new(self, ePropID_lvl,	0),
		[ePropID_speed] = i3k_entity_property.new(self, ePropID_speed,	0),
	};

	properties[ePropID_lvl	]:Set(0,		ePropType_Base, true);
	properties[ePropID_speed]:Set(0,		ePropType_Base, true);

	return self:OnInitBaseProperty(properties);
end

function i3k_entity:OnInitBaseProperty(props)
	return props;
end

function i3k_entity:GetPropertyValue(id)
	local prop = self._properties[id];
	if prop then
		local propCfg = i3k_db_prop_id[id]
		local value = prop:GetValue(self._allPorpReduceValue + self._WeaponBlessAllPorpReduceValue);
		local entityType = self:GetEntityType()
		local condition = self:IsPlayer() or entityType == eET_Pet or entityType == eET_Summoned or entityType == eET_Mercenary
		if condition and propCfg then
			if propCfg.minValue ~= 0 then
				if value < propCfg.minValue then
					value = propCfg.minValue
				end
			end
		end
		return value
	end

	return -1;
end

function i3k_entity:GetPropertyValueWithoutSkill(id)
	local prop = self._properties[id];
	if prop then
		-- return (prop._valueBase - prop._valuePS.Base - prop._valueF.Base - prop._valueHS.Base - prop._valueTL.Base - prop._valueUS.Base - prop._valueAMT.Base - prop._valueAMR.Base - prop._valueMS.Base);
		return prop:GetValuePure()
	end
end

function i3k_entity:GetProperty(id)
	return self._properties[id];
end

function i3k_entity:UpdateProperty(id, type, value, base, showInfo, force)
	local _force = false;
	if force ~= nil then
		_force = force;
	end

	local prop = self._properties[id];
	if prop then
		local valB = prop._valueB;
		local valE = prop._valueE;

		if type == 1 then
			if base then
				if force then
					prop:Set(value, ePropType_Base,false,ePropChangeType_Base);
				else
					prop:Set(valB.Base + value, ePropType_Base,false,ePropChangeType_Base);
				end
			else
				if force then
					prop:Set(value, ePropType_Skill,false,ePropChangeType_Base);
				else
					prop:Set(valE.Base + value, ePropType_Skill,false,ePropChangeType_Base);
				end
			end
		else
			if base then
				prop:Set(valB.Percent + value , ePropType_Base,false,ePropChangeType_Percent);
			else
				prop:Set(valE.Percent + value , ePropType_Skill,false,ePropChangeType_Percent);
			end
		end
	end
end

function i3k_entity:ResetProperty(id, base)
	local prop = self._properties[id];
	if prop then
		if base then
			prop:Set(0, ePropType_Base,false,ePropChangeType_Base);
			prop:Set(0, ePropType_Base,false,ePropChangeType_Percent);
		else
			prop:Set(0, ePropType_Skill,false,ePropChangeType_Base);
			prop:Set(0, ePropType_Skill,false,ePropChangeType_Percent);
		end
	end
end

function i3k_entity:ResetPropertys(id)
	local prop = self._properties[id];
	
	if prop then
		prop:ResetPropertys()
	end
end

function i3k_entity:ResetExtProperty(clearExt)
	for k, v in pairs(self._properties) do
		v:Set(0, ePropType_Passive,false,ePropChangeType_Base);
		v:Set(0, ePropType_Passive,false,ePropChangeType_Percent);
	end

	if clearExt then
		self._passives = { };
	end

	self._pasResetStack = self._pasResetStack + 1;
end

function i3k_entity:AddExtProperty(id, vtype, value)
	table.insert(self._passives, { id = id, type = vtype, value = value });
end

function i3k_entity:TryUpdateExtProperty()
	self._pasResetStack = self._pasResetStack - 1;
	if self._pasResetStack > 0 then
		return false;
	end

	if self._pasResetStack < 0 then
		i3k_log("passive property update error stack overflow 2");
	end

	return true;
end

function i3k_entity:UpdateExtProperty(props)
	if not self:TryUpdateExtProperty() then
		return false;
	end

	local eps = { };

	local _props = props or self._properties;

	for _, p in ipairs(self._passives) do
		table.insert(eps, { id = p.id, type = p.type, value = p.value });
	end

	_cmpEP = function(p1, p2)
		if p1.type < p2.type then
			return true
		elseif p1.type > p2.type then
			return false;
		else
			return p1.id < p2.id;
		end
	end
	table.sort(eps, _cmpEP);

	for k = 1, #eps do
		local p = eps[k];

		local prop = _props[p.id];
		if prop then
			if p.type == 1 then
				prop:Set(prop._valuePS.Base + p.value, ePropType_Passive,false,ePropChangeType_Base);
			else
				prop:Set(prop._valuePS.Percent + p.value*100, ePropType_Passive,false,ePropChangeType_Percent);
			end
		end
	end

	return true;
end

function i3k_entity:OnPropUpdated(id, value)
	if id == ePropID_lvl then
		if self._lvl ~= value then
			self._lvl = value;

			if self:GetEntityType() ~= eET_Player then
				self._properties = self:InitProperties();
			end

			if self._ctrlType == eCtrlType_Player then
				self._properties = self:InitProperties();
			end

			local logic = i3k_game_get_logic();
			if logic then
				local player = logic:GetPlayer();
				if player and player:GetHero() then
					local hero = player:GetHero();
					if hero._guid == self._guid then
						self:UpdateProperties()
					end
					for k = 1, player:GetMercenaryCount() do
						local mercenary = player:GetMercenary(k);
						if self._guid == mercenary._guid then
							self:UpdateProperties()
							break;
						end
					end
				end
			end

			if self._DelayProps then
				for k, v in ipairs(self._DelayProps) do
					i3k_log("delay update property");

					v();
				end
			end
			self._DelayProps = { };
		end
	end
end

function i3k_entity:OnBehavior(caller, bh, value)
	if bh == eEBSpasticity or bh == eEBShift or bh == eEBStun or bh == eEBSleep or bh == eEBRoot or bh == eEBFreeze or bh == eEBPetrifaction or bh == eEBFloating then
		self:ClearMoveState();
	end
end

function i3k_entity:OnBehaviorUpdate(caller, bh, value)
end

function i3k_entity:OnLeaveBehavior(bh)
end

function i3k_entity:OnClearAfterBehavior(bh)

end

function i3k_entity:IsDead()
	return false;
end

function i3k_entity:SetGroupType(type)
	self._groupType = type;
end

function i3k_entity:GetGroupType()
	return self._groupType;
end

function i3k_entity:GetEnemyType()
	local eType = { [eGroupType_U] = true };

	if self._groupType == eGroupType_O then
		eType = { [eGroupType_E] = true, [eGroupType_N] = true };
	elseif self._groupType == eGroupType_E then
		eType = { [eGroupType_O] = true };
	end

	return eType;
end

function i3k_entity:ValidInWorld()
	--return self._groupType == eGroupType_O or self._groupType == eGroupType_E or self._groupType == eGroupType_N;
	return false;
end

function i3k_entity:SetCtrlType(type)
	self._ctrlType = type;
end

function i3k_entity:GetCtrlType()
	return self._ctrlType;
end

function i3k_entity:OnDead(killerId)
end

function i3k_entity:SyncDead(killer, timeTick)
	self:OnDead(killer);
end

-- buffid only not direct valid
function i3k_entity:OnDamage(attacker, val, atr, cri, stype, showInfo, update, SourceType, direct, buffid)
end



function i3k_entity:UseItem(id)
	--TODO now test
	self:UpdateProperty(ePropID_hp, 1, i3k_integer(self:GetPropertyValue(ePropID_maxHP) * 0.25), false, true);
end

function i3k_entity:OnSelected(val)
	--i3k_log("OnSelected: " .. self._guid);

	if self._selected ~= val and not self:IsPlayer() then
		self._selected = val;

		if val then
			local hero = i3k_game_get_player_hero()
			local friendly = false
			if hero then
				for k,v in pairs(hero._alives[1]) do
					if v.entity._guid == self._guid then
						friendly = true ;
						break;
					end
				end
				for _, e in pairs(hero:GetLinkEntitys()) do
					if e._guid == self._guid then
						friendly = true;
						break;
					end
				end
			end

			local entity = self:GetEntityType() 
			if entity == eET_NPC or entity == eET_Crop then
				friendly = true;
			end

			if self:GetEntityType() == eET_Monster and self._cfg then
				if self._cfg.camp == g_DEFENCE_NPC_TYPE then
					friendly = true;
				end
			end
			if self:GetEntityType() ~= eET_PetRace then
				g_i3k_ui_mgr:CloseUI(eUIID_BattlePetRace)
			end
			if self._targetSelEffID and self._targetSelEffID > 0 then
				if self._entity then
					self._entity:RmvHosterChild(self._targetSelEffID);
				end
			end
			self._targetSelEffID = nil;

			if self._entity then
				local ecfg = i3k_db_effects[i3k_db_common.engine.targetSelEffect1];
				if friendly then
					ecfg = i3k_db_effects[i3k_db_common.engine.targetSelEffect2];
				end
				if self:GetEntityType() == eET_Monster and self._cfg.selectEffectId ~= 0 then
					ecfg = i3k_db_effects[self._cfg.selectEffectId]
				end

				if ecfg then
					if ecfg.hs == '' or ecfg.hs == 'default' then
						self._targetSelEffID = self._entity:LinkHosterChild(ecfg.path, string.format("entity_target_selected_%s", self._guid), "", "", 0.0, ecfg.radius * self._selEffScale);
					else
						self._targetSelEffID = self._entity:LinkHosterChild(ecfg.path, string.format("entity_target_selected_%s", self._guid), ecfg.hs, "", 0.0, ecfg.radius * self._selEffScale);
					end
					if not self:IsPlayer() then
						if self._targetSelEffID and self._targetSelEffID > 0 then
							self._entity:LinkChildPlay(self._targetSelEffID, -1, true);
						end
					end
				end

				if self._specialEffID and self._specialEffID > 0 and self._cfg.removeEffect == 1 then --removeEffect为1时取消怪物挂载特效
					self._entity:RmvHosterChild(self._specialEffID);
					self._specialEffID = nil;
				end
			end
		else
			if self._targetSelEffID and self._targetSelEffID > 0 then
				if self._entity then
					self._entity:RmvHosterChild(self._targetSelEffID);
				end
			end
			self._targetSelEffID = nil;
		end
	end
end

function i3k_entity:GetEntityType()
	return self._entityType;
end

function i3k_entity:OnTitleChange(show)
	if self._title and self._title.node then
		if show then
			self:ShowTitleNode(true);
		else
			self:ShowTitleNode(false);
		end
	end
end

function i3k_entity:EnableOutline(val, color)
	if self._entity then
		self._entity:EnableOutline(val, tonumber(color, 16));
	end
end

function i3k_entity:EnableOccluder(val)
	if self._entity then
		self._entity:EnableOccluder(val);
	end
end

function i3k_entity:EnableRender(val)
	self._renderable = val;

	if self._entity and self:IsResCreated() then
		if val then
			self._entity:EnterWorld(false);
		else
			self._entity:LeaveWorld();
		end
	end
end

function i3k_entity:IsRenderable()
	return self._renderable;
end

function i3k_entity:UpdateGrid(grid)
	self._grid = grid;
end

function i3k_entity:GetGrid()
	return self._grid;
end

function i3k_entity:OnEnterScene()
	--TODO
	self:SetIsOperationed(false)
end

function i3k_entity:SetIsOperationed(operation)
	self._isOperationed = operation
end

function i3k_entity:GetGUID()
	return self._guid;
end

function i3k_entity:SetColor(color)
	if self._entity and color then
		self._entity:SetColor(tonumber(color, 16), 1, 1, 1)
	end
end

function i3k_entity:SetLinkChildColor(id, color)
	if self._entity and color then
		self._entity:SetLinkChildColor(id, tonumber(color, 16))
	end
end

function i3k_entity:SetLinkParent(entity, linkID)
	self._linkParent	= entity;
	self._linkId		= linkID;
end

function i3k_entity:AddLinkChild(entity, mulPos, linkRolePoint, pos)
	if self._entity then
		if entity._entity then
			local world = i3k_game_get_world()
			if self._ride.deform then
				local linkInfo = self._ride.deform.horseLinkPoint
				entity:SetFaceDir(0, 1.5, 0);
				entity:SetLinkParent(self, self._entity:AddChild(entity._entity, linkInfo[mulPos + 1], linkRolePoint, pos));

				entity:OnSelected(false);
				entity:Play(self:getMountAction(i3k_db_common.engine.defaultStandAction, mulPos+2), -1) --乘客上马播放骑马stand动作
				if not entity:IsPlayer() then
					world._passengers[entity._guid] = entity
				end
				if entity._title and entity._title.node then
					entity._title.node:SetVisible(false)
				end
				self._linkChilds[mulPos] = entity
				if self:isRideSpecialShow() then
					entity:ChangeRidePlayAction(mulPos + 1, self:isRideSpecialShow(), self)
				end
			end
		end
	end
end

function i3k_entity:RemoveLinkChild()
	if self._linkParent and self._linkId then
		local world = i3k_game_get_world()
		if self._linkParent._entity then
			self._linkParent._entity:RmvChild(self._linkId)
		end
		if g_i3k_game_context:GetIsSpringWorld() then
			self:PlaySpringIdleAct()
		else
			self:Play(i3k_db_common.engine.defaultStandAction, -1)
		end
		if not self._linkParent:IsPlayer() then
			self._linkParent:EnableOccluder(false);
		end
		if self._title and self._title.node then
			self._title.node:SetVisible(true)
		end
		if self._rideSpecialSpr then
			self:ClearRidePlay();
		end
		world:ReleasePassenger(self._guid)
		self._linkParent	= nil;
		self._linkId		= nil;
	end
end

function i3k_entity:GetLinkEntitys()
	return self._linkChilds
end

function i3k_entity:GetLinkEntitysByIdx(index)
	return self._linkChilds[index]
end

function i3k_entity:ReleaseLinkChils()
	self._linkChilds = {}
end

function i3k_entity:ReleaseLinkChildIdx(index)
	if self._linkChilds[index] then
		self._linkChilds[index] = nil
	end
end

-- 相依相偎相关
function i3k_entity:SetLinkHugParent(entity, linkID)
	self._linkHugParent	= entity;
	self._linkHugId		= linkID;
end

function i3k_entity:AddHugLinkChild(entity)
	if self._entity then
		if entity._entity then
			local world = i3k_game_get_world()
			entity:SetLinkHugParent(self, self._entity:AddChild(entity._entity, "HS_sjbao", "CS_sjbao", Engine.SVector3(0.0, 0.0, 0.0)));
			entity:SetPos(self._curPos)
			self:PlayHugAction(self, i3k_db_common.hugMode.pickUp, i3k_db_common.hugMode.pickUpStand);	
			entity:Play(i3k_db_common.hugMode.pickedUpStand, -1);
			entity:SetFaceDir(0, 1.5, 0);
			entity:OnSelected(false);
			entity._hugMode.valid = true;
			self._hugMode.isLeader = true;
			if not entity:IsPlayer() then
				world._embracers[entity._guid] = entity
			end
			if entity._title and entity._title.node then
				entity._title.node:SetVisible(false)
				if entity._isHaveDynamic then
					entity:DetachTitleSPR()
				end
			end
			self._linkHugChild = entity
		end
	end
end

function i3k_entity:RemoveHugLinkChild()
	if self._linkHugParent and self._linkHugId then
		local world = i3k_game_get_world()
		if self._linkHugParent._entity then
			self._linkHugParent._entity:RmvChild(self._linkHugId)
		end
		if not self._linkHugParent:IsPlayer() then
			self._linkHugParent:EnableOccluder(false);
		end
		self._hugMode.valid = false;
		if self._title and self._title.node then
			self._title.node:SetVisible(true)
			if self._isHaveDynamic then
				self:AttachTitleSPR()
			end
		end
		world:ReleaseEmbracer(self._guid)
		self._linkHugParent	= nil;
		self._linkHugId		= nil;
	end
end

function i3k_entity:GetHugLinkEntitys()
	return self._linkHugChild
end

--怪物挂载特效特殊逻辑
function i3k_entity:AddSpecialEffect()
	if self:GetEntityType() == eET_Monster then
		local forceType = self:GetForceType()
		local heroType = g_i3k_game_context:GetForceType()
		local world = i3k_game_get_world()
		if self._cfg.effectId[1] ~= 0 then
			local effectId = self._cfg.effectId[1]
			if table.nums(self._cfg.effectId) > 1 and heroType ~= 0 and forceType ~= heroType then
				effectId = self._cfg.effectId[2]
			end
			local ecfg = i3k_db_effects[effectId]
			self._specialEffID = self._entity:LinkHosterChild(ecfg.path, string.format("entity_target_specail_%s", self._guid), ecfg.hs, "", 0.0, ecfg.radius * self._selEffScale);
		end
		if self._specialEffID and self._specialEffID > 0 then
			self._entity:LinkChildPlay(self._specialEffID, -1, true);
			world._specialMonsters[self._guid] = self
		end
	end
end

function i3k_entity:GetTournamentFriendPet(guid)
	if i3k_is_role_logined() then
	local membersProfile = g_i3k_game_context:GetTeamOtherMembersProfile()
	local ower = string.split(guid, "|")
	local ownerID = ower[3]
	for i,e in ipairs(membersProfile) do
		local id = e.overview.id
		if id == tonumber(ownerID) then
			return true
		end
	end
	end
	return false
end

function i3k_entity:SetLinkItemParent(entity, linkID)
	self._linkItemParent	= entity;
	self._linkItemId		= linkID;
end

-- 挂载entity
function i3k_entity:AddLinkItem(entity, hsLinkPoint, csLinkPoint, defaultAction, offsetY, scale)
	if self._entity then
		if entity._entity then
			local linkId = self._entity:AddChild(entity._entity, hsLinkPoint, csLinkPoint, Engine.SVector3(0.0, offsetY or 0.0, 0.0), scale or 1)
			entity:SetLinkItemParent(self, linkId);
			entity:Play(defaultAction, -1)
			self._linkItem = entity
		end
	end
end

function i3k_entity:RemoveLinkItem()
	if self._linkItemId then
		if self._entity then
			self._entity:RmvChild(self._linkItemId)
		end
		self:Play(i3k_db_common.engine.defaultStandAction, -1)
		self._linkItemParent	= nil;
		self._linkItemId		= nil;
	end
end

--设置怪物可点击次数
function i3k_entity:setCanClickCount(num)
	self._canClickData.canClickCount = num
end

--设置怪物点击次数用于重置
function i3k_entity:sethaveClickCount(num)
	self._canClickData.haveClickCount = num
end

--宠物试炼
function i3k_entity:getPetDungeonInfo()
	return self._petDungeonInfo
end

function i3k_entity:setPetDungeonInfo(value)
	self._petDungeonInfo = value
end

--决战荒漠
function i3k_entity:getDesertBatttleInfo()
	return self._desertInfo
end

function i3k_entity:setDesertBatttleInfo(scroe, id)
	self._desertInfo.modleId = id
	self._desertInfo.scroe = scroe
end

--决战荒漠骷髅复活 g_TASK_TRANSFORM_STATE_SKULL
function i3k_entity:PlaySkullReviveEffect(eid)
	if self._entity then
		local cfg = i3k_db_effects[eid];

		if cfg then
			local effectID = -1

			if cfg.hs == '' or cfg.hs == 'default' then
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s", self._guid, eid), "", "", 0.0, cfg.radius, true, true);
			else
				effectID = self._entity:LinkHosterChild(cfg.path, string.format("entity_%s_hit_effect_%s", self._guid, eid), cfg.hs, "", 0.0, cfg.radius, true, true);
			end

			if effectID > 0 then
				self._entity:LinkChildPlay(effectID, 1, true);				
			end
		end
	end
end
--密探风云
function i3k_entity:getSpyInfo()
	return self._spyInfo
end
function i3k_entity:setSpyInfo(camp, id)
	self._spyInfo.modelID = id
	self._spyInfo.camp = camp
end
--守护灵兽外显
function i3k_entity:isAttachPetGuard()
	local world = i3k_game_get_world()
	local mapType = i3k_game_get_map_type()
	if world and self:GetEntityType() == eET_Mercenary or self:GetEntityType() == eET_Player then --宠物身世 觉醒
		if self._linkitem then
			return false
		end
		local mapTb = { --屏蔽的地图类型
		}
		if mapTb[mapType] then
			return false
		end
		return true --g_i3k_game_context:GetCurPetGuard() ~= 0 and g_i3k_game_context:GetPetGuardIsShow()
	end
	return false
end
function i3k_entity:AttachPetGuard(petGuardId)
	if self:isAttachPetGuard() and petGuardId ~= 0 then
		local guardCfg = i3k_db_pet_guard[petGuardId]
		local modelId = i3k_engine_check_is_use_stock_model(guardCfg.modleId)
		if modelId and self._entity then
			self:LinkPetGuardItem(petGuardId)
				self._curPetGuardId = petGuardId
		end
	end
end

function i3k_entity:DetachPetGuard()
	if self._entity and self._linkItem then
		self:RemoveLinkItem()
		if self._linkItem then
			self._linkItem:Release()
			self._linkItem = nil
		end
		self._curPetGuardId = nil
	end
end
--记录守护灵兽信息 复活时用的到
function i3k_entity:SetCurPetGuardId(id)
	self._currentPetGuardIdUsedByRevive = id
end
function i3k_entity:GetCurPetGuardId()
	return self._currentPetGuardIdUsedByRevive
end

function i3k_entity:PlayPetGuardAction(actionName)
	if self:GetEntityType() == eET_Mercenary and self._linkItem then
		if self.petGuardPlayingAction ~= actionName then
			self:PlayLinkPetGuardItemAction(actionName)
			self.petGuardPlayingAction = actionName
		end
	end
end
-- npc 寻路
function i3k_entity:reSetFindPos()
	self._findPathData = {endPos = nil, callBack = nil, releaseCo = nil, entityFlag = true, aiFlag = true, runFlag = false, fadeDistance = 0, checkFlag = false}
end
function i3k_entity:setCallBack(value, callback, entityFlag, aiFlag, fadeDistance)
	self._findPathData.endPos = value
	self._findPathData.callBack = callback
	self._findPathData.entityFlag = entityFlag
	self._findPathData.aiFlag = aiFlag
	self._findPathData.fadeDistance = fadeDistance or 5
	self._findPathData.checkFlag = true
end
function i3k_entity:popMessage(text)
	local uiids = { eUIID_MonsterPop, eUIID_MonsterPop2, eUIID_MonsterPop3}
	for k, v in ipairs(uiids) do
		if not g_i3k_ui_mgr:GetUI(v) then
			g_i3k_ui_mgr:OpenUI(v)
			g_i3k_ui_mgr:RefreshUI(v, text, self)
			return
		end
	end
end
--创建合照投的头顶
function i3k_entity:TakePhotoCreateTitle(x, w, y, h,  name, isShow, typeName, color)
	if self._title and self._title.node then
		self._title[typeName] = self._title.node:AddTextLable(x, w, y, h, color, name);
		self._title.node:SetElementVisiable(self._title[typeName], isShow)
	end
end
