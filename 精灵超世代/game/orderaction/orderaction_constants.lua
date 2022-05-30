--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令常量模块
-- @DateTime:    2019-04-19 10:08:18
-- *******************************
OrderActionConstants = OrderActionConstants or {}

--入口ID
--[[
需要注意一个问题：就是当更换周期的时候，需要对上一期的图标进行判断，以防止在主城出现两期的图标，
又或者是出现在下一期的时候，第一次点击进去会出现上一期的UI，这样子就会出现错误的情况
]]
OrderActionEntranceID = {
	entrance_id = 606, 	--战令活动
	entrance_id1 = 608, --冒险战纪
	entrance_id2 = 609, --缤纷盛夏
	entrance_id3 = 610, --
	entrance_id4 = 611, -- 开学季
	entrance_id5 = 612, -- 花火映秋
	entrance_id6 = 613, -- 奇妙之夜
	entrance_id7 = 614, -- 雪舞冬季
	entrance_id8 = 615, -- 岁初礼赞
	entrance_id9 = 616, -- 踏雪拾春
}

--视图
OrderActionView = {
	reward_panel   = 1,	--奖励
	tesk_panel     = 2,	--任务
	advance_card   = 3,	--充值卡
}

OrderActionConstants.ColorConst = {
	[1] = cc.c4b(0x71,0x28,0x04,0xff),
	[2] = cc.c4b(0xFF,0xF4,0xD7,0xFF),
	[3] = cc.c4b(0x00,0x00,0x00,0xff),
	[4] = cc.c4b(0xff,0xf3,0xd2,0xFF),
	[5] = cc.c4b(0x5c,0x17,0x10,0xff),
	[6] = cc.c4b(0x33,0x1d,0x00,0xff),
	[7] = cc.c4b(0xcf,0xb5,0x93,0xff),
	[8] = cc.c4b(0xff,0xed,0xd6,0xff),
	[9] = cc.c4b(0x64,0x32,0x23,0xff),
	[10] = cc.c4b(0xff,0xe0,0xb9,0xff),
	[11] = cc.c4b(0xf5,0xe2,0xca,0xff),
}
