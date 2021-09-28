require "Core.Role.Action.AbsAction";

ControllerType = {
	NORMAL = 1; --默认
	ROLE = 5; -- 角色
	NPC = 6;-- npc
	MONSTER = 7;-- 怪物
	PLAYER = 8; -- 其他玩家
	HERO = 9; -- 英雄(自己
	MOUNT = 10;-- 载具
	RIDE = 11;-- 坐骑
	PET = 12;--宠物
	HEORPET = 13;--英雄宠物
	PERFORMANCE = 14;-- 只用于做动画的怪
	PUPPET = 15;--玩家傀儡
	HEROPUPPET = 16; --英雄傀儡
	ROBOT = 17; --机器人
	HEROGUARD = 18; --雇佣npc
	HIRE = 19; --雇佣玩家
	SCENEPROP = 20;-- 在场景中可以点击的 类似宝箱的物品
}
EntityNamePrefix = {
	-- 场景实体名前缀,用于查找
	NORMAL = "mp_";
	ARATHI = "ar_";
	NPC = "npc_";
	MONSTER = "m_";
	PLAYER = "p_";
	HERO = "h_";
	MOUNT = "mt_";
	PET = "pet_";
	HEORPET = "pet_";
	PERFORMANCE = "m_";
	PUPPET = "puppet_";
	HEROPUPPET = "puppet_";
	HEROGUARD = "guard_";
	OBJ = "obj_";
	HIRE = "hire_";
	SCENEPROP = "sprop_";-- 在场景中可以点击的 类似宝箱的物品
}

ControllerSeverType =
{
	PLAYER = 1;
	MONSTER = 2;
	PET = 3;
	PUPPET = 4;-- 傀儡
	ROBOT = 5;-- 机器人
	GUARD = 6;-- 战斗npc
	HIRE = 7;-- 雇佣玩家
}

AbsController = class("AbsController");

function AbsController:New()
	self = {};
	setmetatable(self, {__index = AbsController});
	return self;
end

function AbsController:CanSelect()
	return false
end

function AbsController:SetLayer(layer)
	if(self.transform) then
		self.gameObject.layer = layer;
	end
end

-- 执行动作
function AbsController:DoAction(action, blReplace)
	if(action) then
		local isReplace = true;
		if(blReplace == false) then
			isReplace = false
		end
		if(isReplace) then
			if(self._action) then
				-- if self.__cname == "HeroController" then print(self._action.__cname) end
				if(action.actionType ~= ActionType.COOPERATION) then
					if(self._action.actionType == ActionType.BLOCK) then
						return nil;
					end
					if(self._action.actionType == ActionType.SIMILARBLOCK) then
						if(self._action.__cname == action.__cname) then
							return nil;
						end
					end
					self._action:Stop();
				else
					if(self._cooperation ~= nil) then
						self._cooperation:Stop();
					end
					if(action.isPauseMainAction) then
						self._action:Pause();
					end
				end
			end
			
			if(action.actionType ~= ActionType.COOPERATION) then
				self._action = action;
			else
				self._cooperation = action;
			end
			action:Start(self, function(val) self:_ActionCallBack(val) end);
		else
			action:Start(self);
		end
		return action;
	end
	return nil;
end

-- 停止动作，actionType = 1：主动作，2：协同动作，3：全部动作
function AbsController:StopAction(actType)
	local aType = actType or 1;
	if(aType == 1) then
		if(self._action) then
			self._action:Stop();
			self._action = nil;
		end
	elseif(actType == 2) then
		if(self._cooperation) then
			self._cooperation:Stop();
			self._cooperation = nil;
		end
	elseif(actType == 3) then
		if(self._action) then
			self._action:Stop();
			self._action = nil
		end
		if(self._cooperation) then
			self._cooperation:Stop();
			self._cooperation = nil;
		end
	end
end

-- 动作停止回调
function AbsController:_ActionCallBack(action)
	if(action == self._action) then
		self._action = nil;
	elseif(action == self._cooperation) then
		if(action.isPauseMainAction) then
			if(self._action) then
				self._action:Resume();
			end
		end
		self._cooperation = nil;
	end
	if(self.roleType == ControllerType.HERO) then
		-- print(">>>> stop" .. action.aIndex .. " " .. action.__cname);
	end
end

-- 是否可以执行动作
function AbsController:_CanDoAction()
	if(self._action ~= nil and self._action.actionType == ActionType.BLOCK) then
		return false;
	end
	return true;
end

-- 创建实体，看需求调用
function AbsController:_InitEntity(name, scale, visible)
	local sName = name or "role";
	local defScale = scale or 1;
	self.entity = GameObject.New(sName);
	self.transform = self.entity.transform;
	self.gameObject = self.transform.gameObject
	if visible == nil then visible = true end
	self:SetVisible(visible)
	self.transform.localScale = Vector3.New(defScale, defScale, defScale);
	--    if (not GameConfig.instance.useLight) then
	--        self._shadow = Resourcer.Get("Prefabs", "Blob Shadow Projector", self.transform)
	--        if (self._shadow) then
	--            self._shadow.transform.localPosition = Vector3.up * 5;
	--            self._shadow.transform.localRotation = Quaternion.Euler(90, 0, 0)
	--        end
	--    end
end

function AbsController:GetGo()
	return self.gameObject
end
function AbsController:GetTrf()
	return self.transform
end
function AbsController:GetPos()
	return self.transform and self.transform.position or nil
end
function AbsController:GetAngle()
	return self.transform.rotation.eulerAngles
end
function AbsController:GetAngleY()
	return self.transform.rotation.eulerAngles.y
end

--[[ 用其他 已经存在的 GameObject  作为 父对象
]]
function AbsController:SetEntityByTarget(target_ctr)
	
	self.entity = target_ctr.entity;
	self.transform = self.entity.transform;
	self.gameObject = self.transform.gameObject
	
end

-- 获取模型，子类重写
function AbsController:_GetModern()
	return nil, nil;
end

function AbsController:_LoadModel(creater)
	local roleCreate = creater:New(self.info, self.transform, true, function(val) self:_OnLoadModelSource(val) end, true)
	roleCreate:SetAnimatorCullingMode(self.AnimatorCullingMode)
	self._roleCreater = roleCreate
	-- self._role = self._roleCreater:GetRole()
	-- self._roleAnimator = self._roleCreater:GetAnimator()
end

function AbsController:_OnLoadModelSource(model)
	-- log("=------------------AbsController:_OnLoadModelSource ---------------------------")
	-- log(self:GetRoleCreater())
end

function AbsController:isPaused()
	return self._isPaused or false;
end

function AbsController:Pause()
	self._isPaused = true;
	if(self._action) then
		self._action:Pause()
	end
	if(self._cooperation) then
		self._cooperation:Pause();
	end
end


function AbsController:Resume()
	if(self._action) then
		self._action:Resume()
	end
	if(self._cooperation) then
		self._cooperation:Resume();
	end
	self._isPaused = false;
end

function AbsController:Dispose()
	self:StopAction(3)
	self._dispose = true
	self.visible = false
	self:_DisposeNamePanel()
	
	if self._roleCreater then
		self._roleCreater:Dispose();
		self._roleCreater = nil;
	end
	
	self:_DisposeHandler();
end

function AbsController:_DisposeHandler()
	
end

function AbsController:GetAction()
	return self._action;
end

function AbsController:GetCooperationAction()
	return self._cooperation;
end

-- retrun transform
function AbsController:GetTop()
	if self._dispose then return nil end
	if(self._roleCreater ~= nil) then
		local top = self._roleCreater:GetTop()
		if(top) then
			return top;
		end
	end
	return self.transform;
end

function AbsController:GetNamePoint()
	if self._dispose then return nil end
	if(self._roleCreater ~= nil) then
		local top = self._roleCreater:GetNamePoint()
		if(top) then
			return top;
		end
	end
	return self.transform;
end
function AbsController:HasNamePoint()
	if self._dispose then return nil end
	if(self._roleCreater ~= nil) then
		return self._roleCreater:GetNamePoint()
	end
	return nil
end

function AbsController:SetSelect(selected, selectName)
	
end


-- retrun transform
function AbsController:GetCenter()
	if(self._roleCreater ~= nil) then
		local creater = self._roleCreater:GetCenter()
		if(creater) then
			return creater;
		end
	end
	return self.transform;
end

function AbsController:GetHangingPoint(name)
	local hp = self._roleCreater:GetHangingPoint(name)
	if(hp) then
		return hp;
	end
	return self.transform;
end

-- 获取模型尺寸
function AbsController:GetSize()
	if(self._roleCreater) then
		return self._roleCreater:GetSize();
	end
	return Vector3.zero
end

function AbsController:GetRoleCreater()
	return self._roleCreater
end

function AbsController:SetVisible(visible)
	if not self._dispose and self.visible ~= visible then
		self.visible = visible;
		self.gameObject:SetActive(visible);
	end
end

function AbsController:GetActive()
	return not self._dispose and self.gameObject.activeSelf
end

function AbsController:IsDisposed()
	return self._dispose
end

-- 位置设置 
function AbsController:SetPosition(pos, angle)
	if(pos) then
		MapTerrain.SampleTerrainPositionAndSetPos(self.transform, pos)
		-- 	self.transform.position = MapTerrain.SampleTerrainPosition(pos)
	end
	
	if(angle) then
		self.transform.rotation = Quaternion.Euler(0, angle, 0);
	end
end

function AbsController:GetCreaterr()
	return self._roleCreater
end
function AbsController:GetAnimator()
	return self._roleCreater and self._roleCreater:GetAnimator() or nil
end
function AbsController:SetAnimatorCullingMode(val)
	self.AnimatorCullingMode = val
	if self._roleCreater then
		self._roleCreater:SetAnimatorCullingMode(val)
	end	
end

function AbsController:SetRoleNamePanelActive(enable)
	if(self.namePanel) then
		if(self:GetIsAbsEnable()) then
			self.namePanel:SetActive(enable)
		else
			self.namePanel:SetActive(false)
		end
	end
end

-- 设置名称的绝对状态 隐藏时不响应其他的状态
function AbsController:SetRoleNamePanelAbsActive(enable)
	self.absEnable = enable
	if(self.namePanel) then
		self.namePanel:SetActive(enable)
	end
end

function AbsController:GetIsAbsEnable()
	return self.absEnable or true
end


function AbsController:GetRoleNamePanelActive()
	return self.namePanel and self.namePanel:GetActive()
end
function AbsController:_DisposeNamePanel()
	if self.namePanel then
		self.namePanel:Dispose();
		self.namePanel = nil;
	end
end
function AbsController:RefreshRoleName()
	if self.namePanel then
		self.namePanel:RefreshRoleName()
	end
end

function AbsController:SetRoleTrumpActive(enable)
	
end

function AbsController:SetRoleWingActive(enable)
	
end

----获取模型中心
-- function AbsController:GetCenter()
--    if (self._roleCreater) then
--        return self._roleCreater:GetCenter();
--    end
--    return Vector3.zero
-- end
