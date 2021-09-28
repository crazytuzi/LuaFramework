----------------------------------------------------------------
--module(..., package.seeall)

local require = require;

local BASE = require("logic/i3k_base_logic").i3k_base_logic;


local g_i3k_player_toggle
	= true;
local g_i3k_player_toggle_tick
	= 0;

------------------------------------------------------
local TIMER = require("i3k_timer");
i3k_fps_timer = i3k_class("i3k_fps_timer", TIMER.i3k_timer);

function i3k_fps_timer:ctor(tickLine, entity)
	self._entity = entity;
end

function i3k_fps_timer:Do(args)
	local fps = g_i3k_game_handler:GetFPS();

	if self._entity then
		self._entity:ShowInfo(self._entity, eEffectID_Buff.style, "cur fps: " .. fps, i3k_db_common.engine.durNumberEffect[1] / 1000);
	end
end


------------------------------------------------------
i3k_simple_entity1 = i3k_class("i3k_simple_entity1");
function i3k_simple_entity1:ctor(guid)
	self._id			= -1;
	self._entity		= Engine.MEntity(guid);
	self._guid			= guid;

	i3k_game_register_entity(guid, self);
end

function i3k_simple_entity1:Create(name, cfg)
	self._name		= name;

	self:CreateResSync(cfg);

	return true;
end

function i3k_simple_entity1:SetPos(pos)
	if self._entity then
		self._entity:SetPosition(pos);
	end
end

function i3k_simple_entity1:Show(vis, recursion)
	if self._entity then
		if vis then
			self._entity:FadeIn(300, recursion);
		else
			self._entity:FadeIn(300, recursion);
		end
	end
end

function i3k_simple_entity1:CreateResSync(mcfg)
	if mcfg and self._entity then
		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._resCreated	= 1;
			self._height		= mcfg.titleOffset;

			--[[
			self._title = self:CreateTitle();
			if self._title.node then
				self._title.node:SetVisible(true);
				self._title.node:EnterWorld();

				self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
			end
			]]

			self._entity:SetActionBlendTime(0);

			self._entity:EnterWorld(false);
		end
	end
end

function i3k_simple_entity1:Play(action, loop)
	if self._entity then
		self._entity:SelectAction(action, loop);
		self._entity:Play();
	end
end

function i3k_simple_entity1:Release()
	if self._entity then
		self._entity:Release();
		self._entity = nil;
	end
	i3k_game_register_entity(self._guid, nil);
end


------------------------------------------------------
i3k_simple_entity2 = i3k_class("i3k_simple_entity2");
function i3k_simple_entity2:ctor(guid)
	self._id			= -1;
	self._guid			= guid;
end

function i3k_simple_entity2:Create(name, cfg)
	self._name		= name;
	self._nodeID	= -1;

	self:CreateResSync(cfg);

	return true;
end

function i3k_simple_entity2:SetPos(pos)
	if self._nodeID > 0 then
		g_i3k_actor_manager:SetLocalTrans(self._nodeID, pos);
	end
end

function i3k_simple_entity2:Show(vis, recursion)
	if self._nodeID > 0 then
		g_i3k_actor_manager:SetVisible(self._nodeID, vis or false, recursion or false);
	end
end

function i3k_simple_entity2:CreateResSync(mcfg)
	self._nodeID = g_i3k_actor_manager:CreateSceneNode("scene/model/StaticModel/bfmck/bfmck.stm", "simple_scene_node_" .. self._guid, false);
	if self._nodeID ~= -1 then
		g_i3k_actor_manager:EnterScene(self._nodeID);
	end
end

function i3k_simple_entity2:Play(action, loop)
	if self._nodeID ~= -1 then
		--[[
		g_i3k_actor_manager:SelectAction(self._nodeID, action);
		g_i3k_actor_manager:Play(self._nodeID, loop);
		]]
	end
end

function i3k_simple_entity2:Release()
	if self._nodeID > 0 then
		g_i3k_actor_manager:LeaveScene(self._nodeID);
		g_i3k_actor_manager:ReleaseSceneNode(self._nodeID);

		self._nodeID = -1;
	end
end


