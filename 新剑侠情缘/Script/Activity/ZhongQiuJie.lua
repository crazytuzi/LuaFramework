local tbActUi = Activity:GetUiSetting("ZhongQiuJie");

tbActUi.nShowLevel = 30;
tbActUi.szTitle = "中秋祭月活动";
tbActUi.nBottomAnchor = -70;
tbActUi.nShowPriority = 99

tbActUi.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        return string.format([[活动时间：[FFFE0D]%d年%d月%d日-%d月%d日[-]
参与等级：[FFFE0D]30级[-]
活动内容：
适逢中秋佳节，现推出一系列中秋节特别活动，同步增加[FFFE0D]中秋祭月榜[-]，结算时将会根据不同排行发放丰厚奖励，以敬各位豪侠！
[FFFE0D]活动一【金秋送祝福】[-]：登录即送[ff8f06] [url=openwnd:精美月饼礼盒, ItemTips, "Item", nil, 6442] [-]，使用后必然获得两种新增月饼[aa62fc] [url=openwnd:晴云秋月, ItemTips, "Item", nil, 6440] [-]、[ff578c] [url=openwnd:花好月圆, ItemTips, "Item", nil, 6441] [-]和祭月值，同时有机会获得[11adf6] [url=openwnd:沧海月明, ItemTips, "Item", nil, 2878] [-]、[ff578c] [url=openwnd:簪星曳月, ItemTips, "Item", nil, 9570] [-]和另外一种新增月饼[aa62fc] [url=openwnd:千里月明, ItemTips, "Item", nil, 6444] [-]。
[FFFE0D]活动二【月满人团圆】[-]：活动期间内，参加家族烤火即可获得祭月值奖励，同时提升烤火经验加成上限。家族成员更有机会请大家喝上一壶香醇的[FFFE0D]桂花酒[-]来祈愿团圆美满，在增加烤火经验的同时也能获得额外的祭月值哦！
[FFFE0D]活动三【灯谜猜不停】[-]：各位侠士可在襄阳城[11adf6] [url=npc:公孙惜花, 99, 10][-]处进行[FFFE0D]中秋灯谜考验[-]，每天可猜10次，全部完成可获得大量祭月值奖励，并且全部猜对有概率获得[ff8f06] [url=openwnd:精美月饼礼盒, ItemTips, "Item", nil, 6442] [-]，快速答题（5秒内回答正确）也会有额外的祭月值奖励。
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day)
end

tbActUi.tbSubInfo =
{
    {szType = "Item1", szInfo = "第1-3名", tbItemList = {6445, 6450, 6444, 9571, 6187}, tbItemName = {"头像框·荷塘月色", "称号·霞姿月韵", "千里月明", "主题·共婵娟", "真气"}},
    {szType = "Item1", szInfo = "第4-10名", tbItemList = {6445, 6451, 6444, 6467}, tbItemName = {"头像框·荷塘月色", "称号·花晨月夕", "千里月明", "真气"}},
    {szType = "Item1", szInfo = "第11-50名", tbItemList = {6444, 6466}, tbItemName = {"千里月明", "真气"}},
    {szType = "Item1", szInfo = "800祭月值以上", tbItemList = {6465}, tbItemName = {"真气"}},
};
