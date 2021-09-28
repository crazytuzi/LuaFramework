------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_monster").i3k_monster_base;

------------------------------------------------------
i3k_escort_car = i3k_class("i3k_escort_car", BASE);
function i3k_escort_car:ctor(guid)
	self._entityType	= eET_Car;
	self._hoster		= nil;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._deadTimeLine	= -1;
	self._isReplaceCar	= false;
end

function i3k_escort_car:Create(id, curHP, state, maxHP,_,skin)
	local cfg = i3k_db_escort_car[id];
	if not cfg then
		return false;
	end

	if curHP then
		cfg.curHP = curHP
	end

	if maxHP then
		cfg.maxHP = maxHP
	end
	
	local skinId = skin or 1
	local skinConfig = i3k_db_escort_skin[skinId]
	cfg.modelID = skinConfig["moduleId" .. id]
	cfg.damage_model = skinConfig["breakModuleId" .. id]

	self._carState = state

	local name = string.format("%s%s",g_i3k_game_context:GetRoleName(),"的镖车")
	return self:CreateFromCfg(id, name, cfg, 1, { }, false, nil);
end

function i3k_escort_car:Release()
	BASE.Release(self);
end

function i3k_escort_car:OnAsyncLoaded()
	BASE.OnAsyncLoaded(self);

	if self._carState ~= 0 then
		self._isReplaceCar = true;
	end
end

function i3k_escort_car:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("car_title_node_" .. self._guid) then
		title.name	= title.node:AddTextLable(-0.5, 1, -0.5, 0.5, tonumber("0xffffffff", 16), self._name);
		title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
	else
		title.node = nil;
	end

	return title;
end

function i3k_escort_car:OnInitBaseProperty(props)
	local properties = i3k_entity.OnInitBaseProperty(self, props);

	properties[ePropID_maxHP]			= i3k_entity_property.new(self, ePropID_maxHP,			0);
	properties[ePropID_defN]			= i3k_entity_property.new(self, ePropID_defN,			0);
	properties[ePropID_ctr]				= i3k_entity_property.new(self, ePropID_ctr,			0);
	properties[ePropID_tou]				= i3k_entity_property.new(self, ePropID_tou,			0);
	properties[ePropID_defC]			= i3k_entity_property.new(self, ePropID_defC,			0);
	properties[ePropID_defW]			= i3k_entity_property.new(self, ePropID_defW,			0);
	

	properties[ePropID_maxHP]:Set(self._cfg.maxHP, ePropType_Base);
	properties[ePropID_defN]:Set(self._cfg.defend, ePropType_Base);
	properties[ePropID_ctr]:Set(self._cfg.avoid, ePropType_Base);
	properties[ePropID_tou]:Set(self._cfg.ren_xing, ePropType_Base);
	properties[ePropID_defC]:Set(self._cfg.qi_gong, ePropType_Base);
	properties[ePropID_defW]:Set(self._cfg.shen_bing, ePropType_Base);
	properties[ePropID_speed]:Set(i3k_db_escort.escort_args.speed, ePropType_Base);

	return properties;
end

function i3k_escort_car:OnPropUpdated(id, value)
	if id == ePropID_speed then
		return true;
	end

	BASE.OnPropUpdated(self, id, value);
end

function i3k_escort_car:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	self._timetick = self._timetick + dTick * i3k_engine_get_tick_step();
	
	return true;
end

function i3k_escort_car:Birth(pos)
	self._birthPos = pos;

	self:SetPos(pos);
end

function i3k_escort_car:Bind(hero)
	self._hoster = hero;
end

function i3k_escort_car:GetHoster()
	return self._hoster;
end

function i3k_escort_car:GetFollowTarget()
	if not self._hoster then
		return nil;
	end
	
	local mapID = g_i3k_game_context:GetEscortCarLocation()
	if mapID ~= g_i3k_game_context:GetWorldMapID() then
		return nil
	end

	local dist = i3k_vec3_len(i3k_vec3_sub1(self._curPos, self._hoster._curPos));
	if dist < 800 then
		return nil
	end
	if dist > i3k_db_escort.escort_args.distance then
		return nil;
	end
	
	return self._hoster;
end

function i3k_escort_car:OnSelected(val)
	BASE.OnSelected(self, val);
	if self:GetEntityType() == eET_Car then
		if val == false then
			g_i3k_game_context:OnCancelSelectHandler()
			return;
		end
		local maxhp = self:GetPropertyValue(ePropID_maxHP)
		local curhp = self:GetPropertyValue(ePropID_hp)
		local buffs = {}
		for k,v in pairs (self._buffs) do
			buffs[v._id] = v._endTime-v._timeLine
		end
		g_i3k_game_context:OnSelectEscortCarHandler(self._cfg.id, self._lvl, self._name, curhp, maxhp, buffs, true)
	end
end

function i3k_escort_car:UpdateCarState(state)
	self._carState = state;
	if self:IsResCreated() then
		self._isReplaceCar = true;
	end
end

