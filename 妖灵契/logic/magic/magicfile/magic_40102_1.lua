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
		[2]={
			args={
				alive_time=4,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[3]={
			args={sound_path=[[Magic/sound_magic_40102_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[5]={
			args={sound_path=[[Magic/sound_magic_40102_0.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[6]={
			args={
				alive_time=1.5,
				bind_type=[[empty]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_hit.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0.5,
			},
			func_name=[[BodyEffect]],
			start_time=1.1,
		},
		[7]={
			args={
				alive_time=1.5,
				bind_type=[[empty]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.5,
			},
			func_name=[[BodyEffect]],
			start_time=1.1,
		},
		[8]={args={},func_name=[[End]],start_time=2.5,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_hit.prefab]],
		[3]=[[Effect/Magic/magic_eff_401/Prefabs/magic_eff_40102_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
