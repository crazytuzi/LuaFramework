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
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_31402_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={args={},func_name=[[MagcAnimStart]],start_time=0.28,},
		[6]={
			args={
				alive_time=0.7,
				begin_pos={base_pos=[[atk]],depth=1.15,relative_angle=28.46,relative_dis=1.08,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=false,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=-1,relative_angle=0,relative_dis=-0.5,},
				excutor=[[vicobjs]],
				move_time=0.5,
			},
			func_name=[[ShootEffect]],
			start_time=0.75,
		},
		[7]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.75,
		},
		[8]={
			args={shake_dis=0.12,shake_rate=20,shake_time=0.15,},
			func_name=[[ShakeScreen]],
			start_time=1.15,
		},
		[9]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.15,
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
			start_time=1.2,
		},
		[11]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31401_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobj]],
				height=0.2,
			},
			func_name=[[BodyEffect]],
			start_time=1.2,
		},
		[12]={args={},func_name=[[MagcAnimEnd]],start_time=1.2,},
		[13]={args={},func_name=[[End]],start_time=1.2,},
	},
	group_cmds={},
	magic_anim_end_time=1.2,
	magic_anim_start_time=0.28,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_fly.prefab]],
		[2]=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_att.prefab]],
		[3]=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31402_hit.prefab]],
		[4]=[[Effect/Magic/magic_eff_314/Prefabs/magic_eff_31401_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