------------------------------------------------------
i3k_demo = i3k_class("i3k_demo", BASE)
function i3k_demo:ctor()
	--[[
	local XML = require("i3k_xml");

	local roleid = 1;

	local parser = XML.i3k_xml_parser.new();

	local cfg = parser:Load("user.xml");
	if not cfg then
		cfg = XML.i3k_xml_node.new("config");
	end

	if cfg then
		local user = cfg["user" .. roleid];
		if user then
			local s = "{ prop = { name = " .. user["@name"] .. ", pass = " .. user["@pass"] .. " }, volume = " .. user.volume:GetValue() .. " }";
			i3k_log(s);
		else
			local user = XML.i3k_xml_node.new("user" .. roleid);

			user:AddProperty("name", "demo1");
			user:AddProperty("pass", "123456");
			local volume = XML.i3k_xml_node.new("volume");
			volume:SetValue(100);
			user:AddChild(volume);
			local image = XML.i3k_xml_node.new("image");
			image:SetValue("adf adfasf adfasf");
			user:AddChild(image);

			cfg:AddChild(user);
		end
	end

	parser:Save(cfg, "user.xml");
	]]

	self._atkEffTick = 0;
	self._scenes = {};
	local usedMapID = {};
	for k, v in pairs(i3k_db_dungeon_base) do
		if usedMapID[v.mapID] == nil then
			usedMapID[v.mapID] = true
			local scene = {}
			scene.path = i3k_db_combat_maps[v.mapID].path
			scene.name = v.name
			scene.spawn_pos = v.spawnPos
			table.insert(self._scenes, scene);
		end
	end
	--table.insert(self._scenes, { path = "a",						name = "测试",			spawn_pos = { x = 0, y = 1, z = 0 }});
	--table.insert(self._scenes, { path = 'sp_demo',					name = "测试",			spawn_pos = { x = -157, y = 7.5, z = -54 } });
	self._curScene	= 1;
	self._tester	= false;
	self._testTick	= 0;
	self._targetPos	= i3k_vec3(31, 3, -33);

	--[[
	DCAccount:setAge(30);
	DCAccount:setGender(DC_MALE);
	DCAccount:setAccountType(DC_SinaWeibo);
	DCAccount:setGameServer("3区 偌德萨斯");
	DCAccount:setLevel(15);
	]]
end

function i3k_demo:Create()
	BASE.Create(self);

	g_i3k_game_handler:EnableObjHitTest(false, true);

	i3k_engine_init_rnd(tonumber(tostring(os.time()):reverse():sub(1, 6)));

	g_i3k_game_handler:SetWindowTitle("demo");

	self._splayer = { };
	--[[
	i3k_game_play_bgm("g:/mt/artres/audio/rxjh/BGM/bg02.ogg", 0.1);
	]]

	self:LoadScene();

	--[[
	i3k_log("server count", g_i3k_game_handler:GetServerListCount());
	i3k_log("server name", g_i3k_game_handler:GetServerName(0));
	i3k_log("server addr", g_i3k_game_handler:GetServerAddr(0));
	i3k_log("server port", g_i3k_game_handler:GetServerPort(0));
	--i3k_log("server group", g_i3k_game_handler:GetServerPort(0));
	i3k_log("server state", g_i3k_game_handler:GetServerState(0));
	i3k_log("announment", g_i3k_game_handler:GetAnnouncement());
	g_i3k_game_handler:RoleInfoChanged("adsafsaf");
	g_i3k_game_handler:RolePay("");
	]]

	return true;
end

function i3k_demo:OnUpdate(dTime)
	local ret = BASE.OnUpdate(self, dTime);

	if self._player then
		self._player:OnUpdate(dTime, true);
	end

	if self._async_entity then
		self._async_entity:OnUpdate(dTime);
	end

	if self._monster then
		self._monster:OnUpdate(dTime);
	end

	return true;
end

local test_move = false;
local test_move_tick = 5;

