 --每日答题
meiridatiCfg={
	sortId=567,
	type=1,
	 --开启时间端
	openTime={{12,30},{12,40}},
	 --可以领取奖励的最后时间24:00
	getRewardTime={24,00},
	 --排行榜保留时间24个小时
	rankTime=24,
	 --活动开启前X时间可进入活动
	lastTime=300,
	 --答题时间 
	choiceTime=20,
	 --显示X秒结果
	resultTime=5,
	 --正确答案
	rightAnswer=1,
	 --答错积分
	losepoint=5,
	 --进入排行榜需要积分
	rankNeedPoint=120,
	 --排名奖励
	rankReward={
		{{1,10},{p={{p817=30,index=1},{p1366=10,index=2},{p1365=10,index=3},},}},
		{{11,20},{p={{p817=25,index=1},{p1366=9,index=2},{p1365=9,index=3},},}},
		{{21,100},{p={{p817=20,index=1},{p1366=8,index=2},{p1365=8,index=3},},}},
	},
	 --每题答对奖励
	choiceReward={p={{p19=1,index=1},{p1365=1,index=2},},},
	 --排名前几名的有排名奖励
	rewardlimit=100,
	serverreward={
		--每个类别选择4道题
		choiceSubject=4,
		--总计五大类
		category=5,
		--每个类别题库有多少道题
		subjectCount={104,102,102,102,102},

		--每题答对奖励
		choiceReward={props_p19=1,props_p1365=1},
	},
}