require "Core.Role.ModelCreater.BaseModelCreater"
require "Core.Role.ModelCreater.WingCreater"
require "Core.Module.Common.EquipEffect"

RoleModelCreater = class("RoleModelCreater", BaseModelCreater);

function RoleModelCreater:New(data, parent, asyncLoad, onLoadedSource, withRide)
	self = {};
	setmetatable(self, {__index = RoleModelCreater});
	
	self._withRide = true
	if(withRide ~= nil) then
		self._withRide = withRide
	end
	
	if(asyncLoad ~= nil) then
		self.asyncLoadSource = asyncLoad
	else
		self.asyncLoadSource = true
	end
	-- 是否异步加载模型
	self.onLoadedSource = onLoadedSource
	-- 异步加载后回调
	self.hasCollider = true
	-- 是否要挂点击触发器
	self._isWingActive = AutoFightManager.GetBaseSettingConfig().showWing
	self.showShadow = true
	self:Init(data, parent);
	return self;
end
-- 传入数据包括kind以及Dress
function RoleModelCreater:_Init(data)
	self._handPoint = {}
	self._partCount = 0
	self.onEnableOpen = true
	self.dress = ConfigManager.Clone(data.dress)
	self.kind = data.kind
	local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER) [data.kind]
	self.model_id = config.model_id
	self.weapon_id = config.weapon_id
	self.hang_point = config.hang_point
	self.skeleton_id = config.skeleton_id
	if(data.dress.h and data.dress.h ~= 0) then
		self._isOnRide = true
		local rideData = RideManager.GetRideDataById(self.dress.h)
		self:SetRideInfo(rideData.info)
	end
	self._isDispose = false
end

function RoleModelCreater:_GetModern()
	return self:_GetSkeleton()
end
function RoleModelCreater:_GetSourceAnim()
	return self.useDefualtMode and self:_GetModelDefualt() or self.skeleton_id
end
function RoleModelCreater:_GetSourceDir()
	return "Heros"
end
function RoleModelCreater:_GetSkeleton()
	return "Roles", self.skeleton_id;
end
function RoleModelCreater:_GetBody(id)	
	return "Roles", self:_GetBodyModelId(id)	
end

function RoleModelCreater:_GetBodyModelId(id)
	if(id == 0) then
		return self.model_id
	else
		return ProductManager.GetProductById(id).model_id
	end
	
end

function RoleModelCreater:_GetWeapon(id)
	if(id ~= nil) then	
		return "Equip/Weapon", self:_GetWeaponModelId(id)		
	end
	return nil;
end

function RoleModelCreater:_GetWeaponModelId(id)
	
	if(id == 0) then
		return self.weapon_id
	else
		return ProductManager.GetProductById(id).model_id
	end
	
	return nil;
end


function RoleModelCreater:_GetWing(id)
	local info = WingManager.GetFashionById(id)
	if(info == nil) then
		log("找不到id" .. id)
	end
	return "Equip/Wings", info.model_id, info.model_scale_rate
	-- return "Equip/Wings", WingManager.GetWingConfigById(id, 1).model_id
end
function RoleModelCreater:_GetTrump(id)
	return "Equip/Trump", NewTrumpManager.GetTrumpConfigById(id).model_id
end

-- 复制角色形象数据,用于组装角色,data角色数据,hasWing加翅膀,hasTrump有法宝,hasMountOrRide有坐骑或载具
function RoleModelCreater.CloneDress(data, hasWing, hasTrump, hasMountOrRide)
	local result = {}
	result.kind = data.kind
	local dress = ConfigManager.Clone(data.dress)
	dress.ap = 0
	dress.bp = 0
	if not hasWing then dress.w = nil end
	if not hasTrump then dress.t = nil end
	if not hasMountOrRide then dress.m = nil dress.h = nil end
	result.dress = dress
	return result;
end

function RoleModelCreater:_InitAvtar()
	self._roleAvtar:SetSkeleton(self._role)
	-- 角色组成部位总数 ,用于加载计算完成
	-- 角色组成部位加载完成计算
	if(self.dress ~= nil) then
		
		self:ChangeBody(true)
		-- 翅膀
		if(self.dress.w and self.dress.w ~= 0 and self._isWingActive) then
			self:ChangeWing()
		end
		-- 武器
		self:ChangeWeapon()
		-- 法宝
		if(self.dress.t and self.dress.t ~= 0) then
			self:ChangeTrump()
		end
		
		if(self.dress.h and self.dress.h ~= 0) then
			local rideData = RideManager.GetRideDataById(self.dress.h)
			self:SetRideInfo(rideData.info)
		end
		
		-- 坐骑
		if(self.dress.h and self.dress.h ~= 0 and(self.dress.m == nil) or(self.dress.m == 0)) then
			self:ChangeRide()
		end
	end
