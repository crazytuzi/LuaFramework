DrinkHouse.tbDef = 
{
	SAVE_GROUP = 177;
	SAVE_KEY_DRINK_INVITE = 3;

	NORMAL_MAP = 8011; --普通的进入的地图
	MIN_PLAYER_LEVEL = 20;--进入玩家等级要求
	CHANNEL_NAME = "酒馆";
	CHANNEL_ICON = "#82";
	CHANNEL_COLOR = "ff638b"; --频道文字颜色
	NORMAL_RAND_POS = { --传入随机点
		{2121, 18100};
		{2121, 17644};
		{2628, 178112};
	};

	LEAVE_RAND_POS = {  --离开地图的随机点
		{15, 8529, 16731}; --地图 ，坐标
		{15, 7451, 16621};
		{15, 9337, 16676};
		{15, 6604, 16978};
		{15, 8419, 17604};
		{15, 8452, 15682};
		{15, 8463, 14926};
	};

	WAIYI_HEAD = 6787; --校服第二套头部
	WAIYI_BODY = 6456; --校服第二套外装

	CHAT_SEND_CD = 10; --聊天发送cd
	CHAT_SEND_MAX_COUNT = 1000; --聊天发送次数

	NameSetting = {
		[1] = "ServerSetting/DrinkHouse/MaleName.tab";
		[2] = "ServerSetting/DrinkHouse/FemaleName.tab";
	};

	HIDE_OBJ = { --隐藏的场景物件
		"sn_jiuguan01_jiuzhuo01";
		"sn_jiuguan01_jiuzhuo01 (1)";
		"sn_jiuguan01_jiuzhuo01 (2)";
		"sn_jiuguan01_jiuzhuo01 (3)";
		"xinshou_muzhuo01";
		"xinshou_muzhuo01 (1)";
		"xinshou_muzhuo01 (2)";
		"xinshou_muzhuo01 (3)";
		"xinshou_muzhuo01 (4)";
		"xinshou_muzhuo01 (6)";
		"xinshou_muzhuo01 (9)";
		"xinshou_muzhuo01 (7)";
		"xinshou_muzhuo01 (8)";
		"sn_jiayuan_dengzi01_01";
		"sn_jiayuan_dengzi01_01 (1)";
		"sn_jiayuan_dengzi01_01 (2)";
		"sn_jiayuan_dengzi01_01 (3)";
		"sn_jiayuan_dengzi01_01 (4)";
		"sn_jiayuan_dengzi01_01 (5)";
		"sn_jiayuan_dengzi01_01 (6)";
		"sn_jiayuan_dengzi01_01 (7)";
		"sn_jiayuan_dengzi01_01 (8)";
		"sn_jiayuan_dengzi01_01 (9)";
		"sn_jiayuan_dengzi01_01 (10)";
		"sn_jiayuan_dengzi01_01 (11)";
		"sn_jiayuan_dengzi01_01 (12)";
		"sn_jiayuan_dengzi01_01 (13)";
		"sn_jiayuan_dengzi01_01 (14)";
		"sn_jiayuan_dengzi01_01 (15)";
	};

	AddFurnitureSetting = {--摆放家族配置
		{nTemplate = 1511, nPosX = 5052, nPosY = 5258, nRotation = 255};
		{nTemplate = 1511, nPosX = 5268, nPosY = 5059, nRotation = 360};
		{nTemplate = 1511, nPosX = 5068, nPosY = 4873, nRotation = 90};
		{nTemplate = 1511, nPosX = 4852, nPosY = 5064, nRotation = 180};
		{nTemplate = 1511, nPosX = 4388, nPosY = 5236, nRotation = 255};
		{nTemplate = 1511, nPosX = 4630, nPosY = 5024, nRotation = 360};
		{nTemplate = 1511, nPosX = 4410, nPosY = 4815, nRotation = 90};
		{nTemplate = 1511, nPosX = 4177, nPosY = 5030, nRotation = 180};
		{nTemplate = 1511, nPosX = 6157, nPosY = 8211, nRotation = 255};
		{nTemplate = 1511, nPosX = 6396, nPosY = 8011, nRotation = 360};
		{nTemplate = 1511, nPosX = 6199, nPosY = 7829, nRotation = 90};
		{nTemplate = 1511, nPosX = 6007, nPosY = 8013, nRotation = 180};
		{nTemplate = 1511, nPosX = 6182, nPosY = 8839, nRotation = 255};
		{nTemplate = 1511, nPosX = 6386, nPosY = 8676, nRotation = 360};
		{nTemplate = 1511, nPosX = 6168, nPosY = 8449, nRotation = 90};
		{nTemplate = 1511, nPosX = 5979, nPosY = 8627, nRotation = 180};
		{nTemplate = 10035, nPosX = 3644, nPosY = 6124, nRotation = 90};
		{nTemplate = 10035, nPosX = 3506, nPosY = 6236, nRotation = 180};
		{nTemplate = 10035, nPosX = 3993, nPosY = 5939, nRotation = 90};
		{nTemplate = 10035, nPosX = 3857, nPosY = 6053, nRotation = 180};
		{nTemplate = 10035, nPosX = 4469, nPosY = 6005, nRotation = 90};
		{nTemplate = 10035, nPosX = 4334, nPosY = 6120, nRotation = 180};
		{nTemplate = 10035, nPosX = 4437, nPosY = 6665, nRotation = 255};
		{nTemplate = 10035, nPosX = 4319, nPosY = 6525, nRotation = 180};
		{nTemplate = 10035, nPosX = 4438, nPosY = 6937, nRotation = 90};
		{nTemplate = 10035, nPosX = 4322, nPosY = 7061, nRotation = 180};
		{nTemplate = 10035, nPosX = 4659, nPosY = 7862, nRotation = 90};
		{nTemplate = 10035, nPosX = 4533, nPosY = 7981, nRotation = 180};
		{nTemplate = 10035, nPosX = 5228, nPosY = 7852, nRotation = 90};
		{nTemplate = 10035, nPosX = 5100, nPosY = 7983, nRotation = 180};
		{nTemplate = 10035, nPosX = 5229, nPosY = 8253, nRotation = 90};
		{nTemplate = 10035, nPosX = 5083, nPosY = 8378, nRotation = 180};
		{nTemplate = 10035, nPosX = 4659, nPosY = 8272, nRotation = 90};
		{nTemplate = 10035, nPosX = 4521, nPosY = 8393, nRotation = 180};
	}; 
	AddNpcSetting = {--摆放家族配置
		{nTemplate = 3215, nLevel = 1;  nPosX = 5053, nPosY = 5071, nDir = 0};
		{nTemplate = 3215, nLevel = 1;  nPosX = 4380, nPosY = 5027, nDir = 0};
		{nTemplate = 3215, nLevel = 1;  nPosX = 6171, nPosY = 8005, nDir = 0};
		{nTemplate = 3215, nLevel = 1;  nPosX = 6164, nPosY = 8641, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 3651, nPosY = 6238, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 3992, nPosY = 6062, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 4469, nPosY = 6126, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 4435, nPosY = 6530, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 4437, nPosY = 7069, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 4661, nPosY = 7986, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 5223, nPosY = 7981, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 5221, nPosY = 8380, nDir = 0};
		{nTemplate = 3216, nLevel = 1;  nPosX = 4661, nPosY = 8388, nDir = 0};
	}; 

	nDrinkInviteInterval = 120; --邀请喝酒间隔
	tbDrinkWineRandAction = { --喝酒后的随机反应
		{
			nDuraTime = 20; --持续时间
			nActionID = 26;
			nActionEventID = 5002;
			szNotifyMsg = "%s不胜酒力，喝了一杯就倒地不起。";
			szEndSayMsg = "好大的酒劲！";

		};
		{
			nDuraTime = 30; --持续时间
			bFollow = true;
			nFollowDistance = 200;  --跟战距离
			szNotifyMsg = "%s被%s催眠了，迷迷糊糊的跟着%s走了。";	
			tbRandSay = {
				"我是谁？我在哪儿？前面的人好熟悉呀，别丢下我。";
				"等等我，你不要走，我要和你私奔！";
				"好多蝴蝶呀，好多花呀，我飞呀飞呀~";
			};
			szEndSayMsg = "咦，刚刚发生了什么？我怎么在这里？";
		};
	};
}


