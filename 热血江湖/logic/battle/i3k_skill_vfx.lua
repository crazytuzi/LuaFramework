----------------------------------------------------------------
--module(..., package.seeall)

local require = require

require("i3k_global");


------------------------------------------------------
eVFXBegin			= 1;
eVFXStartSpell		= 2;
eVFXStartCharge		= 3;
eVFXStartAttack		= 4;
eVFXStartBehavior	= 5;
eVFXEndBehavior		= 6;
eVFXDamage			= 7;
eVFXEnd				= 8;

local skill_vfx_effect_id = 0;
local GenerateEffectID = function()
	local id = skill_vfx_effect_id;

	skill_vfx_effect_id = (skill_vfx_effect_id + 1) % 99999;

	return id;
end

local TIMER = require("i3k_timer");
i3k_delay_reset_vfx_timer = i3k_class("i3k_delay_reset_vfx_timer", TIMER.i3k_timer);

function i3k_delay_reset_vfx_timer:ctor(tickLine, autoRelease, reset)
	self._reset = reset;
end

function i3k_delay_reset_vfx_timer:Do(args)
	if self._reset then
		self._reset();
	end

	return true;
end


------------------------------------------------------
i3k_skill_vfx_impl = i3k_class("i3k_skill_vfx_impl");
function i3k_skill_vfx_impl:ctor(mgr)
	self._mgr		= mgr;
	self._turnOn	= false;
	self._effects	= { };
end

function i3k_skill_vfx_impl:Create(cfg)
	if cfg.stype <= 0 then
		return false;
	end

	self._cfg		= cfg;
	self._trigger	= nil;
	self._update	= nil;

	if cfg.stype == 1 then
		self._trigger = function(entity, targets)
			entity:Show(true, true, cfg.args[1]);
		end
	elseif cfg.stype == 2 then
		self._trigger = function(entity, targets)
			entity:Show(false, true, cfg.args[1]);
		end
	elseif cfg.stype == 3 then
		self._trigger = function(entity, targets)
			entity:SetScale(cfg.args[1]);
		end
	elseif cfg.stype == 4 then
	elseif cfg.stype == 5 then
		self._trigger = function(entity, targets)
			if not entity:IsDead() then
				local ecfg = i3k_db_effects[cfg.args[1]];
				if ecfg then
					local effectID = g_i3k_actor_manager:CreateSceneNode(ecfg.path, "skill_vfx_effect_" .. entity._guid .. "_" .. GenerateEffectID());
					if effectID ~= -1 then
						g_i3k_actor_manager:EnterScene(effectID);

						local pos = { x = entity._curPosE.x, y = entity._curPosE.y, z = entity._curPosE.z };
						if cfg.args[4] == 2 and targets and targets[1] then
							pos = { x = targets[1]._curPosE.x, y = targets[1]._curPosE.y, z = targets[1]._curPosE.z };
						elseif cfg.args[4] == 3 and targets then
							pos = { x = 0, y = 0, z = 0 };
							for k, v in pairs(targets) do
								pos.x = pos.x + v._curPosE.x;
								pos.z = pos.z + v._curPosE.z;
							end

							pos.x = pos.x / i3k_table_length(targets);
							pos.z = pos.z / i3k_table_length(targets);
						end

						if cfg.args[3] == -1 then
							local er = entity._faceDir.y - math.pi * 0.5;
							g_i3k_actor_manager:SetLocalRotation(effectID, Engine.SVector3(0, er, 0));
						elseif cfg.args[3] >= 0 then
							local er = cfg.args[3] / 360 * 3.14;
							g_i3k_actor_manager:SetLocalRotation(effectID, Engine.SVector3(0, er, 0));
						end

						g_i3k_actor_manager:SetLocalTrans(effectID, Engine.SVector3(pos.x, pos.y, pos.z));
						g_i3k_actor_manager:SetLocalScale(effectID, ecfg.radius);
						g_i3k_actor_manager:Play(effectID, cfg.args[2]);

						local externalID = -1;--entity._entity:LinkExternal(g_i3k_actor_manager, effectID);

						table.insert(self._effects, { effID = effectID, extID = externalID });
					end
				end
			end
		end

		self._update = function(entity, dTick)
		end

		self._reset = function(entity, targets)
			for k, v in pairs(self._effects) do
				--entity._entity:UnLinkExternal(v.extID);

				g_i3k_actor_manager:ReleaseSceneNode(v.effID);
			end
			self._effects = { }
		end
	elseif cfg.stype == 6 then
		self._trigger = function(entity, targets)
			self._mgr._srcPos = { x = entity._curPos.x, y = entity._curPos.y, z = entity._curPos.z };
		end
	elseif cfg.stype == 7 then
		self._trigger = function(entity)
			if self._mgr._srcPos then
				entity:SetPos(self._mgr._srcPos);
				self._mgr._srcPos = nil;
			end
		end
	elseif cfg.stype == 8 then
		self._trigger = function(entity, targets)
			if not entity:IsDead() then
				local alist = {}
				if #cfg.args[1] > 1 and #cfg.args[1] == #cfg.args[2] then
					for k, v in ipairs(cfg.args[1]) do
                        table.insert(alist, {actionName = v, actloopTimes = cfg.args[2][k]})
					end

					entity:PlayActionList(alist, 1, cfg.args[3] == 1);
				else
					entity:Play(cfg.args[1][1], cfg.args[2][1], cfg.args[3] == 1);			
				end

				if cfg.args[3] == 1 then
					entity:LockAni(true);
				end
			end
		end

		self._reset = function(entity)
			if cfg.args[3] == 1 then
				entity:LockAni(false);
			end
		end
	elseif cfg.stype == 9 then
		self._trigger = function(entity, targets)
			if not entity:IsDead() then
				local sound = i3k_db_sound[cfg.args[1]];
				if sound then
					if entity._entity then
						entity._entity:PlayEffect(sound.path, sound.soundType == 1, 0.1, 150.0, 1.0);
					end
				end
			end
		end
	elseif cfg.stype == 10 then
		self._trigger = function(entity,targets)
			local hero = i3k_game_get_player_hero();
			if hero and entity and hero._guid == entity._guid then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(cfg.args[1]))
			end
		end
	end

	return true;
