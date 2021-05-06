module(...)
--dialogueani editor build
DATA={
	[1]={
		cmdList={
			[1]={
				args={
					[1]={[1]=[[实验体]],},
					[2]={[1]=1004,},
					[3]={[1]=3.4,[2]=2.6,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
			[2]={
				args={
					[1]={[1]=[[实验体2]],},
					[2]={[1]=1004,},
					[3]={[1]=4.1,[2]=3.5,},
					[4]={[1]=-162,},
					[5]={[1]=2,},
					[6]={[1]=0,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
		},
		delay=1,
		idx=1,
		startTime=0,
		type=[[player]],
	},
	[2]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[实验体]],},
					[2]={[1]=[[上次抓来的那些人还不够用！]],},
				},
				cmdType=[[player]],
				func=[[PlayerSay]],
				name=[[剧场冒泡说话]],
			},
		},
		delay=3,
		idx=2,
		startTime=1,
		type=[[player]],
	},
	[3]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[实验体2]],},
					[2]={[1]=[[失败了？我还等着下一次进化哩！]],},
				},
				cmdType=[[player]],
				func=[[PlayerSay]],
				name=[[剧场冒泡说话]],
			},
		},
		delay=3,
		idx=3,
		startTime=4,
		type=[[player]],
	},
	[4]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[实验体]],},
					[2]={[1]=[[哎别说了！走，去取点材料。]],},
				},
				cmdType=[[player]],
				func=[[PlayerSay]],
				name=[[剧场冒泡说话]],
			},
		},
		delay=5,
		idx=4,
		startTime=7,
		type=[[player]],
	},
	[5]={
		cmdList={
			[1]={
				args={[1]={[1]=1,[2]=[[实验体]],},[2]={[1]=1.7,[2]=13.6,},[3]={[1]=-59,},},
				cmdType=[[player]],
				func=[[PlayerRunto]],
				name=[[人物移动]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[实验体2]],},[2]={[1]=2.5,[2]=13,},[3]={[1]=-59,},},
				cmdType=[[player]],
				func=[[PlayerRunto]],
				name=[[人物移动]],
			},
		},
		delay=7,
		idx=5,
		startTime=12,
		type=[[player]],
	},
	[6]={
		cmdList={
			[1]={
				args={[1]={[1]=1,[2]=[[实验体]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetPlayerActive]],
				name=[[设置人物是否可见]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[实验体2]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetPlayerActive]],
				name=[[设置人物是否可见]],
			},
		},
		delay=1,
		idx=6,
		startTime=19,
		type=[[player]],
	},
}

CONFIG={
	isLoop=1,
	isStroy=0,
	isTrigger=1,
	loopTime=120,
	mapInfo=[[201000,3.7,6]],
	minTriggerLevel=40,
	name=[[剧场动画名_10108]],
}
