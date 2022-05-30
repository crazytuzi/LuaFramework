EscortEvent = EscortEvent or {}

-- 护送的基础数据
EscortEvent.UpdateEscortBaseEvent = "EscortEvent.UpdateEscortBaseEvent"

-- 更新自身数据
EscortEvent.UpdateEscortMyInfoEvent = "EscortEvent.UpdateEscortMyInfoEvent"

-- 添加一个护送萌兽
EscortEvent.AddEscortPlayerList = "EscortEvent.AddEscortPlayerList"

-- 推送变化信息
EscortEvent.UpdateEscortPlayerList = "EscortEvent.UpdateEscortPlayerList"

-- 更新掠夺日志,只有请求才有
EscortEvent.UpdateEscortLogInfoEvent = "EscortEvent.UpdateEscortLogInfoEvent"

-- 更新当个掠夺日志,只是掠夺的
EscortEvent.UpdateEscortSingleLogInfo = "EscortEvent.UpdateEscortSingleLogInfo"



EscortConst = EscortConst or {}

EscortConst.log_type = {
    def = 1,    -- 谁掠夺我
    atk = 2     -- 掠夺他人
}

EscortConst.challenge_type = {
    revenge = 1,        -- 复仇
    repel = 2,          -- 击退 
}

-- 我的护送次数相关
EscortConst.times_type = {
    escort = 1,         -- 已派遣次数
    plunder = 2,        -- 已掠夺次数
    atk_back = 3,       -- 已复仇次数
    help = 4,           -- 已求助次数
    do_help = 5,        -- 已帮助次数
    refresh = 6         -- 已刷新次数
}

EscortConst.quality_color = {
    [0] = cc.c4b(0x78,0x78,0x78,0xff),
    [1] = cc.c4b(0x24,0x90,0x03,0xff),
    [2] = cc.c4b(0x3a,0x78,0xc4,0xff),
    [3] = cc.c4b(0xa8,0x38,0xbc,0xff),
    [4] = cc.c4b(0xe2,0x87,0x00,0xff),
}