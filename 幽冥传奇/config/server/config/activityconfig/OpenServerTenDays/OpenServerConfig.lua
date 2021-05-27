
--#include "data\language\LangCode.txt" once
OpenServerConfig =
{
	activitys =
	{
		{
			openDays = 1,
			rankName = "OpenServerTenDays1",
			fileName = "OpenServerTenDays1.txt",
			minLevel = 50,
			columnName =
			{
				{cName = Lang.Activity.w00073,},
				{cName = Lang.Activity.w00074,},
				{cName = Lang.Activity.w00075,},
				{cName = Lang.Activity.w00076,},
				{cName = Lang.Activity.w00077,},
				{cName = Lang.Activity.w00078,},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 181, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1},
				{ type = 0, id = 190, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2},
				{ type = 0, id = 199, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3},
			},
			allAwards =
			{
				{ type = 0, id = 754, count = 1, bind = 0, strong = 0, quality = 0, sex = 0},
				{ type = 0, id = 755, count = 1, bind = 0, strong = 0, quality = 0, sex = 1},
			},
			needValue = 1,
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 2,
			rankName = "OpenServerTenDays2",
			fileName = "OpenServerTenDays2.txt",
			columnName =
			{
				{cName = "type",},
				{cName = "name",},
				{cName = "shape",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 182, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 0, job = 1},
				{ type = 0, id = 191, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 0, job = 2},
				{ type = 0, id = 200, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 0, job = 3},
				{ type = 0, id = 183, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 1, job = 1 },
				{ type = 0, id = 192, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 1, job = 2 },
				{ type = 0, id = 201, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, sex = 1, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 416, count = 1, strong = 0, quality = 0, bind = 1 },
				{ type = 0, id = 655, count = 5, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 10,
			monster =
			{
				{nSceenId=8, nMonsterID = 192, posX1 = 190, posX2 = 190,  posY = 208, nCount = 1, nLiveTime = 0,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 3,
			rankName = "OpenServerTenDays3",
			fileName = "OpenServerTenDays3.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
				{cName = "id",},
				{cName = "name",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 188, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1 },
				{ type = 0, id = 197, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2 },
				{ type = 0, id = 206, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 574, count = 1000, strong = 0, quality = 0, bind = 1 },
				{ type = 0, id = 655, count = 5, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 4,
			AddBuff =
			{
				{buffType= 64, value=2, buffGroup= 106,times =1,interval= 1800,needDelete = true,timeOverlay = true,buffName = Lang.Activity.t00059,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 4,
			rankName = "OpenServerTenDays4",
			fileName = "OpenServerTenDays4.txt",
			columnName =
			{
				{cName = "name",},
				{cName = "swingid",},
				{cName = "swinglevel",},
				{cName = "battle",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 189, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1 },
				{ type = 0, id = 198, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2 },
				{ type = 0, id = 207, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 402, count = 100, strong = 0, quality = 0, bind = 1 },
				{ type = 0, id = 655, count = 5, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 286,
			AddBuff =
			{
				{buffType= 64, value=2, buffGroup= 106,times =1,interval= 1800,needDelete = true,timeOverlay = true,buffName = Lang.Activity.t00050,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 5,
			rankName = "OpenServerTenDays5",
			fileName = "OpenServerTenDays5.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
				{cName = "id",},
				{cName = "name",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 184, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1 },
				{ type = 0, id = 193, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2 },
				{ type = 0, id = 202, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 655, count = 1, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 2,
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 6,
			rankName = "OpenServerTenDays6",
			fileName = "OpenServerTenDays6.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
				{cName = "id",},
				{cName = "name",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 185, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1 },
				{ type = 0, id = 194, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2 },
				{ type = 0, id = 203, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 336, count = 2, strong = 0, quality = 0, bind = 1 },
				{ type = 0, id = 655, count = 5, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 465,
			monster =
			{
				{nSceenId=8, nMonsterID = 192, posX1 = 190, posX2 = 190,  posY = 208, nCount = 1, nLiveTime = 0,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 7,
			rankName = "OpenServerTenDays7",
			fileName = "OpenServerTenDays7.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 186, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 1 },
				{ type = 0, id = 195, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 2 },
				{ type = 0, id = 204, count = 1, strong = 8, quality = 0, bind = 0, circle = 3, job = 3 },
			},
			allAwards =
			{
				{ type = 0, id = 337, count = 2, strong = 0, quality = 0, bind = 1 },
				{ type = 0, id = 655, count = 5, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 7,
			monster =
			{
				{nSceenId=8, nMonsterID = 192, posX1 = 190, posX2 = 190,  posY = 208, nCount = 1, nLiveTime = 0,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 8,
			rankName = "OpenServerTenDays8",
			fileName = "OpenServerTenDays8.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
				{cName = "id",},
				{cName = "name",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 208, count = 2, strong = 0, quality = 0, bind = 0, job = 1 },
				{ type = 0, id = 217, count = 2, strong = 0, quality = 0, bind = 0, job = 2 },
				{ type = 0, id = 226, count = 2, strong = 0, quality = 0, bind = 0, job = 3 },
			},
			allAwards =
			{
				{ type = 5, id = 0, count = 300000000, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 5,
			monster =
			{
				{nSceenId=8, nMonsterID = 192, posX1 = 190, posX2 = 190,  posY = 208, nCount = 1, nLiveTime = 0,},
			},
			effectId = 1,
			lastTime = 60,
		},
		{
			openDays = 9,
			rankName = "OpenServerTenDays9",
			fileName = "OpenServerTenDays9.txt",
			columnName =
			{
				{cName = "jop",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			allAwards =
			{
				{ type = 0, id = 969, count = 1, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 300,
			AddBuff =
			{
				{buffType= 64, value=2, buffGroup= 106,times =1,interval= 1800,needDelete = true,timeOverlay = true,buffName = Lang.Activity.t00057,},
			},
			AuthenScroe = 1,
			ClearScroe = 6,
			SuoScroe = 6,
		},
		{
			openDays = 10,
			rankName = "OpenServerTenDays10",
			fileName = "OpenServerTenDays10.txt",
			columnName =
			{
				{cName = "name",},
				{cName = "jop",},
				{cName = "state",},
			},
			awards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			firstAwards =
			{
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
				{ type = 0, id = 574, count = 1, strong = 0, quality = 0, bind = 0 },
			},
			allAwards =
			{
				{ type = 0, id = 970, count = 1, strong = 0, quality = 0, bind = 1 },
			},
			needValue = 2000,
			effectId = 1,
			lastTime = 30,
		},
	},
}
