require "Core.Role.Controller.AbsController";
require "Core.Role.Action.StandAction"
require "Core.Role.Action.MoveToAngleAction"
require "Core.Role.Action.MoveToPathAction"
require "Core.Role.Action.MoveToAction"
require "Core.Role.Action.SkillMoveAction"
require "Core.Role.Action.RepelAction"
require "Core.Role.Action.DartAction"
require "Core.Role.Action.DieAction"
require "Core.Role.Action.HurtAction"
require "Core.Role.Action.LockAction"
require "Core.Role.Action.KnockAction"
require "Core.Role.Action.HitState"
require "Core.Role.Buff.BuffController";


RoleState =
{
	STAND = 1;
	MOVE = 2;
	RETREAT = 3;
	SKILL = 4;
	HURT = 5;
	DIE = 6;
	SILENT = 7;
	STUN = 8;
	STILL = 9;
}

RoleController = class("RoleController", AbsController);
RoleController.actionType = ControllerType.ROLE;
RoleController.state = RoleState.STAND;
RoleController.id = "";
RoleController.info = nil;
RoleController.target = nil;
RoleController.master = nil;
RoleController.transform = nil;

RoleController._role = nil;
RoleController._roleAnimator = nil;

function RoleController:New()
	self = {};
	setmetatable(self, {__index = RoleController});
	self.state = RoleState.STAND;
	return self;
end

-- 顿帧
function RoleController:PauseFrame(frames, delay)
	if(not self:isPaused()) then
		if(self._pauseFrameTimer) then
			self._pauseFrameTimer:Reset(function(val) self:_OnPauseFrameHandler(val) end, 0, - 1, false);
		else
			self._pauseFrameTimer = Timer.New(function(val) self:_OnPauseFrameHandler(val) end, 0, - 1, false);
		end
		self._pauseFrameAmount = frames;
		self._pauseFrameDelay = delay or 0;
		self._pauseFrameTimer:Start();
		self:Pause();
	end
end

function RoleController:CanSelect()
	if(self.info) then
		if(self._buffCtrl) then
			return(not self.info.gearmonster) and self._buffCtrl:GetCanSelect();			
		else
			return(not self.info.gearmonster);
		end
		
	end
	return true
end

function RoleController:IsOnLMount()
	return false;
end

function RoleController:OnEnterStandAction()
	if self._roleCreater then self._roleCreater:SetShadowStatic(true) end
end
function RoleController:OnExitStandAction()
	if self._roleCreater then self._roleCreater:SetShadowStatic(false) end
end


-- 是否固定朝向,不修正转向
function RoleController:IsFixedRotate()
	if(self.info) then
		return self.info.fixed;
	end
	return false
end


function RoleController:SetFightStatus(status)
	self._isFight = status
end

function RoleController:IsFightStatus()
	if(self._isFight == nil) then
		self._isFight = false;
	end
	return self._isFight;
end

function RoleController:ResetFightStatusTime()
	
end

function RoleController:_OnPauseFrameHandler()
	if(self._pauseFrameDelay > 0) then
		self._pauseFrameDelay = self._pauseFrameDelay - Timer.deltaTime;
	else
		if(self._pauseFrameAmount > 0) then
			self._pauseFrameAmount = self._pauseFrameAmount - 1;
		else
			self._pauseFrameTimer:Stop();
			self._pauseFrameTimer = nil;
			self:Resume();
		end
	end
end

function RoleController:Pause()
	self._isPaused = true;
	if(self._action) then
		self._action:Pause()
	end
	if(self._cooperation) then
		self._cooperation:Pause();
	end
	if(self._roleCreater) then
		self._roleCreater:Pause();
	end
	if(self._skillEffects) then
		for i, v in pairs(self._skillEffects) do
			v:Pause();
		end
	end
end


function RoleController:Resume()
	if(self._action) then
		self._action:Resume()
	end
	if(self._cooperation) then
		self._cooperation:Resume();
	end
	if(self._roleCreater) then
		self._roleCreater:Resume();
	end
	if(self._skillEffects) then
		for i, v in pairs(self._skillEffects) do
			if(v and v.transform) then
				v:Resume();
			end
		end
	end
	self._isPaused = false;
end

function RoleController:IsActive()
	if(self.transform and self.transform.gameObject) then
		return self.transform.gameObject.activeSelf
	end
	return false;
