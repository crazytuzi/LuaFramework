module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[runWar]],
				action_time=0.43,
				end_frame=11,
				excutor=[[atkobj]],
				start_frame=0,
			},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_30801_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={
			args={sound_path=[[Magic/sound_magic_30801_0.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0.01,
		},
		[5]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.7,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.34,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.16,
		},
		[6]={args={},func_name=[[MagcAnimStart]],start_time=0.2,},
		[7]={
			args={
				alive_time=1.12,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_308/Prefabs/magic_eff_30801_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.22,
		},
		[8]={
			args={action_name=[[attack1]],excutor=[[atkobj]],start_frame=7,},
			func_name=[[PlayAction]],
			start_time=0.45,
		},
		[9]={
			args={
				alive_time=0.5,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_308/Prefabs/magic_eff_30801_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.57,
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
			start_time=0.59,
		},
		[11]={
			args={
				alive_time=0.1,
				ease_hide_time=0.1,
				ease_show_time=0,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_red_blend.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.65,
		},
		[12]={args={},func_name=[[MagcAnimEnd]],start_time=1,},
		[13]={args={},func_name=[[End]],start_time=1.11,},
	},
	group_cmds={},
	magic_anim_end_time=1,
	magic_anim_start_time=0.2,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_308/Prefabs/magic_eff_30801_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_308/Prefabs/magic_eff_30801_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
