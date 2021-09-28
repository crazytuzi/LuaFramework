require "Core.Role.Action.SendCmd.SendSkillAction"
require "Core.Role.Action.SendCmd.SendMoveToSkillAction"
require "Core.Role.Action.SendCmd.SendAttackAction"
require "Core.Role.Action.SendCmd.SendMoveToAttackAction"
require "Core.Module.Friend.controlls.PartData"

AttackController = class("AttackController");

function AttackController:New(role)
	self = {};
	setmetatable(self, {__index = AttackController});
	self:_Init(role);
	self._autoSearchTarget = true;
	return self;
end

function AttackController:_Init(role)
	self._role = role;
	self._timer = Timer.New(function(val) self:_OnTimerHandler(val) end, 0.1, - 1, false);
	self._timer:Start();
	self._timer:Pause(true)
	--self._timer.running = false;
end

function AttackController:_GetTargetBySkill(skill)
	local role = self._role;
	local target = role.target;
	local pkType = role.info.pkType;
	local pt = role.transform.position
	if(skill) then
		local mapInfo = GameSceneManager.map.info;
		local maxDistance = skill.max_distance / 100;
		if(skill.target_type == 1) then
			target = role;
		elseif(skill.target_type == 2) then
			target = GameSceneManager.map:GetSameTeamLowHPRole(role.info.camp, pt, maxDistance)
			if(target == nil) then
				target = role;
			else
				local sHPR = role.info.hp / role.info.hp_max;
				local tHPR = target.info.hp / target.info.hp_max;				
				if(sHPR < tHPR) then
					target = role;
				end
			end
		elseif(skill.target_type == 3 or skill.target_type == 4) then
			blSearch = false
			if(target == nil or(target and(target:IsDie() or target.info == nil))) then
				-- 目标为空，从找目标
				blSearch = true;
			else
				if(target == role) then
					-- 目标为自身，从找目标
					blSearch = true;
				else
					if(target.info.camp == 0 or target.state == RoleState.RETREAT or Vector3.Distance2(pt, target.transform.position) > maxDistance) then
						-- 中立、返回出生点、超出技能最大距离，从找目标
						blSearch = true;
					else
						if(target.info.camp == role.info.camp) then							
							if(mapInfo.is_pk and target.roleType == ControllerType.PLAYER and target.info.level > 20) then
								if(PartData.IsMyTeammate(target.id) or GuildDataManager.IsSameGuild(role.info.tgn, target.info.tgn)) then
									-- 目标为队友，从找目标
									blSearch = true;
								else
									if(pkType == 0) then
										if(target.info.camp == role.info.camp) then
											blSearch = true;
										end
									elseif(pkType == 1) then
										if(target.info.pkState == 0) then
											blSearch = true;
										end
									elseif(pkType == 2) then
										if((target.info.pkType == 0 and target.info.pkState == 0) or(target.info.pkType == 1 and target.info.pkState == 0)) then
											blSearch = true;
										end
									end
								end							
							else
								blSearch = true;
							end						
						end
					end
				end
			end
			if(blSearch) then
				target = GameSceneManager.map:GetCanAttackTarget(role.info.camp, pt, maxDistance, pkType, role.info.tgn, 1, false, true);
			end
		end
	end
	return target;
end

function AttackController:_OnTimerHandler()
	local role = self._role;
	local skill = self._skill;
	if(role and(not role:IsDie()) and role.state ~= RoleState.SILENT and role.state ~= RoleState.STUN and skill and(not skill:IsCooling()) and GameSceneManager.map) then
		if(role.info.mp >= skill.mp_cost) then
			local target = role.target;
			local action = role:GetAction();			
			if(action == nil or(action ~= nil and action.actionType ~= ActionType.BLOCK)) then				
				if(self._autoSearchTarget) then
					target = self:_GetTargetBySkill(skill);
					if(target ~= role.target) then
						role:SetTarget(target);						
					end
				end
				if(target and target.transform) then
					local castDistance =(skill.distance + target.info.radius) / 100 * 0.9;
					if(Vector3.Distance2(role.transform.position, target.transform.position) < castDistance) then
						role:DoAction(SendSkillAction:New(skill));
					else
						if(action) then
							if(action.__cname == "SendMoveToSkillAction") then
								if(action:GetTarget() ~= target) then
									action:SetTarget(target);
								end
							else
								role:DoAction(SendMoveToSkillAction:New(target, skill));
							end
						else
							role:DoAction(SendMoveToSkillAction:New(target, skill));
						end
					end
				else
					-- if(GameSceneManager.map) then
					-- 	GameSceneManager.map:ResetLastSelectRole()
					-- end
					if(skill.is_tar_need == 0) then
						role:DoAction(SendSkillAction:New(skill));
					else
						if(not self._showTip1) then
							self._showTip1 = true;
							MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("figth/notTarget"));
						end
					end
				end
			end
		else
			
			-- if(GameSceneManager.map) then
			-- 	GameSceneManager.map:ResetLastSelectRole()
			-- end
			if(not self._showTip2) then
				self._showTip2 = true;
				self:StopAttack();
				MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("figth/notMP"));
			end
		end
	end
end

function AttackController:StartAttack(autoSearch)
	local role = self._role;
	if(role) then
		self._timer:Pause(false);
	end
end

function AttackController:StopAttack()
	self._timer:Pause(true);
	self._skill = nil
end

function AttackController:CastSkill(skill, autoSearch)
	local role = self._role;
	if(autoSearch == false) then
		self._autoSearchTarget = false;
	else
		self._autoSearchTarget = true;
	end
	if(skill and skill ~= self._skill) then
		self._skill = skill;
		self._showTip1 = false
		self._showTip2 = false;
		--if (not self._timer.running) then
		self:StartAttack();
		--end
		self:_OnTimerHandler();
	end
end

function AttackController:Dispose()
	--self:StopAttack();
	if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
	self._skill = nil;
	self._dispose = true
	self.visible = false
end 