-- @Author: lwj
-- @Date:   2019-04-23 16:43:43
-- @Last Modified time: 2019-10-29 20:14:57

FreeGiftModel = FreeGiftModel or class("FreeGiftModel", BaseBagModel)
local FreeGiftModel = FreeGiftModel

function FreeGiftModel:ctor()
    FreeGiftModel.Instance = self
    self:Reset()
end

function FreeGiftModel:Reset()
    FreeGiftController.GetInstance():StopCheckingRD()
    self.is_open_after_get_info = false
    self.info_list = {}
    self.cur_sel_act_id = nil
    self.btn_mode = 1           --1:一档  2:返利
    self.cur_state = 1          --1：未购买     2：已购买   3:已返利   4:已过期
    self.is_open_ui = false
    self.cur_rewa_con = nil     --当前选中的奖励配置
    self.cur_rebate_con = nil   --当前选中的返利配置
    self.cur_cost = nil         --当前档位的花费
    self.is_free = false        --当前档位是否是免费
    self.rd_list = {}           --需要显示红点的档位的列表
    self.is_runnging_sch = false            --是否正在开启定时器
    self.defaut_act_id = 100401
    self.is_game_start = false
end

function FreeGiftModel.GetInstance()
    if FreeGiftModel.Instance == nil then
        FreeGiftModel()
    end
    return FreeGiftModel.Instance
end

function FreeGiftModel:SetInfoList(info)
    local function sort(a, b)
        return a.act_id < b.act_id
    end
    table.sort(info, sort)
    self.info_list = info
    --dump(self.info_list, "<color=#6ce19b>FreeGiftModel   FreeGiftModel  FreeGiftModel  FreeGiftModel</color>")
end

function FreeGiftModel:GetInfo()
    return self.info_list
end

function FreeGiftModel:GetSingleInfoByActId(act_id)
    local list = self.info_list
    local result
    for i = 1, #list do
        if list[i].act_id == act_id then
            result = list[i]
            break
        end
    end
    return result
end

function FreeGiftModel:GetSideItemList()
    local list = self.info_list
    --活动已结束
    if list[1].etime <= os.time() then
        list = {}
        local info = self.info_list
        for i = 1, #info do
            local data = info[i]
            if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD or data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REFUND then
                list[#list + 1] = data
            end
        end
    end
    return list
end

function FreeGiftModel:IsShowIcon()
    local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local key = "850@1"
    if my_lv < Config.db_sysopen[key].level or table.isempty(self.info_list) then
        return
    end
    local list = self.info_list
    local is_show = true
    local compare_time = list[1].etime
    if os.time() < list[1].stime then
        --时间未到
        is_show = false
    else
        --过了开启时间
        local is_refund_exist = false
        for i = 1, #list do
            local data = list[i]
            if compare_time < data.etime then
                compare_time = data.etime
            end
            if data.state == 3 then
                is_refund_exist = true
            end
        end
        --活动已经结束
        if os.time() > compare_time then
            --是否有返利
            if not is_refund_exist then
                is_show = false
            end
        end
    end
    return is_show
end

function FreeGiftModel:GetMoneyTypeNameByItemId(id)
    local result
    if id == 90010003 then
        result = "Diamond"
    elseif id == 90010004 then
        result = "Bound Diamond"
    end
    return result
end

function FreeGiftModel:ModifyInfoList(data)
    --table.merge(self.info_list, data)
    for i = 1, #self.info_list do
        if self.info_list[i].act_id == data.act_id then
            self.info_list[i] = data
            break
        end
    end
end

function FreeGiftModel:IsActOver()
    return os.time() > self.info_list[1].etime
end

function FreeGiftModel:GetActEndTime()
    return self.info_list[1].etime
end

function FreeGiftModel:AddRDByActId(act_id)
    self.rd_list[act_id] = true
end

function FreeGiftModel:RemoveRDByActId(act_id)
    table.removebykey(self.rd_list, act_id)
end

function FreeGiftModel:CheckIsShowRDByActId(act_id, is_cur_sel)
    if not is_cur_sel then
        return self.rd_list[act_id]
    else
        return self.rd_list[self.cur_sel_act_id]
    end
end

--是否有可领取的
function FreeGiftModel:IsHaveCanFetchRewa()
    local result
    for i, info in pairs(self.info_list) do
        if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            result = true
            break
        end
    end
    return result
end

function FreeGiftModel:SetCurDefaultTheme()
    local havent_bought_list = {}
    local have_bought_list = {}
    for i = 1, #self.info_list do
        local info = self.info_list[i]
        if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            havent_bought_list[#havent_bought_list + 1] = info.act_id
        else
            have_bought_list[#have_bought_list + 1] = info.act_id
        end
    end
    local bought_num = #havent_bought_list
    --1:默认选中第一个     2：可领取/已购第一个     3：未购买第一个
    --全部买过 / 活动结束
    if bought_num == 0 or self:IsActOver() then
        --(2)
        local is_can_fetch, first_id = FreeGiftController.GetInstance():CheckRD(true)
        if not first_id then
            self.defaut_act_id = 100401
            return
        end
        if is_can_fetch then
            --可领取
            self.defaut_act_id = first_id
        else
            self.defaut_act_id = have_bought_list[1]
        end
    elseif bought_num > 0 then
        --买过，没有全买，活动时间内  (3)
        self.defaut_act_id = havent_bought_list[1]
    end
end

function FreeGiftModel:GetLongestEndTime()
    -- GetActEndTime
    local etime = 0
    local list = self:GetInfo()
    for _, info in pairs(list) do
        if info.etime > etime then
            etime = info.etime
        end
    end
    etime = etime == 0 and os.time() or etime
    return etime
end