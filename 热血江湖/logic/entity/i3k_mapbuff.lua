------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity");
local BASE = i3k_entity;

local releaseTime = 5
------------------------------------------------------
eSMapBuffBase = 0
eSMapBuffActive = 1
eSMapBuffWait = 2
eSMapBuffFly = 3
------------------------------------------------------
i3k_mapbuff = i3k_class("i3k_mapbuff", BASE);

function i3k_mapbuff:ctor(guid)
	self._entityType	= eET_MapBuff;
	self._showmode		= true
	self._cfg		= nil;
	self._buffcfg		= nil;
	self._status		= eSMapBuffBase
	self._PVPColor		= -2;
	self._tempPos		= nil;
	self._create		= false;
	self._Deny = 0;
end

function i3k_mapbuff:Create(id,mapbuffid, agent)
	local gcfg = i3k_db_mapbuff_base[id];
	if not gcfg then
		return false;
	end
	local bcfg
	if gcfg.buffType == 1 then
	 	bcfg = i3k_db_buff[gcfg.buffID]
	elseif gcfg.buffType == 2 then
		bcfg = i3k_db_team_buff[gcfg.buffID]
	end
	if not bcfg then
		return false;
	end

	--self:CreateActor();

	self._gid	= mapbuffid;
	self._gcfg	= gcfg;
	self._buffcfg	= bcfg;
	self._entityType	= eET_MapBuff;
	self._name	= bcfg.note or bcfg.name;
	self._effectID	= -1
	--self:CreateRes(gcfg.modelID);
	local ecfg = i3k_db_effects[gcfg.modelID];
	if ecfg then
		self._effectID = g_i3k_actor_manager:CreateSceneNode(ecfg.path, "Mapbuff_" .. self._guid);
		if self._effectID ~= -1 then
			self._create = true;
			g_i3k_actor_manager:EnterScene(self._effectID);
			local pos = { x = self._curPosE.x, y = self._curPosE.y, z = self._curPosE.z };
			g_i3k_actor_manager:SetLocalTrans(self._effectID, Engine.SVector3(pos.x, pos.y, pos.z));
			g_i3k_actor_manager:SetLocalScale(self._effectID, ecfg.radius);
			g_i3k_actor_manager:Play(self._effectID, 1);
		end
	end
	self._status = eSMapBuffActive

	return true;
end

function i3k_mapbuff:IsDestory()
	return not self:IsValid();
end

function i3k_mapbuff:ValidInWorld()
	return true;
end

function i3k_mapbuff:SetTempPos(Pos)
	self._tempPos = Pos
end
function i3k_mapbuff:SetPos(Pos)
	if not Pos then
		Pos = self._tempPos
	end
	BASE.SetPos(self, Pos);
	if self:IsValid() then
		if self._effectID and self._curPosE then
			g_i3k_actor_manager:SetLocalTrans(self._effectID, self._curPosE);
		end
	end
end

function i3k_mapbuff:OnUpdate(dTime)
end

function i3k_mapbuff:IsValid()
	if self._create then
		return self._effectID and self._effectID > -1;
	else
		return true;
	end
end