end

function RoleController:AddSkillEffect(eff)
	if(eff) then
		if(self._skillEffects == nil) then
			self._skillEffects = {};
		end
		table.insert(self._skillEffects, eff);
		if(self:isPaused()) then
			eff:Pause();
		end
	end
end

function RoleController:RemoveSkillEffect(eff)
	if(self._skillEffects and not self._isClearSkillEffect) then
		-- for i, v in pairs(self._skillEffects) do
		for i = 1, #self._skillEffects do
			if(self._skillEffects[i] == eff) then
				table.remove(self._skillEffects, i);
				return;
			end
		end
	end
end

function RoleController:ClearSkillEffect()
	self._isClearSkillEffect = true
	if(self._skillEffects) then
		for i, v in pairs(self._skillEffects) do
			if(v.transform ~= nil and v.transform.parent == self.transform) then
				v:Dispose();
			end
		end
		self._skillEffects = nil;
	end
	self._isClearSkillEffect = false
end

function RoleController:SetTarget(target)
	
	if(target == nil or(target ~= nil and target:CanSelect())) then
		if(target ~= self.target) then
			self.target = target;
		end
	end
end

function RoleController:GetTarget()
	return self.target;
end

function RoleController:SetEpigoneTarget(target)
	
end

function RoleController:SetSelect(selected, selectName, selecter)
	self:_DisposeSelectEff()
	if(selected) and self.transform then
		if(not selecter and GameSceneManager.map) then
			GameSceneManager.map:SetSelect(self)
			return
		end
		
		if selectName == nil then selectName = "select" end
		self._selectedEff = Resourcer.Get("Effect/UIEffect", selectName, self.transform);
		
		self._selectedEff:SetActive(true)
		
	end
end

function RoleController:CalculateAttribute()
	
end

-- 自动消失
function RoleController:SetAutoDisappear(time)
	self._lastDisappearTime = os.clock();
	self.disappearTime = time / 1000
	if(self._disappearTimer == nil) then
		self._disappearTimer = Timer.New(function(val) self:_OnDisappearTimerHandler(val) end, 0.2, - 1);
		self._disappearTimer:Start();
	end
end

function RoleController:_OnDisappearTimerHandler()
	local curDisappearTime = os.clock();
	self.disappearTime = self.disappearTime -(curDisappearTime - self._lastDisappearTime)
	
	self._lastDisappearTime = curDisappearTime;
	if(self.disappearTime <= 0) then
		self._disappearTimer:Stop();
		self._disappearTimer = nil;
		self.disappearTime = 0;
		GameSceneManager.map:RemoveRole(self);
	end
end

function RoleController:_OnLoadModelSource(model)
	if(self._buffCtrl) then
		self._buffCtrl:ResetEffectPos();
	end
	if(self._alpha ~= nil) then
		self:SetAlpha(self._alpha);
	end
	
	self:_OnLoadModelSourceOtherSetting();
end

function RoleController:_OnLoadModelSourceOtherSetting()
	
end

function RoleController:HasBuffAction()
	if(self._buffCtrl) then
		return self._buffCtrl:HasBuffAction();
	end
	return false;
end

function RoleController:GetBuffController()
	if(self._buffCtrl == nil) then
		self._buffCtrl = BuffController:New(self);
	end
	return self._buffCtrl;
end

-- 获取buff
function RoleController:GetBuffs()
	if self._buffCtrl then
		return self._buffCtrl:GetBuffs();
	end
	return nil;
end

-- 添加buffs
function RoleController:AddBuffs(buffs)
	if(buffs) then
		for i, v in pairs(buffs) do
			self:AddBuff(nil, v.id, v.lv, v.rt, v.num);
		end
	end
end

-- 添加buff
function RoleController:AddBuff(caster, id, level, time, overlap)
	if(not self:IsDie()) then
		if(self._buffCtrl == nil) then
			self._buffCtrl = BuffController:New(self);
		end
		return self._buffCtrl:Add(caster, id, level, time, overlap);
		
	end
	return nil;
end

-- 清除buff
function RoleController:RemoveBuff(id, dispose)
	if(not self:IsDie()) then
		if(self._buffCtrl) then
			self._buffCtrl:RemoveBuff(id, dispose);
		end
	end
end
-- 清除所有buff
function RoleController:RemoveBuffAll(isFilter)
	if(self._buffCtrl) then
		self._buffCtrl:RemoveAll(isFilter)
	end
