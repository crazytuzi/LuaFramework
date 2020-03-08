local tbArborDayCure = Activity:GetUiSetting("ArborDayCure")

tbArborDayCure.nShowLevel = 60
tbArborDayCure.szTitle    = "吾爱家园种情缘";
tbArborDayCure.nBottomAnchor = -50;

tbArborDayCure.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime + 1)
        local szContent = "\n      诸位侠士！如今诸位都已拥有自己的府邸，是否也想在其中培养一份小小情缘？值此情缘佳节，正是好时机哦！"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbArborDayCure.tbSubInfo =
{
	{szType = "Item2", szInfo =  [[活动内容：
    活动期间，与一名[FFFE0D]亲密度5级以上的异性角色[-]组成[FFFE0D]二人队伍[-]去找[c8ff00][url=npc:颖宝宝, 2204, 999][-]报名，[FFFE0D]成功报名[-]后通过邮件发放[FFFE0D]花草种子[-]以及[FFFE0D]养护道具[-]，男女拿到的道具不同，需注意[FFFE0D]一旦确定协作关系，活动期间不可更换与解除[-]！领取后需保持队伍前往双方的家园种下植物，每日固定时间植物会陷入虚弱状态，需两人组队各自进行治疗，[FFFE0D]点击植物可了解状态[-]，不同性别的角色需要治理的问题也不同。治疗时需注意花朵的对话内容，治疗错误将消耗次数且不计入养护成绩，养护成绩将决定活动结束时的最终奖励哦。]], 
    szBtnText = "前往",  szBtnTrap = "[url=npc:text, 2204, 999]"},
};

local tbFathersDayAct = Activity:GetUiSetting("FathersDay")

tbFathersDayAct.nShowLevel = 20
tbFathersDayAct.szTitle    = "一朝桃李遍天下";
tbFathersDayAct.nBottomAnchor = -50;

tbFathersDayAct.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime + 1)
        local szContent = "\n      诸位侠士！如今诸位都是老江湖了，是否也曾投得名师，又是否如今已经有几个得意徒弟？是否也想与他们一叙？有道是一日为师终生为父，值此佳节，正是好时机！"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbFathersDayAct.tbSubInfo =
{
    {szType = "Item2", szInfo =  "活动一     十年树木 百年树人\n      活动期间，[FFFE0D]师徒二人[-]组成[FFFE0D]队伍[-]前往忘忧岛找[c8ff00][url=npc:颖宝宝, 2204, 999][-]报名即可参与活动，[FFFE0D]成功报名[-]后通过邮件发放[FFFE0D]养护道具[-]，师徒拿到的道具会有所不同喔，需注意两人[FFFE0D]一旦确定协作关系，活动期间不可更换与解除，也无法再与其他人报名[-]！领取道具后组队前往新颖小院，院中植物每日固定时间会虚弱，需进行治疗，[FFFE0D]点击植物可了解它的状态[-]，治疗完所有。要注意的是，治疗错误将消耗次数且不计入养护成绩，而养护成绩将决定活动结束时的最终奖励哦。", 
    szBtnText = "前往",  szBtnTrap = "[url=npc:text, 2204, 999]"},
    {szType = "Item2", szInfo =  "活动二     桃李天下 春风遍布\n      活动期间，报名参与[FFFE0D]活动一[-]还将同时获得道具[aa62fc][url=openwnd:祝福册, ItemTips, 'Item', nil, 3911][-]，[FFFE0D]每次将植物所有状态解决[-]后，[FFFE0D]徒弟[-]均将获得一枚[11adf6][url=openwnd:祝福签, ItemTips, 'Item', nil, 3910][-]！只能由[FFFE0D]徒弟给师父赠送祝福[-]，消耗[FFFE0D]祝福签[-]可以赠送免费的固定祝福，消耗[FFFE0D]元宝[-]可以自己定义对师父的祝福，赠送祝福后双方均将获得一个[aa62fc][url=openwnd:祝福礼盒, ItemTips, 'Item', nil, 4889][-]，每人每天最多获得[FFFE0D]5[-]个，若师父收到的祝福超过[FFFE0D]15[-]个，还将额外获得一个[aa62fc][url=openwnd:名师礼盒, ItemTips, 'Item', nil, 4890][-]，快向你的师长送上最美好的祝福吧。", 
    szBtnText = "前往",  szBtnTrap = "[url=npc:text, 2204, 999]"},    
};

UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, Activity.FathersDay.OnMapLoaded, Activity.FathersDay)
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, Activity.FathersDay.OnLeaveMap, Activity.FathersDay)