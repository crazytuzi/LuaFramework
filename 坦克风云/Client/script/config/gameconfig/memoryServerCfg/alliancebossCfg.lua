alliancebossCfg={
    startLevel=20, --BOSS起始等级
    levelLimite=30, --功能开放等级
    paotou={1,3,2,4,6,5}, --炮头死亡顺序

     -- 每次击杀获得礼包奖励
    serverreward={
        props_p3309=1,
    },
    reward={
        p={p3309=1}
    },
   
    raisingConsume=50,   --兑换礼包需要的个人贡献值
    addexp=50, -- 最终击杀之后 赠送军团科技
    exprie=60,  -- boss死亡多久复活(s)

    award={ -- 单次进攻奖励
        props_p3308=1,
        userinfo_exp=0.00005, -- 每造成 X 伤害， 获得 x * 0.00005的经验
        userinfo_honors=5, -- 每次进攻无论输赢，均获得 5 点个人荣誉点数
		userinfo_expMax=12000000, -- 每次进攻获取经验上限

    },
	chapterCfg={name="alliance_fuben_chapterName_6",icon="LegionCopyEagle.png",star=5,maxNum=5,awardMaxNum=5},
}
