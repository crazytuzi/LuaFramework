-- 对象池
-- @author huangyq
-- @date 160727
GoPoolType = {
    Role = 1
    ,Head = 2
    ,Npc = 3
    ,BoundRole = 4
    ,BoundNpc = 5
    ,Wing = 6
    ,Weapon = 7
    ,Surbase = 8
    ,Effect = 9
    ,Number = 10
    ,BoundRoleCombat = 11
    ,BoundNpcCombat = 12
    ,Ride = 13
}

GoPoolManager = GoPoolManager or BaseClass()

function GoPoolManager:__init()
    if GoPoolManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    GoPoolManager.Instance = self
    self.poolIndex = 1
    self.OnTickCtx = {poolIndex = 1, done = false}

    self.OnTickCount = 1
    self.TickToRelease = 30 * 8
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.TickToRelease = 30 * 2
    end

    self.parentRole = GameObject("GameObjectPoolRole")
    self.parentHead = GameObject("GameObjectPoolHead")
    self.parentNpc = GameObject("GameObjectPoolNpc")
    self.parentBound = GameObject("GameObjectPoolBound")
    self.parentWing = GameObject("GameObjectPoolWing")
    self.parentWeapon = GameObject("GameObjectPoolWeapon")
    self.parentSurbase = GameObject("GameObjectPoolSurbase")
    self.parentEffect = GameObject("GameObjectPoolEffect")
    self.parentNumber = GameObject("GameObjectPoolNumber")
    self.parentBoundCombat = GameObject("GameObjectPoolBoundCombat")
    self.parentRide = GameObject("GameObjectPoolRide")

    self.parentRole.transform.position = Vector3(100, 0, 0)
    self.parentHead.transform.position = Vector3(100, 0, 0)
    self.parentNpc.transform.position = Vector3(100, 0, 0)
    self.parentBound.transform.position = Vector3(100, 0, 0)
    self.parentWing.transform.position = Vector3(100, 0, 0)
    self.parentWeapon.transform.position = Vector3(100, 0, 0)
    self.parentSurbase.transform.position = Vector3(100, 0, 0)
    self.parentEffect.transform.position = Vector3(100, 0, 0)
    self.parentNumber.transform.position = Vector3(100, 0, 0)
    self.parentBoundCombat.transform.position = Vector3(100, 0, 0)
    self.parentRide.transform.position = Vector3(100, 0, 0)

    GameObject.DontDestroyOnLoad(self.parentRole)
    GameObject.DontDestroyOnLoad(self.parentHead)
    GameObject.DontDestroyOnLoad(self.parentNpc)
    GameObject.DontDestroyOnLoad(self.parentBound)
    GameObject.DontDestroyOnLoad(self.parentWing)
    GameObject.DontDestroyOnLoad(self.parentWeapon)
    GameObject.DontDestroyOnLoad(self.parentSurbase)
    GameObject.DontDestroyOnLoad(self.parentEffect)
    GameObject.DontDestroyOnLoad(self.parentNumber)
    GameObject.DontDestroyOnLoad(self.parentBoundCombat)
    GameObject.DontDestroyOnLoad(self.parentRide)

    self.rolePool = GoRolePool.New(self.parentRole)
    self.headPool = GoHeadPool.New(self.parentHead)
    self.npcPool = GoNpcPool.New(self.parentNpc)
    self.boundPool = GoBoundPool.New(self.parentBound)
    self.wingpPool = GoWingPool.New(self.parentWing)
    self.weaponPool = GoWeaponPool.New(self.parentWeapon)
    self.surbasePool = GoSurbasePool.New(self.parentSurbase)
    self.boundCombatPool = GoBoundCombatPool.New(self.parentBoundCombat)
    self.effectPool = GoEffectPool.New(self.parentEffect)
    self.numberPool = GoNumberPool.New(self.parentNumber)
    self.ridePool = GoRidePool.New(self.parentRide)
end

function GoPoolManager:__delete()
    self.rolePool:DeleteMe()
    self.headPool:DeleteMe()
    self.npcPool:DeleteMe()
    self.boundPool:DeleteMe()
    self.wingpPool:DeleteMe()
    self.weaponPool:DeleteMe()
    self.surbasePool:DeleteMe()
    self.effectPool:DeleteMe()
    self.numberPool:DeleteMe()
    self.boundCombatPool:DeleteMe()
    self.ridePool:DeleteMe()
end

-- 两秒一次
function GoPoolManager:OnTick()
    -- local now = Time.time
    -- self.OnTickCtx.done = false
    -- self.rolePool:OnTick(now, self.OnTickCtx)
    -- self.headPool:OnTick(now, self.OnTickCtx)
    -- self.npcPool:OnTick(now, self.OnTickCtx)
    -- self.boundPool:OnTick(now, self.OnTickCtx)
    -- self.wingpPool:OnTick(now, self.OnTickCtx)
    -- self.weaponPool:OnTick(now, self.OnTickCtx)
    -- self.surbasePool:OnTick(now, self.OnTickCtx)
    -- self.boundCombatPool:OnTick(now, self.OnTickCtx)
    -- self.ridePool:OnTick(now)

    self.OnTickCount = self.OnTickCount + 1
    if self.OnTickCount > self.TickToRelease then
        self:Release()
        self.OnTickCount = 1
    end
