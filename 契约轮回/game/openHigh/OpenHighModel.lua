-- @Author: lwj
-- @Date:   2019-07-18 14:28:45 
-- @Last Modified time: 2019-11-05 11:02:36

OpenHighModel = OpenHighModel or class("OpenHighModel", BaseBagModel)
local OpenHighModel = OpenHighModel

function OpenHighModel:ctor()
    OpenHighModel.Instance = self
    self:Reset()
end

function OpenHighModel:Reset()
    self.info_list = {}
    self.theme_cf_list = {}
    self.rewa_cf_list = {}
    self.default_sel_theme = 120101
    self.is_open_panel = false
    self.is_openning = false
    self.act_id_list = { 120101, 120201, 120301, 120401 }
    self.cur_theme = 120101
    self.act_end_list = {}
    self.cur_high_pro = 0

    self.wedding_btn_mode = 1       --结婚三档按钮点击模式 1：寻路   2：领取
    self.wedding_reco_info = {}      --结婚三档的记录

    self.rd_list = {}               --标签栏红点列表
    self.game_started = false

    self.sec_opday = 7
end

function OpenHighModel.GetInstance()
    if OpenHighModel.Instance == nil then
        OpenHighModel()
    end
    return OpenHighModel.Instance
end

function OpenHighModel:SetActInfo(info)
    self.info_list[info.id] = info
    if info.id == 120101 then
        self:CheckCurProChange(info)
        self:CheckMainRD(info.id)
    end
end

function OpenHighModel:CheckCurProChange(info)
    local list = info.tasks
    local max = 0
    for i, v in pairs(list) do
        if v.level == 2 then
            local pro = v.count
            if pro > max then
                max = pro
            end
        end
    end
    if max ~= self.cur_high_pro then
        self.cur_high_pro = max
        self:Brocast(OpenHighEvent.UpdateHighCurPro, max)
    end
end

function OpenHighModel:CheckMainRD(act_id)
    local is_show_rd = false
    local list = self.info_list[act_id].tasks
    for i, v in pairs(list) do
        if v.level == 2 and v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_show_rd = true
            break
        end
    end
    self.rd_list[act_id] = is_show_rd
    if not is_show_rd and self:IsCanHideMainIconRD() == false then
        return is_show_rd
    end
    OperateModel.GetInstance():UpdateIconReddot(act_id, is_show_rd)
    return is_show_rd
end

function OpenHighModel:CheckWeddingRD()
    local info = self:GetActInfoByActId(120201)
    local is_show_wedding_rd = false
    for i, v in pairs(info.tasks) do
        if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_show_wedding_rd = true
            break
        end
    end
    self.rd_list[120201] = is_show_wedding_rd
    return is_show_wedding_rd
end

function OpenHighModel:CheckColeRD()
    if table.isempty(self.rewa_cf_list) then
        self:GetRewaCf()
    end
    local is_show_rd = false
    local list = self:GetRewaCfByActId(120301)
    if not list then
        return false
    end
    for i = 1, #list do
        local cf = list[i]
        local sum = String2Table(cf.limit)[2]
        local ser_data = self:GetSingleTaskInfo(120301, cf.id)
        local cur = sum - ser_data.count
        if cur > 0 then
            local is_lack = false
            local cost_tbl = String2Table(cf.cost)
            for i, v in pairs(cost_tbl) do
                local item_id = v[1]
                if BagModel.GetInstance():GetItemNumByItemID(item_id) == 0 then
                    is_lack = true
                    break
                end
            end
            if not is_lack then
                is_show_rd = true
                break
            end
        end
    end
    self.rd_list[120301] = is_show_rd
    return is_show_rd
end

function OpenHighModel:CheckCreateClubRD()
    local info = self:GetActInfoByActId(120401)
    if not info then
        return false
    end
    local is_show_rd = false
    for i, v in pairs(info.tasks) do
        if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            local max_num = self:GetMaxNum(120401, v.id, v.level)
            local is_can_continue = true
            if max_num then
                local cur = max_num - v.count
                if cur <= 0 then
                    is_can_continue = false
                end
            end
            if is_can_continue then
                is_show_rd = true
                break
            end
        end
    end
    self.rd_list[120401] = is_show_rd
    return is_show_rd
end

function OpenHighModel:IsCanHideMainIconRD()
    local is_can = true
    for i, v in pairs(self.rd_list) do
        if v == true then
            is_can = false
            break
        end
    end
    return is_can
end

function OpenHighModel:GetMaxNum(act_id, id, level)
    local act_cf_list = self:GetRewaCfByActId(act_id)
    if not act_cf_list then
        return
    end
    local result
    for i, v in pairs(act_cf_list) do
        if v.id == id and v.level == level then
            result = String2Table(v.limit)[2]
            break
        end
    end
    return result
end

function OpenHighModel:GetActInfoByActId(id)
    return self.info_list[id]
end

function OpenHighModel:GetSingleTaskInfo(act_id, task_id)
    local act_info = self:GetActInfoByActId(act_id)
    local result = {}
    for i, v in pairs(act_info.tasks) do
        if v.id == task_id then
            result = v
            break
        end
    end
    return result
end

function OpenHighModel:SetThemeCf(cf)
    self.theme_cf_list[cf.id] = cf
end

function OpenHighModel:GetThemeCfById(id)
    return self.theme_cf_list[id]
end

function OpenHighModel:GetThemeCf()
    return self.theme_cf_list
end

function OpenHighModel:GetRewaCf()
    for act_id, info_list in pairs(self.info_list) do
        local list = {}
        for idx, task_info in pairs(info_list.tasks) do
            list[task_info.id] = OperateModel.GetInstance():GetRewardConfig(act_id, task_info.id)
        end
        self.rewa_cf_list[act_id] = list
    end
end

function OpenHighModel:GetRewaCfByActId(id)
    return self.rewa_cf_list[id]
end

function OpenHighModel:GetClubFightRewaCFByLevel()
    local act_id = OperateModel.GetInstance():GetActIdByType(205)
    local cf = self:GetRewaCfByActId(act_id)
    local list = {}
    for i = 1, #cf do
        list[#list + 1] = cf[i]
    end
    return list
end

function OpenHighModel:CheckInfoExsitByActId(act_id)
    local info = self.info_list[act_id]
    if not info then
        return false
    end
    return not table.isempty(info.tasks)
end

function OpenHighModel:SetEndTimeByActId(id, time_stamp)
    self.act_end_list[id] = time_stamp
end

function OpenHighModel:GetOHThemeList()
    local list = self:GetThemeCf()
    local interator = table.pairsByKey(list)
    local cf = {}
    for k, v in interator do
        local end_time = self.act_end_list[v.id]
        if end_time then
            if end_time > os.time() then
                --活动未结束
                cf[#cf + 1] = v
            end
        end
    end
    return cf
end

function OpenHighModel:CheckClubFightRD()
    --local opday = LoginModel.GetInstance():GetOpenTime()
    --local level = 1
    --if opday >= self.sec_opday then
    --    level = 2
    --end
    local act_id = OperateModel.GetInstance():GetActIdByType(205)
    local act_info = self:GetActInfoByActId(act_id)
    local is_can_fetch = false
    for i, v in pairs(act_info.tasks) do
        if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_can_fetch = true
            break
        end
    end
    self.rd_list[act_id] = is_can_fetch
    return is_can_fetch
end

function OpenHighModel:CheckActListId()
    self.act_id_list[5] = OperateModel.GetInstance():GetActIdByType(205)
end