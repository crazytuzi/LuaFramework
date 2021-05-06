module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[runWar]],
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
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.2,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0,
		},
		[3]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[4]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[5]={args={},func_name=[[MagcAnimStart]],start_time=0,},
		[6]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[7]={
			args={sound_path=[[Magic/sound_magic_50101_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[8]={
			args={
				alive_time=0.1,
				ease_hide_time=0.05,
				ease_show_time=0.05,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_zise.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.25,
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
			start_time=0.25,
		},
		[10]={
			args={
				alive_time=0.55,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[top]],
					path=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_hit01.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.1,
			},
			func_name=[[BodyEffect]],
			start_time=0.3,
		},
		[11]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.65,
		},
		[12]={
			args={
				alive_time=0.15,
				ease_hide_time=0.05,
				ease_show_time=0,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_zise.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.65,
		},
		[13]={
			args={
				alive_time=0.55,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_hit02.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.65,
		},
		[14]={args={},func_name=[[End]],start_time=1,},
		[15]={
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
				height=0.15,
			},
			func_name=[[BodyEffect]],
			start_time=1,
		},
		[16]={args={},func_name=[[MagcAnimEnd]],start_time=1,},
	},
	group_cmds={},
	magic_anim_end_time=1,
	magic_anim_start_time=0,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_hit01.prefab]],
		[3]=[[Effect/Magic/magic_eff_501/Prefabs/magic_eff_50101_hit02.prefab]],
		[4]=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail02.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
