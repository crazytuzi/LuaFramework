GuildvoyageConst = GuildvoyageConst or {} 

GuildvoyageConst.index = {
    order = 1,              -- 可接订单
    escort = 2,             -- 正在护送
    interaction = 3,        -- 互助加速
}

-- 1:待执行 2:正在执行 3:待领取 4:已领取
GuildvoyageConst.status = {
    accept = 1,
    doing = 2,
    submit = 3,
    over = 4
}

-- 订单类型
GuildvoyageConst.escort_type = {
    prepare = 1, -- 可接订单
    escort = 2  -- 护送中订单
}