end

function i3k_skill_vfx_impl:Reset(entity)
	if self._turnOn then
		if self._reset then
			local _cb = function()
				self._reset(entity);
			end

			if self._cfg.delayReset > 0 then
				local logic = i3k_game_get_logic();
				if logic then
					logic:RegisterTimer(i3k_delay_reset_vfx_timer.new(self._cfg.delayReset, true, _cb));
				else
					_cb();
				end
			else
				_cb();
			end
		end

		self._turnOn = false;
	end
end

function i3k_skill_vfx_impl:Trigger(entity, targets)
	if self._trigger then
		if not self._turnOn then
			self._turnOn = true;

			self._trigger(entity, targets);
		end
	end
end

function i3k_skill_vfx_impl:OnLogic(entity, dTick)
	if self._update and self._turnOn then
		self._update(entity, dTick);
	end
end


------------------------------------------------------
i3k_skill_vfx = i3k_class("i3k_skill_vfx");
function i3k_skill_vfx:ctor()
	self._valid		= false;
	self._turnOn	= false;
	self._vfx		= nil;
end

function i3k_skill_vfx:Create(id)
	self._valid	= false;
	self._vfx	= nil;
	self._ignoreAct
				= false;
	self._stage	= -1;

	if vfxID ~= -1 then
		local vcfg = i3k_db_skill_vfx[id];
		if vcfg then
			self._valid = true;
			self._ignoreAct
						= vcfg.ignoreAct == 1;
			self._stage	= vcfg.stage;

			self._vfx = i3k_skill_vfx_impl.new(self);
			if not self._vfx:Create(vcfg) then
				self._vfx 	= nil;
				self._valid = false;
			end
		end
	end

	return self._valid;
end

function i3k_skill_vfx:Reset(entity)
	if self._turnOn then
		self._turnOn = false;

		self._vfx:Reset(entity);
	end
end

function i3k_skill_vfx:TriggerOn(entity, targets)
	if self._valid and self._vfx and not self._turnOn then
		self._turnOn = true;

		self._vfx:Trigger(entity, targets);
	end
end

function i3k_skill_vfx:TriggerOff(entity)
	if self._valid and self._vfx and self._turnOn then
		--self._turnOn = false;

		--self._vfx:Reset(entity);
	end
end

function i3k_skill_vfx:OnLogic(entity, dTick)
	if self._valid and self._vfx and self._turnOn then
		self._vfx:OnLogic(entity, dTick);
	end
end

