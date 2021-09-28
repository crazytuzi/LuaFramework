
i3k_db_single_challenge_cfg = {
	[1] = { name = '宗门禁地', needLvl = 35, startPoint = 101, startDate = 1523548800, endDate = 1586707200, openDay = { 3, 0, }, startTime = 34200, endTime = 84600, npcId = 70020, sealIconId = 6262 },
};

i3k_db_single_challenge_group = {
	{ groupId = 101, nextGroupId = { 102, }, npcGroupId = { 17, }, challengeName = '迷雾洞窟', challengeDesc = '听说禁地里有许多可怕的存在，要多加小心呀！' },
	{ groupId = 102, nextGroupId = { 103, }, npcGroupId = { 18, 19, 20, 21, 22, }, challengeName = '六壬秘境', challengeDesc = '要尽快从的诸多石柱中找到三根六壬之柱，不然可能会永远迷失在这里。' },
	{ groupId = 103, nextGroupId = { 104, }, npcGroupId = { 28, }, challengeName = '千机阁楼', challengeDesc = '千机阁楼的机关可不是开玩笑的，要注意，注意，注意呀！' },
	{ groupId = 104, nextGroupId = { 105, 106, }, npcGroupId = { 23, }, challengeName = '幻影圣殿', challengeDesc = '幻影圣殿很有可能让人产生幻觉，你要小心应对。' },
	{ groupId = 105, nextGroupId = { }, npcGroupId = { 24, 25, }, challengeName = '游云山巅', challengeDesc = '大盗极有可能逃到了这里，抓到他会获得丰厚的奖励。' },
	{ groupId = 106, nextGroupId = { }, npcGroupId = { 26, 27, }, challengeName = '暗夜密林', challengeDesc = '大盗极有可能逃到了这里，抓到他会获得丰厚的奖励。' },
};

