local localWarCfg={
    limitLevel=30, --玩家30以上才能参战
    minRegistrationFee=1000, -- 报名 最少花费
    startWarTime={20,30},
    maxBattleTime=3600, --最长战斗时间, 单位: 秒
    cdTime=20, -- 战斗冷却时间，每X秒发生1次战斗

    --报名时间, 周几0~6 周日是0
    prepareTime=1,
    --战斗时间, 单位: 天
    battleTime=1,
    --战斗后的buff时间, 单位: 天
    buffTime=5,
    --阵亡者复活时间和金币消耗
    reviveTime=30,
    reviveCost=10, --(每1秒花费1金币+固定值)
    --战斗队列人数上限
    battleQueue=5,
    --当玩家一轮战斗多次时，那么该玩家战斗力削减
    reducePercentage=0.15,
    --普通基地每X秒对王城发动一次攻击，削减X王城城防值
    baseAttackCD=20,
    baseAttack={2,8,24,64}, --占领几个城市对应的伤害

    --进攻队列剩余部队所加点数，点/每人
    attackBase=10,

    --玩家打王城，无人防守时，一次削减X王城城防值
    attackEmptyBase=10,
    --报名前几名可参加战斗
    signupBattleNum=4,
    --团长和副团长标记建筑的cd时间
    flagBuildCD=30,
    --奴隶的捕获几率
    slaveRate=0.1,
    --每只奴隶提供的军团资金
    slaveRaising=50,
    --坦克消耗兑换的比例
    tankeTransRate=100, --100比1的消耗比例,足的部分向上取整
    --战报最大数量
    reportMaxNum=50,
    winRate=30, --单场胜利积分
    loseRate=10, --单场失败积分
    winAllianceRate=30, --占领积分
    occupyRate=300, --最终胜利积分加成

    --个人排名奖励
    --rankReward={
    --    {range={1,1},reward={p={{p817=80},{p819=60},{p705=60},}},serverReward={props_p817=80,props_p819=60,props_p705=60},icon="serverWarTopMedal1.png"},
    --    {range={2,2},reward={p={{p817=60},{p819=40},{p705=40},}},serverReward={props_p817=60,props_p819=40,props_p705=40},icon="serverWarTopMedal2.png"},
    --    {range={3,3},reward={p={{p817=50},{p819=30},{p705=30},}},serverReward={props_p817=50,props_p819=30,props_p705=30},icon="serverWarTopMedal3.png"},
    --    {range={4,10},reward={p={{p817=40},{p819=25},{p705=20},}},serverReward={props_p817=40,props_p819=25,props_p705=20},},
    --    {range={11,30},reward={p={{p817=30},{p819=20},}},serverReward={props_p817=30,props_p819=20,},},
    --    {range={31,100},reward={p={{p817=20},{p819=15},}},serverReward={props_p817=20,props_p819=15,},},
    --    {range={101,500},reward={p={{p817=10},{p819=10},}},serverReward={props_p817=10,props_p819=10,},},
    --},

    --野怪配置
    guard={tank={{"a10004",676},{"a10004",676},{"a10004",676},{"a10034",676},{"a10024",676},{"a10014",676},},skill={s101=50,s102=50,s103=50,s104=50,s105=50,s106=50,s107=50,s108=50,s109=50,s110=50,s111=50,s112=50,},attributeUp={attack=1,life=1,accurate=1,avoid=1,critical=1,decritical=1,},},

    jobs={
        {pic="Office1.png",title="local_war_office_1",id=1,buff={1,2,5,6,7},},
        {pic="Office2.png",title="local_war_office_2",id=2,buff={1},},
        {pic="Office3.png",title="local_war_office_3",id=3,buff={2},},
        {pic="Office4.png",title="local_war_office_4",id=4,buff={3},},
        {pic="Office5.png",title="local_war_office_5",id=5,buff={4},},
        {pic="Office6.png",title="local_war_office_6",id=6,buff={5},},
        {pic="Office7.png",title="local_war_office_7",id=7,buff={6},},
        {pic="Office8.png",title="local_war_office_8",id=8,buff={7},},
        {pic="Office9.png",title="local_war_office_9",id=9,buff={8},},
        {pic="Office10.png",title="local_war_office_10",id=10,buff={9,10},count=5},
    },
    buff={
        {id=1,type="build",value=1},--建造基础速度增加
        {id=2,type="tech",value=1},--研究基础速度增加
        {id=3,type="attack",value=2},--行军基础速度增加
        {id=4,type="challenge",value=1},--关卡战斗基础经验增加
        {id=5,type="resource",value=0.5},--野外采集基础速度增加
        {id=6,type="troops",value=0.5},--生产，改造坦克基础速度增加
        {id=7,type="houseStorage",value=1},--基地资源基础产量增加
        {id=8,type="prop",value=1.5},--制造道具基础速度增加
        {id=9,type="houseStoragedel",value=0.5},--仓库保护量减少
        {id=10,type="allianceFunds",value=50},--提供军团资金
    },

--区域战任务
    task={ -- 任务目标参数  和 前台描述
        t1={5,"taskDes1"},
        t2={5000,"taskDes2"},
        t3={1,"taskDes3"},
        t4={10,"taskDes3"},
        t5={1,"taskDes5"},
        t6={10,"taskDes5"},
        t7={3,"taskDes8"},
        t8={10,"taskDes8"},
        t9={50,"taskDes8"},
    },
    taskreward={ -- 任务奖励
        t1={{p={{p982=50}}},{props_p982=50}},
        t2={{p={{p20=10}}},{props_p20=10}},
        t3={{p={{p817=10}}},{props_p817=10}},
        t4={{p={{p448=5}}},{props_p448=5}},
        t5={{p={{p819=10}}},{props_p819=10}},
        t6={{p={{p983=20}}},{props_p983=20}},
        t7={{p={{p705=30}}},{props_p705=30}},
        t8={{p={{p705=20}}},{props_p705=20}},
        t9={{p={{p819=10}}},{props_p819=10}},
    },

    --胜利军团奖励
    winreward={reward={p={{p983=20,index=1},{p817=25,index=2},{p819=20,index=3},{p705=10,index=4}}},serverReward={props_p983=20,props_p817=25,props_p819=20,props_p705=10}},

    --前端活跃奖励
    activeReward={reward={p={{p983=20,index=1},{p982=50,index=2},{p20=10,index=3},{p705=60,index=4}}}},

    --获胜军团，军团科技经验奖励
    winEXP=1000,

    --根据防守军团连续占领首都次数，对进攻方的加成buff
    --DfBuff=num/(num+5)
    --num：防守军团连续占领首都次数

    --根据进攻军团的实际参战军团数,对进攻方的加成buff
    --AtBuff=0.05*num
    --num：实际参战的进攻方军团数

}
return localWarCfg
