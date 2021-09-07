AssetPoolManager = AssetPoolManager or BaseClass()

function AssetPoolManager:__init()
    if AssetPoolManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    AssetPoolManager.Instance = self

    self.Counter = 0
    self.AssetUnloadCounter = 0

    self.assetPool = AssetPool.New()
    self.assetDepPool = AssetDepPool.New()

    self.assetPool_ForScene = AssetPool_ForScene.New()

    self.mapList = {50001, 50002, 50005, 50011, 50012, 50013, 50021, 50022, 50023}
end

function AssetPoolManager:__delete()
    self.assetPool:DeleteMe()
    self.assetPool = nil
    self.assetDepPool:DeleteMe()
    self.assetDepPool = nil
end

function AssetPoolManager:OnTick()
    -- self.Counter = self.Counter + 1
    self.AssetUnloadCounter = self.AssetUnloadCounter + 1

    -- -- 两秒执行一次
    -- if self.Counter > 10 then
    --     self.assetPool:CheckToRelease()
    --     self.assetPool_ForScene:CheckToRelease()
    --     self.assetDepPool:CheckToRelease()
    --     self.Counter = 0
    -- end

    -- 周年庆期间ios的释放时间临时缩短
    if BaseUtils.IsIPhonePlayer() then
        if self.AssetUnloadCounter > 750 then
            self:DoUnloadUnusedAssets()
        end
    else
        -- 省电模式五分钟清理一次
        if self.AssetUnloadCounter > 1500 then
            if not SleepManager.Instance.IsWakeUp then
                self:DoUnloadUnusedAssets()
            elseif self.AssetUnloadCounter > 1500 then
                self:DoUnloadUnusedAssets()
            end
        end
    end
    -- if self.AssetUnloadCounter > 6000 then
    --     self:DoUnloadUnusedAssets()
    -- elseif self.AssetUnloadCounter > 3000 then
    --     local mapId = SceneManager.Instance:CurrentMapId()
    --     for _, data in ipairs(self.mapList) do
    --         if mapId == data then
    --             self:DoUnloadUnusedAssets()
    --             break;
    --         end
    --     end
    -- end
end

function AssetPoolManager:DoUnloadUnusedAssets()
    self.assetPool:CheckToRelease()
    self.assetPool_ForScene:CheckToRelease()
    self.assetDepPool:CheckToRelease()

    GoPoolManager.Instance:CheckResPool()

    self.AssetUnloadCounter = 0
    ctx:DoUnloadUnusedAssets() -- 清理资源
end
