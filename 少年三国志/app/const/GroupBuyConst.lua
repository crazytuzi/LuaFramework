-- GroupBuyConst.lua

local GroupBuyConst = {
	CONFIG_FILE_NAME = "groupbuy.data", -- 数据持久化文件名称
	DISCOUNT_IMAGE_PATH = "ui/text/txt/xstg_zhekou_%d.png",  -- 打折图片地址

	TIME_STATUS_TYPE = {
		UN_OPEN = 1, -- 未开始
		RUNNING = 2, -- 活动进行中
		REWARD  = 3, -- 活动结束，领奖中
		END     = 4, -- 领奖结束
	},

	AWARD_RANK_MAX_NUM = 100, -- 可以获奖的最大名次

	DAILY_AWARD_TYPE = { -- 每日任务
		SELF = 1, -- 自己的
		ALL = 2, -- 全服的
		BACKGOLD = 3, -- 返还的元宝
	},

	RANK_AWARD_TEMP_ID = 3, -- 排行奖励表对应的typeId
	
	RANK_AWARD_TYPE = {
		NORMAL = 1, -- 普通榜单
		LUXURY = 2, -- 豪华榜单
		AWARD = 3, -- 排行奖励
	},

	-- 活动结束奖励领取状态
	END_RAWARD_STATUS = {
		UN_GET = 0, -- 未领取
		HAVE_GET = 1, -- 已领取
	},

	RANK_MAX_NUM = 100, -- 排行榜最大的名次
}

return GroupBuyConst