module(...)
--anim editor build
DATA={
	[101]={
		attack1001={
			[1]={action='attack3',end_frame=7,hit_frame=10,start_frame=0,},
			[2]={action='attack3',end_frame=11,hit_frame=10,start_frame=7,},
			[3]={action='attack3',end_frame=11,hit_frame=10,start_frame=7,},
			[4]={action='attack3',end_frame=29,hit_frame='nil',start_frame=11,},
		},
		attack1002={
			[1]={action='attack2',end_frame=20,hit_frame=6,start_frame=4,},
			[2]={action='attack3',end_frame=30,hit_frame=20,start_frame=8,},
		},
	},
	[102]={
		attack1002={
			[1]={action='attack1',end_frame=30,hit_frame=10,start_frame=0,},
			[2]={action='attack2',end_frame=30,hit_frame=20,start_frame=10,},
		},
	},
	[1110]={
		["1101"]={
			[1]={action='attack2',end_frame=13,hit_frame=20,speed=1,start_frame=8,},
			[2]={action='attack3',end_frame=17,hit_frame=20,speed=1,start_frame=6,},
			[3]={action='magic',end_frame=29,hit_frame=20,speed=1,start_frame=17,},
		},
		["1102"]={
			[1]={action='attack1',end_frame=12,hit_frame=9,speed=1,start_frame=0,},
			[2]={action='attack1',end_frame=12,hit_frame=3,speed=1,start_frame=8,},
			[3]={action='magic',end_frame=40,hit_frame=20,speed=1,start_frame=10,},
		},
		["1103"]={
			[1]={action='attack2',end_frame=12,hit_frame=20,speed=1,start_frame=8,},
			[2]={action='attack3',end_frame=11,hit_frame=3,speed=1,start_frame=8,},
			[3]={action='attack2',end_frame=12,hit_frame=3,speed=1,start_frame=8,},
			[4]={action='attack3',end_frame=25,hit_frame=3,speed=1,start_frame=8,},
		},
		["1104"]={
			[1]={action='attack3',end_frame=12,hit_frame=3,speed=1,start_frame=8,},
			[2]={action='attack1',end_frame=21,hit_frame=10,speed=1,start_frame=9,},
		},
	},
}
