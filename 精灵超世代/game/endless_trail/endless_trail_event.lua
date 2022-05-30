Endless_trailEvent = Endless_trailEvent or {}

--请求基础信息返回
Endless_trailEvent.UPDATA_BASE_DATA = "Endless_trailEvent.UPDATA_BASE_DATA"

--请求首通奖励返回
Endless_trailEvent.UPDATA_FIRST_DATA = "Endless_trailEvent.UPDATA_FIRST_DATA"

--派遣伙伴信息
Endless_trailEvent.UPDATA_SENDPARTNER_DATA = "Endless_trailEvent.UPDATA_SENDPARTNER_DATA"

--可雇佣伙伴信息
Endless_trailEvent.UPDATA_HIREPARNER_DATA = "Endless_trailEvent.UPDATA_HIREPARNER_DATA"

--已雇佣
Endless_trailEvent.UPDATA_HASHIREPARNER_DATA = "Endless_trailEvent.UPDATA_HASHIREPARNER_DATA"

--首通红点事件
Endless_trailEvent.UPDATA_REDPOINT_FIRST_DATA = "Endless_trailEvent.UPDATA_REDPOINT_FIRST_DATA"

--获取所有日常奖励结算红点事件
Endless_trailEvent.UPDATA_REDPOINT_REWARD_DATA = "Endless_trailEvent.UPDATA_REDPOINT_REWARD_DATA"

--支援他人红点减
Endless_trailEvent.UPDATA_REDPOINT_SENDPARTNER_DATA = "Endless_trailEvent.UPDATA_REDPOINT_SENDPARTNER_DATA"


--无尽试炼战斗界面
Endless_trailEvent.UPDATA_ENDLESSBATTLE_DATA = "Endless_trailEvent.UPDATA_ENDLESSBATTLE_DATA"

--无尽试炼buff界面
Endless_trailEvent.UPDATA_BUFF_DATA = "Endless_trailEvent.UPDATA_BUFF_DATA"

--无尽试炼派遣
Endless_trailEvent.UPDATA_SENDPARTNER_SUCESS_DATA = "Endless_trailEvent.UPDATA_SENDPARTNER_SUCESS_DATA"

--无尽试炼在试炼之门的红点
Endless_trailEvent.UPDATA_ESECSICE_ENDLESS_REDPOINT = "Endless_trailEvent.UPDATA_ESECSICE_ENDLESS_REDPOINT"

--刷新排行榜返回
Endless_trailEvent.UPDATA_RANK_DATA = "Endless_trailEvent.UPDATA_RANK_DATA"

-- 伤害排行榜
Endless_trailEvent.type = {
    rank = 1,
    reward = 2
}

Endless_trailEvent.helptype = {
    friend = 1,
    me = 2
}

Endless_trailEvent.Tab_Index = {
    endless = 1,  -- 无尽试炼
	campEndless = 2,  -- 阵营试炼
}

Endless_trailEvent.endless_type = {
    water = 1,  -- 水类型
    fire = 2,  -- 火类型
    wind = 3,  -- 风类型
    light_dark = 4,  -- 光暗类型
    old = 5,  -- 老版类型
}


-- 物品的星级颜色
Endless_trailEvent.type_name = {
    [34] = TI18N("水系"),
    [35] = TI18N("火系"),
    [36] = TI18N("风系"),
    [37] = TI18N("光暗")
}