function i3k_demo:OnLogic(dTick)
	local ret = BASE.OnLogic(self, dTick);

	if self._tester then
		self._testTick = self._testTick + dTick * i3k_engine_get_tick_step();
		if self._testTick > 2000 then
			self._testTick = 0;

			if self._monster then
				self:ReleaseMonster();
			else
				self:CreateMonster(self._scenes[self._curScene].spawn_pos);
			end
		end
	end

	if self._player then
		if test_move then
			test_move_tick = test_move_tick + dTick;
			if test_move_tick >= 5 then
				test_move_tick = 0;

				local _x = i3k_engine_get_rnd_f(-1.0, 1.0);
				local _z = i3k_engine_get_rnd_f(-1.0, 1.0);

				self._player:SetVelocity(i3k_vec3_normalize1(i3k_vec3(_x, 0.0, _z)), true);
			end
		end

		self._player:OnLogic(dTick, true);
	end

	if self._async_entity then
		self._async_entity:OnLogic(dTick);
	end

	if self._monster then
		self._monster:OnLogic(dTick);
	end

	return ret;
end

function i3k_demo:OnMapLoaded()
	local scene = self._scenes[self._curScene];

	if self._loadTime then
		self._loadTime = os.clock() - self._loadTime;

		--i3k_log("load scene " .. Engine.UTF82A(scene.name) .. " time = " .. self._loadTime);
	end

	--[[
	local camera = i3k_game_get_logic():GetMainCamera();
	camera:UpdatePos(scene.spawn_pos);
	]]

	--self:CreatePlayer(scene.spawn_pos);

	--[[
	self:ReleaseAllSimplePlayer();
	local _x = -10;
	local _z = -10;
	for k1 = 1, 5 do
		for k2 = 1, 5 do
			local x = _x + k1 * 2;--i3k_engine_get_rnd_u(-10, 10);
			local z = _z + k2 * 2;--i3k_engine_get_rnd_u(-10, 10);

			self:CreateSimplePlayer(i3k_vec3(scene.spawn_pos.x + x, scene.spawn_pos.y, scene.spawn_pos.z + z));
		end
	end
	]]

	--[[
	for k1 = 1, 80 do
		self:CreateSimplePlayer(i3k_vec3(50, 10, 10));
	end
	]]

	g_i3k_game_handler:EnableObjHitTest(false, true);

	local ui = g_i3k_ui_mgr:OpenUI(eUIID_SP_DEMO);
	if ui then
		local name = scene.name;
		if self._loadTime then
			name = name .. " load time(" .. self._loadTime .. ")";
		end
		ui:setSceneName(name);
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Yg);

	return true;
end

function i3k_demo:PrevScene()
	self._curScene = self._curScene	- 1;
	if self._curScene < 1 then
		self._curScene = #self._scenes;
	end
	self:LoadScene();
end

function i3k_demo:NextScene()
	self._curScene = self._curScene	+ 1;
	if self._curScene > #self._scenes then
		self._curScene = 1;
	end
	self:LoadScene();
end

function i3k_demo:RefreshScene()
	self:UnloadMap();
	self:LoadScene();
end

function i3k_demo:UpdateLoadFlags(enableS, enableD, enableP, enableE, enableG, enableT)
	local flags = 0;
	if not enableS then
		flags = flags + eDisLoadStaticNode;
	end

	if not enableD then
		flags = flags + eDisLoadDynamicNode;
	end

	if not enableP then
		flags = flags + eDisLoadSprNode;
	end

	if not enableE then
		flags = flags + eDisLoadEffectNode;
	end

	if not enableE then
		flags = flags + eDisLoadGroupNode;
	end

	if not enableE then
		flags = flags + eDisLoadTerrain;
	end

	g_i3k_mmengine:SetLoadFlags(flags, eLoadPriority_Zero, 64);

	self:RefreshScene();
end

function i3k_demo:LoadScene()
	local loaded = function()
		self:OnMapLoaded();
	end

	self._loadTime = os.clock();

	--[[
	local scene = self._scenes[self._curScene];
	if scene then
		--g_i3k_mmengine:EnableSceneCheckPos(true, i3k_vec3_to_engine(scene.spawn_pos):ToEngine(), 32);

		self:LoadMap(scene.path, Engine.SVector3(0, 0, 0):ToEngine(), "default", loaded, 0);
	end
	]]
	self:LoadMap("shinei1", Engine.SVector3(0, 0, 0):ToEngine(), "default", loaded, 0);
