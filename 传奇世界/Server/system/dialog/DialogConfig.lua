--DialogConfig.lua
--/*-----------------------------------------------------------------
 --* Module:  DialogConfig.lua
 --* Author:  Huang YingTian
 --* Modified: 2009年12月8日 11:42:24
 --* Purpose: Implementation of the class DialogConfig
 -------------------------------------------------------------------*/

Dialog_Distance_So_Long	= -1	--和NPC对话距离超过5格

DialogModelType={
	Task			=1,		--任务对话模板	
	Npc				=2,		--NPC对话模板
}

DialogActionType={
	Runtime_Task	=1,		--运行时任务类	
	Doer			=2,		--执行某项功能
	Client			=3,		--客户端操作
	Close			=4,		--关闭对话框
	ClientDoer		=5,		--执行客户端某项功能
}

TaskStateText={
	Accept	=  "接受任务",
	Finish  =  "完成任务",
	Active  =  "马上就去",
	Hunter  =  "马上就去###a133",
}

GameDoer =
{
	Dart			=1,				--运镖
	Guard			=2,    	--救公主
	DartReward 		=3, 		--运镖领取奖励
	FactionDartPick =4, 		--行会运镖领取物资
	FactionDartSend =5,		--行会运镖提交物资
	SwornBrosEnter  =6,		--进入结义场景
	SwornBrosStart  =7,		--开始结义
	InvadeState		=8,		--山贼入侵状态
	MountArrest     =9,     --灵曦岛

}

GameDoerMap =
{
	[GameDoer.Dart]			= "CommonServlet.clickNPC",
	[GameDoer.Guard]        = "GuardBook.GuardPricess",
	[GameDoer.DartReward]	= "CommonServlet.clickNPCpick",
	[GameDoer.FactionDartPick] = "FactionServlet.NpcFactionDartPick",
	[GameDoer.FactionDartSend] = "FactionServlet.NpcFactionDartSend",
	[GameDoer.SwornBrosEnter] = "SwornBrosServlet.doEnterScene",
	[GameDoer.SwornBrosStart] = "SwornBrosServlet.swornStart",
	[GameDoer.InvadeState] = "InvadeManager.invadeState",
	[GameDoer.MountArrest] = "MountManager.doEnterScene",
}

--默认选项
default_option_id = 1