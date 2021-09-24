local alliancebossCfg={
    startLevel=20, --BOSS起始等级
    levelLimite=30, --功能开放等级
    paotou={1,3,2,4,6,5}, --炮头死亡顺序

     -- 每次击杀获得礼包奖励
    serverreward={
        props_p4651=1,
    },
    reward={
        p={p4651=1}
    },
   
    raisingConsume=50,   --兑换礼包需要的个人贡献值
    addexp=50, -- 最终击杀之后 赠送军团科技
    exprie=60,  -- boss死亡多久复活(s)
    expLimit=200000,   -- 经验获得上限

    award={ -- 单次进攻奖励
        props_p4650=1,
        userinfo_exp=0.0001, -- 每造成 X 伤害， 获得 x * 0.0001的经验
        userinfo_honors=5, -- 每次进攻无论输赢，均获得 5 点个人荣誉点数
    },
}


    function alliancebossCfg.getBossHp(level)
        return math.floor(12500000000*2^(level-19)-15000000000)
    end
     --装甲
    function alliancebossCfg.getBossArmor(level)
        return level*0.1 - 1 
    end
     --闪避
    function alliancebossCfg.getBossDodge(level)
        return level*0.1 - 1
    end
     --防护
    function alliancebossCfg.getBossDefence(level)
        return level*25
    end

return alliancebossCfg