end

function RoleModelCreater:ChangeData(data)
	self.dress = ConfigManager.Clone(data.dress)
	if(self.dress ~= nil) then
		self:ChangeBody(true)
		-- 翅膀
		if(self.dress.w and self.dress.w ~= 0 and self._isWingActive) then
			self:ChangeWing()
		end
		-- 武器
		self:ChangeWeapon()
		-- 法宝
		if(self.dress.t and self.dress.t ~= 0) then
			self:ChangeTrump()
		end
		
		if(self.dress.h and self.dress.h ~= 0) then
			local rideData = RideManager.GetRideDataById(self.dress.h)
			self:SetRideInfo(rideData.info)
		end
		
		-- 坐骑
		if(self.dress.h and self.dress.h ~= 0 and(self.dress.m == nil) or(self.dress.m == 0)) then
			self:ChangeRide()
		end
	end
end

-- 变身
function RoleModelCreater:Shapeshift()
	if(self.dress.c ~= "") then
		if(self._parent) then
			if(self._role ~= nil) then
				self._oriRole = self._role;
				self._oriRole:SetActive(false);
			end
			-- self._role = Resourcer.Get("Roles", self.dress.c, self._parent)
			local func = System.Action_UnityEngine_GameObject(function(args)
				if self._isDispose or IsNil(self._role) then
					Resourcer.Recycle(args, false)
					return
				end
				self._role = args
				self._role.layer = self._layer;
				self._roleAnimator = self._role:GetComponent("Animator");
				local allChildTransForm = UIUtil.GetComponentsInChildren(self._role, "Transform")
				self:AddWeapon(allChildTransForm);
			end)
			Resourcer.GetAsync("Roles", self.dress.c, self._parent, func)
		end
	else
		if(self._oriRole ~= nil) then
			local tmp = self._role;
			tmp:SetActive(false);
			Resourcer.Recycle(tmp, false);
			self._role = self._oriRole;
			self._role:SetActive(true);
			self._roleAnimator = self._role:GetComponent("Animator");
			self._roleAvtar = self._role:GetComponent("Avtar");
			self:ChangeWeapon()
			self:Play(self._actionName);
			self._oriRole = nil;
		end
	end
end

-- 返回默认的模型衣服
function RoleModelCreater:_GetBodyDefualt()
	return self.model_id
end

-- 衣服(装备)
function RoleModelCreater:ChangeBody(generate)
	local f, p = self:_GetBody(self.dress.b)
	self:_LoadBody(generate, f, p)
end
function RoleModelCreater:_LoadBody(generate, f, p)
	if not self._role then return end -- 模型还没加载
	local func = function(bodyPrefab)
		self.bodyPath = f .. '/' .. p
		if self._isDispose or IsNil(self._role) then
			Resourcer.Recycle(self.bodyPath, true)
			self.bodyPath = nil
			return
		end
		if IsNil(bodyPrefab) and p ~= self:_GetBodyDefualt() then
			p = self:_GetBodyDefualt()
			if p then self:_LoadBody(generate, f, p) end
			return
		end
		self._roleAvtar:ChangeSkinnedMesh("body", bodyPrefab, false)
		if generate then self:_GenerateMesh() end
		self:ChangeEquipEffect()
		self:SetLayer(self._layer)
	end
	Resourcer.GetPrefabAsync(f, p, func)
end
-- 翅膀(装备)
function RoleModelCreater:ChangeWing()
	
	if not self._role then return end -- 模型还没加载
	self:_RemoveWing()
	if((self.dress.w == 0) or(not self._isWingActive)) then
		
	else
		local f, p, s = self:_GetWing(self.dress.w)
		if(self._cbParent == nil) then
			self._cbParent = self:GetHangingPoint("B_CB")
		end
		if(self._wingCreater == nil) then
			self._wingCreater = WingCreater:New({model_id = p, model_scale = s}, self._cbParent, false, self)
		end
	end
end

-- 生成蒙皮
function RoleModelCreater:_GenerateMesh()
	self._roleAvtar:Generate()
	self:_OnUpdatePart(ModelType.Body, self._role)
	self:_OnModeInited()
	Resourcer.Recycle(self.bodyPath, false)
end
-- 部分资源更新时
function RoleModelCreater:_OnUpdatePart(partName, part)
	
