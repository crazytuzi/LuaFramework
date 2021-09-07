-- 对象池基类
-- @author huangyq
-- @date   160726
GoBasePool = GoBasePool or BaseClass()

function GoBasePool:__init()
    self.name = "<Unknown>"
    -- AssetType.Main的资源，需要去资源池里面验证
    self.assetType = AssetType.Main
    self.poolIndex = GoPoolManager.Instance.poolIndex
    GoPoolManager.Instance.poolIndex = GoPoolManager.Instance.poolIndex + 1
    self.maxSize = 10
    self.parent = nil
    self.queue = {}

    self.Type = nil

    self.__index = 0
    -- 秒
    self.timeout = 300
    self.checkExpire = 1

    self.expireTime = 60

    self.IsIos = false
    if BaseUtils.platform == RuntimePlatform.IPhonePlayer then
        self.IsIos = true
    end

    self.ignoreList = {GoPoolType.Role, GoPoolType.Head, GoPoolType.Npc, GoPoolType.Wing, GoPoolType.Weapon, GoPoolType.Surbase, GoPoolType.Ride}
    self.neewIgnore = false

    -- 记录借出内容，与名字判断，在清理的时候防止误删
    self.borrowQueue = {}
end

function GoBasePool:__delete()
    for _, data in ipairs(self.queue) do
        data:DeleteMe()
    end
    self.queue = {}
end

function GoBasePool:SetIgnoreFlag()
    if self.IsIos and BaseUtils.ContainValueTable(self.ignoreList, self.Type) then
        self.neewIgnore = true
    end
end

-- 两秒执行一次
function GoBasePool:OnTick(now, OnTickCtx)
    if self.poolIndex == OnTickCtx.poolIndex and OnTickCtx.done == false then
        local res = self:ClearPoolData(self.timeout, now, 5)
        if res then
            OnTickCtx.done = true
        end
        OnTickCtx.poolIndex = OnTickCtx.poolIndex + 1
        if OnTickCtx.poolIndex >= GoPoolManager.Instance.poolIndex then
            OnTickCtx.poolIndex = 1
        end
    end
end

-- 过场景用
function GoBasePool:Release(now)
    self:ClearPoolData(self.timeout, now, 30)
end

function GoBasePool:ClearPoolData(timeout, now, delMax)
    local poolData = nil
    local matchList = {}
    for index, data in ipairs(self.queue) do
        if (now - data.time) > self.timeout then
            table.insert(matchList, index)
        end
        if #matchList >= delMax then
            break
        end
    end
    local size = #matchList
    for i = size, 1, -1 do
        local idx = matchList[i]
        local poolData = self.queue[idx]
        table.remove(self.queue, idx)
        poolData:DeleteMe()
        poolData = nil
    end

    self:checkExpirePoolobj()

    if #matchList > 0 then
        return true
    else
        return false
    end
end

