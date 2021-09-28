require "Core.Role.Controller.MainCameraController";
require "Core.Role.Controller.HeroController";
require "Core.Role.Controller.PlayerController";
require "Core.Role.Controller.RobotController";
require "Core.Role.Controller.MonsterController";
require "Core.Role.Controller.PortalController";
require "Core.Role.Controller.HeroPetController";
require "Core.Role.Controller.PetController";
require "Core.Role.Controller.HeroPuppetController";
require "Core.Role.Controller.PuppetController";
require "Core.Role.Controller.NpcController";
require "Core.Role.Controller.HeroGuardController";
require "Core.Role.Controller.PerformanMonsterController";
require "Core.Role.Controller.ArathiPointController";
require "Core.Role.Controller.ObjectController";
require "Core.Role.Controller.HirePlayerController";
require "Core.Manager.Item.AutoFightManager"
require "Core.Manager.Item.NoviceManager"
require "Core.Module.Scene.RoleNamePanel"
require "Core.Manager.Item.PetManager"
require "Core.Module.Scene.TargetFigthLabelPanel"
require "Core.Scene.MapRoleList"

require "Core.Module.Common.DropItem"
require "Core.Scene.SceneActiveMgr"
require "Core.Scene.SceneEventManager"
require "Core.Scene.SceneSelecter"

require "Core.Scene.MapPointCheckCtrManager"

require "Core.Manager.Item.ScencePropManager"
require "Core.Role.Controller.ScencePropController";


SceneMap = class("SceneMap")

SceneMap.info = nil;
local _eventMgr = nil;
local _activeMgr = nil;
local _selecter = nil;
local filterType = {"HeroPetController", "PetController", "HeroPuppetController", "PuppetController"}  -- 宠物筛选
SceneMap.MINGZURUQIN = "MINGZURUQIN"
SceneMap.MINGZURUQIN_END = "MINGZURUQIN_END"
SceneMap.INTERRUPT = "INTERRUPT"
SceneMap.SELF_CHP_SUB_CHANGE = "SELF_CHP_SUB_CHANGE"
local insert = table.insert
local removet = table.remove
local _sortfunc = table.sort
local Distance = Vector3.Distance

function SceneMap:New(id, fid)
	self = {};
	setmetatable(self, {__index = SceneMap});
	if(_eventMgr == nil) then _eventMgr = SceneEventManager:New() end
	if(_activeMgr == nil) then _activeMgr = SceneActiveMgr:New() end
	_activeMgr.SetMaxPlayerCount(AutoFightManager.GetBaseSettingConfig().maxPlayerCount)
	
	self._fid = fid;
	self._effects = {};
	self._rolePos = {}
	self._dropItem = {}
	self._dropItemInfo = {}
	self._hurtCmdList = {};
	self._ready = false;
	self._performanMonsters = {}
	self._allNpcCount = 0
	self._curNpcCount = 0
	self._bossCount = 0
	self:_Init(tonumber(id));
	
	if(_selecter == nil) then _selecter = SceneSelecter:New() end
	_selecter:SetMapRoleList(self._roles)
	return self;
end

function SceneMap:ResetLastSelectRole()
	if(_selecter) then
		_selecter:ResetLastSelectRole()
	end
end

function SceneMap:Dispose()
	ChoosePKTypeProxy.CancelForcePeace();
	ModuleManager.SendNotification(FightAlertNotes.CLOSE_FIGHTALERT);
	ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL)
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END);
	
	
	MapPointCheckCtrManager.GetInstance():Stop();
	if(self._arathWarTimer) then
		self._arathWarTimer:Stop()
		self._arathWarTimer = nil
	end
	SkillExecuteManage.Clear();
	
	local hero = HeroController.GetInstance();
	if hero then
		-- hero.target = nil;
		hero:StopAutoFight();
		hero:StopFightStatusTimer()
		hero:StopAttack();
		hero:SetTarget(nil)
		if(hero.pet) then
			hero.pet:StopAI();
			hero.pet:StopAction(3);
			hero.pet:Stand();
		end
		if(hero.puppet) then
			hero.puppet:StopAI();
			hero.puppet:StopAction(3);
			hero.puppet:Stand();
		end
		if(self.info.type == InstanceDataManager.MapType.Novice) then
			NoviceManager.B(hero);
		end
		-- hero:ClearSkillEffect();
	end
	
	self:_StopListener();
	if(self._roles) then
		self._roles:Dispose();
		self._roles = nil;
	end
	
	if(self._effects and table.getCount(self._effects) > 0) then
		for i, v in pairs(self._effects) do
			Resourcer.Recycle(v, false);
		end
	end
	
	self._effects = nil
	if(self._dropItem and table.getCount(self._dropItem) > 0) then
		for i, v in pairs(self._dropItem) do
			if(v) then
				v:Dispose()
			end
		end
	end
	
	if(self._performanMonsters and table.getCount(self._performanMonsters) > 0) then
		for i, v in pairs(self._performanMonsters) do
			if(v) then
				v:Dispose()
			end
		end
	end
	
	if(self.battlefieldPoints and table.getCount(self.battlefieldPoints) > 0) then
		for i, v in pairs(self.battlefieldPoints) do
			if(v) then
				v:Dispose()
			end
		end
	end
	
	if self._objects then
		for k, v in pairs(self._objects) do
			v:Dispose();
		end
	end
	
	if self.timer then self.timer:Stop() self.timer = nil end
	
	if(self._safeEffect) then
		Resourcer.Recycle(self._safeEffect, true)
		self._safeEffect = nil
	end
	
	_activeMgr:Clear();
	_eventMgr:Clear();
	_selecter:Clear();
	
	self._ready = false;
	self._dropItem = nil
	self._rolePos = nil
	self._npcInfoes = nil
	self._portalInfoes = nil
	self._ScenePropInfos = nil
	self._monsters = nil
	self._performanMonsters = nil
	self.battlefieldPoints = nil;
	self._bttlefieldCheckPoint = nil
	self._dropItemInfo = nil
	-- BaseModelCreater.ClearModels()
	BaseModelCreater.ClearAnims(hero)
	SoundManager.instance:ClearClip()
	DramaDirector.Clear()
	SceneEventManager.ClearCameraCache()
	TargetFigthLabelPanel.Clear()
	RoleNamePanel.Clear()
	Resourcer.ClearCacheAll()
end

function SceneMap:IsInstance()
	return self.info.type == InstanceDataManager.MapType.Instance
end

function SceneMap.GetActiveMgr()
	return _activeMgr
end

-- 删除角色
function SceneMap:RemoveRole(role)
	-- logTrace("SceneMap:RemoveRole=================")
	if(self:_GetIsBoss()) then
		if(role and role.info and role.info.slaughter) then
			self._bossCount = self._bossCount - 1
			if(self._bossCount <= 0) then
				ChoosePKTypeProxy.CancelForcePeace()
			end
			MsgUtils.ShowTips("WildBoss/OutArea");			
		end
	end
	_activeMgr:Remove(role.id);
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_REMOVE_ROLE, role);
	return self._roles:RemoveRole(role, true);
end

function SceneMap:RemoveById(id)
	local role = self._roles:GetRoleById(id)
	if(role) then
		return RemoveRole(role);
	end
	return false
end

-- 根据id获取角色
function SceneMap:GetRoleById(id)
	local role = HeroController.GetInstance();
	if(role.id ~= id) then
		role = self._roles:GetRole(id);
	end
	return role
end

-- 获取在视图上的所有角色管理员
function SceneMap:GetMapRole()
	return self._roles;
end
-- 获取在视图上的所有其他玩家
function SceneMap:GetAllHeros()
	return self._roles:GetAllHeros();
end

-- 获取在视图上所有某个类型的角色
function SceneMap:GetAllRoles(type)
	if(self._roles and type) then
		return self._roles:GetAllRoles(type);
	end
	return self._roles:GetAllRoles();
end

function SceneMap:GetBoss()
	if(self._roles) then
		return self._roles:GetBoss();
	end
	
end

-- 获取相同阵营最近角色
function SceneMap:GetSameCampRole(camp, position, distance)
	return self._roles:GetSameCampRole(camp, position, distance);
end

-- 获取相同阵营最近角色列表
function SceneMap:GetSameCampRoles(camp)
	return self._roles:GetSameCampRoles(camp);
end

-- 获取相同阵营血量最低
function SceneMap:GetSameCampLowHPRole(camp, position, distance)
	return self._roles:GetSameCampLowHPRole(camp, position, distance);
end

-- 获取组队队员血量最低
function SceneMap:GetSameTeamLowHPRole(camp, position, distance)
	return self._roles:GetSameTeamLowHPRole(camp, position, distance);
end

-- 获取不同阵营最近角色,ignoreElite忽略精英怪和boss,ignorePlayer忽略玩家
function SceneMap:GetNotSameCampRole(camp, position, distance, ignoreElite, ignorePlayer)
	local role = self._roles:GetNotSameCampRole(camp, position, distance, ignoreElite, ignorePlayer);
	return role
end

-- 获取攻击目标
function SceneMap:GetCanAttackTarget(camp, position, distance, pkType, guild, priority, ignoreElite, ignoreAppear)
	return self._roles:GetCanAttackTarget(camp, position, distance, pkType, guild, priority, ignoreElite, ignoreAppear);
end

function SceneMap:GetHostileTargets(camp, pkType)
	return self._roles:GetHostileTargets(camp, pkType);
end


function SceneMap:GetCanAttackTargetById(id, camp, position, distance)
	return self._roles:GetCanAttackTargetById(id, camp, position, distance);
end

-- 废弃
function SceneMap:GetRoleByArea(position, radius, roleType, ignoreElite)
	return self._roles:GetRoleByArea(position, radius, roleType, ignoreElite);
end

