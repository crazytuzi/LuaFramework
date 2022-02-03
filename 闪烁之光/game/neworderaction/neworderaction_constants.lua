--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com 
-- @description: 全新战令常量模块
-- @DateTime:    2020-02-20
-- *******************************
NeworderactionConstants = NeworderactionConstants or {}

--入口ID
--[[
需要注意一个问题：就是当更换周期的时候，需要对上一期的图标进行判断，以防止在主城出现两期的图标，
又或者是出现在下一期的时候，第一次点击进去会出现上一期的UI，这样子就会出现错误的情况
]]
NewOrderActionEntranceID = {
	entrance_id = 617, 	--英灵战令活动
}

--视图
NewOrderActionView = {
	reward_panel   = 1,	--奖励
	task_panel     = 2,	--任务
	advance_card   = 3,	--充值卡
}

NeworderactionConstants.ColorConst = {
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
