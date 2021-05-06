module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				excutor=[[atkobj]],
				face_to=[[fixed_pos]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0.2,
			},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_31202_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={
			args={action_name=[[attack2]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.1,
		},
		[5]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.1,
		},
		[6]={
			args={
				alive_time=2,
				bind_idx=101,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_att2.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.1,
		},
		[7]={
			args={
				alive_time=1.2,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=1,},
				delay_time=0.3,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				move_time=0.9,
			},
			func_name=[[ShootEffect]],
			start_time=1.25,
		},
		[8]={
			args={
				alive_time=1.2,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=1,},
				delay_time=0.3,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				move_time=0.9,
			},
			func_name=[[ShootEffect]],
			start_time=1.25,
		},
		[9]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=2.3,
		},
		[10]={args={},func_name=[[End]],start_time=3.1,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_att2.prefab]],
		[3]=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_fly.prefab]],
		[4]=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail.prefab]],
		[5]=[[Effect/Magic/magic_eff_312/Prefabs/magic_eff_31202_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
