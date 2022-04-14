-- @Author: lwj
-- @Date:   2020-01-06 11:17:10
-- @Last Modified time: 2020-01-06 11:17:52

GundamActModel = GundamActModel or class("GundamActModel", BaseModel)
local GundamActModel = GundamActModel

function GundamActModel:ctor()
    GundamActModel.Instance = self
    self:Reset()
end

function GundamActModel:Reset()
    self.act_id_list = { 178100, 178200, 178300 }
    self.info_list = {}
    self.cur_day = 1
    self.rd_list = {}
    self.is_showing_task_rd = false
end

function GundamActModel.GetInstance()
    if GundamActModel.Instance == nil then
        GundamActModel()
    end
    return GundamActModel.Instance
end

function GundamActModel:SetInfo(data)
    self.info_list[data.id] = self.info_list[data.id] or {}
    self.info_list[data.id] = data
end

function GundamActModel:GetInfo(act_Id)
    return self.info_list[act_Id]
end

function GundamActModel:GetInfoByRewaId(act_id, id)
    local sin_info = self:GetInfo(act_id)
    if not sin_info then
        return
    end
    local list = sin_info.tasks
    local result
    for i = 1, #list do
        local info = list[i]
        if info.id == id then
            result = info
            break
        end
    end
    return result
end

--是否足够三个活动的数据
function GundamActModel:IsEnoughData()
    return table.nums(self.info_list) == 3
end

function GundamActModel:IsInOpenTime()
    local opday = LoginModel.GetInstance():GetOpenTime()
    return opday <= 3
end

function GundamActModel:IsAllFinish()
    if not self:IsInOpenTime() then
        return true
    end
    local result = false
    for i = 1, #self.act_id_list do
        local act_id = self.act_id_list[i]
        local cf = OperateModel.GetInstance():GetRewardConfig(act_id)
        if cf then
            local info = self:GetInfoByRewaId(act_id, cf.id)
            if not info then
                result = false
                break
            else
                if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE or info.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                    result = true
                    break
                end
            end
        end
    end
    return result
end

function GundamActModel:IsHaveRewaCanFetch()
    if not self:IsInOpenTime() then
        return false
    end
    self.rd_list = {}
    local list = self.info_list
    local is_show_icon_rd = false
    local intera = table.pairsByKey(list)
    for act_id, info in intera do
        local info = info.tasks
        for idx = 1, #info do
            local sin_info = info[idx]
            if sin_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_show_icon_rd = true
                self.rd_list[act_id] = self.rd_list[act_id] or {}
                self.rd_list[act_id][sin_info.id] = true
            end
        end
    end
    return is_show_icon_rd
end

function GundamActModel:IsShowDayRD(idx)
    local id = self.act_id_list[idx]
    if (not id) or (not self.rd_list[id]) then
        return false
    end
    return not table.isempty(self.rd_list[id])
end

function GundamActModel:IsShowRewaRD(act_id, id)
    local act_list = self.rd_list[act_id]
    if not act_list then
        return false
    end
    return act_list[id]
end

function GundamActModel:IsShowMainRD()
    self.is_showing_task_rd = false
    local is_show_once_rd = false
    if not self:IsAllFinish() then
        ----没有全部完成
        if self:IsHaveRewaCanFetch() then
            --有可以获取的奖励
            self.is_showing_task_rd = true
            is_show_once_rd = true
        else
            --没有
            if self:CheckLastOneDayTime() then
                --大于1天
                is_show_once_rd = true
            end
        end
    end
    --主界面
    GlobalEvent:Brocast(GundamActEvent.UpdateGundamIconRD, is_show_once_rd)
end

function GundamActModel:CheckLastOneDayTime()
    local str = "gundam_act_check_red_dot_stamp"
    local stamp = CacheManager.GetInstance():GetFloat(str)
    if stamp == nil then
        --没有登录时间
        return true
    else
        local param = TimeManager.GetInstance():GetDifDay(stamp, os.time())
        if param >= 1 then
            --显示一天一次红点
            return true
        else
            return false
        end
    end
end