end

-- 是否死亡
function RoleController:IsDie()
	return self._blDie;
end

-- 是否骑坐骑
function RoleController:IsOnRide()
	return false;
end

-- 播放默认动画
function RoleController:PlayDefualt()
	
	if((not self:IsDie()) and self._roleCreater) then
		self._roleCreater:PlayDefualt();
	end
end
-- 播放动画
function RoleController:Play(name, returnActionTime)
	
	if((not self:IsDie()) and self._roleCreater) then
		return self._roleCreater:Play(name, returnActionTime)
	end
end
-- 播放当前动画进度
function RoleController:AnimNormalizedTime()
	if self._roleCreater then
		return self._roleCreater:AnimNormalizedTime()
	end
    return -1
end
-- 是否正在播放name动画
function RoleController:AnimIsName(name)
	if self._roleCreater then
		return self._roleCreater:AnimIsName(name)
	end
    return false
end

function RoleController:GetAnimatorStateInfo()
	if(self._roleCreater) then
		return self._roleCreater:GetAnimatorStateInfo();
	end
	return nil;
end

function RoleController:LockTarget(target)
	if(target and target.transform and target ~= self) then
		local r = math.atan2(target.transform.position.x - self.transform.position.x, target.transform.position.z - self.transform.position.z);
		local angle = r * 180 / math.pi;
		self.transform.rotation = Quaternion.Euler(0, angle, 0);
	end
end

function RoleController:Lock()
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(LockAction:New());
	end
end

function RoleController:UnLock()
	if(not self:IsDie()) then
		self:StopAction(3);
		self:Stand();
	end
end

function RoleController:SetMoveSpeed(speed)
	if(self.info) then
		self.info.move_spd = speed;
	end
end

-- 待机
function RoleController:Stand(position, angle)
	if(not self:IsDie()) then
		local action = self._action;
		local cooperation = self._cooperation;
		if(action) then
			if(action.canMove) then
				local standAct = StandAction:New(position, angle)
				standAct.actionType = ActionType.COOPERATION;
				self:StopAction(2);
				self:DoAction(standAct);
			else
				-- if (action.actionType ~= ActionType.BLOCK) then
				self:StopAction(3);
				self:DoAction(StandAction:New(position, angle));
				-- end
			end
		else
			self:StopAction(3);
			self:DoAction(StandAction:New(position, angle));
		end
	end
end

function RoleController:Relive()
	--    if (self:IsDie()) then
	self.info.hp = self.info.hp_max;
	self:StopAction(3);
	self._blDie = false;
	self:Stand();
	--    end
end

-- 死亡
function RoleController:Die(blFly)
	if(not self:IsDie() and not self:IsDisposed()) then
		self.info.hp = 0;
		self:RemoveBuffAll(true);
		
		self:StopAction(3);
		self:DoAction(DieAction:New(blFly));
		self._blDie = true;
		-- self:SetSelect(false);
	end
end

-- 伤害
function RoleController:Hurt()
	if(not self:IsDie()) then
		if(self.state == RoleState.STAND) then
			self:DoAction(HurtAction:New());
		end
	end
end

-- 突进
function RoleController:Dart(distance, delay, time)
	if(not self:IsDie()) then
		self:DoAction(DartAction:New(distance, delay, time));
	end
end
--[[function RoleController:Dart(distance, speed)
    if (distance and speed) then
        self:DoAction(DartAction:New(distance, speed));
    end
end
]]
-- 被击退
function RoleController:Repel(role, distance)
	if(not self:IsDie() and role and distance) then
		self:DoAction(RepelAction:New(role, distance));
	end
end

function RoleController:Knock(id, pt, blShake)
	if(not self:IsDie()) then
		self:DoAction(KnockAction:New(id, pt, blShake));
	end
end

function RoleController:MoveTo(pt, map)
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(MoveToAction:New(pt, map))
	end
end

