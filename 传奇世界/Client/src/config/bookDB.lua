local Items = {
	{q_id = 1,q_school = 1,q_lv = 1,q_top = '角色诞生',q_depict = '完成主线任务，迈出您征服传奇世界的第一步',q_function = '角色',q_link = 'a13',},
	{q_id = 2,q_school = 1,q_lv = 1,q_top = '装备打造',q_depict = '消耗指定材料可以打造出强力装备。',q_function = '打造装备',q_link = 'a141',},
	{q_id = 3,q_school = 1,q_lv = 1,q_top = '道具合成',q_depict = '消耗指定材料可以合成高级道具。',q_function = '合成道具',q_link = 'a186',},
	{q_id = 4,q_school = 1,q_lv = 1,q_top = '社交好友',q_depict = '恩怨情仇江湖路。交好友以心，斩仇人于义。',q_function = '查看好友',q_link = 'a167',},
	{q_id = 5,q_school = 1,q_lv = 1,q_top = '拍卖行',q_depict = '拍卖行可随时随地购买、寄售非绑定的物品，享受高品质便捷服务。',q_function = '查看拍卖行',q_link = 'a123',},
	{q_id = 6,q_school = 1,q_lv = 2,q_top = '获得装备',q_depict = '完成主线任务，获得装备：衣服',q_function = '查看装备',q_link = 'a13',},
	{q_id = 7,q_school = 1,q_lv = 3,q_top = '获得武器',q_depict = '完成主线任务，获得装备：武器',q_function = '查看装备',q_link = 'a13',},
	{q_id = 8,q_school = 1,q_lv = 4,q_top = '学习技能',q_depict = '学习技能可以强化角色，更有效的增加伤害，或者提升防御。',q_function = '查看技能',q_link = 'a27',},
	{q_id = 9,q_school = 1,q_lv = 5,q_top = '获得药品',q_depict = '使用药品可以在平时或者某些关键时刻回复您的状态。',q_function = '查看背包',q_link = 'a31',},
	{q_id = 10,q_school = 1,q_lv = 10,q_top = '怪物攻城',q_depict = '修罗魔界合兵进攻中州，中州城岌岌可危，召集各路勇士守卫中州，击退怪物可获各种道具奖励。',q_function = '怪物攻城',q_link = 'a109',},
	{q_id = 11,q_school = 1,q_lv = 10,q_top = '王城赐福',q_depict = '每日12点和18点，可前往中州王雕像处领取美酒，使用后可获得大量经验',q_function = '前往领取',q_link = 'a129',Value = 8,},
	{q_id = 12,q_school = 1,q_lv = 12,q_top = '每日签到',q_depict = '每日只需登录即可获得海量福利。',q_function = '每日签到',q_link = 'a28',},
	{q_id = 13,q_school = 1,q_lv = 15,q_top = '开启坐骑',q_depict = '完成主线任务，获得坐骑：枣红马。坐骑可永久增加角色属性。',q_function = '查看坐骑',q_link = 'a17',},
	{q_id = 14,q_school = 1,q_lv = 16,q_top = '传世之路',q_depict = '一步一个脚印的走属于自己的传世之路，享受逐渐成长的喜悦。',q_function = '立即查看',q_link = 'a194',},
	{q_id = 15,q_school = 1,q_lv = 17,q_top = '开启熔炼',q_depict = '熔炼可将装备转化为金币与熔炼值，熔炼值可在熔炼商店购买道具。',q_function = '熔炼装备',q_link = 'a124',},
	{q_id = 16,q_school = 1,q_lv = 19,q_top = '行会',q_depict = '通过行会，将结识到许多义气相投的朋友。加入行会，即可获得战旗buff，提升属性，行会贡献可购买珍宝阁的物品。',q_function = '查看行会',q_link = 'a3',},
	{q_id = 17,q_school = 1,q_lv = 19,q_top = '拜师',q_depict = '有一个好的师父可以让游戏更加欢乐和流畅，快去找个师父吧。',q_function = '前往拜师',q_link = 'a168',},
	{q_id = 18,q_school = 1,q_lv = 20,q_top = '冒险挖矿',q_depict = '通过进入中部矿区采集“矿石结晶”，采集有风险，挖矿需谨慎！',q_function = '立即前往',q_link = 'a129',Value = 10,},
	{q_id = 19,q_school = 1,q_lv = 21,q_top = '强化装备',q_depict = '强化可大幅提升装备的基础属性，装备品质越高可强化上限越高。',q_function = '强化装备',q_link = 'a164',},
	{q_id = 20,q_school = 1,q_lv = 21,q_top = '离线经验',q_depict = '角色离线一段时间后，就会开始累积离线经验，上线后即可领取。',q_function = '查看角色',q_link = 'a13',},
	{q_id = 21,q_school = 1,q_lv = 22,q_top = '王城诏令',q_depict = '每日完成王城诏令可获得大量经验和参与日常活动所需道具。',q_function = '立即前往',q_link = 'a1',},
	{q_id = 22,q_school = 1,q_lv = 23,q_top = '获得勋章',q_depict = '完成主线任务，获得新装备：勋章，勋章拥有强大属性，可以通过声望提升品质星级和属性。',q_function = '查看勋章',q_link = 'a138',},
	{q_id = 23,q_school = 1,q_lv = 24,q_top = '送花',q_depict = '为心仪的TA送上一束玫瑰可以为对方增加魅力值。',q_function = '前往送花',q_link = 'a167',},
	{q_id = 24,q_school = 1,q_lv = 25,q_top = '每日膜拜',q_depict = '每日膜拜沙城城主可获得大量经验。',q_function = '前往膜拜',q_link = 'a110',},
	{q_id = 25,q_school = 1,q_lv = 25,q_top = '世界聊天',q_depict = '快去世界频道和别人打个招呼吧，让世界听到你的声音。',q_function = '前往聊天',q_link = 'a170',},
	{q_id = 26,q_school = 1,q_lv = 28,q_top = '悬赏任务',q_depict = '完成悬赏任务可获得丰富的经验，每天每种颜色的任务可各完成5个。使用悬赏卷轴可发布任务，每天可发布五个任务。',q_function = '立即前往',q_link = 'a144',},
	{q_id = 27,q_school = 1,q_lv = 29,q_top = '通天塔',q_depict = '挑战通天塔中的BOSS，可获得强化装备所必须的金币、矿石，还可获得洗炼符。',q_function = '挑战通天塔',q_link = 'a129',Value = 2,},
	{q_id = 28,q_school = 1,q_lv = 30,q_top = '落霞夺宝',q_depict = '落霞宝盒引各方争夺，内藏玄机高级技能助勇士叱咤风云。',q_function = '参与夺宝',q_link = 'a129',Value = 6,},
	{q_id = 29,q_school = 1,q_lv = 30,q_top = '装备洗炼',q_depict = '使用洗炼符可以洗炼装备的附加属性。',q_function = '洗炼装备',q_link = 'a166',},
	{q_id = 30,q_school = 1,q_lv = 30,q_top = '公平竞技场',q_depict = '一场绝对公平的竞技，一次充满无限可能的对抗，丰厚奖励唾手可得。',q_function = '前往竞技',q_link = 'a225',},
	{q_id = 31,q_school = 1,q_lv = 32,q_top = '勇闯炼狱',q_depict = '参加勇闯炼狱可获得：仙翼技能书、40级紫色装备等奖励。参与活动消耗：炼狱凭证。（日常活动、商城购买获得）',q_function = '深入炼狱',q_link = 'a210',},
	{q_id = 32,q_school = 1,q_lv = 32,q_top = '全民宝地',q_depict = '全民打宝的限时地图，实力和运气的综合体现。',q_function = '前往打宝',q_link = 'a227',},
	{q_id = 33,q_school = 1,q_lv = 34,q_top = '多人守卫',q_depict = '公主受到邪魔侵袭，急需勇士守卫公主，入侵的怪物极为强大，请勇士组队前往。',q_function = '前往守护',q_link = 'a129',Value = 4,},
	{q_id = 34,q_school = 1,q_lv = 36,q_top = '个人护镖',q_depict = '镖车活动开放，护送镖车可获得大量经验奖励。但是请小心那些窥视镖车物资的人。',q_function = '参与运镖',q_link = 'a129',Value = 12,},
	{q_id = 35,q_school = 1,q_lv = 36,q_top = '组队护镖',q_depict = '组队运镖可获得更高的经验加成，和队友一起也会更安全。但不要忘记，高收益随之而来的高风险。',q_function = '组队运镖',q_link = 'a129',Value = 12,},
	{q_id = 36,q_school = 1,q_lv = 39,q_top = '迷仙阵',q_depict = '每一步都充满惊喜，每一个房间都有无限可能，一切尽在迷仙阵中。',q_function = '前往解谜',q_link = 'a228',},
	{q_id = 37,q_school = 1,q_lv = 40,q_top = '开启仙翼',q_depict = '完成支线任务可获得仙翼。仙翼拥有绚丽的外形与强大的属性，还可以通过仙翼进阶符提升等级，学习强大的仙翼技能。',q_function = '仙翼升级',q_link = 'a18',},
	{q_id = 38,q_school = 1,q_lv = 40,q_top = '武器祝福',q_depict = '祝福油有概率增加武器幸运，幸运越高，出现最大攻击的几率越高。',q_function = '进行祝福',q_link = 'a140',},
	{q_id = 39,q_school = 1,q_lv = 50,q_top = '为人师',q_depict = '成为令人敬仰的师父，给新人教导，收获声望。',q_function = '成为师父',q_link = 'a168',},
	{q_id = 40,q_school = 1,q_lv = 55,q_top = '点金',q_depict = '点金可以使装备获得额外属性，提升整体战斗力。',q_function = '进行点金',q_link = 'a185',},
	{q_id = 101,q_school = 2,q_lv = 1,q_top = '角色诞生',q_depict = '完成主线任务，迈出您征服传奇世界的第一步',q_function = '角色',q_link = 'a13',},
	{q_id = 102,q_school = 2,q_lv = 1,q_top = '装备打造',q_depict = '消耗指定材料可以打造出强力装备。',q_function = '打造装备',q_link = 'a141',},
	{q_id = 103,q_school = 2,q_lv = 1,q_top = '道具合成',q_depict = '消耗指定材料可以合成高级道具。',q_function = '合成道具',q_link = 'a186',},
	{q_id = 104,q_school = 2,q_lv = 1,q_top = '社交好友',q_depict = '恩怨情仇江湖路。交好友以心，斩仇人于义。',q_function = '查看好友',q_link = 'a167',},
	{q_id = 105,q_school = 2,q_lv = 1,q_top = '拍卖行',q_depict = '拍卖行可随时随地购买、寄售非绑定的物品，享受高品质便捷服务。',q_function = '查看拍卖行',q_link = 'a123',},
	{q_id = 106,q_school = 2,q_lv = 2,q_top = '获得装备',q_depict = '完成主线任务，获得装备：衣服',q_function = '查看装备',q_link = 'a13',},
	{q_id = 107,q_school = 2,q_lv = 3,q_top = '获得武器',q_depict = '完成主线任务，获得装备：武器',q_function = '查看装备',q_link = 'a13',},
	{q_id = 108,q_school = 2,q_lv = 4,q_top = '学习技能',q_depict = '学习技能可以强化角色，更有效的增加伤害，或者提升防御。',q_function = '查看技能',q_link = 'a27',},
	{q_id = 109,q_school = 2,q_lv = 5,q_top = '获得药品',q_depict = '使用药品可以在平时或者某些关键时刻回复您的状态。',q_function = '查看背包',q_link = 'a31',},
	{q_id = 110,q_school = 2,q_lv = 10,q_top = '怪物攻城',q_depict = '修罗魔界合兵进攻中州，中州城岌岌可危，召集各路勇士守卫中州，击退怪物可获各种道具奖励。',q_function = '怪物攻城',q_link = 'a109',},
	{q_id = 111,q_school = 2,q_lv = 10,q_top = '王城赐福',q_depict = '每日12点和18点，可前往中州王雕像处领取美酒，使用后可获得大量经验',q_function = '前往领取',q_link = 'a129',Value = 8,},
	{q_id = 112,q_school = 2,q_lv = 12,q_top = '每日签到',q_depict = '每日只需登录即可获得海量福利。',q_function = '每日签到',q_link = 'a28',},
	{q_id = 113,q_school = 2,q_lv = 15,q_top = '开启坐骑',q_depict = '完成主线任务，获得坐骑：枣红马。坐骑可永久增加角色属性。',q_function = '查看坐骑',q_link = 'a17',},
	{q_id = 114,q_school = 2,q_lv = 16,q_top = '传世之路',q_depict = '一步一个脚印的走属于自己的传世之路，享受逐渐成长的喜悦。',q_function = '立即查看',q_link = 'a194',},
	{q_id = 115,q_school = 2,q_lv = 17,q_top = '开启熔炼',q_depict = '熔炼可将不需要的装备转化为金币和熔炼值，魂值可在熔炼商店购买道具。',q_function = '熔炼装备',q_link = 'a124',},
	{q_id = 116,q_school = 2,q_lv = 19,q_top = '行会',q_depict = '通过行会，将结识到许多义气相投的朋友。加入行会，即可获得战旗buff，提升属性，行会贡献可购买珍宝阁的物品。',q_function = '查看行会',q_link = 'a3',},
	{q_id = 117,q_school = 2,q_lv = 19,q_top = '拜师',q_depict = '有一个好的师父可以让游戏更加欢乐和流畅，快去找个师父吧。',q_function = '前往拜师',q_link = 'a168',},
	{q_id = 118,q_school = 2,q_lv = 20,q_top = '冒险挖矿',q_depict = '通过进入中部矿区采集“矿石结晶”，采集有风险，挖矿需谨慎！',q_function = '立即前往',q_link = 'a129',Value = 10,},
	{q_id = 119,q_school = 2,q_lv = 21,q_top = '强化装备',q_depict = '强化可大幅提升装备的基础属性，装备品质越高可强化上限越高。',q_function = '强化装备',q_link = 'a164',},
	{q_id = 120,q_school = 2,q_lv = 21,q_top = '离线经验',q_depict = '角色离线一段时间后，就会开始累积离线经验，上线后即可领取。',q_function = '查看角色',q_link = 'a13',},
	{q_id = 121,q_school = 2,q_lv = 22,q_top = '王城诏令',q_depict = '每日完成王城诏令可获得大量经验和参与日常活动所需道具。',q_function = '立即前往',q_link = 'a1',},
	{q_id = 122,q_school = 2,q_lv = 23,q_top = '获得勋章',q_depict = '完成主线任务，获得新装备：勋章，勋章拥有强大属性，可以通过声望提升品质星级和属性。',q_function = '查看勋章',q_link = 'a138',},
	{q_id = 123,q_school = 2,q_lv = 24,q_top = '送花',q_depict = '为心仪的TA送上一束玫瑰可以为对方增加魅力值。',q_function = '前往送花',q_link = 'a167',},
	{q_id = 124,q_school = 2,q_lv = 25,q_top = '每日膜拜',q_depict = '每日膜拜沙城城主可获得大量经验。',q_function = '前往膜拜',q_link = 'a110',},
	{q_id = 125,q_school = 2,q_lv = 25,q_top = '世界聊天',q_depict = '快去世界频道和别人打个招呼吧，让世界听到你的声音。',q_function = '前往聊天',q_link = 'a170',},
	{q_id = 126,q_school = 2,q_lv = 28,q_top = '悬赏任务',q_depict = '完成悬赏任务可获得丰富的经验，每天每种颜色的任务可各完成5个。使用悬赏卷轴可发布任务，每天可发布五个任务。',q_function = '立即前往',q_link = 'a144',},
	{q_id = 127,q_school = 2,q_lv = 29,q_top = '通天塔',q_depict = '挑战通天塔中的BOSS，可获得强化装备所必须的金币、矿石，还可获得洗炼符。',q_function = '挑战通天塔',q_link = 'a129',Value = 2,},
	{q_id = 128,q_school = 2,q_lv = 30,q_top = '落霞夺宝',q_depict = '落霞宝盒引各方争夺，内藏玄机高级技能助勇士叱咤风云。',q_function = '参与夺宝',q_link = 'a129',Value = 6,},
	{q_id = 129,q_school = 2,q_lv = 30,q_top = '装备洗炼',q_depict = '使用洗炼符可以洗炼装备的附加属性。',q_function = '洗炼装备',q_link = 'a166',},
	{q_id = 130,q_school = 2,q_lv = 30,q_top = '公平竞技场',q_depict = '一场绝对公平的竞技，一次充满无限可能的对抗，丰厚奖励唾手可得。',q_function = '前往竞技',q_link = 'a225',},
	{q_id = 131,q_school = 2,q_lv = 32,q_top = '勇闯炼狱',q_depict = '参加勇闯炼狱可获得：仙翼技能书、40级紫色装备等奖励。参与活动消耗：炼狱凭证。（日常活动、商城购买获得）',q_function = '深入炼狱',q_link = 'a210',},
	{q_id = 132,q_school = 2,q_lv = 32,q_top = '全民宝地',q_depict = '全民打宝的限时地图，实力和运气的综合体现。',q_function = '前往打宝',q_link = 'a227',},
	{q_id = 133,q_school = 2,q_lv = 34,q_top = '多人守卫',q_depict = '公主受到邪魔侵袭，急需勇士守卫公主，入侵的怪物极为强大，请勇士组队前往。',q_function = '前往守护',q_link = 'a129',Value = 4,},
	{q_id = 134,q_school = 2,q_lv = 36,q_top = '个人护镖',q_depict = '镖车活动开放，护送镖车可获得大量经验奖励。但是请小心那些窥视镖车物资的人。',q_function = '参与运镖',q_link = 'a129',Value = 12,},
	{q_id = 135,q_school = 2,q_lv = 36,q_top = '组队护镖',q_depict = '组队运镖可获得更高的经验加成，和队友一起也会更安全。但不要忘记，高收益随之而来的高风险。',q_function = '组队运镖',q_link = 'a129',Value = 12,},
	{q_id = 136,q_school = 2,q_lv = 39,q_top = '迷仙阵',q_depict = '每一步都充满惊喜，每一个房间都有无限可能，一切尽在迷仙阵中。',q_function = '前往解谜',q_link = 'a228',},
	{q_id = 137,q_school = 2,q_lv = 40,q_top = '开启仙翼',q_depict = '完成支线任务可获得仙翼。仙翼拥有绚丽的外形与强大的属性，还可以通过仙翼进阶符提升等级，学习强大的仙翼技能。',q_function = '仙翼升级',q_link = 'a18',},
	{q_id = 138,q_school = 2,q_lv = 40,q_top = '武器祝福',q_depict = '祝福油有概率增加武器幸运，幸运越高，出现最大攻击的几率越高。',q_function = '进行祝福',q_link = 'a140',},
	{q_id = 139,q_school = 2,q_lv = 50,q_top = '为人师',q_depict = '成为令人敬仰的师父，给新人教导，收获声望。',q_function = '成为师父',q_link = 'a168',},
	{q_id = 140,q_school = 2,q_lv = 55,q_top = '点金',q_depict = '点金可以使装备获得额外属性，提升整体战斗力。',q_function = '进行点金',q_link = 'a185',},
	{q_id = 201,q_school = 3,q_lv = 1,q_top = '角色诞生',q_depict = '完成主线任务，迈出您征服传奇世界的第一步',q_function = '角色',q_link = 'a13',},
	{q_id = 202,q_school = 3,q_lv = 1,q_top = '装备打造',q_depict = '消耗指定材料可以打造出强力装备。',q_function = '打造装备',q_link = 'a141',},
	{q_id = 203,q_school = 3,q_lv = 1,q_top = '道具合成',q_depict = '消耗指定材料可以合成高级道具。',q_function = '合成道具',q_link = 'a186',},
	{q_id = 204,q_school = 3,q_lv = 1,q_top = '社交好友',q_depict = '恩怨情仇江湖路。交好友以心，斩仇人于义。',q_function = '查看好友',q_link = 'a167',},
	{q_id = 205,q_school = 3,q_lv = 1,q_top = '拍卖行',q_depict = '拍卖行可随时随地购买、寄售非绑定的物品，享受高品质便捷服务。',q_function = '查看拍卖行',q_link = 'a123',},
	{q_id = 206,q_school = 3,q_lv = 2,q_top = '获得装备',q_depict = '完成主线任务，获得装备：衣服',q_function = '查看装备',q_link = 'a13',},
	{q_id = 207,q_school = 3,q_lv = 3,q_top = '获得武器',q_depict = '完成主线任务，获得装备：武器',q_function = '查看装备',q_link = 'a13',},
	{q_id = 208,q_school = 3,q_lv = 4,q_top = '学习技能',q_depict = '学习技能可以强化角色，更有效的增加伤害，或者提升防御。',q_function = '查看技能',q_link = 'a27',},
	{q_id = 209,q_school = 3,q_lv = 5,q_top = '获得药品',q_depict = '使用药品可以在平时或者某些关键时刻回复您的状态。',q_function = '查看背包',q_link = 'a31',},
	{q_id = 210,q_school = 3,q_lv = 10,q_top = '怪物攻城',q_depict = '修罗魔界合兵进攻中州，中州城岌岌可危，召集各路勇士守卫中州，击退怪物可获各种道具奖励。',q_function = '怪物攻城',q_link = 'a109',},
	{q_id = 211,q_school = 3,q_lv = 10,q_top = '王城赐福',q_depict = '每日12点和18点，可前往中州王雕像处领取美酒，使用后可获得大量经验',q_function = '前往领取',q_link = 'a129',Value = 8,},
	{q_id = 212,q_school = 3,q_lv = 12,q_top = '每日签到',q_depict = '每日只需登录即可获得海量福利。',q_function = '每日签到',q_link = 'a28',},
	{q_id = 213,q_school = 3,q_lv = 15,q_top = '开启坐骑',q_depict = '完成主线任务，获得坐骑：枣红马。坐骑可永久增加角色属性。',q_function = '查看坐骑',q_link = 'a17',},
	{q_id = 214,q_school = 3,q_lv = 16,q_top = '传世之路',q_depict = '一步一个脚印的走属于自己的传世之路，享受逐渐成长的喜悦。',q_function = '立即查看',q_link = 'a194',},
	{q_id = 215,q_school = 3,q_lv = 17,q_top = '开启熔炼',q_depict = '熔炼可将不需要的装备转化为金币和熔炼值，魂值可在熔炼商店购买道具。',q_function = '熔炼装备',q_link = 'a124',},
	{q_id = 216,q_school = 3,q_lv = 19,q_top = '行会',q_depict = '通过行会，将结识到许多义气相投的朋友。加入行会，即可获得战旗buff，提升属性，行会贡献可购买珍宝阁的物品。',q_function = '查看行会',q_link = 'a3',},
	{q_id = 217,q_school = 3,q_lv = 19,q_top = '拜师',q_depict = '有一个好的师父可以让游戏更加欢乐和流畅，快去找个师父吧。',q_function = '前往拜师',q_link = 'a168',},
	{q_id = 218,q_school = 3,q_lv = 20,q_top = '冒险挖矿',q_depict = '通过进入中部矿区采集“矿石结晶”，采集有风险，挖矿需谨慎！',q_function = '立即前往',q_link = 'a129',Value = 10,},
	{q_id = 219,q_school = 3,q_lv = 21,q_top = '强化装备',q_depict = '强化可大幅提升装备的基础属性，装备品质越高可强化上限越高。',q_function = '强化装备',q_link = 'a164',},
	{q_id = 220,q_school = 3,q_lv = 21,q_top = '离线经验',q_depict = '角色离线一段时间后，就会开始累积离线经验，上线后即可领取。',q_function = '查看角色',q_link = 'a13',},
	{q_id = 221,q_school = 3,q_lv = 22,q_top = '王城诏令',q_depict = '每日完成王城诏令可获得大量经验和参与日常活动所需道具。',q_function = '立即前往',q_link = 'a1',},
	{q_id = 222,q_school = 3,q_lv = 23,q_top = '获得勋章',q_depict = '完成主线任务，获得新装备：勋章，勋章拥有强大属性，可以通过声望提升品质星级和属性。',q_function = '查看勋章',q_link = 'a138',},
	{q_id = 223,q_school = 3,q_lv = 24,q_top = '送花',q_depict = '为心仪的TA送上一束玫瑰可以为对方增加魅力值。',q_function = '前往送花',q_link = 'a167',},
	{q_id = 224,q_school = 3,q_lv = 25,q_top = '每日膜拜',q_depict = '每日膜拜沙城城主可获得大量经验。',q_function = '前往膜拜',q_link = 'a110',},
	{q_id = 225,q_school = 3,q_lv = 25,q_top = '世界聊天',q_depict = '快去世界频道和别人打个招呼吧，让世界听到你的声音。',q_function = '前往聊天',q_link = 'a170',},
	{q_id = 226,q_school = 3,q_lv = 28,q_top = '悬赏任务',q_depict = '完成悬赏任务可获得丰富的经验，每天每种颜色的任务可各完成5个。使用悬赏卷轴可发布任务，每天可发布五个任务。',q_function = '立即前往',q_link = 'a144',},
	{q_id = 227,q_school = 3,q_lv = 29,q_top = '通天塔',q_depict = '挑战通天塔中的BOSS，可获得强化装备所必须的金币、矿石，还可获得洗炼符。',q_function = '挑战通天塔',q_link = 'a129',Value = 2,},
	{q_id = 228,q_school = 3,q_lv = 30,q_top = '落霞夺宝',q_depict = '落霞宝盒引各方争夺，内藏玄机高级技能助勇士叱咤风云。',q_function = '参与夺宝',q_link = 'a129',Value = 6,},
	{q_id = 229,q_school = 3,q_lv = 30,q_top = '装备洗炼',q_depict = '使用洗炼符可以洗炼装备的附加属性。',q_function = '洗炼装备',q_link = 'a166',},
	{q_id = 230,q_school = 3,q_lv = 30,q_top = '公平竞技场',q_depict = '一场绝对公平的竞技，一次充满无限可能的对抗，丰厚奖励唾手可得。',q_function = '前往竞技',q_link = 'a225',},
	{q_id = 231,q_school = 3,q_lv = 32,q_top = '勇闯炼狱',q_depict = '参加勇闯炼狱可获得：仙翼技能书、40级紫色装备等奖励。参与活动消耗：炼狱凭证。（日常活动、商城购买获得）',q_function = '深入炼狱',q_link = 'a210',},
	{q_id = 232,q_school = 3,q_lv = 32,q_top = '全民宝地',q_depict = '全民打宝的限时地图，实力和运气的综合体现。',q_function = '前往打宝',q_link = 'a227',},
	{q_id = 233,q_school = 3,q_lv = 34,q_top = '多人守卫',q_depict = '公主受到邪魔侵袭，急需勇士守卫公主，入侵的怪物极为强大，请勇士组队前往。',q_function = '前往守护',q_link = 'a129',Value = 4,},
	{q_id = 234,q_school = 3,q_lv = 36,q_top = '个人护镖',q_depict = '镖车活动开放，护送镖车可获得大量经验奖励。但是请小心那些窥视镖车物资的人。',q_function = '参与运镖',q_link = 'a129',Value = 12,},
	{q_id = 235,q_school = 3,q_lv = 36,q_top = '组队护镖',q_depict = '组队运镖可获得更高的经验加成，和队友一起也会更安全。但不要忘记，高收益随之而来的高风险。',q_function = '组队运镖',q_link = 'a129',Value = 12,},
	{q_id = 236,q_school = 3,q_lv = 39,q_top = '迷仙阵',q_depict = '每一步都充满惊喜，每一个房间都有无限可能，一切尽在迷仙阵中。',q_function = '前往解谜',q_link = 'a228',},
	{q_id = 237,q_school = 3,q_lv = 40,q_top = '开启仙翼',q_depict = '完成支线任务可获得仙翼。仙翼拥有绚丽的外形与强大的属性，还可以通过仙翼进阶符提升等级，学习强大的仙翼技能。',q_function = '仙翼升级',q_link = 'a18',},
	{q_id = 238,q_school = 3,q_lv = 40,q_top = '武器祝福',q_depict = '祝福油有概率增加武器幸运，幸运越高，出现最大攻击的几率越高。',q_function = '进行祝福',q_link = 'a140',},
	{q_id = 239,q_school = 3,q_lv = 50,q_top = '为人师',q_depict = '成为令人敬仰的师父，给新人教导，收获声望。',q_function = '成为师父',q_link = 'a168',},
	{q_id = 240,q_school = 3,q_lv = 55,q_top = '点金',q_depict = '点金可以使装备获得额外属性，提升整体战斗力。',q_function = '进行点金',q_link = 'a185',},
};
return Items
