
local tb    = {
	partner_nlz_normal= --纳兰真-冰心穿云-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_nlz_chpd = --纳兰真-慈航普度
	{ 
	 	userdesc_000={2562},
		missile_hitcount={0,0,1},
	},	
	partner_nlz_chpd_child = --纳兰真-慈航普度_子
	{ 
	 	vitality_recover_life={{{1,120},{20,120}},15},
		skill_statetime={{{1,15*5},{20,15*5}}},
	},
	partner_snyyf_normal=	--少年杨影枫-杨家剑法-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_snyyf_hdwl = --少年杨影枫-画地为牢
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},		
		missile_hitcount={0,0,3},
    },
	partner_ssys_normal = --双首异兽-双龙吐珠-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_ssys_yfsg = --双首异兽-阴风蚀骨
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},		
		missile_hitcount={0,0,3},
    },
	partner_bybw_normal = --奔焰豹王-爪击-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_bybw_flsy = --奔焰豹王-猛力撕咬
    { 
		attack_usebasedamage_p={{{1,180},{20,180}}},
		loselife_dmg_p={{{1,1*100},{20,1*100}}},				--增加：发挥基础攻击力% = 损失生命% * 参数 / 100
		missile_hitcount={0,0,3},
    },
	partner_jwhw_normal = --九尾狐王-雷击-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_jwhw_fwr = --九尾狐王-风舞刃
    { 
		attack_usebasedamage_p={{{1,120},{20,120}}},		
		missile_hitcount={0,0,3},
    },
	partner_tx_normal = --唐潇-追心箭-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_tx_mcqh = --唐潇-明察秋毫
    { 
		deadlystrike_v={{{1,200},{20,200}}},		
		skill_statetime={{{1,15*3},{20,15*3}}},
    },
	partner_zx_normal = --紫轩-琉璃散落-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
    partner_zx_lymt= --紫轩-落樱漫天
    { 
		userdesc_000={966},
    },
    partner_zx_lymt_child = --紫轩-落樱漫天_子
    { 
		attack_usebasedamage_p={{{1,75},{15,75}}},
		state_palsy_attack={{{1,10},{15,10}},{{1,15*0.5},{15,15*0.5}}},
    },
	partner_qw_normal = --蔷薇-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_qw_jxmy= --蔷薇-九溪弥烟
    { 
		userdesc_000={2883},
    },
	partner_qw_jxmy_child= --蔷薇-九溪弥烟_子
    { 
		attack_usebasedamage_p={{{1,180},{20,180}}},
		missile_hitcount={0,0,3},
    },
	partner_zff_normal = --卓非凡-意剑-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},		
		missile_hitcount={0,0,3},
    },
	partner_zff_flws = --卓非凡-风来吴山
    { 
		attack_usebasedamage_p={{{1,40},{20,40}}},		
    },
	partner_ymy_normal = --月明瑶-飞花落-普攻
    { 
		attack_usebasedamage_p={{{1,225},{20,225}}},		
		missile_hitcount={0,0,3},
    },
    partner_ymy_myj = --月明瑶-明月诀
    { 
	 	attackspeed_v={{{1,60},{20,60}}},
		skill_statetime={{{1,15*5},{15,15*5}}},
    },
	partner_ngch_normal = --南宫彩虹-雨后彩虹-普攻
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},		
		missile_hitcount={0,0,3},
    },
	partner_ngch_xmch = --南宫彩虹-寻觅彩虹
    { 
		userdesc_000={972},		
    },
	partner_ngch_xmch_child = --南宫彩虹-寻觅彩虹_子
    { 
		attack_usebasedamage_p={{{1,120},{20,120}}},
		state_knock_attack={50,7,70},
		state_npcknock_attack={50,7,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID		
    },
	partner_zrm_normal = --张如梦-长烟落日-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
	partner_zrm_gsyy = --张如梦-孤山映月
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},
		state_npchurt_attack={100,7},
		state_hurt_attack={100,7},			
		missile_hitcount={0,0,3},
    },
	partner_zlx_normal = --张琳心-江南如烟-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_zlx_qxs = --张琳心_清心术
    { 
		ignore_series_state={},	
		ignore_abnor_state={},
		basic_damage_v={
			[1]={{1,50},{20,50}},
			[3]={{1,50},{20,50}}
			},			
		skill_statetime={{{1,15*6},{10,15*6}}},
    },
	partner_fys_normal = --封玉书-枪-普攻
    { 
		attack_usebasedamage_p={{{1,225},{20,225}}},		
		missile_hitcount={0,0,3},
    },
	partner_fys_dzxy = --封玉书-斗转星移
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},
		state_drag_attack={{{1,100},{15,100}},8,70},
		skill_drag_npclen={70},
    },
	partner_fys_dzxy_child = --封玉书-斗转星移_子
    { 
		state_zhican_attack={{{1,100},{15,100}},{{1,15*1.5},{15,15*1.5}}},
    },
	partner_qx_normal = --曲霞-毒刺骨-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
	partner_qx_bsqf = --曲霞-悲酥清风
    { 
		basic_damage_v={
			[1]={{1,-100},{20,-100}},
			[3]={{1,-100},{20,-100}}
			},		
		skill_statetime={{{1,15*10},{10,15*10}}},
    },
	partner_ylpl_normal = --耶律辟离-弹指烈焰-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
	partner_ylpl_twlx = --耶律辟离-天外流星
    { 
		userdesc_000={2633},
    },
	partner_ylpl_twlx_child = --耶律辟离-天外流星
    { 
		attack_usebasedamage_p={{{1,75},{20,75}}},	
		missile_hitcount={0,0,3},	
    },
	partner_lh_normal = --林海-华山剑法-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_lh_jbf = --林海-羁绊符
    { 
	 	attackspeed_v={{{1,-40},{20,-40}}},
	 	runspeed_v={{{1,-200},{20,-200}}},
		skill_statetime={{{1,15*6},{15,15*6}}},
    },
	partner_lwl_normal = --陆文龙普攻-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
	partner_lwl_klg = --陆文龙-困龙功
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},
		state_palsy_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},	
		missile_hitcount={0,0,3},
    },
	partner_zws_normal = --赵无双普攻-普攻
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},		
		missile_hitcount={0,0,3},
    },
	partner_zws_fxbt = --赵无双-风雪冰天
	{ 
	 	userdesc_000={979},
	},	
	partner_zws_fxbt_child = --赵无双-风雪冰天_子
	{ 
		attack_usebasedamage_p={{{1,120},{20,120}}},
		state_slowall_attack={{{1,50},{20,50}},{{1,15*1.5},{20,15*1.5}}},				
		missile_hitcount={0,0,3},
	},
	partner_wx_normal = --无相-行龙不雨-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
	partner_wx_hlth = --无相-黑龙探海
	{ 
		attack_usebasedamage_p={{{1,276},{20,276}}},		
		attack_steallife_p={{{1,5},{20,5}}},		
		missile_hitcount={0,0,3},
	},
	partner_zj_normal = --赵节-行龙不雨-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_zj_hsqj = --赵节-横扫千军
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
		missile_hitcount={0,0,3},
    },
	partner_sqf_normal = --邵骑风-穿心刺-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_sqf_myzt = --邵骑风-魔焰在天
    { 
		userdesc_000={982},			
		ms_one_hit_count = {0,0,1},				--每次攻击最大数量
		ms_hit_finish_vanish={},			--击中完后子弹就消失
		ms_vanish_remove_buff={981},		--子弹消失后，清掉BUFF
		missile_hitcount={0,0,6},
    }, 
    partner_sqf_myzt_child = --魔焰在天_子
    { 
		attack_usebasedamage_p={{{1,75},{20,75}}},
		missile_hitcount={0,0,1},	
    }, 
	partner_hmx_normal = ---何暮雪-翠烟掌法-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_hmx_mylx = --何暮雪-牧野流星
    { 
		attack_usebasedamage_p={{{1,120},{20,120}}}, 
		state_slowall_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},			
		missile_hitcount={0,0,3},
    },
	partner_zsq_normal = --赵升权-风雪神枪-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_zsq_fxbf = --赵升权-风雪步法
    { 
		basic_damage_v={
			[1]={{1,20},{20,20}},
			[3]={{1,20},{20,20}}
			},	
		attackrate_v={{{1,100},{20,100}}},
		attackspeed_v={{{1,20},{20,20}}},
		deadlystrike_v={{{1,100},{20,100}}},
		runspeed_v={{{1,20},{20,20}}},
		--ignore_series_state={},	
		--ignore_abnor_state={},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
	partner_cs_normal = --柴嵩-高山流水-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},			
		missile_hitcount={0,0,3},
    },
    partner_cs_yhmd = --柴嵩-云海梦蝶
    { 
		basic_damage_v={
			[1]={{1,50},{20,50}},
			[3]={{1,50},{20,50}}
			},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
}

FightSkill:AddMagicData(tb)