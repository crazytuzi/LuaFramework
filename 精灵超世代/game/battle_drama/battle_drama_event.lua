Battle_dramaEvent = Battle_dramaEvent or {}

Battle_dramaEvent.BattleDrama_Update_Data = "Battle_dramaEvent.BattleDrama_Update_Data"
Battle_dramaEvent.BattleDrama_Boss_Update_Data = "Battle_dramaEvent.BattleDrama_Boss_Update_Data"
Battle_dramaEvent.BattleDrama_Quick_Battle_Data = "Battle_dramaEvent.BattleDrama_Quick_Battle_Data"
Battle_dramaEvent.BattleDrama_Top_Update_Data = "Battle_dramaEvent.BattleDrama_Top_Update_Data"

Battle_dramaEvent.BattleDrama_Drama_Reward_Data = "Battle_dramaEvent.BattleDrama_Drama_Reward_Data"
-- 更新剧情副本最大章节数，这个事件只有变化的时候才会推送
Battle_dramaEvent.BattleDrama_Update_Max_Id = "Battle_dramaEvent.BattleDrama_Update_Max_Id"

Battle_dramaEvent.BattleDrama_Drama_Unlock_View = "Battle_dramaEvent.BattleDrama_Drama_Unlock_View"

Battle_dramaEvent.BattleDrama_Drama_Buff_View = "Battle_dramaEvent.BattleDrama_Drama_Buff_View"

Battle_dramaEvent.UpdatePartnerRedStatus = "Battle_dramaEvent.UpdatePartnerRedStatus"

Battle_dramaEvent.BattleDrama_Update_Dun_Id = "Battle_dramaEvent.BattleDrama_Update_Dun_Id"

Battle_dramaEvent.UpdateHookAccumulateTime = "Battle_dramaEvent.UpdateHookAccumulateTime"

Battle_dramaEvent.UpdatePassVedioDataEvent = "Battle_dramaEvent.UpdatePassVedioDataEvent"

Battle_dramaEvent.UpdateDramaProgressDataEvent = "Battle_dramaEvent.UpdateDramaProgressDataEvent"

-- 关闭挂机收益提示弹窗
Battle_dramaEvent.Close_Hook_Alert_Event = "Battle_dramaEvent.Close_Hook_Alert_Event"

BattleDramaConst = {
    Normal = 1,
    Diffcult = 2,
}


BattleDramaResType = {
    [1] = "0_0",
    [2] = "1_0",
    [3] = "0_1",
    [4] = "1_1",
}

BattleShowRewardConst = {
    Boss = 1,
    Hook = 2
}