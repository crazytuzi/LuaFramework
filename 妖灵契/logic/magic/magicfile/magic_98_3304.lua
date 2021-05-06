module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[runWar]],
				action_time=0.5,
				end_frame=19,
				excutor=[[atkobj]],
				start_frame=0,
			},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={time=0.95,},func_name=[[HideUI]],start_time=0,},
		[3]={args={player_swipe=false,},func_name=[[CameraLock]],start_time=0,},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3304/Prefabs/magic_eff_3304_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[relative]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
				relative_dir={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
			},
			func_name=[[StandEffect]],
			start_time=0.1,
		},
		[5]={
			args={action_name=[[attack4]],excutor=[[atkobj]],start_frame=12,},
			func_name=[[PlayAction]],
			start_time=0.5,
		},
		[6]={args={player_swipe=true,},func_name=[[CameraLock]],start_time=0.95,},
		[7]={args={},func_name=[[End]],start_time=0.95,},
	},
	group_cmds={},
	pre_load_res={[1]=[[Effect/Magic/magic_eff_3304/Prefabs/magic_eff_3304_att.prefab]],},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