-- 移动，角度
function RoleController:MoveToAngle(angle, pos)
	-- log(tostring(angle) .. ",pos=" .. tostring(pos).. ",posT=" .. type(pos).. ",action=" .. tostring(self._action))
	if(not self:IsDie()) then
		local action = self._action;
		local cooperation = self._cooperation;
		if(action) then
			if(action.canMove) then
				if(cooperation and cooperation.__cname == "SkillMoveAction") then
					cooperation:SetAngle(angle);
				else
					self:DoAction(SkillMoveAction:New(angle));
				end
			else
				if(action.actionType == ActionType.BLOCK) then
					self:StopAction(3);
					self:DoAction(MoveToAngleAction:New(angle));
				else
					if(action.__cname == "MoveToAngleAction") then
						action:SetAngle(angle);
					else
						self:DoAction(MoveToAngleAction:New(angle));
					end
				end
			end
		else
			self:DoAction(MoveToAngleAction:New(angle));
		end
		self:SetPosition(pos)
	end
end

-- 移动，路径
function RoleController:MoveToPath(path)
	-- if self.__cname == "PlayerController" then Error(tostring(self.gameObject.name) .. "^^^^^^^^"  .. tostring(not self:IsDie())) end
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(MoveToPathAction:New(path))
	end
end

-- 使用技能 
function RoleController:CastSkill(skill)
	if(not self:IsDie() and skill) then
		self:StopAction(3);
		self:DoAction(SkillAction:New(skill));
	end
end

function RoleController:CastPassiveSkill(skill, target)
	self:DoAction(SkillAction:New(skill, target), false);
end

function RoleController:StopCurrentActAndAI()
	if(not self:IsDie()) then
		self:StopAction(3);
		self:Stand();
	end
end

function RoleController:SetAlpha(alpha)
	self._alpha = alpha;
	if(self.transform) then
		UIUtil.SetRoleAlpha(self.transform, alpha);
	end
end

function RoleController:SetEquipAndWeaponeEffectActive(enable)
	if(self._roleCreater) then
		self._roleCreater:SetEquipAndWeaponeEffectActive(enable)
	end	
end

function RoleController:GetAlpha()
	if(self._alpha) then
		return self._alpha
	end
	return 1;
end
function RoleController:_DisposeSelectEff()
	if not IsNil(self._selectedEff) then
		Resourcer.Recycle(self._selectedEff, true)
		self._selectedEff = nil
	end
end

function RoleController:Dispose()
	if not self._dispose then
		if self.hitState then self.hitState:Dispose() self.hitState = nil end
		self:StopAction(3)
		self._dispose = true
		self.visible = false
		--    if (self._shadow) then
		--        Resourcer.Recycle(self._shadow)
		--        self._shadow = nil
		--    end
		self:ClearSkillEffect();
		if(self._disappearTimer) then
			self._disappearTimer:Stop();
			self._disappearTimer = nil;
		end
		if(self._pauseFrameTimer) then
			self._pauseFrameTimer:Stop();
			self._pauseFrameTimer = nil;
		end
		if(self._buffCtrl) then
			self._buffCtrl:RemoveAll()
			self._buffCtrl = nil;
		end
		self:_DisposeNamePanel()
		
		self:_DisposeHandler();
		
		self:_DisposeSelectEff()
		
		if(self.info) then
			self.info:Dispose();
			self.info = nil;
		end
		
		if(self.transform) then
			if(self._roleCreater) then
				self._roleCreater:Dispose()
				self._roleCreater = nil
			end
			Resourcer.Recycle(self.gameObject, false)
		end
		self.target = nil;
		self._master = nil;
		self.pet = nil;
		self.puppet = nil;
		self.transform = nil;
		self.state = RoleState.DIE;
	end
end

function RoleController:GetMoveSpeed()
	if(self.info and self.info.move_spd) then
		return self.info.move_spd;
	end
	return 0;
end

function RoleController:HitBlink()
	if(not self:IsDie()) then
		--self:DoAction(HitBlinkAction:New());
		if not self.hitState then self.hitState = HitState.New():Init(self) end
		self.hitState:SetEnable(true)
	end
end

function RoleController:SetRoleTrumpActive(enable)
	if(self._roleCreater) then
		local trump = self._roleCreater:GetTrump()
		if(trump) then
			trump:SetActive(enable)
		end
	end
end

function RoleController:SetRoleWingActive(enable)
	if(self._roleCreater) then
		self._roleCreater:SetWingActive(enable)
	end
end

function RoleController:_DisposeHandler()
	
end

function RoleController:GetInfo()
	return self.info
end

function RoleController:SetBuffActive(enable)
	if(self._buffCtrl) then
		self._buffCtrl:SetBuffActive(enable)
	end
	
end

