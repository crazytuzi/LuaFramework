-- @Author: lwj
-- @Date:   2019-03-29 19:06:07
-- @Last Modified time: 2019-03-29 19:06:11

DailyRechargeModel = DailyRechargeModel or class("DailyRechargeModel", BaseBagModel)
local DailyRechargeModel = DailyRechargeModel

function DailyRechargeModel:ctor()
    DailyRechargeModel.Instance = self
    self:Reset()
end

function DailyRechargeModel:Reset()
    self.daily_cfg = {}
    self.achi_cfg = {}
    self.daily_reward_cfg = {}
    self.achi_reward_cfg = {}
    self.yy_info = nil
    self.achi_info = nil        --成就奖励信息
    self.cur_btn_model = 0      --0:前往充值    1:未领取   2:已领取
    self.grade_list = {}        --当前显示的档位列表
    self.achi_list = {}         --当前显示的成就列表
    self.default_sel_index = nil    --打开时默认选中的档位
    self.cur_sel_data = nil         --当前选择的档位的data
    self.is_open_panel = false
    self.is_show_rd_once = true       --是否只显示一次，主界面图标显示红点

    self.grade_rd_list = {}             --红点列表
    self.achi_rd_list = {}

    self.act_list = {}                  --活动数量列表
    self.is_show_btn_rd = false         --是否显示按钮红点

    self.act_config = {}                --三个活动的运营配置
end

function DailyRechargeModel.GetInstance()
    if DailyRechargeModel.Instance == nil then
        DailyRechargeModel()
    end
    return DailyRechargeModel.Instance
end

function DailyRechargeModel:SetActConfig(cf)
    if not cf or not cf.id then
        return
    end
    self.act_config[cf.id] = cf
end

function DailyRechargeModel:GetActConfigByActId(act_id)
    return self.act_config[act_id]
end

function DailyRechargeModel:SetYYInfo(info)
    self.yy_info = info
    if not self.act_list[info.id] then
        self.act_list[info.id] = true
    end
    --dump(data, "<color=#6ce19b>HandleGiveGift   HandleGiveGift  HandleGiveGift  HandleGiveGift</color>")
end

function DailyRechargeModel:SetAchiInfo(info)
    if not self.act_list[info.id] then
        self.act_list[info.id] = true
    end
    self.achi_info = info
end

function DailyRechargeModel:GetYYInfoByIndex(index)
    local result = nil
    for i, v in pairs(self.yy_info.tasks) do
        if index == v.id then
            result = v
            break
        end
    end
    return result
end

function DailyRechargeModel:GetDailyInfoByIndex(index)
    local result
    for i, v in pairs(self.yy_info.tasks) do
        if v.level == index then
            result = v
            break
        end
    end
    return result
end

function DailyRechargeModel:GetAchiInfoByIndex(index)
    local result
    for i, v in pairs(self.achi_info.tasks) do
        if v and v.level == index then
            result = v
            break
        end
    end
    return result
end

function DailyRechargeModel:GetCanGetRewardIndex()
    local tbl = self.yy_info.tasks
    for i = 1, #tbl do
        if self.default_sel_index == nil and tbl[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            self.default_sel_index = i
            break
        end
    end
    self.default_sel_index = self.default_sel_index or 1
end

function DailyRechargeModel:GetShowList()
    self.achi_list = {}
    self.grade_list = {}
    local tbl = self.daily_reward_cfg
    --7天外循环
    for i = 1, #tbl do
        self.grade_list[#self.grade_list + 1] = tbl[i]
    end
    for i = 1, #self.achi_reward_cfg do
        self.achi_list[#self.achi_list + 1] = self.achi_reward_cfg[i]
    end
end

function DailyRechargeModel:UpdateRewarded(data)
    local info
    if data.act_id == 100301 then
        info = self.achi_info.tasks
    else
        info = self.yy_info.tasks
    end
    for i = 1, #info do
        if info[i].id == data.id then
            info[i].state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
            break
        end
    end
end

function DailyRechargeModel:GetDailyRewardCfg()
    self.daily_reward_cfg = {}
    for i = 1, #self.yy_info.tasks do
        self.daily_reward_cfg[#self.daily_reward_cfg + 1] = OperateModel.GetInstance():GetRewardConfig(self.yy_info.id, self.yy_info.tasks[i].id)
    end
end

function DailyRechargeModel:GetAchiRewardCfg()
    self.achi_reward_cfg = {}
    for i = 1, #self.achi_info.tasks do
        self.achi_reward_cfg[#self.achi_reward_cfg + 1] = OperateModel.GetInstance():GetRewardConfig(self.achi_info.id, self.achi_info.tasks[i].id)
    end
end

function DailyRechargeModel:ChangeRDShow()
    local is_show = false
    local is_show_nor_id = self:CheckRd(self.yy_info.tasks, true, self.yy_info.id)
    local is_show_achi_id = self:CheckRd(self.achi_info.tasks, false, self.achi_info.id)
    if is_show_nor_id or is_show_achi_id then
        is_show = true
    end
    return is_show
end

function DailyRechargeModel:CheckRd(list, is_grade, act_id)
    local is_show = false
    for i = 1, #list do
        local info = list[i]
        if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            is_show = true
            if is_grade then
                self.grade_rd_list[info.id] = true
            else
                self.achi_rd_list[info.id] = true
            end
        elseif info.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            if is_grade then
                self:RemoveGradeRdById(info.id)
            else
                self:RemoveAchiRDById(info.id)
            end
        end
    end
    OperateModel.GetInstance():UpdateIconReddot(act_id, is_show)
    return is_show
end

function DailyRechargeModel:IsAlreadyGetAllInfo()
    return table.nums(self.act_list) >= 2
end

function DailyRechargeModel:CheckGradeRDById(id)
    return self.grade_rd_list[id]
end

function DailyRechargeModel:RemoveGradeRdById(id)
    table.removebykey(self.grade_rd_list, id)
end

function DailyRechargeModel:CheckAchiRDById(id)
    return self.achi_rd_list[id]
end

function DailyRechargeModel:RemoveAchiRDById(id)
    table.removebykey(self.achi_rd_list, id)
end