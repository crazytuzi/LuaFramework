

BossLeader.nMJHonorID = 1394; --名将令
BossLeader.nItemAwardValueParam = 5; --道具奖励系数

BossLeader.nShowMaxRank = 5;
BossLeader.nBaoDiAwardValue = 10000;
BossLeader.nFirstLastDmgMJHPPercent = 6; --首摸和最后一击额外血量百分比
BossLeader.nHPPercentParam = 1 / 1.2; -- 血量的百分比参数
BossLeader.nMinHPPercent = 1; --最少血量百分比
BossLeader.tbComboSkillCount = {[20] = 1, [30] = 1, [40] = 1, [50] = 1, [60] = 1, [70] = 1, [80] = 1, [90] = 1, [100] = 1}; --连斩数

BossLeader.tbTimePlayerValue = --一轮一个参加玩家的价值量
{
    ["OpenLevel39"] = 5000000;
    ["OpenLevel49"] = 6000000;
    ["OpenLevel59"] = 7000000;
    ["OpenLevel69"] = 8000000;
    ["OpenLevel79"] = 10000000;
    ["OpenLevel89"] = 11000000;
    ["OpenLevel99"] = 12000000;
    ["OpenLevel109"] = 13000000;
    ["OpenLevel119"] = 14000000;
    ["OpenLevel129"] = 15000000;
};

BossLeader.tbKinDmgRankValue =
{
    ["OpenLevel39"] =
    {
        [-1] =
        {
            ["Boss"] =
            {
                [1] = 4000000;
                [2] = 4000000;
                [3] = 4000000;
                [4] = 4000000;
                [5] = 4000000;
            };
            ["FalseBoss"] =
            {
                [1] = 2000000;
                [2] = 2000000;
                [3] = 2000000;
                [4] = 2000000;
                [5] = 2000000;
            }
        };
        [1] =
        {
            ["Boss"] =
            {
                [1] = 6000000;
                [2] = 6000000;
                [3] = 6000000;
                [4] = 6000000;
                [5] = 6000000;
            };
            ["FalseBoss"] =
            {
                [1] = 3000000;
                [2] = 3000000;
                [3] = 3000000;
                [4] = 3000000;
                [5] = 3000000;
            }
        };
    };

    ["OpenDay89"] =
    {
        [-1] =
        {
            ["Boss"] =
            {
                [1] = 4000000 * 1.5;
                [2] = 4000000 * 1.5;
                [3] = 4000000 * 1.5;
                [4] = 4000000 * 1.5;
                [5] = 4000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 2000000 * 1.5;
                [2] = 2000000 * 1.5;
                [3] = 2000000 * 1.5;
                [4] = 2000000 * 1.5;
                [5] = 2000000 * 1.5;
            }
        };
        [1] =
        {
            ["Boss"] =
            {
                [1] = 6000000 * 1.5;
                [2] = 6000000 * 1.5;
                [3] = 6000000 * 1.5;
                [4] = 6000000 * 1.5;
                [5] = 6000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 3000000 * 1.5;
                [2] = 3000000 * 1.5;
                [3] = 3000000 * 1.5;
                [4] = 3000000 * 1.5;
                [5] = 3000000 * 1.5;
            }
        };
    };

    ["OpenLevel119"] =
    {
        [-1] =
        {
            ["Boss"] =
            {
                [1] = 4000000 * 1.5;
                [2] = 4000000 * 1.5;
                [3] = 4000000 * 1.5;
                [4] = 4000000 * 1.5;
                [5] = 4000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 2000000 * 1.5;
                [2] = 2000000 * 1.5;
                [3] = 2000000 * 1.5;
                [4] = 2000000 * 1.5;
                [5] = 2000000 * 1.5;
            }
        };
        [1] =
        {
            ["Boss"] =
            {
                [1] = 6000000 * 1.5;
                [2] = 6000000 * 1.5;
                [3] = 6000000 * 1.5;
                [4] = 6000000 * 1.5;
                [5] = 6000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 3000000 * 1.5;
                [2] = 3000000 * 1.5;
                [3] = 3000000 * 1.5;
                [4] = 3000000 * 1.5;
                [5] = 3000000 * 1.5;
            }
        };
        [2] =
        {
            ["Boss"] =
            {
                [1] = 6000000 * 1.5;
                [2] = 6000000 * 1.5;
                [3] = 6000000 * 1.5;
                [4] = 6000000 * 1.5;
                [5] = 6000000 * 1.5;
            };
            ["FalseBoss"] =
            {
                [1] = 3000000 * 1.5;
                [2] = 3000000 * 1.5;
                [3] = 3000000 * 1.5;
                [4] = 3000000 * 1.5;
                [5] = 3000000 * 1.5;
            }
        };
    };
}

