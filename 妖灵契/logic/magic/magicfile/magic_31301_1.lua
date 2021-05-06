module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				action_name=[[attack1]],
				action_time=0.85,
				end_frame=25,
				excutor=[[atkobj]],
				start_frame=0,
			},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={sound_path=[[Magic/sound_magic_31301_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0.1,
		},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0.35,},
		[4]={
			args={
				alive_time=2.5,
				bind_idx=102,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att_prop2.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.35,
		},
		[5]={
			args={
				alive_time=2.5,
				bind_idx=101,
				bind_type=[[node]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att_prop1.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.35,
		},
		[6]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att2.prefab]],
					preload=true,
				},
				effect_dir_type=[[left]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			editor_is_ban=false,
			func_name=[[StandEffect]],
			start_time=0.35,
		},
		[7]={
			args={action_name=[[run]],action_time=0.6,excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.85,
		},
		[8]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.35,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.85,
		},
		[9]={args={},func_name=[[MagcAnimStart]],start_time=1.3,},
		[10]={
			args={action_name=[[attack1]],end_frame=50,excutor=[[atkobj]],start_frame=22,},
			func_name=[[PlayAction]],
			start_time=1.3,
		},
		[11]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.35,
		},
		[12]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.5,
		},
		[13]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.5,
		},
		[14]={
			args={shake_dis=0.1,shake_rate=55,shake_time=0.1,},
			func_name=[[ShakeScreen]],
			start_time=1.55,
		},
		[15]={
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
		[16]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.8,
		},
		[17]={
			args={shake_dis=0.15,shake_rate=25,shake_time=0.1,},
			func_name=[[ShakeScreen]],
			start_time=1.85,
		},
		[18]={
			args={action_name=[[idleWar]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=2.25,
		},
		[19]={args={},func_name=[[MagcAnimEnd]],start_time=2.3,},
		[20]={args={},func_name=[[End]],start_time=2.45,},
	},
	group_cmds={},
	magic_anim_end_time=2.3,
	magic_anim_start_time=1.3,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att_prop2.prefab]],
		[2]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att_prop1.prefab]],
		[3]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att2.prefab]],
		[4]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_att.prefab]],
		[5]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_hit.prefab]],
		[6]=[[Effect/Magic/magic_eff_313/Prefabs/magic_eff_31301_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
