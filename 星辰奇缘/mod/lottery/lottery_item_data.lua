-- --------------------------------
-- 一闷夺宝展示数据数据结构
-- hosr
-- --------------------------------
LotteryItemData = LotteryItemData or BaseClass()

function LotteryItemData:__init()
    self.idx = 0 --        "期号"}
    self.pos = 0 --         "显示位置"}
    self.item_idx = 0 --    "道具ID"}
    self.times_now = 0 --    "已参与人数"}
    self.role_name = "" --    获奖者
    self.state = 0 --            "活动状态;1:活动中;2:揭晓中;3:已结束"}
    self.time = 0 --             "揭晓时间"}
    self.lucky_num = 0 --   "幸运号码"}
    self.times_lottery = 0 --   "中奖者参与人次"}
    self.times_my = 0 --    "我参与次数"}
    self.focus = 0 --没关注
end

function LotteryItemData:SetData(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end
