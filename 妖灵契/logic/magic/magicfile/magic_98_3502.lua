module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[attack2]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={time=1.98,},func_name=[[HideUI]],start_time=0,},
		[3]={args={player_swipe=false,},func_name=[[CameraLock]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_3502_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0.05,
		},
		[5]={
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
			start_time=0.1,
		},
		[6]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3502/Prefabs/magic_eff_3502_hit2.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0.3,
			},
			func_name=[[BodyEffect]],
			start_time=1.3,
		},
		[7]={args={player_swipe=true,},func_name=[[CameraLock]],start_time=2,},
		[8]={args={},func_name=[[End]],start_time=2,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3501/Prefabs/magic_eff_3501_att02.prefab]],
		[2]=[[Effect/Magic/magic_eff_3502/Prefabs/magic_eff_3502_hit2.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
