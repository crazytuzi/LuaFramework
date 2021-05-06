module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				alive_time=2,
				bind_idx=100,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_302/Prefabs/magic_eff_30202_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_30202_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_302/Prefabs/magic_eff_30202_full.prefab]],
					preload=true,
				},
				effect_dir_type=[[relative]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=-0.5,},
				excutor=[[vicobj]],
				relative_dir={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=1,},
			},
			func_name=[[StandEffect]],
			start_time=0.01,
		},
		[5]={
			args={action_name=[[attack2]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.01,
		},
		[6]={args={},func_name=[[MagcAnimStart]],start_time=0.2,},
		[7]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[OutSine]],
				end_relative={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=1,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.4,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.25,
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
			start_time=0.79,
		},
		[9]={
			args={shake_dis=0.1,shake_rate=30,shake_time=0.35,},
			func_name=[[ShakeScreen]],
			start_time=0.8,
		},
		[10]={
			args={
				down_time=0.5,
				excutor=[[vicobjs]],
				hit_speed=8,
				hit_time=0.2,
				lie_time=0.2,
				up_speed=10,
				up_time=0.1,
			},
			func_name=[[FloatHit]],
			start_time=0.8,
		},
		[11]={args={},func_name=[[End]],start_time=1.2,},
	},
	group_cmds={},
	magic_anim_start_time=0.2,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_302/Prefabs/magic_eff_30202_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_302/Prefabs/magic_eff_30202_full.prefab]],
	},
	run_env=[[dialogueani]],
	type=1,
	wait_goback=true,
}
