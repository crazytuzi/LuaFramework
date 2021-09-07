-- 资源池
-- 当资源类型为AssetType.Main时，可对AssetBundle.mainAsset进行缓存
AssetPool = AssetPool or BaseClass()

function AssetPool:__init(name)
    self.name = name
    self.cache = {}
end

function AssetPool:__delete()
    self.cache = nil
end

function AssetPool:Add(key, poolObj, holdTime)
    if not BaseUtils.ContainKeyTable(self.cache, key) then
        if holdTime == nil then
            holdTime = BaseUtils.DefaultHoldTime()
        end
        self.cache[key] = {asset = poolObj, time = Time.time, holdTime = holdTime}
    else
        -- Log.Info(string.format("重复添加资源池元素:%s", key))
    end
end

function AssetPool:Contain(key)
    local asset = self:Get(key)
    if asset == nil then
        return false
    else
        return true
    end
end

function AssetPool:CheckExist(key)
    local asset = self:GetStatic(key)
    if asset == nil then
        return false
    else
        return true
    end
end

function AssetPool:Get(key)
    if BaseUtils.ContainKeyTable(self.cache, key) then
        local asset = self.cache[key]
        asset.time = Time.time
        return asset
    else
        return nil
    end
end

function AssetPool:GetStatic(key)
    if BaseUtils.ContainKeyTable(self.cache, key) then
        local asset = self.cache[key]
        return asset
    else
        return nil
    end
end

function AssetPool:CheckToRelease()
    local now = Time.time
    local dels = {}
    for key, data in pairs(self.cache) do
        if (now - data.time) > data.holdTime then
            table.insert(dels, key)
        end
    end
    for _, key in ipairs(dels) do
        self.cache[key] = nil
    end
end