end
function RoleModelCreater:_InitRender()
	if self._isDispose or IsNil(self._role) then return end
	if not self._render then
		self._render = self._role.renderer
	end
	self:PlayLast()
	self:_OnInitRender()
end

-- 返回默认的模型
function RoleModelCreater:_GetWeaponDefualt()
	return self.weapon_id
end

-- 武器
function RoleModelCreater:ChangeWeapon()
	self:AddWeapon()
end
function RoleModelCreater:AddWeapon(allChildTransForm)
	if not self._role or self._isDispose then return end -- 模型还没加载
	local f, p = self:_GetWeapon(self.dress.a)
	if(f ~= nil and p ~= nil) then
		self:_LoadWeapon(f, p, allChildTransForm)
	end
end
function RoleModelCreater:_LoadWeapon(f, p, allChildTransForm)
	local handPoint = self.hang_point
	if(self._rightTrf == nil) then
		if(allChildTransForm) then
			self._rightTrf = UIUtil.GetChildInComponents(allChildTransForm, handPoint[1])
		else
			self._rightTrf = self:GetHangingPoint(handPoint[1])
		end
	end
	self:_RemoveWeapon()
	local func = System.Action_UnityEngine_GameObject(function(equipPrefab)
		if self._isDispose or IsNil(self._role) then
			Resourcer.Recycle(equipPrefab, self:_CanPoolMode())
			return
		end
		if IsNil(equipPrefab) and p ~= self:_GetWeaponDefualt() then
			p = self:_GetWeaponDefualt()
			if p then self:_LoadWeapon(f, p, allChildTransForm) end
			return
		end

        if self._rightWeapon then
            Resourcer.Recycle(self._rightWeapon, false)
            self._rightWeapon = nil
        end
	    if self._leftWeapon then
            Resourcer.Recycle(self._leftWeapon, false)
            self._leftWeapon = nil
        end

		self._rightWeapon = equipPrefab;
		self:_OnUpdatePart(ModelType.Weapon, self._rightWeapon);
		
		if(table.getCount(handPoint) == 2) then			
			if(self._leftTrf == nil) then
				if(allChildTransForm) then
					self._leftTrf = UIUtil.GetChildInComponents(allChildTransForm, handPoint[2])
				else
					self._leftTrf = self:GetHangingPoint(handPoint[2])
				end
			end			
			self._leftWeapon = Resourcer.Clone(equipPrefab, self._leftTrf)
			self:_OnUpdatePart(ModelType.Weapon, self._leftWeapon);
		end
		self:ChangeWeaponEffect()
		self:SetLayer(self._layer)
	end)
	Resourcer.GetAsync(f, p, self._rightTrf, func)
end
-- 法宝
function RoleModelCreater:ChangeTrump()
	if not self._role or self._isDispose then return end -- 模型还没加载
	self:_RemoveTrump()
	if(self.dress.t and(self.dress.t ~= 0)) then
		local f, p = self:_GetTrump(self.dress.t)
		self:_LoadTrump(f, p)
	end
end
function RoleModelCreater:_LoadTrump(f, p)
	local func = System.Action_UnityEngine_GameObject(function(go)
		self:_RemoveTrump()
		
		if self._isDispose or IsNil(self._role) then
			Resourcer.Recycle(go, self:_CanPoolMode())
			return
		end
		
		if IsNil(go) and p ~= "trump_htj" then --加载默认法宝
			p = "trump_htj"
			self:_LoadTrump(f, p)
			return
		end
		
		self._trump = go;
		if(not self._isHero) then
			self._trump:SetActive(AutoFightManager.GetBaseSettingConfig().showTrump)
		end
		
		self:SetLayer(self._layer)
		if(self._trump) then
			UIUtil.GetComponent(self._trump, "Animator"):Play("atstand")
		end
		
		self:_OnUpdatePart(ModelType.Trump, self._trump)
	end)
	Resourcer.GetAsync(f, p, self:GetTrumpParent(), func)
end

function RoleModelCreater:ResetTransformToParent()
	if self._transform then
		UIUtil.AddChild(self._parent, self._transform)
	end
end

-- 坐骑
function RoleModelCreater:ChangeRide()
	if not self._role or self._isDispose then return end -- 模型还没加载
	self._isOnRide = false
	if(not self._withRide) then return end
	
	self:ResetTransformToParent()
	self:_RemoveRide()
	
	if(self.dress.h and(self.dress.h ~= 0)) then
		self._isOnRide = true
		self._rideCreater = RideModelCreater:New()
		self:_SetRideCreater(self._rideCreater)
		self._rideCreater:Init(self._rideInfo, self._parent)
		local handPoint = self._rideCreater:GetHangingPoint(self._rideInfo.hang_point)
		UIUtil.AddChild(handPoint, self._transform)
		self:SetLayer(self._layer)
		self:PlayLast()
	end