function SceneMap:_Init(id)
	
	local mapCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP);
	
	
	self._rolePos = {}
	self.info = mapCfg[id];
	self._roles = MapRoleList:New(self.info);
	SceneMap.currSceneInfo = self.info;
	
	local hero = HeroController.GetInstance();
	if(self.info and hero) then
		local mountL = hero:Get_mountLangController();
		
		if(GameSceneManager.to) then
			-- log("----------GameSceneManager.to----------------x " .. GameSceneManager.to.position.x .. " y " .. GameSceneManager.to.position.y .. " z " .. GameSceneManager.to.position.z);
			if mountL ~= nil then
				MapTerrain.SampleTerrainPositionAndSetPos(mountL.transform, GameSceneManager.to.position)
				--                    mountL.transform.position = MapTerrain.SampleTerrainPosition(GameSceneManager.to.position);
			else
				MapTerrain.SampleTerrainPositionAndSetPos(hero.transform, GameSceneManager.to.position)
				--                    hero.transform.position = MapTerrain.SampleTerrainPosition(GameSceneManager.to.position);
			end
			
			local rot = GameSceneManager.to.rot;
			if(GameSceneManager.to.ln) then
				self._toLN = GameSceneManager.to.ln;
			end
			if rot ~= nil then
				if mountL ~= nil then
					mountL.transform.rotation = Quaternion.Euler(0,(rot * 180 / math.pi), 0);
				else
					hero.transform.rotation = Quaternion.Euler(0,(rot * 180 / math.pi), 0);
				end
			end
		else
			if mountL ~= nil then
				MapTerrain.SampleTerrainPositionAndSetPos(mountL.transform, Convert.PointFromServer(self.info.born_x, self.info.born_y, self.info.born_z))
				
				
				--                    mountL.transform.position = MapTerrain.SampleTerrainPosition(Convert.PointFromServer(self.info.born_x, self.info.born_y, self.info.born_z));
			else
				MapTerrain.SampleTerrainPositionAndSetPos(hero.transform, Convert.PointFromServer(self.info.born_x, self.info.born_y, self.info.born_z))
				
				--                    hero.transform.position = MapTerrain.SampleTerrainPosition(Convert.PointFromServer(self.info.born_x, self.info.born_y, self.info.born_z));
			end
		end
		
		if mountL == nil then
			hero:SetFightStatus(self.info.type == 2);
			hero:StartFightStatusTimer(self.info.type == 2);
		end
		if(self.info.type == InstanceDataManager.MapType.WorldBoss) then
			ChoosePKTypeProxy.ForcePeace();
		end
	end
	GameSceneManager.to = nil;
	
	-- 如果场景没有控制角色 不需要锁定摄像机.
	if(hero) then
		MainCameraController:GetInstance():LockHero()
	end
	self:_InitBattlefield(self.info)
	self:_InitEffects(id)
	self:_InitSceneSetting()
	self:_StartListener();
	self:_StartEnterScene();
	
	-- 缓存场景自带的物件.
	self._selfScene = GameObject.Find("Scene");
	self._selfEffect = GameObject.Find("Effect");
	self._selfAnimation = GameObject.Find("Animation");
	
	if SoundManager.instance:PlayMusic(self.info.bg_music) then
		SoundManager.instance:PlayMusic("bgm_xsc");
	end
	
	if GameSceneManager.old_id ~= nil and GameSceneManager.id ~= nil then
		BackPackCDData.TryCleanExtCd(GameSceneManager.id, GameSceneManager.old_id)
	end
	
	
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT);
end

function SceneMap:SetActive(v)
	if self._selfScene then
		SceneMap.SetChildEnabled(self._selfScene, v);
	end
	
	if self._selfEffect then
		SceneMap.SetChildEnabled(self._selfEffect, v);
	end
	
	if self._selfAnimation then
		SceneMap.SetChildEnabled(self._selfAnimation, v);
	end
end

function SceneMap.SetChildEnabled(go, v)
	if go == nil then
		return;
	end
	
	local tr = go.transform;
	
	if tr.childCount == 0 then
		return;
	end
	
	for i = 1, tr.childCount do
		local tmp = tr:GetChild(i - 1).gameObject;
		tmp:SetActive(v);
	end
end
function SceneMap:GetSceneLightDirection()
	return self.info and self.info.light_direction or nil
end
function SceneMap:_InitSceneSetting()
	RenderSettings.fog =(self.info.is_fog == 1 and true or false)
	RenderSettings.fogDensity = self.info.fog_density / 100
	RenderSettings.fogColor = Color.New(self.info.fog_color[1] / 255,
	self.info.fog_color[2] / 255, self.info.fog_color[3] / 255, self.info.fog_color[4] / 255)
	RenderSettings.fogStartDistance = self.info.fog_linerStart
	RenderSettings.fogEndDistance = self.info.fog_linerEnd
	RenderSettings.ambientLight = Color.New(self.info.ambientLight[1] / 255,
	self.info.ambientLight[2] / 255, self.info.ambientLight[3] / 255, self.info.ambientLight[4] / 255)
	RenderSettings.fogMode = UnityEngine.FogMode.IntToEnum(self.info.fogMode)
	
	local skyBoxPath = "Prefabs/SkyBox/" .. self.info.sky_box
	if(self.info.sky_box ~= "") then
		Scene.instance:SetSkyBox(skyBoxPath)
	else
		Scene.instance:SetSkyBox("")
	end
	
	self:_CameraEffec()
end
function SceneMap:_CameraEffec()
	-- if not MainCameraController.camera or not self.info then return end
	--    local fb = UIUtil.GetComponent(MainCameraController.camera, "FastBloom")
	--    if not fb then return end
	--    fb.enabled = self.info.map == '10005_01'
end

function SceneMap:GetSceneObjById(id)
	return self._objects[id];
end

function SceneMap:_InitObjects(id)
	local objsCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_OBJECT);
	self._objects = {}
	if(objsCfg) then
		for i, v in pairs(objsCfg) do
			if(v.map == id) then
				local obj = ObjectController.New(v);
				local trf = obj.transform;
				self._objects[v.id] = obj;
				--_activeMgr:AddObj(obj, trf.gameObject);
			end
		end
	end
	self:RefreshObjectsByTask();
end

function SceneMap:RefreshObjectsByTask()
	if self._objects then
		for k, v in pairs(self._objects) do
			v:UpdateByTask();
		end
	end
end

function SceneMap:_InitMonsterInfo(id)
	local monsterCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER);
	self._monsters = {}
	if(monsterCfg) then
		for i, v in pairs(monsterCfg) do
			if(v.map_id == id) then
				local monster = MonsterInfo:New(v.id);
				insert(self._monsters, monster)
			end
		end
	end
end

function SceneMap:_InitNpcs(id)
	local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC);
	self._npcInfoes = {}
	if(npcCfg) then
		self._npcs = {}
		for i, v in pairs(npcCfg) do
			if(v.map == id and v.type == 1) then
				local npc = NpcController:New(v.id);
				local trf = npc.transform;
				npc.pos = npc.info.position
				MapTerrain.SampleTerrainPositionAndSetPos(trf, npc.pos)
				trf.rotation = Quaternion.Euler(0, npc.info.angle, 0);
				npc:Stand();
				RoleNamePanel.Add(npc);
				self._roles:AddRole(npc);
				insert(self._npcInfoes, npc.info)
				_activeMgr:AddNpc(npc, trf.gameObject);
				insert(self._npcs, npc)
			end
		end
		if #self._npcs then
			self.timer = Timer.New(function() self:_CheckLoadModle() end, 0, - 1, false):Start()
			self:_CheckLoadModle(true)
		end
	end
end
-- 按需要加载模型npc
function SceneMap:_CheckLoadModle(flg)
	local h = HeroController.GetInstance()
	local act = h:GetAction();
	if flg or(act ~= nil and(act.__cname == "SendMoveToAngleAction" or act.__cname == "SendMoveToAction"
	or act.__cname == "SendMoveToNpcAction")) then
		local ns = self._npcs
		local hpos = h:GetPos()
		for i = #ns, 1, - 1 do
			local n = ns[i]
			local dis = Vector3.Distance2(n.pos, hpos)
			if dis < 25 then
				n:CheckLoadModel()
				removet(ns, i)
			end
		end
		if self.timer and #ns == 0 then self.timer:Stop() self.timer = nil end
	end
end
-- 加载所有模型npc
function SceneMap:LoadAllModle()
	local ns = self._npcs
	if not ns then return end
	local len = #ns
	if len == 0 then return end
	for i = len, 1, - 1 do
		local n = ns[i]
		n:CheckLoadModel()
	end
	self._npcs = {}
	if self.timer then self.timer:Stop() self.timer = nil end
end

function SceneMap:_InitPortals(id)
	local portalCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP_PORTAL);
	self._portalInfoes = {}
	if(portalCfg) then
		for i, v in pairs(portalCfg) do
			if(v.map == id) then
				local portal = PortalController:New(v);
				local trf = portal.transform;
				MapTerrain.SampleTerrainPositionAndSetPos(trf, portal.info.position)
				
				portal.target = HeroController.GetInstance();
				portal:Stand();
				self._roles:AddRole(portal);
				insert(self._portalInfoes, portal.info)
				_activeMgr:AddObj(portal, portal.gameObject);
			end
		end
	end
end

function SceneMap:_InitEffects(id)
	local effectCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP_EFFECT);

	local effects = self._effects;
	if(effectCfg) then
		for i, v in pairs(effectCfg) do
			if(v.map == id) then
				local pt = Vector3.New(v.x / 100, v.y / 100, v.z / 100);
				local eff = Resourcer.Get("Effect/ScenceEffect", v.model);
				if(eff) then
					if(v.type == 2) then
						local parent = MainCameraController:GetInstance().transform;
						eff.transform:SetParent(parent);
						Util.SetLocalPos(eff, pt.x, pt.y, pt.z)
						eff.transform.localRotation = Quaternion.Euler(v.rx, v.ry, v.rz);
					else
						Util.SetPos(eff, pt.x, pt.y, pt.z)
					end
					effects[i] = eff;
				end
			end
		end
	end
	
	if(self.info.is_safe) then
		self._safeEffect = Resourcer.Get("Effect/ScenceEffect", "fx_safe_circle");
		if self._safeEffect then		
			MapTerrain.SampleTerrainPositionAndSetPos(self._safeEffect, Convert.PointFromServer(self.info.born_x, self.info.born_y, self.info.born_z))
		end
	end
end

function SceneMap:CheckArathiWarPoint()
	local hero = HeroController.GetInstance();
	local camp = hero.info.camp
	local role = self._roles:GetRoles()
	
	
	for k1, v1 in ipairs(self._bttlefieldCheckPoint) do
		v1.camp1 = false
		v1.camp2 = false
		
		if(hero and hero.transform) then
			local pos = hero.transform.position
			
			if(v1.r * v1.r >(pos.x * 100 - v1.x) *(pos.x * 100 - v1.x) +(pos.z * 100 - v1.z) *(pos.z * 100 - v1.z)) then			
				v1.camp1 = true						
			end		
		end
		
		for k, v in pairs(role) do
			
			if(v.roleType == ControllerType.PLAYER) then
				local pos = v.transform.position
				if(v1.camp1 == false and v.info.camp == camp) then					
					if(v1.r * v1.r >(pos.x * 100 - v1.x) *(pos.x * 100 - v1.x) +(pos.z * 100 - v1.z) *(pos.z * 100 - v1.z)) then				
						v1.camp1 = true						
					end					
				end		
				
				if(v1.camp2 == false and v.info.camp ~= camp) then					
					if(v1.r * v1.r >(pos.x * 100 - v1.x) *(pos.x * 100 - v1.x) +(pos.z * 100 - v1.z) *(pos.z * 100 - v1.z)) then
						v1.camp2 = true						
					end		
				end	
				
				if(v1.camp1 == true and v1.camp2 == true) then		
					break
				end				
			end
		end	
		
	end	
	
	MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIFIGHTCHAGE, self._bttlefieldCheckPoint)
end


