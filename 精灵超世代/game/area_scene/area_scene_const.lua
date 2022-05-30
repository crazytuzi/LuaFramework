Area_sceneConst = Area_sceneConst or {}

-- 各层级地图的Y坐标
Area_sceneConst.Map_Pos_Y = {
    [1] = 0, -- 地图层
    [2] = 650, -- 中景层
    [3] = 750,   -- 远景层
}

-- 区场景类型定义(对应 Config.city_data 中的id)
Area_sceneConst.Area_Type = {
    Shop = 3, -- 商业区
}

-- 商业区建筑id定义
Area_sceneConst.Shop_Type = {
    score = 1,  -- 积分商店
    sprite = 2, -- 精灵商店
    gift = 3,   -- 礼包商店
    skin = 4,   -- 皮肤商店
    plume = 5,  -- 圣羽商店
    item = 6,   -- 杂货店
}