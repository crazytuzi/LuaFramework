-- @author hze
-- @date #2019/05/28#
-- 战令活动配置接口

WarOrderConfigHelper = WarOrderConfigHelper or {}

local _config = nil
function WarOrderConfigHelper.Config()
    if _config == nil then
        _config = DataCampWarOrder
    end
    return _config
end

function WarOrderConfigHelper.GetCamp(campaign_id)
    local cfg = WarOrderConfigHelper.Config().data_camp[campaign_id]
    if cfg == nil then
        Log.Error("camp_long_active_data不存在的活动信息配置 campaign_id = " .. tostring(campaign_id))
    end
    return cfg
end

function WarOrderConfigHelper.GetOrder(order_id)
    local cfg = WarOrderConfigHelper.Config().data_order[order_id]
    if cfg == nil then
        Log.Error("camp_long_active_data不存在的战令信息配置 quest_id = " .. tostring(order_id))
    end
    return cfg
end

function WarOrderConfigHelper.GetQuest(quest_id)
    local cfg = WarOrderConfigHelper.Config().data_quest[quest_id]
    if cfg == nil then
        Log.Error("camp_long_active_data不存在的任务信息配置 quest_id = " .. tostring(quest_id))
    end
    return cfg
end

function WarOrderConfigHelper.GetQuestIdList()
    local data = WarOrderConfigHelper.Config().data_quest
    local list = {}
    for i, v in pairs(data) do
        list[v.sort] = v.id
    end
    return list
end


function WarOrderConfigHelper.GetReward(lev)
    local cfg = WarOrderConfigHelper.Config().data_reward[lev]
    if cfg == nil then
        Log.Error("camp_long_active_data不存在的奖励信息配置 lev = " .. tostring(lev))
    end
    local reward = {}
    
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex

    for i, v in ipairs(cfg) do
        if v.reward ~= nil then 
            for _, vv in ipairs(v.reward) do
                if (lev >= vv[4] and lev <= vv[5]) or (vv[4] == 0 and vv[5] == 0) then 
                    if sex == vv[6] or vv[6] == 2 then
                        if classes == vv[7] or vv[7] == 0 then 
                            local tmp = {}
                            tmp.item_id = vv[1]
                            tmp.num = vv[3]
                            tmp.effect = vv[8]
                            tmp.sort = vv[9]
                            tmp.id = v.id
                            tmp.lev = v.lev
                            tmp.type = (v.id -1) % 2 + 1 -- 没有类型，用奇偶判断
                            table.insert(reward, tmp)
                        end
                    end
                end
            end
        end
    end
    return reward
end