end

function i3k_demo:UnloadScene()
	self:ReleasePlayer();
	self:UnloadMap();
end

function i3k_demo:CreatePlayer(pos)
	local SPlayer = require("logic/battle/i3k_player");

	if self._player then
		self._player:Release();
		self._player = nil;
	end

	local SPlayer = require("logic/battle/i3k_player");

	-- mt
	local player = SPlayer.i3k_player.new();
	if not player:Create() then
		player = nil;
	end

	if not player then
		return false;
	end

	local SEntity = require("logic/entity/i3k_hero");

	local entity = SEntity.i3k_hero.new(i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, 0), true);
	if not entity:Create(2, "安安生生", 1, 57, 9, 99, { }, true, false) then
		entity = nil;
	end

	if entity then
		entity:AttachCamera(self:GetMainCamera());
		entity:SetFaceDir(0, 0, 0);
		entity:SetGroupType(eGroupType_O);
		entity:SetHittable(false);
		entity:SetCtrlType(eCtrlType_Player);
		entity:Play(i3k_db_common.engine.defaultStandAction, -1);
		entity:AddAiComp(eAType_IDLE);
		entity:AddAiComp(eAType_MOVE);
		entity:AddAiComp(eAType_MANUAL_ATTACK);
		entity:AddAiComp(eAType_MANUAL_SKILL);
		entity:AddAiComp(eAType_FIND_TARGET);
		--entity:SetVehicleInfo("model/player/rxjh/zuoqi/ma/ma.spr", "HS_zuoqi", "CS_zuoqi");
		--entity._entity:LinkHosterChild("effect/rxjh_buff/buff_zhounianqing_run02.aef", "entity_buff_100_effect_222", "", "", 0.0, 1, false, true);

		entity:SetPos(i3k_world_pos_to_logic_pos(pos), true);
		entity:Show(true, true);
		--entity:SetScale(2.5);

		entity:SetVehicleInfo("model/player/rxjh/zuoqi/ma/ma.spr", "HS_zuoqi", "CS_zuoqi");

		--entity._entity:EnableOutline(true, tonumber("80ffff00", 16));
		--entity._entity:EnableOccluder(true);

		player:SetHero(entity);
	end
	self._player = player;
end

function i3k_demo:ReleasePlayer()
	if self._player then
		self._player:Release();
		self._player = nil;
	end
end

function i3k_demo:AsyncCreatePlayer()
	--[[
	if self._entity then
		self._entity = nil;
	end
	]]
	self._entity = Engine.MEntity("demo_0x0001");

	--i3k_log("create entity");

	--[[
	if self._async_entity then
		self._async_entity:Release();
	end

	self._async_entity = i3k_entity.new("entity_0x001001");
	self._async_entity._entity:AsyncCreateHosterModel("model/player/rxjh/yongbing/yuanling/yuanling.spr", "entity_hoster_0x001001");
	self._async_entity:SetPos(i3k_world_pos_to_logic_pos(i3k_vec3(7, 5, 14)), true);
	self._async_entity:Show(true, true);
	self._async_entity:Play("attackstand", -1);
	]]
end

function i3k_demo:AsyncReleasePlayer()
	if self._entity then
		self._entity = nil;
	end
	--i3k_log("release entity");

	--[[
	if self._async_entity then
		self._async_entity:Release();
		self._async_entity = nil;
	end
	]]
end

