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
				excutor=[[atkobj]],
				face_to=[[fixed_pos]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0,
			},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[3]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_att_stroy.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0,
		},
		[4]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[5]={args={},func_name=[[MagcAnimStart]],start_time=0.28,},
		[6]={
			args={
				alive_time=0.7,
				begin_pos={base_pos=[[atk]],depth=1.7,relative_angle=90,relative_dis=-0.5,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=false,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				move_time=0.6,
			},
			func_name=[[ShootEffect]],
			start_time=1.2,
		},
		[7]={
			args={
				alive_time=0.7,
				begin_pos={base_pos=[[atk]],depth=1.7,relative_angle=90,relative_dis=-0.5,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=false,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				move_time=0.6,
			},
			func_name=[[ShootEffect]],
			start_time=1.55,
		},
		[8]={args={},func_name=[[MagcAnimEnd]],start_time=1.7,},
		[9]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.7,
		},
		[10]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=1.7,
		},
		[11]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=2.05,
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
			start_time=2.05,
		},
		[13]={args={},func_name=[[End]],start_time=2.3,},
	},
	group_cmds={},
	magic_anim_end_time=1.7,
	magic_anim_start_time=0.28,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_att_stroy.prefab]],
		[2]=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_fly.prefab]],
		[3]=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_fly.prefab]],
		[4]=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_hit.prefab]],
		[5]=[[Effect/Magic/magic_eff_403/Prefabs/magic_eff_40302_hit.prefab]],
	},
	run_env=[[dialogueani]],
	type=1,
	wait_goback=true,
}
