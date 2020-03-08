if not MODULE_GAMESERVER then
    Activity.CollectAndRobClue = Activity.CollectAndRobClue or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("CollectAndRobClue") or Activity.CollectAndRobClue

tbAct.szActStartMailTitle = "国庆·神州大地";
tbAct.szActStartMailText = [[ 	    国庆节“神州大地”收集寻宝活动现已开启，活动时间为[FFFE0D]2018.10.1-2018.10.7[-]。
			    届时将出现传说中的神州宝藏恭候各位少侠，快踏上探寻之旅吧！现为少侠送上[ff8f06] [url=openwnd:神州宝卷收纳盒, ItemTips, "Item", nil, 6468] [-]，希望能在探寻宝藏的过程中助少侠一臂之力，请查收！
			    详细内容请点击查阅[FFFE0D][url=openwnd:最新消息, NewInformationPanel, 'CollectAndRobClue'][-]相关页面。

]];

tbAct.nMinLevel = 30; --活动参与最小等级
tbAct.szNewsText = [[
	国庆节“神州大地”收集寻宝活动开始了！
      活动时间：[FFFE0D]2018.10.1-2018.10.7[-]
      参与等级：[FFFE0D]30级[-]
      活动期间内通过探寻线索收集25张地图分卷，集齐可合成[ff8f06] [url=openwnd:神州大地宝卷, ItemTips, "Item", nil, 6386] [-]，使用后有机会获得[ff8f06] [url=openwnd:地级同伴挑选礼盒, ItemTips, "Item", nil, 3179] [-]、[ff8f06] [url=openwnd:地级本命武器挑选礼盒, ItemTips, "Item", nil, 3693] [-]、[aa62fc] [url=openwnd:随机4级魂石, ItemTips, "Item", nil, 2169] [-]等稀世瑰宝！
      宝卷线索可通过[FFFE0D]每日活跃宝箱[-]（每档活跃度宝箱中包含3张宝卷线索）获得，同时也可在[FFFE0D]商城“限时限购”[-]中进行购买。探寻线索即可获得分卷碎片，消耗10张同种类碎片即可合成对应分卷。在探寻线索的过程中，更有机会遇到萍踪梗迹的江湖行商和江南富贾，可以向他们购买珍贵的[11adf6] [url=openwnd:乾坤分卷碎片, ItemTips, "Item", nil, 6414] [-]哦！
      分卷及碎片全部收入[ff8f06] [url=openwnd:神州宝卷收纳盒, ItemTips, "Item", nil, 6468] [-]，少侠可在收纳盒中将指定碎片赠送给心仪的好友/家族成员，也可以随机抢夺仇人/陌生人的碎片。但要注意的是一旦离线，少侠也将面临着被抢夺的危险。（活动结束后相关道具可进行过期出售，收纳盒中的碎片及分卷的价值将在出售收纳盒时一并计入）

]]; 

--不同活跃时获取的奖励
tbAct.nEverydayTargetAward = 6387
tbAct.tbEverydayTargetAwardCount = {
	[1] = 3;
	[2] = 3;
	[3] = 3;
	[4] = 3;
	[5] = 3;
};

tbAct.szNewsTitle = "国庆·神州大地" --

tbAct.RefreshTime = 3600 * 4; --刷新时间

tbAct.MAX_CLUE_MSG_COUNT = 50; --收纳盒最多记录的消息条目数
tbAct.RequestRobListInterval = 600; --请求强求列表cd 不能太短
tbAct.MAX_ROBED_COUNT = 10; --最多被抢夺次数
tbAct.MAX_ROB_COUNT = 10; --最多抢夺次数
tbAct.ROB_CD = 3600; --抢夺cd

tbAct.MAX_GETSEND_COUNT = 20; --每日被赠送上限次数
tbAct.MAX_SEND_COUNT = 20; --每日赠送上限次数
tbAct.SEND_CD = 1800; --赠送cd

tbAct.nRobAddHate = 10000; --抢碎片增加的仇恨值


tbAct.tbCombieDebrisAward = { {"item", 6532, 1} }; --碎片合成残卷时的奖励



tbAct.LogWayType_Rob = 1; -- 被抢夺
tbAct.LogWayType_OpenBox = 2; -- 挖宝打开宝箱
tbAct.LogWayType_OpenPosin = 3; -- 挖宝打开毒箱子
tbAct.LogWayType_AttackNpc = 4; -- 挖宝打开夺宝贼
tbAct.LogWayType_DialogNpc = 5; -- 对话npc购买
tbAct.LogWayType_RobOther  = 6; -- 抢夺他人获得
tbAct.LogWayType_Combine  = 7; -- 合成碎片
tbAct.LogWayType_GetSend  = 8; -- 被人赠与获得
tbAct.LogWayType_Send  = 9; -- 送给他人扣除


tbAct.tbLogWayDesc = {
	[tbAct.LogWayType_Rob] = "[ffff00]%s[-]打开你的收纳盒，明目张胆的抢走了[11adf6]%s[-]";
	[tbAct.LogWayType_OpenBox] = "[c8ff00]打开线索所指的宝箱%s[-]\n获得了%s"; --多个奖励
	[tbAct.LogWayType_OpenPosin] = "被宝箱内的毒气迷晕%s，不幸丢失了[11adf6]%s[-]";
	[tbAct.LogWayType_AttackNpc] = "[c8ff00]成功击败强大的%s[-]\n获得了%s"; --多个奖励
	[tbAct.LogWayType_DialogNpc] = "幸运的遇到了%s，成功购买了[11adf6]%s[-]";
	[tbAct.LogWayType_RobOther] = "成功抢夺[ffff00]%s[-]的[11adf6]%s[-]";
	[tbAct.LogWayType_Combine] = "成功合成%s[11adf6]%s[-]";
	[tbAct.LogWayType_GetSend] = "获得[ffff00]%s[-]赠送的[11adf6]%s[-]";
	[tbAct.LogWayType_Send] = "赠送[ffff00]%s[-][11adf6]%s[-]";
	[Env.LogWay_ChooseItem] = "通过[11adf6]%s[-] 获得了 [11adf6]%s[-]";
}




