require "Core.Role.Controller.PlayerController";
require "Core.Role.Controller.MonsterController";
require "Core.Module.Friend.controlls.PartData"

MapRoleList = class("MapRoleList")
MapRoleList._instance = nil;
local insert = table.insert

function MapRoleList:GetInstance()
	return MapRoleList._instance
end

function MapRoleList:New(info)
	self = {};
	setmetatable(self, {__index = MapRoleList});
	self._roles = {};
	if(info) then
		self._isPkMap = info.is_pk
	else
		self._isPkMap = false;
	end
	-- self.maxPlayerCount = GameConfig.instance.maxPlayerCount

	MapRoleList._instance = self
	return self;
end



function MapRoleList:_RemoveRoleTarget(role)
	if(role) then
		local roles = self._roles
		if(HeroController.GetInstance().target == role) then
			HeroController.GetInstance().target = nil;
		end
		for i, v in pairs(roles) do
			if(v and v.target == role) then
				v.target = nil;
			end
		end
	end
end

function MapRoleList:GetRoles()
	return self._roles;
end


function MapRoleList:AddRole(role)
	if(role) then
		-- logTrace("MapRoleList:AddRole:" .. role.id .. type(role.id))

		--        if (role.roleType == ControllerType.PLAYER) then
		--            if (table.getCount(self._players) >= self.maxPlayerCount) then
		--                role.transform.gameObject:SetActive(false)
		--            end
		--            table.insert(self._players, role)
		--        end

		-- logTrace("MapRoleList:AddRole:id=" .. role.id .. ",t=" .. type(role.id))
		self._roles[role.id] = role;
		if self.hideRoles then
			insert(self.hideRoles, role)
			role:SetVisible(false)
		end
		
		return role;
	end
	return nil;
end

-- 获取相同阵营血量最低
function MapRoleList:GetSameCampLowHPRole(camp, position, distance)
	local roles = self._roles
	local currRole = nil;
	local max = 0;
	for i, v in pairs(roles) do
		if(v and v.info.camp == camp and v:CanSelect() and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET) then
			local d = Vector3.Distance2(position, v.transform.position);
			local hpR = v.info.hp / v.info.hp_max
			if(d < distance and max < hpR) then
				max = hpR;
				currRole = v;
			end
		end
	end
	return currRole;
end

-- 获取组队队员血量最低
function MapRoleList:GetSameTeamLowHPRole(camp, position, distance)
	local currRole = nil;
	local max = 0;
	if PartData.myTeam ~= nil then
		local m = PartData.myTeam.m;
		for key, value in pairs(m) do
			local role = self:GetRole(value.pid);
			if(role) then
				if(role and role.info.camp == camp and role:CanSelect() and(not role:IsDie()) and role.roleType ~= ControllerType.PET and role.roleType ~= ControllerType.HEORPET) then
					local d = Vector3.Distance2(position, role.transform.position);
					local hpR = role.info.hp / role.info.hp_max
					if(d < distance and max < hpR) then
						max = hpR;
						currRole = role;
					end
				end
			end
		end
	end
	return currRole;
end

-- 获取相同阵营最近角色
function MapRoleList:GetSameCampRole(camp, position, distance)
	local roles = self._roles
	local currRole = nil;
	local max = distance;
	for i, v in pairs(roles) do
		if(v and v.info.camp == camp and v:CanSelect() and v.state ~= RoleState.RETREAT and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET) then
			local d = Vector3.Distance2(position, v.transform.position);
			if(d < max) then
				max = d;
				currRole = v;
			end
		end
	end
	return currRole;
end

-- 获取相同阵营角色列表
function MapRoleList:GetSameCampRoles(camp)
	local roles = self._roles
	local sampRoles = {};
	for i, v in pairs(roles) do
		if(v and v.info.camp == camp) then
			insert(sampRoles, v)
		end
	end
	return sampRoles;
end

-- 获取不同阵营最近角色,ignoreElite忽略精英怪和boss
function MapRoleList:GetNotSameCampRole(camp, position, distance, ignoreElite, ignorePlayer)
	local roles = self._roles
	local currRole = nil;
	local max = distance;
	for i, v in pairs(roles) do
		if(v and self:_GetTargetNotSameCampIsLegal(v, camp)) then
			local d = Vector3.Distance2(position, v.transform.position);
			if(d < max) then
				if(v.roleType == ControllerType.MONSTER) then
					if((ignoreElite and v.info["type"] == 1) or(not ignoreElite)) then
						max = d;
						currRole = v;
					end
				elseif(v.roleType == ControllerType.PLAYER and(not ignorePlayer)) then
					if(not ignorePlayer) then
						max = d;
						currRole = v;
					end
				else
					max = d;
					currRole = v;
				end
			end
		end
	end
	return currRole;
