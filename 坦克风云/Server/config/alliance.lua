local allianceCfg=
{
    createConsume = {
        {r1=500000,r2=500000,r3=500000,gold=500000},
        50,
    },
 --[[
科技捐献
攻打军团副本
购买军功商店道具
协防

    ]]
 --行为获得活跃次数上限
allianceActive={500,100,30,30},
 --每次活跃度增加值
allianceActivePoint={1,2,5,5},
 --军团活跃奖励的百分比
allianceActiveReward={0,0.002,0.004,0.006,0.01},

allianceResourcesRaising={[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8},
allianceGemRaising={[1]=2,[2]=4,[3]=6,[4]=8,[5]=10,[6]=12,[7]=14,[8]=16},
}

return allianceCfg
