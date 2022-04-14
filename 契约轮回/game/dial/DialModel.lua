-- @Author: lwj
-- @Date:   2019-12-05 14:56:17
-- @Last Modified time: 2019-12-05 14:56:24

DialModel = DialModel or class("DialModel", BaseModel)
local DialModel = DialModel

function DialModel:ctor()
    DialModel.Instance = self
    self:Reset()
end

function DialModel:Reset()
    self.info_list = {}
end

function DialModel.GetInstance()
    if DialModel.Instance == nil then
        DialModel()
    end
    return DialModel.Instance
end

function DialModel:SetInfo(data)
    self.info_list[data.act_id] = data
end

function DialModel:GetInfoById(act_id)
    return self.info_list[act_id]
end

function DialModel:GetLotteryCf(act_id, round)
    if act_id == nil or round == nil then
        return {}
    end
    local is_start_getting = false
    local inter = table.pairsByKey(Config.db_yunying_lottery_rewards)
    local list = {}
    for _, cf in inter do
        local bingo = false
        if cf.yunying_id == act_id and cf.group == round then
            bingo = true
            is_start_getting = true
            list[#list + 1] = cf
        end
        if is_start_getting and bingo == false then
            break
        end
    end
    return list
end

function DialModel:GetCurRound(act_id)
    local info = self.info_list[act_id]
    if not info then
        return
    end
    return info.round
end

function DialModel:GetCurHits(act_id)
    local info = self.info_list[act_id]
    if not info then
        return
    end
    return info.hits
end

function DialModel:GetHitsNum(act_id)
    return table.nums(self:GetCurHits(act_id))
end

function DialModel:GetCurPro(act_id)
    local info = self.info_list[act_id]
    if not info then
        return
    end
    return info.progress
end

function DialModel:UpdatePro(id, pro)
    local info = self.info_list[id]
    if not info then
        return
    end
    self.info_list[id].progress = pro
end

function DialModel:UpdateInfo(id, data)
    if not self.info_list[id] then
        return
    end
    if not self.info_list[id].hits then
        self.info_list[id].hits = {}
    end
    self.info_list[id].hits[#self.info_list[id].hits + 1] = data.hit
    self.info_list[id].progress = data.progress
end

function DialModel:CheckRechargeRD()
    local id = OperateModel.GetInstance():GetActIdByType(750)
    if id == 0 then
        return false
    end
    local cf = OperateModel.GetInstance():GetConfig(id)
    local limit = String2Table(cf.reqs)
    local sin_cost = limit[1][2]
    local max_pro = limit[2][2]
    local pro = self:GetCurPro(id)
    local cur_pro = pro
    if not pro then
        pro = 0
    end
    if pro > max_pro then
        cur_pro = max_pro
    end
    local cur_times = math.floor(cur_pro / sin_cost)
    local round = self:GetCurRound(id)
    local list = self:GetLotteryCf(id, round) or {}
    local num = #list
    local hits = self:GetCurHits(id) or {}
    local hits_num = #hits or 0
    local rest = num - hits_num
    local rewa_count = round == 1 and rest + 6 or rest
    local result_times = cur_times < rewa_count and cur_times or rewa_count
    return result_times >= 1
end