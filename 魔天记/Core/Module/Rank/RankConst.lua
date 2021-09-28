RankConst = { };

RankConst.Type = {
    FIGHT = 10;
    LEVEL = 11;
    GOLD = 12;
    MONEY = 13;
    AUTOFIGHT = 14;--挂机效率

    PET = 20;
    REALM = 21;
    WING = 22;
    GUILD_FIGHT = 30;
    GUILD_RANK = 31;
    ARENA = 40;
    XULING = 41;
    BATTLE_FIELD = 42;
}

RankConst.Req = {
    [RankConst.Type.FIGHT] = CmdType.Rank_List_Fight,
    [RankConst.Type.LEVEL] = CmdType.Rank_List_Level,
    [RankConst.Type.GOLD] = CmdType.Rank_List_Gold,
    [RankConst.Type.MONEY] = CmdType.Rank_List_Money,

    [RankConst.Type.AUTOFIGHT] = CmdType.Rank_List_AutoFight,

    [RankConst.Type.PET] = CmdType.Rank_List_Pet,
    [RankConst.Type.REALM] = CmdType.Rank_List_Realm,
    [RankConst.Type.WING] = CmdType.Rank_List_Wing,

    [RankConst.Type.GUILD_FIGHT] = CmdType.Rank_List_GuildFight,
    [RankConst.Type.GUILD_RANK] = CmdType.Rank_List_GuildRank,

    [RankConst.Type.XULING] = CmdType.Rank_List_Xuling,
    [RankConst.Type.BATTLE_FIELD] = nil;
}


function RankConst.GetRankColor(rank, str)
    if rank < 4 then
        return LanguageMgr.GetColor(6 - rank, str);
    else
        return LanguageMgr.GetColor("d", str);
    end
end