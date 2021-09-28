BaseModelCreater = class("BaseModelCreater");
BaseModelCreater.checkAnimation = true -- GameConfig.instance.asyncAnimation
-- BaseModelCreater.reflectTexture = nil--反射调光图
ModelType = {Body = 1, Weapon = 2, Wing = 3, Trump = 4, Shape = 5}-- 模型资源类型
-- local ReflectTex = "_ReflectTex"
BaseModelCreater.allSources = {}-- 当前模型类型的所有角色,用于保留索引删除原始资源
--BaseModelCreater.allAnimDirs = { }-- 当前模型类型的所有角色,用于保留索引删除原始资源
RoleActionName = {defualt = "stand", stand = "stand", run = "run", wait = "wait", die = "die", atstand = "atstand"}-- 角色动作名常量
local Player_Name = {"tqm_0", "tyg_0", "tgz_0", "mxz_0"}
local Model_Effect_Dir = 'Effect/BuffEffect'
local _tableInsert = table.insert
local stringLen = string.len
local stringFind = string.find
local roleBone = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ROLE_BONE)
local modeEff = ConfigManager.GetConfig(ConfigManager.CONFIG_MODEL_EFFECT)

function BaseModelCreater.ClearModels()
	local allSources = BaseModelCreater.allSources
	for k, v in pairs(allSources) do Resourcer.Recycle(k, v) end
	BaseModelCreater.allSources = {}
end

--获取角色某一结点的路劲
function BaseModelCreater.GetRoleBonePath(parentName, boneName)
	local role = roleBone[parentName]
	if(role) then
		return role[boneName]	
	end
	
	return nil
end
function BaseModelCreater.ClearAnims(hero)
	--    local allAnimDirs = BaseModelCreater.allAnimDirs
	--    local heroCreater = hero and hero:GetRoleCreater() or nil
	--    local hanim = heroCreater and heroCreater.animDir or nil
	--    local heroRileCreater = heroCreater and heroCreater:GetRideCreater() or nil
	--    local hRanim = heroRileCreater and heroRileCreater.animDir or nil
	--    BaseModelCreater.allAnimDirs = { }
	--    for k, v in pairs(allAnimDirs) do
	--        --Warning(v .. tostring(hanim) .. tostring(hRanim))
	--        if v ~= hanim and v ~= hRanim then Avtar.Clear(v)
	--        else _tableInsert(BaseModelCreater.allAnimDirs,v) end
	--    end
end

function BaseModelCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = BaseModelCreater});
	self.asyncLoadSource = asyncLoad ~= nil and asyncLoad or false
	-- 异步加载资源
	self.onLoadedSource = onLoadedSource
	-- 异步加载资源完成时
	self:Init(data, parent)
	return self;
end

-- 数据中最少包含以下信息 kindId,dress
function BaseModelCreater:Init(data, parent, isHero)
	self._handPoint = {}
	self._isHero = isHero or false
	self._isDispose = false;
	self._isActive = true;
	self._parent = parent;
	if parent then self._layer = parent.gameObject.layer end
	self._isOnRide = false;
	self.checkAnimation = self:GetCheckAnimation();
	-- 要检查动画内容
	self:_Init(data);
	self:_LoadModel(self:_GetModern());
end

function BaseModelCreater:GetCheckAnimation()
	return BaseModelCreater.checkAnimation
end

function BaseModelCreater:Reset(data, parent, role)
	self._isActive = true;
	self._parent = parent
	if parent then self._layer = parent.gameObject.layer end
	self._role = role
	UIUtil.AddChild(self._parent, self._transform)
	self:_Init(data)
	self:_OnModelLoaded()
end

function BaseModelCreater:SetActive(v)
	self._isActive = v;
	self:_UpdateActive();
end

function BaseModelCreater:IsActive()
	if self._role and self._role then
		return self._role.activeSelf
	end
	return false;
end

function BaseModelCreater:_UpdateActive()
	if self._role and self._role then
		self._role:SetActive(self._isActive);
		if self._shadow then self._shadow:SetActive(self._isActive) end
	end
end

function BaseModelCreater:_Init(data)
	
end

function BaseModelCreater:_GetModern()
	return nil, nil
end
-- 返回默认的模型
function BaseModelCreater:_GetModelDefualt()
	return nil
end

