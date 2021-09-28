i3k_db_lucky_pack_cfg = {
	needLvl = 55, 
	validTime = 1517932800, 
	invalidTime = 1519747200, 
	openDate = 1518019200, 
	openTime = 36000, 
	closeDate = 1519488000, 
	closeTime = 82800, 
	bagID = 1
};
i3k_db_lucky_pack_task = {
	[1] = { taskType = 1, args = 0, score = 15, desc = '每日首次登陸' },
	[2] = { taskType = 2, args = 80, score = 15, desc = '每日活躍度達到80' },
	[3] = { taskType = 2, args = 150, score = 20, desc = '每日活躍度達到150' },
	[4] = { taskType = 2, args = 240, score = 20, desc = '每日活躍度達到240' },
	[5] = { taskType = 2, args = 300, score = 20, desc = '每日活躍度達到300' },
	[6] = { taskType = 3, args = 200, score = 10, desc = '消耗200綁定元寶或元寶（寄售行除外）' },
};

i3k_db_lucky_pack_reward = {
	[1] = { bagName = '一級福袋', bagIcon = 5625, bagDesc = '一級福袋為默認福袋', upgradeDesc = '無獎勵，請儘快升級福袋', needScore = 0, needSpace = 3, upgradeReward = {{ id = 0, count = 0}, { id = 0, count = 0}, }, levels = {60,70,80,90,100,}, drop1 = {dropId = 21100, randDropId = 1100016, randDropCnt = 2}, drop2 = {dropId = 21100, randDropId = 1100016, randDropCnt = 2}, drop3 = {dropId = 21100, randDropId = 1100016, randDropCnt = 2}, drop4 = {dropId = 21100, randDropId = 1100017, randDropCnt = 2}, drop5 = {dropId = 21100, randDropId = 1100017, randDropCnt = 2}, },
	[2] = { bagName = '二級福袋', bagIcon = 5626, bagDesc = '一級福袋升級二級福袋', upgradeDesc = '升級二級福袋需100積分', needScore = 100, needSpace = 9, upgradeReward = {{ id = 66576, count = 1}, { id = 65560, count = 1}, }, levels = {60,70,80,90,100,}, drop1 = {dropId = 21101, randDropId = 1100016, randDropCnt = 8}, drop2 = {dropId = 21101, randDropId = 1100016, randDropCnt = 8}, drop3 = {dropId = 21101, randDropId = 1100016, randDropCnt = 8}, drop4 = {dropId = 21101, randDropId = 1100017, randDropCnt = 8}, drop5 = {dropId = 21101, randDropId = 1100017, randDropCnt = 8}, },
	[3] = { bagName = '三級福袋', bagIcon = 5627, bagDesc = '二級福袋升級三級福袋', upgradeDesc = '升級三級福袋需300積分', needScore = 300, needSpace = 11, upgradeReward = {{ id = 66576, count = 1}, { id = 65560, count = 1}, }, levels = {60,70,80,90,100,}, drop1 = {dropId = 21102, randDropId = 1100016, randDropCnt = 10}, drop2 = {dropId = 21102, randDropId = 1100016, randDropCnt = 10}, drop3 = {dropId = 21102, randDropId = 1100016, randDropCnt = 10}, drop4 = {dropId = 21102, randDropId = 1100017, randDropCnt = 10}, drop5 = {dropId = 21102, randDropId = 1100017, randDropCnt = 10}, },
	[4] = { bagName = '四級福袋', bagIcon = 5628, bagDesc = '三級福袋升級四極福袋', upgradeDesc = '升級四極福袋需500積分', needScore = 500, needSpace = 11, upgradeReward = {{ id = 66576, count = 1}, { id = 65560, count = 1}, }, levels = {60,70,80,90,100,}, drop1 = {dropId = 21103, randDropId = 1100016, randDropCnt = 12}, drop2 = {dropId = 21103, randDropId = 1100016, randDropCnt = 12}, drop3 = {dropId = 21103, randDropId = 1100016, randDropCnt = 12}, drop4 = {dropId = 21103, randDropId = 1100017, randDropCnt = 12}, drop5 = {dropId = 21103, randDropId = 1100017, randDropCnt = 12}, },
	[5] = { bagName = '五級福袋', bagIcon = 5629, bagDesc = '四級福袋升級五級福袋', upgradeDesc = '升級五級福袋需700積分', needScore = 700, needSpace = 11, upgradeReward = {{ id = 66576, count = 1}, { id = 65560, count = 1}, }, levels = {60,70,80,90,100,}, drop1 = {dropId = 21104, randDropId = 1100016, randDropCnt = 15}, drop2 = {dropId = 21104, randDropId = 1100016, randDropCnt = 15}, drop3 = {dropId = 21104, randDropId = 1100016, randDropCnt = 15}, drop4 = {dropId = 21104, randDropId = 1100017, randDropCnt = 15}, drop5 = {dropId = 21104, randDropId = 1100017, randDropCnt = 15}, },
};
