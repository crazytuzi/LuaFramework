local anniversary={
    --兑换
    exchange={
        {id=1,maxLimit=1,price={p={{p4014=1,index=1},{p4015=1,index=2},{p4016=1,index=3},{p4017=1,index=4},{p4018=1,index=5},{p4019=1,index=6},{p4020=1,index=7}},},severprice={p4014=1,p4015=1,p4016=1,p4017=1,p4018=1,p4019=1,p4020=1,},reward={p={{p819=8,index=1},{p956=8,index=2},{p448=4,index=3}},},serverReward={props_p819=8,props_p956=8,props_p448=4,}},
        {id=2,maxLimit=25,price={p={{p4014=1,index=1},{p4015=1,index=2}},},severprice={p4014=1,p4015=1,},reward={p={{p19=3,index=1},{p446=3,index=2}},},serverReward={props_p19=3,props_p446=3,}},
        {id=3,maxLimit=15,price={p={{p4016=1,index=1},{p4017=1,index=2}},},severprice={p4016=1,p4017=1,},reward={p={{p19=4,index=1},{p446=5,index=2}},},serverReward={props_p19=4,props_p446=5,}},
        {id=4,maxLimit=5,price={p={{p4014=1,index=1},{p4015=1,index=2},{p4016=1,index=3},{p4017=1,index=4}},},severprice={p4014=1,p4015=1,p4016=1,p4017=1,},reward={p={{p601=5,index=1},{p447=2,index=2}},},serverReward={props_p601=5,props_p447=2,}},
        {id=5,maxLimit=5,price={p={{p4018=1,index=1},{p4019=1,index=2},{p4020=1,index=3}},},severprice={p4018=1,p4019=1,p4020=1,},reward={p={{p601=6,index=1},{p631=2,index=2}},},serverReward={props_p601=6,props_p631=2,}},
    },
    --戎马生涯
    career={
        {reward={p={{p982=15,index=1},{p983=10,index=2}}},serverReward={props_p982=15,props_p983=10}},
        {reward={p={{p37=1,index=1},{p38=1,index=2},{p39=1,index=3},{p38=1,index=4},{p41=1,index=5}}},serverReward={props_p37=1,props_p38=1,props_p39=1,props_p38=1,props_p41=1}},
        {reward={p={{p2=5,index=1}}},serverReward={props_p2=5}},
        {reward={p={{p1=1,index=1}}},serverReward={props_p1=1}},
        {reward={p={{p49=1,index=1}}},serverReward={props_p49=1}},
    },
    --充值礼包
    costMoney={
        {needNum=268,reward={p={{p4020=1,index=1},{p983=5,index=2},{p601=5,index=3},{p19=5,index=4}}},serverReward={props_p4020=1,props_p983=5,props_p601=5,props_p19=5}},
    },
	drop={
		levelDrop=0.2,
			levelPool= {
			{100},
			{30,25,30,15,},
			{{"props_p4014",1},{"props_p4015",1},{"props_p4016",1},{"props_p4017",1}},
			},
		resDrop=0.2,
			resPool= {
			{100},
			{65,30,5},
			{{"props_p4018",1},{"props_p4019",1},{"props_p4020",1},},
			},
		playerDrop=0.2,
			playerPool= {
			{100},
			{65,30,5},
			{{"props_p4018",1},{"props_p4019",1},{"props_p4020",1},},
	},

}
}

return anniversary
