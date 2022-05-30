----------------------------------------------------
-- 此文件由数据工具生成
-- 特效配置--advance_guide_data.xml
--------------------------------------

Config = Config or {} 
Config.AdvanceGuideData = Config.AdvanceGuideData or {}

-- -------------------group_list_start-------------------
Config.AdvanceGuideData.data_group_list_length = 3
Config.AdvanceGuideData.data_group_list = {
	[1] = {
		[1] = {
			[1] = {group=1, group_id=1, id=1, name="新手推荐", is_parner_form=1, is_goto=0, partner_list={30004,30003,30022,10001,10008}, icon="", cli_label="", extra={}, level=0, des_label="雅典娜<div fontcolor=#d63cfc>（狂怒套）</div>,哈迪斯<div fontcolor=#d63cfc>（迅影狂怒套）</div>,吸血伯爵<div fontcolor=#d63cfc>（狂怒套）</div>,亚瑟<div fontcolor=#d63cfc>（迅影勇气套）</div>;首充可获得超强输出雅典娜，哈迪斯和吸血伯爵搭配能稳定控制敌方单位，亚瑟是前期十分好用的辅助控制", tips_des=""},
			[2] = {group=1, group_id=1, id=2, name="冰冻增伤", is_parner_form=1, is_goto=0, partner_list={30008,20007,30002,20013,30023}, icon="", cli_label="", extra={}, level=0, des_label="冰雪女王<div fontcolor=#d63cfc>（暴击预言者套）</div>,波塞冬<div fontcolor=#d63cfc>（速度秩序套）</div>,游侠射手<div fontcolor=#d63cfc>（速度预言者套）</div>,水元素<div fontcolor=#d63cfc>（暴击预言者套）</div>;依靠获得回合不断控制敌人，控制英雄需要堆高速度，比对面先出手", tips_des=""},
			[3] = {group=1, group_id=1, id=3, name="灼烧暴击", is_parner_form=1, is_goto=0, partner_list={30010,10002,30012,20002,30023}, icon="", cli_label="", extra={}, level=0, des_label="炎魔之王<div fontcolor=#d63cfc>（攻击雷霆套）</div>,炽天使<div fontcolor=#d63cfc>（暴击雷霆套）</div>,凯瑟琳<div fontcolor=#d63cfc>（命中征服套）</div>;配合2个加攻击暴击辅助，前2回合直接结束战斗", tips_des=""},
			[4] = {group=1, group_id=1, id=4, name="诅咒输出", is_parner_form=1, is_goto=0, partner_list={30007,30013,30016,30008,20009}, icon="", cli_label="", extra={}, level=0, des_label="阿努比斯<div fontcolor=#d63cfc>（暴伤狂怒套）</div>,路西法<div fontcolor=#d63cfc>（暴伤狂怒套）</div>,月之祭司<div fontcolor=#d63cfc>（生命战吼套）</div>,娜迦公主<div fontcolor=#d63cfc>（速度迅影套）</div>;诅咒伤害可直接击杀敌方全部单位,月之祭司保证2波怪时刷新CD", tips_des=""},
		},
		[2] = {
			[1] = {group=1, group_id=2, id=1, name="肉盾防守", is_parner_form=1, is_goto=0, partner_list={30024,30006,20019,30009}, icon="", cli_label="", extra={}, level=0, des_label="影刹<div fontcolor=#d63cfc>（生命预言者套）</div>,盖亚<div fontcolor=#d63cfc>（防御秩序套）</div>,憎恶<div fontcolor=#d63cfc>（生命勇气套）</div>,凯兰崔尔<div fontcolor=#d63cfc>（生命预言者套）</div>;敌人较难直接击杀己方任何一个英雄，憎恶反伤消耗", tips_des=""},
			[2] = {group=1, group_id=2, id=2, name="免疫防守", is_parner_form=1, is_goto=0, partner_list={20023,20015,30006,10001}, icon="", cli_label="", extra={}, level=0, des_label="岩石傀儡<div fontcolor=#d63cfc>(抵抗反击套)</div>,吟游诗人<div fontcolor=#d63cfc>(生命预言者套)</div>,盖亚<div fontcolor=#d63cfc>(防御秩序套)</div>,亚瑟<div fontcolor=#d63cfc>(生命战吼套)</div>;没有任何攻击能力,纯防守阵容，用于防守竞技场", tips_des=""},
			[3] = {group=1, group_id=2, id=3, name="高速控制", is_parner_form=1, is_goto=0, partner_list={30022,30003,30023,20014}, icon="", cli_label="", extra={}, level=0, des_label="雷霆狮鹫<div fontcolor=#d63cfc>（速度迅影套）</div>,艾蕾莉亚<div fontcolor=#d63cfc>（速度信仰套）</div>,哈迪斯<div fontcolor=#d63cfc>（命中征服套）</div>,吸血伯爵<div fontcolor=#d63cfc>（暴伤狂怒套）</div>;高速控制对手，且输出足够；惧怕净化免疫", tips_des=""},
		},
		[3] = {
			[1] = {group=1, group_id=3, id=1, name="冰冻控制", is_parner_form=1, is_goto=0, partner_list={30002,20007,30016,20009,30008}, icon="", cli_label="", extra={}, level=0, des_label="娜迦公主<div fontcolor=#d63cfc>（速度迅影套）</div>,波塞冬<div fontcolor=#d63cfc>（速度秩序套）</div>,游侠射手<div fontcolor=#d63cfc>（速度征服套）</div>,月之祭司<div fontcolor=#d63cfc>（生命战吼套）</div>;抢1速稳定控制敌人;惧怕敌人1速控制秒杀", tips_des=""},
			[2] = {group=1, group_id=3, id=2, name="重置冷却", is_parner_form=1, is_goto=0, partner_list={30016,30007,30001,20015,30025}, icon="", cli_label="", extra={}, level=0, des_label="赫拉<div fontcolor=#d63cfc>（速度迅影套）</div>,宙斯<div fontcolor=#d63cfc>（命中迅影套）</div>,阿努比斯<div fontcolor=#d63cfc>（暴伤狂怒套）</div>,月之祭司<div fontcolor=#d63cfc>（生命战吼套）</div>;破敌方免疫且控制敌方，依靠加BUFF后的阿努比斯2套带走", tips_des=""},
			[3] = {group=1, group_id=3, id=3, name="四保一", is_parner_form=1, is_goto=0, partner_list={30011,20016,20015,30009,20011}, icon="", cli_label="", extra={}, level=0, des_label="黑暗之主<div fontcolor=#d63cfc>（暴击雷霆套）</div>,4个辅助都为生命预言者套装；保证输出不死，逐个点杀", tips_des=""},
			[4] = {group=1, group_id=3, id=4, name="睡杀单点", is_parner_form=1, is_goto=0, partner_list={20011,30021,20015,20014,20017}, icon="", cli_label="", extra={}, level=0, des_label="竖琴海妖<div fontcolor=#d63cfc>（命中迅影套）</div>,魅魔女王<div fontcolor=#d63cfc>（暴伤狂怒套）</div>,吟游诗人<div fontcolor=#d63cfc>（生命预言者套）</div>,雷霆狮鹫<div fontcolor=#d63cfc>（速度迅影套）</div>;群体睡眠敌方，单体点杀关键英雄", tips_des=""},
		},
		[4] = {
			[1] = {group=1, group_id=4, id=1, name="提升阶数", is_parner_form=0, is_goto=1, partner_list={}, icon="13", cli_label="evt_partner_strength_treasure", extra={}, level=1, des_label="提升英雄阶数能提升英雄基础属性", tips_des=""},
			[2] = {group=1, group_id=4, id=2, name="提升等级", is_parner_form=0, is_goto=1, partner_list={}, icon="14", cli_label="evt_partner_lev", extra={}, level=1, des_label="提升英雄等级能提升英雄基础属性", tips_des=""},
			[3] = {group=1, group_id=4, id=3, name="提升星级", is_parner_form=0, is_goto=1, partner_list={}, icon="15", cli_label="evt_partner_star_num", extra={}, level=1, des_label="提升英雄星级，能增加大量基础属性", tips_des=""},
			[4] = {group=1, group_id=4, id=4, name="提升技能", is_parner_form=0, is_goto=1, partner_list={}, icon="16", cli_label="evt_partner_skill", extra={}, level=1, des_label="使用符石提升技能等级，技能更强力", tips_des=""},
			[5] = {group=1, group_id=4, id=5, name="提升装备", is_parner_form=0, is_goto=1, partner_list={}, icon="17", cli_label="evt_partner_eqm", extra={}, level=22, des_label="给英雄穿戴装备提升绿字属性", tips_des=""},
		},
	},
	[2] = {
		[1] = {
			[1] = {group=2, group_id=1, id=1, name="通关副本", is_parner_form=0, is_goto=1, partner_list={}, icon="12", cli_label="evt_dungeon_pass", extra={3}, level=6, des_label="通关普通副本可获得领主经验", tips_des=""},
			[2] = {group=2, group_id=1, id=2, name="日常任务", is_parner_form=0, is_goto=1, partner_list={}, icon="9", cli_label="evt_daily_quest", extra={}, level=11, des_label="完成日常任务能获得大量领主经验", tips_des=""},
			[3] = {group=2, group_id=1, id=3, name="诸神大陆", is_parner_form=0, is_goto=1, partner_list={}, icon="28", cli_label="evt_bigworld", extra={}, level=35, des_label="在诸神大陆中击杀怪物获取经验", tips_des=""},
		},
		[2] = {
			[1] = {group=2, group_id=2, id=1, name="炼金场", is_parner_form=0, is_goto=1, partner_list={}, icon="1", cli_label="evt_trade", extra={1}, level=15, des_label="炼金场生产金币，亦可花费钻石换取金币", tips_des=""},
			[2] = {group=2, group_id=2, id=2, name="巨龙副本", is_parner_form=0, is_goto=1, partner_list={}, icon="26", cli_label="evt_dungeon_enter", extra={6}, level=24, des_label="挑战巨龙副本，可获得大量金币", tips_des=""},
			[3] = {group=2, group_id=2, id=3, name="英雄远征", is_parner_form=0, is_goto=1, partner_list={}, icon="8", cli_label="evt_expedition", extra={}, level=26, des_label="挑战英雄远征可获得金币", tips_des=""},
		},
		[3] = {
			[1] = {group=2, group_id=3, id=1, name="充值", is_parner_form=0, is_goto=1, partner_list={}, icon="3", cli_label="evt_pay", extra={}, level=1, des_label="前往充值购买钻石", tips_des=""},
			[2] = {group=2, group_id=3, id=2, name="主线任务", is_parner_form=0, is_goto=1, partner_list={}, icon="9", cli_label="evt_main_quest", extra={}, level=1, des_label="完成每一章主线任务可获得钻石", tips_des=""},
			[3] = {group=2, group_id=3, id=3, name="剧情副本", is_parner_form=0, is_goto=1, partner_list={}, icon="12", cli_label="evt_dungeon_pass", extra={3}, level=1, des_label="开启剧情副本宝箱可获得钻石", tips_des=""},
			[4] = {group=2, group_id=3, id=4, name="地下城副本", is_parner_form=0, is_goto=1, partner_list={}, icon="6", cli_label="evt_dungeon_pass", extra={3,1}, level=1, des_label="开启地下城副本宝箱可获得钻石", tips_des=""},
			[5] = {group=2, group_id=3, id=5, name="试练塔首通", is_parner_form=0, is_goto=1, partner_list={}, icon="2", cli_label="evt_dungeon_enter", extra={4}, level=18, des_label="试炼塔每层首次通关可获得大量钻石", tips_des=""},
		},
		[4] = {
			[1] = {group=2, group_id=4, id=1, name="好友赠送", is_parner_form=0, is_goto=1, partner_list={}, icon="27", cli_label="evt_friend_present", extra={}, level=6, des_label="领取好友赠送的体力", tips_des=""},
			[2] = {group=2, group_id=4, id=2, name="许愿池", is_parner_form=0, is_goto=1, partner_list={}, icon="10", cli_label="evt_wish", extra={}, level=10, des_label="每天定时赠送大量体力", tips_des=""},
			[3] = {group=2, group_id=4, id=3, name="港口", is_parner_form=0, is_goto=1, partner_list={}, icon="7", cli_label="evt_port", extra={}, level=14, des_label="领取停泊在港口的飞船的体力", tips_des=""},
			[4] = {group=2, group_id=4, id=4, name="购买体力", is_parner_form=0, is_goto=1, partner_list={}, icon="19", cli_label="evt_trade", extra={3}, level=6, des_label="点击体力图标花费钻石购买体力", tips_des=""},
		},
		[5] = {
			[1] = {group=2, group_id=5, id=1, name="活动", is_parner_form=0, is_goto=1, partner_list={}, icon="5", cli_label="evt_activity", extra={}, level=6, des_label="部分活动可用钻石直购装备", tips_des=""},
			[2] = {group=2, group_id=5, id=2, name="神秘商店", is_parner_form=0, is_goto=1, partner_list={}, icon="11", cli_label="evt_mystical_shop", extra={}, level=16, des_label="可用金币在神秘商店购买装备", tips_des=""},
			[3] = {group=2, group_id=5, id=3, name="制作装备", is_parner_form=0, is_goto=1, partner_list={}, icon="18", cli_label="evt_research", extra={3}, level=20, des_label="花费一定材料制作装备", tips_des=""},
			[4] = {group=2, group_id=5, id=4, name="装备副本", is_parner_form=0, is_goto=1, partner_list={}, icon="17", cli_label="evt_dungeon_enter", extra={1}, level=22, des_label="挑战装备副本可获得珍稀装备", tips_des=""},
		},
		[6] = {
			[1] = {group=2, group_id=6, id=1, name="竞技积分", is_parner_form=0, is_goto=1, partner_list={}, icon="20", cli_label="evt_arena_fight", extra={}, level=16, des_label="每天挑战竞技场能获得竞技积分", tips_des=""},
			[2] = {group=2, group_id=6, id=2, name="联盟积分", is_parner_form=0, is_goto=1, partner_list={}, icon="21", cli_label="evt_league", extra={}, level=17, des_label="参与联盟相关玩法可获得大量积分", tips_des=""},
			[3] = {group=2, group_id=6, id=3, name="远征积分", is_parner_form=0, is_goto=1, partner_list={}, icon="22", cli_label="evt_expedition", extra={}, level=26, des_label="挑战英雄远征玩法可获得积分", tips_des=""},
			[4] = {group=2, group_id=6, id=4, name="段位积分", is_parner_form=0, is_goto=1, partner_list={}, icon="23", cli_label="evt_rank_match_fight", extra={}, level=28, des_label="挑战段位赛可获得段位积分", tips_des=""},
			[5] = {group=2, group_id=6, id=5, name="天梯积分", is_parner_form=0, is_goto=1, partner_list={}, icon="25", cli_label="evt_sky_ladder_fight", extra={}, level=35, des_label="参与天梯玩法可获得积分", tips_des=""},
		},
		[7] = {
			[1] = {group=2, group_id=7, id=1, name="分解英雄", is_parner_form=0, is_goto=1, partner_list={}, icon="24", cli_label="evt_research", extra={1}, level=9, des_label="分解暂时不用的英雄能获得大量神格", tips_des=""},
			[2] = {group=2, group_id=7, id=2, name="分解碎片", is_parner_form=0, is_goto=1, partner_list={}, icon="24", cli_label="evt_research", extra={1}, level=9, des_label="分解不需要的英雄碎片能获得神格", tips_des=""},
			[3] = {group=2, group_id=7, id=3, name="挑战试练塔", is_parner_form=0, is_goto=1, partner_list={}, icon="2", cli_label="evt_dungeon_enter", extra={4}, level=18, des_label="挑战试炼塔可获得神格奖励", tips_des=""},
		},
	},
	[3] = {
		[1] = {
			[1] = {group=3, group_id=1, id=1, name="英雄速度", is_parner_form=0, is_goto=0, partner_list={}, icon="30", cli_label="", extra={}, level=1, des_label="英雄速度高低决定攻击条增长快慢", tips_des="速度越快，攻击条增长越快，加速度buff可百分比增加整体速度总和。攻击条相同的情况下，速度高的先出手。"},
			[2] = {group=3, group_id=1, id=2, name="行动条", is_parner_form=0, is_goto=0, partner_list={}, icon="31", cli_label="", extra={}, level=1, des_label="行动条满即可达到出手条件", tips_des="1、部分英雄技能可直接改变英雄行动条，行动条满即可获得回合\n2、若多个英雄行动条满，则先满条的先出手，行动条进度一致的，速度快的优先出手\n3、每个英雄行动结束后，全体单位增加固定比例的行动条。"},
			[3] = {group=3, group_id=1, id=3, name="效果命中和抵抗", is_parner_form=0, is_goto=0, partner_list={}, icon="32", cli_label="", extra={}, level=1, des_label="效果命中和抵抗决定最终是否控制成功", tips_des="效果命中可增加控制或者减益效果成功的概率，效果抵抗可降低受到控制或减益效果的概率"},
		},
	},
}
-- -------------------group_list_end---------------------


