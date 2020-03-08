 local tbWomanAct = Activity:GetUiSetting("WomanAct")

 tbWomanAct.nShowLevel = 20
 tbWomanAct.szTitle    = "武林知己印象签";
 tbWomanAct.nBottomAnchor = -50;

 tbWomanAct.FuncContent = function (tbData)
         local tbTime1 = os.date("*t", tbData.nStartTime)
         local tbTime2 = os.date("*t", tbData.nEndTime + 1)
         local szContent = "\n      诸位侠士在行走江湖时，是否曾为一人惊艳？为一人心折，又是否曾为一人倾倒？时值佳节，何不留下你对她的印象，无论是美丽、可爱亦或是刁蛮霸道……咳咳，兴许你对他的印象，不乏共鸣之人……"
         return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
 end

 tbWomanAct.tbSubInfo =
 {
 	{szType = "Item2", szInfo =  [[
     印象添加期
     [c8ff00]3月8日-3月11日凌晨4点期间[-]为印象添加期
     印象添加期，玩家将收到[aa62fc] [url=openwnd:印象册, ItemTips, 'Item', nil, 3911] [-]，在此期间：
     女性侠士活跃度每达到[c8ff00]40、60、80、100[-]将获得一个[aa62fc] [url=openwnd:女侠礼盒, ItemTips, 'Item', nil, 3909] [-]
     男性侠士活跃度每达到[c8ff00]40、60、80、100[-]将获得一个[aa62fc] [url=openwnd:量产印象签·一念花开, ItemTips, 'Item', nil, 3910] [-]
     量产印象签可为[FFFE0D]女性好友[-]添加固定印象，可通过元宝给[FFFE0D]任意性别[-]侠士添加[FFFE0D]自定义印象[-]，最多不超过7个字
     添加印象时；[FFFE0D]双方亲密度等级必须≥5且在线[-]
     添加印象后，双方亲密度提升100点，且均获得一个[aa62fc] [url=openwnd:印象礼盒, ItemTips, 'Item', nil, 3932] [-]，每个角色每天最多获得[FFFE0D]5个[-]，凌晨[FFFE0D]4点[-]重置
     完全相同的印象将叠加，相同的固定印象和自定义印象将分别显示，固定印象不显示添加者，自定义印象显示前5位添加的侠士
     每个侠士最多收到[FFFE0D]15个[-]印象，超过不可添加固定印象；可以添加自定义印象，将优先替换固定印象，若15个均为自定义印象，则无法再添加
     [FFFE0D]女性角色[-]收到的自定义印象数量达到[FFFE0D]10个[-]时，将额外获得一个[aa62fc] [url=openwnd:女神礼盒, ItemTips, 'Item', nil, 10469] [-]
     印象展示期
     [c8ff00]3月11日凌晨4点[-]，不再获得量产印象签且不可再添加印象，已有印象保留至活动结束
 ]] , szBtnText = "前往",  szBtnTrap = "[url=openwnd:test, FriendImpressionPanel]"},
 };

 tbWomanAct.fnCustomCheckRP = function (tbData)
     return false
 end