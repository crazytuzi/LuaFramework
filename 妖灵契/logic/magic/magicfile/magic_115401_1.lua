module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[attack1]],
				action_time=0.5,
				end_frame=6,
				excutor=[[atkobj]],
				start_frame=0,
			},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={
				alive_time=0.6,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1154/Prefabs/magic_eff_115401_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0.2,},
		[4]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.3,
		},
		[5]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.4,
		},
		[6]={
			args={
				alive_time=0.1,
				ease_hide_time=0.05,
				ease_show_time=0.05,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_yellow02.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.4,
		},
		[7]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1152/Prefabs/magic_eff_115201_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.2,
			},
			func_name=[[BodyEffect]],
			start_time=0.4,
		},
		[8]={args={},func_name=[[End]],start_time=0.4,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1154/Prefabs/magic_eff_115401_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_1152/Prefabs/magic_eff_115201_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
