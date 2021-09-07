-- ----------------------------------
-- 幻化手册数据结构
-- hosr
-- ----------------------------------
HandbookItemData = HandbookItemData or BaseClass()

function HandbookItemData:__init()
    self.id = 0 --               "图鉴id"}
    self.status = 0 --           "状态0:未激活1:已激活"}
    self.active_step = 0 --      "当前已收藏点"}
    self.star_step = 0 --        "星数"}
    self.transform_point = 0 --  "幻化点"}
    self.star_val = 0 -- 星进度
end

function HandbookItemData:Update(data)
	for k,v in pairs(data) do
		self[k] = v
	end
end