end

-- 获取攻击目标
function MapRoleList:GetCanAttackTarget(camp, position, distance, pkType, guild, priority, ignoreElite, ignoreAppear)
	local roles = self._roles
	local currPlayer = nil;
	local currMonster = nil;
	local max1 = distance;
	local max2 = distance;
	local blPriorityPlayer =(priority == 1);
	local blPriorityMonster =(priority == 2);
	for i, v in pairs(roles) do
		if(v and v.transform and v.info and v.info.camp ~= 0 and v:CanSelect() and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET and v.roleType ~= ControllerType.NORMAL) then
			local d = Vector3.Distance2(position, v.transform.position);
			if(d < max1 or d < max2) then
				if(v.roleType == ControllerType.PLAYER and v.info.level >= 20 and self._isPkMap) then
					if(d < max1) then
                        if TabooProxy.InTaboo() and TabooProxy.CanAttack(v) then
                            max1 = d;
							currPlayer = v;
                        elseif(v.info.camp ~= camp) then
							max1 = d;
							currPlayer = v;
						elseif(not PartData.IsMyTeammate(v.id) and not GuildDataManager.IsSameGuild(guild, v.info.tgn)) then
							if(pkType == 1) then
								if(v.info.pkState == 1 or v.info.pkState == 2) then
									max1 = d;
									currPlayer = v;
								end
							elseif(pkType == 2) then
								if(v.info.pkType == 3 or v.info.pkType == 2 or(v.info.pkState == 0 and v.info.pkType ~= 0 and v.info.pkType ~= 1)) then
									max1 = d;
									currPlayer = v;
								end
							elseif(pkType == 3) then
								max1 = d;
								currPlayer = v;
							end
						end
					end
				else
					if(ignoreAppear ~= true or(ignoreAppear and v.isAppear ~= true)) then
						if(d < max2) then
							if(v.roleType == ControllerType.MONSTER and v.state ~= RoleState.RETREAT and v.info.camp ~= camp) then
								if(v.info["type"] == 1) then
									max2 = d;
									currMonster = v;
								elseif(not ignoreElite) then
									max2 = d;
									currMonster = v;
								end
							elseif(v.info.camp ~= camp) then
								max2 = d;
								currMonster = v;
							end
						end
					end
				end
			end
		end
	end
	if(blPriorityPlayer and currPlayer ~= nil or currMonster == nil) then
		return currPlayer
	end
	return currMonster;
end

-- 获取敌对目标s
function MapRoleList:GetHostileTargets(camp, pkType)
	local roles = self._roles
	local currRoles = {};
	for i, v in pairs(roles) do
		if(v and v.transform and v.info and v.info.camp ~= 0 and v:CanSelect() and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET and v.roleType ~= ControllerType.NORMAL) then
			if(v.roleType == ControllerType.PLAYER and v.info.level >= 20) then
				if(v.info.camp ~= camp) then
					insert(currRoles, v);
				elseif(not PartData.IsMyTeammate(v.id) and self._isPkMap) then
					if(pkType == 1) then
						if(v.info.pkState == 1 or v.info.pkState == 2) then
							insert(currRoles, v);
						end
					elseif(pkType == 2) then
						if(v.info.pkType == 3 or v.info.pkType == 2 or(v.info.pkState == 0 and(v.info.pkType ~= 0 or v.info.pkType ~= 1))) then
							insert(currRoles, v);
						end
					elseif(pkType == 3) then
						insert(currRoles, v);
					end
				end
			else
				if(v.state ~= RoleState.RETREAT and v.info.camp ~= camp) then
					insert(currRoles, v);
				end
			end
		end
	end
	return currRoles;
end

function MapRoleList:GetCanAttackTargetById(id, camp, position, distance)
	local roles = self._roles
	local currRole = nil;
	local max = distance;
	for i, v in pairs(roles) do
		if(v and v.transform and v.info and v.info.kind == id and v.info.camp ~= 0 and v.info.camp ~= camp and v:CanSelect() and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET and v.roleType ~= ControllerType.NORMAL) then
			local d = Vector3.Distance2(position, v.transform.position);
			if(d < max) then
				max = d;
				currRole = v;
			end
		end
	end
	return currRole;
end

function MapRoleList:_GetTargetNotSameCampIsLegal(v, camp)
	return v.info.camp and v.info.camp ~= camp and v:CanSelect() and v.state ~= RoleState.RETREAT and(not v:IsDie()) and v.roleType ~= ControllerType.PET and v.roleType ~= ControllerType.HEORPET and v.roleType ~= ControllerType.NPC