local simple_guid = 0;
function i3k_demo:CreateSimplePlayer(pos)
	simple_guid = simple_guid + 1;

	local mcfg = i3k_db_models[3009];
	local player = i3k_simple_entity1.new("simple_entity_0x000" .. simple_guid);
	if not player:Create(mcfg.desc, mcfg) then
		player = nil;
	end

	local actions = { "01attack01", "02attack02", "attackstand", "beiji01", "death", "deathloop", "run", "stand" };

	if player then
		--i3k_log("create simple entity guid = " .. simple_guid);

		local aidx = i3k_engine_get_rnd_u(1, #actions);

		player:SetPos(i3k_entine_move_difference(i3k_vec3_to_engine(pos)));
		player:Show(true, true);
		--player:Play(actions[aidx], -1);
		player:Play("attackstand", -1);

		self._splayer[simple_guid] = player;
	end

	return simple_guid;
end

function i3k_demo:ReleaseSimplePlayer(idx)
	local player = self._splayer[idx];
	if player then
		player:Release();

		self._splayer[idx] = nil;
	end
end

function i3k_demo:ReleaseAllSimplePlayer()
	for k, v in pairs(self._splayer) do
		v:Release();
	end
	self._splayer = { };
end

function i3k_demo:CreateMonster(pos)
	if self._monster then
		self._monster:Release();
		self._monster = nil;
	end

	local SMonster = require("logic/entity/i3k_monster");

	local monster = SMonster.i3k_monster.new(i3k_gen_entity_guid_new(SMonster.i3k_monster.__cname, i3k_gen_entity_guid()));
	if monster:Create(60101, false) then
		--i3k_log("create monster success");
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
		monster:Birth(i3k_world_pos_to_logic_pos(pos));
		monster:Show(true, true, 100);
		monster:SetGroupType(eGroupType_E);
		monster:SetFaceDir(0, 0, 0);
	else
		--i3k_log("create monster failed");
		monster:Release();
		monster = nil;
	end
	self._monster = monster;
end

function i3k_demo:ReleaseMonster()
	if self._monster then
		self._monster:Release();
		self._monster = nil;
	end
end



function i3k_demo:commentFunctions()
	--[[
	if self._player then
		local hero = self._player:GetHero();
		if hero then
			hero:DodgeSkill();
		end
	end
	]]

	--[[
	if self._player then
		local hero = self._player:GetHero();

		self:CreateSimplePlayer(hero._curPosE);
	end
	]]

	--g_i3k_mmengine:PlaySceneAni("scene/map/a/aa.mani");

	--[[
	if self._player then
		self._player:MoveTo(i3k_vec3(52.49462890625, 9.1641836166382, 23.056449890137));
	end
	]]

	--[[
	if self._player then
		local hero = self._player:GetHero();
		if hero then
			if entity_is_playing then
				entity_is_playing = false;
				--hero._entity:Stop();
			else
				entity_is_playing = true;
				--hero._entity:Play();
			end
			hero._entity:EnableRender(entity_is_playing);
		end
	end
	]]

	--[[
	if i3k_game_is_pause() then
		i3k_game_resume();
	else
		i3k_game_pause();
	end

	]]

	--[[
	local co = coroutine.create(
		function()
			for k = 1, 100000 do
				if k % 20 == 0 then
					coroutine.yield();
				end
				i3k_log("xxxxxx");
			end
		end
	);
	coroutine.resume(co);
	]]

	--[[
	i3k_enable_render_effect = not i3k_enable_render_effect;
	g_i3k_mmengine:EnableEffectRender(i3k_enable_render_effect);
	]]

	--test_move = not test_move;

	--[[
	local scene = self._scenes[self._curScene];
	if scene then
		local grids = g_i3k_game_handler:CheckRes(20);

		local XML = require("i3k_xml");

		local parser = XML.i3k_xml_parser.new();

		local profile_n = XML.i3k_xml_node.new("profile");

		profile_n:AddProperty("scene", scene.path);
		profile_n:AddProperty("grids", grids:size());

		for k1 = 1, grids:size() do
			local grid = grids[k1 - 1];
			local descs = grid.mDescTbl;

			local grid_n = XML.i3k_xml_node.new("grid");
			grid_n:AddProperty("x", grid.mX);
			grid_n:AddProperty("z", grid.mZ);
			grid_n:AddProperty("count", descs:size());

			for k2 = 1, descs:size() do
				local desc = descs[k2 - 1];

				i3k_log("checking count = " .. desc.mCount .. " size =(" .. desc.mSize.x .. ", " .. desc.mSize.y .. ") name = " .. desc.mName .. " path = " .. desc.mPath);

				local desc_n = XML.i3k_xml_node.new("desc");
				desc_n:AddProperty("count", desc.mCount);
				desc_n:AddProperty("size", "(" .. desc.mSize.x .. ", " .. desc.mSize.y .. ")");
				desc_n:AddProperty("name", desc.mName);
				desc_n:AddProperty("path", desc.mPath);

				grid_n:AddChild(desc_n);
			end
			profile_n:AddChild(grid_n);
		end

		parser:Save(profile_n, "profile_" .. scene.path .. ".xml");
	end
	]]
end

local i3k_capture_players = { };
function i3k_demo:CreateCapturePlayer(id, pos, scale)
	local SEntity = require("logic/entity/i3k_hero");
	local entity = SEntity.i3k_hero.new(i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, id), true);
	entity:SetSyncCreateRes(true);
	if not entity:Create(2, "[" .. id .. "]", 1, 57, 9, 99, { }, true, false) then
		entity = nil;
	end
	if entity then
		--entity:AttachCamera(self:GetMainCamera());
		entity:SetFaceDir(0, 90, 0);
		entity:SetHittable(false);
		entity:Play(i3k_db_common.engine.defaultStandAction, -1);
		entity:AddAiComp(eAType_IDLE);
		entity:SetPos(i3k_world_pos_to_logic_pos(pos), true);
		entity:Show(true, true);
		entity:SetScale(scale);
		--entity._entity:EnableOccluder(false);
		table.insert(i3k_capture_players, entity);
	end
