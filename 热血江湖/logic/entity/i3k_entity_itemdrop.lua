------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity_itemdrop_def");
require("logic/entity/i3k_entity");
------------------------------------------------------
local BASE = i3k_entity;
i3k_entity_itemdrop = i3k_class("i3k_entity_itemdrop",BASE);
------------------------------------------------------
local l_colorTable =
{
	--以下是标准颜色码
	white   = "FFFFFFFF",
	black   = "FF000000",
	red     = "FFFF0000",
	green   = "FF00FF00",
	blue    = "FF0000FF",
	yellow  = "FFFFFF00",
	purple  = "FFFF00FF",
	cyan    = "FF00FFFF",

	--q开头的，是白绿蓝紫橙5个品质的颜色码
	qwhite  = "FFCCE2DD",
	qgreen  = "FF5DD13D",
	qblue   = "FF30B4FF",
	qpurple = "FFCD81FF",
	qorange = "FFFFCD3A",
}

function i3k_entity_itemdrop:ctor(guid)
	self._entityType = eET_ItemDrop;
	self:CreateActor();
end

function i3k_entity_itemdrop:Create(gid, id, count, name, color, itemId)
	self._gid		= gid;
	self._iid		= id;
	self._count		= count;
	self._color		= color;
	self._itemId 	= itemId;

	local mcfg = i3k_db_models[id];
	if mcfg then
		self._name		= mcfg.desc;
		self._dropEff	= mcfg.dropEff;
		if name then
			self._name = name;
		end

		if self._entity:CreateHosterModel(mcfg.path, string.format("itemdrops_%s", self._gid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);

			self._title = self:CreateTitle();
			if self._title.node then
				self._title.node:SetVisible(true);
				self._title.node:EnterWorld();

				self._entity:AddTitleNode(self._title.node:GetTitle(), mcfg.titleOffset);
			end

			self._entity:EnterWorld(false);
		end
	end

	self._linked = eSItemDropLocked;
	self._Deny = 0;
	self._properties = self:InitProperties();
	local world = i3k_game_get_world();
	self._itemdropAutoRange = i3k_db_common.droppick and i3k_db_common.droppick.ItemDropAutoRange
	
	if world then
		self._itemdropAutoRange = world._cfg.ItemDropAutoRange
	end

	return true;
end

function i3k_entity_itemdrop:CreateTitle()
	local title = { };

	local _colors =
	{
		tonumber("0x"..l_colorTable.qwhite,		16),
		tonumber("0x"..l_colorTable.qgreen,		16),
		tonumber("0x"..l_colorTable.qblue,		16),
		tonumber("0x"..l_colorTable.qpurple,	16),
		tonumber("0x"..l_colorTable.qorange,	16),
	};

	local _T = require("logic/entity/i3k_entity_title");
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("drop_item_title_node_" .. self._guid) then
		local _name = self._name;
		if self._count > 1 then
			_name = self._name .. "*" .. self._count;
		end

		title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, _colors[self._color] or tonumber("0xffffffff", 16), _name);
	else
		title.node = nil;
	end

	return title;
end

function i3k_entity_itemdrop:InitProperties()
	local properties = nil;

	return properties;
end

function i3k_entity_itemdrop:IsDestory()
	return self._entity == nil;
end

function i3k_entity_itemdrop:Release()
	if self._entity then
		local player = i3k_game_get_player()
		local world = i3k_game_get_world()
		if player and (world._mapType == g_FIELD or world._mapType == g_FACTION_TEAM_DUNGEON or world._mapType == g_ANNUNCIATE) then
			if player._pickup.cacheItems and player._pickup.cacheItems[self._itemId] then
				player._pickup.cacheItems[self._itemId] = player._pickup.cacheItems[self._itemId] - self._count
				if player._pickup.cacheItems[self._itemId] == 0 then
					player._pickup.cacheItems[self._itemId] = nil
				end
			end
		end
		self._entity:Release();

		self._entity = nil;
	end
	BASE.Release(self);
end

function i3k_entity_itemdrop:ValidInWorld()
	return true;
end

function i3k_entity_itemdrop:OnUpdate(dTime)
end

function i3k_entity_itemdrop:OnLogic(dTick)
	--BASE.OnLogic(self, dTick);

	--self._timeTick = self._timeTick + dTick * i3k_db_common.engine.tickStep;
	local world = i3k_game_get_world()
	if world and (world._mapType ~= g_FIELD and world._mapType ~= g_FACTION_TEAM_DUNGEON and world._mapType ~= g_ANNUNCIATE) then
		if self._entity and self:GetStatus() == eSItemDropActive then
			--添加物品拾取判定，暂时加在这里 TODO
			local logic		= i3k_game_get_logic();
			local player	= logic:GetPlayer();
			if player then
				local Pos = player:GetHeroPos();
				local dist = i3k_vec3_sub1(Pos, self._curPos);
				local ItemDropAutoRange = 200
				
				if self._itemdropAutoRange then
					ItemDropAutoRange = self._itemdropAutoRange
				end
				if ItemDropAutoRange > i3k_vec3_len(dist) then
					self:WaitRequire();
					self._Deny = 0;
					
					player:AddPickup(self._gid, self._itemId, self._count);
				end
			end
		end
	end

	if self._entity and self:GetStatus() == eSItemDropFly then
		local ItemDropAutoPickDeny = 330
		local PickDeny = i3k_db_common["droppick"].ItemDropAutoPickDeny
		if PickDeny then
			ItemDropAutoPickDeny = PickDeny
		end
		if self._Deny > PickDeny then
			self:deleteItem(true);
			self:ShowTitleNode(false);
		end
		self._Deny = self._Deny + dTick * i3k_engine_get_tick_step();
	end
end

function i3k_entity_itemdrop:deleteItem(val)
	i3k_entity.OnSelected(self, val);
	self._selected = val;
	self:Release()
	local world = i3k_game_get_world()
	world:RmvEntity(self);
	local hero = i3k_game_get_player_hero()
	if hero and hero._entity and self._dropEff then
		local ecfg = i3k_db_effects[self._dropEff];
		if ecfg then
			local info = Engine.AttackEventInfo();
				info.mExternalId = i3k_gen_attack_effect_guid();
				info.mAssetFileName = ecfg.path;--"effect/rxjh_gongjishijian/diaoluo_feixing.ate";
				info.mHS = "";
				info.mOffset = 0.0;
				info.mScatter = true;
				info.mDelayTime = 0.0;
				info.mMaxLifeTime = 20.0;
				info.mEmitNodeName = "";
				info.mEmitPosition = i3k_vec3_to_engine(self._curPosE);
				info.mTargetsNodeName:push_back(hero._entity:GetName());
				info.mAttackEffectScale = 1.0;
				info.mCustomVelocity = 10.0;
				info.mCustomAcceleration = 0.0;
			g_i3k_mmengine:PlayAttackEffect(info);
		end
	end
end

function i3k_entity_itemdrop:OnSelected(val)
	
end

function i3k_entity_itemdrop:Linked()
	self._linked = eSItemDropLinked;
end

function i3k_entity_itemdrop:Actived()
	self._linked = eSItemDropActive;
end

function i3k_entity_itemdrop:WaitRequire()
	self._linked = eSItemDropWaitRequire;
end

function i3k_entity_itemdrop:Fly()
	self._linked = eSItemDropFly;
end

function i3k_entity_itemdrop:GetStatus()
	return self._linked;
end

function i3k_entity_itemdrop:TitleColorTest()
		
end

function i3k_entity_itemdrop:GetGuidID()
	local guid = string.split(self._guid, "|")
	return tonumber(guid[2])
end