function SceneMap:_InitBattlefield(info)
	if(info) then
		local cfg = nil;
		
		if info.type == InstanceDataManager.MapType.ArathiWar then
			cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_POINT);
			self._arathWarTimer = Timer.New(function() self:CheckArathiWarPoint() end, 2, - 1, true)
			self._arathWarTimer:Start()
		elseif info.type == InstanceDataManager.MapType.GuildWar then
			cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDWAR_POS);
		end
		
		if(cfg) then
			self.battlefieldPoints = {};
			self._bttlefieldCheckPoint = {}
			for i, v in pairs(cfg) do
				local tPoint = ArathiPointController:New(v);
				local trf = tPoint.transform;
				if(trf) then
					tPoint.target = HeroController.GetInstance();
					if(tPoint:IsValid()) then
						tPoint:Stand();
					else
						tPoint:Invalid()
					end
					MapTerrain.SampleTerrainPositionAndSetPos(trf, tPoint.info.position)
					--                    trf.position = MapTerrain.SampleTerrainPosition(tPoint.info.position);
					_activeMgr:AddObj(tPoint, tPoint.gameObject);
				end
				self.battlefieldPoints[i] = tPoint;
				if(v.type == 3) then
					local item = {}
					setmetatable(item, {__index = v})
					insert(self._bttlefieldCheckPoint, item)					
				end
				
			end
			local hero = HeroController.GetInstance();
			if(hero) then
				local mountL = hero:Get_mountLangController();
				local campHome = self.battlefieldPoints[hero.info.camp];
				if(campHome) then
					local radius = campHome.info.radius;
					--                    local pt = MapTerrain.SampleTerrainPosition(campHome.info.position);
					if mountL ~= nil then
						MapTerrain.SampleTerrainPositionAndSetPos(mountL.transform, campHome.info.position)						
						--                        mountL.transform.position = MapTerrain.SampleTerrainPosition(pt);
					else
						MapTerrain.SampleTerrainPositionAndSetPos(hero.transform, campHome.info.position)
						--                        hero.transform.position = MapTerrain.SampleTerrainPosition(pt);
					end
					--                    while true do
					--                        local r = math.Random(- math.pi, math.pi);
					--                        local len =(radius / 2) +(radius / 2) * math.Random(0.1, 1);
					--                        local tpt = pt;
					--                        tpt.z = tpt.z + math.cos(r) * len
					--                        tpt.x = tpt.x + math.sin(r) * len
					--                        if (GameSceneManager.mpaTerrain:IsWalkable(tpt)) then
					--                            if mountL ~= nil then
					--                                mountL.transform.position = MapTerrain.SampleTerrainPosition(tpt);
					--                            else
					--                                hero.transform.position = MapTerrain.SampleTerrainPosition(tpt);
					--                            end
					--                            return
					--                        end
					--                    end
				end
			end
		end
	end
end


-- 初始化 场景物件
function SceneMap:_InitSceneProps(map_id)
	
	local list = ScencePropManager.GetItems(map_id, ScencePropManager.SCENCE_PROP_TYPE_1);
	if(list) then
		for i, v in pairs(list) do
			self:AddSceneProp(v.id)
		end
	end

	if map_id == SceneEntityMgr.BAOXIAN_MAP_ID then
        SocketClientLua.Get_ins():SendMessage(CmdType.GetSceneProps)
    end	
end

-- id  scence_prop.lua 对应的 id
function SceneMap:AddSceneProp(prop_id)
	local propInfo = ScencePropManager.GetCfData(prop_id);
	if tonumber(propInfo.in_map_id) == tonumber(self.info.id) then
		self:_AddSceneProp(propInfo);
	end
	
end

--[[因为 场景操作物品 是不可能 在同一个场景， 同一时间出现 多个 同一 id 的物品， 所以可以用 id 作为表示
 物品 坐标不同， id 一定不同
]]
function SceneMap:_AddSceneProp(propInfo)
	
	local role = self._roles:GetRole(propInfo.id)
	if role == nil then
		local prop = ScencePropController:New(propInfo);
		local trf = prop.transform;
		propInfo.position = Convert.PointFromServer(propInfo.x, propInfo.y, propInfo.z)--小地图要用
		trf.position = MapTerrain.SampleTerrainPosition(propInfo.position);
		trf.rotation = Quaternion.Euler(0, propInfo.angle, 0);
		prop:Start();
		RoleNamePanel.Add(prop);
		self._roles:AddRole(prop);
		if not self._ScenePropInfos then self._ScenePropInfos = {} end
		insert(self._ScenePropInfos, propInfo)
		_activeMgr:AddObj(prop, prop.gameObject);
	else
		role:Start();
	end
	
end


-- 移除 场景操作物品
-- id  scence_prop.lua 对应的 id
function SceneMap:RemoveSceneProp(id)
	self._roles:RemoveById(id, true)
	local role = self._roles:GetRole(id)
	if role then
		local info = role.info
		local ns = self._ScenePropInfos
		for i = #ns, 1, - 1 do
			local n = ns[i]
			if n == info then
				removet(ns, i)
				break
			end
		end
	end
end



function SceneMap:SetBattlefieldPointCamp(id, camp)
	if(self.battlefieldPoints and camp) then
		local tPoint = self.battlefieldPoints[id];
		if(tPoint) then
			tPoint:SetPointCamp(camp)
		end
	end
end

function SceneMap:SetBattlefieldPointBuff(id, buff)
	if(self.battlefieldPoints and buff) then
		local tPoint = self.battlefieldPoints[id];
		if(tPoint) then
			tPoint:SetBuff(buff)
		end
	end
end

function SceneMap:_StartListener()
	-- RoleInView
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleInView, self._CmdRoleInViewHandler, self);
	-- RoleOutView
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleOutView, self._CmdRoleOutViewHandler, self);
	-- RoleMoveByPath
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleMoveByPath, self._CmdRoleMoveByPathHandler, self);
	-- RoleMoveByAngle
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleMoveByAngle, self._CmdRoleMoveByAngleHandler, self);
	-- RoleMoveEnd
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleMoveEnd, self._CmdRoleMoveEndHandler, self);
	-- SkillHurt
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SkillHurt, self._CmdSkillHurtHandler, self);
	-- CastSkill
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CastSkill, self._CmdCastSkillHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ExtraSkillEffect, self._CmdExtraSkillEffectHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AddBuff, self._CmdAddBuffHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RemoveBuff, self._CmdRemoveBuffHandler, self)
	---------------------------------------------------------
	-- PositionProof
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PositionProof, self._CmdPositionProofHandler, self);
	-- Dress
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DressChange, self._CmdDressChange, self)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DropItem, self._CmdDropItem, self)
	
	
	--  主线副本 结束 通知
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.InstanceMapResult, self._CmdInstanceMapResultHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetXMBossFBResult, self._GetXMBossFBResultHandler, self);
	
	-- 副本强制退出
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.FoceOutOfTeamFB, self._FoceOutOfTeamFBResultHandler, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PlayerDie, self._PlayerDieHandler, self);
	
	-- 队伍成员信息发生改变
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TeamDataChange, self._TeamDataChangeResultHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TransLateInScene, self._TransLateInSceneHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PlayAppearAnimation, self._PlayAppearAnimationHandler, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.InitNpc, self._InitNpcCallBack, self)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.NpcStateChange, self._NpcStateChangeCallBack, self)
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TargetOwnership, self._CmdTargetOwnershipHandler, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TargetMiss, self._CmdTargetMissHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.HeroAbsorption, self._CmdHeroAbsorptionHandler, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleRealmChange, self._CmdRoleRealmChangeHandler, self);
	
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendLineMovePre, self.LineMovePreChange, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RoleDisapear, self._CmdRoleDisapear, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.BossAffiliationChange, self._CmdBossAffiliationChangeHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildMsg, self._GuildMsg, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SceneNotice, self._SceneNotice, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PetChangeBody, self._PetChangeBodyCallBack, self);
	
	
	
	MessageManager.AddListener(PlayerManager, PlayerManager.OtherLevelChange, SceneMap._OtherLevelChange, self)
	MessageManager.AddListener(AutoFightManager, AutoFightManager.BASESETTINGCHANGE, SceneMap.OnBaseSettingChange, self)
	MessageManager.AddListener(TitleManager, TitleManager.TITLECHANGE, SceneMap.OnTitleChange, self)
	MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, SceneMap.OnGuildChange, self)
	MessageManager.AddListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE, SceneMap.InitZongMenLiLian, self);
	MessageManager.AddListener(TaskManager, TaskNotes.TASK_UPDATE, SceneMap.RefreshObjectsByTask, self);
end

function SceneMap:_StopListener()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleInView, self._CmdRoleInViewHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleOutView, self._CmdRoleOutViewHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleMoveByPath, self._CmdRoleMoveByPathHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleMoveByAngle, self._CmdRoleMoveByAngleHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleMoveEnd, self._CmdRoleMoveEndHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SkillHurt, self._CmdSkillHurtHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CastSkill, self._CmdCastSkillHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ExtraSkillEffect, self._CmdExtraSkillEffectHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AddBuff, self._CmdAddBuffHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RemoveBuff, self._CmdRemoveBuffHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PositionProof, self._CmdPositionProofHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DressChange, self._CmdDressChange)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DropItem, self._CmdDropItem)
	
	
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.InstanceMapResult, self._CmdInstanceMapResultHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetXMBossFBResult, self._GetXMBossFBResultHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.FoceOutOfTeamFB, self._FoceOutOfTeamFBResultHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PlayerDie, self._PlayerDieHandler, self);
	-- 队伍成员信息发生改变
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TeamDataChange, self._TeamDataChangeResultHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TransLateInScene, self._TransLateInSceneHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PlayAppearAnimation, self._PlayAppearAnimationHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.InitNpc, self._InitNpcCallBack, self)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.NpcStateChange, self._NpcStateChangeCallBack, self)
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TargetOwnership, self._CmdTargetOwnershipHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TargetMiss, self._CmdTargetMissHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.HeroAbsorption, self._CmdHeroAbsorptionHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleRealmChange, self._CmdRoleRealmChangeHandler, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendLineMovePre, self.LineMovePreChange, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RoleDisapear, self._CmdRoleDisapear, self);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.BossAffiliationChange, self._CmdBossAffiliationChangeHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildMsg, self._GuildMsg, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SceneNotice, self._SceneNotice, self);	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PetChangeBody, self._PetChangeBodyCallBack, self);
	
	MessageManager.RemoveListener(PlayerManager, PlayerManager.OtherLevelChange, SceneMap._OtherLevelChange)
	MessageManager.RemoveListener(AutoFightManager, AutoFightManager.BASESETTINGCHANGE, SceneMap.OnBaseSettingChange)
	MessageManager.RemoveListener(TitleManager, TitleManager.TITLECHANGE, SceneMap.OnTitleChange)
	MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, SceneMap.OnGuildChange)
	MessageManager.RemoveListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE, SceneMap.InitZongMenLiLian, self);
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFATTRIBUTEADD, SceneMap.HeroAttrChange);
	MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_UPDATE, SceneMap.RefreshObjectsByTask);
