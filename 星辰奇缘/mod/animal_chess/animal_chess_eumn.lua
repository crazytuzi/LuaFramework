-- 黄耀聪
-- 2017年5月4日
-- 斗兽棋枚举

AnimalChessEumn = AnimalChessEumn or {}

AnimalChessEumn.SlotStatus = AnimalChessEumn.SlotStatus or {
    Empty = 0,
    UnOpen = 1,
    Opened = 2,
}

AnimalChessEumn.OperateType = AnimalChessEumn.OperateType or {
    Open = 1,
    Move = 2,
    Attack = 3,
}

AnimalChessEumn.ChessType = AnimalChessEumn.ChessType or {
    [1] = {name = TI18N("兵"), skin_1 = 30401, skin_2 = 30501, model_id = 30001, animation_id = 3000101, scale = 100, defeat = {1,6}}
    , [2] = {name = TI18N("士"), skin_1 = 30405, skin_2 = 30505, model_id = 30005, animation_id = 3000501, scale = 100, defeat = {1,2}}
    , [3] = {name = TI18N("尉"), skin_1 = 30409, skin_2 = 30509, model_id = 30009, animation_id = 3000901, scale = 100, defeat = {1,2,3}}
    , [4] = {name = TI18N("校"), skin_1 = 30412, skin_2 = 30512, model_id = 30012, animation_id = 3001201, scale = 80, defeat = {1,2,3,4}}
    , [5] = {name = TI18N("将"), skin_1 = 30822, skin_2 = 30922, model_id = 30022, animation_id = 3002201, scale = 120, defeat = {1,2,3,4,5}}
    , [6] = {name = TI18N("帅"), skin_1 = 30838, skin_2 = 30938, model_id = 30038, animation_id = 3003801, scale = 100, defeat = {2,3,4,5,6}}
}

AnimalChessEumn.Motion = AnimalChessEumn.Motion or {
    ["Move"] = "move_id",
    ["Dead"] = "dead_id",
    ["Hit"] = "hit_id",
    ["Stand"] = "stand_id",
    ["Idle"] = "idle_id",
    ["Upthrow"] = "upthrow_id",
}

AnimalChessEumn.Status = AnimalChessEumn.Status or {
    Close = 0,      -- 不可参与
    Open = 1,       -- 可匹配
}

