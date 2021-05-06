module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={args={},func_name=[[MagcAnimStart]],start_time=0,},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_175201_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={
			args={
				alive_time=0.5,
				begin_pos={base_pos=[[atk]],depth=0.85,relative_angle=0,relative_dis=-1,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175201_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0.8,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				move_time=0.3,
			},
			func_name=[[ShootEffect]],
			start_time=0.5,
		},
		[6]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.75,
		},
		[7]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175201_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.3,
			},
			func_name=[[BodyEffect]],
			start_time=0.75,
		},
		[8]={args={},func_name=[[MagcAnimEnd]],start_time=0.8,},
		[9]={args={},func_name=[[End]],start_time=1.6,},
	},
	group_cmds={},
	magic_anim_end_time=0.8,
	magic_anim_start_time=0,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175201_fly.prefab]],
		[2]=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175201_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
