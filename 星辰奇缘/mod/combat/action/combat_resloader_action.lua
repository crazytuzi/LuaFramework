-- 资源加载
ResloaderAction = ResloaderAction or BaseClass(CombatBaseAction)

-- resources = {string, ...}
function ResloaderAction:__init(brocastCtx, resources, parent)
    self.resources = resources
    self.assetWrapper = nil
    self.isLoaded = false
    self.isPlayed = false
    local list = {}
    for _, path in ipairs(resources) do
        table.insert(list, {file = path, type = CombatAssetType.Main, callback = nil})
    end
    -- 提前加载
    -- batch_asset_loader.New(ctx, list, function() self:OnLoadCompleted() end)
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
    else
        Log.Error("[Error]assetWrapper不可以重复使用 at ResloaderAction")
    end
    parent.assetWrapper = self.assetWrapper
end

function ResloaderAction:Play()
    self.assetWrapper:LoadAssetBundle(list, function() self:OnLoadCompleted() end)
    self.isPlayed = true
    self:CheckEnd()
end

function ResloaderAction:OnLoadCompleted()
    self.isLoaded = true
    self:CheckEnd()
end

function ResloaderAction:CheckEnd()
    if self.isPlayed and self.isLoaded then
        self:OnActionEnd()
    end
end

function ResloaderAction:OnActionEnd()
    -- -- print("==========ResloaderAction:OnActionEnd====================")
    self:InvokeAndClear(CombatEventType.End)
end