-- local t = 0 local minTime = 0
function BaseModelCreater:_LoadModel(f, p)
	if(f and p and self._parent) then
		if self.asyncLoadSource then
			local func = System.Action_UnityEngine_GameObject(function(go)
				if self._isDispose or IsNil(self._parent) then
					if go then Resourcer.Recycle(go) end
					return
				end
				if IsNil(go) and p ~= self:_GetModelDefualt() then
					self.useDefualtMode = true
					p = self:_GetModelDefualt()
					if p then self:_LoadModel(f, p) end
					return
				end
				self._role = go
                self:_LoadEffect(p)
			end)
			Resourcer.GetAsync(f, p, self._parent, func)
		else
			self._role = Resourcer.Get(f, p, self._parent);
			if IsNil(self._role) and p ~= self:_GetModelDefualt() then
				self.useDefualtMode = true
				p = self:_GetModelDefualt()
				if p then self:_LoadModel(f, p) end
				return
			end
			self:_LoadEffect(p)
		end
	end
end

function BaseModelCreater:GetModeEffectId()
    return nil
end
function BaseModelCreater:_LoadEffect(p)
    local modeEffId = self:GetModeEffectId()
    if not modeEffId or #modeEffId == 0 then
        self:_OnModelLoaded()
        return 
    end
    local effLen = #modeEffId
    local effLoadedNum = 0
    self.effects = {}
    local func = System.Action_UnityEngine_GameObject(function(go)
        if self._isDispose or IsNil(self._parent) then
			if go then Resourcer.Recycle(go) end
			return
		end
        if go then
            if self._layer then NGUITools.SetChildLayer(go.transform, self._layer) end
            table.insert(self.effects, go)
        end
        effLoadedNum = effLoadedNum + 1
        if effLoadedNum == effLen then self:_OnModelLoaded() end
    end)
    for i = effLen, 1, -1 do
        local id = modeEffId[i]
	    local c = modeEff[id]
        if not c then Error("没有模型特效配置,id=" .. id) end
        local joint = c.joint 
        --空格 两个下划线,左括号 三个下划线,右括号 四个下划线
        local parentPath = c and BaseModelCreater.GetRoleBonePath(p, joint) or nil
        if not parentPath then Error("没有模型骨骼路径,parentPath=" .. tostring(parentPath)) end
        local bone = parentPath and UIUtil.GetChildByName(self._role, parentPath) or nil
        if not bone then Error("没有模型特效骨骼,bone=" .. tostring(bone)) end
        --Warning(id .. ':' ..tostring(parentPath) .. '-----' .. tostring(bone).. tostring(c.effect_id))
	    if bone then 
            if self.asyncLoadSource then
                Resourcer.GetAsync(Model_Effect_Dir, c.effect_id, bone, func)
            else
                local go = Resourcer.Get(Model_Effect_Dir, c.effect_id, bone)
                if go then
                    if self._layer then NGUITools.SetChildLayer(go.transform, self._layer) end
                    table.insert(self.effects, go)
                end
                effLoadedNum = effLoadedNum + 1
            end
        else
            effLoadedNum = effLoadedNum + 1
        end
        if effLoadedNum == effLen then self:_OnModelLoaded() end
    end
end

function BaseModelCreater:_OnModelLoaded()
	-- local t2 = UnityEngine.Time.realtimeSinceStartup - t
	-- if(t2 > minTime) then logTrace("_OnModelLoaded:time=" .. string.format("%0.3f",t2) ..",obj=" .. self._role.name)end
	if not IsNil(self._role) then
		
		self._transform = self._role.transform;
		-- self._allChildTransForm = UIUtil.GetComponentsInChildren(self._role, "Transform");
		self._roleAnimator = self._role:GetComponent("Animator");
		
		self:_GetDefaltPoint()
		self:_CreateAvtar()		
		if self.checkAnimation then self:_InitAnimation() end
		self:_InitAvtar()		
		self:_SetSelfLayer()	
		self:_UpdateActive();
	end
end

function BaseModelCreater:_GetDefaltPoint()
	self._roleCenter = self:GetHangingPoint("S_Spine")
	self._roleTop = self:GetHangingPoint("S_Head")
	self._namePoint = self:GetHangingPoint("Top")
	if(self._namePoint == nil) then
		self._namePoint = self._roleTop
	end		
end

function BaseModelCreater:_SetSelfLayer()
	local parent = self._parent.gameObject
	if parent then self._layer = parent.layer end
	if self._layer then self:SetLayer(self._layer) end
end

function BaseModelCreater:_InitAvtar()
	self:_OnModeInited()
end

