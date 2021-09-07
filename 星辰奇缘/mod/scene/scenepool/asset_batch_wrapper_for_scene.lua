AssetBatchWrapper_ForScene = AssetBatchWrapper_ForScene or BaseClass()

function AssetBatchWrapper_ForScene:__init()
    self.assetBundleBatch = nil
    self.IsClearMain = false
    self.IsClearDep = false
    self.resList = {}
    self.loadCache = BaseUtils.create_queue()
end

function AssetBatchWrapper_ForScene:__delete()
    self:ClearAll()
    self.assetBundleBatch = nil
end

function AssetBatchWrapper_ForScene:LoadAssetBundle(resList, mOnLoadCompleted)
    if self.assetBundleBatch == nil then
        local callback = function()
            self:AddPool()
            if mOnLoadCompleted ~= nil then
                mOnLoadCompleted()
            end
            self:OnLoadCompleted()
        end
        self:Load(resList, callback)
    else
        BaseUtils.enqueue(self.loadCache, { resList = resList, mOnLoadCompleted = mOnLoadCompleted })
    end
end

function AssetBatchWrapper_ForScene:OnLoadCompleted()
    if self.assetBundleBatch ~= nil then
        self.assetBundleBatch:ClearAll()
        self.assetBundleBatch = nil
    end

    local loadData = BaseUtils.dequeue(self.loadCache)
    if loadData ~= nil then 
        self:LoadAssetBundle(loadData.resList, loadData.mOnLoadCompleted) 
    end
end

function AssetBatchWrapper_ForScene:Load(list, mOnLoadCompleted)
    local callback = function()
        if mOnLoadCompleted ~= nil then
            mOnLoadCompleted()
        end
    end
    self.resList = {}
    local mainAssets = {}
    local depAssets = {}
    for _, data in ipairs(list) do
        if data["type"] ~= nil and data["type"] == AssetType.Dep then
            table.insert(depAssets, data)
        else
            -- 检查缓存
            if not AssetPoolManager.Instance.assetPool_ForScene:Contain(data.file) then
                table.insert(mainAssets, data)
                data.from = AssetFrom.Loader
                self.resList[data.file] = data
            end
        end
    end
    if #mainAssets > 0 or #depAssets > 0 then
        self.assetBundleBatch = AssetBundleBatch()
        self.assetBundleBatch:LoadAssetBundle(mainAssets, depAssets, callback)
    else
        callback()
    end
end

function AssetBatchWrapper_ForScene:AddPool()
    for key, data in pairs(self.resList) do
        local assetBundle = self.assetBundleBatch:GetAssetBundleInfo(data.file)
        if assetBundle ~= nil then
            local mainAsset = assetBundle:GetMainAsset()
            local holdTime = BaseUtils.DefaultHoldTime()
            if data.holdTime ~= nil then
                holdTime = data.holdTime
            end
            data.from = AssetFrom.Cache
            AssetPoolManager.Instance.assetPool_ForScene:Add(data.file, mainAsset, holdTime, data)
        end
    end
end

function AssetBatchWrapper_ForScene:GetMainAsset(file)
    local info = AssetPoolManager.Instance.assetPool_ForScene:Get(file)
    if info ~= nil then
        return info.asset
    end
    return nil
end

-- 从图集里面获取
function AssetBatchWrapper_ForScene:GetSprite(file, name)
    local assetBundle = self.assetBundleBatch:GetAssetBundleInfo(file)
    if assetBundle ~= nil then
        return assetBundle:GetSprite(name)
    else
        Log.Error("AssetBatchWrapper_ForScene:GetSprite找不到资源:" .. file)
        return nil
    end
end

-- 是否在对象池中
function AssetBatchWrapper_ForScene:InAssetPoor(file)
    return AssetPoolManager.Instance.assetPool_ForScene:Get(file) ~= nil
end

-- 获取在对象池中对象
function AssetBatchWrapper_ForScene:GetAssetPoorCache(file)
    return AssetPoolManager.Instance.assetPool_ForScene:Get(file)
end

-- 非依赖资源，窗口创建完可以制裁
function AssetBatchWrapper_ForScene:ClearMainAsset()
    if not self.IsClearMain then
        if self.assetBundleBatch ~= nil then
            self.assetBundleBatch:ClearMainAsset()
        end
        self.IsClearMain = true
    end
end

-- 依赖资源，窗口销毁的时候卸载
function AssetBatchWrapper_ForScene:ClearDepAsset()
    if not self.IsClearDep then
        if self.assetBundleBatch ~= nil then
            self.assetBundleBatch:ClearDepAsset()
        end
        self.IsClearDep = true
    end
end

function AssetBatchWrapper_ForScene:ClearAll()
    self:ClearMainAsset()
    self:ClearDepAsset()
end



------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
function AssetBatchWrapper_ForScene:Get_MapCellAsset_Num()
    return AssetPoolManager.Instance.assetPool_ForScene:Get_MapCellAsset_Num()
end

function AssetBatchWrapper_ForScene:Set_MapCellAsset_DelNow(mapid, newMapId)
    return AssetPoolManager.Instance.assetPool_ForScene:Set_MapCellAsset_DelNow(mapid, newMapId)
end

function AssetBatchWrapper_ForScene:Set_MapCellAsset_Leavetime(mapid)
    AssetPoolManager.Instance.assetPool_ForScene:Set_MapCellAsset_Leavetime(mapid)
end