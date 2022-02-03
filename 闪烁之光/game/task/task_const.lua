TaskConst = TaskConst or {}

TaskConst.type = {
    quest = 1,   --日常任务
    feat  = 2,   --成就
    exp   = 3,   --历练
}

TaskConst.action_status = {
    normal = 0,
    un_activity = 1,
    activity = 2,
    finish = 3
}

TaskConst.update_type = {
    quest = 1,
    feat = 2,
    activity = 3,
    exp = 4
}

TaskConst.task_type = {
    main = 1,                   -- 主线任务
    branch = 2,                 -- 支线任务
    daily = 3                   -- 日常任务
}

TaskConst.task_status = {
    un_finish  = 0,              -- 进行中
    finish     = 1,              -- 可提交
    completed  = 2,              -- 已提交
    over       = 3               -- 已过期
}

TaskConst.exp_type = {
    total        = 0, --总览
    pvp          = 1, --pvp
    common       = 3, --常规战斗
    special      = 2, --特殊
}