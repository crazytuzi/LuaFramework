AssetBatchWrapper = AssetBatchWrapper or BaseClass()
function AssetBatchWrapper:__init()
    self.assetBundleBatch = nil
    self.IsClearMain = false
    self.IsClearDep = false
    self.ResLoaded = false
    self.IsDelete = false
    self.resList = {}
end

function AssetBatchWrapper:__delete()
    self:ClearAll()
    self:RefreshTime()
    self.assetBundleBatch = nil
    self.IsDelete = true
end

-- progressCall没什么事别用
function AssetBatchWrapper:LoadAssetBundle(resList, mOnLoadCompleted, progressCall)
    if self.assetBundleBatch ~= nil then
        local errorInfo = "assetBundleBatch不可以重复使用"
        for key, _ in pairs(self.resList) do
            errorInfo = errorInfo .. " /r/n" .. key
        end
        Log.Error(errorInfo)
    end
    local callback = function()

        self.ResLoaded = true
        if self.resList == nil then
            return
        end
        -- 处理依赖文件缓存
        for _, data in pairs(self.resList) do
            if data["type"] ~= nil and data["type"] == AssetType.Dep and data.from == AssetFrom.Loader and self.assetBundleBatch ~= nil then
                local assetBundle = self.assetBundleBatch:GetAssetBundleInfo(data.file)
                if assetBundle == nil then
                    Log.Error("AssetBundleInfo资源为空")
                end
                AssetPoolManager.Instance.assetDepPool:Add(data.file, assetBundle, data.holdTime)
            end
        end
        if mOnLoadCompleted ~= nil and self.IsDelete == false then
            mOnLoadCompleted()
        end
    end
    -- 需要下载
    local mainAssets = {}
    local depAssets = {}

    for _, data in ipairs(resList) do
        if data["type"] ~= nil and data["type"] == AssetType.Dep then
            local depData = AssetPoolManager.Instance.assetDepPool:Get(data.file)
            if depData == nil or BaseUtils.isnull(depData.asset) then
                table.insert(depAssets, data)
                data.from = AssetFrom.Loader
                self.resList[data.file] = data
            else
                AssetPoolManager.Instance.assetDepPool:AddHoldCount(data.file)
                data.from = AssetFrom.Cache
                self.resList[data.file] = data
                if progressCall ~= nil then
                    progressCall(data.file)
                end
            end
        else
            -- 检查缓存
            if not AssetPoolManager.Instance.assetPool:Contain(data.file) then
                table.insert(mainAssets, data)
                data.from = AssetFrom.Loader
                self.resList[data.file] = data
            else
                data.from = AssetFrom.Cache
                self.resList[data.file] = data
                if progressCall ~= nil then
                    progressCall(data.file)
                end
            end
        end
    end
    if #mainAssets > 0 or #depAssets > 0 then
        self.assetBundleBatch = AssetBundleBatch()
        if progressCall ~= nil then
            self.assetBundleBatch:LoadAssetBundle(mainAssets, depAssets, callback, progressCall)
        else
            self.assetBundleBatch:LoadAssetBundle(mainAssets, depAssets, callback)
        end
    else
        callback()
    end
end

function AssetBatchWrapper:GetMainAsset(file)
    if not self.ResLoaded then
        -- Log.Error("GetMainAsset While AssetBatchWrapper not loaded :" .. file)
        return nil
    end
    local data  = self.resList[file]
    if data ~= nil then
        if data.from == AssetFrom.Cache then
            local asset = nil
            xpcall(function() asset = AssetPoolManager.Instance.assetPool:Get(file).asset end,
            function() Log.Error(file.."资源从缓存加载失败") end )
            return asset
        else
            local assetBundle = self.assetBundleBatch:GetAssetBundleInfo(file)
            if assetBundle ~= nil then
                local mainAsset = assetBundle:GetMainAsset()
                local holdTime = BaseUtils.DefaultHoldTime()
                if data.holdTime ~= nil then
                    holdTime = data.holdTime
                end
                AssetPoolManager.Instance.assetPool:Add(file, mainAsset, holdTime)
                return mainAsset
            end
        end
    else
        Log.Error("AssetBatchWrapper找不到资源:" .. file)
        return nil
    end