DrinkHouse.tbRentDef = {
	NAME = "家族宴席";
	CONTRACT_ITEM = 9502;--合同道具id
	MAX_RENT_TIMES = 2; --家族每周最大承包次数
	RENT_TIME_FROM_TO = { 3600 * 12, 3600 * 24 }; --允许承包的时间范围，当天时间对应秒数
	RENT_MAP = 8012; --地图id
	NORMAL_RAND_POS = { --传入随机点
		{3429, 6572};
		{3657, 6559};
		{3879, 6669};
	};
	RENT_NPC_IN_MAP = 15; --酒馆接引人所在地图
	RENT_NPC_ID = 3213; --酒馆接引人npcId
	szUiHelpKey = "DrinkHouseRent"; --副本界面上的帮助key
	tbGetItemSetting = {
		--头衔等级
		[12] = { 								    nTopInKinNum = 3, nTotalInServer = 60  };
		[11] = {szCloseTimeFrame = "OpenLevel129",  nTopInKinNum = 3, nTotalInServer = 60  };
		[10] = {szCloseTimeFrame = "OpenLevel119",  nTopInKinNum = 3, nTotalInServer = 60  };
		[9]	 = {szCloseTimeFrame = "OpenLevel109",  nTopInKinNum = 3, nTotalInServer = 60  };
		[8]  = { szCloseTimeFrame = "OpenLevel99",  nTopInKinNum = 3, nTotalInServer = 60  };
		[7]  = { szCloseTimeFrame = "OpenLevel89",  nTopInKinNum = 2, nTotalInServer = 40  };
		[6]  = { szCloseTimeFrame = "OpenLevel79",  nTopInKinNum = 2, nTotalInServer = 40  };
		[5]  = { szCloseTimeFrame = "OpenLevel69",  nTopInKinNum = 1, nTotalInServer = 20  };
	};

	SendRentItemMail = {
		To = nil; -- 手动填
		Title = "头衔奖励";
		Text = "    恭喜少侠在本家族第%d个升到[FFFE0D]「%s」[-]头衔，忘忧酒馆特发邀请令，请少侠笑纳。";
		tbAttach = { {"item", 9502, 1} };
	};
	szGetRentItemKinMsg = "「%s」在本家族第%d个升至「%s」头衔，获得了[FFFE0D][酒馆之邀][-]，可以在忘忧酒馆开启家族宴席！ ";


	CREATE_NOTIFY = "家族成员「%s」受酒馆掌柜之邀，在<忘忧酒馆>开启了家族宴席, 宴席将于2分钟后正式开始，大家快去享用佳肴吧！";
	AddNpcSetting = {--摆放家族配置 ,桌子的class是 DrinkHouseTableNpc,显示采集
		{nTemplate = 3236, nLevel = 1;  nPosX = 5053, nPosY = 5071, nDir = 0};
		{nTemplate = 3236, nLevel = 1;  nPosX = 4380, nPosY = 5027, nDir = 0};
		{nTemplate = 3236, nLevel = 1;  nPosX = 6171, nPosY = 8005, nDir = 0};
		{nTemplate = 3236, nLevel = 1;  nPosX = 6164, nPosY = 8641, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 3651, nPosY = 6238, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 3992, nPosY = 6062, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 4469, nPosY = 6126, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 4435, nPosY = 6530, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 4437, nPosY = 7069, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 4661, nPosY = 7986, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 5223, nPosY = 7981, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 5221, nPosY = 8380, nDir = 0};
		{nTemplate = 3237, nLevel = 1;  nPosX = 4661, nPosY = 8388, nDir = 0};
	}; 

	nDinnerActionID = 5;
	nDinnerActionEventID = 10002;
	nDinnerWaitTime = 5;  -- 食用读条时间
	nDiceTimeOutTime = 60;-- 骰子超时时间
	nDiceTopShowNum = 3;--显示前三名
	nDiceBottomShowNum = 4;--显示最后四名
	tbPoolDiceGroup = { --潜规则骰子组合
		{ 1,1,1 };
		{ 1,2,1 };
		{ 1,2,2 };
	}; 
	tbDrinkMsg = {
		"「%s」接受掷骰惩罚，拿起眼前的酒杯，咕的一声把酒送入口中。";
		"「%s」再次接受掷骰惩罚，端起桌上的酒杯，一饮而尽。";
		"「%s」第三次接受掷骰惩罚，已然找不到自己的酒杯，拿着旁边人的酒杯就喝了起来！";
		"「%s」第四次接受掷骰惩罚，拿起酒坛就往自己脸上倒。。";
	};
	DicePriceMail = {
		To = nil; -- 手动填
		Title = "酒馆骰子奖励";
		Text = "    恭喜少侠在家族宴席活动中获得骰子排名奖励，附件是您的奖励，请注意查收。";
		From = "忘忧酒馆老板娘";
		
	};
	DicePriceMailtbAttach = {
			{{"Coin", 30000}},
			{{"Coin", 20000}},
			{{"Coin", 15000}},
		};
	nPunishDanceRadius = 300;--距离跳舞点范围小于该距离的就被传送开
	tbPunishDanceSafePos = { 4020, 6588 }; --在动态障碍区的被传走的安全点
	PunishDancePos = {	--传送过去跳舞的点, 应该是等于 nDiceBottomShowNum
		{3879, 6704};
		{4158, 6704};
		{3877, 6480};
		{4187, 6448};
	};
	PunishDancePosObstacle = { --跳舞的对应的动态障碍名
		"DynmincObstacle1";
		"DynmincObstacle2";
		"DynmincObstacle3";
		"DynmincObstacle4";
	};
	nPunishDanceTime = 60; --惩罚跳舞时间
	tbPunishWaiYiItemId_Body = 8384; --惩罚跳海草舞的外装衣服
	tbPunishWaiYiItemId_Head = 8388; --惩罚跳海草舞的外装头
	nPunishDanceActionID = 10; --跳舞的动作
	nPunishDanceActionEventID = 10020;
	szPunishDanceMsg = "「%s」喝的大醉，脱去外衣，在场地中央跳了起来！";


	tbFOOD_NPC_ID = { --菜桌的npcId
		[3236] = 1;
		[3237] = 2;
	}; 
	FOOD_NAME = {
		"开胃小菜";
		"年年有余";
		"东方鸣凤";
		"鸿运团圆";
	};
	FOOD_AWARD = { --四道菜吃时对应奖励
		{ {"item", 9503,1 },{"BasicExp", 5} };
		{ {"item", 9503,1 },{"BasicExp", 5} };
		{ {"item", 9503,1 },{"BasicExp", 5} };
		{ {"item", 9503,1 },{"BasicExp", 5} };
	};
}

