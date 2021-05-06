module(...)
--dialogueani editor build
DATA={
	[1]={
		cmdList={
			[1]={
				args={
					[1]={[1]=[[伊露]],},
					[2]={[1]=312,},
					[3]={[1]=11.5,[2]=25,},
					[4]={[1]=150,},
					[5]={[1]=1,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
			[2]={
				args={
					[1]={[1]=[[白]],},
					[2]={[1]=801,},
					[3]={[1]=13,[2]=24.5,},
					[4]={[1]=-64,},
					[5]={[1]=2,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
			[3]={
				args={[1]={[1]=2,},},
				cmdType=[[setting]],
				func=[[SetCameraFollow]],
				name=[[镜头跟随]],
			},
			[4]={
				args={[1]={[1]=[[bgm_1010]],},[2]={[1]=0,},},
				cmdType=[[setting]],
				func=[[SetBgMusic]],
				name=[[背景音乐]],
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
				args={[1]={[1]=1,},[2]={[1]=1,},[3]={[1]=1,},[4]={[1]=[[none]],},[5]={[1]=0,},},
				cmdType=[[setting]],
				func=[[SetDialogueAniViewActive]],
				name=[[显示剧情界面]],
			},
			[2]={
				args={
					[1]={[1]=1,[2]=[[伊露]],},
					[2]={
						[1]=[[上次这一管血液样本，与之前执行官黑烈捕捉的活体一样，是基因被改造过的人类。但是他被融合的浓度低很多，我猜可能实验没多久他就逃跑了。]],
					},
					[3]={[1]=20,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005107]],},
					[9]={[1]=0,},
					[10]={[1]=[[default]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
		},
		delay=20,
		idx=2,
		startTime=1,
		type=[[player]],
	},
	[3]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[白]],},
					[2]={
						[1]=[[前几个月因为武道大会，经过断魂崖去帝都的人很多。没想到竟然有人打参赛选手的主意。]],
					},
					[3]={[1]=12,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005108]],},
					[9]={[1]=1,},
					[10]={[1]=[[serious]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[白]],},[2]={[1]=[[idleWar]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=12,
		idx=3,
		startTime=21,
		type=[[player]],
	},
	[4]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[白]],},
					[2]={[1]=[[如果能把人带回来治疗，说不定能成为绝佳的证人。]],},
					[3]={[1]=9,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005109]],},
					[9]={[1]=1,},
					[10]={[1]=[[serious]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[白]],},[2]={[1]=[[idleCity]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=9,
		idx=4,
		startTime=33,
		type=[[player]],
	},
	[5]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[伊露]],},
					[2]={
						[1]=[[科学班还没有研发出反融合试剂，但确实需要实验体。活体越多，药物的确定性就越高，成功率会大大增加。]],
					},
					[3]={[1]=16,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005110]],},
					[9]={[1]=0,},
					[10]={[1]=[[default]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=1,[2]=[[伊露]],},[2]={[1]=[[idleWar]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=16,
		idx=5,
		startTime=42,
		type=[[player]],
	},
	[6]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[白]],},
					[2]={[1]=[[交给我。]],},
					[3]={[1]=2,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005111]],},
					[9]={[1]=1,},
					[10]={[1]=[[serious]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
		},
		delay=2,
		idx=6,
		startTime=58,
		type=[[player]],
	},
	[7]={
		cmdList={
			[1]={
				args={
					[1]={[1]=[[乔焱]],},
					[2]={[1]=1014,},
					[3]={[1]=4.8,[2]=25.7,},
					[4]={[1]=137,},
					[5]={[1]=3,},
					[6]={[1]=0,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
			[2]={
				args={
					[1]={[1]=[[黑]],},
					[2]={[1]=800,},
					[3]={[1]=6.3,[2]=24.5,},
					[4]={[1]=-41,},
					[5]={[1]=4,},
					[6]={[1]=0,},
				},
				cmdType=[[player]],
				func=[[AddPlayer]],
				name=[[生成人物]],
			},
			[3]={
				args={[1]={[1]=3,},},
				cmdType=[[setting]],
				func=[[SetCameraFollow]],
				name=[[镜头跟随]],
			},
			[4]={
				args={[1]={[1]=1,[2]=[[伊露]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetPlayerActive]],
				name=[[设置人物是否可见]],
			},
			[5]={
				args={[1]={[1]=2,[2]=[[白]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetPlayerActive]],
				name=[[设置人物是否可见]],
			},
		},
		delay=1,
		idx=7,
		startTime=60,
		type=[[player]],
	},
	[8]={
		cmdList={
			[1]={
				args={
					[1]={[1]=3,[2]=[[乔焱]],},
					[2]={
						[1]=[[确实断魂崖需要仔细搜索，但以目前状况来看还有一件事更为紧迫。我收到信息组的密函，怀疑统帅部的行动已经被泄露。]],
					},
					[3]={[1]=16,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005112]],},
					[9]={[1]=1,},
					[10]={[1]=[[talk]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
		},
		delay=16,
		idx=8,
		startTime=61,
		type=[[player]],
	},
	[9]={
		cmdList={
			[1]={
				args={
					[1]={[1]=4,[2]=[[黑]],},
					[2]={
						[1]=[[调查断魂崖的任务，除去信息组，只有我、白和三个新兵知道。你怀疑……]],
					},
					[3]={[1]=15,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005113]],},
					[9]={[1]=1,},
					[10]={[1]=[[serious]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
		},
		delay=15,
		idx=9,
		startTime=77,
		type=[[player]],
	},
	[10]={
		cmdList={
			[1]={
				args={
					[1]={[1]=3,[2]=[[乔焱]],},
					[2]={
						[1]=[[三名新兵有重大嫌疑，但不能排除有其他心怀不轨之人混进了统帅部。]],
					},
					[3]={[1]=9,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005114]],},
					[9]={[1]=1,},
					[10]={[1]=[[talk]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=3,[2]=[[乔焱]],},[2]={[1]=[[idleWar]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=9,
		idx=10,
		startTime=92,
		type=[[player]],
	},
	[11]={
		cmdList={
			[1]={
				args={
					[1]={[1]=3,[2]=[[乔焱]],},
					[2]={
						[1]=[[事态严重，我已经将密函呈递给总统。总统指令，立刻开启内部调查，务必将间谍找出来！]],
					},
					[3]={[1]=13,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005115]],},
					[9]={[1]=1,},
					[10]={[1]=[[talk]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=3,[2]=[[乔焱]],},[2]={[1]=[[idleCity]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=13,
		idx=11,
		startTime=101,
		type=[[player]],
	},
	[12]={
		cmdList={
			[1]={
				args={
					[1]={[1]=4,[2]=[[黑]],},
					[2]={[1]=[[收到！]],},
					[3]={[1]=2,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=0,},
					[7]={[1]=1,},
					[8]={[1]=[[1005116]],},
					[9]={[1]=1,},
					[10]={[1]=[[serious]],},
				},
				cmdType=[[player]],
				func=[[PlayerUISay]],
				name=[[剧场界面说话]],
			},
			[2]={
				args={[1]={[1]=4,[2]=[[黑]],},[2]={[1]=[[idleWar]],},},
				cmdType=[[player]],
				func=[[PlayerDoAction]],
				name=[[人物动作]],
			},
		},
		delay=2,
		idx=12,
		startTime=114,
		type=[[player]],
	},
}

CONFIG={
	isLoop=0,
	isStroy=1,
	isTrigger=0,
	loopTime=0,
	mapInfo=[[]],
	minTriggerLevel=1,
	name=[[剧场动画名_10508]],
}
