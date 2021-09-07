FormationEumn = FormationEumn or {}

FormationEumn.Type = {
    None = 1, -- 普通阵
    Wind = 2, -- 疾风阵
    Wood = 3, -- 密林阵
    Fire = 4, -- 天火阵
    Hill = 5, -- 山岳阵
    Star = 6, -- 星魂阵
    Sky = 7, -- 苍穹阵
    Thunder = 8, -- 雷霆阵
}

-- 守护状态
FormationEumn.GuardStatus = {
    Idle = 0, -- 空闲
    Fight = 1, -- 参战
    Help = 2, -- 助战
}

-- 对应界面上的位置
FormationEumn.TypePosition = {
    [FormationEumn.Type.None] = {Vector3(0, 0, 0), Vector3(-63, -47, -41), Vector3(63, 47, 44), Vector3(-122, -93, -83), Vector3(122, 93, 87)},
    [FormationEumn.Type.Wind] = {Vector3(-8, 18, 0), Vector3(-5, -74, -62), Vector3(100, -12, 12), Vector3(-119, -66, -52), Vector3(92, 95, 93)},
    [FormationEumn.Type.Wood] = {Vector3(58, -26, -20), Vector3(-13, -63, -63), Vector3(118, 13, 21), Vector3(-112, -49, -52), Vector3(122, 93, 103)},
    [FormationEumn.Type.Fire] = {Vector3(63, -47, -12), Vector3(-63, -47, -41), Vector3(63, 47, 44), Vector3(-122, -93, -83), Vector3(122, 93, 87)},
    [FormationEumn.Type.Hill] = {Vector3(-35, 30, 31), Vector3(-111, -26, -11), Vector3(40, 82, 72), Vector3(-19, -78, 31), Vector3(121, 26, -45)},
    [FormationEumn.Type.Star] = {Vector3(106, -6, 3), Vector3(29, -58, -39), Vector3(10, 47, 39), Vector3(-112, -49, -39), Vector3(73, 94, 80)},
    [FormationEumn.Type.Sky] = {Vector3(50, -22, 3), Vector3(-26, -78, -39), Vector3(125, 30, 39), Vector3(-108, -17, -39), Vector3(32, 87, 80)},
    [FormationEumn.Type.Thunder] = {Vector3(84, -25, 3), Vector3(-42, -25, -39), Vector3(21, 23, 39), Vector3(-101, -71, -39), Vector3(80, 69, 80)},
}

FormationEumn.TypeLayer = {
    [FormationEumn.Type.None] = {4,2,1,3,5},
    [FormationEumn.Type.Wind] = {4,3,1,2,5},
    [FormationEumn.Type.Wood] = {4,3,1,2,5},
    [FormationEumn.Type.Fire] = {4,2,1,3,5},
    [FormationEumn.Type.Hill] = {5,2,1,4,3},
    [FormationEumn.Type.Star] = {2,5,1,3,4},
    [FormationEumn.Type.Sky] = {2,5,1,3,4},
    [FormationEumn.Type.Thunder] = {2,4,1,3,5},
}
