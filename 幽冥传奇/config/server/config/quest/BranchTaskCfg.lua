
BranchTaskConfig = {
	{
		needLevel = 57,
		Award = {
				{type = 0, id = 541, count = 10,bind = 1},
			    },
		condition = {type=6,params={}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n<创建或者加入行会/@@showWin,7>\n{color;FFFFF0000;奖励:}{color;FFFF07800;精羽毛*10}<领奖/@@GetbranchAward,1>\n",
        broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线1任务,获得{color;FFF00ff00;精羽毛*10}的奖励!",
       -- ttwindowDesc = "未知暗殿\n可爆出:60、65、70级装备",
       -- btnLink = "M卧龙城:185:184:未知暗殿",
	},
	{
		needLevel = 68,
		Award = {
				{type = 2, id = 0, count = 10000000,bind = 1},
				{type = 5, id = 0, count = 3000000,bind = 1},
			    },
		condition = {type=4,params={{69}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;等级达到}{color;FFF00FF00;69}{color;FFFFF0000;级}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;1000W经验、300W绑金}<领奖/@@GetbranchAward,2>\n",
        broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线2任务,获得{color;FFF00ff00;1000W经验、300W绑金}的奖励!",
       -- ttwindowDesc = "未知暗殿\n可爆出:60、65、70级装备",
       -- btnLink = "M卧龙城:185:184:未知暗殿",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 10000000, bind = 1},
			        {type = 0, id = 631, count = 1, bind = 1},
			    },
		condition = {type=2,params={{65},{6}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;6件}{color;FFFFF0000;65级以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;1000W经验、2级宝石礼包}<领奖/@@GetbranchAward,3>\n{color;FFFFF0000;推荐:}<礼包/@@showWin,158> <未知暗殿/M卧龙城:186:185:未知暗殿><(x卧龙城:186:185:未知暗殿)> <合成/@@showWin,120>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线3任务,获得{color;FFF00ff00;1000W经验、2级宝石礼包}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 20000000, bind = 1},
			        {type = 631, id = 0, count = 2, bind = 1},
			    },
		condition = {type=2,params={{70},{6}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;70级以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;2000W经验、2级宝石礼包*2}<领奖/@@GetbranchAward,4>\n{color;FFFFF0000;推荐:}<宝藏/@@showWin,31> <未知暗殿/M卧龙城:186:185:未知暗殿><(x卧龙城:186:185:未知暗殿)> <合成/@@showWin,120>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线4任务,获得{color;FFF00ff00;2000W经验、2级宝石礼包*2}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 30000000, bind = 1},
			        {type = 0, id = 632, count = 1, bind = 1},
			    },
		condition = {type=2,params={{75},{6}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;75级以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;3000W经验、3级宝石礼包*1}<领奖/@@GetbranchAward,5>\n{color;FFFFF0000;推荐:}<BOSS/@@showWin,96>  <合成/@@showWin,120>  <宝藏/@@showWin,31>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线5任务,获得{color;FFF00ff00;3000W经验、3级宝石礼包*1}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 50000000, bind = 1},
			        {type = 0, id = 632, count = 3, bind = 1},
			    },
		condition = {type=5,params={{80},{6}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;3转以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;5000W经验、3级宝石礼包*3}<领奖/@@GetbranchAward,6>\n{color;FFFFF0000;推荐:}<BOSS/@@showWin,96>  <宝藏/@@showWin,31>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线6任务,获得{color;FFF00ff00;--5000W经验、3级宝石礼包*3}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 80000000, bind = 1},
			        {type = 0, id = 633, count = 2, bind = 1},
			    },
		condition = {type=5,params={{1},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;1转以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;8000W经验、4级宝石礼包*2}<领奖/@@GetbranchAward,7>\n{color;FFFFF0000;推荐:}<BOSS/@@showWin,96>  <宝藏/@@showWin,31>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线7任务,获得{color;FFF00ff00;8000W经验、4级宝石礼包*2}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 120000000, bind = 1},
			        {type = 0, id = 633, count = 3, bind = 1},
			    },
		condition = {type=5,params={{3},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;3转以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;1.2亿经验、4级宝石礼包*3}<领奖/@@GetbranchAward,8>\n{color;FFFFF0000;推荐:}<BOSS/@@showWin,96>  <宝藏/@@showWin,31>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线8任务,获得{color;FFF00ff00;--1.2亿经验、4级宝石礼包*3}的奖励!",
	},
	{
		needLevel = 66,
		Award = {
				{type = 2, id = 0, count = 200000000, bind = 1},
			        {type = 0, id = 634, count = 3, bind = 1},
			    },
		condition = {type=5,params={{5},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;穿戴}{color;FFF00FF00;5件}{color;FFFFF0000;3转以上装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;2亿经验、5级宝石礼包*3}<领奖/@@GetbranchAward,9>\n{color;FFFFF0000;推荐:}<BOSS/@@showWin,96>  <宝藏/@@showWin,31>\n",
                broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线9任务,获得{color;FFF00ff00;--2亿经验、5级宝石礼包*3}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 200, bind = 1},
			        {type = 5, id = 0, count = 2000000, bind = 1},
			    },
		condition = {type=3,params={{3},{3}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;3件}{color;FFFFF0000;+3的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;200绑元、200万绑金}<领奖/@@GetbranchAward,10>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,3>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线10任务,获得{color;FFF00ff00;200绑元、200万绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 300, bind = 1},
			        {type = 5, id = 0, count = 3000000, bind = 1},
			    },
		condition = {type=3,params={{3},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+3的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;300绑元、300万绑金}<领奖/@@GetbranchAward,11>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,3>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线11任务,获得{color;FFF00ff00;300绑元、300万绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 400, bind = 1},
			        {type = 5, id = 0, count = 4000000, bind = 1},
			    },
		condition = {type=3,params={{5},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+5的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;400绑元、400W绑金}<领奖/@@GetbranchAward,12>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,5>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线12任务,获得{color;FFF00ff00;400绑元、400W绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 500, bind = 1},
			        {type = 5, id = 0, count = 5000000, bind = 1},
			    },
		condition = {type=3,params={{6},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+6的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;500绑元、500W绑金}<领奖/@@GetbranchAward,13>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,6>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线13任务,获得{color;FFF00ff00;500绑元、500W绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 600, bind = 1},
			        {type = 5, id = 0, count = 6000000, bind = 1},
			    },
		condition = {type=3,params={{7},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+7的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;600绑元、600W绑金}<领奖/@@GetbranchAward,14>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,7>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线14任务,获得{color;FFF00ff00;600绑元、600W绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 700, bind = 1},
			        {type = 5, id = 0, count = 7000000, bind = 1},
			    },
		condition = {type=3,params={{8},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+8的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;700绑元、700W绑金}<领奖/@@GetbranchAward,15>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,8>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线15任务,获得{color;FFF00ff00;700绑元、700W绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 800, bind = 1},
			        {type = 5, id = 0, count = 8000000, bind = 1},
			    },
		condition = {type=3,params={{9},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+9的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;800绑元、800W绑金}<领奖/@@GetbranchAward,16>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,9>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线16任务,获得{color;FFF00ff00;800绑元、800W绑金}的奖励!",
	},
	{
		needLevel = 70,
		Award = {
				{type = 7, id = 0, count = 900, bind = 1},
			        {type = 5, id = 0, count = 9000000, bind = 1},
			    },
		condition = {type=3,params={{10},{5}}},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;强化}{color;FFF00FF00;5件}{color;FFFFF0000;+10的装备}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;900绑元、900W绑金}<领奖/@@GetbranchAward,17>\n{color;FFFFF0000;推荐:}<强化装备/@@showWin,10>\n",
	    broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线17任务,获得{color;FFF00ff00;900绑元、900W绑金}的奖励!",
	},