function BaseModelCreater:_InitRender()
	if self._collider or self._isDispose then return end
	local render = self._render
	if not render then
		render = self._role.renderer
		if not render then
			local renders = UIUtil.GetComponentsInChildren(self._role, "SkinnedMeshRenderer")
			if renders and renders.Length > 0 then render = renders[0] end
		end
		if not render then
			local renders = UIUtil.GetComponentsInChildren(self._role, "MeshRenderer")
			if renders and renders.Length > 0 then render = renders[0] end
		end
		self._render = render
	end
	self:_OnInitRender()
end
function BaseModelCreater:_OnInitRender()
	local render = self._render
	if render then
		render.receiveShadows = false
		render.castShadows = true
	end
	if render and self.hasCollider then
		self:_InitCollider(render)
	end
end

function BaseModelCreater:_InitShadow()
	self:ShadowVisible(self.showShadow)
end
-- 是否显示阴影
function BaseModelCreater:ShadowVisible(val)
	
	self.showShadow = val
	if self.showShadow and not self._shadow then
		self._shadow = Resourcer.Get("Prefabs/Others", "Shadow_circle", self._parent)
		self._shadow.layer = self._role.layer
		--self._shadowBehaviour = self._shadow:GetComponent("FS_ShadowSimple")
		--self._shadowBehaviour.isStatic = self._shadowIsStatic
		--if self._shadowIsStatic then self._shadowBehaviour:CalculateShadowGeometry() end
	end
	if self._shadow then self._shadow:SetActive(val) end
end
function BaseModelCreater:SetShadowStatic(val)
	--if self.IsDramaRole then return end --是否剧情角色 
	--    self._shadowIsStatic = val
	--    if self._shadowBehaviour then
	--        self._shadowBehaviour.isStatic = val
	--    end
end

function BaseModelCreater:_InitCollider(render)
	local go = render.gameObject
	local b = Avtar.InitBoxCollider(go, render)
	if b then
		b.isTrigger = true
		b.enabled = true
		go.layer = self._role.layer
	end
	self._collider = b
end

function BaseModelCreater:_OnModeInited()
	self:_InitRender()
	self:_InitShadow()
	if self._psScaleState == 1 then self:SyncParticleSystemScale() end
	if self.onLoadedSource then
		self:onLoadedSource(self)
		self.onLoadedSource = nil
	end
end


function BaseModelCreater:GetAnimator()
	return self._roleAnimator
end

function BaseModelCreater:GetRole()
	return self._role
end

-- 播放默认动画
function BaseModelCreater:PlayDefualt()
	self:Play(RoleActionName.defualt)
end
-- 播放上次动画
function BaseModelCreater:PlayLast()
	if self._actionName then
		self:Play(self._actionName)
	else
		self:PlayDefualt()
	end
