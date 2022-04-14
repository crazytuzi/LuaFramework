VipSmallModel = VipSmallModel or class('VipSmallModel',BaseModel)

function VipSmallModel:ctor()
    VipSmallModel.Instance = self

    self:Reset()
end

function VipSmallModel:Reset()

    self.vip_small_lv = 0  --小贵族等级
    self.vip_small_exp = 0  --小贵族经验
    self.lv_reward = {}  --已领取的小贵族等级奖励
    self.max_vip_lv = #Config.db_vip2_level - 1

    self.online_reward = {}  --已领取的小贵族在线奖励
    self.online_time = 0  --在线时长

    self.is_first_open_panle = true --是否已经首次打开过小贵族界面

    self.vip2_level_cfg = {}  --以level为key的小贵族等级表
    for k,v in pairs(Config.db_vip2_level) do
        self.vip2_level_cfg[v.level] = v
    end

    self.vip2_card_cfg = {}  --以item_id为key的小贵族激活卡表
    for k,v in pairs(Config.db_vip2_card) do
        self.vip2_card_cfg[v.item] = v
    end

    self.welfare_online2_cfg = {}  --以opdays为key的小贵族在线奖励表
    for k,v in pairs(Config.db_welfare_online2_reward) do
        self.welfare_online2_cfg[v.opdays] = self.welfare_online2_cfg[v.opdays] or {}
        self.welfare_online2_cfg[v.opdays][v.id] = v
    end
end

function VipSmallModel.GetInstance()
    if VipSmallModel.Instance == nil then
        VipSmallModel.new()
    end
    return VipSmallModel.Instance
end



--是否已领取当前小贵族等级及之前所有等级的奖励
function VipSmallModel:IsReceiveCurVipLvReward(  )
    return self:IsReceiveVipLvReward(self.vip_small_lv)
end

--是否已领取指定小贵族等级及之前所有等级的奖励
function VipSmallModel:IsReceiveVipLvReward(lv)

    for i=1,lv do
        if not self.lv_reward[lv] then
            return false
        end
    end

    return true
end

--获取可领取的小贵族等级奖励中的最低的还没领取等级奖励的小贵族等级 
--（比如lv5可领取lv1-5的所有等级奖励，已领取lv1的，那么就返回2）
function VipSmallModel:CanReceiveVipLvRewardLv(  )
    for i=1,self.vip_small_lv do
        if not self.lv_reward[i] then
            return i
        end
    end

    return self.vip_small_lv
end

--是否已领取指定id的小贵族在线奖励
function VipSmallModel:IsReceiveOnlineReward(id)

    for k,v in pairs(self.online_reward) do
        if v == id then
            return true
        end
    end
    return false
end

--是否可以显示小贵族图标
function VipSmallModel:IsCanShowVipSmallIcon()
    local vip_lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    local opdays = LoginModel.GetInstance():GetOpenTime()
    
    --已激活过贵族
    --小贵族等级奖励都领取过了 
    --开服天数超过7天
    --满足以上条件就不显示小贵族图标了
    if vip_lv > 0 and self:IsReceiveCurVipLvReward()  and opdays > 7 then
        --logError("IsCanShowVipSmallIcon false")
        return  false
    end
    --logError("IsCanShowVipSmallIcon true")
    return true
end

--是否有可领取的小贵族奖励
function VipSmallModel:IsCanReceiveReward(  )

    if self.is_first_open_panle then
        --没打开过小贵族界面的话就始终返回true  
        return true
    end

    local flag = self:IsCanReceiveLvReward() or self:IsCanReceiveWefareReward()
    --logError("是否有可领取的小贵族奖励-"..tostring(flag))
    return flag
end

--是否有可领取的小贵族等级奖励
function VipSmallModel:IsCanReceiveLvReward(  )
    local flag  = not self:IsReceiveCurVipLvReward()
    --logError("是否有可领取的小贵族等级奖励-"..tostring(flag))
    return flag
end

--是否有可领取的小贵族在线奖励
function VipSmallModel:IsCanReceiveWefareReward(  )
    local opdays = LoginModel.GetInstance():GetOpenTime()
    local cfgs = self.welfare_online2_cfg[opdays]
    if not cfgs then
        return false
    end
    for k,v in pairs(cfgs) do
        if self.online_time >= v.time and not self:IsReceiveOnlineReward(v.id) then
            --在线时间达到并且未领取过
            --logError("是否有可领取的小贵族在线奖励-true")
            return true 
        end
    end
    --logError("是否有可领取的小贵族在线奖励-false")
    return false
end