-- ------------------------------
-- 任务相关的枚举
-- ------------------------------
QuestEumn = QuestEumn or {}

-- 任务状态
QuestEumn.TaskStatus = {
    CanAccept = 0, -- 可接
    Doing = 1, -- 进行中
    Finish = 2, -- 已完成，未领奖
    End = 3, -- 已完成,并且已领奖
}

--任务类型大类型
QuestEumn.TaskTypeSer = {
    other = 0 --其他
    ,main = 1 --主线
}

--任务类型
QuestEumn.TaskType ={
    main = 1 --主线
    ,branch = 2 -- 支线
    ,offer = 3 --悬赏
    ,cycle = 4 --职业循环
    ,practice = 5 --历练
    ,practice_pro = 6 --历练精英
    ,convoy = 7 --护送任务
    ,daily = 8 --极寒试练
    ,dungeon = 9-- 副本
    ,kill = 10-- 屠魔
    ,treasuremap = 11--藏宝图
    ,guild = 12--公会任务
    ,guide = 13--指引任务
    ,chain = 14 --任务链
    ,couple = 15 -- 伴侣任务
    ,ambiguous = 16 -- 情缘任务
    ,plant = 17 -- 种植任务
    ,teacher = 18 -- 师徒任务
    ,shipping = 19 -- 师徒任务
    ,seekChild = 20 -- 抓迷藏
    ,fineType = 21 --五行修业任务
    ,defensecake = 22 --保卫蛋糕
    ,child = 23 -- 子女
    ,childbreed = 24 -- 子女孕育任务
    ,acquaintance = 25 -- 结缘任务
    ,leveljump = 26 -- 等级突破
    ,king = 27  -- 皇家任务
    ,summer = 28 -- 夏日任务
    ,singledog = 29 -- 逆袭任务
    ,camp_inquire = 30 -- 调查活动任务
    ,sign_draw = 31 --签到抽奖任务
    ,april_treasure = 33 --欢乐寻宝任务
    ,integral_exchange = 34 -- 积分兑换任务
    ,war_order = 35 --战令任务
}

-- 任务统计类型
QuestEumn.StatisticsType = {
    Ring = 1, --环数
    Round = 2, --轮次
    LeaderTimes = 3, -- 队长次数
    CommitBattleId = 6, -- 战场id
    CommitId = 7, -- npcid
    CommitBaseId = 8, -- 基础id
    QuestionId = 9, -- 答题编号
    QuestionZoneId = 10, -- 答题编号平台
    QuestStatsCanCommit = 11, -- 是否可以提交游侠任务
    ChainLuckyVal = 12, -- 历练幸运值
}

-- 任务字符串展示类型
QuestEumn.StringType = {
    TargetName = 1, -- 目标名称
    QuestionFlatform = 2, -- 答题平台
}

-- 任务服务端扩展数据类型
QuestEumn.ExtType = {
    MapBaseId = 1, --地图基础id
    PetBaseId = 2, --宠物基础id
    ItemBaseId = 3, --道具基础id
    UnitBaseId = 4, --单位基础id
    TargetNpcId = 5, --目标npcid
    CommitBattleId = 6,--提交任务战场id
    CommitNpcId = 7, --提交npcid
    CommitNpcBaseId = 8, --提交npc基础id
    ItemType = 9, -- 任务道具类型
}

--配置label操作
QuestEumn.LabelAct = {
    npc = 1,--npc对话
    gohome = 98,--回家园
    panel = 99,--打开界面
}

-- 任务类型对应的颜色名称
QuestEumn.TypeName = {
    [1] = TI18N("剧情")
    ,[2] = TI18N("支线")
    ,[3] = TI18N("悬赏")
    ,[4] = TI18N("职业")
    ,[5] = TI18N("剧情")
    ,[6] = TI18N("剧情")
    ,[7] = TI18N("护送")
    ,[8] = TI18N("试炼")
    ,[9] = TI18N("副本")
    ,[10] = TI18N("屠魔")
    ,[11] = TI18N("宝图")
    ,[12] = TI18N("公会")
    ,[13] = TI18N("指引")
    ,[14] = TI18N("历练")
    ,[15] = TI18N("情缘")
    ,[16] = TI18N("情缘")
    ,[17] = TI18N("植树")
    ,[18] = TI18N("师徒")
    ,[19] = TI18N("远航")
    ,[20] = TI18N("捉迷藏")
    ,[21] = TI18N("游侠")
    ,[22] = TI18N("保卫蛋糕")
    ,[23] = TI18N("子女")
    ,[24] = TI18N("孕育")
    ,[25] = TI18N("结缘")
    ,[26] = TI18N("等级突破")
    ,[27] = TI18N("暖心")
    ,[28] = TI18N("夏日")
    ,[29] = TI18N("逆袭")
    ,[30] = TI18N("调查活动")
    ,[31] = TI18N("抽奖")
}


