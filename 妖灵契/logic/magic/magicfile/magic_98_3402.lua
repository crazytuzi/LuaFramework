module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={time=1.2,},func_name=[[HideUI]],start_time=0,},
		[2]={args={player_swipe=false,},func_name=[[CameraLock]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_3402_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0.18,
		},
		[4]={
			args={action_name=[[attack2]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.2,
		},
		[5]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3402/Prefabs/magic_eff_3402_att03.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.52,
		},
		[6]={
			args={shake_dis=0.03,shake_rate=10,shake_time=0.7,},
			func_name=[[ShakeScreen]],
			start_time=0.55,
		},
		[7]={args={player_swipe=true,},func_name=[[CameraLock]],start_time=1.2,},
		[8]={args={},func_name=[[End]],start_time=1.2,},
	},
	group_cmds={},
	pre_load_res={[1]=[[Effect/Magic/magic_eff_3402/Prefabs/magic_eff_3402_att03.prefab]],},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
