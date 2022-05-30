    -- 事件编号定义
EventId = {
    LOGIN_SUCCESS               = 1,
    SCENE_LAYER_CHANGE          = 2,
    ROLE_CREATE_SUCCESS         = 3,

    BASEVIEW_POPUP			 	= 4,  --界面弹出
    DISCONNECT					= 5,  --断开链接
    CONNECTED					= 6,  --异步链接成功
    ON_VOICE_UPLOAD_RESULT      = 7,  -- 界面弹出

    ON_SPINE_DOWNLOADED         = 8,  --spine图片纹理加载完成()

    CLOSE_BASE_VIEW             = 9,  --窗体关闭

    CAN_OPEN_LEVUPGRADE         = 10, --触发这个事件的时候,就表示可以打开升级面板了

    CAN_OPEN_UNLOCKBUILD        = 11, --触发这个事件,就表示可以打开解锁界面了



     --1501~1600 聊天专用
    CHAT_NEWMSG_FLAG = 1501,        --有信息消息提示
    CHAT_UPDATE_WORD = 1505,        --聊天引用-更新常用語
    CHAT_SELECT_WORD = 1506,        --聊天引用-选择常用语
    CHAT_CLEAR_INPUT = 1507,        --聊天引用-清除输入框文本
    CHAT_UPDATE_EDIT = 1508,        --聊天引用-编辑界面打开状态更新
    CHAT_MAIN_SHOW   = 1509,        --左下角聊天-隐藏、显示
    CHAT_UPDATE_SELF = 1510,        --通用--更新私聊信息
    CHAT_CHANGE_SELF = 1511,        --私聊界面打开关闭状态更新
    CHAT_BACKSPACE   = 1512,        --回退删除输入的信息
    CHAT_CLOSEBTN_VISIBLE   = 1513,        --显示隐藏关闭按钮
    CHAT_SEND_VOICE  = 1514,        --发送聊天语音
    CHAT_SEND_MSGES  = 1515,        --发送文字信息
    CHAT_UDMSG_WORLD = 1516,        --更新世界频道数据
    CHAT_UDMSG_FRIEND= 1517,        --更新好友频道数据
    CHAT_UDMSG_ASSETS= 1518,        --更新资产聊天信息
    CHAT_CUSTOM_MSG  = 1520,        --自定义聊天数据
    CHAT_SELECT_FACE = 1521,        --选中表情

    CHAT_QUICK_SEND  = 1522,        --点击发送按钮
    CHAT_MAIN_ENABLE = 1523,        --左下角UI显隐
    CHAT_TEAMID_CALL = 1524,        --返回队伍id通知
    CHAT_HEIGHT_CHANGE = 1525,      --主界面聊天框高度变化
    CHAT_SELECT_ITEM = 1526,        --选中物品

    
    BATTLE_ADD_ROLE = 1701,         -- 战斗添加角色
    BATTLE_SKILL_TIMEOUT = 1702,    -- 战斗选技能超时

    SCROLL_CREATE_FINISH = 2000,    -- 通用scrollview创建所有子项回调

}

-- 方向类型
DirType = DirType or {
    None = 0,        -- 未定
    Top = 1,         -- 向上
    Bottom = 2,      -- 向下
    Left = 3,        -- 向左
    Right = 4,       -- 向右
    LeftTop = 5,     -- 向左上
    LeftBottom = 6,  -- 向左下
    RightTop = 7,    -- 向右上
    RightBottom = 8  -- 向右下
}

ResourcesType = ResourcesType or {
    plist = 1,
    single = 2
}

ScrollViewDir = ScrollViewDir or {
    vertical = 1,
    horizontal = 2,
}

ScrollViewStartPos = ScrollViewStartPos or {
    top = 1,
    bottom = 2
}

NodeEventStatus = NodeEventStatus or
{
    un_activity = 0,
    activity = 1,
    pass_activity = 2
}

PlayerAction = PlayerAction or
{
    stand = "stand",
    stand_1 = "stand2_1",
    run = "run",
    run_1 = "run_1",
    sit = "sit",
    action = "action", -- 特效类的资源通用动作
    action_1 = "action1", -- 特效类型
    action_2 = "action2", -- 特效类型
    action_3 = "action3", -- 特效类型
    action_4 = "action4",
    action_5 = "action5",
    action_6 = "action6",
    action_7 = "action7",
    action_8 = "action8",
    action_9 = "action9",
    battle_stand = "stand2",
    -- battle_stand = "standby_loop1",
    hurt = "hurt",
    fun = "fun", -- 场景一些特殊单位的休闲动作
    show = "show", --英雄背包里的展示
    special_action_0 = "status_0", -- 特殊的特效动作名
    special_action_1 = "status_1",
    special_action_2 = "status_2",
    idle = "idle",  -- 家园角色 闲转
    move = "move",  -- 家园角色 移动
    interaction = "interaction",  -- 家园角色 互动
    caught_1 = "caught_1",  -- 家园角色 提起
    caught_2 = "caught_2",  -- 家园角色 移动
    caught_3 = "caught_3",  -- 家园角色 放下
    eating = "eating", --年兽吃动作
    sleeping = "sleeping", --年兽睡觉动作
}

--add by chenbin :新老spine兼容
BattleAction = {
    Standby = "standby_loop",
    Standby2 = "standby_loop2",
    Run = "run_loop",
    Win = "win_loop",
    Hurt = "hit",
    Attack = "attack",
    Skill1 = "skill1",
    Skill2 = "skill2",
}

BattleActionForPlayerAction = {
    [PlayerAction.stand] = BattleAction.Standby,
    [PlayerAction.stand_1] = BattleAction.Standby,
    [PlayerAction.battle_stand] = BattleAction.Standby,
    [PlayerAction.run] = BattleAction.Run,
    [PlayerAction.hurt] = BattleAction.Hurt,
    [PlayerAction.show] = BattleAction.Standby,
}
for k,v in pairs(BattleAction) do
    BattleActionForPlayerAction[k] = v
end
-------



WorshipType = WorshipType or 
{
    normal = 0,         -- 普通点赞
    godbattle = 1,      -- 众神战场
    ladder = 3,         -- 跨服天梯
    crossarena = 4,     -- 跨服竞技场
    home = 5,           -- 家园
    crosschampion = 6,  -- 跨服冠军赛
    monopoly = 7,       -- 圣夜奇境
    peakchampion = 8,   -- 巅峰冠军赛
}