end

function SceneMap:_PetChangeBodyCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local role = self:GetRoleById(data.pid)
		if(role) then
			role:ChangeModel(data.id)
		end
	end
end

function SceneMap:_SceneNotice(cmd, data)
	if(data and data.errCode == nil) then
		MsgUtils.ShowAlert(data.id);
		
	end
end


function SceneMap:HeroAttrChange(changeData)	
	local h = HeroController.GetInstance()
    if not h then return end
	local attr = BaseAttrInfo:New()
	attr:Init(h.info)	
	
	local change = attr:Sub1(changeData)	
	if(table.getCount(change) > 0) then
		MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_ADDATTRS, change)		
	end
end

-- data
-- t:当前轮次多少次
-- npc：npcId
-- mid：map_id地图id
-- x：坐标
-- z：坐标
-- r：朝向
function SceneMap:InitZongMenLiLian()
	-- Warning("InitZongMenLiLian")
	local data = ZongMenLiLianDataManager.GetZongMenLiLianPreInfo()
	--  PrintTable(data)
	if(data and data.f == 0 and self._npcInfoes) then
		if(self.info.id == tonumber(data.mid)) then
			local isAdd = false
			if(not self._roles:HasRole(data.npc)) then
				isAdd = true
			end
			
			self:_AddNpc({id = data.npc})
			local role = self._roles:GetRole(data.npc)
			role.info.position = MapTerrain.SampleTerrainPosition(Convert.PointFromServer(data.x, 0, data.z))
			Util.SetPos(role.transform, role.info.position)
			
			--            role.transform.position = role.info.position;
			role.transform.rotation = Quaternion.Euler(0, data.r / 100, 0);
			if(isAdd) then
				insert(self._npcInfoes, role.info)
			end
			
			
		end
	end
end

function SceneMap:DelZongMengLiLianNpc(data)
	-- Warning("DelZongMengLiLianNpc")
	-- PrintTable(data)
	if(data) then
		self._roles:RemoveById(data.npc, true)
	end
end

-- 螟族入侵NPC初始化
function SceneMap:_InitNpcCallBack(cmd, data)
	if(data and data.errCode == nil) then
		self:_InitMingZuRuQinNpc(data.npc)
		
		--        if (data.npc) then
		--            self._allNpcCount = table.getCount(data.npc)
		--            local isStart = false
		--            for k, v in ipairs(data.npc) do
		--                if (v.st >= NpcController.State.NotFight) then
		--                    self:_AddNpc(v)
		--                    self._curNpcCount = self._curNpcCount + 1
		--                    isStart = true
		--                elseif v.st == NpcController.State.Hide then
		--                    self._roles:RemoveById(v.id, true)
		--                end
		--            end
		--            self:_MingZuRuQinState(isStart)
		--            if (not isStart) then
		--                self._curNpcCount = 0
		--            end
		--        end
		--        self:_NoticeNpcCountChange()
	end
end

function SceneMap:_InitMingZuRuQinNpc(data)
	self._allNpcCount = 0
	self._curNpcCount = 0
	if(data) then
		self._allNpcCount = table.getCount(data)
		local isStart = false
		for k, v in ipairs(data) do
			if(v.st >= NpcController.State.NotFight) then
				self:_AddNpc(v)
				self._curNpcCount = self._curNpcCount + 1
				isStart = true
			elseif v.st == NpcController.State.Hide then
				self._roles:RemoveById(v.id, true)
			end
		end
		if(not isStart) then
			self._curNpcCount = 0
		end
		self:_MingZuRuQinState(isStart)
	end
	self:_NoticeNpcCountChange()
end

-- 单个NPC状态改变
function SceneMap:_NpcStateChangeCallBack(cmd, data)
	if(data and data.errMsg == nil) then
		if(data.st == - 1 or data.st == - 2) then
			self._roles:RemoveById(data.id, true)
			self._curNpcCount = self._curNpcCount - 1
		else
			local role = self._roles:GetRole(data.id)
			if(role) then
				role:SetNpcState(data.st)
			end
		end
		self:_NoticeNpcCountChange()
	end
end

function SceneMap:_GuildMsg(cmd, data)
	if not data or data.errmsg then return end
	local m = GameSceneManager.map
	if m then
		-- Warning(tostring(r).."____" .. data.pid .. "___".. tostring(data.tgn))
		local r = self:GetRoleById(data.pid)
		if r then
			if data.tgn == '' then data.tgn = nil end
			r:UpdateOtherInfo(data.tgn)
		end
	end
end


function SceneMap:_NoticeNpcCountChange()
	MessageManager.Dispatch(SceneMap, SceneMap.MINGZURUQIN, {cur = self._curNpcCount, all = self._allNpcCount})
end

function SceneMap:_MingZuRuQinState(state)
	MessageManager.Dispatch(SceneMap, SceneMap.MINGZURUQIN_END, state)
end

function SceneMap.OnGuildChange()
	local role = HeroController.GetInstance()
	if(role and role.namePanel) then
		role.namePanel:UpdateOtherInfo()
	end
end

function SceneMap:OnTitleChange(data)
	if(data) then
		local role = HeroController.GetInstance()
		
		if(data.pi == role.id) then
			if(role and role.namePanel) then
				role.namePanel:UpdateOtherInfo()
			end
		else
			role = self._roles:GetRole(data.pi);
			if(role.info) then
				role.info:SetTitle(data.id)
			end
			
			if(role.namePanel) then
				role.namePanel:UpdateOtherInfo()
			end
			
		end
		
	end
end

function SceneMap:_PlayAppearAnimationHandler(cmd, data)
	if(data and data.errCode == nil and(not self._roles:HasRole(data.id))) then
		local hero = HeroController:GetInstance()
		if(hero and(Vector3.Distance2(Convert.PointFromServer(data.mv.x, 0, data.mv.z),
		Vector3.New(hero.transform.position.x, 0, hero.transform.position.z)) <= 20)) then
			local role = MonsterController:New(data, true);
			-- role.isAppear = true;
			if(role.info) then
				role.info.id = data.id;
				role.info.camp = data.camp;
				if(data.level) then
					role.info:SetLevel(data.level);
				end
				role.info.hp_max = data.mhp
				role.info.hp = role.info.hp_max;
				
				self:_InitRoleMvData(role, data.mv);
				self._roles:AddRole(role);
				--_activeMgr:AddNpc(role, role.gameObject);
				MsgUtils.ShowAlert(role.info.textId);
			end
			
			role:DoAction(AppearAction:New(role.info.appearConfig))
		end
	end
end

function SceneMap:_PlayerDieHandler(cmd, data)
	if(data and data.errCode == nil) then
		local reliveConfig = ConfigManager.GetReliveConfig(self.info.relive_type)
		if(self.info.type == 1) then
			local hero = PlayerManager.hero;
			hero:StopAutoFight();
			hero:StopAutoKill();
		end
		ModuleManager.SendNotification(MainUINotes.OPEN_RELIVEPANEL, {data, reliveConfig})
	end
end

function SceneMap:_TransLateInSceneHandler(cmd, data)
	if(data) then
		local role = HeroController.GetInstance();
		if(data.id ~= role.id) then
			role = self._roles:GetRole(data.id);
		end
		
		if(role) then
			role:SetPosition(Convert.PointFromServer(data.mv.x, data.mv.y, data.mv.z), data.mv.a)
		end
		
		if data.id == PlayerManager.playerId then
			SequenceManager.TriggerEvent(SequenceEventType.Base.TRANSMIT_END, data.mv);
		end
	end
end

function SceneMap:_StartEnterScene()
	local hero = HeroController.GetInstance();
	if(hero) then
		local data = Convert.PointToServer(hero.transform.position, hero.transform.rotation.eulerAngles.y)
		--        local t_CmdEnterSceneHandler = function(cmd, data)
		--            self:_CmdEnterSceneHandler(cmd, data);
		--        end
		--        self.t_CmdEnterSceneHandler = t_CmdEnterSceneHandler;
		SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EnterScene, self._CmdEnterSceneHandler, self);
		SocketClientLua.Get_ins():SendMessage(CmdType.EnterScene, data);
		if(hero.namePanel == nil) then
			RoleNamePanel.Add(hero, true);
		end
		
		if(self.info.type == InstanceDataManager.MapType.Novice) then
			NoviceManager.A(hero);
		end
		
		-- SocketClientLua.Get_ins():SendMessage(0xFF03, {pid = 114001});
	end
end

--[[18 队员升级，战斗力改变通知（服务端发出）
输出：
m:队员[id:玩家id，l:等级,hp:血量,max_hp:最大血量,f:战斗力]
0x0B18
]]
function SceneMap:_TeamDataChangeResultHandler(cmd, data)
	PartData.TeamMenberDataChange(data)
end

function SceneMap:_InitRoleMvData(role, mvData)
	if(role and mvData) then
		local pos = Convert.PointFromServer(mvData.x, mvData.y, mvData.z)
		if mvData.a then
			role:SetPosition(pos, mvData.a / 100)
		else
			role:SetPosition(pos)
		end
		if(mvData.v > 0) then
			role:SetMoveSpeed(mvData.v);
		end
		local st = mvData.st;
		if(st == 1) then
			role:MoveToAngle(mvData.a / 100, pos);
		elseif(st == 2) then
			if(mvData.paths ~= nil and table.getCount(mvData.paths) > 0) then
				role:MoveToPath(mvData.paths);
			end
		elseif(st == 3) then
			
			--[[            local action = PathAction:New()
            action:InitPath(role.transform, mvData.rid, onComplete, nil)
            role:DoAction(action);
            --]]
		else
			role:Stand();
		end
	end
end
-- 使用 载具 
function SceneMap:_InitPlayerMvDataByMount(role, info)
	if(role and info) then
		
		local mvData = info.mv;
		-- local countInfo = { id = 1000, mount_id = info.dress.m };
		-- role:OnMount(mvData.x, mvData.y, mvData.z, mvData.a, countInfo, mvData);
		--[[         S <-- 16:53:40.178, 0x0304, 0, {"views":[{"level":100,"pk":{"st":2,"m":3},"t":1,"camp":1,"kind":101000,"hp":17899,"mhp":17919,
         "mv":{"st":2,"z":-3031,"t":1,"paths":[3587,0,-2575,3637,0,-2475,3687,0,-2375,3737,0,-2275,3837,0,-2125,3887,0,-2025,3987,0,-1875,4087,0,-1725,4384,0,-1131],
         "v":16.0,"y":0,"x":3119,"id":"10100036"},
         "name":"\u9093\u4E91\u58A8","mp":7585,
         "dress":{"w":0,"h":0,"t":0,"b":0,"m":862000,"a":0,"c":""},
         "realm":{"rlv":0,"clv":0,"rsk":[0,0,0,0,0,0,0]},"sex":0,"id":"10100036"}]}
        ]]
		role:OnMount(mvData.x, mvData.y, mvData.z, 0, info.dress.m, mvData.rid, mvData.per, mvData, mvData.paths);
		
	end
