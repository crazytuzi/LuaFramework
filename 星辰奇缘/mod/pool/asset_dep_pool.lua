-- 依赖文件的AssetBundleInfo池
AssetDepPool = AssetDepPool or BaseClass()

function AssetDepPool:__init()
    self.cache = {}
end

function AssetDepPool:__delete()
    self.cache = nil
end

function AssetDepPool:Add(key, assetInfo, holdTime)
    if not BaseUtils.ContainKeyTable(self.cache, key) then
        if holdTime == nil then
            holdTime = BaseUtils.DefaultHoldTime()
        end
        -- multipleSprites 自定义图集的小图缓存
        self.cache[key] = {file = key, assetInfo = assetInfo, time = Time.time, holdTime = holdTime, holdCount = 1, multipleSprites = nil}
    else
        self:AddHoldCount(key)
        -- Log.Info(string.format("重复添加依赖资源池元素:%s", key))
    end
end

function AssetDepPool:Contain(key)
    local data = self:Get(key)
    if data == nil then
        return false
    else
        return true
    end
end

function AssetDepPool:Get(key)
    if BaseUtils.ContainKeyTable(self.cache, key) then
        local data = self.cache[key]
        data.time = Time.time
        return data
    else
        return nil
    end
end

function AssetDepPool:AddHoldCount(key)
    local data = self:Get(key)
    if data ~= nil then
        data.holdCount = data.holdCount + 1
    else
        Log.Error("增加依赖文件HoldCount出错了，找不到相应资源:" .. key)
    end
end

function AssetDepPool:DescHoldCount(key)
    local data = self:Get(key)
    if data ~= nil then
        if data.holdCount > 0 then
            data.holdCount = data.holdCount - 1 -- 一级计数
        end
    else
        Log.Error("释放依赖文件HoldCount出错了，找不到相应资源:" .. key..debug.traceback())
    end
end

function AssetDepPool:CheckToRelease()
    local now = Time.time
    local dels = {}
    for key, data in pairs(self.cache) do
        if (now - data.time) > data.holdTime and data.holdCount <= 0 then
            table.insert(dels, key)
        end
    end
    for _, key in ipairs(dels) do
        -- self.cache[key].assetInfo:DescRefCount() -- 二级计数 只加一次，只减一次
        self.cache[key].assetInfo.RefCount = 0 --计数器并非最高为1，所以现在改为直接置0
        self.cache[key] = nil
    end
end
