-- ----------------------------------
-- 一闷夺宝历史数据结构
-- hosr
-- ----------------------------------
LotteryHistoryData = LotteryHistoryData or BaseClass()

function LotteryHistoryData:__init()
   self.idx = 0       --"期号"
   self.role_name = "" --      "角色名"
   self.item_id = 0 --         "道具ID"
   self.item_count = 0 --      "道具数量"
   self.times_buy = 0 --       "购买次数"
   self.times_sum = 0 --       "总需参与人次数"
   self.time = 0 --            "揭晓时间"
   self.times_my = 0 -- 我的参与次数
   self.focus = 0 --没关注
end

function LotteryHistoryData:SetData(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end