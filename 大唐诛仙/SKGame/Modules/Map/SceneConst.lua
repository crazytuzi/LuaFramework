SceneConst = {}

SceneConst.OBJ_MOVE = "1"

SceneConst.OBJ_STOP = "2"

SceneConst.OBJ_UPDATE = "3" -- 更新属性数据

SceneConst.OBJ_POS_DIR_UPDATE = "4" -- 方位更新

SceneConst.TARGET_POS_CHANGE = "5" -- 目标变化位置

SceneConst.OBJ_DIE = "6" -- 死亡

SceneConst.TowerLevelMax = 13   --大荒塔的层数

SceneConst.MapType = {
	None = 0,  --初始化用
	Main = 1, --主城(城镇)
	Outdoor1 = 2, --野外（pk）
	Outdoor2 = 5, --野外（安全）
	Tower= 3,  --大荒塔
	Copy= 4, -- 副本
	Tianti= 5  --天梯(竞技场)
}

SceneConst.CollectType = {
	None = 0,
	General = 1,
	Advanced = 2,
	Task = 3
}

SceneConst.NewBeeSceneId = 1000
SceneConst.MainCitySceneId = 1001

SceneConst.CollectDistance = 2

SceneConst.PickupDistance = 2

SceneConst.MaxPlayerOnNormal = 30 -- 普通场景限人数
SceneConst.MaxPlayerOnNewer = 12 -- 新手村限人数