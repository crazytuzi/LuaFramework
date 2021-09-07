-- -----------------------------------
-- 星座挑战数据
-- hosr
-- -----------------------------------
ConstellationData = ConstellationData or BaseClass()

function ConstellationData:__init()
	-- 已通关星级
	self.lev = 0
	-- 已召唤单位
	--{uint32,   map,        "地图id"}
    --,{uint32,   x,        "x坐标"}
    --,{uint32,   y,        "y坐标"}
    --,{uint32,   base_id,  "单位base_id"}
    --,{uint8,   lev,        "星级"}
    --,{uint32,   time,  "召唤时间"}
	self.summoned = nil
	-- 召唤今日召唤次数
	self.today_summoned = 0
end

function ConstellationData:Update(data)
	self.lev = data.lev
	self.summoned = data.summoned[1]
	self.today_summoned = data.today_summoned
end