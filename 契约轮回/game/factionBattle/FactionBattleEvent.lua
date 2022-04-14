---
--- Created by R2D2.
--- DateTime: 2019/2/19 19:45
---
FactionBattleEvent = FactionBattleEvent or {
        FactionBattle_FieldsDataEvent = "FactionBattle.OnFieldsData",
        FactionBattle_BattleDataEvent = "FactionBattle.OnBattleData",

        ---获取胜利方信息事件
        FactionBattle_Model_BattleWinnerDataEvent = "FactionBattle.Model.OnWinnerData",
        ---连胜奖励事件
        FactionBattle_Model_AssignedWinAwardEvent = "FactionBattle.Model.OnAssignedWinAward",
        ---终结奖励事件
        FactionBattle_Model_AssignedTerminatorAwardEvent = "FactionBattle.Model.OnAssignedTerminatorAward",
        ---收到排行榜（准备退出）
        FactionBattle_Model_RankListEvent = "FactionBattle.Model.OnRankList",
        ---公会活动发生变化
        FactionBattle_Model_ActivityChange = "FactionBattle.Model.OnActivityChange",
}