end
function RoleModelCreater:_SetRideCreater(rideCreater)
end
function RoleModelCreater:SetRideInfo(rideInfo)
	self._rideInfo = rideInfo
end
function RoleModelCreater:GetRideInfo()
	return self._rideInfo
end
function RoleModelCreater:IsOnRide()
	return self._isOnRide
end
function RoleModelCreater:GetRideCreater()
	return self._rideCreater
end

function RoleModelCreater:SetIsOnRide()
	self._isOnRide = true
end

-- 动画播放
function RoleModelCreater:Play(name, returnActionTime)
	if(self:IsOnRide()) then
		if(name == "stand") or(name == "run") then
			self._rideActionName = name
			-- 保存起来, 有时坐骑还没加载好
			name = self._rideInfo and self._rideInfo.action_id or self._rideActionName
		end
		if(self._rideActionName and self._rideCreater) then
			--local aInfo = self._rideCreater:GetAnimatorStateInfo();
			--if(aInfo == nil or(aInfo and not aInfo:IsName(self._rideActionName))) then				
			self._rideCreater:Play(self._rideActionName)
			--end
		end
	end	
	return self:_Play(name, returnActionTime)
end

-- 清理
function RoleModelCreater:_RemoveWeapon()
	if(self._weaponEffect1) then
		self._weaponEffect1:Dispose()
		self._weaponEffect1 = nil
	end
	
	if(self._weaponEffect2) then
		self._weaponEffect2:Dispose()
		self._weaponEffect2 = nil
	end
	
	if self._rightWeapon then			
		Resourcer.Recycle(self._rightWeapon, self:_CanPoolMode())
		self._rightWeapon = nil
	end
	if self._leftWeapon then
		Resourcer.Recycle(self._leftWeapon, self:_CanPoolMode())
		self._leftWeapon = nil
	end
end

function RoleModelCreater:RemoveWeapon()
	self:_RemoveWeapon()
end

function RoleModelCreater:_RemoveTrump()
	if self._trump then
		Resourcer.Recycle(self._trump, self:_CanPoolMode())
		self._trump = nil
	end
end

function RoleModelCreater:RemoveTrump()
	self:_RemoveTrump()
end


function RoleModelCreater:_RemoveRide()
	if self._rideCreater then
		self._rideCreater:Dispose()
		self._rideCreater = nil
	end
	self._isOnRide = false
end

function RoleModelCreater:RemoveRide()
	self:_RemoveRide()
end

function RoleModelCreater:_RemoveWing()
	if(self._wingCreater) then
		self._wingCreater:Dispose()
		self._wingCreater = nil
	end
end

function RoleModelCreater:_DisposeModel()
	local r = self._role
	if r then
		if(self._equipEffect) then
			self._equipEffect:Dispose()
			self._equipEffect = nil
		end
		
		local rr = self._render
		if rr then GameObject.DestroyImmediate(rr) end
		Resourcer.Recycle(r, self:_CanPoolMode())
		self._role = nil
	end
	if self.bodyPath then Resourcer.Recycle(self.bodyPath, true) self.bodyPath = nil end
end
function RoleModelCreater:_Dispose()
	if self._isDispose then return end
	self:_RemoveWeapon()
	self:_RemoveTrump()
	self:_RemoveRide()
	self:_RemoveWing()
	if self._roleAvtar then self._roleAvtar.onEnable = nil end
	self._btParent = nil
	self._leftTrf = nil
	self._rightTrf = nil
	self._handPoint = nil
	self._cbParent = nil
end

function RoleModelCreater:SetWingActive(active)
	self._isWingActive = active
	self:ChangeWing()
end