end
function i3k_demo:ReleaseCapturePlayers()
	for _, v in ipairs(i3k_capture_players) do
		v:Release();
	end
	i3k_capture_players = { };
end
function i3k_demo:TestMove()
	if self._player then
		self._player:MoveTo(self._targetPos);
	end
end
local entity_is_playing = true;
local coroutine_hdr = nil;
local i3k_enable_render_effect = true;
function i3k_demo:getFactionPhotoCount()
	return 56
end
-- 帮派合照
function i3k_demo:testFactionPhoto()
	if i3k_get_engine_version() < 1001 then
		return;
	end
	g_i3k_ui_mgr:PopupTipMessage("开始生成合照");
	g_i3k_coroutine_mgr:StartCoroutine(function()
		local index = 1
		local count = self:getFactionPhotoCount()
		local posCfg = g_i3k_db.i3k_db_get_faction_photo_positions(count)
		for i = -50, 50 do
			for k = 1, 5 do
				local postionCfg = posCfg[index]
				if postionCfg and count >= index then
					local id = 9999 + i * 5 + k
					local pos = postionCfg.position --{ x = 28 + i * 1.5, y = 18, z = -140 + k * 3.5 }
					local scale = postionCfg.scale
					self:CreateCapturePlayer(id, pos, scale);
				end
				index = index + 1
			end
			g_i3k_coroutine_mgr.WaitForNextFrame();
			g_i3k_ui_mgr:PopupTipMessage("正在生成合照... ...");
		end
		g_i3k_coroutine_mgr.WaitForNextFrame();
		local cfg = Engine.MCaptureConfig();
		cfg.mWidth		= 1920; -- 越大 精度越高  最大不超过2048
		cfg.mHeight		= 1080; -- 最终图片的高度（2000左右就会出现摄像机视角不够了）
		cfg.mViewSize	= 16; -- （渲染一块多少米）越小越窄 精度越高   调节视角距离，摄像机距离第一排的距离
		cfg.mSceneSize	= 60; -- 场景宽度，如果每个人宽3米，50个人一排，那么估算一下需要150多一点，这个值控制两边留白多少，小于30就不好使了
		cfg.mAngle		= -10; -- 俯仰角，根据mY 对应微调
		cfg.mX			= 28;  -- 摄像机左右移动距离，28为中心
		cfg.mY			= 23; -- 这三个参数是摄像机的坐标（上下平移摄像机，21为中心）
		cfg.mZ			= -145; -- 140为中心位置
		-- 最终图片的尺寸为 mHeight * (mWidth *  (mSceneSize / mViewSize + 1) )
		local view = Engine.MCaptureView();
		view:Capture("capture", cfg);
		local fileName = view:GetFileName()
		view:Cleanup();
		self:ReleaseCapturePlayers();
		g_i3k_ui_mgr:PopupTipMessage("合照创建完成"..fileName);
	end)
