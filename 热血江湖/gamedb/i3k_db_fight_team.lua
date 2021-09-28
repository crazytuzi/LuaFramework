i3k_db_fightTeam_base =
{
	budo = {
		showLvl = 65
	},
	primaries = {
		times = 15
	},
	team = {
		requireLvl = 70,
		maxNumber = 5,
		maxRepeatCtype = 2,
		kickCD = 24,
		needItems = {{ id = 65651, count = 50} , { id= 65647,count = 50}, },
		confirmText = 'honor',
		maxJoinTimes = 2
	},
	display = {
		titleIcon = 5025,
		isShowGuard = 0,
		guardModelID = 433
	},
	group = {
		titleIcon = 9999
	},
};

i3k_db_fightTeam_explain =
{
	[1] = { name = '【海選賽】', explainDesc = '%s，賽季開始，此時可組建戰隊\n%s，可以通過匹配跨服參加海選賽\n%s，取跨服海選賽積分前64名，進入錦標賽，並隨機對手', uiName = '海選賽進行中', fightTeamState = '海選還剩%s場', winDesc = '%s，海選賽勝利，獲得%s積分', failDesc = '%s，海選賽失敗，獲得%s積分', enterDesc = '%s，脫穎而出進入64強' },
	[2] = { name = '【錦標賽】——64進32', explainDesc = '%s，64強戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者進入32強\n%s，正式公佈32強結果，並隨機匹配各自對手', uiName = '錦標賽64進32', fightTeamState = '進入64強', winDesc = '%s，64強賽獲勝，進入32強', failDesc = '%s，64強賽失敗，止步64強', enterDesc = '' },
	[3] = { name = '【錦標賽】——32進16', explainDesc = '%s，32強戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者進入16強\n%s，正式公佈16強結果，並隨機匹配各自對手', uiName = '錦標賽32進16', fightTeamState = '進入32強', winDesc = '%s，32強賽獲勝，進入16強', failDesc = '%s，32強賽失敗，止步32強', enterDesc = '' },
	[4] = { name = '【錦標賽】——16進8', explainDesc = '%s，16強戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者進入16強\n%s，正式公佈8強結果，並隨機匹配各自對手', uiName = '錦標賽16進8', fightTeamState = '進入16強', winDesc = '%s，16強賽獲勝，進入8強', failDesc = '%s，16強賽失敗，止步16強', enterDesc = '' },
	[5] = { name = '【錦標賽】——8進4', explainDesc = '%s，8強戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者進入8強\n%s，正式公佈4強結果，並隨機匹配各自對手', uiName = '錦標賽8進4', fightTeamState = '進入8強', winDesc = '%s，8強賽獲勝，進入4強', failDesc = '%s，8強賽失敗，止步8強', enterDesc = '' },
	[6] = { name = '【錦標賽】——4進2', explainDesc = '%s，4強戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者進入冠軍爭奪賽\n%s，正式公佈冠軍爭奪賽結果', uiName = '錦標賽4進2', fightTeamState = '進入4強', winDesc = '%s，4強賽獲勝，進入冠軍爭奪賽', failDesc = '%s，4強賽失敗，止步4強', enterDesc = '' },
	[7] = { name = '【錦標賽】——冠軍戰', explainDesc = '%s，冠軍爭奪賽戰隊<c=green>所有隊員簽到</c>，戰隊全部未簽到的戰隊視為棄權\n%s，正式開戰，勝者獲得賽季冠軍\n%s，正式公佈冠軍', uiName = '錦標賽冠軍戰', fightTeamState = '進入冠軍爭奪賽', winDesc = '%s，冠軍爭奪賽獲勝，獲得冠軍', failDesc = '%s，冠軍爭奪賽失敗，獲得亞軍', enterDesc = '' },
	[8] = { name = '【錦標賽】——閉幕', explainDesc = '%s，武道會正式閉幕，可以領取錦標賽獎勵和個人榮譽獎勵', uiName = '武道會結束，請期待下個賽季', fightTeamState = '獲得冠軍', winDesc = '', failDesc = '', enterDesc = '' },
};

