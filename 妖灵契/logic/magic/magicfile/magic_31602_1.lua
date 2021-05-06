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
		[2]={args={},func_name=[[MagcAnimStart]],start_time=0,},
		[3]={
			args={
				excutor=[[atkobj]],
				face_to=[[look_at]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0.5,
			},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[4]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_att.prefab]],
					preload=true,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0,
		},
		[5]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[6]={
			args={sound_path=[[Magic/sound_magic_31602_1.wav]],sound_rate=1,},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[7]={
			args={
				alive_time=0.5,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_fly.prefab]],
					preload=true,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=8,},
				excutor=[[atkobj]],
				move_time=0.5,
			},
			func_name=[[ShootEffect]],
			start_time=1,
		},
		[8]={
			args={
				down_time=0.5,
				excutor=[[vicobjs]],
				hit_speed=6,
				hit_time=0.4,
				lie_time=0.1,
				up_speed=6,
				up_time=0.2,
			},
			func_name=[[FloatHit]],
			start_time=1.3,
		},
		[9]={
			args={
				alive_time=0.15,
				ease_hide_time=0.05,
				ease_show_time=0,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_zise.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.3,
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
			start_time=1.3,
		},
		[11]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_hit03.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.3,
		},
		[12]={
			args={shake_dis=0.1,shake_rate=15,shake_time=0.3,},
			func_name=[[ShakeScreen]],
			start_time=1.3,
		},
		[13]={args={},func_name=[[MagcAnimEnd]],start_time=1.7,},
		[14]={args={},func_name=[[End]],start_time=1.8,},
	},
	group_cmds={},
	magic_anim_end_time=1.7,
	magic_anim_start_time=0,
	pre_load_res={
		[1]=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_att.prefab]],
		[2]=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_fly.prefab]],
		[3]=[[Effect/Magic/magic_eff_316/Prefabs/magic_eff_31602_hit03.prefab]],
	},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
