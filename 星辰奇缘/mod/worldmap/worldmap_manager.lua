-- ----------------------------------------------------------
-- 逻辑模块 - 世界地图
-- ----------------------------------------------------------
WorldMapManager = WorldMapManager or BaseClass(BaseManager)

function WorldMapManager:__init()
    if WorldMapManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	WorldMapManager.Instance = self

    self.model = WorldMapModel.New()
end

function WorldMapManager:__delete()
end

function WorldMapManager:FixedUpdate()
	self.model:FixedUpdate()
end