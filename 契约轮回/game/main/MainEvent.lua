-- 
-- @Author: LaoY
-- @Date:   2018-07-22 18:02:00
-- 

MainEvent = MainEvent or {
    OpenRocker = "MainEvent.OpenRocker", -- 打开摇杆
    HideRocker = "MainEvent.HideRocker", -- 隐藏摇杆
    StartRocker = "MainEvent.StartRocker", -- 开始摇杆
    MoveRocker = "MainEvent.MoveRocker", -- 移动摇杆
    StopRocker = "MainEvent.StopRocker", -- 停止摇杆
    RockerVec = "MainEvent.RockerVec", -- 摇杆方向

    SwithRight = "MainEvent.SwithRight", -- 切换右下角

    OpenMainPanel = "MainEvent.OpenMainPanel", --打开主界面
    HideMainPanel = "MainEvent.HideMainPanel", --隐藏主界面

    Attack = "MainEvent.Attack", -- 普通攻击
    ReleaseSkill = "MainEvent.ReleaseSkill", -- 释放技能

    OpenTaskTalk = "MainEvent.OpenTaskTalk", -- 任务对话界面
    OpenTaskReward = "MainEvent.OpenTaskReward", -- 任务奖励

    ShowTopRightIcon = "MainEvent.ShowTopRightIcon", -- 显示右上角图标
    HideTopRightIcon = "MainEvent.HideTopRightIcon", -- 隐藏右上角图标


    UpdateMidLeftVisible = "MainEvent.UpdateMidLeftVisible", -- 刷新左侧栏的显示隐藏状态

    MAIN_MIDDLE_LEFT_LOADED = "MainEvent.MainMiddleLeftLoaded",


    OpenMapPanel = "MainEvent.OpenMapPanel", -- 小地图
    MapTouchIcon = "MainEvent.MapTouchIcon", -- 点击小地图图标

    ClickSkiilItem = "MainEvent.ClickSkiilItem", -- 点击右下角技能 参数：技能类型(跳跃，普攻，技能等,见MainSkillItem.SkillType)

    -- MainUIModel 事件
    AddRightIcon = "MainEvent.AddRightIcon", -- 添加右上角图标 参数：key_str
    UpdateRightIcon = "MainEvent.UpdateRightIcon", -- 更新右上角图标 参数：key_str type(更新类型：数据|红点)
    RemoveRightIcon = "MainEvent.RemoveRightIcon", -- 移除右上角图标 参数：key_str

    -- MainUIModel 事件
    AddLeftIcon = "MainEvent.AddLeftIcon", -- 添加右上角图标 参数：key_str
    UpdateLeftIcon = "MainEvent.UpdateLeftIcon", -- 更新右上角图标 参数：key_str type(更新类型：数据|红点)
    RemoveLeftIcon = "MainEvent.RemoveLeftIcon", -- 移除右上角图标 参数：key_str

    -- 全局事件
    ChangeRightIcon = "MainEvent.ChangeRightIcon", -- 添加/移除/更新右上角图标
    ChangeLeftIcon = "MainEvent.ChangeLeftIcon",    --添加、移除、更新左上角图标
    -- 参数：
    -- key_str(IconConfig配置),flag(true显示(或更新)，false关闭),
    -- time_str(选填，结束时间|显示文本),is_destroy(选填,time结束是否删除，默认是),is_notice(选填，是否为预览)
    UpdateRightIconReddot = "MainEvent.UpdateRightIconReddot", -- 更新右上角图标红点
    -- 参数：
    -- key_str(IconConfig配置)  num(大于0表示要显示红点，小于等于0表示不需要红点)



    -- MainUIModel 事件
    AddMidTipIcon = "MainEvent.AddMidTipIcon", -- 添加中间提示图标 参数：key_str
    RemoveMidTipIcon = "MainEvent.RemoveMidTipIcon", -- 移除中间提示图标 参数：key_str

    -- 全局事件
    ChangeMidTipIcon = "MainEvent.ChangeMidTipIcon", -- 添加/移除/ 中间提示图标
    -- 参数：
    -- key_str(IconConfig配置),flag(true显示(或更新)，false关闭) call_back 点击回调
    -- (选填)
    -- num 数量，time 倒计时,sign 储存标志

    -- global
    ChangeRedDot = "MainEvent.ChangeRedDot", -- 设置红点

    -- MainModel 事件
    UpdateRedDot = "MainEvent.UpdateRedDot", -- 设置红点


    ChangePower = "MainEvent.ChangePower", -- 战力改变

    ShowSelfAfterOpen = "MainEvent.ShowSelfAfterOpen", -- 右上角图标开放之后显示出来
    CheckNeedPopSysShow = "MainEvent.CheckNeedPopSysShow", --（因为升级绑定时间比系统开放协议快）检查图标显示状态，在系统开放时
    UpdateNextSysPrediction = "MainEvent.UpdateNextSysPrediction", -- 系统开放之后更新系统开放预告
    SwitchLittleAngleShow = "MainEvent.SwitchLittleAngleShow", --切换小天使的显示
    ChangeThirdTopRightIconPos = "MainEvent.ChangeThirdTopRightIconPos", --切换右上 第三排图标位置

    --变强etc
    ChangeSystemShowInStronger = "MainEvent.ChangeSystemShowInStronger", --往变强中添加/删除可以操作的系统
    CloseStrongerPanel = "MainEvent.CloseStrongerPanel", --跳转后关闭变强面板
    StrongerItemClick = "MainEvent.StrongerItemClick", --变强按钮点击


    --关闭bm面板
    CloseGMPanel = "MainEvent.CloseGMPanel",
    UpdateGMPanelInput = "MainEvent.UpdateGMPanelInput",

    LevelRewardRet = "MainEvent.LevelRewardRet", --章节奖励

    CheckLoadMainIcon = "MainEvent.CheckLoadMainIcon",
    UploadingIconSuccess = "MainEvent.UploadingIconSuccess", --成功上传头像后
    ShowExpStatistics = "MainEvent.ShowExpStatistics", --经验统计

    CloseMainRightSub = "MainEvent.CloseMainRightSub",
}