end


function SceneMap:_AddMonster(info)
	-- if (info and not self._roles:HasRole(info.id)) then
	if(info) then
		local role = self._roles:GetRole(info.id)
		local blCreated = false;
		if(role == nil) then
			role = MonsterController:New(info);
			blCreated = true
		end
		-- info.rt = 1000 * 3600;
		if(role.info) then
			role.isAppear = false;
			if(info.level) then
				role.info:SetLevel(info.level);
			end
			role.info.camp = info.camp;
			role.info.id = info.id;
			role.info.hp = info.hp;
			role.info.hp_max = info.mhp;
			role.info.mp = info.mp;
			role.info.owner = info.oid;
			role.info.ownerName = info.on;
			self:_InitRoleMvData(role, info.mv);
			if(blCreated) then
				self._roles:AddRole(role);
				
				if role.info.type == MonsterInfoType.NORMAL or role.info.type == MonsterInfoType.ELITE or role.info.type == MonsterInfoType.BOSS then
					--if(role.info.type ~= MonsterInfoType.BOSS) then
					_activeMgr:AddMonster(role, role.gameObject);
					--end
				else
					-- if role.info.owner and role.info.owner == PlayerManager.playerId then
					RoleNamePanel.Add(role)
					-- end
				end
				if(role.info.slaughter) then
					self._bossCount = self._bossCount + 1
					ChoosePKTypeProxy.ForcePeace(PlayerPKType.Guild)
					MsgUtils.ShowTips("WildBoss/InArea");
				end
			end
			local camParam = role.info.isSpecCam
			-- 镜头参数{Y角度,y高,距离}
			if camParam and #camParam > 2 then
				local h = HeroController.GetInstance()
				if h then h:SetAttackBossMode(role, camParam) end
			end
			MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_ADD_ROLE, role);
		else
			role.Dispose();
		end
	end
end

function SceneMap:_AddPlayer(info)
	if(info and not self._roles:HasRole(info.id)) then
		local role = PlayerController:New(info);
		if(role.info) then
			role.info.camp = info.camp;
			role.info.hp = info.hp;
			role.info.hp_max = info.mhp;
			role.info.mp = info.mp;
			role:SetFightStatus(self.info.type == 2);
			role:StartFightStatusTimer(self.info.type == 2);
			-- Error(tostring(info.id) .. '____' .. tostring(info.mv))
			if info.dress.m ~= 0 then
				-- 使用 载具
				self:_InitPlayerMvDataByMount(role, info);
			else
				self:_InitRoleMvData(role, info.mv);
			end
			self._roles:AddRole(role);
			_activeMgr:AddPlayer(role, role.gameObject);
			RoleNamePanel.Add(role, true);
			if(info.msubj and info.msubj ~= "") then
				role.namePanel:ShowAffiliation();
			end
			role.namePanel:RefreshRoleCamp()
			-- 在 跟随状态的时候， 如果 跟随目标进入视野， 那么需要 处理
			local flctr = HeroController:GetInstance():GetFollowAiCtr();
			if flctr ~= nil then
				flctr:CheckInView(info.id);
			end
			
			MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_ADD_ROLE, role);
		else
			role.Dispose();
		end
	end
end

function SceneMap:_AddRobot(info)
	if(info and not self._roles:HasRole(info.id)) then
		local role = RobotController:New(info);
		if(role.info) then
			role.info.camp = info.camp;
			role.info.hp = info.hp;
			role.info.hp_max = info.mhp;
			role.info.mp = info.mp;
			role:SetFightStatus(self.info.type == 2);
			role:StartFightStatusTimer(self.info.type == 2);
			if info.dress.m ~= 0 then
				-- 使用 载具
				self:_InitPlayerMvDataByMount(role, info);
			else
				self:_InitRoleMvData(role, info.mv);
			end
			self._roles:AddRole(role);
			_activeMgr:AddPlayer(role, role.gameObject);
			RoleNamePanel.Add(role);
			
			-- 在 跟随状态的时候， 如果 跟随目标进入视野， 那么需要 处理
			--[[            local flctr = HeroController:GetInstance():GetFollowAiCtr();
            if flctr ~= nil then
                flctr:CheckInView(info.id);
            end
            ]]
			MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_ADD_ROLE, role);
		else
			role.Dispose();
		end
	end
end

function SceneMap:_AddPet(info)
	if(info and not self._roles:HasRole(info.id)) then
		local master = HeroController.GetInstance();
		local isSelf = true
		
		local role = nil;
		if(master.id ~= info.pid) then
			master = self._roles:GetRole(info.pid);
			isSelf = false
		end
		if(isSelf) then
			local pInfo = PetManager.GetCurrentPetdata()
			local tempInfo = {}
			setmetatable(tempInfo, {__index = pInfo})
			tempInfo.id = info.id
			role = HeroPetController:New(tempInfo);
		else
			role = PetController:New(info);
		end
		if(role) then
			if(role.info) then
				if(master) then
					master:SetPet(role);
				end
				
				role.info.camp = info.camp;
				role.info.pid = info.pid;
				role.info.id = info.id;
				role.info.hp = info.hp;
				role.info.hp_max = info.mhp;
				role.info.mp = info.mp;
				
				self:_InitRoleMvData(role, info.mv);
				self._roles:AddRole(role);
				
				self:_AddPetOrPuppetByConfig(role, role.gameObject, master and master:IsPetHide() or false)
				role:SetActiveByGonfig()
				RoleNamePanel.Add(role);
				--竞技场开启双方的宠物ai				 
				if(((role.__cname == "HeroPetController") or self:_GetIsPvP()) and not(master and master:IsPetHide() or false)) then
					role:StartAI();
				end
			else
				role.Dispose();
			end
		end
	end
end

function SceneMap:_AddPuppet(info)
	if(info and not self._roles:HasRole(info.id)) then
		local master = HeroController.GetInstance();
		local role = nil;
		if(master.id ~= info.pid) then
			master = self._roles:GetRole(info.pid);
			role = PuppetController:New(info);
		else
			role = HeroPuppetController:New(info);
		end
		if(role) then
			if(role.info) then
				if(master) then
					if(master.puppet ~= nil) then
						self:RemoveRole(master.puppet, true);
					end
					master:SetPuppet(role);
				end
				role:SetActiveByGonfig()
				role.info.camp = info.camp;
				role.info.id = info.id;
				role.info.hp = info.hp;
				role.info.hp_max = info.mhp;
				role.info.mp = info.mp;
				self:_InitRoleMvData(role, info.mv);
				self._roles:AddRole(role);
				self:_AddPetOrPuppetByConfig(role, role.gameObject, master and master:IsPuppetHide() or false)
				
				RoleNamePanel.Add(role);
				--竞技场开启双方的傀儡ai
				if((role.__cname == "HeroPuppetController" or self:_GetIsPvP()) and not(master and master:IsPuppetHide() or false)) then
					role:StartAI();
				end
			else
				role.Dispose();
			end
		end
	end
end

function SceneMap:_AddNpc(info)
	if(info and not self._roles:HasRole(info.id)) then
		local role = NpcController:New(info.id);
		role:CheckLoadModel()
		if(role.info) then
			role.info.camp = 0;
			role.info.id = info.id;
			role:SetNpcState(info.st)
			self._roles:AddRole(role);
			local trs = role.transform;
			--            trs.position = MapTerrain.SampleTerrainPosition(role.info.position);
			MapTerrain.SampleTerrainPositionAndSetPos(trs, role.info.position)
			trs.rotation = Quaternion.Euler(0, role.info.angle, 0);
			role:Stand();
			RoleNamePanel.Add(role);
		else
			role.Dispose();
		end
	end
end

function SceneMap:_AddGuard(info)
	if(info and not self._roles:HasRole(info.id)) then
		local master = HeroController.GetInstance();
		
		local role = nil;
		if(master.id ~= info.pid) then
			master = self._roles:GetRole(info.pid);
		end
		role = HeroGuardController:New(info);
		if(role) then
			if(role.info) then
				if(master) then
					master:AddGuard(role);
				end
				role.info.camp = info.camp;
				role.info.id = info.id;
				role.info.hp = info.hp;
				role.info.hp_max = info.mhp;
				role.info.mp = info.mp;
				self:_InitRoleMvData(role, info.mv);
				self._roles:AddRole(role);
				role:SetActiveByGonfig()
				RoleNamePanel.Add(role);
				role:StartAI();
			else
				role.Dispose();
			end
		end
	end
end

function SceneMap:_AddHire(info)
	if(info and not self._roles:HasRole(info.id)) then
		local master = HeroController.GetInstance();
		local role = nil;
		role = HirePlayerController:New(info);
		if(role) then
			if(role.info) then
				role.info.camp = info.camp;
				role.info.id = info.id;
				role.info.hp = info.hp;
				role.info.hp_max = info.mhp;
				role.info.mp = info.mp;
				self:_InitRoleMvData(role, info.mv);
				self._roles:AddRole(role);
				RoleNamePanel.Add(role);
				if(master.id == info.pid) then
					master:AddHire(role);
					-- role:SetMaster(master);
					role:StartAI();
				end
			else
				role.Dispose();
			end
		end
	end
end

function SceneMap:_AddPetOrPuppetByConfig(role, go, isPetorPuppetHide)
	if(AutoFightManager.GetBaseSettingConfig().showPet and not isPetorPuppetHide) then
		_activeMgr:AddPlayerPet(role, role.gameObject);
	end
end

function SceneMap:GetMapId()
	return self.info.map
end
function SceneMap:GetId()
	return self.info.id
end

