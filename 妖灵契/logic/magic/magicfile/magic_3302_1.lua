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
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3302/Prefabs/magic_eff_3302_att.prefab]],
					preload=true,
				},
				effect_dir_type=[[relative]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				relative_dir={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=1,},
			},
			func_name=[[StandEffect]],
			start_time=0,
		},
		[3]={args={},func_name=[[MagcAnimStart]],start_time=0,},
		[4]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[5]={
			args={sound_path=[[Magic/sound_magic_3302_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[6]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_3302/Prefabs/magic_eff_3302_hit.prefab]],
					preload=true,
				},
				effect_dir_type=[[relative]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
				relative_dir={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1,},
			},
			func_name=[[StandEffect]],
			start_time=0.55,
		},
		[7]={args={},func_name=[[MagcAnimEnd]],start_time=0.7,},
		[8]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.7,
		},
		[9]={args={},func_name=[[End]],start_time=0.75,},
	},
	group_cmds={},
	magic_anim_end_time=0.7,
	magic_anim_start_time=0,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_3302/Prefabs/magic_eff_3302_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_3302/Prefabs/magic_eff_3302_hit.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
