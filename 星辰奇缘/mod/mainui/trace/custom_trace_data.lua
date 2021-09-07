-- -------------------------------
-- 自定义追踪项数据结构
-- hosr
-- -------------------------------
CustomTraceEunm = CustomTraceEunm or {}
CustomTraceEunm.Type = {
    None = 0,
    Activity = 1, -- 活动
    MainQuest = 2, -- 主线
    ActivityShort = 4,  -- 短活动
    Shipping = 3, -- 远航
    MonthlyCard = 5,    -- 月卡
    Monster = 6, -- 上古
}

CustomTraceData = CustomTraceData or BaseClass()

function CustomTraceData:__init()
    -- 唯一标识
    self.customId = 0
    -- 类型
    self.type = CustomTraceEunm.Type.None
    -- 标题
    self.title = ""
    -- 描述
    self.Desc = ""
    -- 点击回调
    self.callback = nil
    -- UI元素
    self.tab = {}
    --完成标志
    self.finish = false
    -- 倒计时时间
    self.countDown = 0
    -- 倒计时描述
    self.countDownDesc = TI18N("剩余时间:")
end
