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
		[2]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[3]={
			args={sound_path=[[Magic/sound_magic_175202_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[4]={
			args={
				alive_time=0.8,
				begin_pos={base_pos=[[atk]],depth=0.85,relative_angle=0,relative_dis=0,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic_team_center]],depth=10,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				move_time=0.6,
			},
			func_name=[[ShootEffect]],
			start_time=0.85,
		},
		[5]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_full.prefab]],
					preload=true,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.5,
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
			start_time=1.65,
		},
		[7]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.65,
		},
		[8]={args={},func_name=[[End]],start_time=2,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_fly.prefab]],
		[2]=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_full.prefab]],
		[3]=[[Effect/Magic/magic_eff_1752/Prefabs/magic_eff_175202_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
