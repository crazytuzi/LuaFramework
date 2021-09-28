------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity_itemdrop_def");
require("logic/entity/i3k_entity");
------------------------------------------------------
local BASE = i3k_entity;
i3k_ghost_fragment = i3k_class("i3k_ghost_fragment",BASE);
------------------------------------------------------
function i3k_ghost_fragment:ctor(guid)
	self._entityType = eET_GhostFragment;
	self._effectID	= -1
	self._Deny = 0;
end

function i3k_ghost_fragment:Create(id, guid)
	self._id = id
	self._guid = guid
	self._name = i3k_db_catch_spirit_fragment[id].name
	self._effectID	= -1
	local ecfg = i3k_db_effects[i3k_db_catch_spirit_fragment[id].dropEffectId];
	if ecfg then
		self._effectID = g_i3k_actor_manager:CreateSceneNode(ecfg.path, "ghost_fragment_" .. self._guid);
		if self._effectID ~= -1 then
			g_i3k_actor_manager:EnterScene(self._effectID);
			local pos = {x = self._curPosE.x, y = self._curPosE.y, z = self._curPosE.z};
			g_i3k_actor_manager:SetLocalTrans(self._effectID, Engine.SVector3(pos.x, pos.y, pos.z));
			g_i3k_actor_manager:SetLocalScale(self._effectID, ecfg.radius);
			g_i3k_actor_manager:Play(self._effectID, 1);
		end
	end
	return true;
end

--[[
function i3k_ghost_fragment:CreateTitle()
	local title = { };
	local _T = require("logic/entity/i3k_entity_title");
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("ghost_fragment_title_node_" .. self._guid) then
		title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, tonumber("0xffffffff", 16), self._name);
	else
		title.node = nil;
	end
	return title;
end
--]]
function i3k_ghost_fragment:Release()
	self._text_pool:Clear();
	self._resCreated = 1;
	if self._effectID and self._effectID > -1 then
		g_i3k_actor_manager:LeaveScene(self._effectID);
		g_i3k_actor_manager:ReleaseSceneNode(self._effectID);
		self._effectID = -1
	end
end

function i3k_ghost_fragment:ValidInWorld()
	return true;
end

function i3k_ghost_fragment:OnUpdate(dTime)
end

function i3k_ghost_fragment:OnLogic(dTick)
	if self._effectID then
		local PickDeny = i3k_db_common.droppick.ItemDropAutoPickDeny
		self._Deny = self._Deny + dTick * i3k_engine_get_tick_step();
		if self._Deny > 1500 then
			self:deleteItem()
		end
	end
end

function i3k_ghost_fragment:deleteItem()
	local world = i3k_game_get_world()
	world:RmvEntity(self);
	local logic = i3k_game_get_logic();
	local player = logic:GetPlayer();
	if player then
		local info = Engine.AttackEventInfo();
		info.mExternalId = i3k_gen_attack_effect_guid();
		info.mAssetFileName = "effect/rxjh_gongjishijian/diaoluo_feixing.ate";
		info.mHS = "";
		info.mOffset = 0.0;
		info.mScatter = true;
		info.mDelayTime = 0.0;
		info.mMaxLifeTime = 20.0;
		info.mEmitNodeName = "";
		info.mEmitPosition = i3k_vec3_to_engine(self._curPosE);
		info.mTargetsNodeName:push_back(player:GetHero()._entity:GetName());
		info.mAttackEffectScale = 1.0;
		info.mCustomVelocity = 10.0;
		info.mCustomAcceleration = 0.0;
		g_i3k_mmengine:PlayAttackEffect(info);
	end
	self:Release()
end

function i3k_ghost_fragment:OnSelected(val)
	
end

function i3k_ghost_fragment:TitleColorTest()
	
end

function i3k_ghost_fragment:GetGuidID()
	return self._guid
end