end
function i3k_demo:TestFunc()
	self:commentFunctions()
	self:testFactionPhoto()
end

function i3k_demo:OnKeyDown(handled, key)
	BASE.OnKeyDown(self, handled, key);

	if self._player then
		self._player:OnKeyDown(handled, key);
	end

	return 0;
end

function i3k_demo:OnKeyUp(handled, key)
	BASE.OnKeyUp(self, handled, key);

	local scene = self._scenes[self._curScene];

	if key == 59 then -- F1
		--self._obstacle = g_i3k_mmengine:AddDynObstacle(i3k_vec3_to_engine(scene.spawn_pos), 10, 2, 50, i3k_vec3_to_engine(i3k_vec3(0, (90 / 180) * math.pi, 0)));
	elseif key == 60 then -- F2
		--self:RmvObstacle();
	elseif key == 61 then -- F3
	elseif key == 62 then -- F4
		--[[
		local states = string.split(g_i3k_game_handler:GetRenderState(), ",")
		for k, v in ipairs(states) do
			g_i3k_ui_mgr:PopupTipMessage(Engine.A2UTF8(v));
		end
		]]
		g_i3k_ui_mgr:PopupTipMessage(g_i3k_game_handler:GetRenderState());
	elseif key == 63 then -- F5
		if self._player then
			local entity = self._player:GetHero();
			entity:Mount();
			entity:Play("stand", -1, false);

			local speed = entity:GetPropertyValue(ePropID_speed);
			entity:UpdateProperty(ePropID_speed, 1, speed * 2, true, false, true);
		end
	elseif key == 64 then -- F6
		if self._player then
			local entity = self._player:GetHero();
			entity:Unmount();
			entity:Play("stand", -1, false);

			local speed = entity:GetPropertyValue(ePropID_speed);
			entity:UpdateProperty(ePropID_speed, 1, speed * 0.5, true, false, true);
		end
	elseif key == 65 then -- F7
	elseif key == 2 then -- 1
		local entity = self._player:GetHero();
		if entity then
			local _pos = i3k_vec3_to_engine(i3k_vec3(entity._curPosE.x, entity._curPosE.y + 2.5, entity._curPosE.z));

			g_i3k_effect_mgr:SetImageEffect(14, _pos, "", "醉舞狂歌", 2);
		end
	elseif key == 3 then -- 2
		local entity = self._player:GetHero();
		if entity then
			local _pos = i3k_vec3_to_engine(i3k_vec3(entity._curPosE.x, entity._curPosE.y + 2.5, entity._curPosE.z));

			g_i3k_effect_mgr:SetImageEffect(1, _pos, "heal_",  "暴击+" .. i3k_engine_get_rnd_u(99, 9999), 2);
		end
	elseif key == 4 then -- 3
	elseif key == 5 then -- 4
	elseif key == 6 then -- 5
	elseif key == 7 then -- 6
	end

	if self._player then
		self._player:OnKeyUp(handled, key);
	end

	return 0;
end

function i3k_demo:RmvObstacle()
	if self._obstacle then
		g_i3k_mmengine:RmvDynObstacle(self._obstacle);
	end
	self._obstacle = nil;
end

function i3k_demo:OnHitGround(handled, x, y, z)
	BASE.OnHitGround(self, handled, x, y, z);

	if self._player then
		--[[
		local hero = self._player:GetHero();

		i3k_log("find path from ", i3k_format_pos(hero._curPosE), "to ", i3k_format_pos(i3k_vec3(x, y, z)));

		local paths = g_i3k_mmengine:FindPath(hero._curPosE, i3k_vec3_to_engine(i3k_vec3(x, y, z)));
		local size = paths:size();
		if size > 0 then
			i3k_log("found", size, "pos");

			for k = 0, size - 1 do
				local pos = paths[k];

				i3k_log("pos", k, "=", i3k_format_pos(pos));
			end
			--local pos = paths[size];
		end
		]]

		i3k_log("hit ground");

		self._player:OnHitGround(handled, x, y, z);
	end
end