function RoleModelCreater:ChangeWeaponEffect()
	
	if(self._isDispose == true) then return end
	local colorConfig =	NewEquipStrongManager.GetPromoteColorByLevel(self.dress.ap)
	local config =	NewEquipStrongManager.GetPromoteEffectByName(self:_GetWeaponModelId(self.dress.a))
	
	if(self._rightWeapon) then
		if(colorConfig) then
			if(config) then
				if(self._weaponEffect1 == nil) then
					self._weaponEffect1 = EquipEffect:New()
					self._weaponEffect1:Init(config, self._rightTrf)	
				end
				local color = Color.New(colorConfig.glow_color[1] / 255, colorConfig.glow_color[2] / 255,
				colorConfig.glow_color[3] / 255, colorConfig.glow_color[4] / 255)
				
				self._weaponEffect1:ChangeGlowColor(color)
				self._weaponEffect1:ChangeSmokeColor(color)	
			end
		else
			if(self._weaponEffect1) then
				self._weaponEffect1:Dispose()
				self._weaponEffect1 = nil		
			end
		end
		
	end
	
	if(self._leftWeapon) then
		if(colorConfig) then
			if(config) then
				if(self._weaponEffect2 == nil) then
					self._weaponEffect2 = EquipEffect:New()
					self._weaponEffect2:Init(config, self._leftTrf)	
				end
				
				local color = Color.New(colorConfig.glow_color[1] / 255, colorConfig.glow_color[2] / 255,
				colorConfig.glow_color[3] / 255, colorConfig.glow_color[4] / 255)
				
				self._weaponEffect2:ChangeGlowColor(color)
				self._weaponEffect2:ChangeSmokeColor(color)	
				
			end
		else
			if(self._weaponEffect2) then
				self._weaponEffect2:Dispose()
				self._weaponEffect2 = nil
			end
		end
		
	end
end

function RoleModelCreater:ChangeEquipEffect()		
	if(self._isDispose == true) then return end
	local colorConfig = NewEquipStrongManager.GetPromoteColorByLevel(self.dress.bp)
	if(colorConfig) then		
		local config =	NewEquipStrongManager.GetPromoteEffectByName(self:_GetBodyModelId(self.dress.b))	
		if(config) then
			
			if(self._equipEffect == nil) then
				self._equipEffect = EquipEffect:New()
				self._equipEffect:Init(config, self._btParent)	
			end
			local color1 = Color.New(colorConfig.glow_color[1] / 255, colorConfig.glow_color[2] / 255,
			colorConfig.glow_color[3] / 255, colorConfig.glow_color[4] / 255)
			local color2 = Color.New(colorConfig.smoke_color[1] / 255, colorConfig.smoke_color[2] / 255,
			colorConfig.smoke_color[3] / 255, colorConfig.smoke_color[4] / 255)
			self._equipEffect:ChangeGlowColor(color1)
			self._equipEffect:ChangeSmokeColor(color2)			
		end
	else
		if(self._equipEffect) then
			self._equipEffect:Dispose()
			self._equipEffect = nil
		end
	end			
end

function RoleModelCreater:SetEquipAndWeaponeEffectActive(active)
	if(self._equipEffect) then
		self._equipEffect:SetActive(active)
	end
	
	if(self._weaponEffect1) then
		self._weaponEffect1:SetActive(active)
	end

	if(self._weaponEffect2) then
		self._weaponEffect2:SetActive(active)
	end
end


function RoleModelCreater:_GetDefaltPoint()
	-- self._allChildTransForm = UIUtil.GetComponentsInChildren(self._role, "Transform");
	self._roleCenter = self:GetHangingPoint("S_Spine")
	self._roleTop = self:GetHangingPoint("S_Head")
	self._namePoint = self:GetHangingPoint("Top")
	if(self._namePoint == nil) then
		self._namePoint = self._roleTop
	end		
	self._trumpParent = self:GetHangingPoint("B_FB")
	self._btParent = self:GetHangingPoint("S_BT")
end

function RoleModelCreater:GetHangingPoint(name)
	if(self._handPoint[name] == nil) then
		if(self._role and self.skeleton_id) then
			self._handPoint[name] = UIUtil.GetChildByName(self._role, BaseModelCreater.GetRoleBonePath(self.skeleton_id, name))		
			-- return UIUtil.GetChildInComponents(self._allChildTransForm, name);	 
		end
	end
	return self._handPoint[name]
end

-- function RoleModelCreater:GetEquipEffect(level, model_id, effectRef)	
-- 	local colorConfig = NewEquipStrongManager.GetPromoteColorByLevel(level)
-- 	if(colorConfig) then
-- 		local config =	NewEquipStrongManager.GetPromoteEffectByName(model_id)
-- 		if(config) then
-- 			if(effectRef == nil) then
-- 				effectRef = Resourcer.Get("BuffEffect", config.effect_name)
-- 			end
-- 			--设置颜色
-- 		end
-- 	else
-- 		if(effectRef) then
-- 			Resourcer.Recycle(effectRef, true)
-- 		end
-- 	end		
-- end
