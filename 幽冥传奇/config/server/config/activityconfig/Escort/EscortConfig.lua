
--#include "..\..\..\language\LangCode.txt"
EscortConfig  =
{
	factor = 2,
    level = {0, 70},
	Times = 3,
	IncTimes = 0,
	IncTimesItem = {type = 0 ,id = 1, count = 1},
	EscortTime = 600,
	EscortSrc =  {npcid = 168, sceneid = 4, x = 56, y = 92},
    EscortNpcDist = 20,
	EscortDest = {sceneid = 5, x = 50, y = 40,npcid=169},
	NpcId = 168,
	MobTimer = 1000,
	CheckTimer = 1,
	FinishsuccDist = 10,
	OpenNpcDist = 5,
	distance = {3, 18},
	forbidTime 	= {{{19,50},{21,00}}},
	dieDropPrcent = 0.1,
	dieDropCount = 2,
	Monsters =
	{
		{ monid = 438, sceneid  = 46, x = 53, y = 399,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 63, y = 389,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 77, y = 387,livetime = 1800},
		{ monid = 445, sceneid  = 46, x = 87, y = 381,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 87, y = 365,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 80, y = 347,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 69, y = 336,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 65, y = 322,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 57, y = 310,livetime = 1800},
		{ monid = 444, sceneid  = 46, x = 47, y = 300,livetime = 1800},
		{ monid = 445, sceneid  = 46, x = 41, y = 284,livetime = 1800},
		{ monid = 445, sceneid  = 46, x = 39, y = 264,livetime = 1800},
		{ monid = 445, sceneid  = 46, x = 40, y = 246,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 48, y = 230,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 62, y = 222,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 74, y = 212,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 84, y = 204,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 95, y = 195,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 109, y = 191,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 121, y = 190,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 134, y = 190,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 147, y = 191,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 160, y = 193,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 176, y = 199,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 188, y = 189,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 196, y = 179,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 208, y = 173,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 224, y = 173,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 236, y = 173,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 249, y = 174,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 265, y = 174,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 279, y = 174,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 295, y = 176,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 307, y = 176,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 319, y = 174,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 331, y = 174,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 342, y = 175,livetime = 1800},
		{ monid = 440, sceneid  = 46, x = 360, y = 185,livetime = 1800},
		{ monid = 440, sceneid  = 46, x = 377, y = 195,livetime = 1800},
		{ monid = 440, sceneid  = 46, x = 389, y = 208,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 402, y = 216,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 413, y = 208,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 425, y = 194,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 436, y = 183,livetime = 1800},
		{ monid = 438, sceneid  = 46, x = 447, y = 172,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 459, y = 166,livetime = 1800},
		{ monid = 439, sceneid  = 46, x = 469, y = 166,livetime = 1800},
	},
	OneKeyConsumes =
	{
	   	{
	      type = 10, id = 0, count = 1000,
	   	},
	},
    EscortList =
	{
		{
			id = 1130,
			livetime = 1800,
			name  = Lang.ScriptTips.EscortName001,
			desc =  Lang.ScriptTips.EscortDesc001,
			broadcast = false,
			buffid = 986,
			rate = {6000, 3000, 600, 300, 100},
			ConsumeCfg =
			{
			   	{
			      type = 3, id = 0, count = 200000,
			   	},
			},
			AwardCfg  =
			{
                {
				    cond = {1, 9999},
				    Award =
                    {
      			       { type = 1, id = 0, count = 2500000},
      			       { type = 5, id = 0, count = 500},
				    }
				},
			},
		},
		{
			id = 1131,
			livetime = 1800,
			name  = Lang.ScriptTips.EscortName002,
			desc =  Lang.ScriptTips.EscortDesc002,
			buffid = 986,
			broadcast = false,
			rate = {7000, 2300, 600, 100},
			ConsumeCfg =
			{
			   	{
			      	type = 3, id = 0, count = 200000,
			   	},
			},
			AwardCfg  =
			{
                {
				    cond = {1, 9999},
				    Award =
                    {
						{ type = 1, id = 0, count = 5000000},
 						{ type = 5, id = 0, count = 1500},
				    }
				},
			},
		},
		{
			id = 1132,
			livetime = 1800,
			name  = Lang.ScriptTips.EscortName003,
			desc =  Lang.ScriptTips.EscortDesc003,
			buffid = 986,
			broadcast = true,
			rate = {8000, 1900, 100},
			ConsumeCfg =
			{
			   	{
			      	type = 3, id = 0, count = 200000,
			   	},
			},
			AwardCfg  =
			{
               {
				    cond = {1, 9999},
				    Award =
                    {
      			       { type = 1, id = 0, count = 7500000},
      			       { type = 5, id = 0, count = 3000},
				    }
				},
			},
		},
		{
			id = 1133,
			livetime = 1800,
			name  = Lang.ScriptTips.EscortName004,
			desc =  Lang.ScriptTips.EscortDesc004,
			buffid = 986,
			broadcast = true,
			rate = {9000, 1000},
			ConsumeCfg =
			{
			  	{
			      	type = 3, id = 0, count = 200000,
			   	},
			},
			AwardCfg  =
			{
                {
				    cond = {1, 9999},
				    Award =
                    {
                       { type = 1, id = 0, count = 10000000},
      			       { type = 5, id = 0, count = 5000},
				    }
				},
			},
		},
		{
			id = 1134,
			livetime = 1800,
			name  = Lang.ScriptTips.EscortName005,
			desc =  Lang.ScriptTips.EscortDesc005,
			buffid = 986,
			broadcast = true,
			rate = {10000},
			ConsumeCfg =
			{
			},
			AwardCfg  =
			{
                {
				    cond = {1, 9999},
				    Award =
                    {
      			       { type = 1, id = 0, count = 12500000},
      			       { type = 5, id = 0, count = 7500},
				    }
				},
			},
		},
	},
}