local Items = {
	{q_featureid = 20028,q_name = '老尸王',q_stand = 4,q_walk = 6,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20104,q_name = '僵尸',q_stand = 4,q_walk = 4,q_attack = 4,q_appear = 5,appear_dir = 7,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20105,q_name = '僵尸',q_stand = 4,q_walk = 4,q_attack = 4,q_appear = 5,appear_dir = 7,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20016,q_name = '魔眼',q_stand = 4,q_walk = 0,q_attack = 4,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20060,q_name = '尸霸',q_stand = 4,q_walk = 6,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20048,q_name = '蛇妖王',q_stand = 5,q_walk = 6,q_attack = 7,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20019,q_name = '逆魔',q_stand = 4,q_walk = 4,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 6,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20009,q_name = '禁地魔王',q_stand = 4,q_walk = 0,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20032,q_name = '铁血魔王',q_stand = 4,q_walk = 6,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 20,q_disappear = 0,run = 0,},
	{q_featureid = 20033,q_name = '通天教主变身前',q_stand = 4,q_walk = 8,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20087,q_name = '阿修罗神变身前',q_stand = 4,q_walk = 8,q_attack = 6,q_appear = 8,appear_dir = 6,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20003,q_name = '机关巨兽',q_stand = 5,q_walk = 0,q_attack = 6,q_appear = 4,appear_dir = 7,q_change = 0,q_eff_appear = 0,q_disappear = 4,run = 0,},
	{q_featureid = 20034,q_name = '通天教主变身后',q_stand = 4,q_walk = 6,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 6,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20079,q_name = '阿修罗神变身后',q_stand = 4,q_walk = 8,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 8,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20024,q_name = '三头蛇王',q_stand = 4,q_walk = 6,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20047,q_name = '白蛇妖',q_stand = 4,q_walk = 4,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20036,q_name = '大刀守卫',q_stand = 4,q_walk = 4,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 4,},
	{q_featureid = 20057,q_name = '沙雕',q_stand = 4,q_walk = 4,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 4,},
	{q_featureid = 20059,q_name = '闪电魔',q_stand = 4,q_walk = 4,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 4,},
	{q_featureid = 20030,q_name = '藤妖',q_stand = 4,q_walk = 4,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 4,},
	{q_featureid = 20045,q_name = '蝎子',q_stand = 4,q_walk = 4,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20114,q_name = '火烈鸟',q_stand = 4,q_walk = 4,q_attack = 8,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 20037,q_name = '弓箭手',q_stand = 6,q_walk = 0,q_attack = 4,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 4,},
	{q_featureid = 20085,q_name = '召唤神兽',q_stand = 4,q_walk = 8,q_attack = 6,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
	{q_featureid = 10036,q_name = '练功师',q_stand = 4,q_walk = 8,q_attack = 4,q_appear = 0,appear_dir = 0,q_change = 0,q_eff_appear = 0,q_disappear = 0,run = 0,},
};
return Items
