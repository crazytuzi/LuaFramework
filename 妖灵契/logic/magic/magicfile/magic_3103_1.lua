module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[run]],
				action_time=0.49,
				end_frame=19,
				excutor=[[atkobj]],
				start_frame=0,
			},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={
				begin_type=[[current]],
				calc_face=false,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=false,
				move_time=0.25,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0,
		},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_3103_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={
			args={action_name=[[attack3]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.25,
		},
		[6]={args={},func_name=[[MagcAnimStart]],start_time=0.25,},
		[7]={
			args={
				alive_time=2.3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3103/Prefabs/magic_eff_3103_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.35,
		},
		[8]={
			args={shake_dis=0.05,shake_rate=15,shake_time=0.6,},
			func_name=[[ShakeScreen]],
			start_time=0.96,
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
			start_time=1.35,
		},
		[10]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3101/Prefabs/magic_eff_3101_hit01.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=-0.3,
			},
			func_name=[[BodyEffect]],
			start_time=1.35,
		},
		[11]={args={},func_name=[[End]],start_time=2,},
	},
	group_cmds={},
	magic_anim_start_time=0.25,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3103/Prefabs/magic_eff_3103_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_3101/Prefabs/magic_eff_3101_hit01.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