end

function GoPoolManager:Release()
    local now = Time.time
    self.rolePool:Release(now)
    self.headPool:Release(now)
    self.npcPool:ReleaseAll()
    self.npcPool:checkExpirePoolobj()
    self.boundPool:Release(now)
    self.wingpPool:Release(now)
    self.weaponPool:Release(now)
    self.surbasePool:Release(now)
    self.ridePool:Release(now)
    if not CombatManager.Instance.isFighting then
        self.effectPool:ReleaseAll()
        self.effectPool:checkExpirePoolobj()
        self.numberPool:ReleaseAll()
        self.numberPool:checkExpirePoolobj()
    end
    self.OnTickCount = 1
end

function GoPoolManager:Borrow(path, poolType)
    local pool = nil
    if poolType == GoPoolType.Role then
        pool = self.rolePool
    elseif poolType == GoPoolType.Head then
        pool = self.headPool
    elseif poolType == GoPoolType.Npc then
        pool = self.npcPool
    elseif poolType == GoPoolType.BoundRole then
        pool = self.boundPool
    elseif poolType == GoPoolType.BoundNpc then
        pool = self.boundPool
    elseif poolType == GoPoolType.Wing then
        pool = self.wingpPool
    elseif poolType == GoPoolType.Weapon then
        pool = self.weaponPool
    elseif poolType == GoPoolType.Surbase then
        pool = self.surbasePool
    elseif poolType == GoPoolType.Effect then
        pool = self.effectPool
    elseif poolType == GoPoolType.Number then
        pool = self.numberPool
    elseif poolType == GoPoolType.BoundRoleCombat then
        pool = self.boundCombatPool
    elseif poolType == GoPoolType.BoundNpcCombat then
        pool = self.boundCombatPool
    elseif poolType == GoPoolType.Ride then
        pool = self.ridePool
    end
    if pool == nil then
        Log.Error("GoPoolManager:Borrow Error: poolType:" .. tostring(poolType) .. " path:" .. tostring(path))
    else
        return pool:Borrow(path)
    end
end

function GoPoolManager:Return(poolObj, path, poolType)
    if path == nil or path == "" then
        GameObject.Destroy(poolObj.gameObject)
        return
    end
    if BaseUtils.is_null(poolObj) then
        return
    end
    local pool = nil
    if poolType == GoPoolType.Role then
        pool = self.rolePool
    elseif poolType == GoPoolType.Head then
        pool = self.headPool
    elseif poolType == GoPoolType.Npc then
        pool = self.npcPool
    elseif poolType == GoPoolType.BoundRole then
        pool = self.boundPool
    elseif poolType == GoPoolType.BoundNpc then
        pool = self.boundPool
    elseif poolType == GoPoolType.Wing then
        pool = self.wingpPool
    elseif poolType == GoPoolType.Weapon then
        pool = self.weaponPool
    elseif poolType == GoPoolType.Surbase then
        pool = self.surbasePool
    elseif poolType == GoPoolType.Effect then
        pool = self.effectPool
    elseif poolType == GoPoolType.Number then
        pool = self.numberPool
    elseif poolType == GoPoolType.BoundRoleCombat then
        pool = self.boundCombatPool
    elseif poolType == GoPoolType.BoundNpcCombat then
        pool = self.boundCombatPool
    elseif poolType == GoPoolType.Ride then
        pool = self.ridePool
    end
    if pool == nil then
        Log.Error("GoPoolManager:Return Error: poolType:" .. tostring(poolType) .. " path:" .. tostring(path))
        Log.Error(debug.traceback())
    else
        if poolType == GoPoolType.BoundRole then
            pool:ReturnRole(poolObj, path)
        elseif poolType == GoPoolType.BoundNpc then
            pool:ReturnNpc(poolObj, path)
        elseif poolType == GoPoolType.BoundRoleCombat then
            pool:ReturnRole(poolObj, path)
        elseif poolType == GoPoolType.BoundNpcCombat then
            pool:ReturnNpc(poolObj, path)
        elseif poolType == GoPoolType.Effect then
            pool:ReturnEffect(poolObj, path)
        else
            pool:Return(poolObj, path)
        end
    end
end

function GoPoolManager:CheckResPool()
    self.rolePool:CheckResPool()
    self.headPool:CheckResPool()
    self.npcPool:CheckResPool()
    self.wingpPool:CheckResPool()
    self.weaponPool:CheckResPool()
    self.surbasePool:CheckResPool()
    self.effectPool:CheckResPool()
end

function GoPoolManager:ReleaseOnEndCombat()
    self.numberPool:ReleaseAll()
    self.effectPool:ReleaseAll()
end