i3k_db_single_challenge_buff = {
	{ buffId = 1001, buffType = 1, buffInactiveDesc = '每5秒恢复10%气血', buffDesc = '每5秒恢复10%气血', activeIcon = 344, inactiveIcon = 0, args1 = 1201, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1002, buffType = 1, buffInactiveDesc = '攻击加成10%', buffDesc = '攻击加成10%', activeIcon = 334, inactiveIcon = 0, args1 = 1202, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1003, buffType = 1, buffInactiveDesc = '防御加成10%', buffDesc = '防御加成10%', activeIcon = 336, inactiveIcon = 0, args1 = 1203, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1004, buffType = 1, buffInactiveDesc = '命中加成10%', buffDesc = '命中加成10%', activeIcon = 333, inactiveIcon = 0, args1 = 1204, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1005, buffType = 1, buffInactiveDesc = '躲闪加成10%', buffDesc = '躲闪加成10%', activeIcon = 337, inactiveIcon = 0, args1 = 1205, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1006, buffType = 1, buffInactiveDesc = '暴击加成10%', buffDesc = '暴击加成10%', activeIcon = 335, inactiveIcon = 0, args1 = 1206, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1007, buffType = 1, buffInactiveDesc = '韧性加成10%', buffDesc = '韧性加成10%', activeIcon = 339, inactiveIcon = 0, args1 = 1207, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1008, buffType = 1, buffInactiveDesc = '伤害增加10%', buffDesc = '伤害增加10%', activeIcon = 6258, inactiveIcon = 0, args1 = 1208, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1009, buffType = 1, buffInactiveDesc = '伤害减免10%', buffDesc = '伤害减免10%', activeIcon = 6256, inactiveIcon = 0, args1 = 1209, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1011, buffType = 1, buffInactiveDesc = '每5秒恢复15%气血', buffDesc = '每5秒恢复15%气血', activeIcon = 344, inactiveIcon = 0, args1 = 1213, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1012, buffType = 1, buffInactiveDesc = '攻击加成20%', buffDesc = '攻击加成20%', activeIcon = 334, inactiveIcon = 0, args1 = 1214, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1013, buffType = 1, buffInactiveDesc = '防御加成20%', buffDesc = '防御加成20%', activeIcon = 336, inactiveIcon = 0, args1 = 1215, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1014, buffType = 1, buffInactiveDesc = '命中加成20%', buffDesc = '命中加成20%', activeIcon = 333, inactiveIcon = 0, args1 = 1216, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1015, buffType = 1, buffInactiveDesc = '躲闪加成20%', buffDesc = '躲闪加成20%', activeIcon = 337, inactiveIcon = 0, args1 = 1217, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1016, buffType = 1, buffInactiveDesc = '暴击加成20%', buffDesc = '暴击加成20%', activeIcon = 335, inactiveIcon = 0, args1 = 1218, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1017, buffType = 1, buffInactiveDesc = '韧性加成20%', buffDesc = '韧性加成20%', activeIcon = 339, inactiveIcon = 0, args1 = 1219, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1018, buffType = 1, buffInactiveDesc = '伤害增加20%', buffDesc = '伤害增加20%', activeIcon = 6258, inactiveIcon = 0, args1 = 1220, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1019, buffType = 1, buffInactiveDesc = '伤害减免20%', buffDesc = '伤害减免20%', activeIcon = 6256, inactiveIcon = 0, args1 = 1221, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1021, buffType = 1, buffInactiveDesc = '每5秒恢复20%气血', buffDesc = '每5秒恢复20%气血', activeIcon = 344, inactiveIcon = 0, args1 = 1222, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1022, buffType = 1, buffInactiveDesc = '攻击加成30%', buffDesc = '攻击加成30%', activeIcon = 334, inactiveIcon = 0, args1 = 1223, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1023, buffType = 1, buffInactiveDesc = '防御加成30%', buffDesc = '防御加成30%', activeIcon = 336, inactiveIcon = 0, args1 = 1224, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1024, buffType = 1, buffInactiveDesc = '命中加成30%', buffDesc = '命中加成30%', activeIcon = 333, inactiveIcon = 0, args1 = 1225, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1025, buffType = 1, buffInactiveDesc = '躲闪加成30%', buffDesc = '躲闪加成30%', activeIcon = 337, inactiveIcon = 0, args1 = 1226, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1026, buffType = 1, buffInactiveDesc = '暴击加成30%', buffDesc = '暴击加成30%', activeIcon = 335, inactiveIcon = 0, args1 = 1227, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1027, buffType = 1, buffInactiveDesc = '韧性加成30%', buffDesc = '韧性加成30%', activeIcon = 339, inactiveIcon = 0, args1 = 1228, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1028, buffType = 1, buffInactiveDesc = '伤害增加30%', buffDesc = '伤害增加30%', activeIcon = 6258, inactiveIcon = 0, args1 = 1229, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 1029, buffType = 1, buffInactiveDesc = '伤害减免30%', buffDesc = '伤害减免30%', activeIcon = 6256, inactiveIcon = 0, args1 = 1230, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2001, buffType = 2, buffInactiveDesc = '通关额外掉落铜钱', buffDesc = '通关额外掉落铜钱', activeIcon = 6259, inactiveIcon = 0, args1 = 8401, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2002, buffType = 2, buffInactiveDesc = '通关额外掉落道具', buffDesc = '通关额外掉落道具', activeIcon = 6254, inactiveIcon = 0, args1 = 8402, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2003, buffType = 2, buffInactiveDesc = '下个关卡通关后获得绑定元宝\n<c=hlred>已失效</c>', buffDesc = '下个关卡通关后获得绑定元宝\n<c=hlred>稀有祝福仅触发一次</c>', activeIcon = 6260, inactiveIcon = 6260, args1 = 8403, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2004, buffType = 2, buffInactiveDesc = '下个关卡通关会获得神兵碎片\n<c=hlred>已失效</c>', buffDesc = '下个关卡通关会获得神兵碎片\n<c=hlred>稀有祝福仅触发一次</c>', activeIcon = 6257, inactiveIcon = 6257, args1 = 8404, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2005, buffType = 2, buffInactiveDesc = '下个关卡通关会获得宠物碎片\n<c=hlred>已失效</c>', buffDesc = '下个关卡通关会获得宠物碎片\n<c=hlred>稀有祝福仅触发一次</c>', activeIcon = 6255, inactiveIcon = 6255, args1 = 8405, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
	{ buffId = 2006, buffType = 2, buffInactiveDesc = '下个关卡通关会获得坐骑碎片\n<c=hlred>已失效</c>', buffDesc = '下个关卡通关会获得坐骑碎片\n<c=hlred>稀有祝福仅触发一次</c>', activeIcon = 6261, inactiveIcon = 6261, args1 = 8406, args2 = 0, args3 = 0, args4 = 0, args5 = 0 },
};
