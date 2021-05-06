module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[attack3]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_3503_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att02.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.4,
		},
		[5]={
			args={shake_dis=0.02,shake_rate=10,shake_time=0.8,},
			func_name=[[ShakeScreen]],
			start_time=0.7,
		},
		[6]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3503/Prefabs/magic_eff_3503_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0.1,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.7,
		},
		[7]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.7,
		},
		[8]={
			args={shake_dis=0.04,shake_rate=10,shake_time=0.3,},
			func_name=[[ShakeScreen]],
			start_time=1.75,
		},
		[9]={args={},func_name=[[End]],start_time=2,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att02.prefab]],
		[2]=[[Effect/Magic/magic_eff_3503/Prefabs/magic_eff_3503_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
