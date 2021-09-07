-- 缓冲池
SingleIconPool = SingleIconPool or BaseClass()

function SingleIconPool:__init()
    --key = Key
    --value = {type = SingleIconType, iconId = string, obj = asset, ref = 0, time = 0, timeout = 15}
    self.cacheDict = {}

    self.loaderDict = {}
    self.loaderIndex = 0
end

function SingleIconPool:__delete()
end

function SingleIconPool:OnTick()
    for key, data in pairs(self.cacheDict) do
        if data.ref < 1 and (Time.time - data.time) > data.timeout then
            data.obj = nil
            self.cacheDict[key] = nil
        end
    end
end

function SingleIconPool:CheckPool()
    BaseUtils.dump(self.cacheDict, "==============  SingleIconPool:CheckPool  ============")
end

-- 异步获取Icon
function SingleIconPool:GetSprite(iconType, iconId, callback)
    local data = self.cacheDict[self:Key(iconType, iconId)]
    if data ~= nil then
        data.ref = data.ref + 1
        data.time = Time.time
        local call = function() callback(data.obj) end
        local status, err = xpcall(call, function(errinfo)
            Log.Error("SingleIconPool:LoadAssetFinish出错了[" .. key .. "]:" .. tostring(errinfo)); Log.Error(debug.traceback())
        end)
    else
        local path = self:Path(iconType, iconId)
        local index = self:Index()
        local resList = {
            {file = path, type = AssetType.Main, holdTime = 5}
        }
        local cb = function()
            self:LoadAssetFinish(iconType, iconId, callback, path, index)
        end
        local assetWrapper = AssetBatchWrapper.New()
        self.loaderDict[index] = assetWrapper
        assetWrapper:LoadAssetBundle(resList, cb)
    end
end

function SingleIconPool:LoadAssetFinish(iconType, iconId, callback, path, index)
    local assetWrapper = self.loaderDict[index]
    if assetWrapper == nil then
        Log.Error("获取iconType:" .. tostring(iconType) .. " iconId:" .. tostring(iconId) .. "出错，assetWrapper为空")
        return
    end
    local key = self:Key(iconType, iconId)
    local cache = self.cacheDict[key]
    local icon = nil
    if cache == nil then
        icon = assetWrapper:GetSprite(path, iconId)
        self.cacheDict[key] = {type = iconType, iconId = iconId, obj = icon, ref = 1, time = Time.time, timeout = 5}
    else
        icon = cache.obj
        cache.ref = cache.ref + 1
        cache.time = Time.time
    end
    assetWrapper:DeleteMe()
    self.loaderDict[index] = nil
    local call = function() callback(icon) end
    local status, err = xpcall(call, function(errinfo)
        Log.Error("SingleIconPool:LoadAssetFinish出错了[" .. key .. "]:" .. tostring(errinfo)); Log.Error(debug.traceback())
    end)
    callback = nil
end

-- 减少引用数
function SingleIconPool:DecreaseReferenceCount(iconType, iconId)
    local key = self:Key(iconType, iconId)
    local cache = self.cacheDict[key]
    if cache ~= nil then
        cache.ref = cache.ref - 1
        if cache.ref < 0 then
            Log.Error("SingleIconPool:DecreaseReferenceCount出错[" .. key .. "] 引用数不对，减多了")
        end
    else
        Log.Error("SingleIconPool:DecreaseReferenceCount出错[" .. key .. "]cache为空".."\n"..debug.traceback())
    end
end

function SingleIconPool:Key(iconType, iconId)
    return BaseUtils.Key(iconType, "IconPoolKey", iconId)
end

function SingleIconPool:Path(iconType, iconId)
    if iconType == SingleIconType.Item then
        return BaseUtils.GetItemPath(iconId)
    elseif iconType == SingleIconType.MianUI then
        return string.format("textures/singlemainuiicon/%s.unity3d", iconId)
    elseif iconType == SingleIconType.SkillIcon then
        return string.format(AssetConfig.single_skillIcon, iconId)
    elseif iconType == SingleIconType.Pet then
        return string.format("textures/singlepetuipet/%s.unity3d",iconId)
    elseif iconType == SingleIconType.Other then
        return string.format(AssetConfig.singleothericon,iconId)
    else
        return nil
    end
end

function SingleIconPool:Index()
    if self.loaderIndex % 10000  == 0 then
        self.loaderIndex = 0
    end
    self.loaderIndex = self.loaderIndex + 1
    return self.loaderIndex
end