function SceneMap:_CmdEnterSceneHandler(cmd, data)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EnterScene, self._CmdEnterSceneHandler, self);
	-- 属性改变的消息在场景初始话之后才需要监听
	MessageManager.AddListener(PlayerManager, PlayerManager.SELFATTRIBUTEADD, SceneMap.HeroAttrChange, self);
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_ENTER);
	
	local id = self.info.id
	_eventMgr:EnterScene(data.obstacle, id, self.info.map)
	_activeMgr:InitScene()
	self:_InitPortals(id);
	self:_InitNpcs(id);
	self:_InitMonsterInfo(id)
	-- self:InitZongMenLiLian()
	self:_InitObjects(id)
	if(data) then
		local view = data.views;
		--        local monsters = data.monsters;
		--        local pets = data.pets;
		local hero = HeroController.GetInstance();
		local npc = data.npc;
		
		if(hero) then
			MapTerrain.SampleTerrainPositionAndSetPos(hero.transform, Convert.PointFromServer(data.x, data.y, data.z))
			
			--            hero.transform.position = MapTerrain.SampleTerrainPosition(Convert.PointFromServer(data.x, data.y, data.z));
			hero:Resume();
			if(hero:GetAction() == nil or hero.state == RoleState.STAND) then
				hero:StopAction(3)
				hero:Stand(false);
			end
			if(hero.namePanel) then
				hero.namePanel:RefreshRoleName();
				hero.namePanel:RefreshRoleCamp()
			end
		end
		if(self._toLN) then
			SocketClientLua.Get_ins():SendMessage(CmdType.SceneLineChange, {ln = self._toLN});
			self._toLN = nil
		else
			if(view) then
				if(table.getCount(view) > 1) then
					_sortfunc(view, function(a, b) return a.t < b.t end)
				end
				
				for k, v in ipairs(view) do
					if(v.id ~= hero.id) then
						-- 过滤自己的信息
						if(v.t == ControllerSeverType.PLAYER) then
							self:_AddPlayer(v);
						elseif(v.t == ControllerSeverType.MONSTER) then
							self:_AddMonster(v);
						elseif(v.t == ControllerSeverType.PET) then
							self:_AddPet(v);
						elseif(v.t == ControllerSeverType.PUPPET) then
							self:_AddPuppet(v);
						elseif(v.t == ControllerSeverType.ROBOT) then
							self:_AddRobot(v);
						elseif(v.t == ControllerSeverType.GUARD) then
							self:_AddGuard(v);
						elseif(v.t == ControllerSeverType.HIRE) then
							self:_AddHire(v);
						end
					else
						hero.info.camp = v.camp;
						hero.info.tgn = v.tgn
						if(v.hp and hero.info.hp ~= v.hp) then
							hero.info.hp = v.hp
							MessageManager.Dispatch(PlayerManager, PlayerManager.SelfHpChange);
						end
						if(v.msubj and v.msubj ~= "") then
							hero.namePanel:ShowAffiliation()
						else
							hero.namePanel:HideAffiliation()
						end
					end
				end
			end
		end
		if(npc) then
			self:_InitMingZuRuQinNpc(npc)
		else
			self:_MingZuRuQinState(false)
		end
	end
	--        if (players) then
	--            for i, v in pairs(players) do
	--                if (v.id ~= hero.id) then
	--                    self:_AddPlayer(v);
	--                end
	--            end
	--        end
	--        if (monsters) then
	--            for i, v in pairs(monsters) do
	--                self:_AddMonster(v);
	--            end
	--        end
	--        if (pets) then
	--            for i, v in pairs(pets) do
	--                self:_AddPet(v);
	--            end
	--        end
	-- end
	self._ready = true;
	
	--[[    for i,v in pairs(self._hurtCmdList) do
        self:_CmdSkillHurtHandler(CmdType.SkillHurt,v);
    end
    ]]
	if(self.info["type"] == InstanceDataManager.MapType.Instance) then
		HeroController:GetInstance():Stand(false)
	end
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START);
	
	-- 登录 并进入场景后， 需要检测自己 是否 还在 载具状态
	MountManager.LoginCheckMount();
	
	-- 检测点 开始 检查
	MapPointCheckCtrManager.GetInstance():Start(self.info);
	SequenceManager.TriggerEvent(SequenceEventType.Base.MOVE_TO_SCENE, id);
	-- 需要判断 是否自动 战斗
	GameSceneManager.Check_autoFight()
	
	-- ZongMenLiLianDataManager.CheckGoOnZongMengLiLian()
	--[[    local act = HeroController.GetInstance():GetAction();
    if (act == nil or (act and act.__cname~="SendMoveToNpc")) then
        print("======xxxxxxxxxx==========")
    HeroController.GetInstance():MoveToNpc(130002);
    end
    ]]
	GameSceneManager.SetSceneLine(data.line)
	GameSceneManager.DestroyLoadObject()
	
	if(HeroController:GetInstance().info.hp == 0) then
		SocketClientLua.Get_ins():SendMessage(CmdType.PlayerDie);
	end
    self:_InitSceneProps(id)
end



function SceneMap:_CmdRoleInViewHandler(cmd, data)
	
	local hero = HeroController.GetInstance();
	if(data) then
		if(data.views and table.getCount(data.views) > 1) then
			_sortfunc(data.views, function(a, b) return a.t < b.t end)
		end		
		
		for k, v in pairs(data.views) do
			if(v.id ~= hero.id) then
				if(v.t == ControllerSeverType.PLAYER) then					
					self:_AddPlayer(v);
				elseif(v.t == ControllerSeverType.MONSTER) then
					self:_AddMonster(v);
				elseif(v.t == ControllerSeverType.PET) then
					self:_AddPet(v);
				elseif(v.t == ControllerSeverType.PUPPET) then
					self:_AddPuppet(v);
				elseif(v.t == ControllerSeverType.ROBOT) then
					self:_AddRobot(v);
				elseif(v.t == ControllerSeverType.GUARD) then
					self:_AddGuard(v);
				elseif(v.t == ControllerSeverType.HIRE) then
					self:_AddHire(v);
				end
			end
		end
	end
end

function SceneMap:_CmdRoleOutViewHandler(cmd, data)
	if(data) then
		if(data.l) then
			for k, v in ipairs(data.l) do
				local role = self._roles:GetRole(v.id);
				if(role and role.transform) then
					self:RemoveRole(role);
				end
			end
		end
	end
end

function SceneMap:_CmdRoleMoveByPathHandler(cmd, data)
	if(data) then
		local hero = HeroController.GetInstance();
		local role = self._roles:GetRole(data.id);
		if(role) then
			if(not role:IsDie()) then
				role:SetMoveSpeed(data.v);
			
				if(self:GetCanExcuteCmd(role)) then
					role:StopAction(3);
					-- 需要判断是否有载具
					assert(role.info, role.id .. ":" .. role.roleType)
					local dress = role.info.dress;
					
					if dress ~= nil and dress.m ~= 0 then
						role:OnMount(data.x, data.y, data.z, data.a, role.info.dress.m, nil, 0, nil, data.paths);
					else
						role:MoveToPath(data.paths);
					end
					
					if(data.spawn == 1) then
						role.state = RoleState.RETREAT;
					end
				end
			end
		else
			if(data.id == hero.id) then
				hero:SetMoveSpeed(data.v);
			end
		end
	end
end

function SceneMap:_CmdRoleMoveByAngleHandler(cmd, data)
	if(data) then
		local hero = HeroController.GetInstance();
		local role = self._roles:GetRole(data.id);
		if(role) then
			role:SetMoveSpeed(data.v);
			if(self:GetCanExcuteCmd(role)) then
				if(not role:IsDie()) then
					if role._mountLangController ~= nil then
						role:StopAction(3);
						role:SetMoveSpeed(0);
						
						role:MoveByAngleByMount(Convert.AngleFromServer(data.a), Convert.PointFromServer(data.x, data.y, data.z), data.v);
						
					else
						-- role:StopAction(3);
						role:MoveToAngle(Convert.AngleFromServer(data.a), Convert.PointFromServer(data.x, data.y, data.z));
					end
				end
			end
		else
			if(data.id == hero.id) then
				
				hero:SetMoveSpeed(data.v);
			end
		end
	end
end

function SceneMap:_CmdRoleMoveEndHandler(cmd, data)
	if(data) then
		local hero = HeroController.GetInstance();
		local role = self._roles:GetRole(data.id);
		if(self:GetCanExcuteCmd(role)) then
			if(not role:IsDie()) then
				if role._mountLangController ~= nil then
					role:MoveEndByMount(data);
				else
					role:StopAction(3);
					role:Stand(Convert.PointFromServer(data.x, data.y, data.z));
				end
			end
		end
	end
end

function SceneMap:_CmdSkillHurtHandler(cmd, data)
	if(data) then
		local hero = HeroController.GetInstance();
		local tRole = self:GetRoleById(data.tid);
		if(tRole and tRole.transform) then
			local skill = nil;
			local stage = nil;
			local sRole = nil;
			local tInfo = tRole:GetInfo()
			-- 敌人血量最大值得在技能执行之前改变
			if((tRole ~= hero) and data.mhp) then
				tInfo.hp_max = data.mhp
			end
			
			if(data.sid ~= nil) then
				sRole = self:GetRoleById(data.sid);
				if(sRole ~= nil) then
					if(tRole == hero) then
						_activeMgr:SetAttackMe(sRole);
						if(data.st == ControllerSeverType.PLAYER or data.st == ControllerSeverType.MONSTER) then
							
							if data.chp < 0 then
								-- http://192.168.0.8:3000/issues/4359
								-- 被打的时候 chp < 0
								-- 吃药的时候 chp > 0
								MessageManager.Dispatch(SceneMap, SceneMap.SELF_CHP_SUB_CHANGE, data);
							end
							
							MessageManager.Dispatch(SceneMap, SceneMap.INTERRUPT, data.st);
						end
					end
					if(data.skId ~= nil or data.skid ~= nil) then
						skill = sRole.info:GetSkill(data.skId or data.skid);
						if(skill) then
							stage = skill.stages[data.sgid];
							if(sRole.roleType == ControllerType.HERO or sRole.roleType == ControllerType.PLAYER) then
								sRole:ResetFightStatusTime();
							end
							SkillExecuteManage.ExecuteHitEffect(skill, data.sgid, sRole, tRole);
						end
					end
				end
			end
			
			tInfo.hp = data.hp;
			-- if (tRole:IsDie() and data.chp > 0 and data.chp == data.hp and data.chp == data.mhp) then
			if(data.live) then
				tRole:Relive();
			else
				if(tRole.roleType == ControllerType.HERO or(sRole and(sRole.roleType == ControllerType.HERO or sRole.roleType == ControllerType.HEORPET or sRole.roleType == ControllerType.HEROPUPPET or sRole.roleType == ControllerType.HEROGUARD))) then
					if(data.chp ~= 0) then
						TargetFigthLabelPanel.Add(tRole, data.chp, data.ht, data.st);
					end
				end
				if(tRole == hero and data.chp < 0 and(sRole and(sRole.roleType == ControllerType.PLAYER or sRole.roleType == ControllerType.PET or sRole.roleType == ControllerType.PUPPET))) then
					if(tRole.info.pkType == 0 and tRole.info.pkState == 0 and self.info.is_pk) then
						if(tRole:IsAutoFight() == false or(tRole:IsAutoFight() == true and AutoFightManager.revenge == true)) then
							ChoosePKTypeProxy.ChooseType(PlayerPKType.GoodEvil);
						end
					end
					ModuleManager.SendNotification(FightAlertNotes.OPEN_FIGHTALERT);
				end
			end
			
			if(tRole == hero) then
				MessageManager.Dispatch(PlayerManager, PlayerManager.SelfHpChange);
			end
			if(not tRole:IsDie()) then
				if(data.hp > 0) then
					if(skill) then
						if(tRole.roleType == ControllerType.MONSTER) then
							if(tRole:GetAction() == nil or tRole.state == RoleState.STAND) then
								tRole:Hurt();
							end
							if(stage and stage.knock_back_ID ~= 0 and tRole.info.is_back == true) then
								tRole:StopAction(3);
								tRole.transform.rotation = Quaternion.Euler(0, Convert.AngleFromServer(data.a), 0);
								tRole:Knock(stage.knock_back_ID, Convert.PointFromServer(data.x, data.y, data.z));
							end
						end
					end
					if(tRole.roleType == ControllerType.MONSTER and data.chp < 0) then
						tRole:HitBlink();
					end
					if(skill) then
						tRole:SetFightStatus(true);
						if(tRole.roleType == ControllerType.HERO or tRole.roleType == ControllerType.PLAYER) then
							tRole:ResetFightStatusTime();
						end
					end
				else
					local blFly = false;
					if(skill ~= nil) then
						blFly = true;
					end
					self:_SetRolePosData(tRole.id, tRole.transform.position)
					tRole:StopAction(3);
					if(tRole.info and tRole.info.slaughter) then
						ChoosePKTypeProxy.CancelForcePeace()
						MsgUtils.ShowTips("WildBoss/OutArea");
					end
					if(blFly) then
						tRole:LockTarget(sRole);
					end
					tRole:Die(blFly);
				end
			end
		end
	end