function i3k_mapbuff:OnLogic(dTick)
	if not self:IsInLeaveCache() and not self._showmode then
		self._showmode = true
		self:Show(true);
	end

	if self:IsInLeaveCache() then
		self:UpdateCacheTime(dTick * i3k_engine_get_tick_step());
		self:Show(false);
		self._showmode = false;
		if self:GetLeaveCacheTime() > releaseTime then
			local world = i3k_game_get_world();
			if world then
				local guid = string.split(self._guid, "|")								
				local RoleID = tonumber(guid[2])
				local MapBuff = world._mapbuffs[RoleID];
				if MapBuff then
					--world._mapbuffs[RoleID] = nil
					world:RmvEntity(MapBuff);
					MapBuff:Release()
					self._showmode = true
				end
			end
			self:ResetLeaveCache();
		end
	end

	if self:IsValid() and self:GetStatus() == eSMapBuffActive then
		--添加物品拾取判定，暂时加在这里 TODO
		local logic	= i3k_game_get_logic();
		local player	= logic:GetPlayer();
		if player then
			local Pos = player:GetHeroPos();
			local dist = i3k_vec3_sub1(Pos, self._curPos);
			local MapAutoRange = 200
			local mapID = g_i3k_game_context:GetWorldMapID()
			-- local PickDeny = i3k_db_common["droppick"].MapbuffAutoRange
			local PickDeny = i3k_db_dungeon_base[mapID] and i3k_db_dungeon_base[mapID].buffAutoRange
			if PickDeny then
				MapAutoRange = PickDeny
			end
			if MapAutoRange > i3k_vec3_len(dist) or MapAutoRange < 0 then
				self:WaitRequire();
				self._Deny = 0;
				local hero = i3k_game_get_player_hero()
				if hero and not hero:GetIsGuard() then
					local isMission, missionType = g_i3k_game_context:IsInMissionMode()
					if isMission and missionType == g_TASK_TRANSFORM_STATE_SKULL then
					else
						i3k_log("role_pickup_mapbuff")
						local pickup_mapbuff_req = i3k_sbean.role_pickup_mapbuff.new()
						pickup_mapbuff_req.mapBuffID = self._gid
						i3k_game_send_str_cmd(pickup_mapbuff_req)
					end
				end
			end
		end
	end

	if self:IsValid() and self:GetStatus() == eSMapBuffFly then
		local MapBuffAutoPickDeny = 330
		if self._Deny > MapBuffAutoPickDeny then
			self:OnSelected(true);
			self:ShowTitleNode(false);
		end
		self._Deny = self._Deny + dTick * i3k_engine_get_tick_step();
	end
	if g_i3k_game_context:GetMapBuffFlagInPracticeGate(self:GetGuidID()) and self._create and self:GetStatus() == eSMapBuffWait then
		self:Fly()
		g_i3k_game_context:RemoveMapBuffFlagInPracticeGate(self:GetGuidID())
	end
end

function i3k_mapbuff:WaitRequire()
	self._status = eSMapBuffWait;
end

function i3k_mapbuff:Fly()
	self._status = eSMapBuffFly;
end

function i3k_mapbuff:GetStatus()
	return self._status;
end

function i3k_mapbuff:OnSelected(val)
	BASE.OnSelected(self, val);

	if self:GetStatus() == eSMapBuffFly then
		-----TODO 添加拾取并进行析构

		local logic = i3k_game_get_logic();
		local world = logic:GetWorld();
		if world then
			if not world._syncRpc then
				local player = logic:GetPlayer();
				if player then
					local hero = player:GetHero();
					if hero then
						if self._gcfg.affecttype == 0 then
							local BUFF = require("logic/battle/i3k_buff");
							local buff = BUFF.i3k_buff.new(nil, self._gcfg.buffID, self._buffcfg);
							if buff then
								hero:AddBuff(nil, buff);
							end
						elseif self._gcfg.affecttype == 1 then
							local BUFF = require("logic/battle/i3k_buff");
							local buff = BUFF.i3k_buff.new(nil, self._gcfg.buffID, self._buffcfg);
							if buff then
								hero:AddBuff(nil, buff);
							end
							local Mercenaries = player:GetMercenaries()
							for k,v in pairs(Mercenaries) do
								local BUFF = require("logic/battle/i3k_buff");
								local buff = BUFF.i3k_buff.new(nil, self._gcfg.buffID, self._buffcfg);
								if buff then
									v:AddBuff(nil, buff);
								end
							end
						end
					end
				end	
			end
		end
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
end

function i3k_mapbuff:Show()
	if self:IsValid() then
		g_i3k_actor_manager:SetVisible(self._effectID, true,true);
	end
end

function i3k_mapbuff:hide()
	if self:IsValid() then
		g_i3k_actor_manager:SetVisible(self._effectID, false,true);
	end
end

function i3k_mapbuff:Release()
--[[	if self._entity then
		self._entity:Release();
		self._entity = nil;
	end--]]

	self._text_pool:Clear();

	self._resCreated = 1;

	if self._effectID and self._effectID > -1 then
		g_i3k_actor_manager:LeaveScene(self._effectID);
		g_i3k_actor_manager:ReleaseSceneNode(self._effectID);
		self._effectID = -1
	end
end

function i3k_mapbuff:GetGuidID()
	local guid = string.split(self._guid, "|")
	return tonumber(guid[2])
end
