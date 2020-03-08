
local tbAct      = Activity:GetUiSetting("DongRiJiAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "新春福袋"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]新春福袋活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%s~%s[-]
[FFFE0D]参与等级：[-]20级
[FFFE0D]收到福袋 填写愿望[-]
活动开始时玩家会收到一封附有[ff578c][url=openwnd:新春福袋, ItemTips, "Item", nil, 10224][-]的邮件，大侠可以打开福袋尽快选择想要收到的礼物。
[FFFE0D]选购礼物 赠予好友[-]
活动开始后商城将会上架一系列[FFFE0D]开年利是[-]，大侠可以根据自己好友的愿望选购然后写好寄语送出，加深双方之间的友谊，可获得大量[FFFE0D]亲密度[-]，每天两人之间可获得亲密度上限为[FFFE0D]10000[-]。大侠赠送礼物的时候注意查看对方的愿望哦，每满足其他玩家[FFFE0D]5个愿望[-]自己还会额外获得[FFFE0D]10000贡献[-]！
购买的礼物在活动结束时会过期，大侠记得及时送出！
[FFFE0D]江湖重聚 额外奖励[-]
如果活动中大侠选择给以为已经[FFFE0D]退隐江湖[-]的玩家赠送礼物，如果活动中该玩家重回江湖，则双方都能收到[FFFE0D]5000贡献[-]和[aa62fc][url=openwnd:花草礼包, ItemTips, "Item", nil, 3698][-]！快去邀请隐士们重回江湖吧！
[FFFE0D]送礼积分 排行发奖[-]
活动期间玩家送出不同的礼物将获得对应的积分，系统将根据积分设置排行，活动结束时将根据最终的排行发放奖励。
第1名将获得[ff8f06][url=openwnd:新春福袋宝箱·二阶, ItemTips, "Item", nil, 10298][-]；
第2~10名将获得[aa62fc][url=openwnd:新春福袋宝箱·一阶, ItemTips, "Item", nil, 10299][-]。
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc7(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end