DrinkHouse.tbDinnerDef = 
{
	AddNpcSetting = {--摆放家族配置 ,桌子的class是 DrinkHouseTableNpc,显示采集
		{nTemplate = 3424, nLevel = 1;  nPosX = 5053, nPosY = 5071, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4380, nPosY = 5027, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 6171, nPosY = 8005, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 6164, nPosY = 8641, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 3651, nPosY = 6238, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 3992, nPosY = 6062, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4469, nPosY = 6126, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4435, nPosY = 6530, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4437, nPosY = 7069, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4661, nPosY = 7986, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 5223, nPosY = 7981, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 5221, nPosY = 8380, nDir = 0};
		{nTemplate = 3424, nLevel = 1;  nPosX = 4661, nPosY = 8388, nDir = 0};
	}; 

	FOOD_NAME = {
		"擂茶";
		"烧鹅";
		"牛肉丸";
		"鱼饭";
	};

	FOOD_AWARD = { --四道菜吃时对应奖励
		{ {"item", 10284,1 },{"BasicExp", 5} };
		{ {"item", 10285,1 },{"BasicExp", 5} };
		{ {"item", 10286,1 },{"BasicExp", 5} };
		{ {"item", 10287,1 },{"BasicExp", 5} };
	};

	tbRandPos = { --传入随机点
		{3429, 6572};
		{3657, 6559};
		{3879, 6669};
	};

	tbGreetings = {	--祝福语
		"恭喜发财",
		"一帆风顺",
		"富贵双全",
		"双喜临门",
		"五福临门",
		"六六大顺",
		"十全十美",
		"万事如意",
		"福满门庭",
		"心想事成",
		"吉星高照",
		"福满人间",
		"喜气临门",
		"吉祥如意",
		"万事亨通",
		"万象更新",
		"合家欢乐",
		"门迎百福",
		"瑞气盈门",
		"旭日东升",
		"和气生财",
		"财源广进",
		"出入平安",
		"新年快乐",
		"欣欣向荣",
		"和气致祥",
		"鸾凤和鸣",
		"喜气盈门",
		"招财进宝",
		"福星高照",
		"福禄寿禧",
		"荣华富贵",
		"大展鸿图",
		"前途无量",
		"前程似锦",
		"万福临门",
		"家庭幸福",
		"美满幸福",
		"鹏程万里",
	};

	tbGatherBoxPos = { --宝箱位置
			{3868,18546};
			{3729,18327};
			{3993,18243};
			{3517,18230};
			{3774,18105};
			{3535,17952};
			{3840,17941};
			{3507,17715};
			{3771,17722};
			{3535,17517};
			{3868,17514};
			{3674,17309};
			{3517,17174};
			{3760,17035};
			{4021,17135};
			{4014,17361};
			{3981,16805};
			{4240,16616};
			{4393,16397};
			{4559,16344};
			{4708,16602};
			{4317,16845};
			{4061,16553};
			{4187,16367};
			{4585,16795};
			{4681,16891};
			{4943,16854};
			{4788,16752};
			{4628,16586};
			{5013,16626};
			{5143,16851};
			{5182,16639};
			{4993,16805};
			{4864,16513};
			{4685,16310};
			{5269,16463};
			{5415,16908};
			{5285,17024};
			{5292,17150};
			{5471,17339};
			{5551,17485};
			{5527,17601};
			{5461,17787};
			{5385,18002};
			{5398,18201};
			{5249,18546};
			{4970,18533};
			{4867,18709};
			{4705,18706};
			{4469,18732};
			{4320,18752};
			{4071,18387};
			{4366,18361};
			{4655,18364};
			{4665,18583};
			{5063,18241};
			{4804,18321};
			{4834,18440};
			{4645,18165};
			{4983,18108};
			{5070,18009};
			{4632,18049};
			{4098,17989};
			{4035,18075};
			{4124,17717};
			{4058,17584};
			{4287,17392};
			{4267,17209};
			{4529,17140};
			{4748,17127};
			{4987,17130};
			{5149,17336};
			{5202,17481};
			{5212,17641};
			{5162,17813};
			{4841,17734};
			{4695,17604};
			{4655,17365};
			{4827,17312};
			{4970,17501};
			{4814,17525};
			{5033,17674};
			{4867,17843};
			{4635,17823};
			{4526,17614};
			{4399,17611};
			{4293,17800};
			{4310,17893};
			{4469,17966};
			{4811,18052};
			{5235,18148};
			{4509,18497};
			{4140,16985};
			{3985,17819};
			{5125,17033};
			{3864,18368};
	};

	tbPlayFireworkSetting = { -- 烟花
		[1] ={
			{9184,4356,16266,0},
			{9186,4338,17023,0},
			{9188,4694,16600,0},
			{9185,5228,17034,0},
			{9187,5261,16593,0},
			{9189,5495,16845,0},
			{9184,5488,16467,0},
			{9187,4041,17042,0},
			{9189,3666,17924,0},
			{9188,3956,17709,0},
			{9184,3663,17509,0},
			{9186,4267,17524,0},
			{9185,4846,17242,0},
			{9186,4586,17260,0},
			{9188,4034,17305,0},
			{9186,5291,17572,0},
			{9188,5261,18002,0},
			{9189,5054,18199,0},
			{9185,4794,18347,0},
			{9187,4601,18347,0},
			{9184,3722,18151,0},
			{9185,3963,18177,0},
			{9186,4137,18280,0},
			{9189,4753,18707,0},
			{9184,3974,18529,0},
			{9187,5376,18166,0},
		};
	};

	tbDanceActionId = {
		[7] = true,
		[9] = true,
		[10] = true,
		[13] = true,
		[14] = true,
	};

	tbOpenDinnerItemLimit = {
		{"OpenLevel39", 20};
		{"OpenLevel49", 10};
		{"OpenLevel59", 5};
		{"OpenLevel69", 0};
	};

	nDanceRedBagNum = 5; -- 跳舞红包每轮最多5个
	szUiHelpKey = "DrinkHouseDinner";
	nDinnerWaitTime = 2;  -- 食用读条时间
	nOpenDinnerItemId = 10282; -- 年夜饭开启道具id
	tbOpenDinnerItemId = {{"item", 10282, 1}};
	nInvitationItemId = 10283; -- 年夜饭玩家邀请函
	tbInvitationItemId = {{"item", 10283, 1}};
	tbOpenTimeFromTo = { 3600 * 18, 3600 * 24 }; -- 允许开启年夜饭的时间范围，当天时间对应秒数
	nDinnerMapId = 8017; -- 地图id
	nDinnerActionID = 5;
	nDinnerActionEventID = 10002;
	nDinnerNpcMapId = 15; -- 酒馆接引人所在地图
	nDinnerNpcId = 3213; -- 酒馆接引人npcId
	szNotifyMsg = "家族成员「%s」在<忘忧酒馆>开启了风味家族年夜饭, 宴席将于2分钟后正式开始，大家快去享用佳肴吧！";
	szDancingRedBagMsg = "家族成员「%s」舞姿卓越，获得了一个红包！";
	nCanOpenBoxTimes = 10;
	nBoxTemplateId = 3439; -- 宝箱id
	nDinnerRoundNum = 4;
	nDanceRedBagProbability = 0.2; -- 获得跳舞红包的概率
	nVoiceRedBagEventId = {225,226,227,228}; -- 祝福语红包id
	tbDanceRedBagEventId = {229,230,}; -- 跳舞红包id
	nFireworkTimes = 5; -- 燃放烟花次数
	nFireworkTimeInterval = 2;  -- 燃放烟花时间间隔
	szNewInfoMsg = 
				[[[FFFE0D]风味家族年夜饭活动开始了！[-]
				[FFFE0D]活动时间：[-]2019年1月30日-2019年2月4日
				活动开始时，[FFFE0D]族长[-]会收到一个[11adf6][url=openwnd:酒馆之邀（年夜饭）, ItemTips, "Item", nil, 10282][-]。所有大侠都会收到一个[11adf6][url=openwnd:年夜饭邀请函, ItemTips, "Item", nil, 10283][-]。
				持有[11adf6][url=openwnd:酒馆之邀（年夜饭）, ItemTips, "Item", nil, 10282][-]的大侠可以在活动期间任意一天晚上[FFFE0D]18：00-24：00[-]期间前往[FFFE0D]临安忘忧酒馆老板娘[-]处开启年夜饭。
				开启后本家族所有成员均可进入忘忧酒馆享用丰盛的年夜饭，猜红包送祝福，赏烟花捡宝箱。详情可在活动副本中查看。
				注：
				[FFFE0D]每个家族只能开启一次年夜饭[-],请选择合适的时间召集大家开启年夜饭。
				[11adf6][url=openwnd:年夜饭邀请函, ItemTips, "Item", nil, 10283][-]将在参加一次年夜饭后扣除,无邀请函的玩家无法享用年夜饭菜品和拾取宝箱，即每位大侠[FFFE0D]只有一次[-]获取年夜饭奖励的机会。]];
	nLevelLimit = 10; 
}


function DrinkHouse:InviteDrinkPopAvaliable(pPlayer)
	return pPlayer.GetUserValue(DrinkHouse.tbDef.SAVE_GROUP, DrinkHouse.tbDef.SAVE_KEY_DRINK_INVITE) == 1
end