
HeroChallenge.tbDefInfo = HeroChallenge.tbDefInfo or {};
local tbDef = HeroChallenge.tbDefInfo;
tbDef.szHeroChallengeCount = "HeroChallenge";
tbDef.nChallengTypeNone   = 0;
tbDef.nChallengTypeNpc    = 1;
tbDef.nChallengTypePlayer = 2;

tbDef.nSaveGroupID      = 43;
tbDef.nSavePerTime      = 1; --每天更新的时间
tbDef.nSaveFloorCount   = 2; --当天的挑战层数
tbDef.nSaveChallenge     = 3; --挑战的次数
tbDef.nSaveChallengeRank = 4; --当前挑战的名次
tbDef.nSaveChallRankType = 5; --当前挑战的类型
tbDef.nSaveDegreeCount   = 6; --当前挑战的类型
tbDef.nSaveDegreeDay     = 7; --当前挑战的类型
tbDef.nSaveOneExtAward   = 8; --获得一次的奖励标识
tbDef.nSaveGetAwardFlag  = 9; --领取奖励的标识

tbDef.nSaveShowGroupID   = 44; --头像显示
tbDef.nSaveShowFloor     = 1;
tbDef.nSaveShowFloorEnd  = 12;




------------------下面策划填写---------------
tbDef.szDayUpdateTime = "4:00"; --每天更新的时间
tbDef.nMinPlayerLevel = 30; --最少玩家等级
tbDef.nFightMapID = 1015; --地图ID
tbDef.tbEnterMapPos = {1900, 2450};
tbDef.szOpenTimeFrame = "OpenDay2"; --开启的时间轴
tbDef.tbFloorAchievement =
{
    [1] = "HeroChallenge_1";
    [6] = "HeroChallenge_2";
    [10] = "HeroChallenge_3";
}