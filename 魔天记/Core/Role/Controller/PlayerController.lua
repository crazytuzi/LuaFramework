require "Core.Role.Controller.RoleController";
require "Core.Info.PlayerInfo";
require "Core.Role.ModelCreater.RoleModelCreater"
require "Core.Role.ModelCreater.RideModelCreater"

require "Core.Role.Controller.MountController"

PlayerController = class("PlayerController", RoleController);
PlayerController.FIGHTSTATUSINTERVAL = 3

function PlayerController:New(data, parent)
	self = {};
	setmetatable(self, {__index = PlayerController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.PLAYER;
	self:_Init(data);
	self:AddBuffs(data.buff)
	return self;
end

function PlayerController:_Init(data)
	self.id = data.id;
	self.info = PlayerInfo:New(data);
	if(data.dress and data.dress.m ~= 0) then
		self._isRideHid = true
	end
	
	self:_InitEntity(EntityNamePrefix.PLAYER .. self.id, nil, false);
	self:SetLayer(Layer.Player);
	self:_LoadModel(RoleModelCreater);
end


function PlayerController:_GetModern()
	return "Roles/Heros", self.info.model_id;
end

function PlayerController:_OnFigthStatusHandler()
	local t = os.time()
	if(self:IsOnRide()) then
		self._figthStatusTime = t
	else
		if(t - self._figthStatusTime) > PlayerController.FIGHTSTATUSINTERVAL then
			self._figthStatusTime = t
			if(not self._isForeverFight) then
				self:SetFightStatus(false);
			end
			if(RideManager.GetIsRideUse() and GameSceneManager.map.info.ride and self.roleType == ControllerType.HERO and
			((self._isRideHide ~= nil) and(self._isRideHide == false) or self._isRideHide == nil)) then
				RideProxy.SendGetOnRide()
			end
		end
	end
end

function PlayerController:ResetFightStatusTime()
	self._figthStatusTime = os.time()
	self:SetFightStatus(true);
end

function PlayerController:StopFightStatusTimer()
	if(self._figthStatusTimer) then
		self._figthStatusTime = os.time()
		self._figthStatusTimer:Stop()
		self._figthStatusTimer = nil;
	end
end

function PlayerController:StartFightStatusTimer(blForeverFight)
	self._isForeverFight = blForeverFight or false;
	self:SetFightStatus(self._isForeverFight);
	self._figthStatusTime = os.time()
	if(self._figthStatusTimer == nil) then
		self._figthStatusTimer = Timer.New(function(val) self:_OnFigthStatusHandler(val) end, 1, - 1, false);
	end
	if not self._figthStatusTimer.running then self._figthStatusTimer:Start() end
end

function PlayerController:SetPet(petController)
	self.pet = petController;
	if(self.pet) then
		self.pet.info.move_spd = self.info.move_spd;
		self.pet.info.camp = self.info.camp;
		self.pet:SetMaster(self);
	end
end

function PlayerController:GetPet()
	return self.pet;
end

function PlayerController:SetPuppet(puppetController)
	self.puppet = puppetController;
	if(self.puppet) then
		self.puppet.info.camp = self.info.camp;
		self.puppet:SetMaster(self);
	end
end

function PlayerController:GetPuppet()
	return self.puppet;
end

function PlayerController:SetPuppetAI(val)
	if self.puppet then
		if val then
			self.puppet:StartAI()
		else
			self.puppet:StopAI()
		end
	end
end
function PlayerController:SetPetAI(val)
	if self.pet then
		if val then
			self.pet:StartAI()
		else
			self.pet:StopAI()
		end
	end
end
function PlayerController:PuppetVisible(val)
	if self.puppet then
		self.puppet:GetRoleCreater():SetActive(val)
		self.puppet:SetRoleNamePanelAbsActive(val)
	end
end

function PlayerController:PetVisible(val)
	if self.pet then
		self.pet:SetActiveByGonfig()
		self.pet:SetRoleNamePanelAbsActive(val)
	end
end

--[[function PlayerController:SetTarget(target)

    self.target = target;
    if (self.pet) then
        self.pet:SetTarget(target);
    end
    if (self.puppet) then
        self.puppet:SetTarget(target);
    end
end
]]
function PlayerController:RefreshEpigoneTarget()
	local target = self.target;
	local blRefresh = false;
	local pkType = self.info.pkType;
	if(target == nil) then
		blRefresh = true
	elseif(target ~= self) then	 
		if(target.info.camp ~= 0) then
			if(target.info.camp ~= self.info.camp) then
				blRefresh = true;
			else				 
				if(pkType == 0) then
					if(target.info.camp ~= self.info.camp) then
						blRefresh = true;
					end
				elseif(pkType == 1) then
					if(target.info.pkState == 0) then
						blRefresh = true;
					end
				elseif(pkType == 2) then
					if((target.info.pkType == 0 and target.info.pkState == 0) or(target.info.pkType == 1 and target.info.pkState == 0)) then
						blRefresh = true;
					end
				elseif(pkType == 3) then
					blRefresh = true
				end
			end
		end
	end
 
	if(blRefresh) then
		if(self.pet) then
			self.pet:SetTarget(target);
		end
		if(self.puppet) then
			self.puppet:SetTarget(target);
		end
	end
end

-- 变身
function PlayerController:Shapeshift()
	if(self._roleCreater) then
		self._roleCreater.dress.c = self.info.dress.c
		self._roleCreater:Shapeshift();
	end
end

function PlayerController:ChangeRide()
	self._roleCreater.dress.h = self.info.dress.h
	
	if(self._roleCreater) then
		local rideData = RideManager.GetRideDataById(self._roleCreater.dress.h)
		if(rideData) then
			self._roleCreater:SetRideInfo(rideData.info)
			self:SetBuffActive(false)
		else
			self._roleCreater:SetRideInfo(nil)
			self:SetBuffActive(true)
		end
		
		if(not self:IsRideHide()) then
			self._roleCreater:ChangeRide()
		end
	end
end

-- 武器
function PlayerController:ChangeWeapon()
	self._roleCreater.dress.a = self.info.dress.a
	if(not self:IsWeaponHide()) then
		self._roleCreater:ChangeWeapon()
	end
end

-- 衣服(装备)
function PlayerController:ChangeBody()
	self._roleCreater.dress.b = self.info.dress.b
	self._roleCreater:ChangeBody(true)
end

-- 翅膀(装备)
function PlayerController:ChangeWing()
	self._roleCreater.dress.w = self.info.dress.w
	if(not self:IsWingHide()) then
		self._roleCreater:ChangeWing()
	end
end


function PlayerController:ChangeTrump()
	self._roleCreater.dress.t = self.info.dress.t
	if(not self:IsTrumpHide()) then
		self._roleCreater:ChangeTrump()
	end
end

function PlayerController:ChangeEquipEffect()
	self._roleCreater.dress.bp = self.info.dress.bp
	self._roleCreater:ChangeEquipEffect()	
end

function PlayerController:ChangeWeaponEffect()	
	self._roleCreater.dress.ap = self.info.dress.ap
	self._roleCreater:ChangeWeaponEffect()
end

function PlayerController:LoadLevelUpEffect()
	local go = Resourcer.Get("Effect/UIEffect", "levelUp", self.transform)
	
	if(go) then
		Resourcer.RecycleDelay(go, 1.5, true)
	end
end

function PlayerController:ResetTransform(pos)
	UIUtil.AddChild(nil, self.transform);
	if pos ~= nil then
		Util.SetPos(self.transform, pos.x, pos.y, pos.z)
		--        self.transform.position = Vector3.New(pos.x, pos.y, pos.z);
	end
end

--[[当上飞行载具的时候， 如果同时还处战斗载具中的时候，需要暂战斗载具状
]]
function PlayerController:CheckAndPaushLandMount()
	if self._mountLangController ~= nil then
		self._mountLangController:Paush();
	end
end

--[[当下飞行载具的时候， 如果同时还处战斗载具中的时候，需要重新设置进入战斗载具状
]]
function PlayerController:CheckAndReLandMount()
	if self._mountLangController ~= nil then
		self._mountLangController:ReStart();
	end
end

function PlayerController:DressInMount(countInfo)
	
	local mount_config = ConfigManager.GetMount(countInfo.mount_id)
	
	self.info.dress.m = countInfo.mount_id;
	
	local mtype = mount_config.type;
	
	if mtype == MountManager.TYPE_F_MOUNT then
		-- 飞行载具
		self:CheckAndPaushLandMount()
		
		if self._mountController == nil then
			
			self._mountController = MountController:New(mount_config, PlayerController.FMountInitComplete, self);
		else
			
			if not self._mountController.loadingMode then
				
				self:FMountInitComplete(self._mountController);
			end
			
		end
		
	elseif mtype == MountManager.TYPE_L_MOUNT then
		-- 地面载具
		if self._mountLangController ~= nil then
			self._mountLangController:Stop(true);
			
		end
		
		if self._mountLangController == nil then
			self._mountLangController = MountLangController:New(countInfo.mount_id, nil, self);
			self._mountLangController:Start(self, nil);
			self._mountLangController.id = self.id;
		end
		
	end
	self:SetBuffActive(false)
	self.info.dress.m = countInfo.mount_id;
	
end


function PlayerController:FMountInitComplete(target)
	
	self._mountController = target;
	
	if self.mvData == nil or self.mvData.per == nil or self.mvData.paths == nil then
		
		-- 飞行载具 没有 进度信息那么不进行移动， 收到 031B 的同步指令再处理
		-- 这情况发生在在别人正飞行载具的时下线自己在别人的下线点站着别人又上线时 还带载具的情
		return;
	end
	
	self._mountController:Start(self);
	
	if self._mountController ~= nil then
		
		if self.mvData ~= nil and self.mvData.paths ~= nil then
			
			self._mountController:MoveToTarget(self.mvData.paths.id, self.mvData.per, false);
			local transform = self._mountController.transform;
			
			local pos = self.mvData.pos;
			Util.SetPos(transform, pos.x * 0.01, pos.y * 0.01, pos.z * 0.01)
			--            transform.position = Vector3.New(pos.x * 0.01, pos.y * 0.01, pos.z * 0.01);
			transform.rotation = Quaternion.Euler(0, pos.a * 0.01, 0);
			
		end
		self:Lock();
	end
	
	self:UpdateNamePanel()
	
end

function PlayerController:DressOutMount()
	
	
	if self._mountController ~= nil then
		self._mountController:Stop();
		self._mountController = nil;
		
	end
	
	if self._mountLangController ~= nil then
		self._mountLangController:Stop();
		self._mountLangController = nil;
	end
	
	
	if self.info ~= nil then
		self.info.dress.m = 0;
	end
	
	self:UpdateNamePanel()
	self:ReStand();
	self:SetBuffActive(true)
end


function PlayerController:MoveByAngleByMount(a, pos, speed)
	
	
	
	if self._mountLangController ~= nil then
		-- self._mountLangController:StopAction(3);
		self._mountLangController:PMoveToAngle(a, pos, speed);
	end
	
end

function PlayerController:MoveEndByMount(data)
	
	if self._mountLangController ~= nil then
		self._mountLangController:StopAction(3);
		self._mountLangController:PStand(Convert.PointFromServer(data.x, data.y, data.z));
	end
end


-- 进入 载具模式
function PlayerController:OnMount(x, y, z, a, mount_id, rid, per, mv, paths)
	
	
	self.mvData = {};
	
	if rid ~= nil then
		self.mvData.paths = ConfigManager.GetMovePath(rid);
	else
		self.mvData.paths = nil;
	end
	
	if a == nil then
		a = 0;
	end
	
	self.mvData.per = per;
	
	self.mvData.pos = {x = x, y = y, z = z, a = a};
	
	self:DressInMount({id = 0, x = self.mvData.pos.x, y = self.mvData.pos.y, z = self.mvData.pos.z, mount_id = mount_id});
	-- Error(tostring(self._mountLangController) .. '____' .. tostring(mv))
	if self._mountLangController ~= nil then
		local transform = self._mountLangController.transform;
		Util.SetPos(transform, x * 0.01, y * 0.01, z * 0.01)
		--        transform.position = Vector3.New(x * 0.01, y * 0.01, z * 0.01);
		transform.rotation = Quaternion.Euler(0, a * 0.01, 0);
		if(mv ~= nil and mv.st == 1) then
			self._mountLangController:PMoveToAngle(mv.a);
		elseif paths ~= nil then
			self._mountLangController:MoveToPath(paths);
		end
	end
	
	self:UpdateNamePanel()
	
end


function PlayerController:UpdateNamePanel()
	
	
	if(self.namePanel) then
		
		if self._mountLangController ~= nil then
			self.namePanel:SetTop(self._mountLangController:GetNamePoint());
		else
			self.namePanel:SetTop(nil);
		end
		
		self.namePanel:UpdateOtherInfo()
	end
end
function PlayerController:UpdateOtherInfo(tgn)
	if(self.namePanel) then
		self.info.tgn = tgn
		self.namePanel:UpdateOtherInfo()
	end
end

--  退载具 模式
function PlayerController:OutMount(notNeedSendToServer)
	
	
	self:UnLock();
	if self._mountController ~= nil then
		self._mountController = nil;
	end
	
	if self.info ~= nil then
		self.info.dress.m = 0;
	end
	
	if(self._roleCreater ~= nil and self._roleCreater.dress) then
		self._roleCreater.dress.m = 0
	end
	
	self.transform.rotation = Quaternion.Euler(0, 0, 0);
	-- 位置设置为靠地面
	--    local pos = self.transform.position;
	--    local pt = Vector3(pos.x, pos.y, pos.z);
	MapTerrain.SampleTerrainPositionAndSetPos(self.transform)
	--    self.transform.position = MapTerrain.SampleTerrainPosition(pt);
	self:UpdateNamePanel()
	self:ReStand();
end

function PlayerController:OutMountComplete()
	
	self:CheckAndReLandMount()
end

-- 使用技
function PlayerController:CastSkill(skill)
	
	if self._mountLangController ~= nil then
		self._mountLangController:PCastSkill(skill);
	else
		if(not self:IsDie() and skill) then
			self:StopAction(3);
			self:DoAction(SkillAction:New(skill));
		end
	end
end

function PlayerController:OutMountLang(notSendToServer)
	
	if self._mountLangController ~= nil then
		self._mountLangController = nil;
	end
	
	if(self._roleCreater ~= nil and self._roleCreater.dress) then
		self._roleCreater.dress.m = 0
		
	end
	
	if self.info ~= nil then
		self.info.dress.m = 0;
	end
	
	self:UpdateNamePanel()
	self:ReStand();
end

function PlayerController:ReStand()
	local ct = self:GetRoleCreater();
	if ct ~= nil then
		if(self._roleCreater.dress.h ~= 0) then
			self._roleCreater:SetIsOnRide(true)
		end
		ct:Play("stand");
	end
end

--[[获取 战斗载具控制
]]
function PlayerController:Get_mountLangController()
	return self._mountLangController;
end



--[[ 是否正在飞行载具
]]
function PlayerController:IsOnFMount()
	if self._mountController ~= nil then
		return true;
	end
	return false;
end


function PlayerController:GetMountName()
	
	if self._mountLangController ~= nil then
		return self._mountLangController:GetName();
	end
	
	if self._mountController ~= nil then
		return self._mountController:GetName();
	end
	
	return nil;
end

--[[ 是否正在战斗载具
]]
function PlayerController:IsOnLMount()
	if self._mountLangController ~= nil then
		return true;
	end
	return false;
end


function PlayerController:_DisposeHandler()
	self:StopFightStatusTimer();
	self:DressOutMount();
end


function PlayerController:Get_mountController()
	return self._mountController;
end

function PlayerController:IsOnRide()
	if(self._roleCreater) then
		return self._roleCreater:IsOnRide()
	end
	return false;
end

function PlayerController:IsBodyHide()
	return self._isBodyHide or false
end

------------------------------------------------------------
-- 隐藏 body
function PlayerController:HideBody()
	self._isBodyHide = true
	if(self._roleCreater) then
		self._roleCreater:SetActive(false)
	end
end

-- 恢复 body
function PlayerController:ShowBody()
	self._isBodyHide = false
	
	if(self._roleCreater) then
		self._roleCreater:SetActive(true)
	end
end

function PlayerController:IsWeaponHide()
	return self._isWeaponHide or false
end

------------------------------------------------------------
-- 隐藏 
function PlayerController:HideWeapon()
	self._isWeaponHide = true
	if(self._roleCreater) then
		self._roleCreater:RemoveWeapon(true)
	end
end

-- 恢复 
function PlayerController:ShowWeapon()
	self._isWeaponHide = false
	self:ChangeWeapon()
end

function PlayerController:IsWingHide()
	return self._isWingHide or false
end

------------------------------------------------------------
-- 隐藏 
function PlayerController:HideWing()
	self._isWingHide = true
	local creater = self:GetRoleCreater()
	if(creater and creater.dress.w and creater.dress.w ~= 0) then
		self:SetRoleWingActive(false)
	end
end

-- 恢复 
function PlayerController:ShowWing()
	self._isWingHide = false
	local creater = self:GetRoleCreater()
	if(creater and creater.dress.w and creater.dress.w ~= 0) then
		self:SetRoleWingActive(true)
	end
end

function PlayerController:IsPetHide()
	return self._isPetHide or false
end

------------------------------------------------------------
-- 隐藏 
function PlayerController:HidePet()
	self._isPetHide = true
	--    local pet = self:GetPet()
	--    if (pet) then
	--        SceneMap.GetActiveMgr():Remove(pet.id)
	--        self:PetVisible(false)
	--        self:SetPetAI(false)
	--    end
end

-- 恢复 
function PlayerController:ShowPet()
	self._isPetHide = false
	--    local pet = self:GetPet()
	--    if (pet) then
	--        SceneMap.GetActiveMgr():AddPlayerPet(pet, pet.gameObject)
	--        self:PetVisible(true)
	--        self:SetPetAI(true)
	--    end
end

function PlayerController:IsPuppetHide()
	return self._isPuppetHide or false
end
------------------------------------------------------------
-- 隐藏 傀傀儡销毁改为后端触
function PlayerController:HidePuppet()
	--    self._isPuppetHide = true
	--    local puppet = self:GetPuppet()
	--    if (puppet) then
	--        SceneMap.GetActiveMgr():Remove(puppet.id)
	--        self:PuppetVisible(false)
	--        self:SetPuppetAI(false)
	--    end
end

-- 恢复 
function PlayerController:ShowPuppet()
	--    self._isPuppetHide = false
	--    local puppet = self:GetPuppet()
	--    if (puppet) then
	--        SceneMap.GetActiveMgr():AddPlayerPet(puppet, puppet.gameObject)
	--        self:PuppetVisible(true)
	--        self:SetPuppetAI(true)
	--    end
end

function PlayerController:IsTrumpHide()
	return self._isTrumpHide or false
end

------------------------------------------------------------
-- 隐藏 
function PlayerController:HideTrump()
	self._isTrumpHide = true
	if(self._roleCreater) then
		self._roleCreater:RemoveTrump()
	end
end

-- 恢复 
function PlayerController:ShowTrump()
	self._isTrumpHide = false
	if(self._roleCreater) then
		self:ChangeTrump()
	end
end

function PlayerController:IsRideHide()
	return self._isRideHide or false
end

------------------------------------------------------------
-- 隐藏 坐骑 -ok
function PlayerController:HideRide()
	self._isRideHide = true
	if(self._roleCreater) then
		self._roleCreater:ResetTransformToParent()
		self._roleCreater:RemoveRide()
	end
end

-- 恢复 
function PlayerController:ShowRide()
	self._isRideHide = false
	if(self._roleCreater) then
		self:ChangeRide()
	end
end

function PlayerController:_OnLoadModelSourceOtherSetting()
	if(self.info.hp == 0) then
		self:Die(false)
	end
end

-- function PlayerController:Play(name)
--    if (self:IsOnRide()) then
--        if ((not self:IsDie())) then
--            if (self._roleCreater) then
--                if (name == "stand" or name == "run") then
--                    self._roleCreater:Play(self.rideInfo.action_id);
--                else
--                    self._roleCreater:Play(name);
--                end
--            end
--            if (self._rideCreater) then
--                if (name == "stand" or name == "run") then
--                    self._rideCreater:Play(name);
--                end
--            end
--        end
--    else
--        if ((not self:IsDie()) and self._roleCreater) then
--            self._roleCreater:Play(name);
--        end
--    end
-- end
