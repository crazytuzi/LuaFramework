--#include "data\language\LangCode.txt" once
CrossBattlefieldCfg = {
	ActivityTime = 20 ;
	CondictionType = {
		Level = 1;
		Coin = 2;
		[1] = Lang.Activity.kfzc0002;
		[2] = Lang.Activity.kfzc0003;
	};
	ApplyCondictions = {
		{type = 1, Count = 55};
		{type = 2, Count = 10000};
	};
	TriggerNewActivity = 30;
	NewActivityPlayers = 20;
	CountDown = 30;
	FubenId = 22;
	SceneId = 33;
	XiangMoPos = {1,2};
	LieYaoPos = {1,2};
	QizhiId = 700;
	ShouweiId = 222;
	AddBattleScoreInterval = 5;
	AddBattleScore = 1;
	AddBattleScoreWhenKillOther = 2;
	AddShadirongyuWhen = 10;
	EndBattleScore = 1000;
	FrontPlayers = 10;
}