end

function SceneMap:_CmdCastSkillHandler(cmd, data)

	if(data and data.errCode == nil) then
		local hero = HeroController.GetInstance();
		local role = self:GetRoleById(data.sid);
		if(role and(not role:IsDie())) then
			local target = self:GetRoleById(data.tid);
			local skill = role.info:GetSkill(data.skid, true);
			if(skill) then
				MsgUtils.ShowAlert(skill.textId);
				if(skill.skill_type == 3) then
					role:CastPassiveSkill(skill, target);
				else
					if(role ~= hero) then
						if skill == nil and role._mountLangController ~= nil then
							skill = role._mountLangController.info:GetSkill(data.skid);
						end
						if(skill) then
						
							if(role and self:GetCanExcuteCmd(role) and(role ~= hero)) then
								local realPosition = MapTerrain.SampleTerrainPosition(Vector3.New(data.x / 100, data.y / 100, data.z / 100))
								if Vector3.Distance2(role.transform.position, realPosition) > 0.5 then		
									Util.SetPos(role.transform, realPosition.x, realPosition.y, realPosition.z)
									--                                role.transform.position = realPosition
								end
								role.info:AddSkill(data.skid);
								skill = role.info:GetSkill(data.skid);
								if(skill) then
									if(role ~= hero) then
										role.target = target;
									end
									role:StopAction(1);
									role:CastSkill(skill);
								elseif skill == nil and role._mountLangController ~= nil then
									skill = role._mountLangController.info:GetSkill(data.skid);
									
									role:StopAction(1);
									role:CastSkill(skill);
								end
							end
						end
						
						if(role.__cname == "RobotController" and self:_GetIsPvP()) then					
							role:RefreshEpigoneTarget()							
						end						
					else
						hero:RefreshEpigoneTarget();
					end
				end
			end
		end
	end
end

function SceneMap:_CmdExtraSkillEffectHandler(cmd, data)
	if(data) then
		local sRole = self:GetRoleById(data.sid);
		if(sRole) then
			local skill = sRole.info:GetSkill(data.skid);
			if(skill) then
				local eff = SkillExecuteManage.ExecuteAttackEffect(skill, data.sgid, sRole);
				if(eff and eff.transform ~= nil) then
					MapTerrain.SampleTerrainPositionAndSetPos(eff.transform, Vector3.New(data.x / 100, data.y / 100, data.z / 100))
					--                    eff.transform.position = MapTerrain.SampleTerrainPosition(Vector3.New(data.x / 100, data.y / 100, data.z / 100));
				end
			end
		end
	end
end

function SceneMap:_CmdAddBuffHandler(cmd, data)
	if(data) then
		local tRole = self:GetRoleById(data.tid);
		if(tRole and(not tRole:IsDie())) then
			local sRole = self:GetRoleById(data.sid);
			tRole:AddBuff(sRole, data.id, data.lv, data.rt, data.num);
		end
	end
end

function SceneMap:_CmdRemoveBuffHandler(cmd, data)
	if(data) then
		local role = self:GetRoleById(data.tid);
		if(role and(not role:IsDie())) then
			role:RemoveBuff(data.id, true);
		end
		--        if data.id == 218001 then --vip试用卡时间结束,弹出激励充值面板
		--            ModuleManager.SendNotification(VipTryNotes.OPEN_VIP_TRY_PANEL,{ s = 0 })
		--            ModuleManager.SendNotification(VipTryNotes.USE_VIP_TRY,{ s = 0 })
		--        end
	end
end

--
function SceneMap:_CmdPositionProofHandler(cmd, data)
	if(data) then
		local role = self:GetRoleById(data.id);
		if(role and role.namePanel) then
			-- 坐标
			role.namePanel:UPVerify(data.x, data.z, data.a);
		end
	end
end

function SceneMap:_OtherLevelChange(id, level)
	local role = self._roles:GetRole(id);
	if(role and role.info) then
		role.info:SetLevel(level);
		role:LoadLevelUpEffect()
	end
end

function SceneMap:_CmdDressChange(cmd, data)
	if(data) then
		local hero = nil
		local isother = true;
		
		hero = HeroController.GetInstance();
		if(data.id ~= hero.id) then
			hero = self._roles:GetRole(data.id);
			isother = true;
		else
			MessageManager.Dispatch(PlayerManager, PlayerManager.SelfDressChange, data.dress);
			isother = false;
		end
		
		
		if(hero ~= nil) then
			if(data.dress ~= nil) then
				if(data.dress.a ~= hero.info.dress.a) then
					hero.info.dress.a = data.dress.a
					hero:ChangeWeapon()
				end
				
				if(data.dress.b ~= hero.info.dress.b) then
					hero.info.dress.b = data.dress.b
					hero:ChangeBody()
				end
				
				if(data.dress.w ~= hero.info.dress.w) then
					hero.info.dress.w = data.dress.w
					hero:ChangeWing()
				end
				
				if(data.dress.c ~= hero.info.dress.c) then
					hero.info.dress.c = data.dress.c
					hero:Shapeshift()
				end
				
				if(data.dress.t ~= hero.info.dress.t) then
					hero.info.dress.t = data.dress.t
					hero:ChangeTrump()
				end
				
				if(data.dress.m ~= hero.info.dress.m) then
					-- 使用 载具
					if isother then
						if data.dress.m ~= 0 then
							local position = hero.transform.position;
							hero:DressInMount({id = 0, x = position.x, y = position.y, z = position.z, mount_id = data.dress.m})
						else
							hero:DressOutMount()
						end
					end
				end
				
				if(data.dress.h ~= hero.info.dress.h) then
					hero.info.dress.h = data.dress.h
					hero:ChangeRide()
					if((hero.state == RoleState.MOVE)) then
						hero:Play(RoleActionName.run)
					elseif(hero.state == RoleState.STAND) then
						hero:Play(RoleActionName.stand)
					end
				end
				
				if(data.dress.ap ~= hero.info.dress.ap) then				
					hero.info.dress.ap = data.dress.ap
					hero:ChangeWeaponEffect()
				end
				
				if(data.dress.bp ~= hero.info.dress.bp) then					
					hero.info.dress.bp = data.dress.bp
					hero:ChangeEquipEffect()
				end
				
			end
		end
	end
end


function SceneMap:_CmdDropItem(cmd, data)
	if(data) then
		
		local itemCount = table.getCount(data.l)
		for i = 1, itemCount do
			
			local tempDrop = {spId = 0, am = 0}
			tempDrop.spId = data.l[i].spId
			tempDrop.am = data.l[i].am
			
			insert(self._dropItemInfo, tempDrop)
		end
		
		local pos = self:_GetRolePosData(data.m)
		if pos ~= nil then
			for i = 1, itemCount do
				local item = DropItem:New(data.l[i].spId, pos, data.l[i].am)
				insert(self._dropItem, item)
			end
		end
	end
end

--  仙盟boss 副本 结算
--[[0A 帮会boss结算（服务器发出）
输出：
win：（0失败1成功）
instId：副本ID
items：道具[spIdL:道具ID,am:数量]
fItems：道具[spIdL:道具ID,am:数量](第一次通过额外奖励)
time：用时
l1：伤害列表[id：玩家排名,n:玩家呢称，v:伤害值,s:伤害比例,r:[spid:道具id，num:数量] ]
l2：治疗列表[id：玩家排名,n:玩家呢称，v:治疗值,s:伤害比例,r:[spid:道具id，num:数量] ]
l3：承受伤害列表[id：玩家排名,n:玩家呢称，v:承受伤害值,s:伤害比例,r:[spid:道具id，num:数量] ]

scene:{sid:sceneId,x,y,z} 下线场景点

0x030A

]]
function SceneMap:_GetXMBossFBResultHandler(cmd, data)
	
	-- 需要停在自动打怪
	HeroController.GetInstance():StopAutoFight();
	
	MessageManager.Dispatch(XMBossFloatPanelControll, XMBossFloatPanelControll.MESSAGE_XMBOSS_FBOVER);
	
	ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSGAMERESULTPANEL, data);
	
	
end

--[[ S <-- 19:38:03.134, 0x030A, 0, {"instId":"750001","fItems":[{"am":2,"spId":301000},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301001}],"star":[5,2,1],"it":1,"time":45,"items":[{"am":2,"spId":301000},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301001}],"win":1,"harts":[{"s":99,"t":1,"h":30946,"id":"20100244","icon_id":"101000","l":81,"n":"赖义宇"}],"scene":{"x":-35,"y":55,"z":-955,"sid":"709999"}}

]]
function SceneMap:_CmdInstanceMapResultHandler(cmd, data)
	
	-- 需要停在自动打怪
	HeroController.GetInstance():StopAutoFight();
	
	
	if data and data.errCode == nil and data.win == 1 then
		
		local instId = data.instId;
		local inscf = InstanceDataManager.GetMapCfById(instId);
		if inscf.type == InstanceDataManager.InstanceType.XuLingTaInstance then
			local cen = instId - 756000 + 1;
			InstanceDataManager.SetXLTHasPassInfo(cen)
		end
		
		if DramaDirector.CheckInstanceEnd(data.instId, data) then
			return
		end
		DramaDirector.SceneSlowMotion(3, 0.25, function()
			if not self._roles then return end
			self:CmdInstanceMapResultHandlering(data)
		end)
		return
	end
	self:CmdInstanceMapResultHandlering(data)
end

