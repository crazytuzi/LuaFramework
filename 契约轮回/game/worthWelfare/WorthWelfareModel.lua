WorthWelfareModel = WorthWelfareModel or class('WorthWelfareModel',BaseModel)

function WorthWelfareModel:ctor()
    WorthWelfareModel.Instance = self

    self:Reset()

    self.invest_reward_cfg = {}

    for k,v in pairs(Config.db_vip_invest_reward) do
        self.invest_reward_cfg[v.id] = v
    end

    
   
end

function WorthWelfareModel:Reset()
   

end

function WorthWelfareModel.GetInstance()
    if WorthWelfareModel.Instance == nil then
        WorthWelfareModel.new()
    end
    return WorthWelfareModel.Instance
end

--是否已购买当前等级档位的多倍投资
function WorthWelfareModel:IsPayInvestment(  )
     --根据等级判断是哪一档
    local pay_id = 16  --充值id
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 371 then
        pay_id = 17
    end

    local list = VipModel.GetInstance().have_pay_list
    for k,v in ipairs(list) do
        if v == pay_id then
            return true
        end
    end

    return false
end

--检查是否有可领取投资红点
--返回检查结果和第一个可领取的投资的配置表id
function WorthWelfareModel:CheckInvestmentReddot(list)

    --先检查是否已购买多倍投资
    local is_pay = self:IsPayInvestment()  
    if not is_pay then
        return false
    end

    local new_list = {}
    for k,v in pairs(list) do
        new_list[v.id] = v
    end

    self.min_cfg_id = 200  --最小配置表id
    self.max_cfg_id = 300  --最大配置表id
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 371 then
        self.min_cfg_id = 300
        self.max_cfg_id = 400
    end

    for i=self.min_cfg_id,self.max_cfg_id - 1 do
        local cfg = self.invest_reward_cfg[i]
        if not cfg then
            --logError("超值福利投资红点检查，结果false")
            return false
        end

        if new_list[i] then
            if new_list[i].state == 1 then
                 --有可领取的
                --logError("超值福利投资红点检查，结果true,id-"..i)
                return true,i
            end
        else
            local target_lv = cfg.level
            if lv >= target_lv  then
                --等级达到 且未领取 可以领取
                --logError("超值福利投资红点检查，结果true,id-"..i)
                return true,i
            end
        end
    end
    --logError("超值福利投资红点检查，结果false")
    return false
end