-- 任务状态对应颜色名称
QuestEumn.StateName = {
    TI18N("[可接]")
    ,""
    ,TI18N("[完成]")
}

--任务要求标签
QuestEumn.CliLabel = {
    use = 1--使用道具
    ,fight = 2--杀死单位
    ,visit = 3--单位对话
    ,collect = 4--单位操作
    ,into = 5--进入场景
    ,gain = 6--获得道具
    ,upskill = 7--技能升级
    ,choosepet = 8--选中宠物
    ,guard = 9-- 招募守护
    ,newequip = 10--更新装备
    ,joinguild = 11--加入公会
    ,petfight = 12--宠物出战
    ,patrol = 13--巡逻
    ,levelup = 14--升级
    ,catchpet = 15--捕捉宠物
    ,dungeon = 16--通关副本
    ,finish_offer = 17--完成悬赏任务环
    ,arena_win = 18--竞技场胜利
    ,arena_join = 19--参与竞技场
    ,publicity = 21 --公会宣传
    ,guild_plantflower = 22 --公会种花
    ,couple_answer = 23 -- 伴侣答题
    ,couple_flower = 24 -- 伴侣送花
    ,protest = 25 -- 示威
    ,ambiguous_answer = 26 -- 情缘答题
    ,plant_tree = 27 -- 种植耕耘
    ,teacher_answer = 28 -- 师徒答题
    ,goto_bed = 34 --造人
    ,pregnancy = 35 --孕育
    ,wing_lev = 36 -- 翅膀等级
    ,guild_talk = 52 -- 公会说话
    ,rideChoose = 54 -- 新手坐骑任务
}

--任务要求描述
QuestEumn.RequireName = {
    [1] = TI18N("使用")
    ,[2] = TI18N("击败")
    ,[3] = TI18N("拜访")
    ,[4] = TI18N("采集")
    ,[5] = TI18N("进入")
    ,[6] = TI18N("为<color='#00ff12'>%s</color>寻来<color='#00ff12'>%s</color>")--寻物
    ,[7] = TI18N("提升技能")
    ,[8] = TI18N("选择宠物")
    ,[9] = TI18N("招募守护")
    ,[10] = TI18N("更新装备")
    ,[11] = TI18N("加入公会")
    ,[12] = TI18N("宠物出战")
    ,[13] = TI18N("巡逻")
    ,[14] = TI18N("升级")
    ,[15] = TI18N("为<color='#00ff12'>%s</color>捕捉或购买一只野生的<color='#00ff12'>%s</color>")--捕宠
    ,[16] = TI18N("通关副本")
    ,[17] = TI18N("完成悬赏任务环")
    ,[18] = TI18N("竞技场胜利")
    ,[19] = TI18N("参与竞技场")
    ,[21] = TI18N("公会宣传")
    ,[22] = TI18N("公会种花")
    ,[23] = TI18N("伴侣共同答题")
    ,[24] = TI18N("伴侣相互送花")
    ,[25] = TI18N("教训四处挑衅的<color='#ffff00'>%s</color>")
    ,[26] = TI18N("异性好友共同答题")
    ,[27] = TI18N("种植耕耘")
    ,[28] = TI18N("师徒答题")
    ,[34] = TI18N("造人计划")
    ,[35] = TI18N("孕育任务")
    ,[100] = ""
}

-- 任务自动进行标签
QuestEumn.AutoNext = {
    AllYes = 1, --全部状态都跑
    AllNot = 2, -- 全部状态都不跑
    NotAccept = 3, -- 不去接
    NotForward = 4, -- 不去做
    NotCommit = 5, -- 不去提
    JustAccept = 6, -- 只去接
}

-- 任务颜色
function QuestEumn.ColorName(type)
    local color = "#ffcc66"
    if type == QuestEumn.TaskType.main or type == QuestEumn.TaskType.practice or type == QuestEumn.TaskType.practice_pro then--主线，历练
        color = "#fa74ff"
    elseif type == QuestEumn.TaskType.guide then-- 指引任务
        color = "#00ccff"
    elseif type == QuestEumn.TaskType.plant then
        -- 活动
        color = "#61e261"
    end
    return color
end

-- 任务对话框颜色
function QuestEumn.ColorNameDialog(type)
    local color = "#195195"
    if type == QuestEumn.TaskType.main or type == QuestEumn.TaskType.practice or type == QuestEumn.TaskType.practice_pro then--主线，历练
        color = "#8037d2"
    elseif type == QuestEumn.TaskType.guide then--指引任务
        color = "#00ccff"
    end
    return color
end