end

function MapRoleList:GetRoleByArea(position, radius, roleType, ignoreElite)
	local roles = self._roles
	local currRole = nil;
	local max = radius;
	for i, v in pairs(roles) do
		if(v and v:CanSelect() and v.state ~= RoleState.RETREAT and(not v:IsDie()) and v.roleType == roleType) then
			if(ignoreElite and v.info.type == 1 or(not ignoreElite)) then
				local d = Vector3.Distance2(position, v.transform.position);
				if(d < max) then
					max = d;
					currRole = v;
				end
			end
		end
	end
	return currRole;
end

function MapRoleList:GetAllHeros()
	local roles = self._roles
	local items = {};
	local index = 1;
	for id, value in pairs(roles) do
		if(value and value.roleType == ControllerType.PLAYER) then
			items[index] = value;
			index = index + 1;
		end
	end
	return items;
end
-- 隐藏当前显示的名字
function MapRoleList:HideNamePanels()
	local roles = self._roles
	self.hideNameRoles = {};
	for id, r in pairs(roles) do
		if r:GetRoleNamePanelActive() then
			insert(self.hideNameRoles, r)
			r:SetRoleNamePanelActive(false)
		end
	end
end
-- 显示上次调用 hideNamePanels函数被隐藏的名字
function MapRoleList:ShowNamePanels()
	local roles = self.hideNameRoles
	if not roles then return end
	for id, r in pairs(roles) do
		r:SetRoleNamePanelActive(true)
	end
	self.hideNameRoles = nil
end
-- 隐藏当前显示的角色, ControllerType类型t 除外 
function MapRoleList:HideRole(t)
	local roles = self._roles
	self.hideRoles = {};
	for id, r in pairs(roles) do
		if r.roleType ~= t then
			insert(self.hideRoles, r)
			r:SetVisible(false)
		end
	end
end
-- 显示上次调用 HideRole 函数被隐藏的角色
function MapRoleList:ShowRole()
	local roles = self.hideRoles
	if not roles then return end
	for id, r in pairs(roles) do
		r:SetVisible(true)
	end
	self.hideRoles = nil
end

function MapRoleList:GetAllRoles(type)
	local roles = self._roles
	if(type) then
		local items = {};
		local index = 1;
		for id, value in pairs(roles) do
			if(value and value:CanSelect()) then
				if(type == value.roleType) then
					items[index] = value;
					index = index + 1;
				end
			end
		end
		return items
	end
	return roles;
end

function MapRoleList:GetBoss()
	for id, value in pairs(self._roles) do
		if(value and value.info and value:CanSelect()) then
			if(ControllerType.MONSTER == value.roleType) then
				return value
			end
		end
	end
end

function MapRoleList:HasRole(id)
	if(self._roles[id]) then
		return true;
	end
	return false;
end

function MapRoleList:GetRole(id)
	-- logTrace("MapRoleList:GetRole:id=" .. id .. ",t=" .. type(id))
	return self._roles[id];
end

function MapRoleList:RemoveRole(role, blDispose)
	-- logTrace("MapRoleList:RemoveRole:" .. role.id)
	if(role and role.info) then
		self:RemoveById(role.id, blDispose)
	end
end

function MapRoleList:RemoveById(id, blDispose)
	-- log(id)
	local dispose = blDispose and true;
	local role = self:GetRole(id)
	if(role ~= nil) then
		self:_RemoveRoleTarget(role);
		
		--        if (self._players) then
		--            local key = nil
		--            for k, v in pairs(self._players) do
		--                if (v.id == id) then
		--                    self._players[k] = nil
		--                end
		--            end
		--            local playerCount = 0
		--            for k, v in pairs(self._players) do
		--                if (playerCount <= self.maxPlayerCount) then
		--                    v.transform.gameObject:SetActive(true)
		--                else
		--                    v.transform.gameObject:SetActive(false)
		--                end
		--                playerCount = playerCount + 1
		--            end
		--        end

		if(dispose and role.transform ~= nil) then
			role:Dispose();
		end
		self._roles[id] = nil;
		role = nil;
	end
end

function MapRoleList:Dispose()
	if(self.hideRoles ~= nil) then
		for i, v in pairs(self.hideRoles) do
			self.hideRoles[i] = nil;
			v = nil;
		end
		self.hideRoles = nil;
	end
	if(self._roles ~= nil) then
		 
		for i, v in pairs(self._roles) do
			if(v.transform ~= nil) then
				v:Dispose();
				self._roles[i] = nil;
			end
		end
		self._roles = nil;
	end
end