BossLeader.tbBaoDiKinAward =
{
    ["Boss"] = true;
};


BossLeader.tbSinglePlayerRank = --玩家单独排行奖励
{
    ["Leader"] = true;
}

BossLeader.tbKinAwardDesc =
{
    ["Boss"]   = "名将";
    ["Leader"] = "首领";
}


BossLeader.tbSendMailTxt =
{
    ["Boss"] = "历代名将获得奖励";
    ["Leader"] = "野外首领获得奖励";
}


BossLeader.tbJoinPrestige = --参加家族威望
{
    ["Boss"] = 3;
    ["Leader"] = 1;
}

BossLeader.tbDmgRankPrestige  = --伤害排行威望
{
    ["Boss"] =
    {
        [1] = 50;
        [2] = 35;
        [3] = 25;
        [4] = 15;
        [5] = 10;

    };

    ["Leader"] =
    {
        [1] = 3;
        [2] = 2;
        [3] = 1;
    };
}

BossLeader.tbTouchImitityTeam = --摸到增加亲密度
{
    ["Boss"]   = 30;
    ["Leader"] = 20;
};

BossLeader.tbKillImitityTeam = --杀死增加亲密度
{
    ["Boss"]   = 30;
    ["Leader"] = 30;
}

BossLeader.tbStartWorldNotice =
{
    ["Boss"]   = "历代名将现身江湖，各位大侠可前往挑战！奖励主要按照伤害发放！";
    ["Leader"] = "野外首领现身江湖，各位大侠可前往挑战！";
}

BossLeader.tbEndWorldNotice =
{
    ["Boss"]   = "历代名将已经结束";
    ["Leader"] = "野外首领已经结束";
}

BossLeader.tbMapAllKillNotice =
{
    ["Leader"] = "%s的首领被全部击败！";
}

BossLeader.tbNpcKillNotice =
{
    ["Boss"] = "%s(真身)被%s的队伍所击败";
}

BossLeader.tbWorldPreNotic =
{
    ["Boss"] = "历代名将即将出现，各位大侠可前往挑战！奖励主要按照伤害发放！";
}

BossLeader.tbMapBackNotic =
{
    ["Boss"] = "你已进入名将藏身地图，强制进入家族PK模式";
}

BossLeader.tbJoinAchievement =
{
    ["Boss"]   = {szKey = "FieldBoss_1", nValue = 1},
    ["Leader"] = {szKey = "FieldLeader_1", nValue = 1},
}

BossLeader.tbFirstAttackAchievement =
{
    ["Boss"] = {szKey = "FieldBoss_First", nValue = 1},
}

BossLeader.tbAttackTenAchievement =
{
    ["Boss"] = {szKey = "Mystic_10InHouse", nValue = 1},
}

BossLeader.nAchievementRank = 1;
BossLeader.tbKillNpcAchievementRank =
{
    ["Leader"] = {szKey = "FieldLeader_2", nValue = 1},
}

BossLeader.nAchievementKinRank = 1;
BossLeader.tbKillKinAchievement =
{
    ["Boss"]   = {szKey = "FieldBoss_2", nValue = 1},
}

-- 名将最后一击成就配置，npcid 对应 成就内容
BossLeader.tbLastDmgAchievement =
{
	[127]  = {["Boss"]   = {szKey = "FieldBoss_Jingke", nValue = 1}},
	[2498] = {["Boss"]   = {szKey = "FieldBoss_Xiangyu", nValue = 1}},
    [2235] = {["Boss"]   = {szKey = "FieldBoss_Xiangyu", nValue = 1}},
	[2497]  = {["Boss"]   = {szKey = "FieldBoss_ Yuji", nValue = 1}},
}

--每日目标
BossLeader.tbEveryDayTarget =
{
    ["Boss"] = "FieldBoss";
}

-- 名将，野外首领 黎饰拍卖物品配置
BossLeader.tbSilverAuctionItems = {
    [1397] = true;
	[10140] = true;
	[11121] = true;
};


--当前时间轴最高级野外首领伤害第一的队伍额外掉落
BossLeader.tbLeaderDmgNo1ExtraAward = {
	bOpen = true;			--万一出问题可以指令关闭开关
	szOpenTimeFrame = "OpenLevel109",
	tbAward = {{"Item", 11410, 1}},
	nMaxRandom = 10000,			--随机范围
	nHitByCount = 6000,			--随到多少以内掉落(需要再除以NPC的数量)
}