function SceneMap:CmdInstanceMapResultHandlering(data)
	if(data and data.errCode == nil) then
		
		local instId = data.instId;
		local cfData = InstanceDataManager.GetMapCfById(instId);
		local fb_type = cfData.type;
		local hero = HeroController.GetInstance();
		hero:StopAttack();
		hero:Stand();
		
		-- http://192.168.0.8:3000/issues/5847
		--Warning(fb_type)
		--PrintTable(data, "___", Warning)
		if fb_type == InstanceDataManager.InstanceType.MainInstance or
		fb_type == InstanceDataManager.InstanceType.ExperienceInstance or
		fb_type == InstanceDataManager.InstanceType.EquipInstance or
		fb_type == InstanceDataManager.InstanceType.SpiritStonesInstance or
		fb_type == InstanceDataManager.InstanceType.MaterialInstance or
		fb_type == InstanceDataManager.InstanceType.type_jiuyouwangzuo or
		fb_type == InstanceDataManager.InstanceType.type_MingZhuRuQing
		then
			-- 单人副本
			if(data.win == 1) then
				ModuleManager.SendNotification(FBResultNotes.OPEN_SINGLEFBWINRESULTPANEL, data);
			else
				ModuleManager.SendNotification(FBResultNotes.OPEN_SINGLEFBFAILRESULTPANEL, data);
			end
			
		elseif fb_type == InstanceDataManager.InstanceType.XuLingTaInstance then
			-- 虚灵塔
			if(data.win == 1) then
				ModuleManager.SendNotification(FBResultNotes.OPEN_XLTWINRESULTPANEL, data);
			else
				ModuleManager.SendNotification(FBResultNotes.OPEN_XLTFAILRESULTPANEL, data);
			end
			
			
		elseif fb_type == InstanceDataManager.InstanceType.System_instance or
		-- fb_type == InstanceDataManager.InstanceType.EquipInstance or
		-- fb_type == InstanceDataManager.InstanceType.SpiritStonesInstance or
		-- fb_type == InstanceDataManager.InstanceType.MaterialInstance or
		fb_type == InstanceDataManager.InstanceType.type_ZongMenLiLian then
			-- fb_type == InstanceDataManager.InstanceType.type_jiuyouwangzuo or
			-- fb_type == InstanceDataManager.InstanceType.type_MingZhuRuQing then
			-- 组队结束
			if(data.win == 1) then
				ModuleManager.SendNotification(FBResultNotes.OPEN_TEAMFBWINRESULTPANEL, data);
			else
				ModuleManager.SendNotification(FBResultNotes.OPEN_TEAMFBFAILRESULTPANEL, data);
			end
			
			
			--  pvp
		elseif fb_type == InstanceDataManager.InstanceType.PVPInstance then
			GameSceneManager.SetInitSceneCallBack(function() PVPProxy.SendGetPVPPlayer() end)
			if(data.win == 1) then
				ModuleManager.SendNotification(FBResultNotes.OPEN_PVPFBWINPANEL, data);
			else
				ModuleManager.SendNotification(FBResultNotes.OPEN_PVPFBFAILRESULTPANEL, data);
			end
			
		elseif fb_type == InstanceDataManager.InstanceType.type_novice then
			local toScene = data.scene;
			if(toScene) then
				local to = {}
				to.sid = toScene.sid;
				to.position = Convert.PointFromServer(toScene.x, toScene.y, toScene.z);
				GameSceneManager.GotoScene(toScene.sid, nil, to);
			end
		elseif fb_type == InstanceDataManager.InstanceType.type_endlessTry then
			ModuleManager.SendNotification(EndlessTryNotes.CLOSE_ENDLESS_INSPRIE_PANEL);
			ModuleManager.SendNotification(EndlessTryNotes.CLOSE_ENDLESS_EXP_BUY_PANEL);
			ModuleManager.SendNotification(FBResultNotes.OPEN_INSPIRETRY_WIN_PANEL, data);
		end
		
		
	end
end

--[[05 退出副本（服务器发出）
输出：
scene:{sid:sceneId,x,y,z} 跳转场景点
0x0F05

]]
function SceneMap:_FoceOutOfTeamFBResultHandler(cmd, data)
	local info = data.scene;
	
	local toScene = {};
	toScene.sid = info.sid;
	toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
	
	-- GameSceneManager.to = toScene;
	GameSceneManager.GotoScene(info.sid, nil, to);
end


function SceneMap:_SetRolePosData(id, pos)
	self._rolePos[id] = pos
end

function SceneMap:_GetRolePosData(id)
	if(self._rolePos[id] ~= nil) then
		return self._rolePos[id]
	end
end

function SceneMap:_RemoveRolePosData(id)
	if(self._rolePos[id] ~= nil) then
		self._rolePos[id] = nil
	end
end

-- 获取当前场景所有NPC数据
function SceneMap:GetCurNpcInfoes()
	return self._npcInfoes or {}
end

-- 获取当前场景所有传送门数据
function SceneMap:GetCurPortalInfoes()
	return self._portalInfoes or {}
end
-- 获取当前场景所有交互物件数据
function SceneMap:GetCurScenePropInfos()
	return self._ScenePropInfos or {}
end

function SceneMap:GetCurMonsterInfoes()
	return self._monsters or {}
end

-- 切换场景中的宠物形象
-- function SceneMap:_ChangePetModel(data)
--    if (data) then
--        local role = self._roles:GetRole(data.id)
--        if (role) then
--            role:ChangeModel()
--            --          local roleCreater = role:GetRoleCreater()
--            --          if(roleCreater) then
--            --             roleCreater = role:ChangeModel()
--            --          end
--        end
--    end
-- end
function SceneMap:AddMonsterCreater(id, controll)
	if(self._performanMonsters[id] == nil) then
		self._performanMonsters[id] = controll
	end
end

function SceneMap:GetMonsterCreater(id)
	if(self._performanMonsters[id] ~= nil) then
		local creater = ConfigManager.Clone(self._performanMonsters[id]:GetRoleCreater())
		self._performanMonsters[id]:GetRoleCreater():GetRole().transform.parent = null
		self._performanMonsters[id]:ClearRoleCreater()
		self._performanMonsters[id]:Dispose()
		self._performanMonsters[id] = nil
		return creater
	end
	return nil
end

function SceneMap:OnBaseSettingChange(data)
	
	local roles = self._roles:GetRoles()
	if(data) then
		for k, v in pairs(roles) do
			self:_PlayerChange(v, data)
		end
		
		self:_PlayerChange(HeroController:GetInstance(), data, true)
	end
end

function SceneMap.SetMaxPlayCount(count)
	_activeMgr.SetMaxPlayerCount(count)
end


function SceneMap:_PlayerChange(role, data, isSelf)
	isSelf = isSelf or false
	if(role) then
		if(data.showTrump ~= nil and(isSelf ~= true)) then
			role:SetRoleTrumpActive(data.showTrump)
		end
		
		if(data.showWing ~= nil and(isSelf ~= true)) then
			role:SetRoleWingActive(data.showWing)
		end
		
		if(data.showName ~= nil) then
			role:SetRoleNamePanelActive(data.showName)
		end
		
		if(data.showPet ~= nil) then
			if(table.contains(filterType, role.__cname)) then
				if(data.showPet) then
					_activeMgr:AddPlayerPet(role, role.gameObject)
				else
					_activeMgr:Remove(role.id)
				end
				
				if(role.gameObject) then
					role:SetActiveByGonfig()
				else
					assert(role, "SceneMap:_PlayerChange找不到对象")
				end
			end
		end
	end
end

function SceneMap:_CmdTargetOwnershipHandler(cmd, data)
	if(data) then
		local role = self._roles:GetRole(data.mid);
		if(role) then
			role.vested = data.subj;
		end
	end
end

function SceneMap:_CmdTargetMissHandler(cmd, data)
	if(data) then
		local hero = HeroController.GetInstance();
		local tRole = self:GetRoleById(data.tid);
		local sRole = self:GetRoleById(data.sid);
		if(tRole == hero or sRole == hero) then
			TargetFigthLabelPanel.Add(tRole, 0, TargetFigthLabelPanel.MISS);
		end
	end
end

function SceneMap:_CmdHeroAbsorptionHandler(cmd, data)
	if(data) then
		TargetFigthLabelPanel.Add(HeroController.GetInstance(), data.hm, TargetFigthLabelPanel.ABSORPTION);
	end
end

function SceneMap:_CmdRoleRealmChangeHandler(cmd, data)
	if(data) then
		local tRole = self:GetRoleById(data.id);
		if(tRole) then
			tRole.info.realm = data.realm;
			if(tRole.namePanel) then
				tRole.namePanel:RefreshRealm();
			end
		end
	end
end


--[[ 031B 别人 正在 改变 载具 路线 数据

 1B 轨迹移动数据
输入：
x
y
z
rid：路线id String
per：进度0-10000

输出：
id：playerId
x
y
z
rid：路线id


]]
function SceneMap:LineMovePreChange(cmd, data)
	if(data) then
		
		local hero = nil
		local isother = true;
		
		hero = HeroController.GetInstance();
		if(data.id ~= hero.id) then
			hero = self._roles:GetRole(data.id);
			
			if hero ~= nil then
				-- 只会处理 别人的载具情况
				local _mountController = hero:Get_mountController();
				
				
				if _mountController ~= nil and not _mountController.moving then
					-- 不在运动中，
					local mount_id = hero.info.dress.m;
					
					hero:OnMount(data.x, data.y, data.z, 0, mount_id, data.rid, data.per);
					
				end
			end
		end
	end
end

function SceneMap:_CmdRoleDisapear(cmd, data)
	if(data and data.errCode == nil) then
		local role = self._roles:GetRole(data.tid);
		if(role and not role:IsDie()) then
			self:RemoveRole(role);
		end
	end
end

function SceneMap:ResumeAllPortal()
	local ps = self:GetCurPortalInfoes()
	if(table.getCount(ps) > 0) then
		local temp
		for k, v in ipairs(ps) do
			temp = self._roles:GetRole(tostring(v.id))
			if(temp) then
				temp:Resume()
			end
		end
	end
end

function SceneMap:_CmdBossAffiliationChangeHandler(cmd, data)
	if(data and data.errCode == nil and data.l ~= nil) then
		for i, v in pairs(data.l) do
			local sRole = self:GetRoleById(v.pid);
			if(sRole) then
				if(v.msubj and v.msubj ~= "") then
					sRole.namePanel:ShowAffiliation();
				else
					sRole.namePanel:HideAffiliation();
				end
			end
		end
	end
end

function SceneMap:GetDropItem()
	return self._dropItem
end


function SceneMap:GetDropInfos()
	return self._dropItemInfo;
end

function SceneMap:SetSelect(data)
	if(_selecter) then
		_selecter:Selected(data)
	end
end

function SceneMap:GetCanExcuteCmd(role)
	if(role) then
		local hero = HeroController.GetInstance()
		local result =(role ~= hero.pet) and(role ~= hero.puppet) and(role.roleType ~= ControllerType.HEROGUARD) and(role.roleType ~= ControllerType.HIRE or(role.roleType == ControllerType.HIRE and not role.isMainControl))
		if(self:_GetIsPvP()) then
			-- log(result and(role.roleType ~= ControllerType.PET) and(role.roleType ~= ControllerType.PUPPET))
			return result 
		else
			-- log(result)			
			return result		
		end
	end
	return false	
end

function SceneMap:_GetIsPvP()
	return self.info.id == 705000
end

--是否boss
function SceneMap:_GetIsBoss()
	return self.info.is_boss
end 