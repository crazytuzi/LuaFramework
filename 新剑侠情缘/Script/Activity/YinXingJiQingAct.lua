
local tbAct      = Activity:GetUiSetting("YinXingJiQingAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "银杏寄情"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]银杏寄情活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%s~%s[-]
[FFFE0D]参与等级：[-]20级
江湖盛典即将来临，武林盟特为江湖中诸位大侠准备了一片[ff8f06][url=openwnd:并蒂金连叶, ItemTips, "Item", nil, 9918][-]，大侠可借此向自己重要的人表达情意。
[FFFE0D]撰写情书 择人寄出[-]
大侠可在[ff8f06][url=openwnd:并蒂金连叶, ItemTips, "Item", nil, 9918][-]上写下[FFFE0D]三行情诗[-]，最多可选择三个好友寄出。每封情书第一次提交[FFFE0D]免费[-]，后续修改每次需要消耗[FFFE0D]200元宝[-]，且每日只允许修改[FFFE0D]2次[-]。
[FFFE0D]分享求赞 提升排名[-]
大侠可以把自己的情书分享到好友频道，亲密度超过[FFFE0D]15级[-]的好友点击情书链接可以打开自己的情书并可以点赞，系统会根据玩家获得的总赞数进行排行。每个玩家每天可给别人点赞[FFFE0D]10次[-]，可给同一封情书点赞[FFFE0D]1次[-]。
注：给寄给自己的情书点赞，寄出情书的大侠会收到[FFFE0D]2个[-]赞哦！
[FFFE0D]召回好友 额外奖励[-]
如果大侠寄情书的对象已经退隐江湖超过[FFFE0D]15天[-]了，且收到情书后在活动期间上线，则双方都能收到[FFFE0D]5000贡献[-]和[aa62fc][url=openwnd:花草礼包, ItemTips, "Item", nil, 3698][-]！快去邀请隐士们重回江湖吧！
[FFFE0D]结算排行 发放奖励[-]
最终活动结束时会进入时长为[FFFE0D]3天[-]的展示期，展示期间将不能修改情书以及点赞，展示期结束时会按照每个玩家的总获赞数进行排行，并发放奖励，奖励如下：
第1名---------------[e6d012][url=openwnd:四阶·银杏寄情礼盒, ItemTips, "Item", nil, 9967][-]
第2至第10名---------[ff8f06][url=openwnd:三阶·银杏寄情礼盒, ItemTips, "Item", nil, 9968][-]
第11至第30名--------[ff578c][url=openwnd:二阶·银杏寄情礼盒, ItemTips, "Item", nil, 9969][-]
第31至第100名-------[aa62fc][url=openwnd:一阶·银杏寄情礼盒, ItemTips, "Item", nil, 9970][-]
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc7(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end