end
-- 播放动画name名字,returnActionTime是否返回动画时间(循环动画返回-1
function BaseModelCreater:Play(name, returnActionTime)	
	return self:_Play(name, returnActionTime)
end
function BaseModelCreater:_Play(name, returnActionTime)
	--Warning(self._parent.name .. name .. '___'.. tostring(self._lastAction).. '___'.. tostring(self._roleAnimator))
	self._actionName = name;
	if stringLen(name) < 2 then
		Error("anim error,role=" .. self._transform.name .. ",anim=" .. tostring(name))
		return -1
	end
	if(self._roleAnimator) then
		if returnActionTime and self._lastAction == name and(name == RoleActionName.run or name == RoleActionName.stand
		or name == RoleActionName.atstand or name == RoleActionName.wait) then
			return self._animationTime or -1
		end
        local sampleAction = self._lastAction == name
		if sampleAction and self._animtionLoop then return self._animationTime end
--	    if self.__cname == 'MonsterModelCreater' and self._parent.gameObject.activeSelf then
--            Warning(self._parent.name .. '___' .. name.. tostring(self._lastAction).. tostring(self._animtionLoop))
--        end
		if self.checkAnimation then
			if self._roleAvtar then
				local suf = self._roleAvtar:PlayAnimation(name)
				if not suf then suf = self._roleAvtar:PlayAnimation(self:GetDefaultAction()) end
				if not suf then Error("anim error,role=" .. self._transform.name .. ",anim=" .. tostring(name)) end
				self._lastAction = name
			end
		else
			self._roleAnimator:Play(name, 0, 0);
			self._roleAnimator:Update(0);
			self._lastAction = name
		end
		--if returnActionTime then
        if not sampleAction then
			self._animStateInfo = self:GetAnimatorStateInfo()
            self._animtionLoop = self._animStateInfo.loop
			self._animationTime = self._animtionLoop and -1 or self._animStateInfo.length
			-- log(tostring(self.checkAnimation) .. "__" .. tostring(t))
            --Warning(tostring(self._animStateInfo) .. tostring(self._animtionLoop).. self._animationTime)
			return self._animationTime
		end
	end
	-- if (self.__cname == "RideModelCreater") then Error ((self._parent and self._parent.name or "nil") .."___" .. name) end
	return -1
end

function BaseModelCreater:AnimNormalizedTime()
    local s = self:GetAnimatorStateInfo()
    return s and s.normalizedTime or -1
end
function BaseModelCreater:AnimIsName(name)
    if name == nil then return false end
    local s = self:GetAnimatorStateInfo()
    if s then return s:IsName(name) end
    return false
end


-- 默认动作,用于找不到动作时
function BaseModelCreater:GetDefaultAction()
	return "attack01"
end

function BaseModelCreater:_CreateAvtar()
	if not self.checkAnimation and not self.hasCollider then return end
	if(self._roleAvtar == nil) then self._roleAvtar = self._role:GetComponent("Avtar") end
	if(self._roleAvtar == nil) then self._roleAvtar = self._role:AddComponent("Avtar") end
	if self.onEnableOpen then self._roleAvtar.onEnable = function() self:_OnEnable() end end
end

-- 初始化动画
function BaseModelCreater:_InitAnimation()
	self:_InitPlayerRole()
	self:_InitAnimator()
	
	local sourceDir = self._isPlayerRole and self:_GetPlayerSourceDir() or self:_GetSourceDir()
	self._roleAvtar:SetAnimation(self._roleAnimator, self.animDir, sourceDir)
	self:_AddAnimCache(self.animDir)
	
	self:PlayLast()
end
function BaseModelCreater:_InitAnimator()
	--Warning(tostring(self._roleAnimator) .. tostring(self._isPlayerRole))
	local anim = self._isPlayerRole and self:_GetPlayerSourceAnim() or self:_GetSourceAnim()
	self.animDir = self:_GetAnimDir(anim)
	if not self._roleAnimator then
		self._roleAnimator = self._role:AddComponent("Animator")
		local contrl = Resourcer.GetController(self:_GetControllerDir() .. self.animDir)
		self._roleAnimator.runtimeAnimatorController = contrl
	end
	self:SetAnimatorCullingMode(self.AnimatorCullingMode)
	--if self:_IsLoadController() then
	--end
end
function BaseModelCreater:SetAnimatorCullingMode(val)
	val = val or UnityEngine.AnimatorCullingMode.IntToEnum(1)--0alway,1reader
	if self.AnimatorCullingMode ~= val and self._roleAnimator then
		self._roleAnimator.cullingMode = val
	end	
	self.AnimatorCullingMode = val
end
function BaseModelCreater:_GetAnimDir(anim)
	return string.split(anim, "-") [1]
end
function BaseModelCreater:_IsLoadController()
	return self._isPlayerRole
end
function BaseModelCreater:_GetControllerDir()
	return "Roles/Controller/"
end
function BaseModelCreater:_GetSourceAnim()
	return self.useDefualtMode and self:_GetModelDefualt() or self.model_id
end
function BaseModelCreater:_GetSourceDir()
	return nil
end
function BaseModelCreater:_GetPlayerSourceDir()
	return "Heros"
end
function BaseModelCreater:_GetPlayerSourceAnim()
	return string.split(self.model_id, "_") [1] .. "_00"
end

function BaseModelCreater:_AddAnimCache(animDir)
	--    local ads = BaseModelCreater.allAnimDirs
	--    if not table.contains(ads, animDir) then _tableInsert(ads, animDir) end
end
function BaseModelCreater:_InitPlayerRole()
	self._isPlayerRole = false
	local mode = self:_GetSourceAnim()
	for k, v in ipairs(Player_Name) do
		local s = stringFind(mode, v)
		if(s == 1) then
			self._isPlayerRole = true
			break
		end
	end
end
-- 用于角色启用后动画重置为站立问题
function BaseModelCreater:_OnEnable()
	self:_InitRender()
    self:PlayLast()
	--    if self._actionName then
	--        self:Play(self._actionName)
	--        if (self._rideCreater ~= nil) then
	--            self._rideCreater:Play(self._rideCreater._actionName)
	--    end
end



-- 暂停动作
function BaseModelCreater:Pause()
	if(self._roleAnimator) then
		self._roleAnimator.speed = 0;
	end
end

-- 恢复执行动作
function BaseModelCreater:Resume()
	if(self._roleAnimator) then
		self._roleAnimator.speed = 1;
	end
end

function BaseModelCreater:GetAnimatorStateInfo()
	if(self._roleAnimator) then
		return self._roleAnimator:GetCurrentAnimatorStateInfo(0);
	end
	return nil;
end

function BaseModelCreater:SetLayer(layer)
	self._layer = layer
	if self._role then self._role.layer = self._layer end
	local trf = self._transform and self._transform or self._parent
	-- logTrace(tostring(self._transform) .. "___" .. tostring(trf) .. "___" .. layer)
	if trf == nil then return end
	NGUITools.SetChildLayer(trf, self._layer)
	-- NGUITools.SetChildLayer(self._transform, layer)
end

function BaseModelCreater:GetCenter()
	return self._roleCenter
end

function BaseModelCreater:GetNamePoint()
	return self._namePoint or self._transform
end

function BaseModelCreater:GetTrumpParent()
	if(self._trumpParent == nil) then
		return self._roleCenter
	end
	return self._trumpParent
end


function BaseModelCreater:GetTop()
	return self._roleTop
end

function BaseModelCreater:GetHangingPoint(name)
	if(self._handPoint[name] == nil) then
		if(self.model_id and self._role) then
			self._handPoint[name] = UIUtil.GetChildByName(self._role, BaseModelCreater.GetRoleBonePath(self.model_id, name))		
		else
			--log(self.__cname .. "没有modelId")
			if(self._role) then
				self._handPoint[name] = UIUtil.GetChildByName(self._role, BaseModelCreater.GetRoleBonePath(self._role.name, name))
			end
		end
	end
	return self._handPoint[name];
end

-- 获取模型尺寸
function BaseModelCreater:GetSize()
	return Vector3.zero
end


-- 位置设置 
function BaseModelCreater:SetPosition(pos, angle)
	if(pos) then
		MapTerrain.SampleTerrainPositionAndSetPos(self._transform, pos)
		--        self._transform.position = MapTerrain.SampleTerrainPosition(pos)
	end
	
	if(angle) then
		--self._transform.rotation = Quaternion.Euler(0, angle, 0);
		Util.SetRotation(self._transform, 0, angle, 0)
	end
end
function BaseModelCreater:_CanPoolMode()
	return self._psScaleState ~= 2
end
function BaseModelCreater:_DisposeShadow()
	if self._shadow then
		--self._shadowBehaviour:RemoveGeometry()
		--self._shadowBehaviour = nil
		Resourcer.Recycle(self._shadow, true)
		self._shadow = nil
	end
end
function BaseModelCreater:_DisposeModel()
	if not IsNil(self._role) then
		Resourcer.Recycle(self._role, self:_CanPoolMode())
		self._role = nil
	end
end
function BaseModelCreater:Dispose()
	if self._isDispose then return end
	self:_Dispose()
    if self.effects then
        for i = #self.effects, 1, -1 do Resourcer.Recycle(self.effects[i]) end
	end
	self._transform = nil
	self._allChildTransForm = nil
	self._parent = nil
	self._roleAvtar = nil
	self._roleAnimator = nil
	self._roleCenter = nil
	self._roleTop = nil
	self._trumpParent = nil
	self:_DisposeShadow()
	if self._collider then
		self._collider.enabled = false
		self._collider = nil
	end
	self:_DisposeModel()
	self._render = nil
	self._handPoint = nil
    self._animStateInfo = nil
	self._isDispose = true
end
function BaseModelCreater:_Dispose()
	
end
-- 同步go的特效缩放
function BaseModelCreater:SyncParticleSystemScale()
	if not IsNil(self._role) and self._psScaleState ~= 2 then
		UIUtil.ScaleParticleSystem(self._role)
		self._psScaleState = 2
		-- 标记设置过特效缩放,只能设置一次
	else
		self._psScaleState = 1
		-- 标记要设置特效缩放
	end
end
-- 传入一个浮点数
function BaseModelCreater:SetScale(scale)
	if self._transform then self._transform.localScale = Vector3.one * scale end
end

-- 传入Vector3
function BaseModelCreater:SetRotation(rotation)
	--if self._transform then self._transform.localRotation = Quaternion.Euler(rotation.x, rotation.y, rotation.z) end
	if self._transform then Util.SetRotation(self._transform, rotation.x, rotation.y, rotation.z) end
end

function BaseModelCreater:GetTrump()
	return self._trump
end

function BaseModelCreater:SetWingActive(active)
	
end 