-- 任务奖励格式化
function QuestEumn.AwardItemInfo(v)
    local _baseid = 0
    local _count = 0
    local _bind = 1

    if v.label == "item_base_id" then
        _baseid = v.val[1][1]
        _bind = v.val[1][2]
    _count = v.val[1][3]
    elseif v.label == "exp" then
        _baseid = 90010
        _count = v.val[1]
    elseif v.label == "coin" then
        _baseid = 90000
        _count = v.val[1]
    elseif v.label == "classes_item" then
        _baseid = v.val[RoleManager.Instance.RoleData.classes][2]
        _bind = v.val[RoleManager.Instance.RoleData.classes][3]
        _count = v.val[RoleManager.Instance.RoleData.classes][4]
    elseif v.label == "pet_exp" then
        _baseid = 90005
        _count = v.val[1]
    elseif v.label == "pet" then
        return nil
    elseif v.label == "pet_custom" then
        return nil
    elseif v.label == "classes_sex_item" then
        local classes = RoleManager.Instance.RoleData.classes
        local sex = RoleManager.Instance.RoleData.sex
        -- _baseid = v.val[1 + sex + (classes - 1) * 2][3]
        -- _bind = v.val[1 + sex + (classes - 1) * 2][4]
        -- _count = v.val[1 + sex + (classes - 1) * 2][5]
        local dat = v.val[(1 - sex) * #KvData.classes_name + classes]
        _baseid = dat[3]
        _bind = dat[4]
        _count = dat[5]
    else
        return nil
    end
    return {baseid = _baseid, count = _count, bind = _bind}
end

--根据职业性别获取内容显示
function QuestEumn.FilterContent(str)
    local m = StringHelper.MatchBetweenSymbols(str, "【", "】")
    if #m > 1 then
        m = m[RoleManager.Instance.RoleData.sex + 1]
    elseif #m == 1 then
        m = m[1]
    else
        m = str
    end
    m = string.gsub(m, "%[role%]", RoleManager.Instance.RoleData.name)
    return m
end

QuestEumn.PlantBaseId = {
    [1] = 76180,
    [2] = 76181,
    [3] = 76182,
    [4] = 76183,
}

QuestEumn.PlantName = {
    [1] = TI18N("下一阶段"),
    [2] = TI18N("下一阶段"),
    [3] = TI18N("下一阶段"),
    [4] = ""
}

QuestEumn.PlantTime = {
    [1] = 180,
    [2] = 300,
    [3] = 600,
    [4] = 180,
}

QuestEumn.PlantDesc = {
    TI18N("纯真，不是外在而是内在；童心，不是心灵而是心态；幸福，不是物质而是感受；六一儿童节，愿你拥有纯真童心，幸福相伴一生。")
    ,TI18N("面部保持住童颜，心里驻留一颗童心，生活中不时来点童趣，思想里保留一些童真，六一儿童节，愿你拥有儿童般的快乐。")
    ,TI18N("站在地上打过枣，爬到树上啃过梨，钻进田里摘过瓜，下到水里摸过鱼。儿时的生活很调皮，儿时的生活很有趣。不知你是否常忆起？六一儿童节，愿你的生活有童趣，愿你的生活有童真，无忧无虑快乐心！")
    ,TI18N("青春短暂，不要叹老，人生中最重要的就是保持几分天真童心，这样才能使自己永远快乐、永远幸福。今天是特殊的日子，祝你童心不老。")
    ,TI18N("一曲同桌的你唤回多少回忆，谁还能记起争执的起因是半块橡皮，多少日夜的纸醉金迷，谁还会执著的写下日记，六一儿童节，回味已经逝去的美丽！")
    ,TI18N("有了扣扣，我们却少了见面；有了手机，我们却少了交心；有了金钱，我们却少了健康；六一儿童节，愿你我能重回儿童时代，即使什么都没有，我们却是最快乐的。")

    -- ,"清明节快乐，三天假期，别整天宅家里哦，记得出去踏青~"
    -- ,"清明时节雨纷纷，路上行人欲断魂，记得回家扫扫墓，免得杂草长满坟"
    -- ,"明朝寒食了，又是一年春，春来发时节，超短将满城。"
    -- ,"燕子来时新社，梨花落后清明，已是一年春来到，请把红唇描。"
    -- ,"清明节至，愿生者珍惜幸福，愿逝者平静安息。"
    -- ,"一路跌跌撞撞，看岁月刻下沧桑，又是一年清明，三天假里偷闲，有条件就回家吧，多陪陪家里老人。"
    -- ,"杨柳青青着地垂，杨花漫漫搅天飞。柳条折尽花飞尽，借问行人归不归。"
    -- ,"清明节里好踏青，愿你带上幸福的包袱，顺着洋溢的春风，踏上多姿多彩的旅程"
    -- ,"无花无酒过清明，兴味萧然似野僧。有美相伴饮满觞，欲仙欲死赛神仙"
}