i3k_db_fightTeam_tournament_reward =
{
	{id = 1, stageDesc = '冠軍', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 68267, count = 1}, { id = 66786, count = 1}, { id = 16, count = 2000}, { id = 0, count = 0}, },icon = 5049 },
	{id = 2, stageDesc = '亞軍', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 75}, { id = 66787, count = 1}, { id = 16, count = 1800}, { id = 0, count = 0}, },icon = 5050 },
	{id = 4, stageDesc = '4強', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 65}, { id = 66788, count = 1}, { id = 16, count = 1600}, { id = 0, count = 0}, },icon = 5051 },
	{id = 8, stageDesc = '8強', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 55}, { id = 66789, count = 1}, { id = 16, count = 1400}, { id = 0, count = 0}, },icon = 0 },
	{id = 16, stageDesc = '16強', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 45}, { id = 66790, count = 1}, { id = 16, count = 1200}, { id = 0, count = 0}, },icon = 0 },
	{id = 32, stageDesc = '32強', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 35}, { id = 66791, count = 1}, { id = 16, count = 1000}, { id = 0, count = 0}, },icon = 0 },
	{id = 64, stageDesc = '64強', leaderReward ={{ id = 66800, count = 1}, { id = 0, count = 0}, }, memberReward ={{ id = 67267, count = 25}, { id = 66792, count = 1}, { id = 16, count = 800}, { id = 0, count = 0}, },icon = 0 },
};

i3k_db_fightTeam_honor_reward =
{
	{id = 1, rankDesc = '1', honorReward ={{ id = 5, count = 16200}, { id = 16, count = 3200}, { id = 66816, count = 50}, { id = 66444, count = 2}, },icon = 2718 },
	{id = 2, rankDesc = '2', honorReward ={{ id = 5, count = 14400}, { id = 16, count = 3000}, { id = 66816, count = 30}, { id = 66444, count = 2}, },icon = 2719 },
	{id = 3, rankDesc = '3', honorReward ={{ id = 5, count = 12600}, { id = 16, count = 2800}, { id = 66816, count = 25}, { id = 66444, count = 2}, },icon = 2720 },
	{id = 4, rankDesc = '4', honorReward ={{ id = 5, count = 10800}, { id = 16, count = 2650}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 10, rankDesc = '5-10', honorReward ={{ id = 5, count = 9900}, { id = 16, count = 2500}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 20, rankDesc = '11-20', honorReward ={{ id = 5, count = 8100}, { id = 16, count = 2350}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 30, rankDesc = '21-30', honorReward ={{ id = 5, count = 7200}, { id = 16, count = 2200}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 50, rankDesc = '31-50', honorReward ={{ id = 5, count = 6300}, { id = 16, count = 2050}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 100, rankDesc = '51-100', honorReward ={{ id = 5, count = 5400}, { id = 16, count = 1900}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 200, rankDesc = '101-200', honorReward ={{ id = 5, count = 4500}, { id = 16, count = 1750}, { id = 66816, count = 20}, { id = 66444, count = 2}, },icon = 0 },
	{id = 400, rankDesc = '201-400', honorReward ={{ id = 5, count = 3600}, { id = 16, count = 1600}, { id = 66816, count = 20}, { id = 66444, count = 1}, },icon = 0 },
	{id = 500, rankDesc = '401-500', honorReward ={{ id = 5, count = 2700}, { id = 16, count = 800}, { id = 66816, count = 20}, { id = 66444, count = 1}, },icon = 0 },
	{id = 700, rankDesc = '500+', honorReward ={{ id = 0, count = 0}, { id = 0, count = 0}, { id = 66816, count = 12}, { id = 66444, count = 1}, },icon = 0 },
};

i3k_db_fightTeam_group_name =
{
	[1] = { name = '武皇組'},
	[2] = { name = '武帝組'},
};
