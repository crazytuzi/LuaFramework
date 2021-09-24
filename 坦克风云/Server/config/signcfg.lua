local signCfg={
   [1]= {
        level=0,
--[升级奖励所需的角色等级]
        dailySign={
--[连续签到领取奖励]
            {userinfo_honors=50,userinfo_gems=5,props_p6=1},
            {userinfo_honors=50,userinfo_gems=5,props_p7=1},
            {userinfo_honors=50,userinfo_gems=5,props_p8=1},
            {userinfo_honors=50,userinfo_gems=6,props_p15=1},
            {userinfo_honors=50,userinfo_gems=8,props_p19=3},

        },
        totalSign={
--[累计签到奖励]
            d7={userinfo_gems=10,props_p6=1,props_p19=5,props_p13=1},
            d15={userinfo_gems=15,props_p7=1,props_p47=3,props_p12=1},
            d30={userinfo_gems=30,props_p8=1,props_p2129=1,props_p5=1},

        },
    },

   [2]= {
        level=15,
        dailySign={
            {userinfo_honors=50,userinfo_gems=5,props_p6=1},
            {userinfo_honors=50,userinfo_gems=6,props_p7=1},
            {userinfo_honors=50,userinfo_gems=7,props_p8=1},
            {userinfo_honors=50,userinfo_gems=8,props_p9=1},
            {userinfo_honors=50,userinfo_gems=10,props_p19=3},

        },
        totalSign={
            d7={userinfo_gems=50,props_p9=1,props_p15=1,props_p45=1},
            d15={userinfo_gems=100,props_p89=1,props_p42=1,props_p43=1},
            d30={userinfo_gems=300,props_p447=5,props_p3=1,props_p5=1},
        },
    },

   [3]= {
        level=40,
        dailySign={
            {userinfo_honors=50,userinfo_gems=5,props_p6=1},
            {userinfo_honors=50,userinfo_gems=6,props_p7=1},
            {userinfo_honors=50,userinfo_gems=7,props_p8=1},
            {userinfo_honors=50,userinfo_gems=8,props_p9=1},
            {userinfo_honors=50,userinfo_gems=10,props_p19=3},

        },
        totalSign={
            d7={userinfo_gems=50,props_p9=1,props_p16=1,props_p44=1},
            d15={userinfo_gems=100,props_p447=5,props_p42=3,props_p43=3},
            d30={userinfo_gems=300,props_p1=5,props_p4=1,props_p5=1},

        },
    },

    totalSignDays={
        7,15,30
    },
    AddSign={8,38,118,188},
}
return signCfg
