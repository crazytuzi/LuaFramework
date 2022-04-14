---
--- Created by R2D2.
--- DateTime: 2019/1/8 14:40
---

WelfareEvent = WelfareEvent or {
    --打开窗体
    Welfare_OpenEvent = "WelfareEvent.OnOpenWelfare",
    --切换页面
    Welfare_ChangePageEvent = "WelfareEvent.OnChangePage",

    --[[签到]]
    --点击签到格
    Welfare_SignCellClick = "WelfareEvent.OnSignCellClick",
    --收到签收数据
    Welfare_SignDataEvent = "WelfareEvent.OnSignData",
    --签到返回
    Welfare_SignedEvent = "WelfareEvent.OnSigned",

    --[[在线奖励]]
    --获得在线奖励
    Welfare_OnlineRewardEvent = "WelfareEvent.OnOnlineReward",
    ---本地倒计时事件
    Welfare_OnlineLocalCountDownEvent = "WelfareEvent.OnOnlineLocalCountDown",

    --[[等级奖励]]
    Welfare_LevelDataEvent = "WelfareEvent.OnLevelData",
    Welfare_LevelRewardEvent = "WelfareEvent.OnLevelReward",

    --[[战力奖励]]
    Welfare_PowerDataEvent = "WelfareEvent.OnPowerData",
    Welfare_PowerRewardEvent = "WelfareEvent.OnPowerReward",

    --[[公告奖励]]
    Welfare_NoticeRewardEvent = "WelfareEvent.OnNoticeReward",

    --[[资源下载奖励]]
    Welfare_ResRewardEvent = "WelfareEvent.OnResReward",

    --[[祈福]]
    Welfare_GrailRefreshEvent = "WelfareEvent.OnGrailRefresh",

    --[[祈福]]
    Welfare_GiftCodeSuccessEvent = "WelfareEvent.OnGiftCodeSuccess",

    --------------------
    Welfare_Global_LevelRewardDataEvent = "WelfareEvent.Global.OnLevelRewardData",

    
}