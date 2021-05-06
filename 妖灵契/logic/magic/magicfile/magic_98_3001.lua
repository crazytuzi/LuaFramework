module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={time=1,},func_name=[[HideUI]],start_time=0,},
		[2]={args={player_swipe=false,},func_name=[[CameraLock]],start_time=0,},
		[3]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3001/Prefabs/magic_eff_3001_att02.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0.3,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.25,
		},
		[4]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.25,
		},
		[5]={
			args={shake_dis=0.05,shake_rate=5,shake_time=0.2,},
			func_name=[[ShakeScreen]],
			start_time=0.65,
		},
		[6]={
			args={
				alive_time=0.55,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[bottom]],
					path=[[Effect/Magic/magic_eff_3001/Prefabs/magic_eff_3001_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.4,
			},
			func_name=[[BodyEffect]],
			start_time=0.65,
		},
		[7]={args={player_swipe=true,},func_name=[[CameraLock]],start_time=1,},
		[8]={args={},func_name=[[End]],start_time=1,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3001/Prefabs/magic_eff_3001_att02.prefab]],
		[2]=[[Effect/Magic/magic_eff_3001/Prefabs/magic_eff_3001_hit.prefab]],
	},
	run_env=[[createrole]],
	type=1,
	wait_goback=false,
}
