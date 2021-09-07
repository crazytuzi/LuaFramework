AssetWrapperAction  = AssetWrapperAction or BaseClass(CombatBaseAction)

function AssetWrapperAction:__init(brocastCtx, minoraction, resList)
    self.resList = {}
    self.minoraction = minoraction
    if resList ~= nil and next(resList) ~= nil then
        for _,v in pairs(resList) do
            table.insert(self.resList, {file = v, type = AssetType.Main})
        end
    end
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
    else
        Log.Error("assetWrapper不可以重复使用 at AssetWrapperAction")
    end
    self.minoraction.assetwrapper = self.assetWrapper
end

function AssetWrapperAction:Play()
    self.assetWrapper:LoadAssetBundle(self.resList, function() self:OnActionEnd() end)
end

function AssetWrapperAction:AddResPath(tab)
    if tab == nil or next(tab) == nil then return end
    for _,v in pairs(tab) do
        table.insert(self.resList, {file = v, type = AssetType.Main})
    end
end

function AssetWrapperAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
