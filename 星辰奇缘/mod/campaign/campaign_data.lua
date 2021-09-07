-- ---------------------
-- 活动数据结构
-- hosr
-- ---------------------
CampaignData = CampaignData or BaseClass()

function CampaignData:__init()
    self.id = 0
    self.status = CampaignEumn.Status.Doing
    self.value = 0 -- 当前进度
    self.target_val = 0 -- 目标值
    self.ext_val = 0 -- 附加值
    self.reward_max = 0 -- 最大可奖励(购买/兑换)次数(个人)
    self.reward_can = 0 -- 剩余奖励(购买/兑换)次数(个人)
    self.base = nil     -- 活动基础数据
end

function CampaignData:Update(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end

function CampaignData:SetBase(base)
    self.base = base
end
