
--#include "..\..\language\LangCode.txt" once
XiangYaoChuMoCfg =
{
	openLevel = 180,
	NpcMapId = 2,
	NpcPos = {65, 129},
	maxTimes = 10,
	opensv = 1,
	shuaXin = {10, 60,},
	shuaXinCousume = {{type = 6, id = 0, count=10000,},},
	starNum = {1, 3},
	killCount = {10, 15},
	HuSongNpcPos = {215, 126},
	awardMults = {1, 2,},
	maxBuyTms = 10,
	buyTmsCost = {{type = 15, id = 0, count = 200,},},
	doubleConsumeBindYb = {{type = 15, id = 0, count=198,},},
	oneKeyBindYb = {{type = 15, id = 0, count=198,},},
	YuanBaoRatio = 1,
	yuanBaoConsumeTips = "是否消耗{wordcolor;ff2828;%d}钻石",
	enterSence =
	{
		[6] =
		{
			minlv = 1,
			maxlv = 199,
			senceId = 6,
			area = {30, 6, 53, 26},
			name = Lang.EntityName.m6,
			monsterIds = {15},
		},
		[8] =
		{
			minlv = 200,
			maxlv = 299,
			senceId = 8,
			area = {37, 136, 53, 153},
			name = Lang.EntityName.m8,
			monsterIds = {18},
		},
		[12] =
		{
			minlv = 300,
			maxlv = 400,
			senceId = 12,
			area = {61, 77, 83, 99},
			name = Lang.EntityName.m514,
			monsterIds = {30},
		},
		[16] =
		{
			minlv = 401,
			maxlv = 500,
			senceId = 16,
			area = {104, 30, 127, 54},
			name = Lang.EntityName.m21,
			monsterIds = {42},
		},
		[20] =
		{
			minlv = 501,
			maxlv = 600,
			senceId = 20,
			area = {15, 6, 45, 30},
			name = Lang.EntityName.m26,
			monsterIds = {54},
		},
		[24] =
		{
			minlv = 601,
			maxlv = 700,
			senceId = 24,
			area = {15, 114, 40, 139},
			name = Lang.EntityName.m26,
			monsterIds = {64},
		},
		[27] =
		{
			minlv = 701,
			maxlv = 2000,
			senceId = 27,
			area = {73, 49, 94, 70},
			name = Lang.EntityName.m26,
			monsterIds = {75},
		},
	},
	reward =
	{
		[1] =
		{
			minLv = 1,
			maxLv = 199,
			awards =
			{
[1] = {{type = 0, id =2, count = 1 , bind = 1,},},
[2] = {{type = 0, id =2, count = 2 , bind = 1,},},
[3] = {{type = 0, id =2, count = 3 , bind = 1,},},
[4] = {{type = 0, id =2, count = 4 , bind = 1,},},
[5] = {{type = 0, id =2, count = 5 , bind = 1,},},
[6] = {{type = 0, id =2, count = 6 , bind = 1,},},
[7] = {{type = 0, id =2, count = 7 , bind = 1,},},
[8] = {{type = 0, id =2, count = 8 , bind = 1,},},
[9] = {{type = 0, id =2, count = 9 , bind = 1,},},
[10] = {{type = 0, id =2, count = 10 , bind = 1,},},
			},
		},
		[2] =
		{
			minLv = 200,
			maxLv = 299,
			awards =
			{
[1] = {{type = 0, id =3, count = 2 , bind = 1,},},
[2] = {{type = 0, id =3, count = 3 , bind = 1,},},
[3] = {{type = 0, id =3, count = 5 , bind = 1,},},
[4] = {{type = 0, id =3, count = 6 , bind = 1,},},
[5] = {{type = 0, id =3, count = 8 , bind = 1,},},
[6] = {{type = 0, id =3, count = 9 , bind = 1,},},
[7] = {{type = 0, id =3, count = 11 , bind = 1,},},
[8] = {{type = 0, id =3, count = 12 , bind = 1,},},
[9] = {{type = 0, id =3, count = 14 , bind = 1,},},
[10] = {{type = 0, id =3, count = 15 , bind = 1,},},
			},
		},
		[3] =
		{
			minLv = 300,
			maxLv = 400,
			awards =
			{
[1] = {{type = 0, id =22, count = 3 , bind = 1,},},
[2] = {{type = 0, id =22, count = 6 , bind = 1,},},
[3] = {{type = 0, id =22, count = 9 , bind = 1,},},
[4] = {{type = 0, id =22, count = 12 , bind = 1,},},
[5] = {{type = 0, id =22, count = 15 , bind = 1,},},
[6] = {{type = 0, id =22, count = 18 , bind = 1,},},
[7] = {{type = 0, id =22, count = 21 , bind = 1,},},
[8] = {{type = 0, id =22, count = 24 , bind = 1,},},
[9] = {{type = 0, id =22, count = 27 , bind = 1,},},
[10] = {{type = 0, id =22, count = 30 , bind = 1,},},
			},
		},
		[4] =
		{
			minLv = 401,
			maxLv = 500,
			awards =
			{
[1] = {{type = 0, id =22, count = 5 , bind = 1,},},
[2] = {{type = 0, id =22, count = 10 , bind = 1,},},
[3] = {{type = 0, id =22, count = 15 , bind = 1,},},
[4] = {{type = 0, id =22, count = 20 , bind = 1,},},
[5] = {{type = 0, id =22, count = 25 , bind = 1,},},
[6] = {{type = 0, id =22, count = 30 , bind = 1,},},
[7] = {{type = 0, id =22, count = 35 , bind = 1,},},
[8] = {{type = 0, id =22, count = 40 , bind = 1,},},
[9] = {{type = 0, id =22, count = 45 , bind = 1,},},
[10] = {{type = 0, id =22, count = 50 , bind = 1,},},
			},
		},
		[5] =
		{
			minLv = 501,
			maxLv = 600,
			awards =
			{
[1] = {{type = 0, id =22, count = 8 , bind = 1,},},
[2] = {{type = 0, id =22, count = 16 , bind = 1,},},
[3] = {{type = 0, id =22, count = 24 , bind = 1,},},
[4] = {{type = 0, id =22, count = 32 , bind = 1,},},
[5] = {{type = 0, id =22, count = 40 , bind = 1,},},
[6] = {{type = 0, id =22, count = 48 , bind = 1,},},
[7] = {{type = 0, id =22, count = 56 , bind = 1,},},
[8] = {{type = 0, id =22, count = 64 , bind = 1,},},
[9] = {{type = 0, id =22, count = 72 , bind = 1,},},
[10] = {{type = 0, id =22, count = 80 , bind = 1,},},
			},
		},
		[6] =
		{
			minLv = 601,
			maxLv = 700,
			awards =
			{
[1] = {{type = 0, id =22, count = 10 , bind = 1,},},
[2] = {{type = 0, id =22, count = 20 , bind = 1,},},
[3] = {{type = 0, id =22, count = 30 , bind = 1,},},
[4] = {{type = 0, id =22, count = 40 , bind = 1,},},
[5] = {{type = 0, id =22, count = 50 , bind = 1,},},
[6] = {{type = 0, id =22, count = 60 , bind = 1,},},
[7] = {{type = 0, id =22, count = 70 , bind = 1,},},
[8] = {{type = 0, id =22, count = 80 , bind = 1,},},
[9] = {{type = 0, id =22, count = 90 , bind = 1,},},
[10] = {{type = 0, id =22, count = 100 , bind = 1,},},
			},
		},
		[7] =
		{
			minLv = 701,
			maxLv = 2000,
			awards =
			{
[1] = {{type = 0, id =22, count = 15 , bind = 1,},},
[2] = {{type = 0, id =22, count = 30 , bind = 1,},},
[3] = {{type = 0, id =22, count = 45 , bind = 1,},},
[4] = {{type = 0, id =22, count = 60 , bind = 1,},},
[5] = {{type = 0, id =22, count = 75 , bind = 1,},},
[6] = {{type = 0, id =22, count = 90 , bind = 1,},},
[7] = {{type = 0, id =22, count = 105 , bind = 1,},},
[8] = {{type = 0, id =22, count = 120 , bind = 1,},},
[9] = {{type = 0, id =22, count = 135 , bind = 1,},},
[10] = {{type = 0, id =22, count = 150 , bind = 1,},},
			},
		},
	},
}