end

-- 获取子集
function AssetBatchWrapper:GetSubAsset(file, name)
    local data = self.resList[file]
    local assetBundle = nil
    if data["type"] == AssetType.Dep then
        local depData = AssetPoolManager.Instance.assetDepPool:Get(data.file)
        assetBundle = depData.assetInfo
    else
        assetBundle = self.assetBundleBatch:GetAssetBundleInfo(file)
    end
    if assetBundle ~= nil then
        return assetBundle:GetSubAsset(name)
    else
        Log.Error("AssetBatchWrapper:GetSubAsset找不到资源:" .. file)
        return nil
    end
end

-- 从图集里面获取
function AssetBatchWrapper:GetSprite(file, name)

    if not self.ResLoaded then
        -- Log.Error("GetSprite While AssetBatchWrapper not loaded :" .. file)
        return nil
    end
    local data = self.resList[file]
    local assetBundle = nil
    if data["type"] == AssetType.Dep then
        local depData = AssetPoolManager.Instance.assetDepPool:Get(data.file)
        if depData == nil then
            Log.Error(string.format("GetSprite出错了从图集[%s]:GetSprite:%s", file, name))
        else
            assetBundle = depData.assetInfo
        end
    else
        assetBundle = self.assetBundleBatch:GetAssetBundleInfo(file)
    end
    if assetBundle ~= nil and not BaseUtils.isnull(assetBundle) then
        return assetBundle:GetSprite(name)
    else
        Log.Error("AssetBatchWrapper:GetSprite找不到资源:" .. file)
        return nil
    end
end

function AssetBatchWrapper:GetTextures(file, name)
    if not self.ResLoaded then
        Log.Error("GetTextures While AssetBatchWrapper not loaded :" .. file.."at:\n" ..debug.traceback())
        return nil
    end
    local data = self.resList[file]
    local assetBundle = nil
    if data["type"] == AssetType.Dep then
        local depData = AssetPoolManager.Instance.assetDepPool:Get(data.file)
        assetBundle = depData.assetInfo
        if assetBundle ~= nil then
            local multipleSprites = depData.multipleSprites
            if multipleSprites ~= nil then
                return multipleSprites[name]
            else
                assetBundle.IsUnload = false
                local objList = assetBundle.mAssetBundle:LoadAll()
                multipleSprites = {}
                for _, spriteObj in ipairs(objList) do
                    multipleSprites[spriteObj.name] = spriteObj
                end
                return multipleSprites[name]
            end
        end
    end
    Log.Error("AssetBatchWrapper:GetTextures找不到资源:" .. file)
    return nil
end

-- 非依赖资源，窗口创建完可以制裁
function AssetBatchWrapper:ClearMainAsset()
    if not self.IsClearMain and self.ResLoaded then
        if self.assetBundleBatch ~= nil then
            self.assetBundleBatch:ClearMainAsset()
        end
        self.IsClearMain = true
    end
end

-- 依赖资源，窗口销毁的时候卸载
function AssetBatchWrapper:ClearDepAsset()
    if not self.IsClearDep and self.ResLoaded then
        for _, data in pairs(self.resList) do
            if data["type"] ~= nil and data["type"] == AssetType.Dep then
                AssetPoolManager.Instance.assetDepPool:DescHoldCount(data.file)
            end
        end
        self.IsClearDep = true
    end
end

function AssetBatchWrapper:ClearAll()
    self:ClearMainAsset()
    self:ClearDepAsset()
end

function AssetBatchWrapper:RefreshTime()
    for _, data in pairs(self.resList) do
        if data.type == AssetType.Main then
            AssetPoolManager.Instance.assetPool:Get(data.file)
        end
    end
end

