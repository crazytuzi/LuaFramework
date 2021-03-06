module(...)
--magic editor build
DATA={
	atk_stophit=false,
	cmds={
		[1]={args={alive_time=0.5,},func_name=[[Name]],start_time=0,},
		[2]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=false,
			},
			func_name=[[VicHitInfo]],
			start_time=0.1,
		},
		[3]={
			args={
				alive_time=2,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/magic_eff_407/Prefabs/magic_eff_40702_hit.prefab]],
					preload=true,
				},
				excutor=[[vicobjs]],
				height=0.7,
			},
			func_name=[[BodyEffect]],
			start_time=0.1,
		},
		[4]={args={},func_name=[[MagcAnimStart]],start_time=0.2,},
		[5]={args={},func_name=[[End]],start_time=0.5,},
	},
	group_cmds={},
	magic_anim_start_time=0.2,
	pre_load_res={[1]=[[Effect/Magic/magic_eff_407/Prefabs/magic_eff_40702_hit.prefab]],},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