--		branchTaskDesc = "{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;消灭}{color;FFF00FF00;1只}{color;FFFFF0000;堕落魔域BOSS}%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;8000W经验、600W绑金}<领奖/@@GetbranchAward,5>\n{color;FFFFF0000;推荐:}<堕落魔域/M卧龙城:183:177:堕落魔域><(x卧龙城:183:177:堕落魔域)> <组队完成/@@showWin,30>\n",
--		broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线5任务,获得{color;FFF00ff00;8000W经验、600W绑金}的奖励!",
	{
		needLevel = 69,
		Award = {
				{type = 2, id = 0, count = 110000000,bind = 1},
			        {type = 5, id = 0, count = 9000000,bind = 1},
			    },
		condition = {type=1,params={{6},{},{135,136,137,138,139,140,141,142,143,239,240,241,242,243,244,245,246,247,248}},},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;消灭}{color;FFF00FF00;6只}<任意世界BOSS/@@showWin,96,1>%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;1.1亿经验、900W绑金}<领奖/@@GetbranchAward,9>\n{color;FFFFF0000;推荐:}<打开BOSS面板/@@showWin,96,1>\n",
	        broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线18任务,获得{color;FFF00ff00;1.1亿经验、900W绑金}的奖励!",
	},
	{
		needLevel = 69,
		Award = {
				{type = 2, id = 0, count = 200000000,bind = 1},
			        {type = 5, id = 0, count = 10000000,bind = 1},
			    },
		condition = {type=1,params={{6},{},{323,324,325,326,327,328,329,330}},},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;消灭}{color;FFF00FF00;6只}<雷泽BOSS/@@showWin,96,4>%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;2亿经验、1000W绑金}<领奖/@@GetbranchAward,10>\n{color;FFFFF0000;推荐:}<打开BOSS面板/@@showWin,96,4>\n",
	        broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线19任务,获得{color;FFF00ff00;2亿经验、1000W绑金}的奖励!",
	},
	{
		needLevel = 69,
		Award = {
				{type = 2, id = 0, count = 600000000,bind = 1},
			        {type = 5, id = 0, count = 20000000,bind = 1},
			    },
		condition = {type=1,params={{4},{49},{474,475,476,477,478,479,480,481}},},
		branchTaskDesc = "\n{color;FFFFFFF00;[支线任务]}\n{color;FFFFF0000;消灭}{color;FFF00FF00;4只}<狂暴BOSS/@@showWin,96,5>%s\n{color;FFFFF0000;奖励:}{color;FFFF07800;6亿经验、2000W绑金}<领奖/@@GetbranchAward,13>\n{color;FFFFF0000;推荐:}<打开BOSS面板/@@showWin,96,5>\n",
	        broadcastDesc = "恭喜{color;FFF00ff00;%s}完成支线20任务,获得{color;FFF00ff00;6亿经验、2000W绑金}的奖励!",
	},
}