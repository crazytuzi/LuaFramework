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
		[2]={
			args={
				excutor=[[atkobj]],
				face_to=[[look_at]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=1.5,
			},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[3]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[4]={
			args={sound_path=[[Magic/sound_magic_120001_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[5]={
			args={
				alive_time=0.6,
				begin_pos={base_pos=[[atk]],depth=0.7,relative_angle=0,relative_dis=-2,},
				delay_time=0,
				ease_type=[[Unset]],
				effect={
					is_cached=false,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1200/Prefabs/magic_eff_120001_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0.6,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				move_time=0.5,
			},
			func_name=[[ShootEffect]],
			start_time=0.7,
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
			start_time=1,
		},
		[7]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_1200/Prefabs/magic_eff_120001_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=-0.2,
			},
			func_name=[[BodyEffect]],
			start_time=1.1,
		},
		[8]={args={},func_name=[[End]],start_time=1.3,},
	},
	group_cmds={},
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_1200/Prefabs/magic_eff_120001_fly.prefab]],
		[2]=[[Effect/Magic/magic_eff_1200/Prefabs/magic_eff_120001_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
