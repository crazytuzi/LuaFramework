module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={
				excutor=[[atkobj]],
				face_to=[[fixed_pos]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0,
			},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[3]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_505/Prefabs/magic_eff_50501_hit01.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0.5,relative_angle=0,relative_dis=0.6,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0,
		},
		[4]={
			args={action_name=[[hit1]],action_time=0.8,excutor=[[vicobjs]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[5]={
			args={
				alive_time=1.2,
				color={a=0,b=255,g=255,r=255,},
				excutor=[[vicobjs]],
				fade_time=0.5,
			},
			func_name=[[ActorColor]],
			start_time=0,
		},
		[6]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[7]={
			args={shake_dis=0.01,shake_rate=5,shake_time=0.5,},
			func_name=[[ShakeScreen]],
			start_time=0.1,
		},
		[8]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.4,
		},
		[9]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.45,
		},
		[10]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_505/Prefabs/magic_eff_50501_hit02.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1,
		},
		[11]={
			args={shake_dis=0.02,shake_rate=10,shake_time=0.2,},
			func_name=[[ShakeScreen]],
			start_time=1.15,
		},
		[12]={args={},func_name=[[End]],start_time=1.6,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_505/Prefabs/magic_eff_50501_hit01.prefab]],
		[2]=[[Effect/Magic/magic_eff_505/Prefabs/magic_eff_50501_hit02.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