function GoBasePool:checkExpirePoolobj()
    self.checkExpire = self.checkExpire + 1
    local now = Time.time
    if self.checkExpire > 5 then
        self:RemoveHead(self.maxSize)
        local count = self.parent.transform.childCount
        if (#self.queue + 3) < count then
            if count > 0 then
                for i = count, 1, -1 do
                    local child = self.parent.transform:GetChild(i-1).gameObject
                    if not self:InPoolObj(child) and not self:InBorrowQueue(child:GetInstanceID(), now) then
                        Log.Debug("GoBasePool has error poolObj:" .. child.name)
                        GameObject.DestroyImmediate(child)
                    end
                end
            end
        end
        self.checkExpire = 1
    end
end

function GoBasePool:RemoveHead(size)
    local length = #self.queue
    if length > size then
        local poolData = self.queue[1]
        table.remove(self.queue, 1)
        poolData:DeleteMe()
        poolData = nil
        self:RemoveHead(size)
    end
end

function GoBasePool:Borrow(path)
    if self.neewIgnore then
        return nil
    end
    local index = 0
    local match = nil
    for idx, data in ipairs(self.queue) do
        if data.path == path then
            index = idx
            match = data
            break
        end
    end
    if match == nil then
        return nil
    else
        table.remove(self.queue, index)
        -- 所有借出去内容，需要资源池中拥有
        if self.assetType == AssetType.Main and (not AssetPoolManager.Instance.assetPool:Contain(match.path)) then
            match:DeleteMe()
            match = nil
            return nil
        else
            local poolObj = match:GetObj()
            if BaseUtils.is_null(poolObj) then
                Log.Debug("Borrow is nil:" .. path)
                match:DeleteMe()
                poolObj = nil
                return nil
            end
            self:AddBorrowQueue(poolObj:GetInstanceID())
            poolObj:SetActive(true)
            return poolObj
        end
    end
end

function GoBasePool:Return(poolObj, path)
    if self.neewIgnore then
        if not BaseUtils.is_null(poolObj) then
            GameObject.DestroyImmediate(poolObj.gameObject)
            return
        end
    end
    -- poolObj.name = self.name .. self:GetIndex()
    self:Reset(poolObj, path)
    local poolData = GoPoolObject.New(poolObj, path)
    if self.assetType == AssetType.Main and (not AssetPoolManager.Instance.assetPool:Contain(path)) then
        poolData:DeleteMe()
        poolData = nil
        return
    else
        table.insert(self.queue, poolData)
    end

    -- 一般销毁在OnTick函数中处理，除非数据正常两倍
    if #self.queue > (self.maxSize * 2) then
        local pObj = self.queue[1]
        table.remove(self.queue, 1)
        pObj:DeleteMe()
        pObj = nil
    end
end

-- 需要重写
function GoBasePool:Reset(poolObj, path)
end

function GoBasePool:CheckResPool()
    if self.assetType ~= AssetType.Main then
        return
    end
    local poolData = nil
    local matchList = {}
    for index, data in ipairs(self.queue) do
        if not AssetPoolManager.Instance.assetPool:CheckExist(data.path) then
            table.insert(matchList, index)
        end
    end
    local size = #matchList
    for i = size, 1, -1 do
        local idx = matchList[i]
        poolData = self.queue[idx]
        table.remove(self.queue, idx)
        poolData:DeleteMe()
        poolData = nil
    end
end

-- 还原
function GoBasePool:ResetModel(poolObj)
    poolObj:SetActive(false)
    poolObj.transform:SetParent(self.parent.transform)
    poolObj.transform.localPosition = Vector3(0, 0, 0)
    poolObj.transform.localRotation = Quaternion.identity
    poolObj.transform.localScale = Vector3.one
    CombatUtil.SetAlpha(poolObj, 1)
end

-- role npc 需要把贴图清掉
function GoBasePool:ClearMesh(go)
    if go == nil then
        return
    end
    if string.find(go.name, "Mesh_") ~= nil then
        go.renderer.material.mainTexture = nil
    end
    local count = go.transform.childCount
    if count > 0 then
        for i = 1, count do
            local child = go.transform:GetChild(i-1)
            if string.find(child.name, "tpose") ~= nil or string.find(child.name, "Mesh_") ~= nil then
                self:ClearMesh(child)
            end

        end
    end
end

function GoBasePool:ClearBpObj(go, min)
    local count = go.transform.childCount
    if count > min then
        for i = 1, count do
            local child = go.transform:GetChild(i-1)
            if string.find(child.gameObject.name, "(Clone)") ~= nil
                or string.find(child.gameObject.name, "Effect") ~= nil
                or string.find(child.gameObject.name, "effect_") ~= nil then
                    GameObject.Destroy(child.gameObject)
            end
        end
    end

end

function GoBasePool:GetIndex()
    self.__index = self.__index + 1
    if self.__index > 100000 then
        self.__index = 1
    end
    return self.__index
end

function GoBasePool:AddBorrowQueue(objName)
    if #self.borrowQueue > 10 then
        table.remove(self.borrowQueue, 1)
    end
    table.insert(self.borrowQueue, {name = objName, time = Time.time})
end

function GoBasePool:InPoolObj(obj)
    for _, data in ipairs(self.queue) do
        if data.obj == obj then
            return true
        end
    end
    return false
end

function GoBasePool:InBorrowQueue(objName, now)
    for _, data in ipairs(self.borrowQueue) do
        if data.name == objName and  (now - data.time) < 3 then
            return true
        end
    end
    return false
end

function GoBasePool:DeleteChild(node)
    if node ~= nil then
        local count = node.transform.childCount
        if count > 0 then
            local list = {}
            for i = 1, count do
                local child = node.transform:GetChild(i-1)
                table.insert(list, child)
            end
            for _, data in ipairs(list) do
                GameObject.Destroy(data.gameObject)
            end
        end
    end
end

function GoBasePool:ReleaseAll()
    for _, data in ipairs(self.queue) do
        data:DeleteMe()
    end
    self.queue = {}
    self.__index = 0
    self.clearCount = 0
end
