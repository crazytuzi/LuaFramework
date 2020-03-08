
local tb    = {
    newrole_tw_xyj = --行云诀--普攻1式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_npcknock_attack={100,7,25},	
		spe_knock_param={6 , 4, 9},
    }, 
    newrole_tw_jlj = --惊雷诀--普攻2式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_hurt_attack={{{1,40},{20,40},{30,40}},{{1,4},{20,4},{30,4}}},
		
		state_npcknock_attack={100,7,45},	
		spe_knock_param={6 , 4, 9},
    }, 
	
    newrole_tw_xlj = --降龙诀--普攻3式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_hurt_attack={{{1,60},{20,60},{30,60}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,7,35},	
		spe_knock_param={6 , 4, 9},
	
    }, 	
    newrole_tw_ptj = --破天诀--普攻4式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1600},{30,2400}}},
		attack_metaldamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_hurt_attack={{{1,100},{20,100},{30,100}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
    }, 
	newrole_tw_ymcz = --野蛮冲撞--1级主动1
    { 
		userdesc_000={2106},
    },
    newrole_tw_ymcz_child = --野蛮冲撞_子
    { 
		attack_usebasedamage_p={{{1,2600},{30,4200}}},
		attack_metaldamage_v={
			[1]={{1,100*0.95},{30,500*0.95}},
			[3]={{1,100*1.05},{30,500*1.05}}
			},
		state_fixed_attack={{{1,100},{15,100}},{{1,15*1},{15,15*1}}},
		state_knock_attack={100,7,35},		
		state_npcknock_attack={100,7,35},	
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
    },
	newrole_tw_dmxy = --金钟罩-5级主动2
    { 
		all_series_resist_p={{{1,200},{30,300}}},
		recover_life_v={{{1,100},{30,300}},15*5},
		all_series_resist_v={{{1,50},{30,200}}},	
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
    newrole_tw_bwnh = --霸王怒吼--10级主动3
    { 
		attack_usebasedamage_p={{{1,3600},{30,4200}}},
		attack_metaldamage_v={
			[1]={{1,300*1},{30,450*0.95}},
			[3]={{1,300*1},{30,450*1.05}}
			},
		state_hurt_attack={{{1,100},{15,100}},{{1,15*1},{15,15*1}}},
		state_npcknock_attack={100,7,80},	
		spe_knock_param={6 , 4, 9},
    },
    newrole_tw_xzbf = --血战八方--30级主动4
    {
		userdesc_000={2109, 2110},
    },
    newrole_tw_xzbf_child1 = --血战八方_子1
    { 
		attack_usebasedamage_p={{{1,1000},{30,1200}}},
		attack_metaldamage_v={
			[1]={{1,50*0.95},{30,200*0.95}},
			[3]={{1,50*1.05},{30,200*1.05}}
			},
		state_npcknock_attack={100,7,30},	
		spe_knock_param={6 , 4, 9},		
    },
    newrole_tw_xzbf_child2 = --血战八方_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*7},{30,15*7}}},
    },

    newrole_em_pg1 = --峨眉剑法1
    { 
		attack_attackrate_v={{{1,100},{30,100}}}, 
		attack_usebasedamage_p={{{1,1400},{30,1800}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{30,150*0.95}},
			[3]={{1,40*1},{30,150*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{30,2}}},  
    }, 
    newrole_em_pg2 = --峨眉剑法2
    { 
		attack_attackrate_v={{{1,100},{30,100}}}, 
		attack_usebasedamage_p={{{1,1400},{30,1800}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{30,150*0.95}},
			[3]={{1,40*1},{30,150*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{30,2}}},  
    },
    newrole_em_pg3 = --峨眉剑法3
    { 
		attack_attackrate_v={{{1,100},{30,100}}}, 
		attack_usebasedamage_p={{{1,2000},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,60*1*0.5},{30,200*0.95*0.5}},
			[3]={{1,60*1*0.5},{30,200*1.05*0.5}}
			},
	--	state_hurt_attack={50,5,0},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,3},{30,3}}},  
    },

    newrole_em_pg4 = --峨眉剑法4
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_slowall_attack={{{1,80},{30,80}},{{1,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={80,10},
		missile_hitcount={{{1,4},{30,4}}},   
    },
 
    newrole_em_jhnb = --江海凝波-1级主动1
    { 
		userdesc_000={2120},
    },
    newrole_em_jhnb_child = --江海凝波_子
    { 
		state_slowall_attack={{{1,30},{30,30}},{{1,15*1.5},{30,15*1.5}}},
		attack_usebasedamage_p={{{1,1600},{30,2200}}},
		attack_waterdamage_v={
			[1]={{1,100*0.9},{30,600*0.9}},
			[3]={{1,100*1.1},{30,600*1.1}}
			},
    },
    newrole_em_blns = --白露凝霜-5级主动2
    { 
		attack_usebasedamage_p={{{1,2800},{30,4000}}},
		attack_waterdamage_v={
			[1]={{1,300*0.9},{30,600*0.9}},
			[3]={{1,300*1.1},{30,600*1.1}}
			},
		state_slowall_attack={{{1,40},{30,40}},{{1,15*2},{30,15*2}}},
		missile_hitcount={{{1,3},{30,3}}},
    },
    newrole_em_blns_child = --白露凝霜_子
    { 
		attack_usebasedamage_p={{{1,2800},{30,4000}}},
		attack_waterdamage_v={
			[1]={{1,300*0.9},{30,600*0.9}},
			[3]={{1,300*1.1},{30,600*1.1}}
			},
		state_slowall_attack={{{1,40},{30,40}},{{1,15*2},{30,15*2}}},
		missile_hitcount={{{1,5},{30,5}}},
    },
	newrole_em_chpd = --慈航普度-10级主动3
	{ 
	 	userdesc_000={2117},
		missile_hitcount={{{1,1},{30,1}}}, 
	},	
	newrole_em_chpd_child = --慈航普度_子
	{ 
	 	recover_life_v={{{1,2000},{30,4000}},15},
		skill_statetime={{{1,15*5},{30,15*5}}},
	},	
    newrole_em_twbl = --天舞宝轮-30级主动4
    { 
		recover_life_v={{{1,2000},{30,4000}},15},
		skill_statetime={{{1,20},{30,20}}},
		userdesc_000={2122},
    },
    newrole_em_twbl_child = --天舞宝轮_子
    { 
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_waterdamage_v={
			[1]={{1,80*0.9},{30,200*0.9}},
			[3]={{1,80*1.1},{30,200*1.1}}
			},
		state_slowall_attack={{{1,70},{30,70}},{{1,15*3},{30,15*3}}},
    },
    newrole_th_pg1 = --桃花箭术1-普攻1式
    { 
		attack_usebasedamage_p={{{1,1200},{30,1800}}},
		attack_firedamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_npchurt_attack={100,9},
	--	state_hurt_attack={20,15*0.3,0}, 
		missile_hitcount={{{1,1},{30,1}}},  
		attack_attackrate_v={{{1,100},{30,100}}},
    }, 
    newrole_th_pg2 = --桃花箭术2-普攻2式
    { 
		attack_usebasedamage_p={{{1,1200},{30,1800}}},
		attack_firedamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_npchurt_attack={100,9},
	--	state_hurt_attack={40,4,0}, 
		missile_hitcount={{{1,2},{30,2}}},
		attack_attackrate_v={{{1,100},{30,100}}},
    }, 
    newrole_th_pg3 = --桃花箭术3-普攻3式
    {  
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_npchurt_attack={100,9},
	--	state_hurt_attack={80,5,0},
		missile_hitcount={{{1,3},{30,3}}},
		attack_attackrate_v={{{1,100},{30,100}}},
    }, 
    newrole_th_pg4 = --桃花箭术4-普攻4式
    {  
		attack_usebasedamage_p={{{1,1800},{30,3000}}},
		attack_firedamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_npchurt_attack={100,9},
		state_palsy_attack={{{1,80},{30,80}},{{1,15*0.5},{30,15*0.5}}},
		missile_hitcount={{{1,3},{30,3}}},
		attack_attackrate_v={{{1,100},{30,100}}},
    }, 
    newrole_th_fhlx = --飞火流星-1级主动1 
    { 
		attack_usebasedamage_p={{{1,4000},{30,6000}}},
		attack_firedamage_v={
			[1]={{1,200*0.95},{30,600*0.95}},
			[3]={{1,200*1.05},{30,600*1.05}}
			},
		state_knock_attack={40,12,30},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 9},
		state_palsy_attack={{{1,100},{30,100},{31,100}},{{1,15*1.5},{30,15*1.5}}},
    },	
	newrole_th_hfly = --火凤燎原-5级主动2
    { 
		runspeed_v={{{1,100},{30,200}}},
		attackspeed_v={{{1,20},{30,50}}},
		defense_p={{{1,50},{30,100}}},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
	newrole_th_jylz_root= --九曜连珠-10级主动3
	{ 
		userdesc_000={2131},
    },
	
    newrole_th_jylz = --九曜连珠-10级主动3
    { 
		attack_usebasedamage_p={{{1,900},{30,1400}}},
		attack_firedamage_v={
			[1]={{1,120*0.95},{30,180*0.95}},
			[3]={{1,120*1.05},{30,180*1.05}}
			},
		state_palsy_attack={{{1,10},{30,10}},{{1,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={100,9},
    },
	newrole_th_cypy_root= --穿云破月-30级主动4
	{ 
		userdesc_000={2136},
    },
    newrole_th_cypy = --穿云破月-30级主动4
    { 
		attack_usebasedamage_p={{{1,7200},{30,8800}}},
		attack_firedamage_v={
			[1]={{1,1000*0.9},{30,1600*0.9}},
			[3]={{1,1000*1.1},{30,1600*1.1}}
			},
	--	state_palsy_attack={{{1,100},{30,100},{31,100}},{{1,15*1},{30,15*1}}},

		state_knock_attack={30,12,30},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 26},
		missile_hitcount={{{1,4},{30,4}}},
    },

    newrole_xy_qf1 = --逍遥枪法-普攻1式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1800}}},
		attack_wooddamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},	
		state_zhican_attack={{{1,30},{30,30}},{{1,4},{30,4}}},
		state_npchurt_attack={100,9},
	
    }, 
    newrole_xy_qf2 = --逍遥枪法-普攻2式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1800}}},
		attack_wooddamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_zhican_attack={{{1,50},{30,50}},{{1,4},{30,4}}},
		state_npchurt_attack={100,9},
			
    }, 
    newrole_xy_qf3 = --逍遥枪法-普攻3式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1400},{30,1800}}},
		attack_wooddamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_zhican_attack={{{1,80},{30,80}},{{1,6},{30,6}}},

		state_npcknock_attack={100,9,20},
		spe_knock_param={6 , 4, 9},
    }, 
    newrole_xy_qf4 = --逍遥枪法-普攻4式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1800},{30,2800}}},
		attack_wooddamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_zhican_attack={{{1,100},{30,100}},{{1,6},{30,6}}},	
		
		state_npcknock_attack={100,12,20},
		spe_knock_param={9 , 4, 26},

    }, 
    newrole_xy_bhgr = --白虹贯日-1级主动
    { 
		userdesc_000={2148},
    },
    newrole_xy_bhgr_child1 = --白虹贯日_子1
    { 
		attack_usebasedamage_p={{{1,3000},{30,4000}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
    },
    newrole_xy_bhgr_child2 = --白虹贯日_子2
    { 
		addpowerwhencol={511,{{1,25},{30,50},{31,50}},{{1,50},{30,150},{31,150}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },	
    newrole_xy_qtsp = --七探蛇盘-5级主动2
    { 
		userdesc_000={2144},
    },
    newrole_xy_qtsp_child = --七探蛇盘_子
    { 
		attack_usebasedamage_p={{{1,2900},{30,3300}}},
		attack_wooddamage_v={
			[1]={{1,150*0.9},{30,400*0.9}},
			[3]={{1,150*1.1},{30,400*1.1}}
			},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		state_npchurt_attack={100,6},
    },
	newrole_xy_dzxy = --斗转星移-10级主动3
    { 
		attack_usebasedamage_p={{{1,4800},{30,6000}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
		state_drag_attack={{{1,100},{30,100}},8,70},
		skill_drag_npclen={70},
    },
	newrole_xy_dzxy_child = --斗转星移_子
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
    newrole_xy_fjcy = --风卷残云-30级主动4
    { 
		dotdamage_wood={{{1,1000},{30,1400}},{{1,150},{30,350}},{{1,5},{30,5}}},
		state_float_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
		--missile_hitcount={{{1,3},{30,3}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    newrole_wd_pg1 = --武当剑法-普攻1式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_stun_attack={{{1,30},{30,30}},{{1,4},{30,4}}},
		state_npchurt_attack={100,9},
    }, 
    newrole_wd_pg2 = --武当剑法-普攻2式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_stun_attack={{{1,50},{30,50}},{{1,4},{30,4}}},
    }, 	
    newrole_wd_pg3 = --武当剑法-普攻3式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_stun_attack={{{1,80},{30,80}},{{1,6},{30,6}}},	
    }, 	
    newrole_wd_pg4 = --武当剑法-普攻4式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1600},{30,2400}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,6},{30,6}}},
    }, 
    newrole_wd_jfjt = --剑飞惊天-1级主动1
    { 
		attack_usebasedamage_p={{{1,3600},{30,5000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},				
    }, 
	newrole_wd_rjhy = --人剑合一-4级主动2
    { 
		userdesc_000={2164},	
    }, 
	newrole_wd_rjhy_child = --人剑合一-4级主动2
    { 
		attack_usebasedamage_p={{{1,4000},{30,6000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_knock_attack={30,12,30},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 26},
    }, 	
	newrole_wd_zwww = --坐忘无我-10级主动3
    { 
		magicshield={{{1,2000},{30,6000}},{{1,15*15},{30,15*15}}},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={{{1,15*15},{30,15*15}}},		
    },
    newrole_wd_tdwj = --天地无极-30级主动4
    { 
		attack_usebasedamage_p={{{1,7200},{30,8800}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,6},{30,6}}},
    },
    newrole_tr_pg1 = --天忍刺杀术1--普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{60,160}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,30*1},{20,150*0.95},{60,270*0.95}},
			[3]={{1,30*1},{20,150*1.05},{60,270*1.05}}
			},
		state_palsy_attack={{{1,30},{20,30}},{{1,4},{20,4}}},
		state_npcknock_attack={100,7,20},	
		spe_knock_param={6 , 4, 9},

    }, 
    newrole_tr_pg2 = --天忍刺杀术2--普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{60,160}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,30*1},{20,150*0.95},{60,270*0.95}},
			[3]={{1,30*1},{20,150*1.05},{60,270*1.05}}
			},
		state_palsy_attack={{{1,50},{20,50}},{{1,4},{20,4}}},
		state_npcknock_attack={100,7,40},	
		spe_knock_param={6 , 4, 9},

    }, 	
    newrole_tr_pg3 = --天忍刺杀术3--普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{60,160}}},
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,80*1},{20,200*0.95},{60,300*0.95}},
			[3]={{1,80*1},{20,200*1.05},{60,300*1.05}}
			},
		state_palsy_attack={{{1,80},{20,80}},{{1,6},{20,6}}},
		
		state_npcknock_attack={100,7,45},
		spe_knock_param={6 , 4, 9},
	
    }, 	
    newrole_tr_pg4 = --天忍刺杀术4--普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{60,160}}},
		attack_usebasedamage_p={{{1,1600},{30,2400}}},
		attack_firedamage_v={
			[1]={{1,90*1},{20,350*0.95},{60,420*0.95}},
			[3]={{1,90*1},{20,350*1.05},{60,420*1.05}}
			},
		state_palsy_attack={{{1,100},{20,100}},{{1,6},{20,6}}},
		
		state_npcknock_attack={100,14,35},
		spe_knock_param={11 , 4, 26},
    }, 
    newrole_tr_myzt = --魔焰在天-1级主动1--10级
    { 
		userdesc_000={2174},			
		keephide={},
		ms_one_hit_count = {0,0,1},				--每次攻击最大数量
		ms_hit_finish_vanish={},			--击中完后子弹就消失
		ms_vanish_remove_buff={2173},		--子弹消失后，清掉BUFF
		missile_hitcount={0,0,6},
    }, 
    newrole_tr_myzt_child2 = --魔焰在天_子2--10级
    { 
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,50*1},{10,100*0.95},{60,270*0.95}},
			[3]={{1,50*1},{10,100*1.05},{60,270*1.05}}
			},
		state_npchurt_attack={100,10}, 
		state_burn_attack={{{1,100},{10,100}},{{1,15*5},{10,15*5}},10},  --概率，持续时间，叠加百分比
		missile_hitcount={{{1,1},{10,1}},{{1,1},{10,1}}}, 	
    }, 
    newrole_tr_swhx = --死亡回旋-4级主动2--10级
    { 
		userdesc_000={2176},	
    }, 
    newrole_tr_swhx_child = --死亡回旋_子--10级
    { 
		attack_usebasedamage_p={{{1,2600},{30,4200}}},
		attack_firedamage_v={
			[1]={{1,200*1},{10,400*0.95}},
			[3]={{1,200*1},{10,400*1.05}}
			},
		state_npchurt_attack={100,10}, 
    }, 
    newrole_tr_xyzy = --血月之影-10级主动3--15级
    { 
		keephide={},
		runspeed_v={{{1,100},{15,200}}},
		hide={{{1,15*15},{15,15*20}},1},				--参数1时间，参数2：队友1，同阵营2
		autoskill={74,{{1,1},{15,15}}},	
		skill_statetime={{{1,15*15},{15,15*20}}},
    }, 
    newrole_tr_xyzy_child1 = --血月之影_破隐普攻加成buff--15级
    { 
		ignore_defense_v={{{1,100},{15,200}}},
		attackspeed_v={{{1,20},{15,50}}},
		deadlystrike_v={{{1,50},{15,100}}},
		--physics_potentialdamage_p={{{1,100},{15,300}}},
		link_skill_buff={},				--连招内保持当前加成BUFF的魔法属性
		addaction_event1={2168,2179},		
		addaction_event2={2169,2180},		
		addaction_event3={2170,2181},		
		addaction_event4={2171,2182},		
		skill_statetime={{{1,15*4},{15,15*4}}},
    },
    newrole_tr_xyzy_gongji1 = --血月之影_攻击1--15级
    { 
		attack_attackrate_v={{{1,100},{15,100},{60,160}}},
		attack_usebasedamage_p={{{1,1600},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,150*1},{15,150*0.95},{60,270*0.95}},
			[3]={{1,150*1},{15,150*1.05},{60,270*1.05}}
			},
		state_palsy_attack={{{1,30},{15,30}},{{1,4},{15,4}}},
		state_npcknock_attack={100,7,20},	
		spe_knock_param={6 , 4, 9},
    }, 
    newrole_tr_xyzy_gongji2 = --血月之影_攻击2--15级
    { 
		attack_attackrate_v={{{1,100},{15,100},{60,160}}},
		attack_usebasedamage_p={{{1,1600},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,150*1},{15,150*0.95},{60,270*0.95}},
			[3]={{1,150*1},{15,150*1.05},{60,270*1.05}}
			},
		state_palsy_attack={{{1,50},{15,50}},{{1,4},{15,4}}},
		state_npcknock_attack={100,7,80},	
		spe_knock_param={6 , 4, 9},

    }, 	
    newrole_tr_xyzy_gongji3 = --血月之影_攻击3--15级
    { 
		attack_attackrate_v={{{1,100},{15,100},{60,160}}},
		attack_usebasedamage_p={{{1,1600},{30,1600}}},
		attack_firedamage_v={
			[1]={{1,200*1},{15,200*0.95},{60,300*0.95}},
			[3]={{1,200*1},{15,200*1.05},{60,300*1.05}}
			},
		state_palsy_attack={{{1,80},{15,80}},{{1,6},{15,6}}},
		
		state_npcknock_attack={100,7,90},
		spe_knock_param={6 , 4, 9},

	
    }, 	
    newrole_tr_xyzy_gongji4 = --血月之影_攻击4--15级
    { 
		attack_attackrate_v={{{1,100},{15,100},{60,160}}},
		attack_usebasedamage_p={{{1,3000},{30,3000}}},
		attack_firedamage_v={
			[1]={{1,350*1},{15,350*0.95},{60,420*0.95}},
			[3]={{1,350*1},{15,350*1.05},{60,420*1.05}}
			},
		state_palsy_attack={{{1,100},{15,100}},{{1,6},{15,6}}},
		
		state_npcknock_attack={100,14,80},
		spe_knock_param={11 , 4, 26},

    },	
    newrole_tr_shlx = --摄魂乱心-30级主动4--15级
    { 
		userdesc_000={2184},	
    }, 	
    newrole_tr_shlx_child = --摄魂乱心_子--15级
    { 
		attack_usebasedamage_p={{{1,2400},{30,3000}}},
		attack_firedamage_v={
			[1]={{1,100*1},{15,300*0.95}},
			[3]={{1,100*1},{15,300*1.05}}
			},
		state_confuse_attack={{{1,30},{15,60}},{{1,15*2},{15,15*2}}},		
		state_drag_attack={{{1,30},{15,60}},8,30},		
		skill_drag_npclen={0},
		state_npchurt_attack={100,10}, 
    },
    newrole_sl_pg1 = --少林棍法--普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,160}}},
		attack_usebasedamage_p={{{1,1000},{20,1600},{30,2200}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,270*1.05}}
			},
		state_npcknock_attack={100,7,25},	
		spe_knock_param={6 , 4, 9},

    }, 
    newrole_sl_pg2 = --少林棍法--普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,160}}},
		attack_usebasedamage_p={{{1,1000},{20,1600},{30,2200}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,270*1.05}}
			},
		state_hurt_attack={{{1,40},{20,40},{30,40}},{{1,4},{20,4},{30,4}}},
		
		state_npcknock_attack={100,7,45},	
		spe_knock_param={6 , 4, 9},
    }, 
	
    newrole_sl_pg3 = --少林棍法--普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,160}}},
		attack_usebasedamage_p={{{1,1000},{20,1600},{30,2200}}},
		attack_metaldamage_v={
			[1]={{1,60*1},{20,180*0.95},{30,300*0.95}},
			[3]={{1,60*1},{20,180*1.05},{30,300*1.05}}
			},
		state_hurt_attack={{{1,60},{20,60},{30,60}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,7,35},	
		spe_knock_param={6 , 4, 9},
	
    }, 	
    newrole_sl_pg4 = --少林棍法--普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,160}}},
		attack_usebasedamage_p={{{1,1600},{20,2400},{30,3000}}},
		attack_metaldamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_hurt_attack={{{1,100},{20,100},{30,100}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
    }, 
    newrole_sl_xlg = --降龙棍--1级主动1--15级
    { 
		attack_usebasedamage_p={{{1,2600},{30,4200}}},
		attack_metaldamage_v={
			[1]={{1,150*0.95},{15,600*0.95}},
			[3]={{1,150*1.05},{15,600*1.05}}
			},
		state_hurt_attack={{{1,100},{15,100}},{{1,15*1},{15,15*1}}},

		state_npcknock_attack={100,14,35},			--概率，时间，速度
		spe_knock_param={11 , 4, 26},				--停留时间，玩家动作，npc动作
		spe_knock_param1={1},
    },
    newrole_sl_dljgz = --大力金刚指--4级主动2--15级
    { 
		attack_usebasedamage_p={{{1,3200},{30,4200}}},
		attack_metaldamage_v={
			[1]={{1,150*0.95},{15,600*0.95}},
			[3]={{1,150*1.05},{15,600*1.05}}
			},
		state_hurt_attack={{{1,70},{15,90}},{{1,15*2},{15,15*2}}},				
		state_fixed_attack={{{1,100},{15,100}},{{1,15*1},{15,15*1}}},
		
		state_npcknock_attack={100,7,35},
		missile_hitcount={0,0,1},				--子弹最多打多少人
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
    },
	newrole_sl_jgfm = --金刚伏魔-10级主动3--15级
    { 
		defuse_damage={{{1,100},{10,300}},30},
		ignore_abnor_state={},
		skill_statetime={{{1,15*15},{15,15*15}}},
    },
    newrole_sl_seqls = --十二擒龙手--30级主动4--15级
    { 
		attack_usebasedamage_p={{{1,3600},{30,4200}}},
		attack_metaldamage_v={
			[1]={{1,300*1},{15,450*0.95}},
			[3]={{1,300*1},{15,450*1.05}}
			},
		state_drag_attack={{{1,100},{15,100}},8,70},
		skill_drag_npclen={90},
		state_fixed_attack={{{1,100},{15,100}},{{1,15*2},{15,15*2}}},
    }, 
    newrole_cy_pg1 = --翠烟御伞诀1--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{20,2}}},  
    }, 
 
    newrole_cy_pg2 = --翠烟御伞诀2--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{20,2}}},  
    },

    newrole_cy_pg3 = --翠烟御伞诀3--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
	--	state_hurt_attack={50,5,0},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,3},{20,3}}},  
    },

    newrole_cy_pg4 = --翠烟御伞诀4--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,2000},{20,3000},{30,2600}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_slowall_attack={{{1,80},{20,80},{30,80}},{{1,15*0.5},{20,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={80,6},
		missile_hitcount={{{1,4},{20,4}}},  
    }, 
    newrole_cy_tlxj = --璇玑罗舞-1级主动1--15级
    { 
		attack_usebasedamage_p={{{1,1400},{15,2200}}},
		attack_waterdamage_v={
			[1]={{1,80*0.9},{15,400*0.9}},
			[3]={{1,80*1.1},{15,400*1.1}}
			},
		userdesc_000={807},
    },
    newrole_cy_tlxj_child1 = --璇玑罗舞_子1--15级
    { 
		state_slowall_attack={{{1,30},{15,30}},{{1,15*1},{15,15*1}}},
		attack_usebasedamage_p={{{1,1400},{15,2200}}},
		attack_waterdamage_v={
			[1]={{1,80*0.9},{15,400*0.9}},
			[3]={{1,80*1.1},{15,400*1.1}}
			},
    },
    newrole_cy_tlxj_child2 = --璇玑罗舞_子2--15级
    { 
		state_knock_attack={100,5,70},				--几率，时间，速度
		state_npcknock_attack={100,5,70},			--几率，时间，速度 
		spe_knock_param={3 , 4, 9},					--停留时间，玩家动作ID，NPC动作ID
    },
    newrole_cy_ydlh = --雨打梨花-4级主动2--10级
    { 
		userdesc_000={829},
    },
    newrole_cy_ydlh_child1 = --雨打梨花1倍伤害--10级
    { 
		attack_usebasedamage_p={{{1,600},{10,1200}}},
		attack_waterdamage_v={
			[1]={{1,70*0.9},{10,200*0.9}},
			[3]={{1,70*1.1},{10,200*1.1}}
			},
		state_slowall_attack={{{1,70},{10,70}},{{1,15*1},{10,15*1}}},
    },    
	newrole_cy_ydlh_child2 = --雨打梨花2倍伤害--10级
    { 
		attack_usebasedamage_p={{{1,800},{10,1600}}},
		attack_waterdamage_v={
			[1]={{1,70*0.9},{10,200*0.9}},
			[3]={{1,70*1.1},{10,200*1.1}}
			},
		state_slowall_attack={{{1,70},{10,70}},{{1,15*1},{10,15*1}}},
    },	
	newrole_cy_ydlh_child3 = --雨打梨花3倍伤害--10级
    { 
		attack_usebasedamage_p={{{1,1800},{10,3600}}},
		attack_waterdamage_v={
			[1]={{1,70*0.9},{10,200*0.9}},
			[3]={{1,70*1.1},{10,200*1.1}}
			},
		state_slowall_attack={{{1,70},{10,70}},{{1,15*1},{10,15*1}}},
    },
	newrole_cy_zh = --召唤-10级主动3--15级
    { 
		call_npc1={1827, -1, 3},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={1827},
		userdesc_000={811},
		skill_statetime={{{1,15*15},{10,15*15},{11,15*15}}},
    },	
	newrole_cy_zh_child = --召唤_子--15级
    { 
	 	callnpc_life={1827,{{1,1000},{15,3000}}},				--NPCid，生命值%
	 	callnpc_damage={1827,{{1,1000},{15,3000}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},
    },
    newrole_cy_xm_normal = --熊猫-普攻
    { 
		attack_usebasedamage_p={100},
		attack_waterdamage_v={
			[1]={{1,200*0.9},{10,200*0.9}},
			[3]={{1,200*1.1},{10,200*1.1}}
			},
		state_slowall_attack={80,15*0.5},			--概率，持续时间
		missile_hitcount={{{1,4},{20,4}}},  
    },
    newrole_cy_xm_chong = --熊猫-冲
    { 
		attack_usebasedamage_p={200},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },	
    newrole_cy_bzwy = --冰踪无影-30级主动4--15级
    { 
	 	userdesc_000={817},
		state_freeze_attack={{{1,10},{10,50}},{{1,15*1},{10,15*1.5}}},
		missile_hitcount={{{1,1},{15,1}}},
    },
    newrole_cy_bzwy_child = --冰踪无影_子--15级
    { 
		attack_usebasedamage_p={{{1,2800},{15,4400}}},
		attack_waterdamage_v={
			[1]={{1,300*0.9},{15,800*0.9}},
			[3]={{1,300*1.1},{15,800*1.1}}
			},
		missile_hitcount={{{1,3},{15,3}}},
    },
    newrole_tm_pg1 = --唐门暗器-普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,2500}}},
		attack_wooddamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,270*0.95},{32,294*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,270*1.05},{32,294*1.05}}
			},	
		state_npchurt_attack={100,7},
    }, 
    newrole_tm_pg2 = --唐门暗器-普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,2500}}},
		attack_wooddamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,270*0.95},{32,294*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,270*1.05},{32,294*1.05}}
			},	
		state_npchurt_attack={100,7},	
    }, 
    newrole_tm_pg3 = --唐门暗器-普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1400},{30,2600}}},
		attack_wooddamage_v={
			[1]={{1,60*1},{20,180*0.95},{30,300*0.95},{32,324*0.95}},
			[3]={{1,60*1},{20,180*1.05},{30,300*1.05},{32,324*1.05}}
			},
		state_npchurt_attack={100,7},
    }, 
    newrole_tm_pg4 = --唐门暗器-普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1800},{30,3800}}},
		attack_wooddamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95},{32,444*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05},{32,444*1.05}}
			},
		state_zhican_attack={{{1,40},{20,40},{30,40},{32,40}},{{1,15*0.5},{20,15*0.5},{30,15*0.5},{32,15*0.5}}},
		state_npchurt_attack={100,7},
    }, 
    newrole_tm_dgc = --毒骨刺-1级主动--10级
    { 
		userdesc_000={4007},
    },
    newrole_tm_dgc_child = --毒骨刺_子
    { 
		attack_usebasedamage_p={{{1,3000},{30,4800}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{15,700*0.9},{16,735*0.9}},
			[3]={{1,200*1.1},{15,700*1.1},{16,735*1.1}}
			},
		state_zhican_attack={{{1,100},{15,100},{16,100}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},
    },
    newrole_tm_bylh = --暴雨梨花--10级
    { 
		attack_usebasedamage_p={{{1,2400},{30,3600}}},
		attack_wooddamage_v={
			[1]={{1,150*0.9},{15,500*0.95},{16,525*0.95}},
			[3]={{1,150*1.1},{15,500*1.05},{16,525*1.05}}
			},
		state_npchurt_attack={100,6},	
    },	
    newrole_tm_bylh_child = --暴雨梨花_子
    { 
		attack_usebasedamage_p={{{1,2400},{30,3600}}},
		attack_wooddamage_v={
			[1]={{1,150*0.9},{15,500*0.95},{16,525*0.95}},
			[3]={{1,150*1.1},{15,500*1.05},{16,525*1.05}}
			},
		state_npchurt_attack={100,6},
    },
	newrole_tm_myz = --迷影纵-10级主动3--15级
    { 
		skill_mintimepercast_v={{{1,15*15},{15,10*15},{16,10*15}}},
    },
    newrole_tm_jgfx = --九宫飞星-30级主动4--15级
    { 
		userdesc_000={4013},	
    },	
    newrole_tm_jgfx_child = --九宫飞星_子
    { 
		attack_usebasedamage_p={{{1,1000},{30,1500}}},
		attack_wooddamage_v={
			[1]={{1,150*0.9},{15,500*0.95},{16,525*0.95}},
			[3]={{1,150*1.1},{15,500*1.05},{16,525*1.05}}
			},
		state_zhican_attack={{{1,50},{15,50},{16,50}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},
		spe_knock_param1={1},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		missile_hitcount={1,1,1},
    },
    newrole_kl_pg1 = --昆仑剑法--普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,330*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,330*1.05}}
			},
		state_stun_attack={{{1,30},{20,30},{30,30},{32,30}},{{1,4},{20,4},{30,4},{32,4}}},
		state_npcknock_attack={100,7,50},	
		spe_knock_param={6 , 4, 9},
    }, 
    newrole_kl_pg2 = --昆仑剑法--普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,330*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,330*1.05}}
			},
		state_stun_attack={{{1,40},{20,40},{30,40},{32,40}},{{1,4},{20,4},{30,4},{32,4}}},
		state_npcknock_attack={100,7,40},	
		spe_knock_param={6 , 4, 9},	
    }, 
	
    newrole_kl_pg3 = --昆仑剑法--普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,1300},{30,2600}}},
		attack_earthdamage_v={
			[1]={{1,60*1},{20,200*0.95},{30,350*0.95},{32,380*0.95}},
			[3]={{1,60*1},{20,200*1.05},{30,350*1.05},{32,380*1.05}}
			},
		state_stun_attack={{{1,60},{20,60},{30,60},{32,60}},{{1,4},{20,4},{30,4},{32,4}}},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},	
    }, 	
    newrole_kl_pg4 = --昆仑剑法--普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
		attack_usebasedamage_p={{{1,2000},{30,4000}}},
		attack_earthdamage_v={
			[1]={{1,100*1},{20,350*0.95},{30,500*0.95},{32,530*0.95}},
			[3]={{1,100*1},{20,350*1.05},{30,500*1.05},{32,530*1.05}}
			},
		state_stun_attack={{{1,100},{20,100},{30,100},{32,100}},{{1,6},{20,6},{30,6},{32,6}}},
		spe_knock_param1={1},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
    }, 
    newrole_kl_xrzl = --仙人指路-1级主动1--10级
    { 
		userdesc_000={4107},			
    }, 
    newrole_kl_xrzl_child = --仙人指路_子
    { 
		attack_usebasedamage_p={{{1,4800},{30,6000}}},
		attack_earthdamage_v={
			[1]={{1,200*1},{15,500*0.95},{16,520*0.95}},
			[3]={{1,200*1},{15,500*1.05},{16,520*1.05}}
			},
		state_stun_attack={{{1,100},{15,100},{16,100}},{{1,15*1},{15,15*1},{16,15*1}}},
		state_npcknock_attack={100,15,20},
		spe_knock_param={9 , 4, 26},
		missile_hitcount={{{1,6},{15,6},{16,6}}},		
    },
    newrole_kl_hdjz = --混沌剑阵-4级主动2--15级
    { 
		userdesc_000={4109},			
    },  
    newrole_kl_hdjz_child = --混沌剑阵_子
    { 
		attack_usebasedamage_p={{{1,800},{30,1000}}},
		attack_earthdamage_v={
			[1]={{1,600*1},{15,800*0.95},{16,814*0.95}},
			[3]={{1,600*1},{15,800*1.05},{16,814*1.05}}
			},
		state_npchurt_attack={{{1,100},{15,100},{16,100}},{{1,6},{15,6},{16,6}}},
		missile_hitcount={{{1,6},{15,6},{16,6}}},
    },     
	newrole_kl_xfsl = --啸风三连-10级主动3--15级
    { 
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,600*1},{15,800*0.95},{16,814*0.95}},
			[3]={{1,600*1},{15,800*1.05},{16,814*1.05}}
			},
		state_stun_attack={{{1,50},{15,80},{16,83}},{{1,15*1},{15,15*3},{16,15*3}}},
		state_knock_attack={100,7,50},
		state_npcknock_attack={100,7,50},	
		spe_knock_param={6 , 4, 9},
		skill_statetime={{{1,15*3},{15,15*3},{16,15*3}}},
		missile_hitcount={{{1,3},{15,3},{16,3}}}, 
    },
	newrole_kl_ldjt = --雷动九天-30级主动4--15级
    { 
		userdesc_000={3424},
		missile_hitcount={1,1,1},	
		attack_usebasedamage_p={{{1,3000},{30,5000}}},
		attack_earthdamage_v={
			[1]={{1,300*1},{15,800*1},{16,850*1}},
			[3]={{1,300*1},{15,800*1},{16,850*1}}
			},
		state_stun_attack={{{1,100},{15,100},{16,100}},{{1,15*1},{15,15*1.5},{16,15*1.5}}},
    }, 
	newrole_kl_ldjt_child = --雷动九天2轮-30级主动4--15级
    { 
		ms_one_hit_count = {0,0,1},															--每次攻击最大数量
		ms_powerwhencol={{{1,20},{30,20}},{{1,100},{30,100}}},  		--参数1：每次增加伤害，参数2：增加上限
		attack_usebasedamage_p={{{1,3100},{30,5100}}},
		attack_earthdamage_v={
			[1]={{1,300*1},{15,800*1},{16,850*1}},
			[3]={{1,300*1},{15,800*1},{16,850*1}}
			},
    }, 
    newrole_gb_pg1 = --丐帮棍法1-普攻1式--20级
    { 
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_firedamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,400*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,400*1.05}}
			},
		state_npchurt_attack={100,7}, 
		state_palsy_attack={{{1,30},{20,30},{30,30},{32,30}},{{1,4},{20,4},{30,4},{32,4}}},
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
    }, 
    newrole_gb_pg2 = --丐帮棍法2-普攻2式--20级
    { 
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_firedamage_v={
			[1]={{1,30*1},{20,150*0.95},{30,300*0.95},{32,400*0.95}},
			[3]={{1,30*1},{20,150*1.05},{30,300*1.05},{32,400*1.05}}
			},
		state_npchurt_attack={100,7},
		state_palsy_attack={{{1,40},{20,40},{30,40},{32,40}},{{1,4},{20,4},{30,4},{32,4}}},
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
    }, 
    newrole_gb_pg3 = --丐帮棍法3-普攻3式--20级
    {  
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_firedamage_v={
			[1]={{1,60*1},{20,180*0.95},{30,350*0.95},{32,400*0.95}},
			[3]={{1,60*1},{20,180*1.05},{30,350*1.05},{32,400*1.05}}
			},
		state_npchurt_attack={100,7},
		state_palsy_attack={{{1,60},{20,60},{30,60},{32,60}},{{1,6},{20,6},{30,6},{32,6}}},
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
    }, 
    newrole_gb_pg4 = --丐帮棍法4-普攻4式--20级
    {  
		attack_usebasedamage_p={{{1,1200},{30,2400}}},
		attack_firedamage_v={
			[1]={{1,60*1},{20,180*0.95},{30,350*0.95},{32,400*0.95}},
			[3]={{1,60*1},{20,180*1.05},{30,350*1.05},{32,400*1.05}}
			},
		state_npchurt_attack={100,7},
		state_palsy_attack={{{1,60},{20,60},{30,60},{32,60}},{{1,6},{20,6},{30,6},{32,6}}},
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
    },
    newrole_gb_pg5 = --丐帮棍法5-普攻5式--20级
    {  
		attack_usebasedamage_p={{{1,1800},{30,3000}}},
		attack_firedamage_v={
			[1]={{1,90*1},{20,350*0.95},{30,500*0.95},{32,600*0.95}},
			[3]={{1,90*1},{20,350*1.05},{30,500*1.05},{32,600*1.05}}
			},
		state_npchurt_attack={100,7},
		state_palsy_attack={{{1,100},{20,100},{30,100},{32,100}},{{1,10},{20,10},{30,10},{32,10}}},
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
    }, 
    newrole_gb_klyh = --亢龙有悔-1级主动1 --15级
    { 
		attack_usebasedamage_p={{{1,3200},{30,4000}}},
		attack_firedamage_v={
			[1]={{1,300*0.95},{15,500*0.95},{16,550*0.95}},
			[3]={{1,300*1.05},{15,500*1.05},{16,550*1.05}}
			},
		state_palsy_attack={{{1,100},{15,100},{16,100}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},
		skill_point={{{1,200},{7,200},{8,300},{10,300},{11,400},{13,400},{14,400},{15,500},{16,500}},{{1,100},{15,100},{16,100}}}, 		--参数1/100：叠加次数，参数2/100：每次CD回复的次数
    },
    newrole_gb_klg = --困龙功-4级主动2--15级
    { 
		userdesc_000={4209},
    }, 	
    newrole_gb_klg_child = --困龙功_子--15级
    { 
		attack_usebasedamage_p={{{1,2400},{30,6000}}},
		attack_firedamage_v={
			[1]={{1,500*1},{15,800*0.95},{16,900*0.95}},
			[3]={{1,500*1},{15,800*1.05},{16,900*1.05}}
			},
		state_palsy_attack={{{1,50},{15,70},{16,80}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},	
		state_fixed_attack={{{1,50},{15,70},{16,80}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},	
		state_npchurt_attack={100,10}, 
		missile_hitcount={{{1,6},{15,6},{16,6}}},
    }, 
    newrole_gb_zdkw = --醉蝶狂舞-10级主动3--15级
    { 
		runspeed_v={{{1,100},{15,200},{16,210}}},
		defense_p={{{1,1500},{15,2000},{16,2200}}},
		skill_statetime={{{1,15*10},{15,15*10},{16,15*10}}},
    },
    newrole_gb_lzyy = --龙战于野-30级主动4--15级
    { 
		userdesc_000={4214},
		skill_mintimepercast_v={{{1,45*15},{15,40*15},{16,40*15}}},
    }, 	
    newrole_gb_lzyy_child1 = --龙战于野_子1（群攻）--15级
    { 
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_firedamage_v={
			[1]={{1,600*1},{15,1000*0.95},{16,1200*0.95}},
			[3]={{1,600*1},{15,1000*1.05},{16,1200*1.05}}
			},
		dotdamage_maxlife_p={{{1,1},{30,6}},15,30000},			--掉血百分比，debuff每间隔帧掉血，每次掉血上限
		state_palsy_attack={{{1,15},{15,30},{16,31}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},	
		state_npchurt_attack={100,10}, 
		skill_statetime={{{1,1},{30,1}}},								--debuff持续时间 填的短代表只掉血1次
		missile_hitcount={{{1,6},{15,6},{16,6}}},
    }, 
    newrole_gb_lzyy_child3 = --龙战于野_子3--15级
    { 
		missile_hitcount={0,0,1},
    },
    newrole_gb_lzyy_child4 = --龙战于野_子4（单体）--15级
    { 
		attack_usebasedamage_p={{{1,2400},{30,3200}}},
		attack_firedamage_v={
			[1]={{1,100*1},{15,400*0.95},{16,420*0.95}},
			[3]={{1,100*1},{15,400*1.05},{16,420*1.05}}
			},
		dotdamage_maxlife_p={{{1,1},{30,6}},15,30000},			--掉血百分比，debuff每间隔帧掉血，每次掉血上限
		state_palsy_attack={{{1,15},{15,30},{16,31}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},	
		state_npchurt_attack={100,10}, 
		skill_statetime={{{1,1},{30,1}}},								--debuff持续时间 填的短代表只掉血1次
		missile_hitcount={0,0,1},
    }, 
    newrole_wudu_pg1 = --五毒笛咒-普攻1式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
	--	attack_usebasedamage_p={{{1,40},{20,70},{30,100},{32,120}}},
	--	attack_wooddamage_v={
	--		[1]={{1,30*1},{20,130*0.95},{30,300*0.95},{32,350*0.95}},
	--		[3]={{1,30*1},{20,130*1.05},{30,300*1.05},{32,350*1.05}}
	--		},
		dotdamage_wood={{{1,160},{30,480}},{{1,5},{20,30},{30,100},{32,120}},15*0.5},  	--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{15,15*6},{16,15*6}}},								--毒的持续时间
		userdesc_109={{{1,13},{15,13},{16,13}}},										--描述用，显示毒的次数
		skill_dot_ext_type={1},															--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_npchurt_attack={100,7},
		missile_hitcount={{{1,2},{20,2},{30,2},{32,2}}},
    }, 
    newrole_wudu_pg2 = --五毒笛咒-普攻2式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
	--	attack_usebasedamage_p={{{1,40},{20,70},{30,110},{32,120}}},
	--	attack_wooddamage_v={
	--		[1]={{1,30*1},{20,140*0.95},{30,300*0.95},{32,350*0.95}},
	--		[3]={{1,30*1},{20,140*1.05},{30,300*1.05},{32,350*1.05}}
	--		},
		dotdamage_wood={{{1,160},{30,480}},{{1,5},{20,30},{30,150},{32,160}},15*0.5},  	--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{15,15*6},{16,15*6}}},								--毒的持续时间
		skill_dot_ext_type={1},															--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_npchurt_attack={100,7},
		missile_hitcount={{{1,2},{20,2},{30,2},{32,2}}},
    }, 
    newrole_wudu_pg3 = --五毒笛咒-普攻3式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
	--	attack_usebasedamage_p={{{1,60},{20,80},{30,110},{32,120}}},
	--	attack_wooddamage_v={
	--		[1]={{1,60*1},{20,180*0.95},{30,350*0.95},{32,400*0.95}},
	--		[3]={{1,60*1},{20,180*1.05},{30,350*1.05},{32,400*1.05}}
	--		},
		dotdamage_wood={{{1,200},{30,560},{32,15}},{{1,5},{20,40},{30,150},{32,160}},15*0.5},  	--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{15,15*6},{16,15*6}}},										--毒的持续时间
		skill_dot_ext_type={1},																	--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_npchurt_attack={100,7},
		missile_hitcount={{{1,3},{20,3},{30,3},{32,3}}},
    }, 
    newrole_wudu_pg4 = --五毒笛咒-普攻4式--20级
    { 
		attack_attackrate_v={{{1,100},{20,100},{30,100},{32,100}}},
--		attack_usebasedamage_p={{{1,80},{20,130},{30,170},{32,180}}},
--		attack_wooddamage_v={
--			[1]={{1,90*1},{20,300*0.95},{30,500*0.95},{32,550*0.95}},
--			[3]={{1,90*1},{20,300*1.05},{30,500*1.05},{32,550*1.05}}
--			},
		dotdamage_wood={{{1,240},{30,640}},{{1,5},{20,60},{30,200},{32,250}},15*0.5},  	--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{15,15*6},{16,15*6}}},								--毒的持续时间
		skill_dot_ext_type={1},															--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_zhican_attack={{{1,40},{20,40},{30,40},{32,40}},{{1,15*0.5},{20,15*0.5},{30,15*0.5},{32,15*0.5}}},
		state_npchurt_attack={100,7},
		missile_hitcount={{{1,4},{20,4},{30,4},{32,4}}},
    }, 
    newrole_wudu_yfsg = --阴风蚀骨-1级主动--15级
    { 
--		attack_usebasedamage_p={{{1,150},{15,240},{16,250}}},
--		attack_wooddamage_v={
--			[1]={{1,200*0.9},{15,600*0.9},{16,700*0.9}},
--			[3]={{1,200*1.1},{15,600*1.1},{16,700*1.1}}
--			},
		dotdamage_wood={{{1,600},{30,1000}},{{1,50},{15,150},{16,180}},15*0.5}, 		--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{15,15*6},{16,15*6}}},							--毒的持续时间
		userdesc_109={{{1,13},{15,13},{16,13}}},									--描述用，显示毒的次数
		skill_dot_ext_type={1},														--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_zhican_attack={{{1,100},{15,100},{16,100}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},
    },	
    newrole_wudu_zhdc = --召唤毒虫-4级主动2--15级
    { 
		skill_randskill1={{{1,20},{10,20}},3607,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill2={{{1,20},{10,20}},3609,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill3={{{1,20},{10,20}},3611,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill4={{{1,20},{10,20}},3613,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill5={{{1,20},{10,20}},3615,{{1,1},{10,10}}},	--权值，技能ID，等级
		userdesc_000={4313},
		userdesc_101={100,15*2},					--描述用：灵蛇造致缠，对应wudu_zhdc_ls_skill		
		userdesc_102={-300},						--描述用：碧蟾降木抗，对应wudu_zhdc_bc_skill		
		userdesc_103={{{1,2},{10,20},{11,22}}},		--描述用：赤蝎会心一击,wudu_zhdc_cx_skill
		userdesc_104={-300},						--描述用：风蜈降闪避，对应wudu_zhdc_fw_skill		
		userdesc_105={6},							--描述用：墨蛛延毒伤，对应wudu_zhdc_mz_skill		
		skill_statetime={{{1,2},{15,2},{16,2}}},	
		skill_mintimepercast_v={{{1,35*15},{15,30*15},{16,30*15}}},		
    },
	newrole_wudu_zhdc_ls = --召唤毒虫_灵蛇
    { 
		call_npc1={2190, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2190},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	newrole_wudu_zhdc_ls_child = --召唤毒虫_灵蛇_子
    { 
	 	callnpc_life={2190,{{1,100},{15,200},{16,230}}},			--NPCid，生命值%
	 	callnpc_damage={2190,{{1,1000},{30,2000}}},					--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},					--持续时间需要跟召唤毒虫_灵蛇的时间一致
    },
	newrole_wudu_zhdc_bc = --召唤毒虫_碧蟾
    { 
		call_npc1={2191, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2191},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	newrole_wudu_zhdc_bc_child = --召唤毒虫_碧蟾_子
    { 
	 	callnpc_life={2191,{{1,100},{15,200},{16,230}}},			--NPCid，生命值%
	 	callnpc_damage={2191,{{1,1000},{30,2000}}},					--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},					--持续时间需要跟召唤毒虫_碧蟾的时间一致
    },
	newrole_wudu_zhdc_cx = --召唤毒虫_赤蝎
    { 
		call_npc1={2192, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2192},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},
    },	
	newrole_wudu_zhdc_cx_child = --召唤毒虫_赤蝎_子
    { 
	 	callnpc_life={2192,{{1,100},{15,200},{16,230}}},			--NPCid，生命值%
	 	callnpc_damage={2192,{{1,1000},{30,2000}}},					--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},					--持续时间需要跟召唤毒虫_赤蝎的时间一致
    },
	newrole_wudu_zhdc_fw = --召唤毒虫_风蜈
    { 
		call_npc1={2193, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2193},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	newrole_wudu_zhdc_fw_child = --召唤毒虫_风蜈_子
    { 
	 	callnpc_life={2193,{{1,100},{15,200},{16,230}}},			--NPCid，生命值%
	 	callnpc_damage={2193,{{1,1000},{30,2000}}},					--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},					--持续时间需要跟召唤毒虫_风蜈的时间一致
    },
	newrole_wudu_zhdc_mz = --召唤毒虫_墨蛛
    { 
		call_npc1={2194, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2194},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},
    },	
	newrole_wudu_zhdc_mz_child = --召唤毒虫_墨蛛_子
    { 
	 	callnpc_life={2194,{{1,100},{15,200},{16,230}}},			--NPCid，生命值%
	 	callnpc_damage={2194,{{1,1000},{30,2000}}},					--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},					--持续时间需要跟召唤毒虫_墨蛛的时间一致
    },
	newrole_wudu_mxg = --迷心蛊-10级主动3--15级
    { 
		userdesc_000={4336,4337},
		dotdamage_wood={{{1,400},{30,800}},{{1,10},{15,150},{16,160}},15*0.5},  			--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_dot_ext_type={1},															--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		skill_statetime={{{1,15*7.5},{15,15*7.5},{16,15*7.5}}},							--毒的持续时间
		userdesc_109={{{1,16},{15,16},{16,16}}},										--描述用，显示毒的次数
    },
	newrole_wudu_mxg_child1 = --迷心蛊_子1
    { 
		recdot_wood_p={{{1,10},{15,40},{16,42}}},										--增加受到的毒伤%
		skill_statetime={{{1,15*8},{15,15*8},{16,15*8}}},								--debuff的持续时间
    },
	newrole_wudu_mxg_child2 = --迷心蛊_子2
    { 
		state_zhican_attack={{{1,10},{15,30},{16,30}},{{1,15*0.5},{15,15*0.5},{16,15*0.5}}},
		skill_ignore_npchurt = {1},				--标记野怪不被此技能打到后仰效果
    },
    newrole_wudu_wgsx = --万蛊蚀心-30级主动4--15级
    { 
		attack_usebasedamage_p={{{1,5200},{30,6000}}},
		attack_wooddamage_v={
			[1]={{1,600*1},{15,1000*1},{16,1300*1}},
			[3]={{1,600*1},{15,1000*1},{16,1300*1}}
			},
		--dotdamage_wood={{{1,1},{15,15},{16,16}},{{1,10},{15,150},{16,160}},15*0.5},  		--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		--skill_statetime={{{1,15*0.1},{15,15*0.1},{16,15*0.1}}},							--毒的持续时间
		--skill_dot_ext_type={1},															--增加受到的毒伤%的标记，有dotdamage_wood的技能都要加上
		state_zhican_attack={{{1,60},{15,90},{16,95}},{{1,15*1.5},{15,15*1.5},{16,15*1.5}}},
		state_npchurt_attack={100,7},
		userdesc_000={4340},
		missile_hitcount={{{1,5},{15,5},{16,5}}},
		skill_mintimepercast_v={{{1,45*15},{15,40*15},{16,40*15}}},	
    },
    newrole_wudu_wgsx_child = --万蛊蚀心_子
    { 
		receive_dot_alldmg={{{1,200},{15,200},{16,200}},3},								--引爆的比例，技能类型索引SkillSetting.ini
		missile_hitcount={{{1,5},{15,5},{16,5}}},
    },
    newrole_cj_pg1 = --藏剑剑法--普攻1式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_npcknock_attack={100,7,25},	
		spe_knock_param={6 , 4, 9},
    }, 
    newrole_cj_pg2 = --藏剑剑法--普攻2式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_hurt_attack={{{1,40},{20,40},{30,40}},{{1,4},{20,4},{30,4}}},
		
		state_npcknock_attack={100,7,45},	
		spe_knock_param={6 , 4, 9},
    }, 
	
    newrole_cj_pg3 = --藏剑剑法--普攻3式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_hurt_attack={{{1,60},{20,60},{30,60}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,7,35},	
		spe_knock_param={6 , 4, 9},
	
    }, 	
    newrole_cj_pg4 = --藏剑剑法--普攻4式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1600},{30,2400}}},
		attack_metaldamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_hurt_attack={{{1,100},{20,100},{30,100}},{{1,5},{20,5},{30,5}}},
		
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
    },
   newrole_cj_jxmy = --九溪弥烟
    { 
		attack_usebasedamage_p={{{1,3000},{30,6000}}},
		attack_metaldamage_v={
			[1]={{1,150*0.95},{30,600*0.95}},
			[3]={{1,150*1.05},{30,600*1.05}}
			},
		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
    },
	newrole_cj_phdy = --平湖断月
    { 
		userdesc_000={4409},
    },
    newrole_cj_phdy_child = --平湖断月_子
    { 
		attack_usebasedamage_p={{{1,3000},{30,4800}}},
		attack_metaldamage_v={
			[1]={{1,200*0.9},{30,700*0.9}},
			[3]={{1,200*1.1},{30,700*1.1}}
			},	
		state_npcknock_attack={100,7,35},	
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
    },
    newrole_cj_xj = --心剑
    {
		autoskill={135,{{1,1},{10,10},{11,11}}},	
		userdesc_000={4489},	
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15},{21,15*15}}},
		userdesc_101={{{1,15*15},{15,15*15},{16,15*15},{21,15*15}}},		--描述用，心剑buff存活时间
		userdesc_102={{{1,15*10},{15,15*10},{16,15*10},{21,15*10}}},		--描述用，攻击buff存活时间
    },
    newrole_cj_xj_child = --心剑_子
    {
		physics_potentialdamage_p={{{1,10},{15,40},{16,42},{21,60}}},
		superposemagic={{{1,3},{15,6},{16,6},{21,6}}},						--叠加层数
		skill_statetime={{{1,15*10},{15,15*10},{16,15*10},{21,15*10}}},	
    },
	newrole_cj_fcyj = --峰插云景
    { 
		userdesc_000={4414,4415},
		skill_mintimepercast_v={{{1,45*15},{15,40*15},{16,40*15},{21,40*15}}},
    },
    newrole_cj_fcyj_child1 = --峰插云景_内圈伤害
    { 
		attack_usebasedamage_p={{{1,900},{30,1600}}},
		attack_metaldamage_v={
			[1]={{1,70*0.9},{30,500*0.9}},
			[3]={{1,70*1.1},{30,500*1.1}}
			},	
		flag_attack_npc={{{1,15*15},{15,15*15},{16,15*15},{21,15*15}}},   --对击中的目标进行标记，该标记只有自己能看到
		forbid_jump={1},
		skill_statetime={15*1},
		missile_hitcount={{{1,6},{15,6},{16,6},{21,6}}},
    },
    newrole_cg_pg1 = --长歌扇诀-普攻1式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_stun_attack={{{1,30},{30,30}},{{1,4},{30,4}}},
		state_npchurt_attack={100,9},
    }, 
    newrole_cg_pg2 = --长歌扇诀-普攻2式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1000},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,30*1},{30,150*0.95}},
			[3]={{1,30*1},{30,150*1.05}}
			},
		state_stun_attack={{{1,50},{30,50}},{{1,4},{30,4}}},
    }, 	
    newrole_cg_pg3 = --长歌扇诀-普攻3式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1200},{30,1600}}},
		attack_earthdamage_v={
			[1]={{1,60*1},{30,180*0.95}},
			[3]={{1,60*1},{30,180*1.05}}
			},
		state_stun_attack={{{1,80},{30,80}},{{1,6},{30,6}}},	
    }, 	
    newrole_cg_pg4 = --长歌扇诀-普攻4式
    { 
		attack_attackrate_v={{{1,100},{30,100}}},
		attack_usebasedamage_p={{{1,1600},{30,2400}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,300*0.95}},
			[3]={{1,90*1},{30,300*1.05}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,6},{30,6}}},
    }, 
    newrole_cg_psyl = --平沙雁落
    { 
		userdesc_000={4507},
    },
    newrole_cg_psyl_child = --平沙雁落_子
    { 
		attack_usebasedamage_p={{{1,4000},{30,6000}}},
		attack_earthdamage_v={
			[1]={{1,150*0.95},{15,500*0.95},{16,550*0.95},{21,800*0.95}},
			[3]={{1,150*1.05},{15,500*1.05},{16,550*1.05},{21,800*1.05}}
			},
    },
    newrole_cg_ysjh = --云生结海
    { 
		userdesc_000={4509},
    },
    newrole_cg_ysjh_self = --云生结海_自身
    { 
		physics_potentialdamage_p={{{1,100},{30,400}}},
		all_series_resist_p={{{1,30},{15,120},{16,125},{21,180}}},
		meleedamagereturn_p={{{1,2},{15,15},{16,16},{21,18}}},
		rangedamagereturn_p={{{1,2},{15,15},{16,16},{21,18}}},
		skill_statetime={{{1,15*8},{15,15*8},{16,15*8},{21,15*8}}},
    },
	newrole_cg_qycx = --清音长啸
	{ 
		state_hurt_attack={{{1,40},{30,40}},{{1,15*1},{30,15*2}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,1000*0.95}},
			[3]={{1,90*1},{30,1000*1.05}}
			},
	},
	newrole_cg_qycx_child1 = --清音长啸_子1
	{ 
		state_zhican_attack={{{1,40},{30,40}},{{1,15*1},{30,15*2}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,1000*0.95}},
			[3]={{1,90*1},{30,1000*1.05}}
			},
	},
	newrole_cg_qycx_child2 = --清音长啸_子2
	{ 
		state_slowall_attack={{{1,40},{30,40}},{{1,15*1},{30,15*2}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,1000*0.95}},
			[3]={{1,90*1},{30,1000*1.05}}
			},
	},
	newrole_cg_qycx_child3 = --清音长啸_子3
	{ 
		state_palsy_attack={{{1,40},{30,40}},{{1,15*1},{30,15*2}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,1000*0.95}},
			[3]={{1,90*1},{30,1000*1.05}}
			},
	},
	newrole_cg_qycx_child4 = --清音长啸_子4
	{ 
		state_stun_attack={{{1,40},{30,40}},{{1,15*1},{30,15*2}}},
		attack_usebasedamage_p={{{1,2000},{30,3000}}},
		attack_earthdamage_v={
			[1]={{1,90*1},{30,1000*0.95}},
			[3]={{1,90*1},{30,1000*1.05}}
			},
	},
    newrole_cg_jzyt = --江逐月天
    { 
		userdesc_000={4519,4520},
		skill_mintimepercast_v={{{1,45*15},{15,40*15},{16,40*15},{21,40*15}}},
    },
    newrole_cg_jzyt_child1 = --江逐月天_子1
    { 
		attack_usebasedamage_p={{{1,300},{30,800}}},
		attack_earthdamage_v={
			[1]={{1,70*0.9},{30,500*0.9}},
			[3]={{1,70*1.1},{30,500*1.1}}
			},
		state_stun_attack={{{1,40},{15,40},{16,40},{21,40}},{{1,15*1},{15,15*1},{16,15*1},{21,15*1}}},
		attackrate_p={{{1,-20},{15,-100},{16,-120},{21,-150}}},	
		deadlystrike_p={{{1,-10},{15,-50},{16,-55},{21,-80}}},	
		all_series_resist_p={{{1,-20},{15,-100},{16,-120},{21,-150}}},	
		skill_statetime={{{1,15*2},{15,15*2},{16,15*2},{21,15*2}}},	
		missile_hitcount={{{1,5},{15,5},{16,5},{21,5}}},
    },
    newrole_cg_jzyt_child2 = --江逐月天_子2
    { 
		physics_potentialdamage_p={{{1,200},{30,650}}},
		attackspeed_v={{{1,5},{15,50},{16,53},{21,68}}},
		runspeed_v={{{1,5},{15,50},{16,53},{21,68}}},
		skill_statetime={{{1,15*2},{15,15*2},{16,15*2},{21,15*2}}},
    },
    newrole_ts_pg1 = --天山琴曲1--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{20,2}}},  
    }, 
 
    newrole_ts_pg2 = --天山琴曲2--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,2},{20,2}}},  
    },

    newrole_ts_pg3 = --天山琴曲3--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,1400},{20,1800},{30,2400}}},
		attack_waterdamage_v={
			[1]={{1,40*1},{20,150*0.95},{30,270*0.95}},
			[3]={{1,40*1},{20,150*1.05},{30,270*1.05}}
			},
	--	state_hurt_attack={50,5,0},
		state_npchurt_attack={100,6},
		missile_hitcount={{{1,3},{20,3}}},  
    },
    newrole_ts_pg4 = --天山琴曲4--20级
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,2000},{20,3000},{30,2600}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_slowall_attack={{{1,80},{20,80},{30,80}},{{1,15*0.5},{20,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={80,6},
		missile_hitcount={{{1,4},{20,4}}},  
    }, 
    newrole_ts_fylb = --飞燕凌波
    { 
		attack_attackrate_v={{{1,100},{20,100}}},
		attack_usebasedamage_p={{{1,3000},{30,4000}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_npchurt_attack={80,6},  
    }, 
    newrole_ts_ypys = --银瓶玉碎
    { 
		attack_usebasedamage_p={{{1,4000},{30,5000}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_slowall_attack={{{1,80},{20,80},{30,80}},{{1,15*0.5},{20,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={80,6},  
    },
	newrole_ts_ksny = --空山凝云
    {
		physics_potentialdamage_p={{{1,200},{30,200}}},
		skill_statetime={{{1,15*10},{15,15*10},{16,15*10}}},
    },
    newrole_ts_sly = --水龙吟
    { 
		attack_usebasedamage_p={{{1,5000},{30,6000}}},
		attack_waterdamage_v={
			[1]={{1,90*1},{20,300*0.95},{30,420*0.95}},
			[3]={{1,90*1},{20,300*1.05},{30,420*1.05}}
			},
		state_slowall_attack={{{1,80},{20,80},{30,80}},{{1,15*0.5},{20,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={80,6},  
    }, 
	newrole_bd_pg1 = {--霸刀刀法--普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{30,130*2*0.9}},
			[3]={{1,60*2*1.1},{30,130*2*1.1}}
			},
		state_hurt_attack={40,4},
		state_npcknock_attack={100,7,25},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
	},
	newrole_bd_pg2 = {--霸刀刀法--普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{30,130*2*0.9}},
			[3]={{1,60*2*1.1},{30,130*2*1.1}}
			},
		state_hurt_attack={55,4},

		state_npcknock_attack={100,7,45},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
	},
	newrole_bd_pg3 = {--霸刀刀法--普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{30,130*2*0.9}},
			[3]={{1,60*2*1.1},{30,130*2*1.1}}
			},
		state_hurt_attack={75,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},

	},
	newrole_bd_pg4 = {--霸刀刀法--普攻4式--20级,包含4和5
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{30,130*2*0.9}},
			[3]={{1,60*2*1.1},{30,130*2*1.1}}
			},
		state_hurt_attack={100/2,10},

		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
	},
	newrole_bd_xd = {--血刀--1级主动1--15级
		attack_usebasedamage_p={{{1,2000},{30,4800}}},
		attack_metaldamage_v={
			[1]={{1,100*2*0.9},{30,240*2*0.9}},
			[3]={{1,100*2*1.1},{30,240*2*1.1}}
		},
		state_hurt_attack={30,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
		
		skill_point={300,100}, 		--参数1/100：叠加次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={8*15},
		
		userdesc_000={5006},
	},
	newrole_bd_xd_child = {--血刀_生命相关伤害-1级主动1--15级
		damage_maxlife_p={{{1,800},{30,1500}},1},
		state_hurt_attack={30,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
    },
	newrole_bd_cf = {--冲锋-4级主动2--15级
		skill_mintimepercast_v={{{1,19*15},{15,12*15},{20,12*15}}},
		
		userdesc_000={5010},
    },
	newrole_bd_cf_child1 = {--冲锋_拉回
		state_drag_attack={100,3,70},
		skill_drag_npclen={70},
		
		missile_hitcount={3,0,0},
	},
	newrole_bd_cf_child2 = {--冲锋_伤害
		attack_usebasedamage_p={{{1,6000},{30,6000}}},
		attack_metaldamage_v={
			[1]={{1,305*2*0.9},{30,525*2*0.9}},
			[3]={{1,305*2*1.1},{30,525*2*1.1}}
			},
		missile_hitcount={3,0,0},
    },
	
	newrole_bd_sl = {--撕裂--15级
		missile_hitcount={6,0,0},
		
		skill_mintimepercast_v={20*15},
		
		userdesc_000={5013},
	},
	
	newrole_bd_sl_child1 = {--撕裂_持续子弹--15级
		ms_one_hit_count = {1,0,0},
	},
	newrole_bd_sl_child2 = {--撕裂_伤害--15级
		attack_usebasedamage_p={{{1,600},{30,2800}}},
		attack_metaldamage_v={
			[1]={{1,30*2*0.9},{30,140*2*0.9}},
			[3]={{1,30*2*1.1},{30,140*2*1.1}}
			},
		missile_hitcount={0,0,1},
		
		state_hurt_attack={{{1,10},{15,30},{20,30}},5},
		
		runspeed_p={{{1,-4},{10,-40},{20,-40}}},
		skill_statetime={5*15},
	},
	newrole_bd_kb = {--狂暴-30级主动4--15级
		ignore_abnor_state={},			--免疫负面
		state_zhican_ignore={1},		--免疫致残
		physics_potentialdamage_p={{{1,225},{15,225},{20,300}}},
		lifemax_p={{{1,320},{15,320},{20,425}}},
		skill_statetime={6*15},
		
		skill_mintimepercast_v={{{1,24*15},{15,10*15},{20,10*15}}},
		
		force_ignore_spe_state={7077403},--test:测试技能可在特定负面下释放
		
		userdesc_000={5016},
		userdesc_101={30*15},--触发间隔描述
    },
	newrole_bd_kb_child = {--狂暴_耗血减cd
		reduce_cd_time_point={5075,8*15,1},			--减少血刀cd,对充能可减
		--make_npc_lose_lifeP={30},
		mult_skill_state={5018,{{1,1},{10,10}},-1}, 		--扣除降低耗血buff
    },
	newrole_bd_kb_child2 = {--狂暴_被动间隔时间免疫耗血-30级主动4--15级
		autoskill={169,{{1,1},{15,15}}},
		skill_statetime={-1},
    },
	newrole_bd_kb_child3 = {--狂暴_免疫耗血-30级主动4--15级
		--缺少对耗血的加成属性
		skill_statetime={60*15},
    },
    newrole_hs_pg1 = {--华山剑法-普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={40,4},
		state_npcknock_attack={100,7,50},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    newrole_hs_pg2 = {--华山剑法-普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={60,4},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    newrole_hs_pg3 = {--华山剑法-普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={80,6},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    newrole_hs_pg4 = {--华山剑法-普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,1200},{30,2600}}},
		attack_wooddamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
			},
		state_zhican_attack={80,6},
		spe_knock_param1={1},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
	
    newrole_hs_xscl = {--萧史乘龙
		skill_mintimepercast_v={15*7},				
    },
    newrole_hs_xscl_child1 = {--萧史乘龙_伤害
		attack_usebasedamage_p={{{1,8000},{30,8000}}},
		attack_wooddamage_v={
			[1]={{1,379*2*0.9},{15,704*2*0.9},{20,820*2*0.9}},
			[3]={{1,379*2*1.1},{15,704*2*1.1},{20,820*2*1.1}}
		},
		
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
    newrole_hs_tsdx = {--天绅倒悬_15级
		attack_usebasedamage_p={{{1,4000},{30,6000}}},
		attack_wooddamage_v={
			[1]={{1,379*2*0.9},{15,704*2*0.9},{20,820*2*0.9}},
			[3]={{1,379*2*1.1},{15,704*2*1.1},{20,820*2*1.1}}
		},
		
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
		
		skill_mintimepercast_v={{{1,16*15},{15,8*15},{20,8*15}}},
    },
    newrole_hs_cyyqj = {--朝阳一气剑_15级
		attack_usebasedamage_p={{{1,3000},{30,4500}}},
		attack_wooddamage_v={
			[1]={{1,379*2*0.9},{15,704*2*0.9},{20,820*2*0.9}},
			[3]={{1,379*2*1.1},{15,704*2*1.1},{20,820*2*1.1}}
		},
		
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
		
		skill_mintimepercast_v={15*15},
    },
    newrole_hs_fszx = {--风送紫霞
		skill_mintimepercast_v={5*15},
    },
    newrole_hs_fszx_dmg = {--风送紫霞_伤害
		attack_usebasedamage_p={{{1,4000},{30,6000}}},
		attack_wooddamage_v={
			[1]={{1,50*2*0.9},{15,60*2*0.9},{20,70*2*0.9}},
			[3]={{1,50*2*1.1},{15,60*2*1.1},{20,70*2*1.1}}
		},
		
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
	newrole_zzt1 = --张仲天普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,200}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
    },
	newrole_zzt2 = --张仲天冲锋
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
    },
	newrole_zzt3 = --张仲天飞刃
    { 
		attack_usebasedamage_p={{{1,300},{30,400}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
    },
	newrole_zzt4 = --张仲天地裂
    { 
		attack_usebasedamage_p={{{1,400},{30,200}}},
		attack_wooddamage_v={
			[1]={{1,200*0.9},{30,500*0.9}},
			[3]={{1,200*1.1},{30,500*1.1}}
			},
    },
}

FightSkill:AddMagicData(tb)