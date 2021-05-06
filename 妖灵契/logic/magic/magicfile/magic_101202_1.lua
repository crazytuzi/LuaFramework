module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[show]],end_frame=22,excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={
				alive_time=0.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=1.35,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.35,
		},
		[4]={
			args={
				alive_time=0.15,
				ease_hide_time=0.35,
				ease_show_time=0.1,
				excutor=[[vicobj]],
				mat_path=[[Material/effect_Fresnel_red_blend02.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.45,
		},
		[5]={
			args={
				alive_time=1.5,
				bind_idx=101,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att4_bone015.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.5,
		},
		[6]={
			args={
				alive_time=1.5,
				bind_type=[[pos]],
				body_pos=[[head]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.5,
		},
		[7]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[vicobj]],
				look_at_pos=true,
				move_time=0.5,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.8,
		},
		[8]={
			args={action_name=[[run]],excutor=[[vicobj]],},
			func_name=[[PlayAction]],
			start_time=0.8,
		},
		[9]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att2.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[10]={
			args={action_name=[[attack2]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1,
		},
		[11]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.2,
		},
		[12]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.2,
		},
		[13]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic_lineup]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[vicobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=1.4,
		},
		[14]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.4,
		},
		[15]={
			args={
				alive_time=3.5,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.6,
		},
		[16]={
			args={action_name=[[attack1]],action_time=0.7,excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1.6,
		},
		[17]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.25,
				move_type=[[line]],
			},
			editor_is_ban=false,
			func_name=[[Move]],
			start_time=1.6,
		},
		[18]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.7,
		},
		[19]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.8,
		},
		[20]={
			args={action_name=[[attack2]],action_time=1.2,excutor=[[atkobj]],start_frame=25,},
			func_name=[[PlayAction]],
			start_time=2.1,
		},
		[21]={
			args={
				alive_time=1.5,
				bind_idx=101,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att4_bone015.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=2.1,
		},
		[22]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att3.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=2.5,
		},
		[23]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[head]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1506/Prefabs/magic_eff_150602_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0.25,
			},
			func_name=[[BodyEffect]],
			start_time=2.5,
		},
		[24]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=2.5,
		},
		[25]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=2.5,
		},
		[26]={args={},func_name=[[End]],start_time=3.4,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att4_bone015.prefab]],
		[3]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_hit.prefab]],
		[4]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att2.prefab]],
		[5]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
		[6]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_att.prefab]],
		[7]=[[Effect/Magic/magic_eff_smoketrail/Prefabs/magic_eff_smoketrail.prefab]],
		[8]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
		[9]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att4_bone015.prefab]],
		[10]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101202_att3.prefab]],
		[11]=[[Effect/Magic/magic_eff_1506/Prefabs/magic_eff_150602_hit.prefab]],
		[12]=[[Effect/Magic/magic_eff_1012/Prefabs/magic_eff_101201_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
