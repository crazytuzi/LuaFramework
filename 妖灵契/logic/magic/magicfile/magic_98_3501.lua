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
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[3]={
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
			start_time=0,
		},
		[4]={
			args={sound_path=[[Magic/sound_magic_3501_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={args={time=1.99,},func_name=[[HideUI]],start_time=0,},
		[6]={args={player_swipe=false,},func_name=[[CameraLock]],start_time=0,},
		[7]={args={},func_name=[[MagcAnimStart]],start_time=0.28,},
		[8]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[top]],
					path=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.3,
			},
			func_name=[[BodyEffect]],
			start_time=1.2,
		},
		[9]={
			args={shake_dis=0.02,shake_rate=10,shake_time=0.4,},
			func_name=[[ShakeScreen]],
			start_time=1.2,
		},
		[10]={args={},func_name=[[End]],start_time=2,},
		[11]={args={player_swipe=true,},func_name=[[CameraLock]],start_time=2.01,},
	},
	group_cmds={},
	magic_anim_start_time=0.28,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att02.prefab]],
		[3]=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
