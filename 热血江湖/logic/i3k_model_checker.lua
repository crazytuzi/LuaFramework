----------------------------------------------------------------
--module(..., package.seeall)

local require = require;

local BASE = require("logic/i3k_base_logic").i3k_base_logic;


------------------------------------------------------
i3k_entity_ex = i3k_class("i3k_entity_ex");
function i3k_entity_ex:ctor(guid)
	self._id			= -1;
	self._entity		= Engine.MEntity(guid);
	self._guid			= guid;

	i3k_game_register_entity(guid, self);
end

function i3k_entity_ex:Create(name, cfg)
	self._name	= name;

	self:CreateResSync(cfg);

	return true;
end

function i3k_entity_ex:CreateResSync(mcfg)
	if mcfg and self._entity then
		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._resCreated	= 1;
			self._height		= mcfg.titleOffset;

			self._title = self:CreateTitle();
			if self._title.node then
				self._title.node:SetVisible(true);
				self._title.node:EnterWorld();

				self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
			end

			self._entity:SetActionBlendTime(0);

			self._entity:EnterWorld(false);
		end
	end
end

function i3k_entity_ex:Release()
	if self._entity then
		--self._entity:Release();
		self._entity = nil;
	end

	i3k_game_register_entity(self._guid, nil);
end

function i3k_entity_ex:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("entity_title_node_" .. self._guid) then
		title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, tonumber("0xffffffff", 16), self._name);
	else
		title.node = nil;
	end

	return title;
end

------------------------------------------------------
i3k_model_checker = i3k_class("i3k_model_checker", BASE)
function i3k_model_checker:ctor()
end

function i3k_model_checker:Create()
	BASE.Create(self);

	g_i3k_game_handler:SetWindowTitle("model_checker");

	local loaded = function()
		self:OnMapLoaded();
	end
	self:LoadMap("test", Engine.SVector3(0, 0, 0):ToEngine(), "default", loaded, 0);

	return true;
end

function i3k_model_checker:OnUpdate(dTime)
	local ret = BASE.OnUpdate(self, dTime);

	if self._player then
		self._player:OnUpdate(dTime, true);
	end

	if self._npc then
		for k, v in ipairs(self._npc) do
			--v:OnUpdate(dTime, true);
		end
	end

	return true;
end

function i3k_model_checker:OnLogic(dTick)
	local ret = BASE.OnLogic(self, dTick);

	if self._player then
		self._player:OnLogic(dTick, true);
	end

	if self._npc then
		for k, v in ipairs(self._npc) do
			--v:Onlogic(dTick, true);
		end
	end

	return ret;
end

function i3k_model_checker:OnMapLoaded()
	self:CreatePlayer(i3k_vec3(0, 0, 0));
	self:CreateNpc();

	g_i3k_game_handler:EnableObjHitTest(false, true);

	-- g_i3k_ui_mgr:OpenUI(eUIID_Yg);

	return true;
end

function i3k_model_checker:CreatePlayer(pos)
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
	if not entity:Create(1, "demo", 1, 1, 31, 100, { }, true, false) then
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

		entity:UpdateProperty(ePropID_speed, 1, 2000, true, false, true);

		entity:SetPos(i3k_world_pos_to_logic_pos(pos), true);
		entity:Show(true, true, 100000);

		entity:SetVehicleInfo("model/player/rxjh/zuoqi/ma/ma.spr", "HS_zuoqi", "CS_zuoqi");

		player:SetHero(entity);
	end
	self._player = player;
end

function i3k_model_checker:ReleasePlayer()
	if self._player then
		self._player:Release();
		self._player = nil;
	end
end

local npc_guid = 1;
function i3k_model_checker:CreateNpc()
	self._npc = { };

	local x = -120;
	local z = -120;
	local w = 10;
	local n = 0;

	for k, v in pairs(i3k_db_models) do
		local npc = i3k_entity_ex.new("simple_entity_0x000" .. npc_guid);
		if not npc:Create(v.desc, v) then
			npc = nil;
		end

		if npc then
			npc_guid = npc_guid + 1;

			n = n + 1;

			if n % 12 == 0 then
				z = z + w;
				x = -120;
			else
				x = x + w;
			end

			npc._entity:SetPosition(i3k_vec3_to_engine(i3k_vec3(x, 0.1, z)));
			npc._entity:FadeIn(500, true);
			npc._entity:SelectAction("stand", -1);
			npc._entity:Play();

			table.insert(self._npc, npc);
		end
	end
end

function i3k_model_checker:OnKeyDown(handled, key)
	BASE.OnKeyDown(self, handled, key);

	if self._player then
		self._player:OnKeyDown(handled, key);
	end

	return 0;
end

function i3k_model_checker:OnKeyUp(handled, key)
	BASE.OnKeyUp(self, handled, key);

	if key == 62 then -- F4
		g_i3k_ui_mgr:PopupTipMessage(g_i3k_game_handler:GetRenderState());
	end

	if self._player then
		self._player:OnKeyUp(handled, key);
	end

	return 0;
end

function i3k_model_checker:OnHitGround(handled, x, y, z)
	BASE.OnHitGround(self, handled, x, y, z);

	if self._player then
		self._player:OnHitGround(handled, x, y, z);
	end
end
