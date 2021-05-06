module(...)
--dialogueani editor build
DATA={
	[1]={cmdList={},delay=1,idx=1,startTime=0,type=[[player]],},
	[2]={
		cmdList={
			[1]={
				args={
					[1]={[1]=[[白婆婆]],},
					[2]={[1]=1750,},
					[3]={[1]=-500,[2]=-120,},
					[4]={[1]=1,},
					[5]={[1]=0,},
					[6]={[1]=1,},
					[7]={[1]=[[rotation]],},
				},
				cmdType=[[player]],
				func=[[AddLayerAniPlayer]],
				name=[[生成界面人物]],
			},
			[2]={
				args={
					[1]={[1]=[[我]],},
					[2]={[1]=0,},
					[3]={[1]=-280,[2]=-120,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=2,},
					[7]={[1]=[[rotation]],},
				},
				cmdType=[[player]],
				func=[[AddLayerAniPlayer]],
				name=[[生成界面人物]],
			},
			[3]={
				args={
					[1]={[1]=1,},
					[2]={[1]=1,},
					[3]={[1]=1,},
					[4]={[1]=[[none]],},
					[5]={[1]=0,},
					[6]={[1]=0,},
					[7]={[1]=[[none]],},
					[8]={[1]=[[none]],},
				},
				cmdType=[[setting]],
				func=[[SetDialogueAniViewActive]],
				name=[[显示剧情界面]],
			},
		},
		delay=1,
		idx=2,
		startTime=1,
		type=[[player]],
	},
	[3]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=1,},
					[3]={[1]=-500,[2]=140,},
					[4]={[1]=1,},
					[5]={[1]=1.7,},
				},
				cmdType=[[player]],
				func=[[LayerAniCameraScale]],
				name=[[界面镜头缩放]],
			},
		},
		delay=1,
		idx=3,
		startTime=2,
		type=[[player]],
	},
	[4]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=[[婆婆你又偷偷在我房间贴这种莫名其妙的海报！]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=3,
		idx=4,
		startTime=3,
		type=[[player]],
	},
	[5]={
		cmdList={
			[1]={
				args={[1]={[1]=1,[2]=[[白婆婆]],},[2]={[1]=-400,[2]=-120,},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerRunto]],
				name=[[人物移动]],
			},
		},
		delay=1,
		idx=5,
		startTime=6,
		type=[[player]],
	},
	[6]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[白婆婆]],},
					[2]={[1]=[[守护梦想与忠诚，我们是世界的偶像~]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=3,
		idx=6,
		startTime=7,
		type=[[player]],
	},
	[7]={
		cmdList={
			[1]={
				args={[1]={[1]=2,[2]=[[我]],},[2]={[1]=[[dian]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
		},
		delay=3,
		idx=7,
		startTime=10,
		type=[[player]],
	},
	[8]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=[[守护……与……，我们是……]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
			[2]={
				args={[1]={[1]=1,[2]=[[白婆婆]],},[2]={[1]=[[shengqi]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
		},
		delay=4,
		idx=8,
		startTime=13,
		type=[[player]],
	},
	[9]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[白婆婆]],},
					[2]={[1]=[[婆婆安利给你这么多次不会记不住吧？]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[我]],},[2]={[1]=[[wuyu1]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
		},
		delay=3,
		idx=9,
		startTime=17,
		type=[[player]],
	},
	[10]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=[[守护梦想与忠诚，我们是世界的偶像！]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=4,
		idx=10,
		startTime=20,
		type=[[player]],
	},
	[11]={
		cmdList={
			[1]={
				args={
					[1]={[1]=1,[2]=[[白婆婆]],},
					[2]={
						[1]=[[将我爱豆的海报贴你房间还不满意吗！记住你还要买……]],
					},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
			[2]={
				args={[1]={[1]=2,[2]=[[我]],},[2]={[1]=-180,[2]=-40,},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerRunto]],
				name=[[人物移动]],
			},
			[3]={
				args={[1]={[1]=2,[2]=[[我]],},[2]={[1]=[[wuyu2]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
		},
		delay=4,
		idx=11,
		startTime=24,
		type=[[player]],
	},
	[12]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=[[天啊，为什么有这么羞耻的口头禅！]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=3,
		idx=12,
		startTime=28,
		type=[[player]],
	},
	[13]={
		cmdList={
			[1]={
				args={
					[1]={[1]=2,[2]=[[我]],},
					[2]={[1]=1,},
					[3]={[1]=500,[2]=20,},
					[4]={[1]=1,},
					[5]={[1]=1.7,},
				},
				cmdType=[[player]],
				func=[[LayerAniCameraScale]],
				name=[[界面镜头缩放]],
			},
			[2]={
				args={[1]={[1]=1,[2]=[[白婆婆]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetLayerAniPlayerActive]],
				name=[[设置界面人物是否可见]],
			},
			[3]={
				args={[1]={[1]=2,[2]=[[我]],},[2]={[1]=0,},},
				cmdType=[[player]],
				func=[[SetLayerAniPlayerActive]],
				name=[[设置界面人物是否可见]],
			},
		},
		delay=1,
		idx=13,
		startTime=31,
		type=[[player]],
	},
	[14]={
		cmdList={
			[1]={
				args={
					[1]={[1]=[[绯翼]],},
					[2]={[1]=1201,},
					[3]={[1]=500,[2]=-180,},
					[4]={[1]=1,},
					[5]={[1]=1,},
					[6]={[1]=3,},
					[7]={[1]=[[rotation]],},
				},
				cmdType=[[player]],
				func=[[AddLayerAniPlayer]],
				name=[[生成界面人物]],
			},
			[2]={
				args={
					[1]={[1]=[[青翼]],},
					[2]={[1]=1200,},
					[3]={[1]=300,[2]=-180,},
					[4]={[1]=0,},
					[5]={[1]=1,},
					[6]={[1]=4,},
					[7]={[1]=[[rotation]],},
				},
				cmdType=[[player]],
				func=[[AddLayerAniPlayer]],
				name=[[生成界面人物]],
			},
		},
		delay=2,
		idx=14,
		startTime=32,
		type=[[player]],
	},
	[15]={
		cmdList={
			[1]={
				args={
					[1]={[1]=3,[2]=[[绯翼]],},
					[2]={[1]=[[强健之躯是艺术，而爱，是它的灵魂！]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=4,
		idx=15,
		startTime=34,
		type=[[player]],
	},
	[16]={
		cmdList={
			[1]={
				args={
					[1]={[1]=4,[2]=[[青翼]],},
					[2]={[1]=[[不忠之人即为恶，这一箭会让他神魂颠倒哟~~]],},
				},
				cmdType=[[player]],
				func=[[LayerAniPlayerSay]],
				name=[[界面人物冒泡说话]],
			},
		},
		delay=4,
		idx=16,
		startTime=38,
		type=[[player]],
	},
	[17]={
		cmdList={
			[1]={
				args={[1]={[1]=3,[2]=[[绯翼]],},[2]={[1]=[[kaixin]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
			[2]={
				args={[1]={[1]=4,[2]=[[青翼]],},[2]={[1]=[[kaixin]],},[3]={[1]=1,},},
				cmdType=[[player]],
				func=[[LayerAniPlayerShowSocialEmoji]],
				name=[[界面社交表情]],
			},
		},
		delay=3,
		idx=17,
		startTime=42,
		type=[[player]],
	},
	[18]={cmdList={},delay=1,idx=18,startTime=45,type=[[player]],},
}

CONFIG={
	isLoop=0,
	isStroy=3,
	isTrigger=0,
	loopTime=0,
	mapInfo=[[3013]],
	minTriggerLevel=1,
	name=[[剧场动画名_3014]],
}