-- -------------------group_name_start-------------------
Config.AdvanceGuideData.data_group_name_length = 3
Config.AdvanceGuideData.data_group_name = {
	[1] = {
		[1] = {group=1, group_id=1, group_name="英雄指引", sec_name="剧情推图", is_parner_form=1},
		[2] = {group=1, group_id=2, group_name="英雄指引", sec_name="四人竞技", is_parner_form=1},
		[3] = {group=1, group_id=3, group_name="英雄指引", sec_name="五人竞技", is_parner_form=1},
		[4] = {group=1, group_id=4, group_name="英雄指引", sec_name="提升英雄", is_parner_form=0},
		[5] = {group=1, group_id=5, group_name="英雄指引", sec_name="游戏帮助", is_parner_form=0},
	},
	[2] = {
		[1] = {group=2, group_id=1, group_name="资源获取", sec_name="我要经验", is_parner_form=0},
		[2] = {group=2, group_id=2, group_name="资源获取", sec_name="我要金币", is_parner_form=0},
		[3] = {group=2, group_id=3, group_name="资源获取", sec_name="我要钻石", is_parner_form=0},
		[4] = {group=2, group_id=4, group_name="资源获取", sec_name="我要体力", is_parner_form=0},
		[5] = {group=2, group_id=5, group_name="资源获取", sec_name="我要装备", is_parner_form=0},
		[6] = {group=2, group_id=6, group_name="资源获取", sec_name="我要积分", is_parner_form=0},
		[7] = {group=2, group_id=7, group_name="资源获取", sec_name="我要神格", is_parner_form=0},
	},
	[3] = {
		[1] = {group=3, group_id=1, group_name="游戏帮助", sec_name="战斗规则", is_parner_form=0},
	},
}
-- -------------------group_name_end---------------------
