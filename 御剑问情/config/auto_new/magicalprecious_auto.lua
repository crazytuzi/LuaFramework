-- M-魔龙秘宝.xls
return {
other={
{}},

chapter_cfg={
{param_b=2,param_c=5,},
{reward_index=1,condition_type=41,param_a=30,reward_item={[0]={item_id=26100,num=1,is_bind=1}},desc="强化总等级达30级",open_panel="Forge#forge_strengthen",target_name="强化",},
{reward_index=2,condition_type=43,param_a=20,reward_item={[0]={item_id=28501,num=1,is_bind=1}},desc="宝石总等级达20级",open_panel="Forge#forge_baoshi",target_name="宝石",},
{reward_index=3,condition_type=104,param_a=1,param_b=2,desc="收集一套蓝色卡牌",open_panel="CardView",target_name="卡牌",},
{reward_index=4,condition_type=105,param_a=5,reward_item={[0]={item_id=28854,num=2,is_bind=1}},desc="仙缘总等级达五级",open_panel="Player#role_bag",target_name="仙缘",},
{reward_index=5,condition_type=44,param_a=201,desc="角色等级达到二转",open_panel="YewaiGuajiView",target_name="等级",},
{reward_index=6,condition_type=46,param_a=14,desc="符文塔通关14层",open_panel="Rune#rune_tower",target_name="符文",},
{chapter_id=1,param_b=3,param_c=5,desc="穿戴四件三阶红装",},
{chapter_id=1,reward_index=1,condition_type=106,param_a=1,param_b=1,param_c=4,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="穿戴一阶橙色情饰",open_panel="Marriage#marriage_equip",target_name="情饰",},
{chapter_id=1,reward_index=2,condition_type=12,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="羽翼进阶至3阶",open_panel="Advance#wing_jinjie",target_name="羽翼",},
{chapter_id=1,reward_index=3,condition_type=104,param_a=2,param_b=2,desc="收集二套蓝色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=1,reward_index=4,condition_type=108,param_a=1,reward_item={[0]={item_id=22810,num=1,is_bind=1}},desc="穿戴一阶左勾玉",open_panel="NewExchangeView#exchange_shengwang",target_name="勾玉",},
{chapter_id=1,reward_index=5,condition_type=44,param_a=240,desc="角色等级二转40级",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=1,reward_index=6,condition_type=47,param_a=18,reward_item={[0]={item_id=28501,num=1,is_bind=1}},desc="爬塔副本通关18层",open_panel="FuBen#fb_tower",target_name="爬塔",},
{chapter_id=2,param_a=3,param_b=4,param_c=5,desc="穿戴三件四阶红装",},
{chapter_id=2,reward_index=1,condition_type=107,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="出战4个仙宠",open_panel="SpiritView#spirit_spirit",target_name="仙宠",},
{chapter_id=2,reward_index=2,condition_type=14,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="伙伴光环进阶至3阶",open_panel="Goddess#goddess_shengong",target_name="伙伴",},
{chapter_id=2,reward_index=3,condition_type=104,param_b=2,desc="收集四套蓝色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=2,reward_index=4,condition_type=105,param_a=20,reward_item={[0]={item_id=28854,num=3,is_bind=1}},desc="仙缘总等级达20级",open_panel="Player#role_bag",target_name="仙缘",},
{chapter_id=2,reward_index=5,condition_type=44,param_a=270,desc="角色等级二转70级",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=2,reward_index=6,condition_type=46,param_a=28,desc="符文塔通关28层",open_panel="Rune#rune_tower",target_name="符文",},
{chapter_id=3,param_a=5,param_b=4,param_c=5,desc="穿戴五件四阶红装",},
{chapter_id=3,reward_index=1,condition_type=113,param_a=15,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="伙伴神器总等级达到15",open_panel="Goddess#goddess_shengwu",target_name="伙伴",},
{chapter_id=3,reward_index=2,condition_type=13,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="光环进阶至3阶",open_panel="Advance#halo_jinjie",target_name="光环",},
{chapter_id=3,reward_index=3,condition_type=104,param_a=1,param_b=3,desc="收集一套紫色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=3,reward_index=4,condition_type=108,param_a=2,reward_item={[0]={item_id=22811,num=1,is_bind=1}},desc="穿戴二阶左勾玉",open_panel="NewExchangeView#exchange_shengwang",target_name="勾玉",},
{chapter_id=3,reward_index=5,condition_type=44,param_a=301,desc="角色等级达到三转",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=3,reward_index=6,condition_type=47,param_a=25,reward_item={[0]={item_id=28501,num=1,is_bind=1}},desc="爬塔副本通关25层",open_panel="FuBen#fb_tower",target_name="爬塔",},
{chapter_id=4,param_a=7,param_b=4,param_c=5,desc="穿戴七件四阶红装",},
{chapter_id=4,reward_index=1,condition_type=117,param_a=2,param_b=2,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="激活两个魔神",open_panel="ShenShou#shenshou_equip",target_name="魔神",},
{chapter_id=4,reward_index=2,condition_type=15,param_b=1,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="伙伴法阵进阶至3阶",open_panel="Goddess#goddess_shenyi",target_name="伙伴",},
{chapter_id=4,reward_index=3,condition_type=104,param_a=2,param_b=3,desc="收集两套紫色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=4,reward_index=4,condition_type=109,param_a=1,reward_item={[0]={item_id=22825,num=1,is_bind=1}},desc="穿戴一阶右勾玉",open_panel="NewExchangeView#exchange_rongyao",target_name="勾玉",},
{chapter_id=4,reward_index=5,condition_type=44,param_a=330,desc="角色等级三转30级",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=4,reward_index=6,condition_type=46,param_a=37,desc="符文塔通关37层",open_panel="Rune#rune_tower",target_name="符文",},
{chapter_id=5,param_a=3,param_b=5,param_c=5,desc="穿戴三件五阶红装",},
{chapter_id=5,reward_index=1,condition_type=119,param_a=2,param_b=2,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="激活两个天神",open_panel="FamousGeneralView#famous_general_info",target_name="天神",},
{chapter_id=5,reward_index=2,condition_type=23,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="足迹进阶至3阶",open_panel="Advance#foot_jinjie",target_name="足迹",},
{chapter_id=5,reward_index=3,condition_type=104,param_a=3,param_b=3,desc="收集三套紫色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=5,reward_index=4,condition_type=105,param_a=30,reward_item={[0]={item_id=28854,num=3,is_bind=1}},desc="仙缘总等级达30级",open_panel="Player#role_bag",target_name="仙缘",},
{chapter_id=5,reward_index=5,condition_type=44,param_a=350,desc="角色等级三转50级",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=5,reward_index=6,condition_type=47,param_a=29,reward_item={[0]={item_id=28501,num=1,is_bind=1}},desc="爬塔副本通关29层",open_panel="FuBen#fb_tower",target_name="爬塔",},
{chapter_id=6,param_a=5,param_b=5,param_c=5,desc="穿戴五件五阶红装",},
{chapter_id=6,reward_index=1,condition_type=114,param_a=1,param_b=1,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="镶嵌一个蓝色命魂",open_panel="SpiritView#spirit_soul",target_name="命魂",},
{chapter_id=6,reward_index=2,condition_type=16,reward_item={[0]={item_id=22018,num=1,is_bind=1}},desc="战斗坐骑进阶至3阶",open_panel="Advance#fight_mount",target_name="战骑",},
{chapter_id=6,reward_index=3,condition_type=104,param_a=1,param_b=4,desc="收集一套橙色卡牌",open_panel="CardView",target_name="卡牌",},
{chapter_id=6,reward_index=4,condition_type=108,param_a=3,reward_item={[0]={item_id=22826,num=1,is_bind=1}},desc="穿戴三阶左勾玉",open_panel="NewExchangeView#exchange_shengwang",target_name="勾玉",},
{chapter_id=6,reward_index=5,condition_type=44,param_a=370,desc="角色等级三转70级",open_panel="YewaiGuajiView",target_name="等级",},
{chapter_id=6,reward_index=6,condition_type=46,param_a=45,desc="符文塔通关45层",open_panel="Rune#RuneTowerView",target_name="符文",}},

finish_chapter_reward_cfg={
{},
{chapter_id=1,reward_item={[0]={item_id=26403,num=1,is_bind=1},[1]={item_id=26301,num=8,is_bind=1},[2]={item_id=26410,num=4,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},
{chapter_id=2,reward_item={[0]={item_id=24503,num=1,is_bind=1},[1]={item_id=26303,num=8,is_bind=1},[2]={item_id=27832,num=3,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},
{chapter_id=3,reward_item={[0]={item_id=22548,num=1,is_bind=1},[1]={item_id=27830,num=10,is_bind=1},[2]={item_id=26302,num=8,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},
{chapter_id=4,reward_item={[0]={item_id=26404,num=1,is_bind=1},[1]={item_id=26304,num=8,is_bind=1},[2]={item_id=23597,num=1,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},
{chapter_id=5,reward_item={[0]={item_id=24544,num=1,is_bind=1},[1]={item_id=26298,num=8,is_bind=1},[2]={item_id=26451,num=4,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},
{chapter_id=6,reward_item={[0]={item_id=24018,num=1,is_bind=1},[1]={item_id=26299,num=8,is_bind=1},[2]={item_id=27702,num=8,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},}},

big_chapter_cfg={
{},
{chapter_id=1,chapter_name="伙伴·司空文林",chapter_pic=2,},
{chapter_id=2,chapter_name="光环·未来之光",chapter_pic=3,},
{chapter_id=3,chapter_name="光环·花飞叶舞",chapter_pic=4,},
{chapter_id=4,chapter_name="伙伴·上官阳",chapter_pic=5,},
{chapter_id=5,chapter_name="羽翼·雁飞惊鸿",chapter_pic=6,},
{chapter_id=6,chapter_name="坐骑·剑齿虎",chapter_pic=7,}},

other_default_table={open_level=108,},

chapter_cfg_default_table={chapter_id=0,reward_index=0,condition_type=103,param_a=4,param_b=0,param_c=0,is_show_result=0,offer=0,shenwang_reward=0,mojing_reward=0,bind_gold_reward=0,reward_item={[0]={item_id=22702,num=1,is_bind=1}},client_reward={},tuijian_item={},desc="穿戴四件二阶红装",open_panel="Boss#miku_boss",target_name="红装",},

finish_chapter_reward_cfg_default_table={chapter_id=0,reward_item={[0]={item_id=26401,num=1,is_bind=1},[1]={item_id=26300,num=8,is_bind=1},[2]={item_id=26410,num=4,is_bind=1},[3]={item_id=22026,num=1,is_bind=1}},},

big_chapter_cfg_default_table={chapter_id=0,chapter_name="伙伴·沐雪",chapter_pic=1,}

}

