module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[runWar]],action_time=0.49,end_frame=19,excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0,
		},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_150201_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.19,
		},
		[6]={args={},func_name=[[MagcAnimStart]],start_time=0.2,},
		[7]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1502/Prefabs/magic_eff_150201_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.2,
		},
		[8]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1502/Prefabs/magic_eff_150201_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[9]={
			args={
				alive_time=0.2,
				ease_hide_time=0.2,
				ease_show_time=0,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_yellow01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.85,
		},
		[10]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.9,
		},
		[11]={args={},func_name=[[MagcAnimEnd]],start_time=1.5,},
		[12]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail02.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0.1,
			},
			func_name=[[BodyEffect]],
			start_time=1.5,
		},
		[13]={args={},func_name=[[End]],start_time=1.6,},
	},
	group_cmds={},
	magic_anim_end_time=1.5,
	magic_anim_start_time=0.2,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1502/Prefabs/magic_eff_150201_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_1502/Prefabs/magic_eff_150201_hit.prefab]],
		[3]=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail02.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
